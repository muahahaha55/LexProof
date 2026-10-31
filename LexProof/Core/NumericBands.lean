import LexProof.Core.AtomTable

/-!
# Numeric bands over integer units, and a tiling check

A **band specification** lists bands over an integer scale (tenths of a degree of alcohol, whole years of
age): lower bound inclusive, upper bound exclusive, a label, and the source clause of each bound. Each bound
also says whether the law states it (`loStated` / `hiStated`); a bound the law does not state is marked
«assumed, not in the law» by the module that uses it.

`tiles bs a b` is a decidable check that the bands cover `[a, b)` with no gap and no overlap, in list order.
`tiles_unique_band` proves that then every number in the range has exactly one band and `bandOf` returns it.

**What this does not do.** It does not know what the numbers mean: not that 150 tenths is «15 độ», not that
18 is the age in the law, not that an age is counted in whole years. It only checks that the bands tile the
stated range. A wrong boundary that still tiles is invisible here.
-/

namespace LexProof

structure NumBand where
  lo : Int
  hi : Int
  label : String
  loSource : String
  hiSource : String
  loStated : Bool
  hiStated : Bool
  deriving Repr, DecidableEq

/-- Bands in list order: each starts where the previous one ends, each is non-empty, the first starts at `a`
and the last ends at `b`. -/
def bandsChain : Int → List NumBand → Int → Bool
  | a, [], b => a == b
  | a, x :: xs, b => x.lo == a && decide (x.lo < x.hi) && bandsChain x.hi xs b

/-- The bands tile `[a, b)` (`a < b`): no gap, no overlap. -/
def tiles (bs : List NumBand) (a b : Int) : Bool := decide (a < b) && bandsChain a bs b

/-- Label of the first band that contains `x`; `none` outside every band. -/
def bandOf : List NumBand → Int → Option String
  | [], _ => none
  | b :: bs, x => if b.lo ≤ x ∧ x < b.hi then some b.label else bandOf bs x

/-- Bounds the law does not state, as text for the reviewer. -/
def NumBand.assumedBounds (b : NumBand) : List String :=
  (if b.loStated then [] else [s!"{b.label}: cận dưới {b.lo} — assumed, not in the law ({b.loSource})"]) ++
  (if b.hiStated then [] else [s!"{b.label}: cận trên {b.hi} — assumed, not in the law ({b.hiSource})"])

theorem bandsChain_lo : ∀ (bs : List NumBand) (a b : Int), bandsChain a bs b = true →
    ∀ x ∈ bs, a ≤ x.lo
  | [], _, _, _, x, hx => by simp at hx
  | y :: ys, a, b, h, x, hx => by
    simp only [bandsChain, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨hlo, hlt⟩, hrest⟩ := h
    rcases List.mem_cons.1 hx with rfl | hx
    · omega
    · have := bandsChain_lo ys y.hi b hrest x hx
      omega

theorem bandsChain_hi : ∀ (bs : List NumBand) (a b : Int), bandsChain a bs b = true →
    ∀ x ∈ bs, x.hi ≤ b
  | [], _, _, _, x, hx => by simp at hx
  | y :: ys, a, b, h, x, hx => by
    simp only [bandsChain, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨hlo, hlt⟩, hrest⟩ := h
    rcases List.mem_cons.1 hx with rfl | hx
    · cases ys with
      | nil => simp only [bandsChain, beq_iff_eq] at hrest; omega
      | cons z zs =>
        have := bandsChain_lo (z :: zs) x.hi b hrest z (by simp)
        have h2 := bandsChain_hi (z :: zs) x.hi b hrest z (by simp)
        have h3 : z.lo < z.hi := by
          simp only [bandsChain, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at hrest; exact hrest.1.2
        omega
    · exact bandsChain_hi ys y.hi b hrest x hx

theorem bandOf_eq_some (bs : List NumBand) (x : Int) (band : NumBand) (hm : band ∈ bs)
    (hin : band.lo ≤ x ∧ x < band.hi) (huniq : ∀ b' ∈ bs, b'.lo ≤ x → x < b'.hi → b' = band) :
    bandOf bs x = some band.label := by
  induction bs with
  | nil => simp at hm
  | cons y ys ih =>
    by_cases hy : y.lo ≤ x ∧ x < y.hi
    · have : y = band := huniq y (by simp) hy.1 hy.2
      subst this; simp [bandOf, hy]
    · have hne : band ≠ y := fun e => hy (e ▸ hin)
      have hm' : band ∈ ys := by
        rcases List.mem_cons.1 hm with e | e
        · exact absurd e hne
        · exact e
      simp only [bandOf, hy, ite_false]
      exact ih hm' fun b' hb' => huniq b' (List.mem_cons_of_mem _ hb')

theorem bandsChain_unique : ∀ (bs : List NumBand) (a b : Int), bandsChain a bs b = true →
    ∀ x : Int, a ≤ x → x < b →
    ∃ band ∈ bs, (band.lo ≤ x ∧ x < band.hi) ∧
      ∀ b' ∈ bs, b'.lo ≤ x → x < b'.hi → b' = band
  | [], a, b, h, x, hax, hxb => by simp only [bandsChain, beq_iff_eq] at h; omega
  | y :: ys, a, b, h, x, hax, hxb => by
    have hrest : bandsChain y.hi ys b = true := by
      simp only [bandsChain, Bool.and_eq_true] at h; exact h.2
    simp only [bandsChain, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨hlo, hlt⟩, _⟩ := h
    by_cases hx : x < y.hi
    · refine ⟨y, by simp, ⟨by omega, hx⟩, fun b' hb' h1 h2 => ?_⟩
      rcases List.mem_cons.1 hb' with e | e
      · exact e
      · have := bandsChain_lo ys y.hi b hrest b' e
        omega
    · obtain ⟨band, hm, hin, hu⟩ := bandsChain_unique ys y.hi b hrest x (by omega) hxb
      refine ⟨band, List.mem_cons_of_mem _ hm, hin, fun b' hb' h1 h2 => ?_⟩
      rcases List.mem_cons.1 hb' with e | e
      · subst e; omega
      · exact hu b' e h1 h2

/-- If the bands tile `[a, b)`, every number in the range has exactly one band and `bandOf` returns it. -/
theorem tiles_unique_band {bs : List NumBand} {a b : Int} (h : tiles bs a b = true) {x : Int}
    (hax : a ≤ x) (hxb : x < b) :
    ∃ band ∈ bs, (band.lo ≤ x ∧ x < band.hi) ∧
      (∀ b' ∈ bs, b'.lo ≤ x → x < b'.hi → b' = band) ∧ bandOf bs x = some band.label := by
  have hc : bandsChain a bs b = true := by simp only [tiles, Bool.and_eq_true] at h; exact h.2
  obtain ⟨band, hm, hin, hu⟩ := bandsChain_unique bs a b hc x hax hxb
  exact ⟨band, hm, hin, hu, bandOf_eq_some bs x band hm hin hu⟩

theorem bandsChain_none : ∀ (bs : List NumBand) (a b : Int), bandsChain a bs b = true →
    ∀ x : Int, (x < a ∨ b ≤ x) → bandOf bs x = none
  | [], _, _, _, _, _ => rfl
  | y :: ys, a, b, h, x, hx => by
    have hhi := bandsChain_hi (y :: ys) a b h y (by simp)
    simp only [bandsChain, Bool.and_eq_true, beq_iff_eq, decide_eq_true_eq] at h
    obtain ⟨⟨hlo, hlt⟩, hrest⟩ := h
    have hn : ¬ (y.lo ≤ x ∧ x < y.hi) := by omega
    simp only [bandOf, hn, ite_false]
    exact bandsChain_none ys y.hi b hrest x (by omega)

/-- Outside the stated range there is no band: the lookup fails instead of guessing. -/
theorem tiles_bandOf_none {bs : List NumBand} {a b : Int} (h : tiles bs a b = true) {x : Int}
    (hx : x < a ∨ b ≤ x) : bandOf bs x = none := by
  simp only [tiles, Bool.and_eq_true] at h
  exact bandsChain_none bs a b h.2 x hx

end LexProof
