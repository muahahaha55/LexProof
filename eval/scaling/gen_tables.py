# -*- coding: utf-8 -*-
import math, statistics, io
from collections import Counter
import scaling_model as M
from scaling_model import *

OUT = {}


def sfmt(fs):
    return ", ".join(sorted(fs, key=lambda x: (x[0] != "S", x)))


def dom(fs):
    d = 1
    for f in fs:
        d *= FACTS[f]
    return d


def pb(b):
    return ("%.2f" % b).replace(".", ",")


MOD = {O: "nghĩa vụ", F: "cấm", P: "cho phép"}
G4N = {"exc": "ngoại lệ", "perm": "cho phép"}

set_mode("enum", False)
VARS = [(g1, g4, c) for g1 in "ab" for g4 in ("exc", "perm") for c in (False, True)]
R = {v: analyse(*v) for v in VARS}

# ---------------------------------------------------------------- appendix A: norms (default variant)
N = build("a", "exc")
L = ["| # | Khoản | Loại | Act (mịn) | Fact/tham số đọc (điều kiện + ngoại lệ) | Bit |",
     "|---|---|---|---|---|---|"]
for i, n in enumerate(N, 1):
    L.append("| %d | %s | %s | `%s` | %s | %s |" % (i, n.clause, MOD[n.mod], n.act, sfmt(n.reads) or "—", pb(bits(n.reads))))
OUT["norms"] = "\n".join(L)

# ---------------------------------------------------------------- appendix B: all pairs, default variant
o = R[("a", "exc", False)]
L = ["| # | Cặp | Act | Loại | Fact/tham số trong F | Bit | Miền | IC chạm | Bit nếu giữ IC |",
     "|---|---|---|---|---|---|---|---|---|"]
rows = sorted(o["rows"], key=lambda r: (r["act"], -r["bF"]))
for i, r in enumerate(rows, 1):
    L.append("| %d | %s × %s | `%s` | %s/%s | %s | %s | %d | %s | %s |" % (
        i, r["n1"].id, r["n2"].id, r["act"], MOD[r["n1"].mod][0], MOD[r["n2"].mod][0],
        sfmt(r["F"]) or "—", pb(r["bF"]), dom(r["F"]), ", ".join(r["touch"]) or "—", pb(r["bC"])))
OUT["pairs"] = "\n".join(L)

# ---------------------------------------------------------------- per-act summary, default variant
byact = {}
for r in o["rows"]:
    byact.setdefault(r["act"], []).append(r)
L = ["| Act | Norm | Cặp | Bit nhỏ nhất | Trung vị | Bit lớn nhất | Cặp lớn nhất |", "|---|---|---|---|---|---|---|"]
for a, rs in sorted(byact.items(), key=lambda kv: -max(r["bF"] for r in kv[1])):
    nn = len({r["n1"].id for r in rs} | {r["n2"].id for r in rs})
    w = max(rs, key=lambda r: r["bF"])
    L.append("| `%s` | %d | %d | %s | %s | %s | %s × %s |" % (
        a, nn, len(rs), pb(min(r["bF"] for r in rs)),
        pb(statistics.median([r["bF"] for r in rs])), pb(w["bF"]), w["n1"].id, w["n2"].id))
OUT["groups"] = "\n".join(L)


def h(hh):
    return " / ".join(str(hh[k]) for k in BUCKETS)


# ---------------------------------------------------------------- matrix over 8 variants
L = ["| G1 | G4 | G7 | Norm | Cặp cùng act | Cặp `check` hiện tại duyệt | Chiếu theo cặp (≤12 / ≤14 / ≤16 / ≤20 / >20) | … khi giữ IC | Bit lớn nhất | Σ điểm (chiếu) |",
     "|---|---|---|---|---|---|---|---|---|---|"]
for v in VARS:
    o = R[v]
    L.append("| %s | %s | %s | %d | %d | %d | %s | %s | %s | %.3g |" % (
        v[0], G4N[v[1]], "thô" if v[2] else "mịn", o["norms"], o["same_act_pairs"], o["all_pairs"],
        h(o["hist_F"]), h(o["hist_C"]), pb(o["max_bF"]), o["sum_pts_F"]))
OUT["matrix"] = "\n".join(L)

# ---------------------------------------------------------------- baselines (current design) per variant
L = ["| G1 | G4 | G7 | Một S chung (bit/cặp · cặp duyệt · tổng điểm) | Mô-đun theo chủ đề (biểu đồ trên cặp cùng act · tổng điểm) | Mô-đun theo act (biểu đồ · tổng điểm) | Chiếu theo cặp (tổng điểm) |",
     "|---|---|---|---|---|---|---|"]
for v in VARS:
    o = R[v]
    L.append("| %s | %s | %s | %s b · %d · 2^%.1f | %s · 2^%.1f | %s · 2^%.1f | 2^%.1f |" % (
        v[0], G4N[v[1]], "thô" if v[2] else "mịn", pb(o["global_bits"]), o["all_pairs"],
        math.log2(o["global_pts_all_pairs"]), h(o["hist_mod_theme"]), math.log2(o["mod_theme_pts"]),
        h(o["hist_mod_act"]), math.log2(o["mod_act_pts"]), math.log2(o["sum_pts_F"])))
OUT["baseline"] = "\n".join(L)

o = R[("a", "exc", False)]
L = ["| Mô-đun | Norm | Bit của S và P của mô-đun | Cặp mà `check` duyệt | Cặp cùng act |", "|---|---|---|---|---|"]
for m, d in o["mod_theme"].items():
    if d["pairs"] == 0:
        continue
    same_n = sum(1 for r in o["rows"] if module_of_theme(r["n1"], False) == m)
    L.append("| `%s` | %d | %s | %d | %d |" % (m, d["n"], pb(d["bits"]), d["pairs"], same_n))
OUT["modules_theme"] = "\n".join(L)

# ---------------------------------------------------------------- opposed-pairs counts by class per variant
L = ["| G1 | G4 | G7 | Cặp đối nghịch modality | … cùng áp dụng được | có sẵn do xây dựng | hình thức hoặc dẫn chiếu × cấm | chéo (cho phép × cấm khác) | Không thể cùng áp dụng |",
     "|---|---|---|---|---|---|---|---|---|"]
for v in VARS:
    opp = R[v]["opp"]
    c = Counter((x["cls"], x["exact"]) for x in opp)
    co = sum(1 for x in opp if x["exact"])
    L.append("| %s | %s | %s | %d | %d | %d | %d | %d | %d |" % (
        v[0], G4N[v[1]], "thô" if v[2] else "mịn", len(opp), co,
        c[("by-construction", True)], c[("form-vs-ban", True)], c[("cross", True)], len(opp) - co))
OUT["opp_counts"] = "\n".join(L)

CLS = {"by-construction": "có sẵn do xây dựng", "form-vs-ban": "hình thức × cấm", "cross": "chéo"}


def listing(v):
    opp = R[v]["opp"]
    L = ["| Cặp | Act | Lớp | Cùng áp dụng được | Fact chung của hai norm |", "|---|---|---|---|---|"]
    for x in sorted(opp, key=lambda x: (x["cls"], x["r"]["n1"].id)):
        r = x["r"]
        shared = sorted(r["n1"].reads & r["n2"].reads)
        L.append("| %s (%s) × %s (%s) | `%s` | %s | %s | %s |" % (
            r["n1"].id, MOD[r["n1"].mod], r["n2"].id, MOD[r["n2"].mod], r["act"], CLS[x["cls"]],
            "có" if x["exact"] else "không", ", ".join(shared) or "không có"))
    return "\n".join(L)


OUT["opp_a_perm_fine"] = listing(("a", "perm", False))
OUT["opp_a_exc_coarse"] = listing(("a", "exc", True))

# ---------------------------------------------------------------- ICX sensitivity
set_mode("enum", True)
L = ["| G1 | G4 | G7 | Đối nghịch | Chính xác (giữ IC + hoàn tất) | Chiếu từng IC (∃ ngoài F) | Bỏ IC không nằm hẳn trong F | Bỏ mọi IC (`valid` mờ) |",
     "|---|---|---|---|---|---|---|---|"]
for v in VARS:
    oo = analyse(*v)
    opp = oo["opp"]
    if not opp:
        continue
    s = lambda k: sum(1 for x in opp if x[k])
    L.append("| %s | %s | %s | %d | %d | %d | %d | %d |" % (
        v[0], G4N[v[1]], "thô" if v[2] else "mịn", len(opp), s("exact"), s("eproj"), s("proj"), s("noic")))
OUT["icx"] = "\n".join(L)

# ---------------------------------------------------------------- threshold-as-Bool mode
set_mode("enum", False)
enum_max = {v: analyse(*v)["max_bF"] for v in VARS}
set_mode("bools", False)
L = ["| G1 | G4 | G7 | Đối nghịch | Chính xác | Bỏ mọi IC (`valid` mờ) | Cặp giả | Bit lớn nhất (Bool rời) | Bit lớn nhất (enum) |",
     "|---|---|---|---|---|---|---|---|---|"]
for v in VARS:
    oo = analyse(*v)
    opp = oo["opp"]
    if not opp:
        continue
    ex = sum(1 for x in opp if x["exact"])
    no = sum(1 for x in opp if x["noic"])
    L.append("| %s | %s | %s | %d | %d | %d | %d | %s | %s |" % (
        v[0], G4N[v[1]], "thô" if v[2] else "mịn", len(opp), ex, no, no - ex, pb(oo["max_bF"]), pb(enum_max[v])))
OUT["bools"] = "\n".join(L)
set_mode("enum", False)

# ---------------------------------------------------------------- ICs
L = ["| IC | Nội dung | Fact |", "|---|---|---|"]
for ic in BASE_ICS:
    L.append("| %s | %s | %s |" % (ic.id, ic.text.split("   (")[0], sfmt(ic.facts)))
OUT["ics"] = "\n".join(L)

for k, v in OUT.items():
    io.open("tab_%s.md" % k, "w", encoding="utf-8", newline="\n").write(v + "\n")
    print("wrote tab_%s.md (%d lines)" % (k, v.count("\n") + 1))
