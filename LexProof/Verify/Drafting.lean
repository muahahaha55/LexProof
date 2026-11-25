import LexProof.Verify.Conflict
import LexProof.Core.AtomTable

/-!
# Drafting defects: dead norms, redundant norms, exceptions that never fire (ADR-0030)

Not conflicts: a separate, lower-priority check (Should). Each «clean» result is an **existential** statement, so it
is proved by a witness that an untrusted tool finds and the kernel checks at one point (`decide`), never by walking
the whole domain:

* `Live A n` — some point where `n` applies (a norm that never applies is dead);
* `NotSubsumed A a b` — some point where `a` applies and `b` does not (otherwise, for two norms on one act with one
  modality, `a` adds nothing to `b`);
* `ExcFires A n e` — some point where the condition of `n` and the exception `e` both hold (otherwise the exception
  never changes anything).

What a certificate is: a list of points (in any encoding `W`, read by a decoder `dec` that may refuse), keyed by norm id (and the second id, or the exception index). `checkLive`,
`checkNotSubsumed`, `checkExcFires` are Boolean and decidable; the `*_of_check` theorems say that `true` implies the
statement for **every** norm (pair, exception) of the list. A missing or wrong witness makes the check `false`, and
the build fails. An item with no witness goes in the `skip` list instead, and the theorem excludes exactly
it: the tool reports it as «unknown» (a possible defect), never as clean and never as a proven defect (fail closed). Proving that a norm **is** dead or
redundant needs a universal statement and is not done here.

Norms are named by id, so these theorems assume the ids of the list are distinct (the validator already reports
duplicate ids as a finding, and a promoted module is `silent`).
-/

namespace LexProof

variable {S P : Type}

/-! ## The statements -/

def Live (A : Atoms S P) (n : Norm) : Prop :=
  ∃ π s, n.applies A π s = some true

def NotSubsumed (A : Atoms S P) (a b : Norm) : Prop :=
  ∃ π s, a.applies A π s = some true ∧ b.applies A π s = some false

def ExcFires (A : Atoms S P) (n : Norm) (e : Cond) : Prop :=
  ∃ π s, n.condition.eval A π s = some true ∧ e.eval A π s = some true

/-- Two norms that could make each other redundant: same act and same modality. -/
def SameDuty (a b : Norm) : Bool := a.act == b.act && a.modality == b.modality

/-! ## Certificates and their checks -/

def lookup1 {W : Type} (c : List (String × W)) (i : String) : Option W :=
  (c.find? (·.1 == i)).map (·.2)

def lookup2 {W : Type} (c : List (String × String × W)) (i j : String) : Option W :=
  (c.find? (fun x => x.1 == i && x.2.1 == j)).map (·.2.2)

def lookupE {W : Type} (c : List (String × Nat × W)) (i : String) (k : Nat) : Option W :=
  (c.find? (fun x => x.1 == i && x.2.1 == k)).map (·.2.2)

def checkLive {W : Type} (A : Atoms S P) (dec : W → Option (P × S)) (ns : List Norm) (c : List (String × W))
    (skip : List String) : Bool :=
  ns.all fun n => skip.contains n.id || match (lookup1 c n.id).bind dec with
    | some (π, s) => n.applies A π s == some true
    | none => false

def checkNotSubsumed {W : Type} (A : Atoms S P) (dec : W → Option (P × S)) (ns : List Norm) (c : List (String × String × W))
    (skip : List (String × String)) : Bool :=
  ns.all fun a => ns.all fun b =>
    if a.id != b.id && SameDuty a b && !skip.contains (a.id, b.id) then
      match (lookup2 c a.id b.id).bind dec with
      | some (π, s) => a.applies A π s == some true && b.applies A π s == some false
      | none => false
    else true

def checkExcFires {W : Type} (A : Atoms S P) (dec : W → Option (P × S)) (ns : List Norm) (c : List (String × Nat × W))
    (skip : List (String × Nat)) : Bool :=
  ns.all fun n => (List.range n.exceptions.length).all fun k => skip.contains (n.id, k) ||
    match (lookupE c n.id k).bind dec, n.exceptions[k]? with
    | some (π, s), some e => n.condition.eval A π s == some true && e.eval A π s == some true
    | _, _ => false

/-! ## Soundness of the checks -/

theorem live_of_check {W : Type} {A : Atoms S P} {dec : W → Option (P × S)} {ns : List Norm} {c : List (String × W)}
    {skip : List String} (h : checkLive A dec ns c skip = true) : ∀ n ∈ ns, n.id ∉ skip → Live A n := by
  intro n hn hs
  have := List.all_eq_true.1 h n hn
  simp only [Bool.or_eq_true, List.contains_iff_mem, hs, false_or] at this
  split at this
  · rename_i π s _
    exact ⟨π, s, by simpa using this⟩
  · cases this

theorem notSubsumed_of_check {W : Type} {A : Atoms S P} {dec : W → Option (P × S)} {ns : List Norm}
    {c : List (String × String × W)} {skip : List (String × String)} (h : checkNotSubsumed A dec ns c skip = true) :
    ∀ a ∈ ns, ∀ b ∈ ns, a.id ≠ b.id → SameDuty a b = true → (a.id, b.id) ∉ skip → NotSubsumed A a b := by
  intro a ha b hb hid hd hs
  have h1 := List.all_eq_true.1 (List.all_eq_true.1 h a ha) b hb
  have hc : (a.id != b.id && SameDuty a b && !skip.contains (a.id, b.id)) = true := by
    simp [hid, hd, hs]
  simp only [hc, ↓reduceIte] at h1
  split at h1
  · rename_i π s _
    simp only [Bool.and_eq_true, beq_iff_eq] at h1
    exact ⟨π, s, h1.1, h1.2⟩
  · cases h1

theorem excFires_of_check {W : Type} {A : Atoms S P} {dec : W → Option (P × S)} {ns : List Norm}
    {c : List (String × Nat × W)} {skip : List (String × Nat)} (h : checkExcFires A dec ns c skip = true) :
    ∀ n ∈ ns, ∀ (k : Nat) (hk : k < n.exceptions.length), (n.id, k) ∉ skip → ExcFires A n n.exceptions[k] := by
  intro n hn k hk hs
  have h1 := List.all_eq_true.1 (List.all_eq_true.1 h n hn) k (List.mem_range.2 hk)
  simp only [Bool.or_eq_true, List.contains_iff_mem, hs, false_or] at h1
  rw [List.getElem?_eq_getElem hk] at h1
  revert h1
  cases (lookupE c n.id k).bind dec with
  | none => intro h1; cases h1
  | some ps =>
    obtain ⟨π, s⟩ := ps
    intro h1
    simp only [Bool.and_eq_true, beq_iff_eq] at h1
    exact ⟨π, s, h1.1, h1.2⟩

/-- Decoder for modules over atom tables: two raw value lists, accepted only if they are legal valuations. -/
def decodeVal {ts tp : AtomTable} : List Nat × List Nat → Option (Valuation tp × Valuation ts)
  | (a, b) =>
    if ha : legalVals tp.sizes a = true then
      if hb : legalVals ts.sizes b = true then some (⟨a, ha⟩, ⟨b, hb⟩) else none
    else none

/-- `NotSubsumed` is what it says: `a` is not covered by `b` (some point where `a` applies and `b` does not). -/
theorem not_covered_of_notSubsumed {A : Atoms S P} {a b : Norm} (h : NotSubsumed A a b) :
    ¬ ∀ π s, a.applies A π s = some true → b.applies A π s = some true := by
  intro hall
  obtain ⟨π, s, ha, hb⟩ := h
  rw [hall π s ha] at hb
  cases hb

end LexProof
