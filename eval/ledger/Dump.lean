import LexProof
/-! Scratch (not part of the library): prints the encoded norm sources and the not-encoded entries of
`Laws/AlcoholSale.lean` as JSON, with each reference parsed by `ClauseRef`. Run:
`lake env lean --run eval/ledger/Dump.lean > eval/ledger/module.json` -/
open LexProof LexProof.Laws.AlcoholSale LexProof.Laws.AlcoholSaleRefs

def esc (s : String) : String :=
  let bs := Char.ofNat 92
  let dq := Char.ofNat 34
  String.ofList (s.toList.flatMap fun c => if c == dq || c == bs then [bs, c] else [c])

def q (s : String) : String := "\"" ++ esc s ++ "\""

def refJson (r : ClauseRef) : String :=
  s!"\{\"article\": {r.article}, \"clause\": {match r.clause with | some k => toString k | none => "null"}, \"point\": {match r.point with | some p => q p | none => "null"}, \"heading\": {r.part == .heading}, \"branch\": {match r.branch with | some b => q b | none => "null"}, \"render\": {q r.render}}"

def list (xs : List String) : String := "[" ++ ",\n  ".intercalate xs ++ "]"

def main : IO Unit := do
  let ns := norms.map fun n =>
    s!"\{\"id\": {q n.id}, \"act\": {q n.act}, \"source\": {q n.source.article}, \"refs\": {list (refsOf n.source.article |>.map refJson)}}"
  let es := notEncoded.map fun e =>
    s!"\{\"clause\": {q e.clause}, \"reason\": {q e.reason}, \"refs\": {list (refsOf e.clause |>.map refJson)}}"
  IO.println s!"\{\"norms\": {list ns},\n\"notEncoded\": {list es}}"
