/-!
# Finite enumerable types

A minimal replacement for `Fintype` (no Mathlib). A `Finite α` instance is an
explicit enumeration plus a proof that it misses nothing, which is what lets a
conflict search over `α` be turned into a statement about every `α`.
-/

namespace LexProof

/-- A type with an explicit, provably complete enumeration. -/
class Finite (α : Type) where
  enum : List α
  complete : ∀ a : α, a ∈ enum

namespace Finite

/-- Size of the enumeration. Counts towards the `decide` budget. -/
def card (α : Type) [Finite α] : Nat := (enum (α := α)).length

/-- The bridge from an exhaustive `Bool` scan to a real universal statement. -/
theorem forall_of_all {α : Type} [Finite α] (p : α → Bool)
    (h : (enum (α := α)).all p = true) : ∀ a : α, p a = true :=
  fun a => List.all_eq_true.mp h a (complete a)

instance : Finite Unit where
  enum := [()]
  complete := by intro a; cases a; simp

instance : Finite Bool where
  enum := [false, true]
  complete := by intro a; cases a <;> simp

instance {α β : Type} [Finite α] [Finite β] : Finite (α × β) where
  enum := (enum (α := α)).flatMap fun a => (enum (α := β)).map fun b => (a, b)
  complete := by
    intro ab
    refine List.mem_flatMap.mpr ⟨ab.1, complete ab.1, ?_⟩
    exact List.mem_map.mpr ⟨ab.2, complete ab.2, rfl⟩

end Finite

end LexProof
