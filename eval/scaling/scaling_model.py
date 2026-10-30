# -*- coding: utf-8 -*-
"""
Paper model for docs/scaling-analysis.md.  NOT part of the repository.

The norm table below is HAND-AUTHORED from docs/slice1-notes.md (B1, B2, C).
It is a model of how an encoder might read each clause, not the law.
Nothing here is Lean.
"""
import itertools, math, sys, json

# ---------------------------------------------------------------- vocabulary
FACTS = {"S01": 2, "S02": 3, "S07": 4}
for i in list(range(3, 7)) + list(range(8, 33)):
    FACTS["S%02d" % i] = 2
for i in range(1, 14):
    FACTS["P%02d" % i] = 2
assert sum(1 for k, v in FACTS.items() if k.startswith("S") and v == 2 and k != "S01") == 29
assert len([k for k in FACTS if k.startswith("S")]) == 32
assert len([k for k in FACTS if k.startswith("P")]) == 13

RUOU, BIA = 0, 1
LOW, MID, HIGH = 0, 1, 2
O, F, P = "O", "F", "P"          # obligation, prohibition, permission


def incompatible(a, b):
    return (a, b) in {(O, F), (F, O), (P, F), (F, P)}


def bits(fs):
    return sum(math.log2(FACTS[f]) for f in fs)


MODE = {"band": "enum", "icx": False}


def set_mode(band="enum", icx=False):
    """band='enum'  : one enum field S02 with 3 disjoint bands
       band='bools' : two threshold Bools B55 (>=5.5) and B15 (>=15), needs IC  B15 -> B55
       icx=True     : add a medium-exclusivity IC over S23..S26 (sensitivity run)"""
    MODE["band"], MODE["icx"] = band, icx
    for k in ("S02", "B55", "B15"):
        FACTS.pop(k, None)
    if band == "enum":
        FACTS["S02"] = 3
    else:
        FACTS["B55"] = 2
        FACTS["B15"] = 2
    ICS[:] = BASE_ICS[:]
    if band == "bools":
        ICS.append(IC("IC_B", "B15 -> B55   (>=15 implies >=5.5)", ["B15", "B55"],
                      lambda e: (not e["B15"]) or e["B55"]))
    if icx:
        ICS.append(IC("ICX", "at most one of S23,S24,S25,S26 (an ad sits on one medium)",
                      ["S23", "S24", "S25", "S26"],
                      lambda e: sum(1 for k in ("S23", "S24", "S25", "S26") if e[k]) <= 1))


def bk(kind):
    """band condition: returns (reads, fn)"""
    if MODE["band"] == "enum":
        return {"LOW": (["S02"], lambda e: e["S02"] == LOW),
                "MID": (["S02"], lambda e: e["S02"] == MID),
                "HIGH": (["S02"], lambda e: e["S02"] == HIGH),
                "B13": (["S01", "S02"], lambda e: (e["S01"] == RUOU and e["S02"] == MID) or
                        (e["S01"] == BIA and e["S02"] >= MID))}[kind]
    return {"LOW": (["B55"], lambda e: not e["B55"]),
            "MID": (["B55", "B15"], lambda e: e["B55"] and not e["B15"]),
            "HIGH": (["B15"], lambda e: e["B15"]),
            "B13": (["S01", "B55", "B15"], lambda e: (e["S01"] == RUOU and e["B55"] and not e["B15"]) or
                    (e["S01"] == BIA and e["B55"]))}[kind]


def band13(e):
    return bk("B13")[1](e)


# ---------------------------------------------------------------- norm model
class Norm:
    def __init__(self, nid, clause, mod, act, reads, cond, exc=None,
                 derived_from=None, kind="substantive"):
        self.id, self.clause, self.mod, self.act = nid, clause, mod, act
        self.reads = frozenset(reads)
        self.cond, self.exc = cond, exc
        self.derived_from = derived_from
        self.kind = kind            # substantive | form | meta | authority

    def applies(self, e):
        if not self.cond(e):
            return False
        return not (self.exc(e) if self.exc else False)


COARSE = {}
for a in ("ban", "cung_cap", "khuyen_mai", "ban_may", "dung_lam_qua"):
    COARSE[a] = "cung_ung"
for a in ("qc_15", "qc_noi_dung_cam", "qc_o_noi", "canh_bao", "chan_loc", "tuan_thu"):
    COARSE[a] = "quang_cao"


def act_of(n, coarse):
    return COARSE.get(n.act, n.act) if coarse else n.act


def build(g1, g4):
    """g1: 'a' (Dieu 12 applies to every band) | 'b' (Dieu 12 only < 5.5, copies for Dieu 13 bands)
       g4: 'exc' (exceptions stay exceptions) | 'perm' (each exception also written as a permission)"""
    N = []
    A = N.append
    tt = lambda e: True

    # ---------------- Dieu 5 (prohibitions; act = fine id from section C)
    A(Norm("5.1", "5.1", F, "xui_giuc", [], tt))
    A(Norm("5.2", "5.2", F, "uong", ["S03"], lambda e: e["S03"]))
    A(Norm("5.3a", "5.3", F, "ban", ["S04"], lambda e: e["S04"]))
    A(Norm("5.3b", "5.3", F, "cung_cap", ["S04"], lambda e: e["S04"]))
    A(Norm("5.3c", "5.3", F, "khuyen_mai", ["S04"], lambda e: e["S04"]))
    A(Norm("5.4", "5.4", F, "lao_dong", ["S05", "P02"], lambda e: e["S05"] and e["P02"]))
    A(Norm("5.5", "5.5", F, "uong", ["S06", "S07", "P01"],
           lambda e: e["S06"] and (e["S07"] in (1, 2) or (e["S07"] == 0 and e["P01"]))))
    A(Norm("5.6", "5.6", F, "dieu_khien", ["S08", "S09"], lambda e: e["S08"] and e["S09"]))
    hr, hf = bk("HIGH")
    A(Norm("5.7", "5.7", F, "qc_15", ["S01"] + hr, lambda e: e["S01"] == RUOU and hf(e)))
    A(Norm("5.8", "5.8", F, "tin_sai", ["P03"], lambda e: e["P03"]))
    A(Norm("5.9a", "5.9", F, "khuyen_mai", hr, hf))
    A(Norm("5.9b", "5.9", F, "dung_lam_qua", hr, hf))
    A(Norm("5.10", "5.10", F, "nguyen_lieu", ["P04", "P05", "P06"],
           lambda e: e["P06"] or (e["P04"] and e["P05"])))
    A(Norm("5.11a", "5.11", F, "kd_khong_phep", ["S01", "S10", "S11"],
           lambda e: e["S01"] == RUOU and (e["S10"] or e["S11"])))
    A(Norm("5.11b", "5.11", F, "ban_may", [], tt))
    A(Norm("5.12a", "5.12", F, "kd_hang_cam", ["S12", "S13", "P04", "P05"],
           lambda e: e["S12"] or e["S13"] or e["P04"] or e["P05"]))
    A(Norm("5.12b", "5.12", F, "nhap_lau", [], tt))
    A(Norm("5.13", "5.13", F, "cam_khac", [], tt))

    # ---------------- Dieu 10 (prohibitions on drinking)
    A(Norm("10.1", "10.1", F, "uong", ["S14"], lambda e: e["S14"]))
    A(Norm("10.2", "10.2", F, "uong", ["S15", "S21"], lambda e: e["S15"] and e["S21"]))
    A(Norm("10.3", "10.3", F, "uong", ["S16"], lambda e: e["S16"]))
    A(Norm("10.4", "10.4", F, "uong", ["S17"], lambda e: e["S17"]))
    A(Norm("10.5", "10.5", F, "uong", ["S18"], lambda e: e["S18"]))
    A(Norm("10.7", "10.7", F, "uong", ["P07"], lambda e: e["P07"]))
    # 10.6 and 19.6 : exception vs permission
    c106 = lambda e: e["S19"] and e["S22"]
    if g4 == "exc":
        A(Norm("10.6", "10.6", F, "uong", ["S19", "S22", "S20"], c106, lambda e: e["S20"]))
    else:
        A(Norm("10.6", "10.6", F, "uong", ["S19", "S22"], c106))
        A(Norm("10.6P", "10.6", P, "uong", ["S19", "S22", "S20"],
               lambda e: c106(e) and e["S20"], derived_from="10.6"))

    # ---------------- Dieu 19 (prohibitions on selling)
    A(Norm("19.1", "19.1", F, "ban", ["S14"], lambda e: e["S14"]))
    A(Norm("19.2", "19.2", F, "ban", ["S15"], lambda e: e["S15"]))
    A(Norm("19.3", "19.3", F, "ban", ["S16"], lambda e: e["S16"]))
    A(Norm("19.4", "19.4", F, "ban", ["S17"], lambda e: e["S17"]))
    A(Norm("19.5", "19.5", F, "ban", ["S18"], lambda e: e["S18"]))
    c196 = lambda e: e["S19"]
    if g4 == "exc":
        A(Norm("19.6", "19.6", F, "ban", ["S19", "S20"], c196, lambda e: e["S20"]))
    else:
        A(Norm("19.6", "19.6", F, "ban", ["S19"], c196))
        A(Norm("19.6P", "19.6", P, "ban", ["S19", "S20"],
               lambda e: c196(e) and e["S20"], derived_from="19.6"))

    # ---------------- Dieu 12 : advertising bodies, optionally band-conditioned
    # (id, mod, act, reads, cond, exc(reads, fn), kind)
    base12 = [
        ("12.1", O, "tuan_thu", [], tt, None, "meta"),
        ("12.2a", F, "qc_noi_dung_cam", ["P08", "P09", "P10"],
         lambda e: e["P08"] or e["P09"] or e["P10"], None, "substantive"),
        ("12.2b", F, "qc_noi_dung_cam", ["P11", "S32"],
         lambda e: e["P11"] or e["S32"], None, "substantive"),
        ("12.3a", F, "qc_o_noi", ["P11"], lambda e: e["P11"], None, "substantive"),
        ("12.3b", F, "qc_o_noi", ["S23"], lambda e: e["S23"], None, "substantive"),
        ("12.3c", F, "qc_o_noi", ["S24", "S29", "P11", "S30"],
         lambda e: e["S24"] and ((e["S29"] and e["P11"]) or e["S30"]),
         (["S31", "P13"], lambda e: e["S31"] or e["P13"]), "substantive"),
        ("12.3d", F, "qc_o_noi", ["S25", "P12"], lambda e: e["S25"] and e["P12"], None, "substantive"),
        ("12.4", O, "canh_bao", [], tt, None, "form"),
        ("12.5", O, "chan_loc", ["S26"], lambda e: e["S26"], None, "form"),
    ]

    def emit(suffix, bandreads, bandfn):
        for (nid, mod, act, reads, cond, exc, kind) in base12:
            if suffix == "'" and nid == "12.1":
                continue                     # 13.0 plays the role of the copy of 12.1
            r = list(reads) + list(bandreads)
            c = (lambda cond=cond, bandfn=bandfn: (lambda e: cond(e) and bandfn(e)))()
            if exc is None:
                A(Norm(nid + suffix, nid.split(".")[0] + "." + nid.split(".")[1][0:1], mod, act, r, c, kind=kind))
            else:
                er, ef = exc
                if g4 == "exc":
                    A(Norm(nid + suffix, nid, mod, act, r + er, c, ef, kind=kind))
                else:
                    A(Norm(nid + suffix, nid, mod, act, r, c, kind=kind))
                    A(Norm(nid + suffix + "P", nid, P, act, r + er,
                           (lambda c=c, ef=ef: (lambda e: c(e) and ef(e)))(),
                           derived_from=nid + suffix))

    if g1 == "a":
        emit("", [], lambda e: True)
    else:
        lr, lf = bk("LOW")
        br, bf = bk("B13")
        emit("", lr, lf)
        emit("'", br, bf)

    # 12.6 authority
    A(Norm("12.6", "12.6", O, "chinh_phu", [], tt, kind="authority"))

    # ---------------- Dieu 13
    br, bf = bk("B13")
    A(Norm("13.0", "13", O, "tuan_thu", br, bf, kind="meta"))
    A(Norm("13.1", "13.1", F, "qc_o_noi", br + ["S27"],
           lambda e: bf(e) and e["S27"]))
    c132 = lambda e: bf(e) and e["S25"]
    if g4 == "exc":
        A(Norm("13.2", "13.2", F, "qc_o_noi", br + ["S25", "S28"], c132, lambda e: e["S28"]))
    else:
        A(Norm("13.2", "13.2", F, "qc_o_noi", br + ["S25"], c132))
        A(Norm("13.2P", "13.2", P, "qc_o_noi", br + ["S25", "S28"],
               lambda e: c132(e) and e["S28"], derived_from="13.2"))
    return N


# ---------------------------------------------------------------- integrity constraints
class IC:
    def __init__(self, iid, text, facts, fn):
        self.id, self.text, self.facts, self.fn = iid, text, frozenset(facts), fn


BASE_ICS = [
    IC("IC1", "S31 -> S24 and S27   (ad inside a sports programme is on broadcast media and in a sports programme)",
       ["S31", "S24", "S27"], lambda e: (not e["S31"]) or (e["S24"] and e["S27"])),
    IC("IC2", "S28 -> S25           (a shop sign is an outdoor medium)",
       ["S28", "S25"], lambda e: (not e["S28"]) or e["S25"]),
    IC("IC3", "S29 -> S24           (before/during/after a children's programme: broadcast media)",
       ["S29", "S24"], lambda e: (not e["S29"]) or e["S24"]),
    IC("IC4", "S06 and S22 -> S07 in {trong gio, nghi giua gio}   (staff drinking in working time)",
       ["S06", "S22", "S07"], lambda e: (not (e["S06"] and e["S22"])) or e["S07"] in (1, 2)),
]
ICS = BASE_ICS[:]


# ---------------------------------------------------------------- helpers
class Env(dict):
    def __init__(self, d, allowed):
        super().__init__(d)
        self._allowed = allowed

    def __getitem__(self, k):
        if k not in self._allowed:
            raise KeyError("UNDECLARED READ " + k)
        return dict.__getitem__(self, k)


def points(fs):
    fs = sorted(fs)
    for vals in itertools.product(*[range(FACTS[f]) for f in fs]):
        yield dict(zip(fs, vals))


def check_reads(N):
    """declared reads must (1) cover every actual read, (2) each really matters"""
    problems = []
    for n in N:
        fs = sorted(n.reads)
        pts = list(points(fs))
        try:
            outcome = {}
            for p in pts:
                outcome[tuple(sorted(p.items()))] = n.applies(Env(p, n.reads))
        except KeyError as ex:
            problems.append((n.id, str(ex)))
            continue
        for f in fs:
            matter = False
            for p in pts:
                for v in range(FACTS[f]):
                    if v == p[f]:
                        continue
                    q = dict(p)
                    q[f] = v
                    if outcome[tuple(sorted(p.items()))] != outcome[tuple(sorted(q.items()))]:
                        matter = True
                        break
                if matter:
                    break
            if not matter:
                problems.append((n.id, "declared but irrelevant: " + f))
    return problems


def co_applies(n1, n2, fs, ics):
    for p in points(fs):
        if all(ic.fn(p) for ic in ics) and n1.applies(p) and n2.applies(p):
            return True
    return False


def group_pairs(N, coarse):
    groups = {}
    for n in N:
        groups.setdefault(act_of(n, coarse), []).append(n)
    pairs = []
    for a, ns in groups.items():
        for i in range(len(ns)):
            for j in range(i + 1, len(ns)):
                pairs.append((a, ns[i], ns[j]))
    return groups, pairs


THRESH = [12, 14, 16, 20]


def bucket(b):
    for t in THRESH:
        if b <= t + 1e-9:
            return "<=%d" % t
    return ">20"


BUCKETS = ["<=12", "<=14", "<=16", "<=20", ">20"]


def hist(values):
    h = {k: 0 for k in BUCKETS}
    for v in values:
        h[bucket(v)] += 1
    return h


MODULES_THEME = {          # as in slice1-notes B3: drinking / selling / advertising
    "uong": "M_uong", "ban": "M_ban", "khuyen_mai": "M_km",
}
AD_ACTS = {"qc_15", "qc_noi_dung_cam", "qc_o_noi", "canh_bao", "chan_loc", "tuan_thu"}


def module_of_theme(n, coarse):
    a = n.act
    if coarse:
        a = COARSE.get(a, a)
        if a == "cung_ung":
            return "M_cung_ung"
        if a == "quang_cao":
            return "M_qc"
        return MODULES_THEME.get(a, "M_" + a)
    if a in AD_ACTS:
        return "M_qc"
    return MODULES_THEME.get(a, "M_" + a)


def module_bits(N, keyfn):
    mods = {}
    for n in N:
        mods.setdefault(keyfn(n), []).append(n)
    return mods, {m: bits(set().union(*[x.reads for x in ns])) for m, ns in mods.items()}


def analyse(g1, g4, coarse, detail=False):
    N = build(g1, g4)
    probs = check_reads(N)
    groups, pairs = group_pairs(N, coarse)
    out = {"g1": g1, "g4": g4, "coarse": coarse, "norms": len(N), "probs": probs,
           "all_pairs": len(N) * (len(N) - 1) // 2, "same_act_pairs": len(pairs)}
    rows = []
    for a, n1, n2 in pairs:
        F_ = n1.reads | n2.reads
        touch = [ic for ic in ICS if ic.facts & F_]
        clos = set(F_)
        while True:                       # transitive closure through chained ICs
            more = [ic for ic in ICS if ic.facts & clos]
            new_clos = set(clos)
            for ic in more:
                new_clos |= ic.facts
            if new_clos == clos:
                break
            clos = new_clos
        inside = [ic for ic in touch if ic.facts <= F_]
        rows.append(dict(act=a, n1=n1, n2=n2, F=F_, bF=bits(F_), clos=clos, bC=bits(clos),
                         touch=[ic.id for ic in touch], inside=[ic.id for ic in inside]))
    out["rows"] = rows
    out["hist_F"] = hist([r["bF"] for r in rows])
    out["hist_C"] = hist([r["bC"] for r in rows])
    out["max_bF"] = max([r["bF"] for r in rows], default=0)
    out["sum_pts_F"] = sum(2 ** r["bF"] for r in rows)

    # ---- baselines for the CURRENT design (every pair of the module is enumerated)
    all_fs = set(FACTS)
    out["global_bits"] = bits(set().union(*[n.reads for n in N]))
    out["global_pts_all_pairs"] = out["all_pairs"] * 2 ** out["global_bits"]
    for tag, keyfn in (("theme", lambda n: module_of_theme(n, coarse)),
                       ("act", lambda n: act_of(n, coarse))):
        mods, mb = module_bits(N, keyfn)
        enum_pairs = {m: len(ns) * (len(ns) - 1) // 2 for m, ns in mods.items()}
        out["mod_" + tag] = {m: dict(n=len(mods[m]), bits=mb[m], pairs=enum_pairs[m]) for m in mods}
        out["mod_%s_pts" % tag] = sum(enum_pairs[m] * 2 ** mb[m] for m in mods)
        # per same-act pair, cost of the module it lives in
        vals = []
        for r in rows:
            vals.append(mb[keyfn(r["n1"])] if keyfn(r["n1"]) == keyfn(r["n2"]) else float("inf"))
        out["hist_mod_" + tag] = hist(vals)

    # ---- modality-opposed pairs
    opp = []
    for r in rows:
        n1, n2 = r["n1"], r["n2"]
        if not incompatible(n1.mod, n2.mod):
            continue
        by_con = (n1.derived_from == n2.id) or (n2.derived_from == n1.id)
        form = (n1.kind in ("form", "meta", "authority")) or (n2.kind in ("form", "meta", "authority"))
        cls = "by-construction" if by_con else ("form-vs-ban" if form else "cross")
        exact = co_applies(n1, n2, r["clos"], [ic for ic in ICS if ic.facts & r["clos"]])
        proj = co_applies(n1, n2, r["F"], [ic for ic in ICS if ic.facts <= r["F"]])
        none_ = co_applies(n1, n2, r["F"], [])
        ep = co_applies_eproj(n1, n2, r["F"], ICS)
        opp.append(dict(r=r, cls=cls, exact=exact, proj=proj, noic=none_, eproj=ep))
    out["opp"] = opp
    return out


set_mode("enum", False)

if __name__ == "__main__":
    # self-check of the table
    allp = []
    for g1 in "ab":
        for g4 in ("exc", "perm"):
            for pr in check_reads(build(g1, g4)):
                allp.append((g1, g4) + pr)
    print("declared-reads problems:", allp if allp else "none")


# ---------------------------------------------------------------- per-IC existential projection
def co_applies_eproj(n1, n2, fs, ics):
    """enforce each IC as  'exists values of its facts outside F such that IC holds'.
       Needs the IC's atom list -> only possible if ICs are syntax trees (design (b))."""
    ics = [ic for ic in ics if ic.facts & fs]
    for p in points(fs):
        ok = True
        for ic in ics:
            outside = ic.facts - fs
            if not outside:
                if not ic.fn(p):
                    ok = False
                    break
            else:
                found = False
                for q in points(outside):
                    r = dict(p)
                    r.update(q)
                    if ic.fn(r):
                        found = True
                        break
                if not found:
                    ok = False
                    break
        if ok and n1.applies(p) and n2.applies(p):
            return True
    return False
