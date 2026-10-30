import scaling_model as M
from scaling_model import *
print("%-26s %-18s | opposed | exact | eproj(per-IC exist.) | proj(drop non-inside) | noIC(valid opaque)" % ("mode", "variant"))
for (band, icx) in (("enum", False), ("bools", False), ("enum", True), ("bools", True)):
    set_mode(band, icx)
    for g1 in "ab":
        for g4 in ("exc", "perm"):
            for coarse in (False, True):
                o = analyse(g1, g4, coarse)
                opp = o["opp"]
                if not opp: continue
                s = lambda k: sum(1 for x in opp if x[k])
                tag = "band=%s icx=%d" % (band, icx)
                var = "G1=%s %s %s" % (g1, g4, "coarse" if coarse else "fine")
                print("%-26s %-18s | %7d | %5d | %20d | %21d | %d" % (tag, var, len(opp), s("exact"), s("eproj"), s("proj"), s("noic")))
set_mode("enum", False)
