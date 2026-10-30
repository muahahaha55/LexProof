import LexProof.Core.Norm

/-!
# Atom tables and valuations (V0)

An **atom table** is data: a list of atoms, each with a name, a domain (`Bool`
or an enum with named values) and the clause of the law it comes from. A
**valuation** of a table is one value index per atom, each inside its domain.
The situation type of a document is `Valuation table`.

This file is **additive**. It changes no existing definition: a table-built
situation type plugs into the existing classes as follows.

* `Finite (Valuation t)` is an instance of the existing `Finite` class, so
  `check`, `analyze`, `scopeOf` accept it unchanged.
* `atomsOf` builds an ordinary `Atoms (Valuation ts) (Valuation tp)`. A reader is
  a Bool predicate "atom `i` has value `v`", so `Cond.sit`/`Cond.param` indices
  keep meaning "reader number `i`". A `Bool` atom has the reader `(atom, 1)`;
  an enum atom has one reader per value. `valid` keeps its default (admit
  everything).
* Integrity constraints are `Cond` trees over those same readers. Here they are
  **only data plus an evaluator** (`icsEval`); nothing feeds them into the
  checker, so `valid` is untouched.

**Trust.** Nothing here is proved to match the law. The names, the value labels
and the `source` strings are for the human reviewer; the kernel checks none of
them. Thresholds (e.g. 5,5 and 15 degrees of alcohol) are bands, each with its
own `source`; a wrong boundary is invisible to the kernel.

## What this file proves

* (P1) `Valuation.nodup_enum`, `Valuation.count_enum`: every valuation appears
  in `Finite.enum` exactly once.
* (P2) `Valuation.card_eq`: `Finite.card (Valuation t)` is the product of the
  domain sizes, and `card_eq_prod` states it without enumerating.
* (P3) `PartialAssign.extend`: a partial assignment within the domains, with no
  atom given two values, extends to a full valuation, provided every domain is
  non-empty.

## What it does *not* give

* **Realisability with constraints.** `extend` ignores integrity constraints. A
  projected counterexample is realisable when its assignment extends to a
  valuation on which every constraint is `some true`. That is satisfiability of
  the constraints over the atoms they share with the assignment (the connected
  component of `F` in the constraint graph); it is neither defined nor proved
  here.
* **`Scope` and D23.** `Finite.card` here is still `enum.length`, so
  `scopeOf`, `validExcludedOf` and `coApplyPoint?` still scan the whole
  enumeration. `card_eq_prod` is the number a rewritten `Scope` could use; no
  existing function uses it yet.
* No validator for tables or readers (`readersOk` is a plain check, not wired
  into `validate`).
-/

namespace LexProof

/-! ## The table (data) -/

/-- One named value of an enum atom, with the clause it comes from. Each band of
a threshold group carries its own `source`. -/
structure Band where
  label : String
  source : String
  deriving Repr, DecidableEq

/-- Domain of an atom: `Bool`, or an enum with named values. -/
inductive Domain
  | bool
  | enum (values : List Band)
  deriving Repr, DecidableEq

/-- Number of values in a domain. -/
def Domain.size : Domain → Nat
  | .bool => 2
  | .enum vs => vs.length

/-- One atom: a name, a domain, and the clause it comes from. -/
structure Atom where
  name : String
  domain : Domain
  source : String
  deriving Repr, DecidableEq

/-- A table of atoms. Order matters: valuations are indexed by position. -/
abbrev AtomTable := List Atom

/-- Domain sizes, in table order. -/
def AtomTable.sizes (t : AtomTable) : List Nat := t.map fun a => a.domain.size

/-- Product of a list of sizes (`1` for the empty list). -/
def prodSizes : List Nat → Nat
  | [] => 1
  | d :: ds => d * prodSizes ds

/-! ## Raw valuations: lists of value indices -/

/-- `vs` has one value per size, each below its size. -/
def legalVals : List Nat → List Nat → Bool
  | [], [] => true
  | d :: ds, v :: vs => decide (v < d) && legalVals ds vs
  | _, _ => false

/-- Every legal list of values for the given sizes. -/
def allVals : List Nat → List (List Nat)
  | [] => [[]]
  | d :: ds => (List.range d).flatMap fun v => (allVals ds).map (v :: ·)

theorem mem_allVals : ∀ (ds vs : List Nat), vs ∈ allVals ds ↔ legalVals ds vs = true
  | [], vs => by cases vs <;> simp [allVals, legalVals]
  | d :: ds, vs => by
    cases vs with
    | nil => simp [allVals, legalVals]
    | cons v vs =>
      simp [allVals, legalVals, List.mem_flatMap, List.mem_map, List.mem_range,
        mem_allVals ds vs]

theorem length_flatMap_const {α β : Type} (l : List α) (f : α → List β) (c : Nat)
    (h : ∀ x ∈ l, (f x).length = c) : (l.flatMap f).length = l.length * c := by
  induction l with
  | nil => simp
  | cons x xs ih =>
    have hx := h x (by simp)
    have hxs := ih (fun y hy => h y (by simp [hy]))
    simp only [List.flatMap_cons, List.length_append, hx, hxs, List.length_cons]
    rw [Nat.succ_mul, Nat.add_comm]

theorem length_allVals : ∀ ds : List Nat, (allVals ds).length = prodSizes ds
  | [] => by simp [allVals, prodSizes]
  | d :: ds => by
    have h := length_flatMap_const (List.range d)
      (fun v => (allVals ds).map (v :: ·)) (prodSizes ds)
      (fun _ _ => by simp [length_allVals ds])
    simpa [allVals, prodSizes] using h

theorem nodup_allVals : ∀ ds : List Nat, (allVals ds).Nodup
  | [] => by simp [allVals]
  | d :: ds => by
    have ih : List.Pairwise (· ≠ ·) (allVals ds) := nodup_allVals ds
    show List.Pairwise (· ≠ ·) (List.flatMap _ (List.range d))
    rw [List.pairwise_flatMap]
    refine ⟨fun v _ => ih.map (v :: ·) (fun a b hab h => hab (List.cons.inj h).2), ?_⟩
    refine (List.pairwise_lt_range (n := d)).imp ?_
    intro a b hab x hx y hy
    obtain ⟨u, _, rfl⟩ := List.mem_map.1 hx
    obtain ⟨w, _, rfl⟩ := List.mem_map.1 hy
    intro h
    have := (List.cons.inj h).1
    omega

/-! ## The situation type -/

/-- A valuation of the table `t`: one value index per atom, inside its domain. -/
structure Valuation (t : AtomTable) where
  vs : List Nat
  h : legalVals t.sizes vs = true
  deriving DecidableEq

instance (t : AtomTable) : Finite (Valuation t) where
  enum := (allVals t.sizes).attach.map fun x => ⟨x.1, (mem_allVals _ _).1 x.2⟩
  complete := by
    intro a
    exact List.mem_map.2 ⟨⟨a.vs, (mem_allVals _ _).2 a.h⟩, List.mem_attach _ _, rfl⟩

namespace Valuation

variable {t : AtomTable}

/-- (P1) Every valuation appears **at most once** in the enumeration. With
`Finite.complete` (at least once) this is "exactly once". -/
theorem nodup_enum : (Finite.enum (α := Valuation t)).Nodup := by
  have hmap : (Finite.enum (α := Valuation t)).map Valuation.vs = allVals t.sizes := by
    show (List.map _ (allVals t.sizes).attach).map Valuation.vs = _
    rw [List.map_map]
    exact List.attach_map_subtype_val _
  have h : List.Pairwise (· ≠ ·) ((Finite.enum (α := Valuation t)).map Valuation.vs) := by
    rw [hmap]; exact nodup_allVals _
  exact List.Pairwise.of_map _ (fun a b hab hEq => hab (by rw [hEq])) h

/-- (P1) Every valuation appears exactly once. -/
theorem count_enum (v : Valuation t) : (Finite.enum (α := Valuation t)).count v = 1 :=
  by simp [List.Nodup.count nodup_enum, Finite.complete v]

/-- (P2) The size of the enumeration is the product of the domain sizes. -/
theorem card_eq : Finite.card (Valuation t) = prodSizes t.sizes := by
  show (List.map _ (allVals t.sizes).attach).length = _
  simp [length_allVals]

/-- Value index of atom `i`; `0` when `i` is out of range (check with
`readersOk` first). -/
def get (s : Valuation t) (i : Nat) : Nat := s.vs.getD i 0

/-- Reader: atom `i` has value index `v`. -/
def reads (i v : Nat) (s : Valuation t) : Bool := s.get i == v

end Valuation

/-- (P2) The same number, stated on the table: product of the domain sizes. -/
def AtomTable.points (t : AtomTable) : Nat := prodSizes t.sizes

theorem card_eq_prod (t : AtomTable) : Finite.card (Valuation t) = t.points :=
  Valuation.card_eq

/-! ## Plugging into `Atoms` -/

/-- A reader specification: name, atom index, value index. -/
abbrev ReaderSpec := String × Nat × Nat

/-- The ordinary `Atoms` of a situation table and a parameter table. `valid` is
left at its default. -/
def atomsOf (ts tp : AtomTable) (rs rp : List ReaderSpec) :
    Atoms (Valuation ts) (Valuation tp) :=
  { sit := rs.map fun r => (r.1, Valuation.reads r.2.1 r.2.2)
  , param := rp.map fun r => (r.1, Valuation.reads r.2.1 r.2.2) }

/-- Every reader names an existing atom and an existing value of it. Without
this, `Valuation.get` would silently answer `0` for a missing atom. -/
def readersOk (t : AtomTable) (rs : List ReaderSpec) : Bool :=
  rs.all fun r =>
    match t.sizes[r.2.1]? with
    | some d => decide (r.2.2 < d)
    | none => false

/-- Integrity constraints as data: `Cond` trees over the readers of an `Atoms`.
`none` when a constraint is malformed. **Not connected to `valid`.** -/
def icsEval {S P : Type} (A : Atoms S P) (π : P) (s : S) : List Cond → Option Bool
  | [] => some true
  | c :: cs =>
    match c.eval A π s, icsEval A π s cs with
    | some a, some b => some (a && b)
    | _, _ => none

/-! ## (P3) Lifting a partial assignment -/

/-- A partial assignment: (atom index, value index) pairs. -/
abbrev PartialAssign := List (Nat × Nat)

/-- First value assigned to atom `i`, if any. -/
def pget : PartialAssign → Nat → Option Nat
  | [], _ => none
  | (k, v) :: r, i => if k = i then some v else pget r i

/-- The assignment stays inside the domains and gives no atom two values. -/
def PartialAssign.Ok (t : AtomTable) (p : PartialAssign) : Prop :=
  (∀ x ∈ p, ∃ d, t.sizes[x.1]? = some d ∧ x.2 < d) ∧
  (∀ x ∈ p, ∀ y ∈ p, x.1 = y.1 → x.2 = y.2)

/-- Every domain has at least one value (otherwise there is no valuation). -/
def AtomTable.NonEmpty (t : AtomTable) : Prop := ∀ d ∈ t.sizes, 0 < d

theorem pget_mem : ∀ {p : PartialAssign} {i v : Nat}, pget p i = some v → (i, v) ∈ p
  | [], _, _, h => by simp [pget] at h
  | (k, w) :: r, i, v, h => by
    by_cases hk : k = i
    · simp [pget, hk] at h
      simp [hk, h]
    · simp [pget, hk] at h
      exact List.mem_cons_of_mem _ (pget_mem h)

theorem pget_of_mem : ∀ {p : PartialAssign}, (∀ x ∈ p, ∀ y ∈ p, x.1 = y.1 → x.2 = y.2) →
    ∀ {x : Nat × Nat}, x ∈ p → pget p x.1 = some x.2
  | [], _, _, hx => by simp at hx
  | (k, w) :: r, hc, x, hx => by
    by_cases hk : k = x.1
    · have : w = x.2 :=
        hc (k, w) (by simp) x hx hk
      simp [pget, hk, this]
    · have hxr : x ∈ r := by
        rcases List.mem_cons.1 hx with h | h
        · exact absurd (by rw [h]) hk
        · exact h
      simp only [pget, hk, ite_false]
      exact pget_of_mem (fun a ha b hb => hc a (List.mem_cons_of_mem _ ha) b
        (List.mem_cons_of_mem _ hb)) hxr

/-- Fill the atoms `k, k+1, …` of the sizes `ds` from `p`, defaulting to `0`. -/
def fillFrom (p : PartialAssign) : Nat → List Nat → List Nat
  | _, [] => []
  | k, _ :: ds => ((pget p k).getD 0) :: fillFrom p (k + 1) ds

theorem getElem?_fillFrom (p : PartialAssign) : ∀ (ds : List Nat) (k j : Nat),
    j < ds.length → (fillFrom p k ds)[j]? = some ((pget p (k + j)).getD 0)
  | [], _, _, h => by simp at h
  | _ :: ds, k, j, h => by
    cases j with
    | zero => simp [fillFrom]
    | succ j =>
      have h' : j < ds.length := by simpa using h
      have e : k + (j + 1) = k + 1 + j := by omega
      simp only [fillFrom, List.getElem?_cons_succ, e]
      exact getElem?_fillFrom p ds (k + 1) j h'

theorem legal_fillFrom (p : PartialAssign) : ∀ (ds : List Nat) (k : Nat),
    (∀ d ∈ ds, 0 < d) →
    (∀ j v d, ds[j]? = some d → pget p (k + j) = some v → v < d) →
    legalVals ds (fillFrom p k ds) = true
  | [], _, _, _ => rfl
  | d :: ds, k, hne, hv => by
    have h0 : (pget p k).getD 0 < d := by
      cases hp : pget p k with
      | none => simpa using hne d (by simp)
      | some v => simpa using hv 0 v d (by simp) (by simpa using hp)
    have ih := legal_fillFrom p ds (k + 1) (fun e he => hne e (by simp [he]))
      (fun j v e hj hpj => hv (j + 1) v e (by simpa using hj)
        (by have : k + (j + 1) = k + 1 + j := by omega
            rw [this]; exact hpj))
    simp [fillFrom, legalVals, h0, ih]

/-- (P3, unconstrained case) A partial assignment inside the domains, with no
atom given two values, extends to a full valuation — provided every domain is
non-empty. Integrity constraints are **not** considered: with constraints the
extension must also satisfy them (satisfiability over the constraint
component), which is not proved here. -/
theorem PartialAssign.extend (t : AtomTable) (hne : t.NonEmpty) (p : PartialAssign)
    (hp : PartialAssign.Ok t p) :
    ∃ s : Valuation t, ∀ x ∈ p, s.vs[x.1]? = some x.2 := by
  have hlegal : legalVals t.sizes (fillFrom p 0 t.sizes) = true := by
    refine legal_fillFrom p t.sizes 0 hne ?_
    intro j v d hj hpj
    obtain ⟨d', hd', hlt⟩ := hp.1 _ (pget_mem hpj)
    have hd'' : t.sizes[j]? = some d' := by simpa using hd'
    have hdd : d = d' := Option.some.inj (hj.symm.trans hd'')
    rw [hdd]; exact hlt
  refine ⟨⟨fillFrom p 0 t.sizes, hlegal⟩, ?_⟩
  intro x hx
  obtain ⟨d, hd, _⟩ := hp.1 x hx
  have hlen : x.1 < t.sizes.length := (List.getElem?_eq_some_iff.1 hd).1
  show (fillFrom p 0 t.sizes)[x.1]? = some x.2
  rw [getElem?_fillFrom p t.sizes 0 x.1 hlen, Nat.zero_add, pget_of_mem hp.2 hx]
  rfl

/-! ## Non-vacuity

A three-atom table (enum 2, enum 3, Bool): 12 valuations, counted by
enumeration and by the product, and a reader that reads what it names. -/

private def demo : AtomTable :=
  [ { name := "S01", source := "Điều 13 đoạn dẫn"
      domain := .enum [⟨"rượu", "Điều 2 khoản 1"⟩, ⟨"bia", "Điều 2 khoản 2"⟩] }
  , { name := "S02", source := "Điều 13 đoạn dẫn"
      domain := .enum [⟨"dưới 5,5 độ", "Điều 12"⟩, ⟨"từ 5,5 đến dưới 15 độ", "Điều 13"⟩,
                        ⟨"từ 15 độ trở lên", "Điều 5 khoản 7"⟩] }
  , { name := "S24", source := "Điều 12 khoản 3 điểm c", domain := .bool } ]

example : Finite.card (Valuation demo) = 12 := by decide

example : demo.points = 12 := by decide

example : readersOk demo [("S01=bia", 0, 1), ("S02>=15", 1, 2), ("S24", 2, 1)] = true := by decide

example : readersOk demo [("S02 giá trị 3", 1, 3)] = false := by decide

example : (Valuation.reads 1 2 (⟨[1, 2, 0], by decide⟩ : Valuation demo)) = true := by decide

end LexProof
