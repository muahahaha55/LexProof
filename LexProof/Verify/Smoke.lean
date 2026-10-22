import LexProof.Verify.Conflict

/-!
# Smoke test for the conflict checker

The minimal two-norm example: one deliberate conflict, and the same pair with
the conflict removed. Everything goes through `analyze`, the public entry
point. Scenario coverage lives in `LexProof/Verify/Tests.lean`.

Not a `Laws` module: the two norms here are invented to exercise the checker,
they are not an encoding of any real provision and nothing here was reviewed
for faithfulness.
-/

namespace LexProof.Smoke

open LexProof

/-! ## A tiny situation space and one open-textured parameter -/

/-- Situation: two Bool fields, so four situations. -/
structure Sit where
  overdue : Bool
  disputed : Bool
  deriving Repr, DecidableEq

/-- Open-textured parameters: one Bool per concept. Here: whether the breach
counts as "nghiêm trọng". The system never decides this. -/
structure Params where
  serious : Bool
  deriving Repr, DecidableEq

instance : Finite Sit where
  enum := [⟨false, false⟩, ⟨false, true⟩, ⟨true, false⟩, ⟨true, true⟩]
  complete := by
    intro s
    obtain ⟨o, d⟩ := s
    cases o <;> cases d <;> decide

instance : Finite Params where
  enum := [⟨false⟩, ⟨true⟩]
  complete := by
    intro p
    obtain ⟨x⟩ := p
    cases x <;> decide

/-- The atom table. `valid` is left at its default, so every point counts. -/
def atoms : Atoms Sit Params where
  sit := [("overdue", fun s => s.overdue), ("disputed", fun s => s.disputed)]
  param := [("serious", fun p => p.serious)]

/-- The reference catalog `analyze` checks `references` against. -/
def catalog : List String := ["Điều 1", "Điều 2"]

/-! ## Two norms about the same act -/

/-- Source of `normA`. -/
def srcA : SourceId :=
  { docId := "SMOKE", docType := .decree
  , effective := ⟨2026, 1, 1⟩, article := "Điều 1" }

/-- Source of `normB`. -/
def srcB : SourceId :=
  { docId := "SMOKE", docType := .decree
  , effective := ⟨2026, 1, 1⟩, article := "Điều 2" }

/-- Must publish once the deadline has passed. -/
def normA : Norm :=
  { id := "A", modality := .obligation, act := "publish"
  , condition := .sit 0, exceptions := [], priority := none
  , source := srcA, references := [] }

/-- Must not publish once the deadline has passed: clashes with `normA`. -/
def normB : Norm :=
  { id := "B", modality := .prohibition, act := "publish"
  , condition := .sit 0, exceptions := [], priority := none
  , source := srcB, references := [] }

/-- Same as `normB`, but it no longer applies when the deadline has passed, so
the two norms never both apply and the conflict is gone. -/
def normBFixed : Norm :=
  { normB with exceptions := [.sit 0] }

/-- The pair that conflicts. -/
def conflicting : List Norm := [normA, normB]

/-- The same pair with the conflict removed by an exception. -/
def fixed : List Norm := [normA, normBFixed]

/-! ## What `analyze` reports -/

/-- Both lists are structurally sound, so `analyze` reaches the search. -/
theorem smoke_validates : validate atoms catalog conflicting = [] := by decide

theorem smoke_fixed_validates : validate atoms catalog fixed = [] := by decide

/-- The deliberate conflict is found, with the full witness. -/
theorem smoke_conflict :
    (analyze atoms catalog conflicting).witness? =
      some
        { situation := ⟨true, false⟩
        , params := ⟨false⟩
        , left := "A"
        , right := "B"
        , modalities := (.obligation, .prohibition)
        , sources := (srcA, srcB) } := by
  decide

/-- With the conflict removed, the checker reports consistency over exactly the
scope `scopeOf` describes. -/
theorem smoke_consistent :
    analyze atoms catalog fixed =
      .consistentOn (scopeOf Sit Params atoms fixed) (auditOf atoms fixed) := by
  decide

/-- The reported witness is a real `Conflict`, via the bridge lemma. -/
theorem smoke_conflict_is_real :
    Conflict atoms normA normB ⟨false⟩ ⟨true, false⟩ :=
  (Internal.isConflictAt_eq_true_iff atoms normA normB ⟨false⟩ ⟨true, false⟩).mp
    (by decide)

/-- And the `consistentOn` report really does rule out every conflict at every
valid point, via theorem (b). -/
theorem smoke_no_conflict_anywhere :
    ∀ n₁ ∈ fixed, ∀ n₂ ∈ fixed, ∀ (π : Params) (s : Sit),
      atoms.valid π s = true → ¬ Conflict atoms n₁ n₂ π s :=
  not_conflict_of_consistentOn smoke_consistent

/-- Theorem (a)+(c) applied: every reported field belongs to the norm it names. -/
theorem smoke_fields_correct :
    ∃ n₁ ∈ conflicting, ∃ n₂ ∈ conflicting,
      "A" = n₁.id ∧ "B" = n₂.id ∧
      (Modality.obligation, Modality.prohibition) = (n₁.modality, n₂.modality) ∧
      (srcA, srcB) = (n₁.source, n₂.source) ∧
      atoms.valid ⟨false⟩ ⟨true, false⟩ = true ∧
      Conflict atoms n₁ n₂ ⟨false⟩ ⟨true, false⟩ :=
  conflict_of_witness smoke_conflict

end LexProof.Smoke
