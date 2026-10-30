import math
from collections import Counter
import scaling_model as M
from scaling_model import *

def summarize(tag, g1, g4, coarse):
    o = analyse(g1, g4, coarse)
    opp = o["opp"]
    ex = sum(1 for x in opp if x["exact"]); pr = sum(1 for x in opp if x["proj"]); no = sum(1 for x in opp if x["noic"])
    spurious_noic = [(x["r"]["n1"].id, x["r"]["n2"].id) for x in opp if x["noic"] and not x["exact"]]
    spurious_proj = [(x["r"]["n1"].id, x["r"]["n2"].id) for x in opp if x["proj"] and not x["exact"]]
    print("%-34s G1=%s G4=%-4s %-6s | pairs %3d maxbits %.2f hist(F) %s | opposed %3d  exact %3d proj %3d noIC %3d | spurious(noIC) %d  spurious(proj) %d" %
          (tag, g1, g4, "coarse" if coarse else "fine", o["same_act_pairs"], o["max_bF"],
           " ".join("%d" % o["hist_F"][k] for k in BUCKETS), len(opp), ex, pr, no, len(spurious_noic), len(spurious_proj)))
    return o, spurious_noic, spurious_proj

for (band, icx) in (("enum", False), ("bools", False), ("enum", True), ("bools", True)):
    set_mode(band, icx)
    print("\n##### MODE band=%s icx=%s | ICs: %s" % (band, icx, [ic.id for ic in ICS]))
    for g1 in "ab":
        for g4 in ("exc", "perm"):
            for coarse in (False, True):
                o, sn, sp = summarize("band=%s icx=%s" % (band, icx), g1, g4, coarse)
                if sn and band == "bools":
                    print("      spurious under noIC:", sn[:8], "..." if len(sn) > 8 else "")
set_mode("enum", False)
