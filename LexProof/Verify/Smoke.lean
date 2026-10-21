import LexProof.Verify.Conflict

/-!
# Smoke test for the conflict checker

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

/-- The atom table: condition atoms are indices into this. -/
def atoms : Atoms Sit Params where
  sit := [("overdue", fun s => s.overdue), ("disputed", fun s => s.disputed)]
  param := [("serious", fun p => p.serious)]

/-! ## Two norms about the same act -/

def srcA : SourceId :=
  { docId := "SMOKE", docType := .decree
  , effective := ⟨2026, 1, 1⟩, article := "Điều 1" }

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

def conflicting : List Norm := [normA, normB]
def fixed : List Norm := [normA, normBFixed]

#eval check atoms conflicting
#eval check atoms fixed

/-! ## What the checker reports -/

/-- The deliberate conflict is found, with the full witness. -/
theorem smoke_conflict :
    check atoms conflicting =
      .conflict
        { situation := ⟨true, false⟩
        , params := ⟨false⟩
        , left := "A"
        , right := "B"
        , modalities := (.obligation, .prohibition)
        , sources := (srcA, srcB) } := by
  decide

/-- With the conflict removed, the checker reports consistency, and says over
exactly which norms, articles and domain size. -/
theorem smoke_consistent :
    check atoms fixed =
      .consistentOn
        { docId := "SMOKE"
        , normIds := ["A", "B"]
        , articles := ["Điều 1", "Điều 2"]
        , situations := 4
        , params := 2 } := by
  decide

/-- The reported witness is a real `Conflict`, via `isConflictAt_eq_true_iff`. -/
theorem smoke_conflict_is_real :
    Conflict atoms normA normB ⟨false⟩ ⟨true, false⟩ :=
  (isConflictAt_eq_true_iff atoms normA normB ⟨false⟩ ⟨true, false⟩).mp (by decide)

/-- And the `consistentOn` report really does rule out every conflict, via
`not_conflict_of_consistentOn`. -/
theorem smoke_no_conflict_anywhere :
    ∀ n₁ ∈ fixed, ∀ n₂ ∈ fixed, ∀ (π : Params) (s : Sit),
      ¬ Conflict atoms n₁ n₂ π s :=
  not_conflict_of_consistentOn smoke_consistent

end LexProof.Smoke
