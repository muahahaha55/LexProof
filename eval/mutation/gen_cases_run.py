# -*- coding: utf-8 -*-
"""POST-HOC (optional part 4). Runs every mutant of the mutation experiment through the case runner of
LexProof/Verify/Cases.lean with the cases of LexProof/Laws/AlcoholSaleCases.lean. Writes CasesRun.lean (scratch)."""
import os

import gen_mutants as G

HERE = os.path.dirname(os.path.abspath(__file__))
TMP = os.path.join(HERE, "_tmp_run.lean")
G.emit_lean(G.generate(), TMP)
text = open(TMP, encoding="utf-8").read()
os.remove(TMP)
text = text.replace("import LexProof.Verify.AnalyzeProjected\n",
                    "import LexProof.Verify.AnalyzeProjected\nimport LexProof.Verify.Cases\nimport LexProof.Laws.AlcoholSaleCases\n", 1)
text = text[:text.index("def main : IO Unit := do")]
text += '''
def tok (r : CaseResult) : String :=
  match r.outcome with
  | .pass => s!"{r.id}:pass"
  | .fail _ => s!"{r.id}:fail"
  | .underspecified _ => s!"{r.id}:under"
  | .malformed _ => s!"{r.id}:malformed"

def caseLine (m : Mut) : String :=
  let rs := LexProof.Laws.AlcoholSaleCases.cases.map (runCase m.ts m.tp m.rs m.rp m.norms)
  "\t".intercalate [m.id, ",".intercalate (rs.map tok)]

def main : IO Unit := do
  for m in muts do
    IO.println (caseLine m)
'''
open(os.path.join(HERE, "CasesRun.lean"), "w", encoding="utf-8", newline="\n").write(text)
print("CasesRun.lean written")
