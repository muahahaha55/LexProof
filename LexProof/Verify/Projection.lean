import LexProof.Verify.Conflict

/-!
# Projection experiment (A1): locality and a sound projected search

**Experiment only.** Nothing here is used by `check`, `analyze`, `Result` or
`Scope`, and no existing declaration is changed. It tests the claim behind
design (a) in `docs/scaling-analysis.md`: whether `Conflict` for a pair of
norms depends only on the atoms the pair reads, and whether a search over
valuations of exactly those atoms is sound.

* (L) `Cond.eval_congr`, `Norm.applies_congr`, `conflict_congr` — two points
  that agree on every atom a pair reads are indistinguishable to `Conflict`.
* (S) `not_conflict_of_projConsistent` — if no valuation of the pair's atoms
  yields a conflict, there is no `Conflict` at any `(π, s)`. `projConsistent`
  does not mention `valid` and does not mention `Atoms` at all.

**What (S) does not give.** It is one-directional: a conflicting valuation is
only a *candidate*. To report a real conflict one would still need a concrete
`(π, s)` realising it with `A.valid π s = true`, and `Conflict` checked there
by the kernel (that is `conflict_of_witness`). Building such a `s` from atom
values is possible only if `S` is a product of independent fields; if atoms are
arbitrary functions of `S` there is no general construction. Also: (S) assumes
both norms are well-formed (`Norm.wf`), which the validator provides, and it
says nothing about the cost of evaluating `projConsistent` beyond that it is
`2^(atoms read by the pair)` valuations.
-/

namespace LexProof

/-! ## Reading atoms -/

variable {S P : Type}

/-- Value of situation reader `i` at `s`; `none` if `i` is out of range. -/
def Atoms.sitVal (A : Atoms S P) (s : S) (i : Nat) : Option Bool :=
  (A.sit[i]?).map fun f => f.2 s

/-- Value of parameter reader `i` at `π`; `none` if `i` is out of range. -/
def Atoms.parVal (A : Atoms S P) (π : P) (i : Nat) : Option Bool :=
  (A.param[i]?).map fun f => f.2 π

namespace Cond

/-- Indices of the situation fields a condition reads. (`paramIdxs` already
exists for parameters.) -/
def sitIdxs : Cond → List Nat
  | .tt | .ff | .param _ => []
  | .sit i => [i]
  | .not c => c.sitIdxs
  | .and a b => a.sitIdxs ++ b.sitIdxs
  | .or a b => a.sitIdxs ++ b.sitIdxs

/-- `eval` with the atom readers abstracted to two environments. -/
def evalE (e g : Nat → Option Bool) : Cond → Option Bool
  | .tt => some true
  | .ff => some false
  | .sit i => e i
  | .param i => g i
  | .not c => (c.evalE e g).map (!·)
  | .and a b =>
    match a.evalE e g, b.evalE e g with
    | some x, some y => some (x && y)
    | _, _ => none
  | .or a b =>
    match a.evalE e g, b.evalE e g with
    | some x, some y => some (x || y)
    | _, _ => none

/-- `evalAny` with abstracted environments. -/
def evalAnyE (e g : Nat → Option Bool) : List Cond → Option Bool
  | [] => some false
  | c :: cs =>
    match c.evalE e g, evalAnyE e g cs with
    | some x, some y => some (x || y)
    | _, _ => none

theorem eval_eq_evalE (A : Atoms S P) (π : P) (s : S) (c : Cond) :
    c.eval A π s = c.evalE (A.sitVal s) (A.parVal π) := by
  induction c with
  | tt => rfl
  | ff => rfl
  | sit i => rfl
  | param i => rfl
  | not c ih => simp only [eval, evalE, ih]
  | and a b iha ihb => simp only [eval, evalE, iha, ihb]; rfl
  | or a b iha ihb => simp only [eval, evalE, iha, ihb]; rfl

theorem evalAny_eq_evalAnyE (A : Atoms S P) (π : P) (s : S) (cs : List Cond) :
    evalAny A π s cs = evalAnyE (A.sitVal s) (A.parVal π) cs := by
  induction cs with
  | nil => rfl
  | cons c cs ih => simp only [evalAny, evalAnyE, eval_eq_evalE, ih]; rfl

/-- (L) for conditions: `evalE` depends only on the environments at the indices
the condition reads. -/
theorem evalE_congr {e e' g g' : Nat → Option Bool} (c : Cond)
    (he : ∀ i ∈ c.sitIdxs, e i = e' i) (hg : ∀ i ∈ c.paramIdxs, g i = g' i) :
    c.evalE e g = c.evalE e' g' := by
  induction c with
  | tt => rfl
  | ff => rfl
  | sit i => exact he i (by simp [sitIdxs])
  | param i => exact hg i (by simp [paramIdxs])
  | not c ih =>
    have := ih (by simpa [sitIdxs] using he) (by simpa [paramIdxs] using hg)
    simp only [evalE, this]
  | and a b iha ihb =>
    have h1 := iha (fun i hi => he i (by simp [sitIdxs, hi]))
      (fun i hi => hg i (by simp [paramIdxs, hi]))
    have h2 := ihb (fun i hi => he i (by simp [sitIdxs, hi]))
      (fun i hi => hg i (by simp [paramIdxs, hi]))
    simp only [evalE, h1, h2]
  | or a b iha ihb =>
    have h1 := iha (fun i hi => he i (by simp [sitIdxs, hi]))
      (fun i hi => hg i (by simp [paramIdxs, hi]))
    have h2 := ihb (fun i hi => he i (by simp [sitIdxs, hi]))
      (fun i hi => hg i (by simp [paramIdxs, hi]))
    simp only [evalE, h1, h2]

theorem evalAnyE_congr {e e' g g' : Nat → Option Bool} (cs : List Cond)
    (he : ∀ i ∈ cs.flatMap sitIdxs, e i = e' i)
    (hg : ∀ i ∈ cs.flatMap paramIdxs, g i = g' i) :
    evalAnyE e g cs = evalAnyE e' g' cs := by
  induction cs with
  | nil => rfl
  | cons c cs ih =>
    have h1 := evalE_congr c (fun i hi => he i (List.mem_flatMap.2 ⟨c, by simp, hi⟩))
      (fun i hi => hg i (List.mem_flatMap.2 ⟨c, by simp, hi⟩))
    have h2 := ih
      (fun i hi => by
        obtain ⟨d, hd, hid⟩ := List.mem_flatMap.1 hi
        exact he i (List.mem_flatMap.2 ⟨d, by simp [hd], hid⟩))
      (fun i hi => by
        obtain ⟨d, hd, hid⟩ := List.mem_flatMap.1 hi
        exact hg i (List.mem_flatMap.2 ⟨d, by simp [hd], hid⟩))
    simp only [evalAnyE, h1, h2]

/-- (L) for `Cond.eval`: two points that give the same reader values at every
atom the condition reads give the same result. -/
theorem eval_congr (A : Atoms S P) {π π' : P} {s s' : S} (c : Cond)
    (hs : ∀ i ∈ c.sitIdxs, A.sitVal s i = A.sitVal s' i)
    (hp : ∀ i ∈ c.paramIdxs, A.parVal π i = A.parVal π' i) :
    c.eval A π s = c.eval A π' s' := by
  rw [eval_eq_evalE, eval_eq_evalE]
  exact evalE_congr c hs hp

/-- Every situation index a well-formed condition reads is in range. -/
theorem sitIdxs_lt_of_wf (c : Cond) {nsit nparam : Nat}
    (h : c.wf nsit nparam = true) : ∀ i ∈ c.sitIdxs, i < nsit := by
  induction c with
  | tt => simp [sitIdxs]
  | ff => simp [sitIdxs]
  | param i => simp [sitIdxs]
  | sit i =>
    simp only [wf, decide_eq_true_eq] at h
    simpa [sitIdxs] using h
  | not c ih => exact ih h
  | and a b iha ihb =>
    simp only [wf, Bool.and_eq_true] at h
    intro i hi
    simp only [sitIdxs, List.mem_append] at hi
    rcases hi with hi | hi
    · exact iha h.1 i hi
    · exact ihb h.2 i hi
  | or a b iha ihb =>
    simp only [wf, Bool.and_eq_true] at h
    intro i hi
    simp only [sitIdxs, List.mem_append] at hi
    rcases hi with hi | hi
    · exact iha h.1 i hi
    · exact ihb h.2 i hi

/-- Every parameter index a well-formed condition reads is in range. -/
theorem paramIdxs_lt_of_wf (c : Cond) {nsit nparam : Nat}
    (h : c.wf nsit nparam = true) : ∀ i ∈ c.paramIdxs, i < nparam := by
  induction c with
  | tt => simp [paramIdxs]
  | ff => simp [paramIdxs]
  | sit i => simp [paramIdxs]
  | param i =>
    simp only [wf, decide_eq_true_eq] at h
    simpa [paramIdxs] using h
  | not c ih => exact ih h
  | and a b iha ihb =>
    simp only [wf, Bool.and_eq_true] at h
    intro i hi
    simp only [paramIdxs, List.mem_append] at hi
    rcases hi with hi | hi
    · exact iha h.1 i hi
    · exact ihb h.2 i hi
  | or a b iha ihb =>
    simp only [wf, Bool.and_eq_true] at h
    intro i hi
    simp only [paramIdxs, List.mem_append] at hi
    rcases hi with hi | hi
    · exact iha h.1 i hi
    · exact ihb h.2 i hi

end Cond

/-! ## Norms and conflicts -/

namespace Norm

/-- Situation indices mentioned anywhere in the norm (condition and
exceptions). Mirrors `Norm.paramIdxs`. -/
def sitIdxs (n : Norm) : List Nat :=
  n.condition.sitIdxs ++ n.exceptions.flatMap Cond.sitIdxs

/-- `applies` with abstracted environments. -/
def appliesE (n : Norm) (e g : Nat → Option Bool) : Option Bool :=
  match n.condition.evalE e g, Cond.evalAnyE e g n.exceptions with
  | some c, some x => some (c && !x)
  | _, _ => none

theorem applies_eq_appliesE (A : Atoms S P) (n : Norm) (π : P) (s : S) :
    n.applies A π s = n.appliesE (A.sitVal s) (A.parVal π) := by
  simp only [applies, appliesE, Cond.eval_eq_evalE, Cond.evalAny_eq_evalAnyE]; rfl

theorem appliesE_congr {e e' g g' : Nat → Option Bool} (n : Norm)
    (he : ∀ i ∈ n.sitIdxs, e i = e' i) (hg : ∀ i ∈ n.paramIdxs, g i = g' i) :
    n.appliesE e g = n.appliesE e' g' := by
  have h1 := Cond.evalE_congr n.condition
    (fun i hi => he i (List.mem_append.2 (Or.inl hi)))
    (fun i hi => hg i (List.mem_append.2 (Or.inl hi)))
  have h2 := Cond.evalAnyE_congr n.exceptions
    (fun i hi => he i (List.mem_append.2 (Or.inr hi)))
    (fun i hi => hg i (List.mem_append.2 (Or.inr hi)))
  simp only [appliesE, h1, h2]

/-- (L) for norms: `applies` (condition and exceptions) is invariant under a
change of point that keeps every atom the norm reads. -/
theorem applies_congr (A : Atoms S P) {π π' : P} {s s' : S} (n : Norm)
    (hs : ∀ i ∈ n.sitIdxs, A.sitVal s i = A.sitVal s' i)
    (hp : ∀ i ∈ n.paramIdxs, A.parVal π i = A.parVal π' i) :
    n.applies A π s = n.applies A π' s' := by
  rw [applies_eq_appliesE, applies_eq_appliesE]
  exact appliesE_congr n hs hp

theorem sitIdxs_lt_of_wf (A : Atoms S P) (n : Norm) (h : n.wf A = true) :
    ∀ i ∈ n.sitIdxs, i < A.sit.length := by
  simp only [wf, Bool.and_eq_true] at h
  intro i hi
  rcases List.mem_append.1 hi with hi | hi
  · exact Cond.sitIdxs_lt_of_wf _ h.1 i hi
  · obtain ⟨c, hc, hic⟩ := List.mem_flatMap.1 hi
    exact Cond.sitIdxs_lt_of_wf c ((List.all_eq_true.1 h.2) c hc) i hic

theorem paramIdxs_lt_of_wf (A : Atoms S P) (n : Norm) (h : n.wf A = true) :
    ∀ i ∈ n.paramIdxs, i < A.param.length := by
  simp only [wf, Bool.and_eq_true] at h
  intro i hi
  rcases List.mem_append.1 hi with hi | hi
  · exact Cond.paramIdxs_lt_of_wf _ h.1 i hi
  · obtain ⟨c, hc, hic⟩ := List.mem_flatMap.1 hi
    exact Cond.paramIdxs_lt_of_wf c ((List.all_eq_true.1 h.2) c hc) i hic

end Norm

/-- (L) for conflicts: if two points agree on every atom either norm reads,
`Conflict` holds at one iff it holds at the other. -/
theorem conflict_congr (A : Atoms S P) {π π' : P} {s s' : S} (n₁ n₂ : Norm)
    (hs₁ : ∀ i ∈ n₁.sitIdxs, A.sitVal s i = A.sitVal s' i)
    (hp₁ : ∀ i ∈ n₁.paramIdxs, A.parVal π i = A.parVal π' i)
    (hs₂ : ∀ i ∈ n₂.sitIdxs, A.sitVal s i = A.sitVal s' i)
    (hp₂ : ∀ i ∈ n₂.paramIdxs, A.parVal π i = A.parVal π' i) :
    Conflict A n₁ n₂ π s ↔ Conflict A n₁ n₂ π' s' := by
  simp only [Conflict, Norm.applies_congr A n₁ hs₁ hp₁, Norm.applies_congr A n₂ hs₂ hp₂]

/-! ## Valuations and the projected search -/

/-- Value recorded for index `i` in an assignment list; first entry wins. -/
def look : List (Nat × Bool) → Nat → Option Bool
  | [], _ => none
  | (k, v) :: t, i => if k = i then some v else look t i

/-- Every assignment of `Bool`s to the given indices (`2 ^ length` of them). -/
def assigns : List Nat → List (List (Nat × Bool))
  | [] => [[]]
  | i :: is => (assigns is).flatMap fun a => [(i, true) :: a, (i, false) :: a]

/-- The enumeration is complete: any Boolean function on the indices is
realised by some listed assignment. -/
theorem assigns_complete (is : List Nat) (f : Nat → Bool) :
    ∃ a ∈ assigns is, ∀ i ∈ is, look a i = some (f i) := by
  induction is with
  | nil => exact ⟨[], by simp [assigns], by simp⟩
  | cons i is ih =>
    obtain ⟨a, ha, hl⟩ := ih
    refine ⟨(i, f i) :: a, ?_, ?_⟩
    · simp only [assigns, List.mem_flatMap]
      refine ⟨a, ha, ?_⟩
      cases h : f i <;> simp
    · intro j hj
      by_cases hij : i = j
      · subst hij; simp [look]
      · have hj' : j ∈ is := by
          rcases List.mem_cons.1 hj with h | h
          · exact absurd h.symm hij
          · exact h
        simp [look, hij, hl j hj']

/-- Remove duplicate indices so a shared atom is enumerated once. -/
def dedupNat : List Nat → List Nat
  | [] => []
  | x :: xs => if x ∈ xs then dedupNat xs else x :: dedupNat xs

theorem mem_dedupNat (l : List Nat) (i : Nat) : i ∈ dedupNat l ↔ i ∈ l := by
  induction l with
  | nil => simp [dedupNat]
  | cons x xs ih =>
    by_cases h : x ∈ xs
    · simp only [dedupNat, h, ite_true, ih, List.mem_cons]
      constructor
      · exact Or.inr
      · rintro (rfl | hi)
        · exact h
        · exact hi
    · simp [dedupNat, h, ih]

/-- Situation atoms read by the pair (each once). -/
def pairSitIdxs (n₁ n₂ : Norm) : List Nat := dedupNat (n₁.sitIdxs ++ n₂.sitIdxs)

/-- Parameter atoms read by the pair (each once). -/
def pairParamIdxs (n₁ n₂ : Norm) : List Nat := dedupNat (n₁.paramIdxs ++ n₂.paramIdxs)

/-- All valuations of the atoms the pair reads. -/
def vals (n₁ n₂ : Norm) : List (List (Nat × Bool) × List (Nat × Bool)) :=
  (assigns (pairSitIdxs n₁ n₂)).flatMap fun a =>
    (assigns (pairParamIdxs n₁ n₂)).map fun b => (a, b)

/-- Does the pair clash under this valuation? Same five clauses as `Conflict`,
with the atoms read from the valuation instead of from `(π, s)`. Mentions
neither `Atoms` nor `valid`. -/
def projConflict (n₁ n₂ : Norm) (a b : List (Nat × Bool)) : Bool :=
  decide (n₁.act = n₂.act) &&
  decide (n₁.appliesE (look a) (look b) = some true) &&
  decide (n₂.appliesE (look a) (look b) = some true) &&
  Incompatible n₁.modality n₂.modality &&
  !(Norm.resolved n₁ n₂)

/-- No valuation of the pair's atoms yields a clash. -/
def projConsistent (n₁ n₂ : Norm) : Bool :=
  (vals n₁ n₂).all fun v => !projConflict n₁ n₂ v.1 v.2

private theorem look_eq_sitVal {A : Atoms S P} {s : S} {a : List (Nat × Bool)}
    {i : Nat} (hi : i < A.sit.length)
    (h : look a i = some ((A.sitVal s i).getD false)) : look a i = A.sitVal s i := by
  have : (A.sitVal s i).isSome = true := by
    simp [Atoms.sitVal, List.getElem?_eq_getElem hi]
  obtain ⟨x, hx⟩ := Option.isSome_iff_exists.1 this
  rw [hx] at h ⊢
  simpa using h

private theorem look_eq_parVal {A : Atoms S P} {π : P} {b : List (Nat × Bool)}
    {i : Nat} (hi : i < A.param.length)
    (h : look b i = some ((A.parVal π i).getD false)) : look b i = A.parVal π i := by
  have : (A.parVal π i).isSome = true := by
    simp [Atoms.parVal, List.getElem?_eq_getElem hi]
  obtain ⟨x, hx⟩ := Option.isSome_iff_exists.1 this
  rw [hx] at h ⊢
  simpa using h

/-- (S) Soundness of the projected search. If no valuation of the atoms the
pair reads yields a clash, then there is no `Conflict` at any `(π, s)` — valid
or not. Needs both norms well-formed, which a clean validator run gives. -/
theorem not_conflict_of_projConsistent (A : Atoms S P) (n₁ n₂ : Norm)
    (w₁ : n₁.wf A = true) (w₂ : n₂.wf A = true)
    (h : projConsistent n₁ n₂ = true) (π : P) (s : S) :
    ¬ Conflict A n₁ n₂ π s := by
  intro hc
  obtain ⟨hact, h1, h2, hinc, hres⟩ := hc
  obtain ⟨a, ha, hla⟩ :=
    assigns_complete (pairSitIdxs n₁ n₂) fun i => (A.sitVal s i).getD false
  obtain ⟨b, hb, hlb⟩ :=
    assigns_complete (pairParamIdxs n₁ n₂) fun i => (A.parVal π i).getD false
  have hs : ∀ n : Norm, n.wf A = true → (∀ i ∈ n.sitIdxs, i ∈ pairSitIdxs n₁ n₂) →
      ∀ i ∈ n.sitIdxs, look a i = A.sitVal s i := fun n w hsub i hi =>
    look_eq_sitVal (Norm.sitIdxs_lt_of_wf A n w i hi) (hla i (hsub i hi))
  have hp : ∀ n : Norm, n.wf A = true → (∀ i ∈ n.paramIdxs, i ∈ pairParamIdxs n₁ n₂) →
      ∀ i ∈ n.paramIdxs, look b i = A.parVal π i := fun n w hsub i hi =>
    look_eq_parVal (Norm.paramIdxs_lt_of_wf A n w i hi) (hlb i (hsub i hi))
  have sub₁s : ∀ i ∈ n₁.sitIdxs, i ∈ pairSitIdxs n₁ n₂ := fun i hi =>
    (mem_dedupNat _ _).2 (List.mem_append.2 (Or.inl hi))
  have sub₂s : ∀ i ∈ n₂.sitIdxs, i ∈ pairSitIdxs n₁ n₂ := fun i hi =>
    (mem_dedupNat _ _).2 (List.mem_append.2 (Or.inr hi))
  have sub₁p : ∀ i ∈ n₁.paramIdxs, i ∈ pairParamIdxs n₁ n₂ := fun i hi =>
    (mem_dedupNat _ _).2 (List.mem_append.2 (Or.inl hi))
  have sub₂p : ∀ i ∈ n₂.paramIdxs, i ∈ pairParamIdxs n₁ n₂ := fun i hi =>
    (mem_dedupNat _ _).2 (List.mem_append.2 (Or.inr hi))
  have e₁ : n₁.appliesE (look a) (look b) = n₁.applies A π s := by
    rw [Norm.applies_eq_appliesE]
    exact Norm.appliesE_congr n₁ (hs n₁ w₁ sub₁s) (hp n₁ w₁ sub₁p)
  have e₂ : n₂.appliesE (look a) (look b) = n₂.applies A π s := by
    rw [Norm.applies_eq_appliesE]
    exact Norm.appliesE_congr n₂ (hs n₂ w₂ sub₂s) (hp n₂ w₂ sub₂p)
  have hv : (a, b) ∈ vals n₁ n₂ :=
    List.mem_flatMap.2 ⟨a, ha, List.mem_map.2 ⟨b, hb, rfl⟩⟩
  have hpc : projConflict n₁ n₂ a b = true := by
    simp [projConflict, e₁, e₂, h1, h2, hact, hinc, hres]
  have hall := (List.all_eq_true.1 h) (a, b) hv
  simp [hpc] at hall

/-! ## Non-vacuity

`projConsistent` computes, and says both things: no clash when the conditions
are disjoint, a clash when they can hold together. -/

private def demoNorm (m : Modality) (c : Cond) : Norm :=
  { (default : Norm) with modality := m, act := "x", condition := c }

example : projConsistent (demoNorm .prohibition (.sit 0))
    (demoNorm .obligation (.not (.sit 0))) = true := by decide

example : projConsistent (demoNorm .prohibition (.sit 0))
    (demoNorm .obligation (.sit 1)) = false := by decide

end LexProof
