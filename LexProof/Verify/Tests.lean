import LexProof.Verify.Smoke

/-!
# Scenario tests

One scenario per structural defect and per reporting path. Every expected
result is pinned exactly and checked by `decide`, so a change in behaviour
breaks the build rather than passing quietly.

Reuses the situation space, atom table and two norms of `Smoke`. Like `Smoke`,
this is **not** a `Laws` module: the norms are invented and nothing here was
reviewed for faithfulness.
-/

namespace LexProof.Tests

open LexProof LexProof.Smoke

/-- The reference catalog the validator checks `references` against. -/
def catalog : List String := ["Điều 1", "Điều 2"]

def srcOf (a : String) : SourceId :=
  { docId := "TEST", docType := .decree, effective := ⟨2026, 1, 1⟩, article := a }

/-- Same atoms as `Smoke`, but an integrity constraint rules out every overdue
situation — which is exactly where `normA` and `normB` clash. -/
def atomsRestricted : Atoms Sit Params where
  sit := [("overdue", fun s => s.overdue), ("disputed", fun s => s.disputed)]
  param := [("serious", fun p => p.serious)]
  valid := fun _ s => !s.overdue

/-! ## 1. Priority cycle -/

def cycA : Norm := { normA with priority := some ⟨["B"]⟩ }
def cycB : Norm := { normB with priority := some ⟨["A"]⟩ }
def cyclePair : List Norm := [cycA, cycB]

/-- Mutual override is reported as a cycle, naming both norms. -/
theorem priority_cycle_found :
    validate atomsRestricted catalog cyclePair =
      [Finding.priorityCycle "A", Finding.priorityCycle "B"] := by
  decide

/-- And mutual override is **not** a resolution: the clash stays unresolved
rather than being silently settled (D13). -/
theorem mutual_override_not_resolved : Norm.resolved cycA cycB = false := by
  decide

/-! ## 2. Duplicate norm id -/

def dupPair : List Norm := [normA, { normB with id := "A" }]

theorem duplicate_id_found :
    validate atomsRestricted catalog dupPair = [Finding.duplicateId "A"] := by
  decide

/-! ## 3. Dangling reference -/

def danglingNorm : Norm :=
  { normA with id := "D", references := ["Điều 99"], source := srcOf "Điều 3" }
def danglingList : List Norm := [danglingNorm, normB]

theorem dangling_reference_found :
    validate atomsRestricted catalog danglingList =
      [Finding.danglingReference "D" "Điều 99"] := by
  decide

/-! ## 4. A malformed norm next to a real conflict — both are reported -/

def badNorm : Norm :=
  { normA with id := "BAD", condition := .sit 99, source := srcOf "Điều 4" }
def conflictPlusBad : List Norm := [normA, normB, badNorm]

/-- The real conflict is reported... -/
theorem conflict_reported_with_bad_norm :
    check atoms conflictPlusBad =
      .conflict
        { situation := ⟨true, false⟩
        , params := ⟨false⟩
        , left := "A"
        , right := "B"
        , modalities := (.obligation, .prohibition)
        , sources := (srcA, srcB) }
        (scopeOf Sit Params atoms conflictPlusBad)
        (auditOf atoms conflictPlusBad) := by
  decide

/-- ...and the unevaluable norm is listed alongside it, not skipped (D20). -/
theorem bad_norm_also_reported :
    (auditOf atoms conflictPlusBad).unevaluable = ["BAD"] := by
  decide

/-- The validator names the norm that is actually malformed, not a sound one. -/
theorem validator_names_the_bad_norm :
    validate atoms catalog conflictPlusBad =
      [Finding.atomIndexOutOfRange "BAD"] := by
  decide

/-! ## 5. Empty norm list -/

/-- Never `consistentOn` (D20). -/
theorem empty_is_a_finding :
    check atoms ([] : List Norm) = .invalid [Finding.emptyNormList] := by
  decide

theorem empty_is_a_finding_via_analyze :
    analyze atoms catalog ([] : List Norm) = .invalid [Finding.emptyNormList] := by
  decide

/-! ## 6. A situation excluded by `valid` -/

/-- With the clashing situation ruled out by the integrity constraint, the same
two norms come back consistent. -/
theorem valid_excludes_the_conflict :
    check atomsRestricted conflicting =
      .consistentOn (scopeOf Sit Params atomsRestricted conflicting)
        (auditOf atomsRestricted conflicting) := by
  decide

/-- And the scope says the domain was restricted, so the claim is not read as
covering everything. -/
theorem restriction_is_recorded :
    (scopeOf Sit Params atomsRestricted conflicting).validRestricted = true := by
  decide

/-- The unrestricted atoms report no restriction. -/
theorem no_restriction_recorded :
    (scopeOf Sit Params atoms conflicting).validRestricted = false := by
  decide

/-! ## 7. A conditional conflict -/

def srcC : SourceId := srcOf "Điều 5"

/-- Prohibited only when the breach counts as serious — an open-textured
parameter, which the system never decides. -/
def normC : Norm :=
  { id := "C", modality := .prohibition, act := "publish"
  , condition := .and (.sit 0) (.param 0), exceptions := [], priority := none
  , source := srcC, references := [] }
def condPair : List Norm := [normA, normC]

/-- Reported as conditional, naming the parameter that decides it. -/
theorem conditional_conflict_found :
    check atoms condPair =
      .conditionalConflict
        { situation := ⟨true, false⟩
        , params := ⟨true⟩
        , left := "A"
        , right := "C"
        , modalities := (.obligation, .prohibition)
        , sources := (srcA, srcC) }
        ["serious"]
        (scopeOf Sit Params atoms condPair)
        (auditOf atoms condPair) := by
  decide

/-- Theorem (e) part 2 applied: there really is a parameter assignment that
conflicts and one that does not. -/
theorem conditional_conflict_splits :
    ∃ n₁ ∈ condPair, ∃ n₂ ∈ condPair,
      (∃ π : Params, atoms.valid π ⟨true, false⟩ = true ∧
        Conflict atoms n₁ n₂ π ⟨true, false⟩) ∧
      (∃ π : Params, atoms.valid π ⟨true, false⟩ = true ∧
        ¬ Conflict atoms n₁ n₂ π ⟨true, false⟩) :=
  conditionalConflict_split conditional_conflict_found

/-! ## 8. One-sided priority resolves the clash and records the winner -/

def resB : Norm := { normB with priority := some ⟨["A"]⟩ }
def resolvedPair : List Norm := [normA, resB]

theorem one_sided_priority_resolves : Norm.resolved normA resB = true := by
  decide

/-- The prevailing norm is recorded, so a report can say which article
applies (D13). -/
theorem winner_is_recorded :
    resolutionsOf resolvedPair = [{ winner := "B", loser := "A" }] := by
  decide

theorem resolved_pair_is_consistent :
    check atoms resolvedPair =
      .consistentOn (scopeOf Sit Params atoms resolvedPair)
        (auditOf atoms resolvedPair) := by
  decide

/-! ## 9. A clean validator run means nothing is unevaluable (theorem (f)) -/

theorem smoke_pair_validates : validate atoms catalog conflicting = [] := by
  decide

theorem smoke_pair_always_evaluates :
    ∀ n ∈ conflicting, ∀ (π : Params) (s : Sit), (n.applies atoms π s).isSome = true :=
  applies_isSome_of_validate_nil smoke_pair_validates

end LexProof.Tests
