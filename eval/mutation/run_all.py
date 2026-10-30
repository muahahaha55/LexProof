# -*- coding: utf-8 -*-
"""Compare the three computations (a) Lean full-domain, (b) Python reference, (c) analyzeP, then
classify each mutant and count (docs/mutation-experiment.md, sections 4 and 5).

  python run_all.py          # reads lean_out.tsv (made by: lake env lean --run eval/mutation/Run.lean)
  python run_all.py --lean   # regenerates Run.lean and re-runs Lean first (about 5 minutes)

Writes results.csv, disagreements.txt, summary.json.  No headline rate is computed.
"""
import csv
import json
import os
import statistics
import subprocess
import sys
from collections import defaultdict

import gen_mutants as G
from reference import *
from reference import sizes as ref_sizes

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
CATALOG = ["Điều %d" % i for i in range(1, 37)]

if "--lean" in sys.argv:
    G.emit_lean(G.generate(), os.path.join(HERE, "Run.lean"))
    with open(os.path.join(HERE, "lean_out.tsv"), "w", encoding="utf-8") as out:
        subprocess.run(["lake", "env", "lean", "--run", "eval/mutation/Run.lean"], cwd=ROOT, stdout=out, check=True)

muts = G.generate()
rows = {}
for line in open(os.path.join(HERE, "lean_out.tsv"), encoding="utf-8").read().split("\n"):
    if not line or line.startswith("CHECK"):
        if line.startswith("CHECK"): check_line = line
        continue
    f = line.split("\t")
    rows[f[0]] = f
assert "ts=true tp=true rs=true rp=true norms=true" in check_line, check_line      # STOP RULE part 1


def pairs(s):
    return {tuple(int(x) for x in p.split("-")) for p in s.split(",") if p}


def ids_of(spec, ps):          # stable identity of a pair: original ids
    ns = spec["norms"]
    return {frozenset((ns[i]["oid"], ns[j]["oid"])) for (i, j) in ps}


def proj_points(spec, i, j):
    """number of partial valuations the projected search of the pair covers (product of the domains of the
    atoms read through the readers of the two norms), situation side x parameter side"""
    def idxs(c, kind):
        if c[0] == kind: return {c[1]}
        if c[0] == "not": return idxs(c[1], kind)
        if c[0] in ("and", "or"): return idxs(c[1], kind) | idxs(c[2], kind)
        return set()
    out = 1
    for kind, readers, table in (("sit", spec["rs"], spec["ts"]), ("param", spec["rp"], spec["tp"])):
        ri = set()
        for n in (spec["norms"][i], spec["norms"][j]):
            ri |= idxs(n["cond"], kind)
            for e in n["exc"]: ri |= idxs(e, kind)
        atoms = {readers[r][1] for r in ri if r < len(readers)}
        sz = ref_sizes(table)
        for a in atoms:
            out *= sz[a] if a < len(sz) else 0
    return out


dis = []              # disagreements (reported first)
res = []
base_pairs = {}
for m in muts:
    f = rows[m["id"]]
    spec = m["spec"]
    lean_keys = sorted(k for k in f[1].split(";") if k)
    lean_unc, lean_con = pairs(f[2]), pairs(f[3])
    kind_a, kind_p = f[4], f[5]
    hits = pairs(f[6])
    checked, lean_pts, us = int(f[7]), int(f[8]), int(f[9])
    py_keys = all_findings(spec, CATALOG)
    py_unc, py_con = conflict_pairs(spec)
    d = []
    if lean_keys != py_keys: d.append("findings Lean %s != Python %s" % (lean_keys, py_keys))
    if lean_unc != py_unc: d.append("unconstrained pairs Lean %s != Python %s" % (sorted(lean_unc), sorted(py_unc)))
    if lean_con != py_con: d.append("constrained pairs Lean %s != Python %s" % (sorted(lean_con), sorted(py_con)))
    # the existing public `analyze` runs `validate` only: it knows the "N:" findings, not table or reader findings
    norm_keys = [k for k in py_keys if k.startswith("N:")]
    if norm_keys:
        if kind_a != "invalid": d.append("analyze kind %s but validate findings exist" % kind_a)
    elif bool(py_unc) != (kind_a in ("conflict", "conditional")):
        d.append("analyze kind %s vs pairs %s" % (kind_a, sorted(py_unc)))
    table_only = bool(py_keys) and not norm_keys
    if py_keys:
        if kind_p != "invalid": d.append("analyzeP %s but findings exist" % kind_p)
    else:
        if (kind_p == "conflicts") != bool(py_unc): d.append("analyzeP %s vs pairs %s" % (kind_p, sorted(py_unc)))
        if hits != py_unc: d.append("analyzeP pairs %s != full-domain pairs %s" % (sorted(hits), sorted(py_unc)))
        ns = spec["norms"]
        same = [(i, j) for i in range(len(ns)) for j in range(i + 1, len(ns)) if ns[i]["act"] == ns[j]["act"]]
        if checked != len(same): d.append("pairsChecked %d != %d" % (checked, len(same)))
        want_pts = sum(proj_points(spec, i, j) for i, j in same)
        if lean_pts != want_pts: d.append("projected points %d != %d" % (lean_pts, want_pts))
    if d: dis.append((m["id"], m["desc"], d))
    valid = not py_keys
    pid = ids_of(spec, hits) if valid else set()
    if m["op"] == "base": base_pairs[m["base"]] = ids_of(spec, py_unc)
    res.append(dict(m=m, table_only=table_only, kind_a=kind_a, findings=lean_keys, unc=lean_unc, con=lean_con, kind_p=kind_p, hits=hits, pid=pid, us=us,
                    valid=valid, d=d, spec=spec))

# ---------------------------------------------------------------- classification and expectations
BO = {"B0": set(), "B1": set(), "B2": base_pairs["B2"]}
assert base_pairs["B0"] == set() and base_pairs["B1"] == set() and len(base_pairs["B2"]) == 1, base_pairs


def precond(spec, i):
    """does norm i have a same-act norm with an incompatible modality and no one-sided priority between them"""
    ns = spec["norms"]
    return any(j != i and ns[j]["act"] == ns[i]["act"] and (ns[i]["mod"], ns[j]["mod"]) in INCOMPAT
               and not resolved(ns[i], ns[j]) for j in range(len(ns)))


for r in res:
    m, spec = r["m"], r["spec"]
    op, base_ = m["op"], m["base"]
    if op == "base":
        r.update(outcome="-", fa=False, unc_only=0, exp_ok=True, hidden=set()); continue
    bp = BO[base_]
    new = r["pid"] - bp if r["valid"] else set()
    hidden = (bp - r["pid"]) if r["valid"] else set()
    ucon = {p for p in r["hits"] if p not in r["con"]}                  # reported pairs that are unconstrained-only
    r["unc_only"] = len(ucon)
    if m["group"] == "A":
        exp = sorted(m["expect"])
        got = r["findings"]
        det = set(exp) <= set(got) and not r["valid"]
        r["outcome"] = "detected" if det else "missed"
        r["exp_ok"] = (got == exp)
        r["fa"] = False
    elif m["group"] == "D":
        changed = (not r["valid"]) or (r["pid"] != bp)
        r["outcome"] = "false-alarm" if changed else "silent"
        r["fa"] = changed
        r["exp_ok"] = not changed
    else:
        if not r["valid"]:
            r["outcome"] = "detected"
        elif new:
            r["outcome"] = "detected"
        elif hidden:
            r["outcome"] = "missed-hiding"
        else:
            r["outcome"] = "missed-invisible"
        r["fa"] = bool(r["valid"] and r["hits"] and all(p in ucon for p in r["hits"]))
        out = r["outcome"]
        ns = spec["norms"]
        ok = r["valid"]                                  # a B/C mutant is not expected to be structurally invalid
        if ok:
            if op == "M1":
                oid = m["desc"].split()[1].rstrip(":")
                i = next(k for k, n in enumerate(ns) if n["oid"] == oid)
                ok = True if precond(spec, i) else (out != "detected")
            elif op == "M2":
                ok = True if precond(spec, len(ns) - 1) else (out != "detected")
            elif op == "M3":
                ok = out == "missed-invisible"
            elif op == "M4":
                ok = (out != "detected") if ("narrow" in m["desc"] or base_ == "B0") else True
            elif op == "M7a":
                ok = (out != "detected") if base_ == "B0" else True
            elif op == "M7b":
                tgt = m["desc"].split()[1].rstrip(":")
                if base_ == "B2":
                    in_pair = any(tgt in tuple(p) for p in bp)
                    ok = (out == "missed-hiding") if in_pair else (out == "missed-invisible")
                else:
                    ok = out == "missed-invisible"
            elif op in ("M8a", "M8d"):
                ok = (out != "detected") if base_ == "B0" else True
            elif op == "M9a":
                a_, b_ = m["desc"].split()[0], m["desc"].split()[2]
                if base_ == "B2":
                    ok = (out == "missed-hiding") if frozenset((a_, b_)) in bp else (out == "missed-invisible")
                else:
                    ok = out == "missed-invisible"
            elif op == "M10a":
                ok = out == "detected" and bool(r["hits"]) and all(p in ucon for p in r["hits"])
            elif op == "M10b":
                ok = out == "detected" and any(p in r["con"] for p in r["hits"])
        r["exp_ok"] = ok
    r["hidden"] = hidden

# ---------------------------------------------------------------- outputs
with open(os.path.join(HERE, "results.csv"), "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f)
    w.writerow(["id", "base", "op", "group", "outcome", "expectation_met", "false_alarm", "unconstrained_only_pairs",
                "analyzeP_kind", "findings", "reported_pairs", "analyzeP_us", "disagreements"])
    for r in res:
        m = r["m"]
        w.writerow([m["id"], m["base"], m["op"], m["group"], r["outcome"], r["exp_ok"], r["fa"], r["unc_only"],
                    r["kind_p"], ";".join(r["findings"]), ";".join("%d-%d" % p for p in sorted(r["hits"])), r["us"],
                    " | ".join(r["d"])])

with open(os.path.join(HERE, "disagreements.txt"), "w", encoding="utf-8") as f:
    f.write("%d mutants with a disagreement among (a) Lean full-domain, (b) Python, (c) analyzeP\n" % len(dis))
    for i, d_, ds in dis:
        f.write("%s | %s\n    %s\n" % (i, d_, "\n    ".join(ds)))

tab = defaultdict(lambda: defaultdict(int))
for r in res:
    m = r["m"]
    if m["op"] == "base": continue
    for key in ((m["group"], m["op"]), (m["group"], "ALL")):
        t = tab[key]
        t["n"] += 1
        t[r["outcome"]] += 1
        t["false_alarm"] += 1 if r["fa"] else 0
        t["unc_only_pairs"] += r["unc_only"]
        t["expectation_wrong"] += 0 if r["exp_ok"] else 1
        t["disagree"] += 1 if r["d"] else 0
        t["hits_total"] += len(r["hits"])

valid = [r for r in res if r["valid"]]
regress = {"valid_mutants": len(valid),
           "pairs_equal_full_domain": sum(1 for r in valid if r["hits"] == r["unc"]),
           "pairs_reported_not_confirmed": sum(len(r["hits"] - r["unc"]) for r in valid),
           "pairs_missed": sum(len(r["unc"] - r["hits"]) for r in valid)}
us = sorted(r["us"] for r in res[1:] if r["valid"])
timing = {"n": len(us), "median_us": statistics.median(us), "p90_us": us[int(0.9 * len(us))], "max_us": us[-1],
          "first_call_us": res[0]["us"]}
summary = {"mutants": len(muts) - 3, "disagreements": len(dis), "regression": regress, "timing": timing,
           "table": {"%s/%s" % k: dict(v) for k, v in sorted(tab.items())}}
json.dump(summary, open(os.path.join(HERE, "summary.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)

print("mutants (excluding 3 unmutated bases):", len(muts) - 3)
print("DISAGREEMENTS:", len(dis))
for i, d_, ds in dis[:20]: print(" ", i, d_, ds)
print("regression:", regress)
print("timing (us):", timing)
cols = ["n", "detected", "missed", "missed-invisible", "missed-hiding", "silent", "false-alarm", "false_alarm", "unc_only_pairs", "expectation_wrong", "disagree"]
print("%-8s" % "op", " ".join("%8s" % c[:8] for c in cols))
for (g, op), v in sorted(tab.items()):
    print("%s %-6s" % (g, op), " ".join("%8d" % v.get(c, 0) for c in cols))
