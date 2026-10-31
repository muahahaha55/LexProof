# -*- coding: utf-8 -*-
"""Writes LexProof/Laws/AlcoholSaleCases.lean from eval/cases/cases_draft.py.
usage: python gen_cases_lean.py [PASS_IDS_COMMA_SEPARATED]   (second phase adds the kernel-checked pass set)"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "sale-group"))
sys.path.insert(0, HERE)
from common import ENCODED, ROOT       # noqa
from cases_draft import CASES          # noqa

LABEL = {k: lab for k, lab, a, b in ENCODED}
KIND = {"positive": ".positive", "negativeControl": ".negativeControl", "boundary": ".boundary", "exception": ".exception"}


def s(x):
    assert '"' not in x and "\\" not in x, x
    return '"' + x + '"'


def pairs(d):
    return "[" + ", ".join("(%s, %s)" % (s(k), s(v)) for k, v in d.items()) + "]"


def case(c):
    return ("  { id := %s, description := %s,\n    situation := %s,\n    params := %s,\n    act := %s, expected := .%s,\n"
            "    clause := %s, quote := %s,\n    kind := %s, confidence := .%s,\n    note := %s }") % (
        s(c["id"]), s(c["description"]), pairs(c["situation"]), pairs(c["params"]), s(c["act"]), c["expected"],
        s(LABEL[c["clause"]]), s(c["quote"]), KIND[c["kind"]], c["confidence"], s(c["note"]))


pass_ids = sys.argv[1].split(",") if len(sys.argv) > 1 and sys.argv[1] else None
out = ['''import LexProof.Laws.AlcoholSale
import LexProof.Verify.Cases

/-!
# DRAFT, NOT HUMAN-REVIEWED — concrete cases for `Laws/AlcoholSale.lean`

Situations written **from the verbatim clauses** of `data/extracted/44-2019-QH14.txt` (the list was recorded in
`eval/cases/RECORD.md` before it was run against the encoding), each with the status a reader of the clause
expects. The expectations were not edited after running. Generated from `eval/cases/cases_draft.py` by
`eval/cases/gen_cases_lean.py`; the human-facing sheet is `docs/review/sale-group-cases.md`.

**Read the limits.** The cases, the encoding and this file come from the same author and the same reading of
the law; a passing case shows the encoding agrees with the author, not with the law. `noNormApplies` is never
a claim that an act is lawful. Cases that do not pass are listed by `notPassingNow` at run time; the kernel
checks exactly which cases pass (`pass_set`).
-/

namespace LexProof.Laws.AlcoholSaleCases

open LexProof LexProof.Laws.AlcoholSale

def cases : List Case :=
  [
''']
out.append(",\n".join(case(c) for c in CASES))
out.append('''
  ]

/-- Every case run against the encoding. -/
def results : List CaseResult := cases.map (runCase tS tP rS rP norms)

/-- Runtime listing of the cases that do not pass. -/
def notPassingNow : List CaseResult := notPassing tS tP rS rP norms cases

def passing : List String := passIds tS tP rS rP norms cases
''')
if pass_ids is not None:
    out.append('''
/-- The kernel checks exactly which cases pass. A case added later that does not pass, or a change to the
encoding that breaks a case, makes this fail until the list is reviewed. -/
theorem pass_set :
    passing = [%s] := by
  decide +kernel
''' % ", ".join(s(i) for i in pass_ids))
out.append("\nend LexProof.Laws.AlcoholSaleCases\n")
open(os.path.join(ROOT, "LexProof", "Laws", "AlcoholSaleCases.lean"), "w", encoding="utf-8", newline="\n").write("".join(out))
print("written; cases:", len(CASES), "pass_set:", None if pass_ids is None else len(pass_ids))
