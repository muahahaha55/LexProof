# -*- coding: utf-8 -*-
"""Every case quote must be a verbatim substring of its clause in data/extracted/44-2019-QH14.txt."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "sale-group"))
from common import *            # noqa
from cases_draft import CASES

key = {k: (a, b) for k, _, a, b in ENCODED}
bad = 0
for c_ in CASES:
    a, b = key[c_["clause"]]
    ok = norm_ws(c_["quote"]) in norm_ws(text(a, b))
    if not ok:
        bad += 1
        print("NOT VERBATIM", c_["id"], c_["quote"])
print("cases: %d, quotes not verbatim: %d" % (len(CASES), bad))
sys.exit(1 if bad else 0)
