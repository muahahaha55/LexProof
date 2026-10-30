# -*- coding: utf-8 -*-
"""Independent Python re-implementation (b) of the semantics, written from the Lean definitions in
LexProof/Core/Norm.lean (Cond.eval, evalAny, Norm.applies, Norm.resolved, Incompatible),
Core/AtomTable.lean (Valuation, reads), Verify/Conflict.lean (Conflict),
Verify/Validate.lean (validate) and Verify/ProjectedCheck.lean (tableFindings, readerFindings).
It does not call Lean and does not read the Lean checker's output.

Finding keys are the canonical strings that Run.lean also prints.
"""
import itertools

INCOMPAT = {("obligation", "prohibition"), ("prohibition", "obligation"),
            ("permission", "prohibition"), ("prohibition", "permission")}


def sizes(table):
    return [2 if a["bands"] is None else len(a["bands"]) for a in table]


# ---------------------------------------------------------------- Cond.eval, three-valued
def eval_cond(c, rs_vals, rp_vals):
    k = c[0]
    if k == "tt": return True
    if k == "ff": return False
    if k == "sit": return rs_vals[c[1]] if c[1] < len(rs_vals) else None
    if k == "param": return rp_vals[c[1]] if c[1] < len(rp_vals) else None
    if k == "not":
        x = eval_cond(c[1], rs_vals, rp_vals)
        return None if x is None else (not x)
    x = eval_cond(c[1], rs_vals, rp_vals)       # no short-circuit: both sides are evaluated
    y = eval_cond(c[2], rs_vals, rp_vals)
    if x is None or y is None: return None
    return (x and y) if k == "and" else (x or y)


def eval_any(cs, rs_vals, rp_vals):
    r = False
    for c in cs:
        x = eval_cond(c, rs_vals, rp_vals)
        if x is None: return None
        r = r or x
    return r


def applies(n, rs_vals, rp_vals):
    c = eval_cond(n["cond"], rs_vals, rp_vals)
    e = eval_any(n["exc"], rs_vals, rp_vals)
    if c is None or e is None: return None
    return c and not e


def resolved(n1, n2):
    return (n2["id"] in n1["ov"]) != (n1["id"] in n2["ov"])


def reader_vals(readers, vs):
    # Valuation.get = vs.getD i 0 ; reads i v = (get i == v)
    return [(vs[a] if a < len(vs) else 0) == v for _, a, v in readers]


def ic_a_valid(pvs, svs):
    # IC-A : P14 (atom 0 of the parameter table, value 1) -> S16 (atom 4 of the situation table, value 1)
    p14 = (pvs[0] if len(pvs) > 0 else 0) == 1
    s16 = (svs[4] if len(svs) > 4 else 0) == 1
    return (not p14) or s16


def conflict_pairs(spec):
    """(unconstrained, constrained-by-IC-A): sets of position pairs (i, j), i < j, with at least one
    point at which Conflict holds. Full enumeration of the product of the domains."""
    ns = spec["norms"]
    ssz, psz = sizes(spec["ts"]), sizes(spec["tp"])
    spts = list(itertools.product(*[range(k) for k in ssz]))
    ppts = list(itertools.product(*[range(k) for k in psz]))
    cand = [(i, j) for i in range(len(ns)) for j in range(i + 1, len(ns))
            if ns[i]["act"] == ns[j]["act"] and (ns[i]["mod"], ns[j]["mod"]) in INCOMPAT
            and not resolved(ns[i], ns[j])]
    unc, con = set(), set()
    if not cand:
        return unc, con
    for pv in ppts:
        rp_vals = reader_vals(spec["rp"], pv)
        for sv in spts:
            rs_vals = reader_vals(spec["rs"], sv)
            ap = [applies(n, rs_vals, rp_vals) for n in ns]
            valid = ic_a_valid(pv, sv)
            for (i, j) in cand:
                if ap[i] is True and ap[j] is True:
                    unc.add((i, j))
                    if valid: con.add((i, j))
    return unc, con


# ---------------------------------------------------------------- findings
def _dups(l):
    return sorted({x for x in l if l.count(x) > 1})


def table_findings(table, side, kind="T"):
    out = []
    k = kind + side
    for n in _dups([a["name"] for a in table]):
        out.append("%s:duplicateAtomName:%s" % (k, n))
    for a in table:
        if a["bands"] is not None and len(a["bands"]) == 0:
            out.append("%s:emptyDomain:%s" % (k, a["name"]))
        if a["bands"] is not None:
            for l in _dups([l for l, _ in a["bands"]]):
                out.append("%s:duplicateBandLabel:%s:%s" % (k, a["name"], l))
        if a["source"] == "":
            out.append("%s:emptyAtomSource:%s" % (k, a["name"]))
        if a["bands"] is not None:
            for l, src in a["bands"]:
                if src == "":
                    out.append("%s:emptyBandSource:%s:%s" % (k, a["name"], l))
    return out


def reader_findings(table, readers, side):
    sz = sizes(table)
    out = []
    for name, a, v in readers:
        if a >= len(sz):
            out.append("R%s:readerAtomOutOfRange:%s:%d" % (side, name, a))
        elif not (v < sz[a]):
            out.append("R%s:readerValueOutOfRange:%s:%d:%d" % (side, name, a, v))
    return out


def _wf(c, nsit, nparam):
    k = c[0]
    if k in ("tt", "ff"): return True
    if k == "sit": return c[1] < nsit
    if k == "param": return c[1] < nparam
    if k == "not": return _wf(c[1], nsit, nparam)
    return _wf(c[1], nsit, nparam) and _wf(c[2], nsit, nparam)


def validate_findings(spec, catalog):
    ns = spec["norms"]
    if not ns:
        return ["N:emptyNormList"]
    out = []
    docs = sorted(set(n["doc"] for n in ns))
    if len(docs) >= 2: out.append("N:mixedDocIds")
    ids = [n["id"] for n in ns]
    for i in _dups(ids): out.append("N:duplicateId:" + i)
    for n in ns:
        ok = _wf(n["cond"], len(spec["rs"]), len(spec["rp"])) and all(
            _wf(e, len(spec["rs"]), len(spec["rp"])) for e in n["exc"])
        if not ok: out.append("N:atomIndexOutOfRange:" + n["id"])
    for n in ns:
        for r in n["refs"]:
            if r not in catalog: out.append("N:dangling:%s:%s" % (n["id"], r))
    for n in ns:
        for t in n["ov"]:
            if t not in ids: out.append("N:unknownOverride:%s:%s" % (n["id"], t))

    def succs(i):
        for n in ns:
            if n["id"] == i: return n["ov"]
        return []
    for n in ns:
        seen, stack = set(), list(succs(n["id"]))
        while stack:
            x = stack.pop()
            if x in seen: continue
            seen.add(x)
            stack.extend(succs(x))
        if n["id"] in seen: out.append("N:priorityCycle:" + n["id"])
    return out


def all_findings(spec, catalog):
    return sorted(validate_findings(spec, catalog)
                  + table_findings(spec["ts"], "S") + table_findings(spec["tp"], "P")
                  + reader_findings(spec["ts"], spec["rs"], "S") + reader_findings(spec["tp"], spec["rp"], "P"))
