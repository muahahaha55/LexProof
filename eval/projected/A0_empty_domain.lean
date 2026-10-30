import LexProof.Verify.Conflict
import LexProof.Core.AtomTable
open LexProof

/-! A0. What does the existing checker say when a table has an enum atom with an
empty band list (so the situation space is empty)? Scratch file, not part of the
library. Two norms that clash at EVERY point (obligation vs prohibition, same act,
condition `tt`), over a table with one Bool atom plus one enum atom. -/

def src : SourceId :=
  { docId := "A0", docType := .law, effective := ⟨2020, 1, 1⟩, article := "Điều 1" }

def mk (id : String) (m : Modality) : Norm :=
  { id := id, modality := m, act := "x", condition := .tt, exceptions := []
  , priority := none, source := src, references := [] }

def norms : List Norm := [mk "O" .obligation, mk "F" .prohibition]

def tPar : AtomTable := [⟨"P1", .bool, "Điều 1"⟩]

/-- Enum atom with NO bands. -/
def tEmpty : AtomTable :=
  [⟨"S1", .bool, "Điều 1"⟩, ⟨"S2", .enum [], "Điều 1"⟩]

/-- Same table with one band. -/
def tOne : AtomTable :=
  [⟨"S1", .bool, "Điều 1"⟩, ⟨"S2", .enum [⟨"một", "Điều 1"⟩], "Điều 1"⟩]

def verdict {S P : Type} [Finite S] [Finite P] (A : Atoms S P) : String :=
  match analyze A [] norms with
  | .invalid fs => s!"invalid ({fs.length} findings)"
  | .consistentOn sc _ => s!"consistentOn  situations={sc.situations} params={sc.params} validTotal={sc.validTotal}"
  | .conflict _ sc _ => s!"conflict  situations={sc.situations} validTotal={sc.validTotal}"
  | .conditionalConflict _ _ sc _ => s!"conditionalConflict  situations={sc.situations}"
  | .unknown _ sc _ => s!"unknown situations={sc.situations}"

#eval s!"empty enum   : card={Finite.card (Valuation tEmpty)}  analyze -> {verdict (atomsOf tEmpty tPar [] [])}"
#eval s!"one-band enum: card={Finite.card (Valuation tOne)}  analyze -> {verdict (atomsOf tOne tPar [] [])}"

/-- Kernel: on the EMPTY space `analyze` is proved `consistentOn` by `decide`. -/
theorem empty_space_is_consistent :
    (analyze (atomsOf tEmpty tPar [] []) [] norms).isConsistentOn = true := by decide +kernel

theorem empty_space_has_no_points : Finite.card (Valuation tEmpty) = 0 := by decide +kernel

/-- And the very same norms DO conflict once the space is non-empty. -/
theorem nonempty_space_conflicts :
    (analyze (atomsOf tOne tPar [] []) [] norms).isConsistentOn = false := by decide +kernel

#print axioms empty_space_is_consistent
