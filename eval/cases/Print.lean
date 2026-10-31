import LexProof.Laws.AlcoholSaleCases
open LexProof LexProof.Laws.AlcoholSaleCases

/-! Scratch (not part of the library): prints every case result.
  lake env lean --run eval/cases/Print.lean -/

def main : IO Unit := do
  IO.println s!"CASES {cases.length}"
  for r in results do IO.println ("R\t" ++ r.line)
  IO.println s!"NOTPASSING {notPassingNow.length}"
  for r in notPassingNow do IO.println ("N\t" ++ r.line)
  IO.println s!"PASSING {",".intercalate passing}"
