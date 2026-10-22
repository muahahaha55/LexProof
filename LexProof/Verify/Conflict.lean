import LexProof.Verify.Validate

/-!
# Level 1 conflict checking

`Conflict` is the `Prop` saying two norms clash at one situation and one
assignment of the open-textured parameters. `check` is a `Bool`-level search
over the valid part of the finite domain.

What ties the two together is at the end of the file:

* `conflict_of_witness` (a) — a reported conflict is a real one;
* `counterexample_fields_correct` (c) — every reported field matches the norms;
* `not_conflict_of_consistentOn` (b) — `consistentOn` rules out conflicts;
* `scopeOf_spec`, `check_scope` (d) — the scope says exactly what was checked;
* `conflict_all_params`, `conditionalConflict_split` (e) — the two labels mean
  what they say;
* theorem (f) lives in `Validate.lean` plus `Norm.applies_isSome_of_wf`, and is
  assembled here as `applies_isSome_of_validate_nil`.

Pairs are compared **once**, unordered, and only when the acts match. Only
`valid` situation/parameter pairs are searched.
-/

namespace LexProof

variable {S P : Type}

/-! ## The conflict relation -/

/-- Two norms conflict at `(π, s)` when they are about the same act, both
apply, their modalities clash, and no explicit priority resolves them. -/
def Conflict (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) : Prop :=
  n₁.act = n₂.act ∧
  n₁.applies A π s = some true ∧
  n₂.applies A π s = some true ∧
  Incompatible n₁.modality n₂.modality = true ∧
  Norm.resolved n₁ n₂ = false

/-- Conflict does not depend on the order of the two norms. This is what makes
it sound to compare each unordered pair only once. -/
theorem Conflict_comm {A : Atoms S P} {n₁ n₂ : Norm} {π : P} {s : S}
    (h : Conflict A n₁ n₂ π s) : Conflict A n₂ n₁ π s := by
  obtain ⟨hact, h1, h2, hinc, hres⟩ := h
  refine ⟨hact.symm, h2, h1, ?_, ?_⟩
  · rw [Incompatible_comm]; exact hinc
  · rw [Norm.resolved_comm]; exact hres

/-- A norm never conflicts with itself, because no modality clashes with
itself. -/
theorem not_conflict_self (A : Atoms S P) (n : Norm) (π : P) (s : S) :
    ¬ Conflict A n n π s := by
  intro h
  have hi := h.2.2.2.1
  rw [Incompatible_irrefl] at hi
  simp at hi

/-- Three-valued test: `some true` conflict, `some false` no conflict,
`none` unknown (a malformed condition). -/
def conflictsAt (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) : Option Bool :=
  match n₁.applies A π s, n₂.applies A π s with
  | some a₁, some a₂ =>
    some ((n₁.act == n₂.act) && a₁ && a₂ &&
          Incompatible n₁.modality n₂.modality && !Norm.resolved n₁ n₂)
  | _, _ => none

/-- `true` only on a definite conflict. Unknown is not a conflict. -/
def isConflictAt (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) : Bool :=
  (conflictsAt A n₁ n₂ π s).getD false

/-- `true` when the encoding could not be evaluated at all. After a clean
validator run this is unreachable (theorem (f)); it stays as a fail-closed
guard. -/
def isUnknownAt (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) : Bool :=
  (conflictsAt A n₁ n₂ π s).isNone

/-- The atom of the checker agrees exactly with the `Prop`. -/
theorem isConflictAt_eq_true_iff (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) :
    isConflictAt A n₁ n₂ π s = true ↔ Conflict A n₁ n₂ π s := by
  simp only [isConflictAt, conflictsAt, Conflict]
  cases h₁ : n₁.applies A π s with
  | none => simp
  | some a₁ =>
    cases h₂ : n₂.applies A π s with
    | none => simp
    | some a₂ => cases a₁ <;> cases a₂ <;> simp [and_assoc]

/-! ## Unordered pairs -/

/-- Each unordered pair of distinct list positions, once. No self-pairs. -/
def pairsOf : List Norm → List (Norm × Norm)
  | [] => []
  | n :: rest => rest.map (fun m => (n, m)) ++ pairsOf rest

theorem pairsOf_subset : ∀ {ns : List Norm} {p : Norm × Norm},
    p ∈ pairsOf ns → p.1 ∈ ns ∧ p.2 ∈ ns := by
  intro ns
  induction ns with
  | nil => intro p hp; simp [pairsOf] at hp
  | cons n rest ih =>
    intro p hp
    simp only [pairsOf] at hp
    rcases List.mem_append.mp hp with hl | hr
    · rcases List.mem_map.mp hl with ⟨m, hm, heq⟩
      subst heq
      exact ⟨by simp, List.mem_cons_of_mem _ hm⟩
    · have hx := ih hr
      exact ⟨List.mem_cons_of_mem _ hx.1, List.mem_cons_of_mem _ hx.2⟩

/-- Two distinct norms of the list occur as a pair, in one order or the other.
Together with `Conflict_comm` this is why comparing each pair once loses
nothing. -/
theorem mem_pairsOf : ∀ {ns : List Norm} {n₁ n₂ : Norm},
    n₁ ∈ ns → n₂ ∈ ns → n₁ ≠ n₂ →
    (n₁, n₂) ∈ pairsOf ns ∨ (n₂, n₁) ∈ pairsOf ns := by
  intro ns
  induction ns with
  | nil => intro n₁ n₂ h₁ _ _; simp at h₁
  | cons n rest ih =>
    intro n₁ n₂ h₁ h₂ hne
    simp only [pairsOf]
    rcases List.mem_cons.mp h₁ with he₁ | hr₁
    · rcases List.mem_cons.mp h₂ with he₂ | hr₂
      · exact absurd (he₁.trans he₂.symm) hne
      · exact Or.inl (List.mem_append.mpr (Or.inl
          (List.mem_map.mpr ⟨n₂, hr₂, by rw [he₁]⟩)))
    · rcases List.mem_cons.mp h₂ with he₂ | hr₂
      · exact Or.inr (List.mem_append.mpr (Or.inl
          (List.mem_map.mpr ⟨n₁, hr₁, by rw [he₂]⟩)))
      · rcases ih hr₁ hr₂ hne with hl | hr
        · exact Or.inl (List.mem_append.mpr (Or.inr hl))
        · exact Or.inr (List.mem_append.mpr (Or.inr hr))

/-! ## The search space -/

/-- One point of the search space. -/
structure Cand (S P : Type) where
  left : Norm
  right : Norm
  params : P
  situation : S

/-- Every unordered pair with matching acts, at every **valid** parameter
assignment and situation. -/
def cands [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : List (Cand S P) :=
  ((pairsOf ns).flatMap fun p =>
    (Finite.enum (α := P)).flatMap fun π =>
      (Finite.enum (α := S)).map fun s => (⟨p.1, p.2, π, s⟩ : Cand S P)).filter
    fun k => (k.left.act == k.right.act) && A.valid k.params k.situation

theorem mem_cands [Finite S] [Finite P] {A : Atoms S P} {ns : List Norm}
    {n₁ n₂ : Norm} {π : P} {s : S}
    (hp : (n₁, n₂) ∈ pairsOf ns) (hact : n₁.act = n₂.act)
    (hv : A.valid π s = true) :
    (⟨n₁, n₂, π, s⟩ : Cand S P) ∈ cands A ns := by
  refine List.mem_filter.mpr ⟨?_, ?_⟩
  · refine List.mem_flatMap.mpr ⟨(n₁, n₂), hp, ?_⟩
    refine List.mem_flatMap.mpr ⟨π, Finite.complete π, ?_⟩
    exact List.mem_map.mpr ⟨s, Finite.complete s, rfl⟩
  · simp [hact, hv]

theorem mem_of_mem_cands [Finite S] [Finite P] {A : Atoms S P} {ns : List Norm}
    {k : Cand S P} (h : k ∈ cands A ns) :
    k.left ∈ ns ∧ k.right ∈ ns ∧ k.left.act = k.right.act ∧
      A.valid k.params k.situation = true := by
  rcases List.mem_filter.mp h with ⟨hmem, hpred⟩
  rcases List.mem_flatMap.mp hmem with ⟨p, hp, hmem⟩
  rcases List.mem_flatMap.mp hmem with ⟨_, _, hmem⟩
  rcases List.mem_map.mp hmem with ⟨_, _, heq⟩
  subst heq
  have hsub := pairsOf_subset hp
  simp only [Bool.and_eq_true, beq_iff_eq] at hpred
  exact ⟨hsub.1, hsub.2, hpred.1, hpred.2⟩

/-! ## Reported results -/

/-- A conflict witness, as printable data for human review. -/
structure Counterexample (S P : Type) where
  situation : S
  params : P
  left : NormId
  right : NormId
  modalities : Modality × Modality
  sources : SourceId × SourceId
  deriving Repr, DecidableEq

/-- Which norm prevailed over which, when explicit priority settled a clash. -/
structure Resolution where
  winner : NormId
  loser : NormId
  deriving Repr, DecidableEq

/-- What the search did besides finding or not finding a conflict: clashes
settled by priority, and norms it could not evaluate. `unevaluable` is reported
alongside **every** result, so a conflict never hides a norm that was skipped. -/
structure Audit where
  resolutions : List Resolution
  unevaluable : List NormId
  deriving Repr, DecidableEq

/-- What was actually encoded and searched. A `consistentOn` claim is only ever
about this much. `validRestricted` says an integrity constraint excluded part of
the domain, so the reader knows the claim is narrower than the raw sizes. -/
structure Scope where
  docId : String
  normIds : List NormId
  articles : List String
  situations : Nat
  params : Nat
  validRestricted : Bool
  deriving Repr, DecidableEq

inductive UnknownReason
  | malformedCondition (norm : NormId)
  deriving Repr, DecidableEq

inductive Result (S P : Type)
  /-- Conflict at that situation under every valid parameter assignment. -/
  | conflict (c : Counterexample S P) (scope : Scope) (audit : Audit)
  /-- Conflict for some valid parameter assignments and not others. The named
  open-textured parameters decide it, and the system does not. -/
  | conditionalConflict (c : Counterexample S P) (params : List String)
      (scope : Scope) (audit : Audit)
  | consistentOn (scope : Scope) (audit : Audit)
  | unknown (reason : UnknownReason) (scope : Scope) (audit : Audit)
  /-- Structural defects; nothing was checked for consistency. -/
  | invalid (findings : List Finding)
  deriving Repr, DecidableEq

/-- The witness of either kind of conflict report. -/
def Result.witness? : Result S P → Option (Counterexample S P)
  | .conflict c _ _ => some c
  | .conditionalConflict c _ _ _ => some c
  | _ => none

/-- The scope of any result that actually searched. -/
def Result.scope? : Result S P → Option Scope
  | .conflict _ sc _ => some sc
  | .conditionalConflict _ _ sc _ => some sc
  | .consistentOn sc _ => some sc
  | .unknown _ sc _ => some sc
  | .invalid _ => none

def Result.isConsistentOn : Result S P → Bool
  | .consistentOn _ _ => true
  | _ => false

/-- Project a candidate into the reported witness. Every field comes from the
two norms, which is what theorem (c) states. -/
def ceOf (k : Cand S P) : Counterexample S P :=
  { situation := k.situation
  , params := k.params
  , left := k.left.id
  , right := k.right.id
  , modalities := (k.left.modality, k.right.modality)
  , sources := (k.left.source, k.right.source) }

/-- Names of the open-textured parameters the two norms mention. -/
def paramNames (A : Atoms S P) (n₁ n₂ : Norm) : List String :=
  ((n₁.paramIdxs ++ n₂.paramIdxs).eraseDups).filterMap fun i =>
    (A.param[i]?).map fun f => f.1

/-- Does `valid` admit the whole enumerated domain? -/
def validIsTrivial [Finite S] [Finite P] (A : Atoms S P) : Bool :=
  (Finite.enum (α := P)).all fun π => (Finite.enum (α := S)).all fun s => A.valid π s

def scopeOf (S P : Type) [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : Scope :=
  { docId := (ns.head?.map fun n => n.source.docId).getD ""
  , normIds := ns.map fun n => n.id
  , articles := ns.map fun n => n.source.article
  , situations := Finite.card S
  , params := Finite.card P
  , validRestricted := !validIsTrivial A }

/-- Clashing pairs that explicit priority settles, with the prevailing norm. -/
def resolutionsOf (ns : List Norm) : List Resolution :=
  (pairsOf ns).filterMap fun p =>
    if p.1.act == p.2.act && Incompatible p.1.modality p.2.modality then
      match Norm.winner? p.1 p.2 with
      | some w => some { winner := w, loser := if w == p.1.id then p.2.id else p.1.id }
      | none => none
    else none

def auditOf [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : Audit :=
  { resolutions := resolutionsOf ns
  , unevaluable := unevaluableIds A ns }

/-- Plain conflict when the clash holds at that situation for every **valid**
parameter assignment; conditional conflict otherwise. -/
def mkResult [Finite P] (A : Atoms S P) (k : Cand S P) (sc : Scope) (au : Audit) :
    Result S P :=
  if (Finite.enum (α := P)).all fun π =>
      !(A.valid π k.situation) || isConflictAt A k.left k.right π k.situation then
    .conflict (ceOf k) sc au
  else
    .conditionalConflict (ceOf k) (paramNames A k.left k.right) sc au

/-! ## The checker -/

/-- The search proper, on a non-empty norm list. -/
def checkNonempty [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : Result S P :=
  match (cands A ns).find? fun k =>
      isConflictAt A k.left k.right k.params k.situation with
  | some k => mkResult A k (scopeOf S P A ns) (auditOf A ns)
  | none =>
    match unevaluableIds A ns with
    | [] => .consistentOn (scopeOf S P A ns) (auditOf A ns)
    | i :: _ => .unknown (.malformedCondition i) (scopeOf S P A ns) (auditOf A ns)

/-- Search the valid part of the finite domain. An empty norm list is a
finding, never a consistency claim. -/
def check [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : Result S P :=
  match ns with
  | [] => .invalid [Finding.emptyNormList]
  | _ => checkNonempty A ns

/-- Validate first, then check. This is the entry point: `unknown` is a
fail-closed guard, not the place where structural defects are reported. -/
def analyze [Finite S] [Finite P] (A : Atoms S P) (catalog : List String)
    (ns : List Norm) : Result S P :=
  match validate A catalog ns with
  | [] => check A ns
  | fs => .invalid fs

/-! ## Core extraction lemma -/

/-- Everything the positive results are built from: a candidate in the search
space whose Bool test was true, and the witness built from it. -/
theorem witness_spec [Finite S] [Finite P] {A : Atoms S P} {ns : List Norm}
    {c : Counterexample S P} (h : (checkNonempty A ns).witness? = some c) :
    ∃ k ∈ cands A ns, c = ceOf k ∧
      isConflictAt A k.left k.right k.params k.situation = true := by
  simp only [checkNonempty] at h
  cases hf : (cands A ns).find? (fun k =>
      isConflictAt A k.left k.right k.params k.situation) with
  | none =>
    rw [hf] at h
    cases hu : unevaluableIds A ns with
    | nil => rw [hu] at h; simp [Result.witness?] at h
    | cons i r => rw [hu] at h; simp [Result.witness?] at h
  | some k =>
    rw [hf] at h
    have hb := List.find?_some hf
    refine ⟨k, List.mem_of_find?_eq_some hf, ?_, hb⟩
    simp only [mkResult] at h
    split at h <;> simp [Result.witness?] at h <;> exact h.symm

/-! ## (a) and (c): a reported conflict is real, in every reported field -/

/-- (a) If the checker reports a conflict, the witness is a real conflict
between two norms of the document, at a **valid** parameter assignment and
situation, and the witness is exactly the projection of those two norms. -/
theorem conflict_of_witness [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {c : Counterexample S P}
    (h : (check A ns).witness? = some c) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      c = ceOf (⟨n₁, n₂, c.params, c.situation⟩ : Cand S P) ∧
      A.valid c.params c.situation = true ∧
      Conflict A n₁ n₂ c.params c.situation := by
  cases ns with
  | nil => simp [check, Result.witness?] at h
  | cons n₀ rest =>
    simp only [check] at h
    obtain ⟨k, hk, hc, hb⟩ := witness_spec h
    obtain ⟨hl, hr, _, hv⟩ := mem_of_mem_cands hk
    subst hc
    exact ⟨k.left, hl, k.right, hr, rfl, hv,
      (isConflictAt_eq_true_iff A k.left k.right k.params k.situation).mp hb⟩

/-- (c) Every reported field — ids, modalities, sources — is the field of the
norm it claims to come from, not just the ids. -/
theorem counterexample_fields_correct [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {c : Counterexample S P}
    (h : (check A ns).witness? = some c) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      c.left = n₁.id ∧ c.right = n₂.id ∧
      c.modalities = (n₁.modality, n₂.modality) ∧
      c.sources = (n₁.source, n₂.source) ∧
      Conflict A n₁ n₂ c.params c.situation := by
  obtain ⟨n₁, h₁, n₂, h₂, hce, _, hconf⟩ := conflict_of_witness h
  refine ⟨n₁, h₁, n₂, h₂, ?_, ?_, ?_, ?_, hconf⟩
  · rw [hce]; rfl
  · rw [hce]; rfl
  · rw [hce]; rfl
  · rw [hce]; rfl

/-! ## (b): consistentOn rules out conflicts -/

/-- (b) If the checker reports `consistentOn`, then no two norms of the
document conflict at any **valid** situation and parameter assignment.

This says nothing about situations `valid` excludes, and nothing about the law
itself. -/
theorem not_conflict_of_consistentOn [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {sc : Scope} {au : Audit}
    (h : check A ns = .consistentOn sc au) :
    ∀ n₁ ∈ ns, ∀ n₂ ∈ ns, ∀ (π : P) (s : S),
      A.valid π s = true → ¬ Conflict A n₁ n₂ π s := by
  intro n₁ h₁ n₂ h₂ π s hv hconf
  cases ns with
  | nil => simp at h₁
  | cons n₀ rest =>
    simp only [check, checkNonempty] at h
    cases hf : (cands A (n₀ :: rest)).find? (fun k =>
        isConflictAt A k.left k.right k.params k.situation) with
    | some k => rw [hf] at h; simp only [mkResult] at h; split at h <;> simp at h
    | none =>
      have hnone := List.find?_eq_none.mp hf
      by_cases heq : n₁ = n₂
      · exact not_conflict_self A n₂ π s (heq ▸ hconf)
      · have hact : n₁.act = n₂.act := hconf.1
        rcases mem_pairsOf h₁ h₂ heq with hp | hp
        · exact hnone _ (mem_cands hp hact hv)
            ((isConflictAt_eq_true_iff A n₁ n₂ π s).mpr hconf)
        · exact hnone _ (mem_cands hp hact.symm hv)
            ((isConflictAt_eq_true_iff A n₂ n₁ π s).mpr (Conflict_comm hconf))

/-! ## (d): the scope says exactly what was checked -/

/-- (d) `scopeOf` lists exactly the ids and articles of the norms given, and
the enumerated domain sizes. -/
theorem scopeOf_spec (S P : Type) [Finite S] [Finite P] (A : Atoms S P)
    (ns : List Norm) :
    (scopeOf S P A ns).normIds = ns.map (fun n => n.id) ∧
    (scopeOf S P A ns).articles = ns.map (fun n => n.source.article) ∧
    (scopeOf S P A ns).situations = Finite.card S ∧
    (scopeOf S P A ns).params = Finite.card P ∧
    ((scopeOf S P A ns).validRestricted = true ↔ validIsTrivial A = false) := by
  refine ⟨rfl, rfl, rfl, rfl, ?_⟩
  simp [scopeOf]

/-- (d) Every result that searched reports that scope, so the guarantee of
`scopeOf_spec` is the guarantee of the report. -/
theorem check_scope [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm)
    (hne : ns ≠ []) : (check A ns).scope? = some (scopeOf S P A ns) := by
  cases ns with
  | nil => exact absurd rfl hne
  | cons n₀ rest =>
    simp only [check, checkNonempty]
    cases hf : (cands A (n₀ :: rest)).find? (fun k =>
        isConflictAt A k.left k.right k.params k.situation) with
    | some k =>
      simp only [mkResult]
      split <;> rfl
    | none =>
      cases hu : unevaluableIds A (n₀ :: rest) with
      | nil => rfl
      | cons i r => rfl

/-! ## (e): the two labels mean what they say -/

theorem conflict_label_spec [Finite S] [Finite P] {A : Atoms S P} {ns : List Norm}
    {c : Counterexample S P} {sc : Scope} {au : Audit}
    (h : checkNonempty A ns = .conflict c sc au) :
    ∃ k ∈ cands A ns, c = ceOf k ∧
      ((Finite.enum (α := P)).all fun π =>
        !(A.valid π k.situation) || isConflictAt A k.left k.right π k.situation) = true := by
  simp only [checkNonempty] at h
  cases hf : (cands A ns).find? (fun k =>
      isConflictAt A k.left k.right k.params k.situation) with
  | none =>
    rw [hf] at h
    cases hu : unevaluableIds A ns with
    | nil => rw [hu] at h; simp at h
    | cons i r => rw [hu] at h; simp at h
  | some k =>
    rw [hf] at h
    simp only [mkResult] at h
    cases hcond : ((Finite.enum (α := P)).all fun π =>
        !(A.valid π k.situation) || isConflictAt A k.left k.right π k.situation) with
    | false => rw [hcond] at h; simp at h
    | true =>
      rw [hcond] at h
      simp at h
      exact ⟨k, List.mem_of_find?_eq_some hf, h.1.symm, hcond⟩

theorem conditionalConflict_label_spec [Finite S] [Finite P] {A : Atoms S P}
    {ns : List Norm} {c : Counterexample S P} {ps : List String}
    {sc : Scope} {au : Audit}
    (h : checkNonempty A ns = .conditionalConflict c ps sc au) :
    ∃ k ∈ cands A ns, c = ceOf k ∧
      isConflictAt A k.left k.right k.params k.situation = true ∧
      ((Finite.enum (α := P)).all fun π =>
        !(A.valid π k.situation) || isConflictAt A k.left k.right π k.situation) = false := by
  simp only [checkNonempty] at h
  cases hf : (cands A ns).find? (fun k =>
      isConflictAt A k.left k.right k.params k.situation) with
  | none =>
    rw [hf] at h
    cases hu : unevaluableIds A ns with
    | nil => rw [hu] at h; simp at h
    | cons i r => rw [hu] at h; simp at h
  | some k =>
    rw [hf] at h
    have hb := List.find?_some hf
    simp only [mkResult] at h
    cases hcond : ((Finite.enum (α := P)).all fun π =>
        !(A.valid π k.situation) || isConflictAt A k.left k.right π k.situation) with
    | true => rw [hcond] at h; simp at h
    | false =>
      rw [hcond] at h
      simp at h
      exact ⟨k, List.mem_of_find?_eq_some hf, h.1.symm, hb, hcond⟩

/-- (e) part 1: `.conflict` means the clash holds at that situation under
**every** valid parameter assignment. -/
theorem conflict_all_params [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {c : Counterexample S P}
    {sc : Scope} {au : Audit} (h : check A ns = .conflict c sc au) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      ∀ π : P, A.valid π c.situation = true → Conflict A n₁ n₂ π c.situation := by
  cases ns with
  | nil => simp [check] at h
  | cons n₀ rest =>
    simp only [check] at h
    obtain ⟨k, hk, hc, hall⟩ := conflict_label_spec h
    obtain ⟨hl, hr, _, _⟩ := mem_of_mem_cands hk
    subst hc
    refine ⟨k.left, hl, k.right, hr, ?_⟩
    intro π hv
    have hv' : A.valid π k.situation = true := hv
    have hx := Finite.forall_of_all _ hall π
    simp only [hv', Bool.not_true, Bool.false_or] at hx
    exact (isConflictAt_eq_true_iff A k.left k.right π k.situation).mp hx

/-- (e) part 2: `.conditionalConflict` means there is a valid parameter
assignment that conflicts and another that does not, at that same situation. -/
theorem conditionalConflict_split [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {c : Counterexample S P} {ps : List String}
    {sc : Scope} {au : Audit} (h : check A ns = .conditionalConflict c ps sc au) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      (∃ π : P, A.valid π c.situation = true ∧ Conflict A n₁ n₂ π c.situation) ∧
      (∃ π : P, A.valid π c.situation = true ∧ ¬ Conflict A n₁ n₂ π c.situation) := by
  cases ns with
  | nil => simp [check] at h
  | cons n₀ rest =>
    simp only [check] at h
    obtain ⟨k, hk, hc, hwit, hall⟩ := conditionalConflict_label_spec h
    obtain ⟨hl, hr, _, hv⟩ := mem_of_mem_cands hk
    subst hc
    refine ⟨k.left, hl, k.right, hr, ?_, ?_⟩
    · exact ⟨k.params, hv,
        (isConflictAt_eq_true_iff A k.left k.right k.params k.situation).mp hwit⟩
    · obtain ⟨π, _, hx⟩ := List.all_eq_false.mp hall
      simp only [Bool.or_eq_true, Bool.not_eq_true'] at hx
      refine ⟨π, ?_, ?_⟩
      · cases hvp : A.valid π k.situation with
        | true => exact hvp
        | false => exact absurd (Or.inl hvp) hx
      · intro hconf
        exact absurd
          (Or.inr ((isConflictAt_eq_true_iff A k.left k.right π k.situation).mpr hconf)) hx

/-! ## (f): a clean validator run means nothing is unevaluable -/

/-- (f) If the validator reports no findings, `applies` never returns `none` —
at any `(π, s)`, valid or not. The guarantee is therefore stronger than the
`valid` restriction the checker uses. -/
theorem applies_isSome_of_validate_nil [Finite S] [Finite P]
    {A : Atoms S P} {catalog : List String} {ns : List Norm}
    (h : validate A catalog ns = []) :
    ∀ n ∈ ns, ∀ (π : P) (s : S), (n.applies A π s).isSome = true := by
  intro n hn π s
  exact Norm.applies_isSome_of_wf A n (wf_of_validate_nil h n hn) π s

end LexProof
