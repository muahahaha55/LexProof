import LexProof.Verify.Entail

/-!
# Tests for `Verify/Entail.lean`

Invented acts and norms (not a `Laws` module, nothing here was reviewed). Every expected result is pinned and
checked by `decide`, so a change in `derive` breaks the build.
-/

namespace LexProof.EntailTests

open LexProof

private def src : SourceId := { docId := "TEST", docType := .law, effective := ⟨2026, 1, 1⟩, article := "Điều 1" }

private def mk (id : String) (mo : Modality) (act : Act) : Norm :=
  { id := id, modality := mo, act := act, condition := .tt, exceptions := [], priority := none, source := src,
    references := [] }

private def e (a b : Act) : Edge := { src := a, dst := b, source := "Điều 1", reading := "test" }

/-- An obligation flows forward along an edge, a prohibition backward. -/
example : (derive [e "thu_hoi" "van_chuyen"] [mk "o" .obligation "thu_hoi", mk "p" .prohibition "van_chuyen"]).map
    (fun n => (n.id, n.modality, n.act)) =
    [("SUY RA [thu_hoi ⇒ van_chuyen] o", .obligation, "van_chuyen"),
     ("SUY RA [thu_hoi ⇒ van_chuyen] p", .prohibition, "thu_hoi")] := by decide

/-- Chains: a prohibition on `c` reaches `b` and then `a` through `a ⇒ b ⇒ c`. -/
example : (derive [e "a" "b", e "b" "c"] [mk "p" .prohibition "c"]).map (·.act) = ["b", "a"] := by decide

/-- A permission is never propagated; no edge, nothing derived. -/
example : derive [e "a" "b"] [mk "q" .permission "a", mk "r" .permission "b"] = [] := by decide
example : derive [] [mk "p" .prohibition "a"] = [] := by decide

/-- An edge whose ends no norm uses derives nothing. -/
example : derive [e "x" "y"] [mk "p" .prohibition "a", mk "o" .obligation "b"] = [] := by decide

/-- A derived norm keeps the scope of its origin. -/
example : (derive [e "a" "b"] [mk "p" .prohibition "b"]).map (fun n => (n.condition, n.exceptions, n.priority)) =
    [(.tt, [], none)] := by decide

end LexProof.EntailTests
