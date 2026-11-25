import LexProof.Verify.Drafting

/-!
# Tests for `Verify/Drafting.lean` (invented norms; nothing here was reviewed)

The checks must reject a missing or a wrong witness, and the skip list must exclude exactly what it names.
-/

namespace LexProof.DraftingTests

open LexProof

private def src : SourceId := { docId := "TEST", docType := .law, effective := ⟨2026, 1, 1⟩, article := "Điều 1" }

private def mk (id : String) (c : Cond) (ex : List Cond := []) : Norm :=
  { id := id, modality := .prohibition, act := "a", condition := c, exceptions := ex, priority := none,
    source := src, references := [] }

/-- One Boolean situation atom; parameters unused. -/
private def A : Atoms Bool Unit := { sit := [("x", id)], param := [] }

private def dec : Bool → Option (Unit × Bool) := fun b => some ((), b)

/-- `x`: applies when x is true; `dead`: never applies; `wide`: always applies. -/
private def nx := mk "x" (.sit 0)
private def dead := mk "dead" (.and (.sit 0) (.not (.sit 0)))
private def wide := mk "wide" .tt

example : checkLive A dec [nx, wide] [("x", true), ("wide", false)] [] = true := by decide
/-- A dead norm has no witness: the check fails whatever point is offered... -/
example : checkLive A dec [dead] [("dead", true)] [] = false := by decide
example : checkLive A dec [dead] [("dead", false)] [] = false := by decide
/-- ...and passes only if the norm is skipped (reported as unknown). -/
example : checkLive A dec [dead] [] ["dead"] = true := by decide
/-- A missing witness fails. -/
example : checkLive A dec [nx] [] [] = false := by decide

/-- `x` is covered by `wide` (no point where x applies and wide does not); `wide` is not covered by `x`. -/
example : checkNotSubsumed A dec [nx, wide] [("wide", "x", false)] [("x", "wide")] = true := by decide
example : checkNotSubsumed A dec [nx, wide] [("wide", "x", false), ("x", "wide", true)] [] = false := by decide

/-- An exception the condition excludes never fires; one it allows does. -/
private def deadExc := mk "e" (.sit 0) [.not (.sit 0)]
private def liveExc := mk "f" .tt [.sit 0]
example : checkExcFires A dec [liveExc] [("f", 0, true)] [] = true := by decide
example : checkExcFires A dec [deadExc] [("e", 0, true)] [] = false := by decide
example : checkExcFires A dec [deadExc] [("e", 0, false)] [] = false := by decide
example : checkExcFires A dec [deadExc] [] [("e", 0)] = true := by decide

end LexProof.DraftingTests
