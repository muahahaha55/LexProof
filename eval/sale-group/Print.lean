import LexProof.Laws.AlcoholSale
open LexProof LexProof.Laws.AlcoholSale

/-! Scratch (not part of the library). Prints, deterministically, what the checker sees
for the DRAFT sale group, and the `analyzeP` result. Run:
  lake env lean --run eval/sale-group/Print.lean -/

def ctx : Render.Ctx := { ts := tS, tp := tP, rs := rS, rp := rP }

def main : IO Unit := do
  IO.println "== BẢNG TÌNH HUỐNG"
  for l in Render.table tS do IO.println l
  IO.println "== BẢNG THAM SỐ"
  for l in Render.table tP do IO.println l
  IO.println "== BỘ ĐỌC TÌNH HUỐNG"
  for l in Render.readers tS rS do IO.println l
  IO.println "== BỘ ĐỌC THAM SỐ"
  for l in Render.readers tP rP do IO.println l
  IO.println "== NORM"
  for n in norms do
    for l in ctx.norm n do IO.println l
  IO.println "== CHƯA MÃ HÓA"
  for e in notEncoded do IO.println s!"{e.clause} ‖ {e.reason}"
  IO.println "== KẾT QUẢ analyzeP"
  match analyzeP tS tP rS rP catalog norms with
  | .invalid fs => IO.println s!"invalid {repr fs}"
  | .conflicts hs sc => IO.println s!"conflicts {hs.length}: {repr sc}"
  | .consistentOn sc => IO.println s!"consistentOn {repr sc}"
  IO.println s!"findings: {repr (pfindings tS tP rS rP catalog norms)}"
  IO.println s!"catalog: {catalog.length} first={catalog.head?} last={catalog.getLast?}"
