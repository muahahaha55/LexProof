import LexProof.Verify.ProjectedCheck
import LexProof.Verify.Conflict

/-!
# `analyzeP` — a whole norm list over atom tables, end to end

**Additive.** Nothing existing is changed or called differently; `analyze` is
untouched. `analyzeP` takes a situation table, a parameter table, their readers,
a reference catalog and a norm list, and runs, in this order and failing closed:

1. **Findings.** If any of `validate`, `tableFindings` (both tables),
   `readerFindings` (both sides) or the empty-list check (inside `validate`) is
   non-empty, return `.invalid` with all of them, each naming its norm, atom or
   reader. Nothing else is searched.
2. **Projected search.** Every unordered pair `(i < j)` of norms **that share an
   act** is checked with `projConsistentT`. Pairs with different acts are skipped
   on purpose: `Conflict` needs equal acts.
3. **Report.** Either `.conflicts` (one witness per conflicting pair — **every**
   conflicting pair, not only the first) or `.consistentOn`; both carry a
   `ProjScope`: points enumerated per pair, pairs checked and skipped by act, and
   that **no integrity constraints were used**.

## Proved here

* (W1) `silent_of_not_invalid`: anything but `.invalid` means all checks were
  silent, hence `NonEmpty` and `ReaderAtomsOk` hold (assumptions of B2, B3).
* (W2) `not_conflict_of_consistentOnP`: `.consistentOn` ⇒ no `Conflict` for any
  two norms of the list at any `(π, s)` of the full domains, including pairs
  skipped by act and the pair `(n, n)`.
* (W3/W4 soundness) `conflicts_sound`: every listed pair is a real conflict at
  some valid point (with no constraints), and the reported ids, modalities and
  sources are those of the norms.
* (W4 completeness) `conflicts_complete`: a pair that really conflicts at some
  point of the full domains **is listed**. Completeness is relative to the
  unconstrained `Conflict`; it makes the list usable for recall counts of the
  unconstrained check, nothing more.
* `projScope_points_spec`, `projScope_pairs`: what the scope's numbers mean.

## Caveat that cannot be removed here

A conflict reported **without integrity constraints may sit at a situation that
cannot occur in reality**. The statement of `conflicts_sound` says so: the point
is valid only in the sense that `valid` is the default (admit everything).
`consistentOn`, in contrast, stays meaningful: with fewer points removed, no
conflict anywhere implies no conflict at the real points.
-/

namespace LexProof

/-! ## Report types -/

inductive TableSide
  | situation
  | parameter
  deriving Repr, DecidableEq

/-- A finding of `analyzeP`, tagged with where it came from. -/
inductive PFinding
  | norm (f : Finding)
  | table (side : TableSide) (f : TableFinding)
  | reader (side : TableSide) (f : TableFinding)
  deriving Repr, DecidableEq

/-- One conflicting pair: the first conflicting partial valuation found, over the
atoms the pair reads. A candidate the kernel can re-check; `conflicts_sound`
says a real `(π, s)` exists. -/
structure ProjHit where
  left : NormId
  right : NormId
  situation : PartialAssign
  params : PartialAssign
  modalities : Modality × Modality
  sources : SourceId × SourceId
  deriving Repr, DecidableEq

/-- What was actually enumerated. A `consistentOn` is only ever about this much. -/
structure ProjScope where
  docId : Option String
  normIds : List NormId
  articles : List String
  /-- Sizes of the full domains (products of the domain sizes; not enumerated). -/
  fullSituations : Nat
  fullParams : Nat
  pairsChecked : Nat
  /-- Pairs not checked because their acts differ. -/
  pairsSkipped : Nat
  /-- For each checked pair, the number of partial valuations its search covers. -/
  pointsPerPair : List (NormId × NormId × Nat)
  /-- Always `false`: no integrity constraint was used (`valid` is the default). -/
  constraintsUsed : Bool
  deriving Repr, DecidableEq

inductive ProjResult
  | invalid (findings : List PFinding)
  | conflicts (hits : List ProjHit) (scope : ProjScope)
  | consistentOn (scope : ProjScope)
  deriving Repr, DecidableEq

def ProjResult.isConsistentOn : ProjResult → Bool
  | .consistentOn _ => true
  | _ => false

/-! ## Definitions -/

/-- Everything checked before any search. -/
def pfindings (ts tp : AtomTable) (rs rp : List ReaderSpec) (catalog : List String)
    (ns : List Norm) : List PFinding :=
  (validate (atomsOf ts tp rs rp) catalog ns).map PFinding.norm ++
  (tableFindings ts).map (PFinding.table .situation) ++
  (tableFindings tp).map (PFinding.table .parameter) ++
  (readerFindings ts rs).map (PFinding.reader .situation) ++
  (readerFindings tp rp).map (PFinding.reader .parameter)

/-- The hit of one pair, if its acts agree and a conflicting partial valuation
exists. -/
def pairHit (ts tp : AtomTable) (rs rp : List ReaderSpec) (n₁ n₂ : Norm) : Option ProjHit :=
  if n₁.act == n₂.act then
    match (projVals ts tp rs rp n₁ n₂).find? (fun v => projConflictT rs rp n₁ n₂ v.1 v.2) with
    | some v => some { left := n₁.id, right := n₂.id, situation := v.1, params := v.2
                     , modalities := (n₁.modality, n₂.modality)
                     , sources := (n₁.source, n₂.source) }
    | none => none
  else none

/-- One hit per conflicting same-act pair `(i < j)`. -/
def projHits (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) : List ProjHit :=
  (pairsOf ns).filterMap fun p => pairHit ts tp rs rp p.1 p.2

def sameAct (p : Norm × Norm) : Bool := p.1.act == p.2.act

def checkedPairs (ns : List Norm) : List (Norm × Norm) := (pairsOf ns).filter sameAct

def projScope (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) : ProjScope :=
  { docId := singleDocId? ns
  , normIds := ns.map fun n => n.id
  , articles := ns.map fun n => n.source.article
  , fullSituations := ts.points
  , fullParams := tp.points
  , pairsChecked := (checkedPairs ns).length
  , pairsSkipped := (pairsOf ns).length - (checkedPairs ns).length
  , pointsPerPair := (checkedPairs ns).map fun p =>
      (p.1.id, p.2.id, projPoints ts tp rs rp p.1 p.2)
  , constraintsUsed := false }

/-- The single entry point for a norm list over atom tables. Fails closed: any
finding means `.invalid` and no search. -/
def analyzeP (ts tp : AtomTable) (rs rp : List ReaderSpec) (catalog : List String)
    (ns : List Norm) : ProjResult :=
  match pfindings ts tp rs rp catalog ns with
  | [] =>
    match projHits ts tp rs rp ns with
    | [] => .consistentOn (projScope ts tp rs rp ns)
    | hits => .conflicts hits (projScope ts tp rs rp ns)
  | fs => .invalid fs

/-! ## Inversion lemmas -/

theorem pfindings_eq_nil {ts tp : AtomTable} {rs rp : List ReaderSpec} {catalog : List String}
    {ns : List Norm} :
    pfindings ts tp rs rp catalog ns = [] ↔
      validate (atomsOf ts tp rs rp) catalog ns = [] ∧ tableFindings ts = [] ∧
      tableFindings tp = [] ∧ readerFindings ts rs = [] ∧ readerFindings tp rp = [] := by
  simp [pfindings, List.append_eq_nil_iff]

theorem inv_consistentOn {ts tp : AtomTable} {rs rp : List ReaderSpec} {catalog : List String}
    {ns : List Norm} {sc : ProjScope}
    (h : analyzeP ts tp rs rp catalog ns = .consistentOn sc) :
    pfindings ts tp rs rp catalog ns = [] ∧ projHits ts tp rs rp ns = [] := by
  unfold analyzeP at h
  rcases hf : pfindings ts tp rs rp catalog ns with _ | ⟨f, fs⟩
  · rcases hh : projHits ts tp rs rp ns with _ | ⟨x, xs⟩
    · exact ⟨rfl, rfl⟩
    · simp [hf, hh] at h
  · simp [hf] at h

theorem inv_conflicts {ts tp : AtomTable} {rs rp : List ReaderSpec} {catalog : List String}
    {ns : List Norm} {hits : List ProjHit} {sc : ProjScope}
    (h : analyzeP ts tp rs rp catalog ns = .conflicts hits sc) :
    pfindings ts tp rs rp catalog ns = [] ∧ projHits ts tp rs rp ns = hits ∧ hits ≠ [] := by
  unfold analyzeP at h
  rcases hf : pfindings ts tp rs rp catalog ns with _ | ⟨f, fs⟩
  · rcases hh : projHits ts tp rs rp ns with _ | ⟨x, xs⟩
    · simp [hf, hh] at h
    · simp only [hf, hh] at h
      have := ProjResult.conflicts.inj h
      exact ⟨rfl, this.1, by rw [← this.1]; simp⟩
  · simp [hf] at h

/-- (W1) Anything but `.invalid` means every check was silent, and the
assumptions of B2 and B3 hold. -/
theorem silent_of_not_invalid {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {catalog : List String} {ns : List Norm}
    (h : ∀ fs, analyzeP ts tp rs rp catalog ns ≠ .invalid fs) :
    validate (atomsOf ts tp rs rp) catalog ns = [] ∧ tableFindings ts = [] ∧
    tableFindings tp = [] ∧ readerFindings ts rs = [] ∧ readerFindings tp rp = [] ∧
    ns ≠ [] ∧ ts.NonEmpty ∧ tp.NonEmpty ∧ ReaderAtomsOk ts rs ∧ ReaderAtomsOk tp rp := by
  have hf : pfindings ts tp rs rp catalog ns = [] := by
    rcases hf : pfindings ts tp rs rp catalog ns with _ | ⟨f, fs⟩
    · rfl
    · exact absurd (by simp [analyzeP, hf]) (h (f :: fs))
  obtain ⟨hv, ht, hp, hr, hq⟩ := pfindings_eq_nil.1 hf
  refine ⟨hv, ht, hp, hr, hq, ?_, nonEmpty_of_tableFindings ht, nonEmpty_of_tableFindings hp,
    readerAtomsOk_of_readersOk (readersOk_of_readerFindings hr),
    readerAtomsOk_of_readersOk (readersOk_of_readerFindings hq)⟩
  rintro rfl
  simp [validate] at hv

/-! ## Facts about one pair -/

theorem pairHit_none {ts tp : AtomTable} {rs rp : List ReaderSpec} {n₁ n₂ : Norm}
    (h : pairHit ts tp rs rp n₁ n₂ = none) (hact : n₁.act = n₂.act) :
    projConsistentT ts tp rs rp n₁ n₂ = true := by
  unfold pairHit at h
  simp only [hact, beq_self_eq_true, ite_true] at h
  cases hf : (projVals ts tp rs rp n₁ n₂).find? (fun v => projConflictT rs rp n₁ n₂ v.1 v.2) with
  | some v => simp [hf] at h
  | none =>
    refine List.all_eq_true.2 fun v hv => ?_
    have := List.find?_eq_none.1 hf v hv
    simpa using this

theorem pairHit_some {ts tp : AtomTable} {rs rp : List ReaderSpec} {n₁ n₂ : Norm}
    {hit : ProjHit} (h : pairHit ts tp rs rp n₁ n₂ = some hit) :
    n₁.act = n₂.act ∧ hit.left = n₁.id ∧ hit.right = n₂.id ∧
    hit.modalities = (n₁.modality, n₂.modality) ∧ hit.sources = (n₁.source, n₂.source) ∧
    (hit.situation, hit.params) ∈ projVals ts tp rs rp n₁ n₂ ∧
    projConflictT rs rp n₁ n₂ hit.situation hit.params = true := by
  unfold pairHit at h
  by_cases hact : (n₁.act == n₂.act) = true
  · simp only [hact, ite_true] at h
    cases hf : (projVals ts tp rs rp n₁ n₂).find? (fun v => projConflictT rs rp n₁ n₂ v.1 v.2) with
    | none => simp [hf] at h
    | some v =>
      simp only [hf, Option.some.injEq] at h
      subst h
      exact ⟨by simpa using hact, rfl, rfl, rfl, rfl, List.mem_of_find?_eq_some hf,
        by simpa using List.find?_some hf⟩
  · simp [hact] at h

theorem projConsistentT_false_of_conflict {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {n₁ n₂ : Norm} {v : PartialAssign × PartialAssign}
    (hv : v ∈ projVals ts tp rs rp n₁ n₂) (hc : projConflictT rs rp n₁ n₂ v.1 v.2 = true) :
    projConsistentT ts tp rs rp n₁ n₂ = false := by
  cases h : projConsistentT ts tp rs rp n₁ n₂ with
  | false => rfl
  | true =>
    have := (List.all_eq_true.1 h) v hv
    simp [hc] at this

theorem pairHit_isSome {ts tp : AtomTable} {rs rp : List ReaderSpec} {n₁ n₂ : Norm}
    (hact : n₁.act = n₂.act) (h : projConsistentT ts tp rs rp n₁ n₂ = false) :
    ∃ hit, pairHit ts tp rs rp n₁ n₂ = some hit := by
  cases hp : pairHit ts tp rs rp n₁ n₂ with
  | some hit => exact ⟨hit, rfl⟩
  | none => rw [pairHit_none hp hact] at h; exact absurd h (by simp)

/-! ## W2 -/

/-- (W2) `.consistentOn` ⇒ no `Conflict` between any two norms of the list at any
`(π, s)` of the full domains. Pairs with different acts cannot conflict; the pair
`(n, n)` cannot conflict. -/
theorem not_conflict_of_consistentOnP {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {catalog : List String} {ns : List Norm} {sc : ProjScope}
    (h : analyzeP ts tp rs rp catalog ns = .consistentOn sc) :
    ∀ n₁ ∈ ns, ∀ n₂ ∈ ns, ∀ (π : Valuation tp) (s : Valuation ts),
      ¬ Conflict (atomsOf ts tp rs rp) n₁ n₂ π s := by
  obtain ⟨hf, hh⟩ := inv_consistentOn h
  obtain ⟨_, _, _, _, _, _, _, _, hrs, hrp⟩ := silent_of_not_invalid
    (fun fs hc => by rw [h] at hc; exact ProjResult.noConfusion hc)
  intro n₁ h₁ n₂ h₂ π s
  by_cases heq : n₁ = n₂
  · exact heq ▸ not_conflict_self _ n₁ π s
  · have key : ∀ a b : Norm, (a, b) ∈ pairsOf ns → ¬ Conflict (atomsOf ts tp rs rp) a b π s := by
      intro a b hab hc
      have hn : pairHit ts tp rs rp a b = none := by
        have : ∀ x ∈ projHits ts tp rs rp ns, False := by rw [hh]; simp
        cases hp : pairHit ts tp rs rp a b with
        | none => rfl
        | some hit => exact (this hit (List.mem_filterMap.2 ⟨(a, b), hab, hp⟩)).elim
      exact not_conflict_of_projConsistentT hrs hrp a b (pairHit_none hn hc.1) π s hc
    rcases mem_pairsOf h₁ h₂ heq with hp | hp
    · exact key n₁ n₂ hp
    · exact fun hc => key n₂ n₁ hp (Conflict_comm hc)

/-! ## W3 and W4 -/

/-- (W3, W4 soundness) A `.conflicts` result is non-empty, and **every** listed
pair is a real conflict at some `(π, s)` of the full domains. The point is valid
only in the sense that `valid` is the default of `atomsOf`: **no integrity
constraint was used**, so the point may be a situation that cannot occur in
reality. The ids, modalities and sources are those of the two norms. -/
theorem conflicts_sound {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {catalog : List String} {ns : List Norm} {hits : List ProjHit} {sc : ProjScope}
    (h : analyzeP ts tp rs rp catalog ns = .conflicts hits sc) :
    hits ≠ [] ∧ ∀ hit ∈ hits, ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      hit.left = n₁.id ∧ hit.right = n₂.id ∧
      hit.modalities = (n₁.modality, n₂.modality) ∧ hit.sources = (n₁.source, n₂.source) ∧
      projConflictT rs rp n₁ n₂ hit.situation hit.params = true ∧
      ∃ (π : Valuation tp) (s : Valuation ts),
        (atomsOf ts tp rs rp).valid π s = true ∧ Conflict (atomsOf ts tp rs rp) n₁ n₂ π s := by
  obtain ⟨_, hhits, hne⟩ := inv_conflicts h
  obtain ⟨_, _, _, _, _, _, hts, htp, _, _⟩ := silent_of_not_invalid
    (fun fs hc => by rw [h] at hc; exact ProjResult.noConfusion hc)
  refine ⟨hne, fun hit hmem => ?_⟩
  rw [← hhits] at hmem
  obtain ⟨p, hp, hph⟩ := List.mem_filterMap.1 hmem
  have hsub := pairsOf_subset hp
  obtain ⟨_, hl, hr, hm, hs, hv, hc⟩ := pairHit_some hph
  exact ⟨p.1, hsub.1, p.2, hsub.2, hl, hr, hm, hs, hc,
    exists_conflict_of_not_projConsistentT hts htp p.1 p.2
      (projConsistentT_false_of_conflict hv hc)⟩

/-- (W4 completeness) Every same-act pair `(i < j)` that really conflicts at some
`(π, s)` of the full domains **is listed**. This is relative to the unconstrained
`Conflict`: it lets the list be used for recall counts of that relation. -/
theorem conflicts_complete {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {catalog : List String} {ns : List Norm} {hits : List ProjHit} {sc : ProjScope}
    (h : analyzeP ts tp rs rp catalog ns = .conflicts hits sc) :
    ∀ p ∈ pairsOf ns, p.1.act = p.2.act →
      (∃ (π : Valuation tp) (s : Valuation ts), Conflict (atomsOf ts tp rs rp) p.1 p.2 π s) →
      ∃ hit ∈ hits, hit.left = p.1.id ∧ hit.right = p.2.id := by
  obtain ⟨_, hhits, _⟩ := inv_conflicts h
  obtain ⟨_, _, _, _, _, _, _, _, hrs, hrp⟩ := silent_of_not_invalid
    (fun fs hc => by rw [h] at hc; exact ProjResult.noConfusion hc)
  intro p hp hact ⟨π, s, hc⟩
  have hfalse : projConsistentT ts tp rs rp p.1 p.2 = false := by
    cases hc' : projConsistentT ts tp rs rp p.1 p.2 with
    | false => rfl
    | true => exact absurd hc (not_conflict_of_projConsistentT hrs hrp p.1 p.2 hc' π s)
  obtain ⟨hit, hhit⟩ := pairHit_isSome hact hfalse
  obtain ⟨_, hl, hr, _⟩ := pairHit_some hhit
  exact ⟨hit, by rw [← hhits]; exact List.mem_filterMap.2 ⟨p, hp, hhit⟩, hl, hr⟩

/-! ## What the scope says -/

theorem scope_of_consistentOn {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {catalog : List String} {ns : List Norm} {sc : ProjScope}
    (h : analyzeP ts tp rs rp catalog ns = .consistentOn sc) :
    sc = projScope ts tp rs rp ns := by
  unfold analyzeP at h
  rcases hf : pfindings ts tp rs rp catalog ns with _ | ⟨f, fs⟩
  · rcases hh : projHits ts tp rs rp ns with _ | ⟨x, xs⟩
    · simp only [hf, hh] at h
      exact ((ProjResult.consistentOn.inj h)).symm
    · simp [hf, hh] at h
  · simp [hf] at h

theorem scope_of_conflicts {ts tp : AtomTable} {rs rp : List ReaderSpec}
    {catalog : List String} {ns : List Norm} {hits : List ProjHit} {sc : ProjScope}
    (h : analyzeP ts tp rs rp catalog ns = .conflicts hits sc) :
    sc = projScope ts tp rs rp ns := by
  unfold analyzeP at h
  rcases hf : pfindings ts tp rs rp catalog ns with _ | ⟨f, fs⟩
  · rcases hh : projHits ts tp rs rp ns with _ | ⟨x, xs⟩
    · simp [hf, hh] at h
    · simp only [hf, hh] at h
      exact (ProjResult.conflicts.inj h).2.symm
  · simp [hf] at h

/-- Each `pointsPerPair` entry is a checked (same-act) pair together with the
exact number of partial valuations its search covers. -/
theorem projScope_points_spec (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) :
    ∀ e ∈ (projScope ts tp rs rp ns).pointsPerPair,
      ∃ p ∈ pairsOf ns, p.1.act = p.2.act ∧
        e = (p.1.id, p.2.id, (projVals ts tp rs rp p.1 p.2).length) := by
  intro e he
  obtain ⟨p, hp, rfl⟩ := List.mem_map.1 he
  obtain ⟨hmem, hsame⟩ := List.mem_filter.1 hp
  refine ⟨p, hmem, by simpa [sameAct] using hsame, ?_⟩
  rw [length_projVals]

/-- Checked and skipped pairs together are all the unordered pairs. -/
theorem projScope_pairs (ts tp : AtomTable) (rs rp : List ReaderSpec) (ns : List Norm) :
    (projScope ts tp rs rp ns).pairsChecked + (projScope ts tp rs rp ns).pairsSkipped =
      (pairsOf ns).length := by
  have : (checkedPairs ns).length ≤ (pairsOf ns).length := List.length_filter_le _ _
  simp only [projScope]
  omega

/-! ## Non-vacuity -/

private def exT : AtomTable :=
  [⟨"A", .bool, "Điều 1"⟩,
   ⟨"B", .enum [⟨"x", "Điều 1"⟩, ⟨"y", "Điều 1"⟩, ⟨"z", "Điều 1"⟩], "Điều 1"⟩]

private def exTP : AtomTable := [⟨"P", .bool, "Điều 1"⟩]

private def exRS : List ReaderSpec := [("A", 0, 1), ("B=z", 1, 2)]

private def exRP : List ReaderSpec := [("P", 0, 1)]

private def exN (id : String) (m : Modality) (act : String) (c : Cond) : Norm :=
  { id := id, modality := m, act := act, condition := c, exceptions := [], priority := none
  , source := { docId := "EX", docType := .law, effective := ⟨2020, 1, 1⟩, article := "Điều 1" }
  , references := [] }

/-- Same-act pair `a`,`b` never applies together; `c` has another act. -/
private def exOk : List Norm :=
  [exN "a" .prohibition "x" (.sit 0), exN "b" .obligation "x" (.not (.sit 0)),
   exN "c" .obligation "y" (.sit 1)]

/-- `a`,`b` clash and `a`,`d` clash; `b`,`d` (obligation, permission) do not. -/
private def exBad : List Norm :=
  [exN "a" .prohibition "x" (.sit 0), exN "b" .obligation "x" (.sit 0),
   exN "c" .obligation "y" (.sit 1), exN "d" .permission "x" (.sit 0)]

example : (analyzeP exT exTP exRS exRP [] exOk).isConsistentOn = true := by decide

example : (match analyzeP exT exTP exRS exRP [] exOk with
    | .consistentOn sc => (sc.pairsChecked, sc.pairsSkipped, sc.pointsPerPair, sc.constraintsUsed)
    | _ => (0, 0, [], true)) = (1, 2, [("a", "b", 2)], false) := by decide

example : (match analyzeP exT exTP exRS exRP [] exBad with
    | .conflicts hs _ => hs.map fun h => (h.left, h.right)
    | _ => []) = [("a", "b"), ("a", "d")] := by decide

example : analyzeP exT exTP exRS exRP [] [] = .invalid [PFinding.norm .emptyNormList] := by
  decide

/-- An empty enum is caught before any search, naming the atom. -/
example : (match analyzeP [⟨"A", .bool, "Điều 1"⟩, ⟨"B", .enum [], "Điều 1"⟩] exTP exRS exRP [] exOk with
    | .invalid fs => fs.contains (PFinding.table .situation (.emptyDomain "B"))
    | _ => false) = true := by decide

/-- Agreement with the full-domain `analyze` on these small cases. -/
example : (analyze (atomsOf exT exTP exRS exRP) [] exOk).isConsistentOn =
    (analyzeP exT exTP exRS exRP [] exOk).isConsistentOn := by decide

example : (analyze (atomsOf exT exTP exRS exRP) [] exBad).isConsistentOn =
    (analyzeP exT exTP exRS exRP [] exBad).isConsistentOn := by decide

end LexProof
