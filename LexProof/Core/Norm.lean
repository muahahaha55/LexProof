import LexProof.Core.Finite

/-!
# Norms

A `Norm` is one formalized provision. Conditions are a printable syntax tree
(`Cond`), not an opaque function, so a condition can be shown to a human
reviewer and inspected by the checker.

`Cond` refers to the situation and to open-textured parameters by index into an
`Atoms` table, so `Norm` itself is plain, comparable data and does not depend on
the situation type.
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
parameter type `P`. Supplied per document. -/
structure Atoms (S P : Type) where
  sit : List (String × (S → Bool))
  param : List (String × (P → Bool))

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

/-- Does `n₁` explicitly override `n₂`, or vice versa? -/
def resolved (n₁ n₂ : Norm) : Bool :=
  (match n₁.priority with
   | some p => p.overrides.contains n₂.id
   | none => false) ||
  (match n₂.priority with
   | some p => p.overrides.contains n₁.id
   | none => false)

end Norm

/-- Modalities that clash: obligation~prohibition and permission~prohibition.
obligation~permission does not clash. Irreflexive. -/
def Incompatible : Modality → Modality → Bool
  | .obligation, .prohibition => true
  | .prohibition, .obligation => true
  | .permission, .prohibition => true
  | .prohibition, .permission => true
  | _, _ => false

end LexProof
