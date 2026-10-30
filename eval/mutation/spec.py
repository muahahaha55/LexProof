# -*- coding: utf-8 -*-
"""Python model of the draft encoding LexProof/Laws/AlcoholSale.lean (B0) and its two synthetic
variants (B1, B2), plus the emitters that write the same data as Lean source.

The two atom tables are PARSED from the Lean file (so the strings are exactly the module's);
readers and norms are written by hand here and checked for equality against the real module by
Run.lean (`B0 emitted == module`). A mismatch is a finding and stops the experiment.
"""
import copy
import io
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
LEAN = os.path.join(ROOT, "LexProof", "Laws", "AlcoholSale.lean")

# Cond: ("tt",) ("ff",) ("sit", i) ("param", i) ("not", c) ("and", a, b) ("or", a, b)
TT = ("tt",)


def S(i): return ("sit", i)
def P(i): return ("param", i)
def NOT(c): return ("not", c)
def AND(a, b): return ("and", a, b)
def OR(a, b): return ("or", a, b)


def _parse_table(block):
    atoms = []
    for piece in re.split(r"\{ name := ", block)[1:]:
        name = re.match(r'"([^"]*)"', piece).group(1)
        src = re.search(r'source := "([^"]*)"', piece).group(1)
        if ".bool" in piece:
            bands = None
        else:
            bands = [(l, s) for l, s in re.findall(r'⟨"([^"]*)",\s*"([^"]*)"⟩', piece)]
        atoms.append({"name": name, "source": src, "bands": bands})
    return atoms


def _tables():
    t = io.open(LEAN, encoding="utf-8").read()
    ts = t[t.index("def tS : AtomTable"):t.index("/-- Open-textured parameters")]
    tp = t[t.index("def tP : AtomTable"):t.index("/-- Readers `(name")]
    return _parse_table(ts), _parse_table(tp)


def norm(id, mod, act, cond, exc=(), refs=(), ov=(), art="", doc="44/2019/QH14"):
    return {"id": id, "oid": id, "mod": mod, "act": act, "cond": cond, "exc": list(exc), "refs": list(refs),
            "ov": list(ov), "art": art, "doc": doc}


RS = [("S04 chưa đủ 18", 0, 0), ("S04 từ đủ 18", 0, 1), ("S02 dưới 15", 1, 0), ("S02 từ 15", 1, 1),
      ("S14", 2, 1), ("S15", 3, 1), ("S16", 4, 1), ("S17", 5, 1), ("S18", 6, 1), ("S19", 7, 1), ("S20", 8, 1)]
RP = [("P14", 0, 1)]

PRO, OBL, PER = "prohibition", "obligation", "permission"

B0_NORMS = [
    norm("5.3-ban", PRO, "ban_ruou_bia", S(0), art="Điều 5 khoản 3"),
    norm("5.3-cung-cap", PRO, "cung_cap_ruou_bia", S(0), art="Điều 5 khoản 3"),
    norm("5.3-khuyen-mai", PRO, "khuyen_mai_ruou_bia", S(0), art="Điều 5 khoản 3"),
    norm("5.9-i", PRO, "khuyen_mai_ruou_bia", S(3), art="Điều 5 khoản 9"),
    norm("5.9-ii", PRO, "dung_ruou_bia_lam_qua_khuyen_mai", S(3), art="Điều 5 khoản 9"),
    norm("5.11-ii", PRO, "ban_ruou_bia_bang_may_tu_dong", TT, art="Điều 5 khoản 11"),
    norm("19.1", PRO, "ban_ruou_bia", S(4), art="Điều 19 khoản 1"),
    norm("19.2", PRO, "ban_ruou_bia", S(5), art="Điều 19 khoản 2"),
    norm("19.3", PRO, "ban_ruou_bia", AND(S(6), P(0)), art="Điều 19 khoản 3"),
    norm("19.4", PRO, "ban_ruou_bia", S(7), art="Điều 19 khoản 4"),
    norm("19.5", PRO, "ban_ruou_bia", S(8), art="Điều 19 khoản 5"),
    norm("19.6", PRO, "ban_ruou_bia", S(9), exc=[S(10)], art="Điều 19 khoản 6"),
]

SYN_ART = "(tổng hợp, không có trong luật)"


def base(name):
    ts, tp = _tables()
    spec = {"name": name, "ts": ts, "tp": tp, "rs": list(RS), "rp": list(RP),
            "norms": copy.deepcopy(B0_NORMS)}
    if name in ("B1", "B2"):
        cond = AND(S(2), S(1)) if name == "B1" else S(1)
        # B1: S02 = dưới 15 AND S04 = từ đủ 18 ; B2: S04 = từ đủ 18 only
        spec["norms"].append(norm("SYN-P", PER, "khuyen_mai_ruou_bia", cond, art=SYN_ART))
    return spec


# ------------------------------------------------------------------ Lean emission
def s(x):
    assert '"' not in x and "\\" not in x, x
    return '"' + x + '"'


def lean_cond(c):
    k = c[0]
    if k == "tt": return "Cond.tt"
    if k == "ff": return "Cond.ff"
    if k == "sit": return "(Cond.sit %d)" % c[1]
    if k == "param": return "(Cond.param %d)" % c[1]
    if k == "not": return "(Cond.not %s)" % lean_cond(c[1])
    if k == "and": return "(Cond.and %s %s)" % (lean_cond(c[1]), lean_cond(c[2]))
    if k == "or": return "(Cond.or %s %s)" % (lean_cond(c[1]), lean_cond(c[2]))
    raise ValueError(c)


def lean_table(atoms):
    rows = []
    for a in atoms:
        if a["bands"] is None:
            dom = ".bool"
        else:
            dom = ".enum [%s]" % ", ".join("⟨%s, %s⟩" % (s(l), s(x)) for l, x in a["bands"])
        rows.append("{ name := %s, source := %s, domain := %s }" % (s(a["name"]), s(a["source"]), dom))
    return "[" + ", ".join(rows) + "]"


def lean_readers(rs):
    return "[" + ", ".join("(%s, %d, %d)" % (s(n), a, v) for n, a, v in rs) + "]"


def lean_norm(n):
    return "nrm %s .%s %s %s [%s] [%s] [%s] %s %s" % (
        s(n["id"]), n["mod"], s(n["act"]), lean_cond(n["cond"]),
        ", ".join(lean_cond(e) for e in n["exc"]), ", ".join(s(r) for r in n["refs"]),
        ", ".join(s(o) for o in n["ov"]), s(n["art"]), s(n["doc"]))
