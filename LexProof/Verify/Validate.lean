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

/-! ### Closure of the priority graph, computed to a fixpoint

Iterating a fixed number of rounds makes *soundness* easy and *completeness*
hard: completeness would need a bound on path length, i.e. a pigeonhole
argument over walks. Iterating **to a fixpoint** instead makes both directions
provable, because at a fixpoint the collected set is closed under `succsOf` and
completeness follows by induction on `Reaches` with no length bound at all.

The iteration budget is `gnodes ns`, every id that can occur in the graph. The
budget cannot run out before the set is closed: each round that is not already
closed adds at least one new id, and the set stays inside `gnodes`.
-/

/-- Add each element of `xs` to `acc`, skipping ones already present. Written by
hand rather than with `List.eraseDups` because core has no `Nodup` lemma for
`eraseDups` and its loop lemmas are private. -/
def addAll : List NormId → List NormId → List NormId
  | [], acc => acc
  | x :: xs, acc => addAll xs (if x ∈ acc then acc else x :: acc)

theorem mem_addAll {y : NormId} : ∀ (xs acc : List NormId),
    y ∈ addAll xs acc ↔ y ∈ xs ∨ y ∈ acc := by
  intro xs
  induction xs with
  | nil => intro acc; simp [addAll]
  | cons x xs ih =>
    intro acc
    simp only [addAll, ih, List.mem_cons]
    split
    · next hx =>
      refine ⟨fun h => ?_, fun h => ?_⟩
      · exact Or.imp Or.inr id h
      · rcases h with (rfl | h) | h
        · exact Or.inr hx
        · exact Or.inl h
        · exact Or.inr h
    · next hx =>
      simp only [List.mem_cons]
      refine ⟨fun h => ?_, fun h => ?_⟩
      · rcases h with h | (rfl | h)
        · exact Or.inl (Or.inr h)
        · exact Or.inl (Or.inl rfl)
        · exact Or.inr h
      · rcases h with (rfl | h) | h
        · exact Or.inr (Or.inl rfl)
        · exact Or.inl h
        · exact Or.inr (Or.inr h)

theorem nodup_addAll : ∀ (xs acc : List NormId),
    acc.Nodup → (addAll xs acc).Nodup := by
  intro xs
  induction xs with
  | nil => intro acc h; exact h
  | cons x xs ih =>
    intro acc h
    simp only [addAll]
    split
    · exact ih _ h
    · next hx => exact ih _ (List.nodup_cons.mpr ⟨hx, h⟩)

/-- Every id that can occur in the priority graph: the ids of the norms, plus
every id they claim precedence over. -/
def gnodes (ns : List Norm) : List NormId :=
  addAll ((ns.map fun n => n.id) ++ ns.flatMap Norm.overrideIds) []

theorem nodup_gnodes (ns : List Norm) : (gnodes ns).Nodup :=
  nodup_addAll _ [] List.nodup_nil

theorem succsOf_subset_gnodes (ns : List Norm) (i : NormId) :
    succsOf ns i ⊆ gnodes ns := by
  intro y hy
  simp only [succsOf] at hy
  cases hf : ns.find? (fun n => n.id == i) with
  | none => rw [hf] at hy; simp at hy
  | some n =>
    rw [hf] at hy
    refine (mem_addAll _ _).mpr (Or.inl ?_)
    exact List.mem_append.mpr (Or.inr
      (List.mem_flatMap.mpr ⟨n, List.mem_of_find?_eq_some hf, hy⟩))

/-- One round: add the successors of everything collected so far. -/
def closureStep (ns : List Norm) (acc : List NormId) : List NormId :=
  addAll (acc.flatMap (succsOf ns)) acc

/-- Iterate `closureStep` until it adds nothing, using `budget` as the number
of rounds still allowed. -/
def closure (ns : List Norm) : List NormId → List NormId → List NormId
  | [], acc => acc
  | _ :: rest, acc =>
    if (closureStep ns acc).all (fun y => acc.contains y) then acc
    else closure ns rest (closureStep ns acc)

/-- The ids reachable from `i` in one or more steps.

`gn` is the iteration budget. It is a parameter rather than a call to
`gnodes ns` inside, so a caller that checks every norm of a document computes
the node list **once** instead of once per norm. -/
def reachableFrom (ns : List Norm) (gn : List NormId) (i : NormId) : List NormId :=
  closure ns gn (addAll (succsOf ns i) [])

/-- Can the norm reach itself through `overrides`, given a precomputed budget? -/
def inPriorityCycleWith (ns : List Norm) (gn : List NormId) (n : Norm) : Bool :=
  (reachableFrom ns gn n.id).contains n.id

/-- Can the norm reach itself through `overrides`? -/
def inPriorityCycle (ns : List Norm) (n : Norm) : Bool :=
  inPriorityCycleWith ns (gnodes ns) n

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
  let gn := gnodes ns
  (ns.filter fun n => inPriorityCycleWith ns gn n).map fun n => Finding.priorityCycle n.id

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

/-- The accumulator survives the iteration. -/
theorem subset_closure (ns : List Norm) : ∀ (budget acc : List NormId),
    acc ⊆ closure ns budget acc := by
  intro budget
  induction budget with
  | nil => intro acc; simp [closure]
  | cons b rest ih =>
    intro acc
    simp only [closure]
    split
    · exact fun _ h => h
    · intro y hy
      refine ih _ ?_
      simp only [closureStep]
      exact (mem_addAll _ _).mpr (Or.inr hy)

/-- Everything the closure collects from a set already reachable from `i` is
still reachable from `i` — soundness. -/
theorem closure_sound (ns : List Norm) (i : NormId) :
    ∀ (budget acc : List NormId), (∀ y ∈ acc, Reaches ns i y) →
      ∀ x ∈ closure ns budget acc, Reaches ns i x := by
  intro budget
  induction budget with
  | nil => intro acc hacc x hx; simp only [closure] at hx; exact hacc x hx
  | cons b rest ih =>
    intro acc hacc x hx
    simp only [closure] at hx
    split at hx
    · exact hacc x hx
    · refine ih _ ?_ x hx
      intro y hy
      simp only [closureStep] at hy
      rcases (mem_addAll _ _).mp hy with hy | hy
      · rcases List.mem_flatMap.mp hy with ⟨a, ha, hya⟩
        exact Reaches.step (hacc a ha) hya
      · exact hacc y hy

theorem closure_subset_gnodes (ns : List Norm) : ∀ (budget acc : List NormId),
    acc ⊆ gnodes ns → closure ns budget acc ⊆ gnodes ns := by
  intro budget
  induction budget with
  | nil => intro acc h; simpa only [closure] using h
  | cons b rest ih =>
    intro acc h
    simp only [closure]
    split
    · exact h
    · refine ih _ ?_
      intro y hy
      simp only [closureStep] at hy
      rcases (mem_addAll _ _).mp hy with hy | hy
      · rcases List.mem_flatMap.mp hy with ⟨a, _, hya⟩
        exact succsOf_subset_gnodes ns a hya
      · exact h hy

/-- **The fixpoint is reached before the budget runs out.** At the end the
collected set is closed under `succsOf`; this is what the bounded-rounds
version could not give, and it is what makes completeness provable. -/
theorem closure_closed (ns : List Norm) : ∀ (budget acc : List NormId),
    acc.Nodup → acc ⊆ gnodes ns →
    (gnodes ns).length ≤ budget.length + acc.length →
    ∀ x ∈ closure ns budget acc, succsOf ns x ⊆ closure ns budget acc := by
  intro budget
  induction budget with
  | nil =>
    intro acc hnd hsub hlen x hx
    simp only [closure] at hx ⊢
    intro y hy
    have hyg : y ∈ gnodes ns := succsOf_subset_gnodes ns x hy
    by_cases hya : y ∈ acc
    · exact hya
    · exfalso
      have h1 : (y :: acc) ⊆ gnodes ns := by
        intro z hz
        rcases List.mem_cons.mp hz with rfl | hz
        · exact hyg
        · exact hsub hz
      have h2 : (y :: acc).Nodup := List.nodup_cons.mpr ⟨hya, hnd⟩
      have h3 := List.Nodup.length_le_of_subset h2 h1
      simp only [List.length_cons, List.length_nil] at h3 hlen
      omega
  | cons b rest ih =>
    intro acc hnd hsub hlen
    by_cases hall : (closureStep ns acc).all (fun y => acc.contains y) = true
    · have hc : closure ns (b :: rest) acc = acc := by
        show (if (closureStep ns acc).all (fun y => acc.contains y) then acc
              else closure ns rest (closureStep ns acc)) = acc
        exact ite_eq_left hall
      rw [hc]
      intro x hx y hy
      have hmem : y ∈ closureStep ns acc := by
        simp only [closureStep]
        exact (mem_addAll _ _).mpr (Or.inl (List.mem_flatMap.mpr ⟨x, hx, hy⟩))
      have := List.all_eq_true.mp hall y hmem
      simpa only [List.contains_eq_mem, decide_eq_true_eq] using this
    · have hfalse : (closureStep ns acc).all (fun y => acc.contains y) = false := by
        simpa using hall
      have hc : closure ns (b :: rest) acc = closure ns rest (closureStep ns acc) := by
        show (if (closureStep ns acc).all (fun y => acc.contains y) then acc
              else closure ns rest (closureStep ns acc)) = _
        exact ite_eq_right hall
      rw [hc]
      -- the step added at least one new id, so the budget keeps up
      obtain ⟨w, hw, hwnot⟩ := List.all_eq_false.mp hfalse
      have hwacc : w ∉ acc := by
        intro hc'
        exact hwnot (by simpa only [List.contains_eq_mem, decide_eq_true_eq] using hc')
      have haccsub : acc ⊆ closureStep ns acc := by
        intro z hz
        simp only [closureStep]
        exact (mem_addAll _ _).mpr (Or.inr hz)
      have hgrow : acc.length + 1 ≤ (closureStep ns acc).length := by
        have h1 : (w :: acc) ⊆ closureStep ns acc := by
          intro z hz
          rcases List.mem_cons.mp hz with rfl | hz
          · exact hw
          · exact haccsub hz
        have h2 : (w :: acc).Nodup := List.nodup_cons.mpr ⟨hwacc, hnd⟩
        simpa only [List.length_cons] using List.Nodup.length_le_of_subset h2 h1
      refine ih _ (nodup_addAll _ _ hnd) ?_ ?_
      · intro y hy
        simp only [closureStep] at hy
        rcases (mem_addAll _ _).mp hy with hy | hy
        · rcases List.mem_flatMap.mp hy with ⟨a, _, hya⟩
          exact succsOf_subset_gnodes ns a hya
        · exact hsub hy
      · simp only [List.length_cons] at hlen
        omega

/-- **Completeness.** Every id reachable from `i` is collected. -/
theorem mem_reachableFrom_of_reaches {ns : List Norm} {i j : NormId}
    (h : Reaches ns i j) : j ∈ reachableFrom ns (gnodes ns) i := by
  have hnd : (addAll (succsOf ns i) []).Nodup := nodup_addAll _ [] List.nodup_nil
  have hsub : addAll (succsOf ns i) [] ⊆ gnodes ns := by
    intro y hy
    rcases (mem_addAll _ _).mp hy with hy | hy
    · exact succsOf_subset_gnodes ns i hy
    · simp at hy
  have hclosed := closure_closed ns (gnodes ns) (addAll (succsOf ns i) [])
    hnd hsub (Nat.le_add_right _ _)
  induction h with
  | base hb =>
    exact subset_closure ns _ _ ((mem_addAll _ _).mpr (Or.inl hb))
  | step _ hs ih => exact hclosed _ ih hs

/-- `inPriorityCycle` only fires on a real cycle. -/
theorem cycle_of_inPriorityCycle {ns : List Norm} {n : Norm}
    (h : inPriorityCycle ns n = true) : Reaches ns n.id n.id := by
  simp only [inPriorityCycle, inPriorityCycleWith, reachableFrom,
    List.contains_eq_mem, decide_eq_true_eq] at h
  refine closure_sound ns n.id (gnodes ns) (addAll (succsOf ns n.id) []) ?_ n.id h
  intro y hy
  rcases (mem_addAll _ _).mp hy with hy | hy
  · exact Reaches.base hy
  · simp at hy

/-- `inPriorityCycle` fires on **every** real cycle. -/
theorem inPriorityCycle_of_reaches {ns : List Norm} {n : Norm}
    (h : Reaches ns n.id n.id) : inPriorityCycle ns n = true := by
  simp only [inPriorityCycle, inPriorityCycleWith, List.contains_eq_mem,
    decide_eq_true_eq]
  exact mem_reachableFrom_of_reaches h

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

/-- **Completeness of cycle detection (D34).** Every norm that lies on a cycle
of the `overrides` relation gets a `priorityCycle` finding.

With `cycle_of_validate_finding` this closes the loop: the validator reports a
priority cycle for a norm **exactly when** that norm really lies on one. -/
theorem cycle_finding_of_reaches {A : Atoms S P} {catalog : List String}
    {ns : List Norm} {n : Norm} (hn : n ∈ ns) (h : Reaches ns n.id n.id) :
    Finding.priorityCycle n.id ∈ validate A catalog ns := by
  cases ns with
  | nil => simp at hn
  | cons n₀ rest =>
    simp only [validate]
    refine List.mem_append.mpr (Or.inr ?_)
    exact List.mem_map.mpr
      ⟨n, List.mem_filter.mpr ⟨hn, inPriorityCycle_of_reaches h⟩, rfl⟩

/-- **D40, the core step.** A silent validator means **no** norm lies on a
cycle of `overrides`. This is the contrapositive of completeness, and it is
what lets every searched result carry the guarantee. -/
theorem no_priority_cycle_of_validate_nil {A : Atoms S P} {catalog : List String}
    {ns : List Norm} (h : validate A catalog ns = []) :
    ∀ n ∈ ns, ¬ Reaches ns n.id n.id := by
  intro n hn hc
  have hmem := cycle_finding_of_reaches (A := A) (catalog := catalog) hn hc
  rw [h] at hmem
  simp at hmem

/-! ## Proved property 4: a silent validator means distinct ids, and then the
priority graph is exactly the `overrides` data -/

/-- **(a)** If the validator is silent, the norm ids are pairwise distinct.

Stated with `List.Nodup` on the id list rather than on `duplicateIds`, because
`Nodup` is the fact every later proof wants. -/
theorem nodup_ids_of_validate_nil {A : Atoms S P} {catalog : List String}
    {ns : List Norm} (h : validate A catalog ns = []) :
    (ns.map fun n => n.id).Nodup := by
  rw [List.nodup_iff_count]
  intro a
  by_cases hle : List.count a (ns.map fun n => n.id) ≤ 1
  · exact hle
  · exfalso
    have hlt : 1 < List.count a (ns.map fun n => n.id) := by omega
    have hmem : a ∈ (ns.map fun n => n.id) := List.count_pos_iff.mp (by omega)
    have hdup : a ∈ duplicateIds ns := by
      simp only [duplicateIds]
      refine List.mem_eraseDups.mpr (List.mem_filter.mpr ⟨hmem, ?_⟩)
      simp only [decide_eq_true_eq]
      rw [← List.countP_eq_length_filter, ← List.count_eq_countP]
      exact hlt
    have hfind : Finding.duplicateId a ∈ validate A catalog ns := by
      cases ns with
      | nil => simp [duplicateIds] at hdup
      | cons n₀ rest =>
        simp only [validate]
        refine List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl
          (List.mem_append.mpr (Or.inl (List.mem_append.mpr (Or.inl
            (List.mem_append.mpr (Or.inr ?_)))))))))
        exact List.mem_map.mpr ⟨a, hdup, rfl⟩
    rw [h] at hfind
    simp at hfind

/-- With distinct ids, looking a norm up by its own id finds that very norm. -/
theorem find?_eq_self_of_nodup_ids {ns : List Norm}
    (hnd : (ns.map fun n => n.id).Nodup) {n : Norm} (hn : n ∈ ns) :
    ns.find? (fun m => m.id == n.id) = some n := by
  induction ns with
  | nil => simp at hn
  | cons n₀ rest ih =>
    simp only [List.map_cons, List.nodup_cons] at hnd
    obtain ⟨hnotin, hnd'⟩ := hnd
    rcases List.mem_cons.mp hn with rfl | hn'
    · exact List.find?_cons_of_pos (by simp)
    · have hne : n₀.id ≠ n.id := by
        intro heq
        exact hnotin (heq ▸ List.mem_map.mpr ⟨n, hn', rfl⟩)
      rw [List.find?_cons_of_neg (by simp [hne])]
      exact ih hnd' hn'

/-- **(b)** With distinct ids, the step relation of the priority graph *is* the
`overrides` field of the norm — no lookup ambiguity.

This is what ties `Reaches` to the actual priority data: without it, `succsOf`
could in principle read a different norm that happens to share an id. -/
theorem succsOf_eq_overrideIds_of_nodup_ids {ns : List Norm}
    (hnd : (ns.map fun n => n.id).Nodup) {n : Norm} (hn : n ∈ ns) :
    succsOf ns n.id = n.overrideIds := by
  simp only [succsOf, find?_eq_self_of_nodup_ids hnd hn]

/-- (a) and (b) composed: after a silent validator run, the priority graph the
cycle check walks is literally the `overrides` data of the norms. -/
theorem succsOf_eq_overrideIds_of_validate_nil {A : Atoms S P}
    {catalog : List String} {ns : List Norm} (h : validate A catalog ns = []) :
    ∀ n ∈ ns, succsOf ns n.id = n.overrideIds := fun _ hn =>
  succsOf_eq_overrideIds_of_nodup_ids (nodup_ids_of_validate_nil h) hn

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
