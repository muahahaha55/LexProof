import LexProof.Core.Norm

/-!
# Well-formedness validator

Runs **before** the conflict checker and returns findings, each naming the
offending norm. Structural defects are caught here rather than surfacing late
as `unknown`, which is what lets `unknown` keep a narrow meaning and lets a
finding point at the norm that is actually wrong.

Checks: empty norm list, mixed `docId`s, duplicate ids, out-of-range atom
index, dangling reference (against a catalog passed in), unknown id in
`overrides`, priority cycle (mutual override is the two-element case).

Two things are proved here: `wf_of_validate_nil` (backs theorem (f)) and
`cycle_of_validate_finding` — a reported priority cycle is a **real** cycle of
the `overrides` relation. The converse (every cycle is reported) is **not**
proved; see the trust base section of `docs/traceability.md`.
-/

namespace LexProof

variable {S P : Type}

/-- One structural defect. Every constructor names the norm at fault, except
`emptyNormList` and `mixedDocIds`, which are properties of the list. -/
inductive Finding
  /-- Nothing to check. Never silently a consistency claim. -/
  | emptyNormList
  /-- The list spans more than one document, so a level-1 claim is meaningless
  and `Scope.docId` would be a guess. -/
  | mixedDocIds (docIds : List String)
  | duplicateId (norm : NormId)
  | atomIndexOutOfRange (norm : NormId)
  | danglingReference (norm : NormId) (ref : String)
  | unknownOverride (norm : NormId) (target : NormId)
  /-- `norm` can reach itself through `overrides`; mutual override is the
  two-element case. -/
  | priorityCycle (norm : NormId)
  deriving Repr, DecidableEq

/-! ## Individual checks -/

/-- Insert into a sorted list. Structurally recursive, so it reduces in the
kernel — `List.mergeSort` is well-founded and would block every `decide`. -/
def insertSorted (x : String) : List String → List String
  | [] => [x]
  | y :: ys => if x < y then x :: y :: ys else y :: insertSorted x ys

/-- Insertion sort on strings. -/
def sortStrings : List String → List String
  | [] => []
  | x :: xs => insertSorted x (sortStrings xs)

theorem mem_insertSorted {x a : String} {l : List String} :
    a ∈ insertSorted x l ↔ a = x ∨ a ∈ l := by
  induction l with
  | nil => simp [insertSorted]
  | cons y ys ih =>
    simp only [insertSorted]
    split
    · simp
    · simp only [List.mem_cons, ih]
      constructor
      · rintro (rfl | rfl | h) <;> simp_all
      · rintro (rfl | rfl | h) <;> simp_all

theorem mem_sortStrings {a : String} {l : List String} :
    a ∈ sortStrings l ↔ a ∈ l := by
  induction l with
  | nil => simp [sortStrings]
  | cons x xs ih => simp [sortStrings, mem_insertSorted, ih]

/-- The distinct `docId`s the list spans, deduplicated **and sorted**, so that
neither this nor `Finding.mixedDocIds` depends on the order of the norm list. -/
def docIdsOf (ns : List Norm) : List String :=
  sortStrings ((ns.map fun n => n.source.docId).eraseDups)

/-- The document the list belongs to, or `none` when it is empty or mixed.
`Scope.docId` uses this instead of guessing from the head of the list. -/
def singleDocId? (ns : List Norm) : Option String :=
  match docIdsOf ns with
  | [d] => some d
  | _ => none

/-- Ids that occur more than once in the list. -/
def duplicateIds (ns : List Norm) : List NormId :=
  let ids := ns.map fun n => n.id
  (ids.filter fun i => 1 < (ids.filter fun j => j == i).length).eraseDups

/-- Norms whose atom indices are out of range for `A`, by id. Also used by the
checker to list unevaluable norms instead of skipping them. -/
def unevaluableIds (A : Atoms S P) (ns : List Norm) : List NormId :=
  (ns.filter fun n => !(n.wf A)).map fun n => n.id

/-- Ids this norm claims precedence over, as a step of the priority graph. -/
def succsOf (ns : List Norm) (i : NormId) : List NormId :=
  match ns.find? fun n => n.id == i with
  | some n => n.overrideIds
  | none => []

/-- `Reaches ns i j`: a non-empty path from `i` to `j` in the `overrides`
graph. `Reaches ns i i` is exactly what "`i` lies on a cycle" means. -/
inductive Reaches (ns : List Norm) : NormId → NormId → Prop
  | base {i j : NormId} (h : j ∈ succsOf ns i) : Reaches ns i j
  | step {i j k : NormId} (t : Reaches ns i j) (h : k ∈ succsOf ns j) :
      Reaches ns i k

/-- One round of closing a set of ids under `succsOf`. -/
def reachStep (ns : List Norm) (acc : List NormId) : List NormId :=
  (acc ++ acc.flatMap (succsOf ns)).eraseDups

/-- Close under `succsOf`, `k` rounds. `k = ns.length` rounds is a bound, not a
proved sufficiency — see `cycle_of_validate_finding` and the trust base. -/
def reachN (ns : List Norm) : Nat → List NormId → List NormId
  | 0, acc => acc
  | k + 1, acc => reachN ns k (reachStep ns acc)

/-- Can the norm reach itself through `overrides`? -/
def inPriorityCycle (ns : List Norm) (n : Norm) : Bool :=
  (reachN ns ns.length (succsOf ns n.id)).contains n.id

/-! ## Findings, one component per defect class -/

def mixedDocIdFindings (ns : List Norm) : List Finding :=
  match docIdsOf ns with
  | [] => []
  | [_] => []
  | ds => [Finding.mixedDocIds ds]

def duplicateIdFindings (ns : List Norm) : List Finding :=
  (duplicateIds ns).map Finding.duplicateId

def malformedFindings (A : Atoms S P) (ns : List Norm) : List Finding :=
  (ns.filter fun n => !(n.wf A)).map fun n => Finding.atomIndexOutOfRange n.id

def danglingFindings (catalog : List String) (ns : List Norm) : List Finding :=
  ns.flatMap fun n =>
    (n.references.filter fun r => !catalog.contains r).map fun r =>
      Finding.danglingReference n.id r

def unknownOverrideFindings (ns : List Norm) : List Finding :=
  ns.flatMap fun n =>
    (n.overrideIds.filter fun t => !(ns.map fun m => m.id).contains t).map fun t =>
      Finding.unknownOverride n.id t

def cycleFindings (ns : List Norm) : List Finding :=
  (ns.filter fun n => inPriorityCycle ns n).map fun n => Finding.priorityCycle n.id

/-- Run every check. `[]` means no structural defect was found; it says nothing
about consistency, and nothing about faithfulness. -/
def validate (A : Atoms S P) (catalog : List String) (ns : List Norm) : List Finding :=
  match ns with
  | [] => [Finding.emptyNormList]
  | _ =>
    mixedDocIdFindings ns ++
    duplicateIdFindings ns ++
    malformedFindings A ns ++
    danglingFindings catalog ns ++
    unknownOverrideFindings ns ++
    cycleFindings ns

/-! ## Proved property 1: a silent validator means everything evaluates -/

/-- If the validator is silent, every norm is statically well-formed. Combined
with `Norm.applies_isSome_of_wf` this gives theorem (f). -/
theorem wf_of_validate_nil {A : Atoms S P} {catalog : List String} {ns : List Norm}
    (h : validate A catalog ns = []) : ∀ n ∈ ns, n.wf A = true := by
  intro n hn
  cases hw : Norm.wf A n with
  | true => rfl
  | false =>
    exfalso
    have hmem : Finding.atomIndexOutOfRange n.id ∈ validate A catalog ns := by
      cases ns with
      | nil => simp at hn
      | cons n₀ rest =>
        simp only [validate]
        refine List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl
          (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inr ?_)))))))
        exact List.mem_map.mpr
          ⟨n, List.mem_filter.mpr ⟨hn, by simp [hw]⟩, rfl⟩
    rw [h] at hmem
    simp at hmem

/-! ## Proved property 2: a reported cycle is a real cycle

Only this direction is proved. See `docs/traceability.md` for why the converse
is not, and what that costs. -/

/-- Everything `reachN` collects from a set already reachable from `i` is still
reachable from `i`. -/
theorem reachN_sound (ns : List Norm) (i : NormId) :
    ∀ (k : Nat) (acc : List NormId), (∀ x ∈ acc, Reaches ns i x) →
      ∀ x ∈ reachN ns k acc, Reaches ns i x := by
  intro k
  induction k with
  | zero => intro acc hacc x hx; exact hacc x hx
  | succ k ih =>
    intro acc hacc x hx
    refine ih (reachStep ns acc) ?_ x hx
    intro y hy
    simp only [reachStep, List.mem_eraseDups, List.mem_append] at hy
    rcases hy with hy | hy
    · exact hacc y hy
    · rcases List.mem_flatMap.mp hy with ⟨a, ha, hya⟩
      exact Reaches.step (hacc a ha) hya

/-- `inPriorityCycle` only fires on a real cycle. -/
theorem cycle_of_inPriorityCycle {ns : List Norm} {n : Norm}
    (h : inPriorityCycle ns n = true) : Reaches ns n.id n.id := by
  simp only [inPriorityCycle, List.contains_eq_mem, decide_eq_true_eq] at h
  exact reachN_sound ns n.id ns.length (succsOf ns n.id)
    (fun _ hx => Reaches.base hx) n.id h

theorem mem_cycleFindings {ns : List Norm} {i : NormId}
    (h : Finding.priorityCycle i ∈ cycleFindings ns) :
    ∃ n ∈ ns, n.id = i ∧ inPriorityCycle ns n = true := by
  rcases List.mem_map.mp h with ⟨n, hn, heq⟩
  rcases List.mem_filter.mp hn with ⟨hmem, hcyc⟩
  refine ⟨n, hmem, ?_, hcyc⟩
  injection heq

/-- A `priorityCycle` finding never comes from any other check. -/
theorem priorityCycle_mem_cycleFindings {A : Atoms S P} {catalog : List String}
    {ns : List Norm} {i : NormId}
    (h : Finding.priorityCycle i ∈ validate A catalog ns) :
    Finding.priorityCycle i ∈ cycleFindings ns := by
  cases ns with
  | nil => simp [validate] at h
  | cons n₀ rest =>
    simp only [validate, List.mem_append] at h
    rcases h with ((((h | h) | h) | h) | h) | h
    · simp [mixedDocIdFindings] at h; split at h <;> simp at h
    · simp [duplicateIdFindings] at h
    · simp [malformedFindings] at h
    · simp [danglingFindings] at h
    · simp [unknownOverrideFindings] at h
    · exact h

/-- **Soundness of cycle detection.** If the validator reports a priority
cycle for `i`, then `i` really lies on a cycle of the `overrides` relation. -/
theorem cycle_of_validate_finding {A : Atoms S P} {catalog : List String}
    {ns : List Norm} {i : NormId}
    (h : Finding.priorityCycle i ∈ validate A catalog ns) :
    ∃ n ∈ ns, n.id = i ∧ Reaches ns i i := by
  obtain ⟨n, hn, hid, hcyc⟩ := mem_cycleFindings (priorityCycle_mem_cycleFindings h)
  exact ⟨n, hn, hid, hid ▸ cycle_of_inPriorityCycle hcyc⟩

/-! ## Proved property 3: a silent validator means one document -/

/-- If the validator is silent, the list does not mix documents, so
`singleDocId?` is a real answer rather than a guess. -/
theorem singleDocId_isSome_of_validate_nil {A : Atoms S P} {catalog : List String}
    {ns : List Norm} (hne : ns ≠ []) (h : validate A catalog ns = []) :
    (singleDocId? ns).isSome = true := by
  cases ns with
  | nil => exact absurd rfl hne
  | cons n₀ rest =>
    simp only [singleDocId?]
    cases hd : docIdsOf (n₀ :: rest) with
    | nil =>
      exfalso
      have : (n₀.source.docId) ∈ docIdsOf (n₀ :: rest) := by
        simp [docIdsOf, mem_sortStrings, List.mem_eraseDups]
      rw [hd] at this; simp at this
    | cons d ds =>
      cases ds with
      | nil => simp
      | cons d₂ ds₂ =>
        exfalso
        have hmem : Finding.mixedDocIds (d :: d₂ :: ds₂) ∈
            validate A catalog (n₀ :: rest) := by
          simp only [validate]
          refine List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl
            (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl
              (List.mem_append.mpr (Or.inl ?_)))))))))
          simp only [mixedDocIdFindings, hd]
          simp
        rw [h] at hmem
        simp at hmem

end LexProof
