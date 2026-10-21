import LexProof.Core.Norm

/-!
# Level 1 conflict checking

`Conflict` is the `Prop` saying two norms clash at one situation and one
assignment of the open-textured parameters. `check` is a `Bool`-level search
over the whole finite domain. The two are tied together by
`conflict_of_witness` and `not_conflict_of_consistentOn` at the end of this
file; everything in between is machinery.
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

/-- `true` when the encoding could not be evaluated at all. -/
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

/-! ## Candidates -/

/-- One point of the search space. -/
structure Cand (S P : Type) where
  left : Norm
  right : Norm
  params : P
  situation : S

/-- Every (ordered pair of norms, parameter assignment, situation). -/
def cands [Finite S] [Finite P] (ns : List Norm) : List (Cand S P) :=
  ns.flatMap fun n₁ => ns.flatMap fun n₂ =>
    (Finite.enum (α := P)).flatMap fun π =>
      (Finite.enum (α := S)).map fun s => ⟨n₁, n₂, π, s⟩

theorem mem_cands [Finite S] [Finite P] {ns : List Norm} {n₁ n₂ : Norm}
    {π : P} {s : S} (h₁ : n₁ ∈ ns) (h₂ : n₂ ∈ ns) :
    (⟨n₁, n₂, π, s⟩ : Cand S P) ∈ cands ns := by
  refine List.mem_flatMap.mpr ⟨n₁, h₁, ?_⟩
  refine List.mem_flatMap.mpr ⟨n₂, h₂, ?_⟩
  refine List.mem_flatMap.mpr ⟨π, Finite.complete π, ?_⟩
  exact List.mem_map.mpr ⟨s, Finite.complete s, rfl⟩

theorem mem_of_mem_cands [Finite S] [Finite P] {ns : List Norm} {k : Cand S P}
    (h : k ∈ cands ns) : k.left ∈ ns ∧ k.right ∈ ns := by
  simp only [cands] at h
  rcases List.mem_flatMap.mp h with ⟨n₁, hn₁, h⟩
  rcases List.mem_flatMap.mp h with ⟨n₂, hn₂, h⟩
  rcases List.mem_flatMap.mp h with ⟨_, _, h⟩
  rcases List.mem_map.mp h with ⟨_, _, heq⟩
  subst heq
  exact ⟨hn₁, hn₂⟩

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

/-- What was actually encoded and searched. A `consistentOn` claim is only ever
about this much. -/
structure Scope where
  docId : String
  normIds : List NormId
  articles : List String
  situations : Nat
  params : Nat
  deriving Repr, DecidableEq

inductive UnknownReason
  | malformedCondition (norm : NormId)
  deriving Repr, DecidableEq

inductive Result (S P : Type)
  /-- Conflict at that situation for every parameter assignment. -/
  | conflict (c : Counterexample S P)
  /-- Conflict for some parameter assignments only. The named open-textured
  parameters decide it, and the system does not. -/
  | conditionalConflict (c : Counterexample S P) (params : List String)
  | consistentOn (scope : Scope)
  | unknown (reason : UnknownReason)
  deriving Repr, DecidableEq

/-- The witness of either kind of conflict report. -/
def Result.witness? : Result S P → Option (Counterexample S P)
  | .conflict c => some c
  | .conditionalConflict c _ => some c
  | _ => none

def Result.isConsistentOn : Result S P → Bool
  | .consistentOn _ => true
  | _ => false

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

def scopeOf (S P : Type) [Finite S] [Finite P] (ns : List Norm) : Scope :=
  { docId := (ns.head?.map fun n => n.source.docId).getD ""
  , normIds := ns.map fun n => n.id
  , articles := ns.map fun n => n.source.article
  , situations := Finite.card S
  , params := Finite.card P }

/-- Plain conflict when it holds for every parameter assignment at that
situation, conditional conflict otherwise (decision 8). -/
def mkResult [Finite P] (A : Atoms S P) (k : Cand S P) : Result S P :=
  if (Finite.enum (α := P)).all fun π => isConflictAt A k.left k.right π k.situation then
    .conflict (ceOf k)
  else
    .conditionalConflict (ceOf k) (paramNames A k.left k.right)

/-! ## The checker -/

/-- Search the whole finite domain. A definite conflict is reported first; an
unevaluable encoding yields `unknown`; `consistentOn` requires that nothing
conflicted and nothing was unevaluable. -/
def check [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : Result S P :=
  match (cands ns).find? fun k => isConflictAt A k.left k.right k.params k.situation with
  | some k => mkResult A k
  | none =>
    match (cands ns).find? fun k => isUnknownAt A k.left k.right k.params k.situation with
    | some k => .unknown (.malformedCondition k.left.id)
    | none => .consistentOn (scopeOf S P ns)

/-! ## Linking the checker to the relation -/

/-- (a) If the checker reports a conflict, the reported witness really is a
conflict between two norms of the document, at those parameters and that
situation. -/
theorem conflict_of_witness [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {c : Counterexample S P}
    (h : (check A ns).witness? = some c) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      n₁.id = c.left ∧ n₂.id = c.right ∧
      Conflict A n₁ n₂ c.params c.situation := by
  simp only [check] at h
  cases hf : (cands ns).find?
      fun k => isConflictAt A k.left k.right k.params k.situation with
  | none =>
    rw [hf] at h
    cases hu : (cands ns).find?
        fun k => isUnknownAt A k.left k.right k.params k.situation with
    | none => rw [hu] at h; simp [Result.witness?] at h
    | some k => rw [hu] at h; simp [Result.witness?] at h
  | some k =>
    rw [hf] at h
    have hk := List.find?_some hf
    have hmem := mem_of_mem_cands (List.mem_of_find?_eq_some hf)
    have hc : c = ceOf k := by
      simp only [mkResult] at h
      split at h <;> simp [Result.witness?] at h <;> exact h.symm
    subst hc
    exact ⟨k.left, hmem.1, k.right, hmem.2, rfl, rfl,
      (isConflictAt_eq_true_iff A k.left k.right k.params k.situation).mp hk⟩

/-- (b) If the checker reports `consistentOn`, then no two norms of the document
conflict at any situation under any parameter assignment. This is a statement
about the encoded norms only; it says nothing about the law itself. -/
theorem not_conflict_of_consistentOn [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {sc : Scope}
    (h : check A ns = .consistentOn sc) :
    ∀ n₁ ∈ ns, ∀ n₂ ∈ ns, ∀ (π : P) (s : S), ¬ Conflict A n₁ n₂ π s := by
  intro n₁ h₁ n₂ h₂ π s hc
  simp only [check] at h
  cases hf : (cands ns).find?
      fun k => isConflictAt A k.left k.right k.params k.situation with
  | some k =>
    rw [hf] at h
    simp only [mkResult] at h
    split at h <;> simp at h
  | none =>
    have hall := List.find?_eq_none.mp hf _ (mem_cands (π := π) (s := s) h₁ h₂)
    exact hall ((isConflictAt_eq_true_iff A n₁ n₂ π s).mpr hc)

end LexProof
