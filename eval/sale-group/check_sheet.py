# -*- coding: utf-8 -*-
"""Verifies the «Nguyên văn» cells of docs/review/sale-group-review.md against
data/extracted/44-2019-QH14.txt: for every quote «…»<br>(dòng a–b ...) the quoted text must equal
the file's lines a..b (running page headers dropped, whitespace normalised), or - only when the
cell says "phần trước dấu chấm phẩy" - be the part of it before the first ';'. Exit 1 on failure."""
import sys

from common import *

SHEET = os.path.join(ROOT, "docs", "review", "sale-group-review.md")
md = io.open(SHEET, encoding="utf-8").read()
pat = re.compile(r"«(.+?)»<br>\(dòng (\d+)(?:–(\d+))?([^)]*)\)")
n = bad = 0
for m in pat.finditer(md):
    q, a, b, rest = m.group(1), int(m.group(2)), int(m.group(3) or m.group(2)), m.group(4)
    n += 1
    ref = norm_ws(text(a, b))
    if norm_ws(q) == ref:
        ok = True
    elif "phần trước dấu chấm phẩy" in rest and norm_ws(q) == norm_ws(ref.split(";")[0]):
        ok = True
    else:
        ok = False
    if not ok:
        bad += 1
        print("MISMATCH lines %d-%d\n  sheet: %s\n  file : %s" % (a, b, q, ref))
print("quotes checked: %d, mismatched: %d" % (n, bad))
sys.exit(1 if bad or n == 0 else 0)
