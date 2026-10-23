import LexProof.Verify.Smoke

/-!
# Scenario tests

One scenario per structural defect and per reporting path. Every expected
result is pinned exactly and checked by `decide`, so a change in behaviour
breaks the build rather than passing quietly.

Scenarios that must bypass validation to be observable (an unevaluable norm, an
empty list) call `Internal.check` directly; everything else goes through
`analyze`.

Reuses the situation space, atom table, catalog and two norms of `Smoke`. Like
`Smoke`, this is **not** a `Laws` module: the norms are invented and nothing
here was reviewed for faithfulness.
-/

namespace LexProof.Tests

open LexProof LexProof.Smoke

def srcOf (a : String) : SourceId :=
  { docId := "SMOKE", docType := .decree, effective := ⟨2026, 1, 1⟩, article := a }

/-- A source in a *different* document, for the mixed-`docId` scenario. -/
def srcOther (a : String) : SourceId :=
  { docId := "OTHER", docType := .decree, effective := ⟨2026, 1, 1⟩, article := a }

/-- Same atoms as `Smoke`, but an integrity constraint rules out every overdue
situation — which is exactly where `normA` and `normB` clash. -/
def atomsRestricted : Atoms Sit Params where
  sit := [("overdue", fun s => s.overdue), ("disputed", fun s => s.disputed)]
  param := [("serious", fun p => p.serious)]
  valid := fun _ s => !s.overdue

/-- A norm skeleton for the priority-graph scenarios: same act, condition
"overdue", explicit `overrides`. -/
def nm (i : NormId) (m : Modality) (ov : List NormId) (art : String) : Norm :=
  { id := i, modality := m, act := "publish"
  , condition := .sit 0, exceptions := []
  , priority := if ov.isEmpty then none else some ⟨ov⟩
  , source := srcOf art, references := [] }

/-! ## 1. Priority cycles of several lengths (D26) -/

def cyc2 : List Norm :=
  [nm "A" .obligation ["B"] "Điều 1", nm "B" .prohibition ["A"] "Điều 2"]

def cyc3 : List Norm :=
  [nm "A" .obligation ["B"] "Điều 1", nm "B" .prohibition ["C"] "Điều 2",
   nm "C" .obligation ["A"] "Điều 3"]

def cyc4 : List Norm :=
  [nm "A" .obligation ["B"] "Điều 1", nm "B" .prohibition ["C"] "Điều 2",
   nm "C" .obligation ["D"] "Điều 3", nm "D" .prohibition ["A"] "Điều 4"]

/-- A 2-cycle plus an unrelated non-cyclic edge `C → D`. Only the cycle is
reported; `C` and `D` are left alone. -/
def cyc2plusEdge : List Norm :=
  [nm "A" .obligation ["B"] "Điều 1", nm "B" .prohibition ["A"] "Điều 2",
   nm "C" .obligation ["D"] "Điều 3", nm "D" .prohibition [] "Điều 4"]

theorem cycle_2_found :
    validate atomsRestricted catalog cyc2 =
      [Finding.priorityCycle "A", Finding.priorityCycle "B"] := by decide

theorem cycle_3_found :
    validate atomsRestricted catalog cyc3 =
      [Finding.priorityCycle "A", Finding.priorityCycle "B",
       Finding.priorityCycle "C"] := by decide

theorem cycle_4_found :
    validate atomsRestricted catalog cyc4 =
      [Finding.priorityCycle "A", Finding.priorityCycle "B",
       Finding.priorityCycle "C", Finding.priorityCycle "D"] := by decide

/-- The unrelated edge is not mistaken for a cycle. -/
theorem cycle_plus_edge_found :
    validate atomsRestricted catalog cyc2plusEdge =
      [Finding.priorityCycle "A", Finding.priorityCycle "B"] := by decide

/-- Soundness of cycle detection, applied: the reported `"A"` really lies on a
cycle of the `overrides` relation. -/
theorem cycle_3_is_real :
    ∃ n ∈ cyc3, n.id = "A" ∧ Reaches cyc3 "A" "A" :=
  cycle_of_validate_finding (A := atomsRestricted) (catalog := catalog)
    (by rw [cycle_3_found]; simp)

/-- Mutual override is **not** a resolution: the clash stays unresolved rather
than being silently settled (D13). -/
theorem mutual_override_not_resolved :
    Norm.resolved (nm "A" .obligation ["B"] "Điều 1")
      (nm "B" .prohibition ["A"] "Điều 2") = false := by decide

/-! ## 2. Duplicate norm id -/

def dupPair : List Norm := [normA, { normB with id := "A" }]

theorem duplicate_id_found :
    validate atoms catalog dupPair = [Finding.duplicateId "A"] := by decide

/-! ## 3. Dangling reference -/

def danglingNorm : Norm :=
  { normA with id := "D", references := ["Điều 99"], source := srcOf "Điều 3" }
def danglingList : List Norm := [danglingNorm, normB]

theorem dangling_reference_found :
    validate atoms catalog danglingList =
      [Finding.danglingReference "D" "Điều 99"] := by decide

/-! ## 4. Mixed `docId`s (D25) -/

def mixedDocs : List Norm :=
  [normA, { normB with source := srcOther "Điều 2" }]

/-- A list spanning two documents is a finding, not a level-1 claim. The ids
come out **sorted**, not in list order. -/
theorem mixed_docids_found :
    validate atoms catalog mixedDocs =
      [Finding.mixedDocIds ["OTHER", "SMOKE"]] := by decide

/-- D30: reversing the norm list does not change the finding. -/
theorem mixed_docids_order_independent :
    validate atoms catalog mixedDocs.reverse =
      validate atoms catalog mixedDocs := by decide

theorem docIds_order_independent :
    docIdsOf mixedDocs.reverse = docIdsOf mixedDocs := by decide

/-- And the scope refuses to guess a document id. -/
theorem mixed_docids_no_scope_docid : singleDocId? mixedDocs = none := by decide

theorem single_docid_when_clean : singleDocId? conflicting = some "SMOKE" := by decide

/-! ## 5. A malformed norm next to a real conflict — both are reported -/

def badNorm : Norm :=
  { normA with id := "BAD", condition := .sit 99, source := srcOf "Điều 4" }
def conflictPlusBad : List Norm := [normA, normB, badNorm]

/-- The validator names the norm that is actually malformed, not a sound one. -/
theorem validator_names_the_bad_norm :
    validate atoms catalog conflictPlusBad =
      [Finding.atomIndexOutOfRange "BAD"] := by decide

/-- If the search is run anyway, the real conflict is reported... -/
theorem conflict_reported_with_bad_norm :
    Internal.check atoms conflictPlusBad =
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
    (auditOf atoms conflictPlusBad).unevaluable = ["BAD"] := by decide

/-! ## 6. Empty norm list -/

/-- Never `consistentOn` (D20), on either entry point. -/
theorem empty_is_a_finding :
    Internal.check atoms ([] : List Norm) = .invalid [Finding.emptyNormList] := by
  decide

theorem empty_is_a_finding_via_analyze :
    analyze atoms catalog ([] : List Norm) = .invalid [Finding.emptyNormList] := by
  decide

/-! ## 7. Points excluded by `valid` (D22) -/

theorem restricted_validates : validate atomsRestricted catalog conflicting = [] := by
  decide

/-- With the clashing situations ruled out by the integrity constraint, the
same two norms come back consistent. -/
theorem valid_excludes_the_conflict :
    analyze atomsRestricted catalog conflicting =
      .consistentOn (scopeOf Sit Params atomsRestricted conflicting)
        (auditOf atomsRestricted conflicting) := by
  decide

/-- And the scope says **how much** of the domain was excluded, not just that
some was. -/
theorem restriction_is_counted :
    (scopeOf Sit Params atomsRestricted conflicting).validExcluded = 4 ∧
    (scopeOf Sit Params atomsRestricted conflicting).validTotal = 8 ∧
    (scopeOf Sit Params atomsRestricted conflicting).isRestricted = true := by
  decide

/-- The unrestricted atoms exclude nothing. -/
theorem no_restriction_counted :
    (scopeOf Sit Params atoms conflicting).validExcluded = 0 ∧
    (scopeOf Sit Params atoms conflicting).isRestricted = false := by
  decide

/-! ## 8. A conditional conflict -/

def srcC : SourceId := srcOf "Điều 5"

/-- Prohibited only when the breach counts as serious — an open-textured
parameter, which the system never decides. -/
def normC : Norm :=
  { id := "C", modality := .prohibition, act := "publish"
  , condition := .and (.sit 0) (.param 0), exceptions := [], priority := none
  , source := srcC, references := [] }
def condPair : List Norm := [normA, normC]

theorem cond_validates : validate atoms catalog condPair = [] := by decide

/-- Reported as conditional, naming the parameter that decides it. -/
theorem conditional_conflict_found :
    analyze atoms catalog condPair =
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

/-! ## 9. One-sided priority resolves the clash and records the winner -/

def resB : Norm := { normB with priority := some ⟨["A"]⟩ }
def resolvedPair : List Norm := [normA, resB]

theorem one_sided_priority_resolves : Norm.resolved normA resB = true := by decide

/-- The prevailing norm is recorded, so a report can say which article
applies (D13). -/
theorem winner_is_recorded :
    resolutionsOf atoms resolvedPair = [{ winner := "B", loser := "A" }] := by
  decide

theorem resolved_validates : validate atoms catalog resolvedPair = [] := by decide

theorem resolved_pair_is_consistent :
    analyze atoms catalog resolvedPair =
      .consistentOn (scopeOf Sit Params atoms resolvedPair)
        (auditOf atoms resolvedPair) := by
  decide

/-- Theorem D23 applied: the recorded resolution is a clash that really arises
at some valid point. -/
theorem recorded_resolution_has_witness :
    ∃ n₁ ∈ resolvedPair, ∃ n₂ ∈ resolvedPair, ∃ (π : Params) (s : Sit),
      atoms.valid π s = true ∧
      n₁.applies atoms π s = some true ∧ n₂.applies atoms π s = some true ∧
      n₁.act = n₂.act ∧
      Incompatible n₁.modality n₂.modality = true ∧
      Norm.winner? n₁ n₂ = some "B" :=
  resolution_has_witness (A := atoms) (r := { winner := "B", loser := "A" })
    (by rw [winner_is_recorded]; simp)

/-! ## 10. Priority that never matters (D23) -/

def xNorm : Norm :=
  { id := "X", modality := .obligation, act := "publish"
  , condition := .sit 0, exceptions := [], priority := none
  , source := srcOf "Điều 6", references := [] }

/-- Prohibited only when disputed and **not** overdue, so it never applies at
the same point as `xNorm` — even though it claims precedence over it. -/
def yNorm : Norm :=
  { id := "Y", modality := .prohibition, act := "publish"
  , condition := .and (.sit 1) (.not (.sit 0)), exceptions := []
  , priority := some ⟨["X"]⟩, source := srcOf "Điều 7", references := [] }
def noCoApply : List Norm := [xNorm, yNorm]

/-- No resolution is reported, because there is no clash to settle. -/
theorem no_resolution_without_co_application :
    resolutionsOf atoms noCoApply = [] := by decide

theorem no_co_apply_validates : validate atoms catalog noCoApply = [] := by decide

theorem no_co_apply_is_consistent :
    analyze atoms catalog noCoApply =
      .consistentOn (scopeOf Sit Params atoms noCoApply)
        (auditOf atoms noCoApply) := by
  decide

/-! ## 11. A clean validator run means nothing is unevaluable (theorem (f)) -/

theorem smoke_pair_always_evaluates :
    ∀ n ∈ conflicting, ∀ (π : Params) (s : Sit),
      (n.applies atoms π s).isSome = true :=
  applies_isSome_of_validate_nil smoke_validates


/-! ## 12. Differential test of cycle detection over all small graphs (D28)

Completeness of `inPriorityCycle` is **not proved** (see the report and the
trust base). Instead, every `overrides` graph on up to 4 nodes is compared
against a reference check written a different way: a depth-bounded search with
no visited set and no deduplication, versus the iterative set closure that
`inPriorityCycle` uses. -/

set_option maxRecDepth 8000

/-- Node id `i`. -/
def gid (i : Nat) : NormId := toString i

/-- Norm `i` of the graph encoded by the bits of `g`: edge `i → j` iff bit
`i * n + j` is set. -/
def gNorm (n : Nat) (g : Nat) (i : Nat) : Norm :=
  { id := gid i, modality := .obligation, act := "a"
  , condition := .tt, exceptions := []
  , priority := some ⟨((List.range n).filter fun j => g.testBit (i * n + j)).map gid⟩
  , source := srcOf "x", references := [] }

def gNorms (n : Nat) (g : Nat) : List Norm := (List.range n).map (gNorm n g)

/-- Reference reachability: depth-bounded search, **no** visited set and **no**
deduplication — a different algorithm from `reachN`. -/
def refReaches (succ : NormId → List NormId) : Nat → NormId → NormId → Bool
  | 0, _, _ => false
  | k + 1, i, j => (succ i).contains j || (succ i).any fun m => refReaches succ k m j

def refInCycle (ns : List Norm) (x : Norm) : Bool :=
  refReaches (succsOf ns) ns.length x.id x.id

/-- Do the two checks agree on every node of this graph? -/
def agree (n : Nat) (g : Nat) : Bool :=
  let ns := gNorms n g
  ns.all fun x => inPriorityCycle ns x == refInCycle ns x

/-- Do they agree on **every** graph on `n` nodes? -/
def agreeAll (n : Nat) : Bool := (List.range (2 ^ (n * n))).all (agree n)

/-- All 2 graphs on 1 node agree. Kernel-checked. -/
theorem cycle_check_agrees_n1 : agreeAll 1 = true := by decide

/-- All 16 graphs on 2 nodes agree. Kernel-checked. -/
theorem cycle_check_agrees_n2 : agreeAll 2 = true := by decide

/-! Graphs on 3 and 4 nodes (512 and 65536 of them) are checked by **compiled
evaluation, not by the kernel** — status *Evaluated*, a diagnostic rather than
a proof. `decide` on n=3 cost about 40s of every build, and `decide` on n=4
would cost roughly half an hour.

Paying that is no longer worth it: completeness of cycle detection is now a
theorem (`cycle_finding_of_reaches`) covering **every** graph size, so these
runs are redundant confirmation that the statement and `succsOf`/`gnodes` say
what was meant — not the evidence the guarantee rests on. -/

#eval agreeAll 3
#eval agreeAll 4

/-! ### Why a missed cycle finding is *not* harmless (D28)

`resolved` is XOR **per pair**. In a cycle of length ≥ 3 every pair has exactly
one direction of override, so every pair looks resolved and the search reports
consistency — even though nothing actually has precedence. Only in a 2-cycle
does XOR come out false and keep the clash visible.

So completeness of cycle detection is not cosmetic: the validator is the only
thing standing between a circular priority structure and a false
"consistentOn". -/

/-- A 2-cycle survives even without validation: XOR is false for the pair, so
the clash is still reported. -/
theorem two_cycle_still_reports_conflict :
    (Internal.check atoms cyc2).witness?.isSome = true := by decide

/-- A 3-cycle **fools the bare search**: every pair looks resolved, so it
reports consistency. This is the concrete reason the earlier claim that a
missed cycle finding is harmless was wrong. -/
theorem three_cycle_hides_conflict_from_search :
    (Internal.check atoms cyc3).isConsistentOn = true := by decide

/-- Validation is what prevents it: through `analyze` the 3-cycle is a finding,
and nothing is reported as consistent. -/
theorem three_cycle_is_caught_by_validation :
    analyze atoms catalog cyc3 =
      .invalid [Finding.priorityCycle "A", Finding.priorityCycle "B",
                Finding.priorityCycle "C"] := by decide

/-- D40 applied: because `analyze` reported `consistentOn` for the fixed pair,
**no** norm in it lies on a priority cycle — a guarantee that now rides along
with every searched result. -/
theorem fixed_has_no_priority_cycle :
    ∀ n ∈ fixed, ¬ Reaches fixed n.id n.id :=
  no_priority_cycle_of_consistentOn smoke_consistent

end LexProof.Tests
