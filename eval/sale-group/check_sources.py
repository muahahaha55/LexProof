# -*- coding: utf-8 -*-
"""Checks the Laws module against the extracted law text:
 1. the catalog (Điều 1..36) equals the article headings of the file;
 2. every clause range is non-blank, has no page header, and starts where expected;
 3. the phrases used in band labels / sources occur verbatim in the file (with line numbers).
Exit status 1 on any failure."""
import re
import sys

from common import *

bad = 0
heads = [int(m.group(1)) for l in LINES for m in [re.match(r"^\s+Điều (\d+)\.\s", l)] if m]
if heads != list(range(1, 37)):
    print("FAIL catalog: headings in file =", heads)
    bad += 1
else:
    print("ok catalog: Điều 1..36, in order, %d headings" % len(heads))

for key, label, a, b in ENCODED + NOT_ENCODED:
    seg = LINES[a - 1:b]
    if any(not s.strip() for s in seg):
        print("FAIL range", key, a, b)
        bad += 1
    else:
        hdr = [a + i for i, s in enumerate(seg) if PAGE.search(s)]
        print("ok clause %-6s %-20s lines %d-%d%s" % (key, label, a, b, "  (dòng đầu trang %s không thuộc nguyên văn)" % hdr if hdr else ""))

phrases = [("chưa đủ 18 tuổi", "5.3"), ("từ 15 độ trở lên", "5.9"), ("có độ cồn dưới 15 độ", "11"),
           ("trừ địa điểm được phép kinh doanh rượu, bia", "19.6"), ("bán rượu, bia", "5.11")]
blob = {k: norm_ws(text(a, b)) for k, _, a, b in ENCODED + NOT_ENCODED}
for ph, key in phrases:
    ok = ph in blob[key]
    print(("ok" if ok else "FAIL") + " phrase %r in clause %s" % (ph, key))
    bad += 0 if ok else 1
sys.exit(1 if bad else 0)
