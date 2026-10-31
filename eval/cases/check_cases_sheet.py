# -*- coding: utf-8 -*-
"""Checks docs/review/sale-group-cases.md: (1) every quoted clause equals the lines of the extracted file;
(2) the sheet for the human shows no answer: none of the answer words, no kind, no note."""
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sale-group"))
from common import *      # noqa

md = io.open(os.path.join(ROOT, "docs", "review", "sale-group-cases.md"), encoding="utf-8").read()
pat = re.compile(r"«([^«»]+)»<br>\(dòng (\d+)(?:–(\d+))?\)")
n = bad = 0
for m in pat.finditer(md):
    q, a, b = m.group(1), int(m.group(2)), int(m.group(3) or m.group(2))
    n += 1
    if norm_ws(q) != norm_ws(text(a, b)):
        bad += 1
        print("MISMATCH lines %d-%d\n  sheet: %s\n  file : %s" % (a, b, q, norm_ws(text(a, b))))
leak = [w for w in ("forbidden", "noNormApplies", "explicitlyPermitted", "PASS", "FAIL", "Kỳ vọng", "kỳ vọng", "đối chứng", "ranh giới", "gần giống", "mã hóa cho", "Đáp án")
        if w in md]
print("clause quotes checked: %d, mismatched: %d; leaked words: %s" % (n, bad, leak))
sys.exit(1 if bad or leak or n == 0 else 0)
