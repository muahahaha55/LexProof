# -*- coding: utf-8 -*-
"""Do the bands of each threshold group meet exactly (no gap, no overlap)?

The Lean checker does NOT check this: a band is a label. Here the intervals are declared by
hand from the clause that fixes each end; the script checks (1) the labels are the ones in
LexProof/Laws/AlcoholSale.lean, (2) the phrase quoted for each end occurs in the extracted law
(with line numbers), (3) consecutive bands touch with exactly one inclusive end.
Exit status 1 on failure."""
import os
import sys
from fractions import Fraction as F

from common import *

LEAN = os.path.join(ROOT, "LexProof", "Laws", "AlcoholSale.lean")
lean = io.open(LEAN, encoding="utf-8").read()

INF = None
# group: list of (label, lo, lo_inclusive, hi, hi_inclusive, [(end, clause key, quoted phrase)])
GROUPS = {
    "S02 độ cồn (đơn vị: độ = % thể tích, Điều 2 khoản 4)": [
        ("dưới 15 độ", F(0), True, F(15), False,
         [("hi", "11", "có độ cồn dưới 15 độ")]),
        ("từ 15 độ trở lên", F(15), True, F(100), True,
         [("lo", "5.9", "có độ cồn từ 15 độ trở lên")]),
    ],
    "S04 tuổi của người nhận (năm)": [
        ("chưa đủ 18 tuổi", F(0), True, F(18), False,
         [("hi", "5.3", "người chưa đủ 18 tuổi")]),
        ("từ đủ 18 tuổi trở lên", F(18), True, INF, True,
         []),   # no clause states this band: complement
    ],
}

key_range = {k: (a, b) for k, _, a, b in ENCODED + NOT_ENCODED}
bad = 0
for g, bands in GROUPS.items():
    print("==", g)
    for i, (lab, lo, loi, hi, hii, ends) in enumerate(bands):
        in_lean = ('"%s"' % lab) in lean
        print("  band %-24s %s%s, %s%s   label in Lean: %s" % (
            lab, "[" if loi else "(", lo, ("∞" if hi is None else hi), ")" if not hii or hi is None else "]",
            "yes" if in_lean else "NO"))
        bad += 0 if in_lean else 1
        for end, key, ph in ends:
            a, b = key_range[key]
            seg = norm_ws(text(a, b))
            found = ph in seg
            where = [a + j for j, l in enumerate(LINES[a - 1:b]) if ph.split(" ")[-1] in l]
            print("     %s end fixed by clause %s (lines %d-%d): %r -> %s" % (end, key, a, b, ph, "found" if found else "NOT FOUND"))
            bad += 0 if found else 1
        if not ends:
            print("     (no clause states this band; it is the complement of the previous one)")
    for x, y in zip(bands, bands[1:]):
        touch = x[3] is not None and x[3] == y[1] and (x[4] != y[2])
        gap = x[3] is not None and x[3] < y[1]
        ovl = x[3] is not None and (x[3] > y[1] or (x[3] == y[1] and x[4] and y[2]))
        print("  %r | %r : meet exactly = %s, gap = %s, overlap = %s" % (x[0], y[0], touch, gap, ovl))
        bad += 0 if touch and not gap and not ovl else 1
sys.exit(1 if bad else 0)
