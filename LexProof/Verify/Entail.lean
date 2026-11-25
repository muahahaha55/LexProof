import LexProof.Verify.Conflict

/-!
# Entailment between acts («A kéo theo B»)

`Conflict` only compares two norms about the **same** act. Two norms about different acts can still be impossible
to satisfy together: an obligation to recall goods (Điều 32 khoản 4) and a prohibition on transporting them
(Điều 5 khoản 12) clash if recalling entails transporting. This is the usual definition in the literature
(compliance with one norm entails violating the other).

An `Edge` says «doing `src` entails doing `dst`». It is a **reading** of the law, not the text: a human reviews it,
and every derived norm carries the edge in its id («SUY RA [A ⇒ B] …») so a report shows which norms are not the
text. `derive` closes the norms under the edges:

* a prohibition on `dst` gives a prohibition on `src` (doing `src` would mean doing `dst`);
* an obligation on `src` gives an obligation on `dst` (doing `src` means doing `dst`).

Permissions are not propagated (a permission on `src` says nothing about `dst`); a permission on `src` still meets
a prohibition on `src` derived from one on `dst`.

What is proved here, for an arbitrary list of edges (the edges themselves are trusted data, like `Atoms.valid`):

* `derive_sound` — every derived norm comes from a norm of the input with the same modality, condition,
  exceptions and priority (so it applies exactly where its origin applies), and whoever respects the edges and
  complies with the origin also complies with the derived norm;
* `conflict_derived_meaning` — a `Conflict` between any norm and a derived one means: at that point the origin
  applies, and nobody who respects the edges can do what the first norm says (or allows) and also comply with the
  origin.

What is **not** proved: that the edges are true of the law. A wrong edge makes false conflicts; a missing edge hides
real ones. Only the reviewer stops either.
-/

namespace LexProof

/-- «Doing `src` entails doing `dst`», read from `source`. -/
structure Edge where
  src : Act
  dst : Act
  source : String
  reading : String
  deriving Repr, DecidableEq, Inhabited

def Edge.label (e : Edge) : String := e.src ++ " ⇒ " ++ e.dst

/-- One derivation step of one edge on one norm. -/
def Edge.step (e : Edge) (n : Norm) : Option Norm :=
  if n.modality = .prohibition ∧ n.act = e.dst then
    some { n with act := e.src, id := "SUY RA [" ++ e.label ++ "] " ++ n.id }
  else if n.modality = .obligation ∧ n.act = e.src then
    some { n with act := e.dst, id := "SUY RA [" ++ e.label ++ "] " ++ n.id }
  else none

/-- Every edge on every norm, once. -/
def stepAll (es : List Edge) (ns : List Norm) : List Norm :=
  ns.flatMap fun n => es.filterMap (·.step n)

/-- `k` rounds; each round derives from the norms the previous round derived. -/
def deriveRounds (es : List Edge) : Nat → List Norm → List Norm
  | 0, _ => []
  | k + 1, ns => stepAll es ns ++ deriveRounds es k (stepAll es ns)

/-- Norms derived from `ns` through chains of at most `es.length` edges (every path without a repeated edge). -/
def derive (es : List Edge) (ns : List Norm) : List Norm :=
  deriveRounds es es.length ns

/-! ## What a derived norm means -/

/-- What the addressee does in one situation: for each act, whether it is done. -/
abbrev Doing := Act → Bool

/-- A course of action that respects the edges: whenever `src` is done, `dst` is done. -/
def Respects (es : List Edge) (d : Doing) : Prop :=
  ∀ e ∈ es, d e.src = true → d e.dst = true

/-- Complying with a norm (where it applies): an obligation is done, a prohibition is not; a permission asks nothing. -/
def Complies (n : Norm) (d : Doing) : Prop :=
  match n.modality with
  | .obligation => d n.act = true
  | .prohibition => d n.act = false
  | .permission => True

/-- Doing what the norm says or allows: for a permission, using it. -/
def Acts (n : Norm) (d : Doing) : Prop :=
  match n.modality with
  | .obligation => d n.act = true
  | .prohibition => d n.act = false
  | .permission => d n.act = true

/-- The fields that decide where a norm applies, and how it is resolved, are those of its origin. -/
def SameScope (m n : Norm) : Prop :=
  m.modality = n.modality ∧ m.condition = n.condition ∧ m.exceptions = n.exceptions ∧ m.priority = n.priority

theorem applies_of_sameScope {S P : Type} {m n : Norm} (h : SameScope m n) (A : Atoms S P) (π : P) (s : S) :
    m.applies A π s = n.applies A π s := by
  obtain ⟨_, hc, he, _⟩ := h
  simp [Norm.applies, hc, he]

theorem step_sound {e : Edge} {n m : Norm} (h : e.step n = some m) :
    SameScope m n ∧ (m.modality = .prohibition ∨ m.modality = .obligation) ∧
      ∀ d : Doing, (d e.src = true → d e.dst = true) → Complies n d → Complies m d := by
  unfold Edge.step at h
  split at h
  · rename_i hp
    obtain ⟨hmod, hact⟩ := hp
    cases h
    refine ⟨⟨rfl, rfl, rfl, rfl⟩, Or.inl hmod, ?_⟩
    intro d hed hc
    simp only [Complies, hmod] at hc ⊢
    rw [hact] at hc
    cases hs : d e.src
    · rfl
    · rw [hed hs] at hc; exact absurd hc (by decide)
  · split at h
    · rename_i _ hp
      obtain ⟨hmod, hact⟩ := hp
      cases h
      refine ⟨⟨rfl, rfl, rfl, rfl⟩, Or.inr hmod, ?_⟩
      intro d hed hc
      simp only [Complies, hmod] at hc ⊢
      rw [hact] at hc
      exact hed hc
    · cases h

/-- The invariant of a derived norm, relative to an origin in the input. -/
def DerivedFrom (es : List Edge) (ns : List Norm) (m : Norm) : Prop :=
  ∃ n ∈ ns, SameScope m n ∧ (m.modality = .prohibition ∨ m.modality = .obligation) ∧
    ∀ d : Doing, Respects es d → Complies n d → Complies m d

theorem stepAll_sound {es : List Edge} {ns : List Norm} {m : Norm} (h : m ∈ stepAll es ns) :
    ∃ n ∈ ns, SameScope m n ∧ (m.modality = .prohibition ∨ m.modality = .obligation) ∧
      ∀ d : Doing, Respects es d → Complies n d → Complies m d := by
  simp only [stepAll, List.mem_flatMap, List.mem_filterMap] at h
  obtain ⟨n, hn, e, he, hs⟩ := h
  obtain ⟨hsc, hmod, hc⟩ := step_sound hs
  exact ⟨n, hn, hsc, hmod, fun d hr => hc d (hr e he)⟩

theorem sameScope_trans {a b c : Norm} (h₁ : SameScope a b) (h₂ : SameScope b c) : SameScope a c := by
  obtain ⟨h1, h2, h3, h4⟩ := h₁
  obtain ⟨g1, g2, g3, g4⟩ := h₂
  exact ⟨h1.trans g1, h2.trans g2, h3.trans g3, h4.trans g4⟩

theorem deriveRounds_sound {es : List Edge} :
    ∀ (k : Nat) (ns : List Norm) (m : Norm), m ∈ deriveRounds es k ns → DerivedFrom es ns m
  | 0, _, _, h => by simp [deriveRounds] at h
  | k + 1, ns, m, h => by
    simp only [deriveRounds, List.mem_append] at h
    rcases h with h | h
    · exact stepAll_sound h
    · obtain ⟨b, hb, hsc, hmod, hc⟩ := deriveRounds_sound k (stepAll es ns) m h
      obtain ⟨n, hn, hsc', _, hc'⟩ := stepAll_sound hb
      exact ⟨n, hn, sameScope_trans hsc hsc', hmod, fun d hr hcn => hc d hr (hc' d hr hcn)⟩

/-- Every derived norm comes from a norm of the input: same scope, and complying with the origin under the edges
means complying with the derived norm. -/
theorem derive_sound {es : List Edge} {ns : List Norm} {m : Norm} (h : m ∈ derive es ns) :
    DerivedFrom es ns m :=
  deriveRounds_sound _ _ _ h

/-- For a prohibition or an obligation, doing what it says is complying with it. -/
theorem acts_iff_complies {n : Norm} (h : n.modality = .prohibition ∨ n.modality = .obligation) (d : Doing) :
    Acts n d ↔ Complies n d := by
  rcases h with h | h <;> simp [Acts, Complies, h]

/-- Two norms about one act with incompatible modalities cannot both be acted on. -/
theorem not_acts_both {n₁ n₂ : Norm} (hact : n₁.act = n₂.act)
    (hinc : Incompatible n₁.modality n₂.modality = true) (d : Doing) : ¬ (Acts n₁ d ∧ Acts n₂ d) := by
  intro ⟨h₁, h₂⟩
  unfold Acts at h₁ h₂
  rw [hact] at h₁
  cases hm₁ : n₁.modality <;> cases hm₂ : n₂.modality <;> simp [hm₁, hm₂, Incompatible] at hinc h₁ h₂ <;>
    simp_all

/-- **What a conflict with a derived norm means.** If `n₁` conflicts at `(π, s)` with a norm derived through the
edges, then some norm `n` of the input applies at `(π, s)`, and whoever respects the edges cannot both do what `n₁`
says (or use what it allows) and comply with `n`. With the edges trusted, this is a conflict between `n₁` and `n`,
which may be about different acts. -/
theorem conflict_derived_meaning {S P : Type} {A : Atoms S P} {es : List Edge} {ns : List Norm}
    {n₁ m : Norm} {π : P} {s : S} (hc : Conflict A n₁ m π s) (hm : m ∈ derive es ns) :
    ∃ n ∈ ns, n.applies A π s = some true ∧ ∀ d : Doing, Respects es d → Acts n₁ d → ¬ Complies n d := by
  obtain ⟨n, hn, hsc, hmod, himp⟩ := derive_sound hm
  obtain ⟨hact, _, h₂, hinc, _⟩ := hc
  refine ⟨n, hn, (applies_of_sameScope hsc A π s).symm.trans h₂, ?_⟩
  intro d hr ha hcn
  exact not_acts_both hact hinc d ⟨ha, (acts_iff_complies hmod d).mpr (himp d hr hcn)⟩

end LexProof
