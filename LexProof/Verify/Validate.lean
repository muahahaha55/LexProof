import LexProof.Core.Norm

/-!
# Well-formedness validator

Runs **before** the conflict checker and returns findings, each naming the
offending norm. Structural defects are caught here rather than surfacing late
as `unknown`, which is what lets `unknown` keep a narrow meaning and lets a
finding point at the norm that is actually wrong.

Checks: empty norm list, duplicate ids, out-of-range atom index, dangling
reference (against a catalog passed in), unknown id in `overrides`, priority
cycle (mutual override is the two-element case).

The only part of this file with a proof is `wf_of_validate_nil`, which backs
theorem (f). Cycle detection is **not** proved correct — see the report.
-/

namespace LexProof

variable {S P : Type}

/-- One structural defect. Every constructor names the norm at fault. -/
inductive Finding
  /-- Nothing to check. Never silently a consistency claim. -/
  | emptyNormList
  | duplicateId (norm : NormId)
  | atomIndexOutOfRange (norm : NormId)
  | danglingReference (norm : NormId) (ref : String)
  | unknownOverride (norm : NormId) (target : NormId)
  /-- `norm` can reach itself through `overrides`; mutual override is the
  two-element case. -/
  | priorityCycle (norm : NormId)
  deriving Repr, DecidableEq

/-! ## Individual checks -/

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

/-- One round of closing a set of ids under `succsOf`. -/
def reachStep (ns : List Norm) (acc : List NormId) : List NormId :=
  (acc ++ acc.flatMap (succsOf ns)).eraseDups

/-- Close under `succsOf`, `k` rounds. `k = ns.length` rounds suffice for a
graph with at most `ns.length` nodes. -/
def reachN (ns : List Norm) : Nat → List NormId → List NormId
  | 0, acc => acc
  | k + 1, acc => reachN ns k (reachStep ns acc)

/-- Can the norm reach itself through `overrides`? -/
def inPriorityCycle (ns : List Norm) (n : Norm) : Bool :=
  (reachN ns ns.length (succsOf ns n.id)).contains n.id

/-! ## Findings, one component per defect class -/

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
    duplicateIdFindings ns ++
    malformedFindings A ns ++
    danglingFindings catalog ns ++
    unknownOverrideFindings ns ++
    cycleFindings ns

/-! ## The one proved property -/

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

end LexProof
