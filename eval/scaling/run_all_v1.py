import math
from scaling_model_v1 import *

def fmt(h): return " ".join("%s:%d" % (k, h[k]) for k in BUCKETS)
res = {}
for g1 in "ab":
    for g4 in ("exc", "perm"):
        for coarse in (False, True):
            o = analyse(g1, g4, coarse)
            res[(g1, g4, coarse)] = o
            tag = "G1=%s G4=%-4s G7=%s" % (g1, g4, "coarse" if coarse else "fine  ")
            print("=" * 100)
            print(tag, "| norms", o["norms"], "| all pairs", o["all_pairs"], "| same-act pairs", o["same_act_pairs"])
            print("  per-pair projection   hist(F):", fmt(o["hist_F"]), "| max bits %.2f" % o["max_bF"],
                  "| sum pts %.3g" % o["sum_pts_F"])
            print("  per-pair + IC closure hist(C):", fmt(o["hist_C"]))
            print("  current design, ONE global S : bits %.2f, pairs enumerated %d, points %.3g (2^%.1f)" %
                  (o["global_bits"], o["all_pairs"], o["global_pts_all_pairs"], math.log2(o["global_pts_all_pairs"])))
            for t in ("theme", "act"):
                print("  current design, modules by %-5s: hist per same-act pair:" % t, fmt(o["hist_mod_" + t]),
                      "| points %.3g (2^%.1f)" % (o["mod_%s_pts" % t], math.log2(o["mod_%s_pts" % t])))
                print("     ", {m: (d["n"], round(d["bits"], 2), d["pairs"]) for m, d in o["mod_" + t].items() if d["pairs"] > 0})
            opp = o["opp"]
            from collections import Counter
            c = Counter((x["cls"], x["exact"]) for x in opp)
            print("  opposed pairs:", len(opp), "| by class/co-applicable(exact):", dict(c))
            print("     co-applicable if ICs dropped (F only, no IC):", sum(1 for x in opp if x["noic"]),
                  "| projection(inside ICs):", sum(1 for x in opp if x["proj"]),
                  "| exact:", sum(1 for x in opp if x["exact"]))
            flips = [(x["r"]["n1"].id, x["r"]["n2"].id) for x in opp if x["proj"] and not x["exact"]]
            print("     pairs where projection over-approximates exact:", flips)
