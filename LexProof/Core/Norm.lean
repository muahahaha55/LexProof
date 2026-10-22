import LexProof.Core.Finite

/-!
# Norms

A `Norm` is one formalized provision. Conditions are a printable syntax tree
(`Cond`), not an opaque function, so a condition can be shown to a human
reviewer and inspected by the checker.

`Cond` refers to the situation and to open-textured parameters by index into an
`Atoms` table, so `Norm` itself is plain, comparable data and does not depend on
the situation type.

`Atoms` also carries an integrity constraint `valid`, which rules out
situation/parameter combinations that cannot occur. `valid` is part of the trust
base: nothing proves it matches the law, and making it too strong silently hides
conflicts.
-/

namespace LexProof

/-- Deontic modality of a provision. -/
inductive Modality
  | obligation
  | prohibition
  | permission
  deriving Repr, DecidableEq, Inhabited

/-- Type of the source document. Kept for the later level 2 extension. -/
inductive DocType
  | law
  | decree
  | circular
  | decision
  | other (name : String)
  deriving Repr, DecidableEq, Inhabited

/-- A calendar date. Not validated: `⟨2026, 99, 99⟩` is well-typed. -/
structure Date where
  year : Nat
  month : Nat
  day : Nat
  deriving Repr, DecidableEq, Inhabited

/-- Where a norm came from. `docId`, `docType` and `effective` are unused at
level 1 but are kept so level 2 needs no schema change. -/
structure SourceId where
  docId : String
  docType : DocType
  effective : Date
  /-- e.g. "Điều 12 khoản 2 điểm a". Every formalized rule keeps this. -/
  article : String
  deriving Repr, DecidableEq, Inhabited

/-- Identifier of a norm within a document. -/
abbrev NormId := String

/-- An act is an opaque glossary id declared per document, not structured. -/
abbrev Act := String

/-- Condition syntax. Atoms are indices into an `Atoms` table: `sit i` reads a
situation field, `param i` reads an open-textured parameter. -/
inductive Cond
  | tt
  | ff
  | sit (i : Nat)
  | param (i : Nat)
  | not (c : Cond)
  | and (a b : Cond)
  | or (a b : Cond)
  deriving Repr, DecidableEq, Inhabited

/-- Named Bool-valued readers for the situation type `S` and the open-concept
parameter type `P`, plus an integrity constraint.

`valid π s` says the pair can actually occur; the checker ignores every pair it
rejects. The default admits everything, so a document that needs no constraint
is unaffected. **`valid` is in the trust base**: an over-strong `valid` hides
real conflicts and no theorem can detect that. -/
structure Atoms (S P : Type) where
  sit : List (String × (S → Bool))
  param : List (String × (P → Bool))
  valid : P → S → Bool := fun _ _ => true

namespace Cond

variable {S P : Type}

/-- Evaluate a condition. `none` means the condition is malformed (an atom index
is out of range); it is never silently treated as `false`, so the caller can
fail closed and report `unknown`. -/
def eval (A : Atoms S P) (π : P) (s : S) : Cond → Option Bool
  | .tt => some true
  | .ff => some false
  | .sit i => (A.sit[i]?).map fun f => f.2 s
  | .param i => (A.param[i]?).map fun f => f.2 π
  | .not c => (c.eval A π s).map (!·)
  | .and a b =>
    match a.eval A π s, b.eval A π s with
    | some x, some y => some (x && y)
    | _, _ => none
  | .or a b =>
    match a.eval A π s, b.eval A π s with
    | some x, some y => some (x || y)
    | _, _ => none

/-- Indices of the open-textured parameters a condition mentions. Used to name
the parameters a conditional conflict depends on. -/
def paramIdxs : Cond → List Nat
  | .tt | .ff | .sit _ => []
  | .param i => [i]
  | .not c => c.paramIdxs
  | .and a b => a.paramIdxs ++ b.paramIdxs
  | .or a b => a.paramIdxs ++ b.paramIdxs

/-- Evaluate a disjunction of conditions; `none` if any of them is malformed. -/
def evalAny (A : Atoms S P) (π : P) (s : S) : List Cond → Option Bool
  | [] => some false
  | c :: cs =>
    match c.eval A π s, evalAny A π s cs with
    | some x, some y => some (x || y)
    | _, _ => none

/-- Every atom index is in range for tables of the given sizes. This is a
*static* check: it needs no situation and no parameter assignment. -/
def wf (nsit nparam : Nat) : Cond → Bool
  | .tt | .ff => true
  | .sit i => decide (i < nsit)
  | .param i => decide (i < nparam)
  | .not c => c.wf nsit nparam
  | .and a b => a.wf nsit nparam && b.wf nsit nparam
  | .or a b => a.wf nsit nparam && b.wf nsit nparam

/-- A well-formed condition always evaluates. This is what lets the validator
promise that `applies` never returns `none`. -/
theorem eval_isSome_of_wf (A : Atoms S P) (π : P) (s : S) (c : Cond) :
    c.wf A.sit.length A.param.length = true → (c.eval A π s).isSome = true := by
  induction c with
  | tt => intro _; rfl
  | ff => intro _; rfl
  | sit i =>
    intro h
    simp only [wf, decide_eq_true_eq] at h
    simp [eval, List.getElem?_eq_getElem h]
  | param i =>
    intro h
    simp only [wf, decide_eq_true_eq] at h
    simp [eval, List.getElem?_eq_getElem h]
  | not c ih =>
    intro h
    simp only [wf] at h
    have hc := ih h
    cases hec : c.eval A π s with
    | none => rw [hec] at hc; simp at hc
    | some x => simp [eval, hec]
  | and a b iha ihb =>
    intro h
    simp only [wf, Bool.and_eq_true] at h
    have ha := iha h.1
    have hb := ihb h.2
    cases hea : a.eval A π s with
    | none => rw [hea] at ha; simp at ha
    | some x =>
      cases heb : b.eval A π s with
      | none => rw [heb] at hb; simp at hb
      | some y => simp [eval, hea, heb]
  | or a b iha ihb =>
    intro h
    simp only [wf, Bool.and_eq_true] at h
    have ha := iha h.1
    have hb := ihb h.2
    cases hea : a.eval A π s with
    | none => rw [hea] at ha; simp at ha
    | some x =>
      cases heb : b.eval A π s with
      | none => rw [heb] at hb; simp at hb
      | some y => simp [eval, hea, heb]

/-- A list of well-formed conditions always evaluates. -/
theorem evalAny_isSome_of_wf (A : Atoms S P) (π : P) (s : S) (cs : List Cond) :
    cs.all (wf A.sit.length A.param.length) = true →
    (evalAny A π s cs).isSome = true := by
  induction cs with
  | nil => intro _; rfl
  | cons c cs ih =>
    intro h
    simp only [List.all_cons, Bool.and_eq_true] at h
    have hc := eval_isSome_of_wf A π s c h.1
    have hcs := ih h.2
    cases hec : c.eval A π s with
    | none => rw [hec] at hc; simp at hc
    | some x =>
      cases hecs : evalAny A π s cs with
      | none => rw [hecs] at hcs; simp at hcs
      | some y => simp [evalAny, hec, hecs]

end Cond

/-- Explicit priority: the norms this norm takes precedence over. There is no
implicit lex specialis; absence of priority means unresolved. -/
structure Priority where
  overrides : List NormId
  deriving Repr, DecidableEq, Inhabited

/-- One formalized provision. -/
structure Norm where
  id : NormId
  modality : Modality
  act : Act
  /-- When the norm applies. -/
  condition : Cond
  /-- Carve-outs: these change *when* the norm applies. -/
  exceptions : List Cond
  /-- Resolves a clash with another norm that also applies. -/
  priority : Option Priority
  source : SourceId
  /-- Articles this provision cites, for the dangling-reference check. -/
  references : List String
  deriving Repr, DecidableEq, Inhabited

namespace Norm

variable {S P : Type}

/-- Does the norm apply at `(π, s)`? `none` means malformed, i.e. unknown. -/
def applies (n : Norm) (A : Atoms S P) (π : P) (s : S) : Option Bool :=
  match n.condition.eval A π s, Cond.evalAny A π s n.exceptions with
  | some c, some e => some (c && !e)
  | _, _ => none

/-- Parameter indices mentioned anywhere in the norm. -/
def paramIdxs (n : Norm) : List Nat :=
  n.condition.paramIdxs ++ n.exceptions.flatMap Cond.paramIdxs

/-- Every atom index of the norm is in range for `A`. Checked statically, so a
finding can name the offending norm instead of waiting for evaluation. -/
def wf (A : Atoms S P) (n : Norm) : Bool :=
  n.condition.wf A.sit.length A.param.length &&
  n.exceptions.all (Cond.wf A.sit.length A.param.length)

/-- A well-formed norm always evaluates, at every `(π, s)`. -/
theorem applies_isSome_of_wf (A : Atoms S P) (n : Norm) (h : n.wf A = true)
    (π : P) (s : S) : (n.applies A π s).isSome = true := by
  simp only [wf, Bool.and_eq_true] at h
  have hc := Cond.eval_isSome_of_wf A π s n.condition h.1
  have he := Cond.evalAny_isSome_of_wf A π s n.exceptions h.2
  cases hec : n.condition.eval A π s with
  | none => rw [hec] at hc; simp at hc
  | some c =>
    cases hee : Cond.evalAny A π s n.exceptions with
    | none => rw [hee] at he; simp at he
    | some e => simp [applies, hec, hee]

/-- The ids this norm claims precedence over; `[]` when it claims none. -/
def overrideIds (n : Norm) : List NormId :=
  match n.priority with
  | some p => p.overrides
  | none => []

/-- Does `n₁` claim precedence over `n₂`? One direction only. -/
def overridesOther (n₁ n₂ : Norm) : Bool := n₁.overrideIds.contains n₂.id

/-- A clash is resolved only when **exactly one** of the two norms claims
precedence. Mutual override is not a resolution: it is a priority cycle, which
the validator reports as a finding. Absence of priority leaves the clash
unresolved, so it is still reported. -/
def resolved (n₁ n₂ : Norm) : Bool :=
  n₁.overridesOther n₂ ^^ n₂.overridesOther n₁

/-- Which norm prevails, when exactly one claims precedence. -/
def winner? (n₁ n₂ : Norm) : Option NormId :=
  if n₁.overridesOther n₂ && !n₂.overridesOther n₁ then some n₁.id
  else if n₂.overridesOther n₁ && !n₁.overridesOther n₂ then some n₂.id
  else none

/-- `resolved` does not depend on the order of the two norms. -/
theorem resolved_comm (n₁ n₂ : Norm) : n₁.resolved n₂ = n₂.resolved n₁ :=
  Bool.xor_comm _ _

end Norm

/-- Modalities that clash: obligation~prohibition and permission~prohibition.
obligation~permission does not clash. Irreflexive. -/
def Incompatible : Modality → Modality → Bool
  | .obligation, .prohibition => true
  | .prohibition, .obligation => true
  | .permission, .prohibition => true
  | .prohibition, .permission => true
  | _, _ => false

/-- `Incompatible` does not depend on the order of the two modalities. -/
theorem Incompatible_comm (a b : Modality) : Incompatible a b = Incompatible b a := by
  cases a <;> cases b <;> rfl

/-- No modality clashes with itself. This is what makes a norm unable to
conflict with itself. -/
theorem Incompatible_irrefl (m : Modality) : Incompatible m m = false := by
  cases m <;> rfl

end LexProof
