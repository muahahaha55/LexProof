import LexProof.Core.AtomTable
import LexProof.Verify.Projection
import LexProof.Verify.Validate

/-!
# Table well-formedness and the projected pair check (unconstrained case)

**Additive.** Nothing here is called by `check` or `analyze`, and no existing
declaration is changed.

## Part A — table well-formedness

`analyze` answers `consistentOn` when the situation space is **empty** (an enum
atom with no bands): `Scope.situations = 0`, and every pair of norms is
"consistent" because there is no point at which to clash (see
`eval/projected/A0_empty_domain.lean`: two norms that clash at every point
still give `consistentOn` over an empty space). The validator does not notice.
`tableFindings` / `readerFindings` name such defects; `card_pos_of_tableFindings`
shows a silent table has a non-empty situation space.

## Part B — projected check over atoms

For a pair of norms the search enumerates **partial valuations of exactly the
atoms the pair reads** (through the readers), not the whole product.

* `not_conflict_of_projConsistentT` (B2, soundness): no conflicting partial
  valuation ⇒ no `Conflict` at any `(π, s)` of the full domains.
* `exists_conflict_of_not_projConsistentT` (B3, realisability): a conflicting
  partial valuation ⇒ some `(π, s)` has `Conflict`.
* `length_projVals` (B4): the number of partial valuations enumerated is the
  product of the domains of the atoms read.

**Assumptions, exactly.** B2: every reader names an existing atom
(`ReaderAtomsOk`, implied by a silent `readerFindings`). B3: every domain of both
tables is non-empty (`AtomTable.NonEmpty`, implied by a silent `tableFindings`),
and **no integrity constraints** — `valid` is the default of `atomsOf`, so every
point is valid. With constraints B3 would additionally need the completion to
satisfy them (satisfiability over the atoms the constraints share with the
assignment); that is not defined or proved here, and B2 would need the
constraints to only remove points (it holds as stated, ignoring them).

## Not given

`Scope` is unchanged (it still reports full-product sizes and scans
`Finite.enum`); `coApplyPoint?` (D23) is unchanged. There is no whole-document
wrapper and nothing connects these checks to `analyze`.
-/

namespace LexProof

/-! ## Part A: table well-formedness -/

/-- One defect of a table or of its readers, naming the offender. -/
inductive TableFinding
  | duplicateAtomName (name : String)
  | emptyDomain (atom : String)
  | duplicateBandLabel (atom : String) (label : String)
  | emptyAtomSource (atom : String)
  | emptyBandSource (atom : String) (label : String)
  | readerAtomOutOfRange (reader : String) (atom : Nat)
  | readerValueOutOfRange (reader : String) (atom : Nat) (value : Nat)
  deriving Repr, DecidableEq

/-- Remove repeated strings (keeps the last occurrence). -/
def dedupStr : List String → List String
  | [] => []
  | x :: xs => if xs.contains x then dedupStr xs else x :: dedupStr xs

/-- The distinct strings that occur more than once. -/
def repeated (l : List String) : List String := dedupStr (l.filter fun x => 1 < l.count x)

/-- No bands at all (an enum with an empty list). -/
def Domain.isEmpty : Domain → Bool
  | .bool => false
  | .enum vs => vs.isEmpty

/-- The named bands of a domain (none for `Bool`). -/
def Domain.bands : Domain → List Band
  | .bool => []
  | .enum vs => vs

def atomFindings (a : Atom) : List TableFinding :=
  (if a.domain.isEmpty then [TableFinding.emptyDomain a.name] else []) ++
  (repeated (a.domain.bands.map (·.label))).map (TableFinding.duplicateBandLabel a.name) ++
  (if a.source.isEmpty then [TableFinding.emptyAtomSource a.name] else []) ++
  (a.domain.bands.filter fun b => b.source.isEmpty).map fun b =>
    TableFinding.emptyBandSource a.name b.label

/-- Unique atom names; every enum non-empty; band labels unique within an atom;
every source string (atom and band) non-empty. `[]` means none of these defects
was found; it says nothing about whether the names or sources are *right*. -/
def tableFindings (t : AtomTable) : List TableFinding :=
  (repeated (t.map (·.name))).map TableFinding.duplicateAtomName ++ t.flatMap atomFindings

/-- Each reader names an existing atom and an existing value of it. -/
def readerFindings (t : AtomTable) (rs : List ReaderSpec) : List TableFinding :=
  rs.flatMap fun r =>
    match t.sizes[r.2.1]? with
    | none => [TableFinding.readerAtomOutOfRange r.1 r.2.1]
    | some d =>
      if r.2.2 < d then [] else [TableFinding.readerValueOutOfRange r.1 r.2.1 r.2.2]

/-- Every reader names an existing atom and a value inside its domain. -/
def ReadersOk (t : AtomTable) (rs : List ReaderSpec) : Prop :=
  ∀ r ∈ rs, ∃ d, t.sizes[r.2.1]? = some d ∧ r.2.2 < d

/-- Every reader names an existing atom (the part B2 needs). -/
def ReaderAtomsOk (t : AtomTable) (rs : List ReaderSpec) : Prop :=
  ∀ r ∈ rs, r.2.1 < t.sizes.length

theorem readerAtomsOk_of_readersOk {t : AtomTable} {rs : List ReaderSpec}
    (h : ReadersOk t rs) : ReaderAtomsOk t rs := by
  intro r hr
  obtain ⟨d, hd, _⟩ := h r hr
  exact (List.getElem?_eq_some_iff.1 hd).1

theorem readersOk_of_readerFindings {t : AtomTable} {rs : List ReaderSpec}
    (h : readerFindings t rs = []) : ReadersOk t rs := by
  intro r hr
  have h1 := (List.flatMap_eq_nil_iff.1 h) r hr
  cases hs : t.sizes[r.2.1]? with
  | none => simp [hs] at h1
  | some d =>
    refine ⟨d, rfl, ?_⟩
    by_cases hlt : r.2.2 < d
    · exact hlt
    · simp [hs, hlt] at h1

theorem size_pos_of_not_isEmpty {d : Domain} (h : d.isEmpty = false) : 0 < d.size := by
  cases d with
  | bool => simp [Domain.size]
  | enum vs =>
    cases vs with
    | nil => simp [Domain.isEmpty] at h
    | cons v vs => simp [Domain.size]

theorem nonEmpty_of_tableFindings {t : AtomTable} (h : tableFindings t = []) :
    t.NonEmpty := by
  intro d hd
  obtain ⟨a, ha, rfl⟩ := List.mem_map.1 hd
  have h2 : t.flatMap atomFindings = [] := (List.append_eq_nil_iff.1 h).2
  have h3 := (List.flatMap_eq_nil_iff.1 h2) a ha
  have h4 : (if a.domain.isEmpty then [TableFinding.emptyDomain a.name] else []) = [] :=
    (List.append_eq_nil_iff.1 (List.append_eq_nil_iff.1 (List.append_eq_nil_iff.1 h3).1).1).1
  apply size_pos_of_not_isEmpty
  cases hE : a.domain.isEmpty with
  | false => rfl
  | true => simp [hE] at h4

theorem prodSizes_pos : ∀ ds : List Nat, (∀ d ∈ ds, 0 < d) → 0 < prodSizes ds
  | [], _ => by simp [prodSizes]
  | d :: ds, h => by
    simp only [prodSizes]
    exact Nat.mul_pos (h d (by simp)) (prodSizes_pos ds (fun e he => h e (by simp [he])))

/-- (A2) A table with no findings has a non-empty situation space. -/
theorem card_pos_of_tableFindings {t : AtomTable} (h : tableFindings t = []) :
    0 < Finite.card (Valuation t) := by
  rw [Valuation.card_eq]
  exact prodSizes_pos _ (nonEmpty_of_tableFindings h)

/-! ## Part B: the projected pair check -/

/-- Value of reader `i` under a partial assignment of atoms. `none` when the
reader or its atom is missing. -/
def renv (rs : List ReaderSpec) (p : PartialAssign) (i : Nat) : Option Bool :=
  (rs[i]?).bind fun r => (pget p r.2.1).map fun v => v == r.2.2

/-- The atoms read through the readers with the given indices, each once. -/
def readAtoms (rs : List ReaderSpec) (idxs : List Nat) : List Nat :=
  dedupNat (idxs.filterMap fun i => (rs[i]?).map fun r => r.2.1)

/-- Every assignment to the given atoms, each inside its domain. -/
def assignsT (sizes : List Nat) : List Nat → List PartialAssign
  | [] => [[]]
  | i :: is =>
    (List.range (sizes.getD i 0)).flatMap fun v => (assignsT sizes is).map ((i, v) :: ·)

/-- Situation atoms the pair reads. -/
def pairAtomsS (rs : List ReaderSpec) (n₁ n₂ : Norm) : List Nat :=
  readAtoms rs (n₁.sitIdxs ++ n₂.sitIdxs)

/-- Parameter atoms the pair reads. -/
def pairAtomsP (rp : List ReaderSpec) (n₁ n₂ : Norm) : List Nat :=
  readAtoms rp (n₁.paramIdxs ++ n₂.paramIdxs)

/-- Every partial valuation of the atoms the pair reads (situation × parameter). -/
def projVals (ts tp : AtomTable) (rs rp : List ReaderSpec) (n₁ n₂ : Norm) :
    List (PartialAssign × PartialAssign) :=
  (assignsT ts.sizes (pairAtomsS rs n₁ n₂)).flatMap fun p =>
    (assignsT tp.sizes (pairAtomsP rp n₁ n₂)).map fun q => (p, q)

/-- The five clauses of `Conflict`, read from partial assignments. Mentions no
`Atoms`, no `valid`. -/
def projConflictT (rs rp : List ReaderSpec) (n₁ n₂ : Norm) (p q : PartialAssign) : Bool :=
  decide (n₁.act = n₂.act) &&
  decide (n₁.appliesE (renv rs p) (renv rp q) = some true) &&
  decide (n₂.appliesE (renv rs p) (renv rp q) = some true) &&
  Incompatible n₁.modality n₂.modality &&
  !(Norm.resolved n₁ n₂)

/-- No partial valuation of the atoms the pair reads yields a clash. -/
def projConsistentT (ts tp : AtomTable) (rs rp : List ReaderSpec) (n₁ n₂ : Norm) : Bool :=
  (projVals ts tp rs rp n₁ n₂).all fun v => !projConflictT rs rp n₁ n₂ v.1 v.2

/-! ### Enumeration lemmas -/

theorem nodup_dedupNat : ∀ l : List Nat, (dedupNat l).Nodup
  | [] => by simp [dedupNat]
  | x :: xs => by
    have ih := nodup_dedupNat xs
    by_cases h : x ∈ xs
    · simp [dedupNat, h, ih]
    · have hx : x ∉ dedupNat xs := fun hm => h ((mem_dedupNat xs x).1 hm)
      simp only [dedupNat, h, ite_false]
      exact List.nodup_cons.2 ⟨hx, ih⟩

theorem mem_assignsT_cons {sizes : List Nat} {i : Nat} {is : List Nat} {p : PartialAssign} :
    p ∈ assignsT sizes (i :: is) ↔
      ∃ v, v < sizes.getD i 0 ∧ ∃ p' ∈ assignsT sizes is, p = (i, v) :: p' := by
  simp only [assignsT, List.mem_flatMap, List.mem_range, List.mem_map]
  constructor
  · rintro ⟨v, hv, p', hp', rfl⟩
    exact ⟨v, hv, p', hp', rfl⟩
  · rintro ⟨v, hv, p', hp', rfl⟩
    exact ⟨v, hv, p', hp', rfl⟩

theorem assignsT_complete (sizes : List Nat) (f : Nat → Nat) :
    ∀ atoms : List Nat, (∀ a ∈ atoms, f a < sizes.getD a 0) →
      ∃ p ∈ assignsT sizes atoms, ∀ a ∈ atoms, pget p a = some (f a)
  | [], _ => ⟨[], by simp [assignsT], by simp⟩
  | i :: is, hf => by
    obtain ⟨p', hp', hl⟩ := assignsT_complete sizes f is (fun a ha => hf a (by simp [ha]))
    refine ⟨(i, f i) :: p', mem_assignsT_cons.2 ⟨f i, hf i (by simp), p', hp', rfl⟩, ?_⟩
    intro a ha
    by_cases hia : i = a
    · subst hia; simp [pget]
    · have ha' : a ∈ is := by
        rcases List.mem_cons.1 ha with h | h
        · exact absurd h.symm hia
        · exact h
      simp [pget, hia, hl a ha']

theorem assignsT_total (sizes : List Nat) :
    ∀ (atoms : List Nat) (p : PartialAssign), p ∈ assignsT sizes atoms →
      ∀ a ∈ atoms, ∃ v, pget p a = some v
  | [], _, _, a, ha => by simp at ha
  | i :: is, p, hp, a, ha => by
    obtain ⟨v, _, p', hp', rfl⟩ := mem_assignsT_cons.1 hp
    by_cases hia : i = a
    · exact ⟨v, by simp [pget, hia]⟩
    · have ha' : a ∈ is := by
        rcases List.mem_cons.1 ha with h | h
        · exact absurd h.symm hia
        · exact h
      obtain ⟨w, hw⟩ := assignsT_total sizes is p' hp' a ha'
      exact ⟨w, by simp [pget, hia, hw]⟩

theorem keys_assignsT (sizes : List Nat) :
    ∀ (atoms : List Nat) (p : PartialAssign), p ∈ assignsT sizes atoms →
      p.map Prod.fst = atoms
  | [], p, hp => by simp [assignsT] at hp; simp [hp]
  | i :: is, p, hp => by
    obtain ⟨v, _, p', hp', rfl⟩ := mem_assignsT_cons.1 hp
    simp [keys_assignsT sizes is p' hp']

theorem entries_assignsT (sizes : List Nat) :
    ∀ (atoms : List Nat) (p : PartialAssign), p ∈ assignsT sizes atoms →
      ∀ x ∈ p, x.2 < sizes.getD x.1 0
  | [], p, hp, x, hx => by simp [assignsT] at hp; simp [hp] at hx
  | i :: is, p, hp, x, hx => by
    obtain ⟨v, hv, p', hp', rfl⟩ := mem_assignsT_cons.1 hp
    rcases List.mem_cons.1 hx with rfl | h
    · exact hv
    · exact entries_assignsT sizes is p' hp' x h

theorem consistent_of_nodup_keys :
    ∀ p : PartialAssign, (p.map Prod.fst).Nodup →
      ∀ x ∈ p, ∀ y ∈ p, x.1 = y.1 → x.2 = y.2
  | [], _, x, hx, _, _, _ => by simp at hx
  | (k, w) :: r, hn, x, hx, y, hy, hxy => by
    obtain ⟨hk, hr⟩ := List.nodup_cons.1 (by simpa using hn : (k :: r.map Prod.fst).Nodup)
    have key : ∀ z ∈ r, z.1 ≠ k := fun z hz hzk =>
      hk (List.mem_map.2 ⟨z, hz, hzk⟩)
    rcases List.mem_cons.1 hx with rfl | hxr
    · rcases List.mem_cons.1 hy with rfl | hyr
      · rfl
      · exact absurd hxy.symm (key y hyr)
    · rcases List.mem_cons.1 hy with rfl | hyr
      · exact absurd hxy (key x hxr)
      · exact consistent_of_nodup_keys r hr x hxr y hyr hxy

theorem ok_of_mem_assignsT (t : AtomTable) (atoms : List Nat) (hnd : atoms.Nodup)
    (p : PartialAssign) (hp : p ∈ assignsT t.sizes atoms) : PartialAssign.Ok t p := by
  refine ⟨?_, ?_⟩
  · intro x hx
    have hlt := entries_assignsT t.sizes atoms p hp x hx
    cases hs : t.sizes[x.1]? with
    | none => simp [List.getD_eq_getElem?_getD, hs] at hlt
    | some d => exact ⟨d, rfl, by simpa [List.getD_eq_getElem?_getD, hs] using hlt⟩
  · apply consistent_of_nodup_keys
    rw [keys_assignsT t.sizes atoms p hp]
    exact hnd

/-! ### From valuations to readers -/

theorem legalVals_getD_lt : ∀ (ds vs : List Nat) (a : Nat), legalVals ds vs = true →
    a < ds.length → vs.getD a 0 < ds.getD a 0
  | [], _, a, _, ha => by simp at ha
  | d :: ds, [], _, h, _ => by simp [legalVals] at h
  | d :: ds, v :: vs, a, h, ha => by
    simp only [legalVals, Bool.and_eq_true, decide_eq_true_eq] at h
    cases a with
    | zero => simpa using h.1
    | succ a =>
      simpa using legalVals_getD_lt ds vs a h.2 (by simpa using ha)

theorem Valuation.get_lt {t : AtomTable} (s : Valuation t) {a : Nat}
    (ha : a < t.sizes.length) : s.get a < t.sizes.getD a 0 :=
  legalVals_getD_lt t.sizes s.vs a s.h ha

theorem sitVal_atomsOf {ts tp : AtomTable} (rs rp : List ReaderSpec) (s : Valuation ts)
    (i : Nat) :
    (atomsOf ts tp rs rp).sitVal s i =
      (rs[i]?).map fun r => Valuation.reads r.2.1 r.2.2 s := by
  simp [Atoms.sitVal, atomsOf, List.getElem?_map]
  rfl

theorem parVal_atomsOf {ts tp : AtomTable} (rs rp : List ReaderSpec) (π : Valuation tp)
    (i : Nat) :
    (atomsOf ts tp rs rp).parVal π i =
      (rp[i]?).map fun r => Valuation.reads r.2.1 r.2.2 π := by
  simp [Atoms.parVal, atomsOf, List.getElem?_map]
  rfl

/-- The partial assignment `p` records the true value of every atom read through
the readers `idxs`. -/
def AgreeOn {t : AtomTable} (rs : List ReaderSpec) (p : PartialAssign)
    (s : Valuation t) (idxs : List Nat) : Prop :=
  ∀ i ∈ idxs, ∀ r, rs[i]? = some r → pget p r.2.1 = some (s.get r.2.1)

theorem renv_eq {t : AtomTable} {rs : List ReaderSpec} {p : PartialAssign}
    {s : Valuation t} {i : Nat}
    (h : ∀ r, rs[i]? = some r → pget p r.2.1 = some (s.get r.2.1)) :
    renv rs p i = (rs[i]?).map fun r => Valuation.reads r.2.1 r.2.2 s := by
  cases hr : rs[i]? with
  | none => simp [renv, hr]
  | some r => simp [renv, hr, h r hr, Valuation.reads]

theorem agreeOn_of_atoms {t : AtomTable} {rs : List ReaderSpec} {p : PartialAssign}
    {s : Valuation t} {idxs : List Nat}
    (H : ∀ a ∈ readAtoms rs idxs, pget p a = some (s.get a)) : AgreeOn rs p s idxs := by
  intro i hi r hr
  apply H
  refine (mem_dedupNat _ _).2 (List.mem_filterMap.2 ⟨i, hi, ?_⟩)
  simp [hr]

theorem appliesE_renv {ts tp : AtomTable} {rs rp : List ReaderSpec} (n : Norm)
    (p q : PartialAssign) (π : Valuation tp) (s : Valuation ts)
    (hs : AgreeOn rs p s n.sitIdxs) (hp : AgreeOn rp q π n.paramIdxs) :
    n.appliesE (renv rs p) (renv rp q) = n.applies (atomsOf ts tp rs rp) π s := by
  rw [Norm.applies_eq_appliesE]
  refine Norm.appliesE_congr n (fun i hi => ?_) (fun i hi => ?_)
  · rw [sitVal_atomsOf]; exact renv_eq (hs i hi)
  · rw [parVal_atomsOf]; exact renv_eq (hp i hi)

/-- The projected clash test agrees with `Conflict` whenever the partial
assignments record the true values of the atoms read. -/
theorem projConflictT_iff {ts tp : AtomTable} {rs rp : List ReaderSpec} (n₁ n₂ : Norm)
    (p q : PartialAssign) (π : Valuation tp) (s : Valuation ts)
    (Hs : ∀ a ∈ pairAtomsS rs n₁ n₂, pget p a = some (s.get a))
    (Hp : ∀ a ∈ pairAtomsP rp n₁ n₂, pget q a = some (π.get a)) :
    projConflictT rs rp n₁ n₂ p q = true ↔ Conflict (atomsOf ts tp rs rp) n₁ n₂ π s := by
  have as := agreeOn_of_atoms Hs
  have ap := agreeOn_of_atoms Hp
  have e₁ := appliesE_renv (rs := rs) (rp := rp) n₁ p q π s
    (fun i hi => as i (List.mem_append.2 (Or.inl hi)))
    (fun i hi => ap i (List.mem_append.2 (Or.inl hi)))
  have e₂ := appliesE_renv (rs := rs) (rp := rp) n₂ p q π s
    (fun i hi => as i (List.mem_append.2 (Or.inr hi)))
    (fun i hi => ap i (List.mem_append.2 (Or.inr hi)))
  simp [projConflictT, Conflict, e₁, e₂, and_assoc]

/-! ### B2 and B3 -/

/-- (B2) Soundness. If no partial valuation of the atoms the pair reads yields a
clash, there is no `Conflict` at any `(π, s)` of the full domains. Needs every
reader to name an existing atom. -/
theorem not_conflict_of_projConsistentT {ts tp : AtomTable} {rs rp : List ReaderSpec}
    (hrs : ReaderAtomsOk ts rs) (hrp : ReaderAtomsOk tp rp) (n₁ n₂ : Norm)
    (h : projConsistentT ts tp rs rp n₁ n₂ = true) (π : Valuation tp) (s : Valuation ts) :
    ¬ Conflict (atomsOf ts tp rs rp) n₁ n₂ π s := by
  intro hc
  have hlt : ∀ (t : AtomTable) (rr : List ReaderSpec), ReaderAtomsOk t rr →
      ∀ (idxs : List Nat) (a : Nat), a ∈ readAtoms rr idxs → a < t.sizes.length := by
    intro t rr hrr idxs a ha
    obtain ⟨i, _, hi⟩ := List.mem_filterMap.1 ((mem_dedupNat _ _).1 ha)
    obtain ⟨r, hr, rfl⟩ := Option.map_eq_some_iff.1 hi
    exact hrr r (List.mem_of_getElem? hr)
  obtain ⟨p, hp, hlp⟩ := assignsT_complete ts.sizes (fun a => s.get a) (pairAtomsS rs n₁ n₂)
    (fun a ha => Valuation.get_lt s (hlt ts rs hrs _ a ha))
  obtain ⟨q, hq, hlq⟩ := assignsT_complete tp.sizes (fun a => π.get a) (pairAtomsP rp n₁ n₂)
    (fun a ha => Valuation.get_lt π (hlt tp rp hrp _ a ha))
  have hv : (p, q) ∈ projVals ts tp rs rp n₁ n₂ :=
    List.mem_flatMap.2 ⟨p, hp, List.mem_map.2 ⟨q, hq, rfl⟩⟩
  have hpc := (projConflictT_iff n₁ n₂ p q π s hlp hlq).2 hc
  have hall := (List.all_eq_true.1 h) (p, q) hv
  simp [hpc] at hall

/-- (B3) Realisability, unconstrained case. If some partial valuation of the atoms
the pair reads yields a clash, there are `π` and `s` with `Conflict`, and the
point is valid (`valid` is the default of `atomsOf`). Needs every domain of both
tables non-empty. -/
theorem exists_conflict_of_not_projConsistentT {ts tp : AtomTable} {rs rp : List ReaderSpec}
    (hts : ts.NonEmpty) (htp : tp.NonEmpty) (n₁ n₂ : Norm)
    (h : projConsistentT ts tp rs rp n₁ n₂ = false) :
    ∃ (π : Valuation tp) (s : Valuation ts),
      (atomsOf ts tp rs rp).valid π s = true ∧ Conflict (atomsOf ts tp rs rp) n₁ n₂ π s := by
  have hne : ¬ ((projVals ts tp rs rp n₁ n₂).all fun v =>
      !projConflictT rs rp n₁ n₂ v.1 v.2) = true := by
    intro hh; unfold projConsistentT at h; rw [hh] at h; exact absurd h (by simp)
  have hex : ∃ x ∈ projVals ts tp rs rp n₁ n₂, ¬ ((!projConflictT rs rp n₁ n₂ x.1 x.2) = true) := by
    exact Classical.byContradiction fun hno => hne (List.all_eq_true.2 fun x hx =>
      Classical.byContradiction fun hx2 => hno ⟨x, hx, hx2⟩)
  obtain ⟨⟨p, q⟩, hv, hbad⟩ := hex
  have hpc : projConflictT rs rp n₁ n₂ p q = true := by simpa using hbad
  obtain ⟨p0, hp0, q0, hq0, hpq⟩ : ∃ p0 ∈ assignsT ts.sizes (pairAtomsS rs n₁ n₂),
      ∃ q0 ∈ assignsT tp.sizes (pairAtomsP rp n₁ n₂), (p0, q0) = (p, q) := by
    obtain ⟨p0, hp0, hh⟩ := List.mem_flatMap.1 hv
    obtain ⟨q0, hq0, hh⟩ := List.mem_map.1 hh
    exact ⟨p0, hp0, q0, hq0, hh⟩
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj hpq
  obtain ⟨s, hs⟩ := PartialAssign.extend ts hts p0
    (ok_of_mem_assignsT ts _ (nodup_dedupNat _) p0 hp0)
  obtain ⟨π, hπ⟩ := PartialAssign.extend tp htp q0
    (ok_of_mem_assignsT tp _ (nodup_dedupNat _) q0 hq0)
  have Hs : ∀ a ∈ pairAtomsS rs n₁ n₂, pget p0 a = some (s.get a) := by
    intro a ha
    obtain ⟨v, hv⟩ := assignsT_total ts.sizes _ p0 hp0 a ha
    have := hs (a, v) (pget_mem hv)
    simp only [Valuation.get, List.getD_eq_getElem?_getD, this]
    simpa using hv
  have Hp : ∀ a ∈ pairAtomsP rp n₁ n₂, pget q0 a = some (π.get a) := by
    intro a ha
    obtain ⟨v, hv⟩ := assignsT_total tp.sizes _ q0 hq0 a ha
    have := hπ (a, v) (pget_mem hv)
    simp only [Valuation.get, List.getD_eq_getElem?_getD, this]
    simpa using hv
  exact ⟨π, s, rfl, (projConflictT_iff n₁ n₂ p0 q0 π s Hs Hp).1 hpc⟩

/-! ### B4: how many points are enumerated -/

theorem length_assignsT (sizes : List Nat) :
    ∀ atoms : List Nat,
      (assignsT sizes atoms).length = prodSizes (atoms.map fun a => sizes.getD a 0)
  | [] => by simp [assignsT, prodSizes]
  | i :: is => by
    have h := length_flatMap_const (List.range (sizes.getD i 0))
      (fun v => (assignsT sizes is).map ((i, v) :: ·))
      (assignsT sizes is).length (fun _ _ => by simp)
    simpa [assignsT, prodSizes, length_assignsT sizes is] using h

/-- Number of points the projected search of one pair enumerates: the product of
the domains of the atoms read, situation side times parameter side. -/
def projPoints (ts tp : AtomTable) (rs rp : List ReaderSpec) (n₁ n₂ : Norm) : Nat :=
  prodSizes ((pairAtomsS rs n₁ n₂).map fun a => ts.sizes.getD a 0) *
    prodSizes ((pairAtomsP rp n₁ n₂).map fun a => tp.sizes.getD a 0)

/-- (B4) The projected search enumerates exactly `projPoints` partial valuations. -/
theorem length_projVals (ts tp : AtomTable) (rs rp : List ReaderSpec) (n₁ n₂ : Norm) :
    (projVals ts tp rs rp n₁ n₂).length = projPoints ts tp rs rp n₁ n₂ := by
  have h := length_flatMap_const (assignsT ts.sizes (pairAtomsS rs n₁ n₂))
    (fun p => (assignsT tp.sizes (pairAtomsP rp n₁ n₂)).map fun q => (p, q))
    (assignsT tp.sizes (pairAtomsP rp n₁ n₂)).length (fun _ _ => by simp)
  simpa [projVals, projPoints, length_assignsT] using h

/-! ## Non-vacuity -/

private def demoT : AtomTable :=
  [⟨"S1", .bool, "Điều 1"⟩, ⟨"S2", .enum [], "Điều 1"⟩, ⟨"S1", .bool, ""⟩]

example : tableFindings demoT =
    [.duplicateAtomName "S1", .emptyDomain "S2", .emptyAtomSource "S1"] := by decide

example : readerFindings demoT [("r", 5, 0), ("v", 0, 7), ("ok", 0, 1)] =
    [.readerAtomOutOfRange "r" 5, .readerValueOutOfRange "v" 0 7] := by decide

private def demoOk : AtomTable :=
  [⟨"A", .bool, "Điều 1"⟩, ⟨"B", .enum [⟨"x", "Điều 1"⟩, ⟨"y", "Điều 1"⟩, ⟨"z", "Điều 1"⟩], "Điều 1"⟩]

example : tableFindings demoOk = [] := by decide

private def demoN (m : Modality) (c : Cond) : Norm :=
  { (default : Norm) with modality := m, act := "x", condition := c }

/-- Two norms reading the same reader (atom `A` is true) clash; the projected
search enumerates only the atom `A` (2 of the 6 situations). -/
example : projConsistentT demoOk demoOk [("A", 0, 1)] []
    (demoN .prohibition (.sit 0)) (demoN .obligation (.sit 0)) = false := by decide

example : projConsistentT demoOk demoOk [("A", 0, 1)] []
    (demoN .prohibition (.sit 0)) (demoN .obligation (.not (.sit 0))) = true := by decide

example : projPoints demoOk demoOk [("A", 0, 1)] []
    (demoN .prohibition (.sit 0)) (demoN .obligation (.sit 0)) = 2 := by decide

end LexProof
