# -*- coding: utf-8 -*-
"""POST-HOC (added after seeing the mutation results; see docs/mutation-posthoc-analyzereport.md).

Runs the SAME mutants through `analyzeReport` and prints its non-core fields. Reuses the mutant data of
gen_mutants.emit_lean; only the `main` differs. Writes ReportRun.lean (scratch, not part of the library).
"""
import os

import gen_mutants as G

HERE = os.path.dirname(os.path.abspath(__file__))
TMP = os.path.join(HERE, "_tmp_run.lean")
G.emit_lean(G.generate(), TMP)
text = open(TMP, encoding="utf-8").read()
os.remove(TMP)
text = text.replace("import LexProof.Verify.AnalyzeProjected\n",
                    "import LexProof.Verify.AnalyzeProjected\nimport LexProof.Verify.AnalyzeReport\n", 1)
text = text[:text.index("def main : IO Unit := do")]
text += '''
/-- The act catalog a caller would supply for this module: the five acts of the group (slice1-notes, section C). -/
def actCat : List Act :=
  ["ban_ruou_bia", "cung_cap_ruou_bia", "khuyen_mai_ruou_bia", "dung_ruou_bia_lam_qua_khuyen_mai",
   "ban_ruou_bia_bang_may_tu_dong"]

def reportLine (m : Mut) : String :=
  let r := analyzeReport .draft actCat m.ts m.tp m.rs m.rp catalog m.norms
  let acts := ";".intercalate (r.acts.map fun a =>
    s!"{a.act}:{a.normCount}:{a.hasObligation}:{a.hasProhibition}:{a.hasPermission}:{a.hasClash}")
  let res := ",".intercalate (r.resolutions.map fun x => s!"{x.winner}>{x.loser}")
  let fnd := ",".intercalate (r.actFindings.map fun f =>
    match f with
    | .unknownAct n a => s!"{n}:{a}")
  "\\t".intercalate [m.id, toString r.noModalityClash, acts, res, ",".intercalate r.singleUseActs,
    ",".intercalate r.unusedCatalogActs, fnd,
    toString (decide (r.core = analyzeP m.ts m.tp m.rs m.rp catalog m.norms))]

def main : IO Unit := do
  for m in muts do
    IO.println (reportLine m)
'''
open(os.path.join(HERE, "ReportRun.lean"), "w", encoding="utf-8", newline="\n").write(text)
print("ReportRun.lean written")
