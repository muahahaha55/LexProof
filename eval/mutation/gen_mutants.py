# -*- coding: utf-8 -*-
"""Deterministic generation of the mutants fixed in docs/mutation-experiment.md.

seed 20261031; every random choice uses random.Random("<seed>-<op>-<base>").
Writes mutants.csv (one line per mutant, no results) and Run.lean (the harness + the mutant data).
"""
import copy
import csv
import os
import random
import sys

from spec import *

SEED = "20261031"
CAP = 6
CAP_M2 = 10
HERE = os.path.dirname(os.path.abspath(__file__))

GROUP = {"M5": "A", "M6a": "A", "M8b": "A", "M8c": "A", "M8e": "A", "M9b": "A", "M9c": "A",
         "M11a": "A", "M11b": "A", "M11c": "A", "M11d": "A",
         "M1": "B", "M2": "B", "M3": "B", "M4": "B", "M7a": "B", "M7b": "B", "M8a": "B", "M8d": "B", "M9a": "B",
         "M10a": "C", "M10b": "C", "C1": "D", "C2": "D", "C3": "D"}

BAND_SIB = {0: 1, 1: 0, 2: 3, 3: 2}      # reader -> the other band of the same atom


def acts(spec): return sorted(set(n["act"] for n in spec["norms"]))


def leaves(c, kinds=("sit",)):
    """paths to leaves of the given kinds"""
    out = []

    def go(x, path):
        if x[0] in kinds: out.append((tuple(path), x))
        elif x[0] == "not": go(x[1], path + [1])
        elif x[0] in ("and", "or"):
            go(x[1], path + [1]); go(x[2], path + [2])
    go(c, [])
    return out


def replace_at(c, path, new):
    if not path: return new
    k = path[0]
    lst = list(c)
    lst[k] = replace_at(c[k], path[1:], new)
    return tuple(lst)


def rand_cond(rng, spec):
    rd = [("sit", i) for i in range(len(spec["rs"]))] + [("param", i) for i in range(len(spec["rp"]))]
    k = rng.choice([1, 2])
    at = [rng.choice(rd) for _ in range(k)]
    at = [NOT(a) if rng.random() < 0.3 else a for a in at]
    return at[0] if k == 1 else (AND if rng.random() < 0.5 else OR)(at[0], at[1])


def mk(spec, op, k, base, desc, expect=None):
    return {"id": "%s.%s.%02d" % (base, op, k), "base": base, "op": op, "group": GROUP[op],
            "desc": desc, "spec": spec, "expect": expect}


# each generator returns a list of (spec, description, expect_keys-or-None)
def cands(op, base, spec, rng):
    out = []
    ns = spec["norms"]
    if op == "M1":
        for i, n in enumerate(ns):
            for nm in ("obligation", "permission", "prohibition"):
                if nm != n["mod"]:
                    sp = copy.deepcopy(spec); sp["norms"][i]["mod"] = nm
                    out.append((sp, "norm %s: modality %s -> %s" % (n["id"], n["mod"], nm), None))
    elif op == "M2":
        for k in range(CAP_M2 * 3):
            sp = copy.deepcopy(spec)
            act = rng.choice(acts(spec))
            mods = {n["mod"] for n in ns if n["act"] == act}
            pool = set()
            for m in mods:
                pool |= {"obligation", "permission"} if m == "prohibition" else {"prohibition"}
            mod = rng.choice(sorted(pool))
            c = rand_cond(rng, spec)
            nid = "M2new-%d" % k
            sp["norms"].append(norm(nid, mod, act, c, art="(đột biến M2)"))
            out.append((sp, "add %s %s on act %s, cond %s" % (mod, nid, act, c), None))
    elif op == "M3":
        for i, n in enumerate(ns):
            if n["exc"]:
                sp = copy.deepcopy(spec); sp["norms"][i]["exc"] = []
                out.append((sp, "drop exception of %s" % n["id"], None))
    elif op == "M4":
        for i, n in enumerate(ns):
            for path, lf in leaves(n["cond"]):
                if lf[1] in BAND_SIB:
                    sib = ("sit", BAND_SIB[lf[1]])
                    for var, new in (("widen", OR(lf, sib)), ("swap", sib), ("narrow", ("ff",))):
                        sp = copy.deepcopy(spec)
                        sp["norms"][i]["cond"] = replace_at(n["cond"], path, new)
                        out.append((sp, "%s: %s band reader %d" % (n["id"], var, lf[1]), None))
    elif op == "M5":
        for i in range(len(ns)):
            for j in range(len(ns)):
                if i != j:
                    sp = copy.deepcopy(spec); sp["norms"][j]["id"] = ns[i]["id"]
                    out.append((sp, "id of norm %d (%s) := id of norm %d" % (j, ns[j]["id"], i),
                                ["N:duplicateId:" + ns[i]["id"]]))
    elif op == "M6a":
        for i, n in enumerate(ns):
            sp = copy.deepcopy(spec); sp["norms"][i]["refs"] = ["Điều 99"]
            out.append((sp, "norm %s cites Điều 99" % n["id"], ["N:dangling:%s:Điều 99" % n["id"]]))
    elif op in ("M7a", "M7b"):
        for i, n in enumerate(ns):
            if op == "M7a":
                for a in acts(spec):
                    if a != n["act"]:
                        sp = copy.deepcopy(spec); sp["norms"][i]["act"] = a
                        out.append((sp, "norm %s: act %s -> existing %s" % (n["id"], n["act"], a), None))
            else:
                sp = copy.deepcopy(spec); sp["norms"][i]["act"] = "act_moi_" + n["id"]
                out.append((sp, "norm %s: act %s -> new act_moi_%s" % (n["id"], n["act"], n["id"]), None))
    elif op == "M8a":
        ssz = sizes_of(spec["ts"])
        for k, (nm, a, v) in enumerate(spec["rs"]):
            for a2 in range(len(ssz)):
                for v2 in range(ssz[a2]):
                    if (a2, v2) != (a, v):
                        sp = copy.deepcopy(spec); sp["rs"][k] = (nm, a2, v2)
                        out.append((sp, "reader %s (%d,%d) -> (%d,%d) in range" % (nm, a, v, a2, v2), None))
    elif op == "M8b":
        ssz = sizes_of(spec["ts"])
        for k, (nm, a, v) in enumerate(spec["rs"]):
            for a2 in range(len(ssz)):
                if a2 != a:
                    sp = copy.deepcopy(spec); sp["rs"][k] = (nm, a2, ssz[a2])
                    out.append((sp, "reader %s -> atom %d value %d (outside its domain)" % (nm, a2, ssz[a2]),
                                ["RS:readerValueOutOfRange:%s:%d:%d" % (nm, a2, ssz[a2])]))
    elif op == "M8c":
        for side, key, tab in (("S", "rs", "ts"), ("P", "rp", "tp")):
            for k, (nm, a, v) in enumerate(spec[key]):
                sp = copy.deepcopy(spec); sp[key][k] = (nm, len(spec[tab]), v)
                out.append((sp, "reader %s -> atom %d (outside the table)" % (nm, len(spec[tab])),
                            ["R%s:readerAtomOutOfRange:%s:%d" % (side, nm, len(spec[tab]))]))
    elif op == "M8d":
        for i, n in enumerate(ns):
            for path, lf in leaves(n["cond"], ("sit",)):
                for r2 in range(len(spec["rs"])):
                    if r2 != lf[1]:
                        sp = copy.deepcopy(spec)
                        sp["norms"][i]["cond"] = replace_at(n["cond"], path, ("sit", r2))
                        out.append((sp, "%s: Cond.sit %d -> %d (in range)" % (n["id"], lf[1], r2), None))
    elif op == "M8e":
        for i, n in enumerate(ns):
            for path, lf in leaves(n["cond"], ("sit",)):
                sp = copy.deepcopy(spec)
                sp["norms"][i]["cond"] = replace_at(n["cond"], path, ("sit", len(spec["rs"])))
                out.append((sp, "%s: Cond.sit %d -> %d (out of range)" % (n["id"], lf[1], len(spec["rs"])),
                            ["N:atomIndexOutOfRange:" + n["id"]]))
    elif op == "M9a":
        for i in range(len(ns)):
            for j in range(len(ns)):
                if i != j:
                    sp = copy.deepcopy(spec); sp["norms"][i]["ov"] = [ns[j]["id"]]
                    out.append((sp, "%s overrides %s" % (ns[i]["id"], ns[j]["id"]), None))
    elif op == "M9b":
        for i in range(len(ns)):
            for j in range(i + 1, len(ns)):
                sp = copy.deepcopy(spec)
                sp["norms"][i]["ov"] = [ns[j]["id"]]; sp["norms"][j]["ov"] = [ns[i]["id"]]
                out.append((sp, "%s and %s override each other" % (ns[i]["id"], ns[j]["id"]),
                            ["N:priorityCycle:" + ns[i]["id"], "N:priorityCycle:" + ns[j]["id"]]))
    elif op == "M9c":
        for i, n in enumerate(ns):
            sp = copy.deepcopy(spec); sp["norms"][i]["ov"] = ["khong_co_id"]
            out.append((sp, "%s overrides unknown id" % n["id"], ["N:unknownOverride:%s:khong_co_id" % n["id"]]))
    elif op in ("M10a", "M10b"):
        if base != "B0":
            return []
        xs = {"19.1": S(4), "19.2": S(5), "19.4": S(7), "19.5": S(8), "19.6": AND(S(9), NOT(S(10)))}
        for xn, x in xs.items():
            for mod in ("permission", "obligation"):
                sp = copy.deepcopy(spec)
                z = AND(P(0), AND(NOT(S(6)), x)) if op == "M10a" else x
                sp["norms"].append(norm("Z-%s-%s" % (mod[:3], xn), mod, "ban_ruou_bia", z, art="(đột biến M10)"))
                out.append((sp, "add %s Z on ban_ruou_bia with cond %s%s" % (
                    mod, xn, " AND P14 AND NOT S16" if op == "M10a" else ""), None))
    elif op == "M11a":
        for i in range(len(spec["ts"])):
            for j in range(i + 1, len(spec["ts"])):
                sp = copy.deepcopy(spec); sp["ts"][j]["name"] = spec["ts"][i]["name"]
                out.append((sp, "situation atoms %d and %d share a name" % (i, j),
                            ["TS:duplicateAtomName:" + spec["ts"][i]["name"]]))
    elif op == "M11b":
        for i, a in enumerate(spec["ts"]):
            if a["bands"] is not None:
                sp = copy.deepcopy(spec); sp["ts"][i]["bands"] = []
                exp = ["TS:emptyDomain:" + a["name"]] + [
                    "RS:readerValueOutOfRange:%s:%d:%d" % (nm, ra, rv) for nm, ra, rv in spec["rs"] if ra == i]
                out.append((sp, "situation atom %d (%s) has no bands" % (i, a["name"][:3]), exp))
    elif op == "M11c":
        for side, tk in (("S", "ts"), ("P", "tp")):
            for i, a in enumerate(spec[tk]):
                sp = copy.deepcopy(spec); sp[tk][i]["source"] = ""
                out.append((sp, "%s atom %d: empty source" % (side, i), ["T%s:emptyAtomSource:%s" % (side, a["name"])]))
                if a["bands"]:
                    sp = copy.deepcopy(spec); l0 = a["bands"][0][0]; sp[tk][i]["bands"][0] = (l0, "")
                    out.append((sp, "%s atom %d band 0: empty source" % (side, i),
                                ["T%s:emptyBandSource:%s:%s" % (side, a["name"], l0)]))
    elif op == "M11d":
        for i, a in enumerate(spec["ts"]):
            if a["bands"] and len(a["bands"]) >= 2:
                sp = copy.deepcopy(spec); l0 = a["bands"][0][0]
                sp["ts"][i]["bands"][1] = (l0, a["bands"][1][1])
                out.append((sp, "situation atom %d: two bands labelled the same" % i,
                            ["TS:duplicateBandLabel:%s:%s" % (a["name"], l0)]))
    elif op == "C1":
        for i, n in enumerate(ns):
            sp = copy.deepcopy(spec); sp["norms"][i]["id"] = n["id"] + "-renamed"
            out.append((sp, "control: norm %s gets a new unique id" % n["id"], []))
    elif op == "C2":
        for i, n in enumerate(ns):
            sp = copy.deepcopy(spec); sp["norms"][i]["refs"] = ["Điều 5"]
            out.append((sp, "control: norm %s cites the existing Điều 5" % n["id"], []))
    elif op == "C3":
        for i in range(len(ns)):
            for j in range(i + 1, len(ns)):
                sp = copy.deepcopy(spec); sp["norms"][i], sp["norms"][j] = sp["norms"][j], sp["norms"][i]
                out.append((sp, "control: swap list positions %d and %d" % (i, j), []))
    return out


def sizes_of(table):
    return [2 if a["bands"] is None else len(a["bands"]) for a in table]


def generate():
    muts = []
    for base in ("B0", "B1", "B2"):
        sp = base_spec(base)
        muts.append({"id": base, "base": base, "op": "base", "group": "-", "desc": "unmutated", "spec": sp, "expect": []})
    ops = list(GROUP)
    for base in ("B0", "B1", "B2"):
        spec = base_spec(base)
        for op in ops:
            rng = random.Random("%s-%s-%s" % (SEED, op, base))
            c = cands(op, base, spec, rng)
            cap = CAP_M2 if op == "M2" else (len(c) if op.startswith("M10") else CAP)
            idx = sorted(rng.sample(range(len(c)), min(cap, len(c))))
            for k, ci in enumerate(idx):
                sp, desc, exp = c[ci]
                muts.append(mk(sp, op, k, base, desc, exp))
    return muts


def base_spec(name):
    return base(name)


# ------------------------------------------------------------------------------ Lean emission
HEADER = '''import LexProof.Verify.AnalyzeProjected
import LexProof.Laws.AlcoholSale
open LexProof

/-! Scratch (NOT part of the library). Generated by eval/mutation/gen_mutants.py. -/

def nrm (id : String) (m : Modality) (act : String) (c : Cond) (ex : List Cond)
    (refs : List String) (ov : List String) (art : String) (doc : String) : Norm :=
  { id := id, modality := m, act := act, condition := c, exceptions := ex
  , priority := if ov.isEmpty then none else some ⟨ov⟩
  , source := { docId := doc, docType := .law, effective := ⟨2020, 1, 1⟩, article := art }
  , references := refs }

def catalog : List String := (List.range 36).map fun i => "Điều " ++ toString (i + 1)

structure Mut where
  id : String
  ts : AtomTable
  tp : AtomTable
  rs : List ReaderSpec
  rp : List ReaderSpec
  norms : List Norm
  deriving Inhabited

def sideS : TableSide → String
  | .situation => "S"
  | .parameter => "P"

def keyNorm : Finding → String
  | .emptyNormList => "N:emptyNormList"
  | .mixedDocIds _ => "N:mixedDocIds"
  | .duplicateId n => s!"N:duplicateId:{n}"
  | .atomIndexOutOfRange n => s!"N:atomIndexOutOfRange:{n}"
  | .danglingReference n r => s!"N:dangling:{n}:{r}"
  | .unknownOverride n t => s!"N:unknownOverride:{n}:{t}"
  | .priorityCycle n => s!"N:priorityCycle:{n}"

def keyT (s : TableSide) (k : String) : TableFinding → String
  | .duplicateAtomName n => s!"{k}{sideS s}:duplicateAtomName:{n}"
  | .emptyDomain a => s!"{k}{sideS s}:emptyDomain:{a}"
  | .duplicateBandLabel a l => s!"{k}{sideS s}:duplicateBandLabel:{a}:{l}"
  | .emptyAtomSource a => s!"{k}{sideS s}:emptyAtomSource:{a}"
  | .emptyBandSource a l => s!"{k}{sideS s}:emptyBandSource:{a}:{l}"
  | .readerAtomOutOfRange r a => s!"{k}{sideS s}:readerAtomOutOfRange:{r}:{a}"
  | .readerValueOutOfRange r a v => s!"{k}{sideS s}:readerValueOutOfRange:{r}:{a}:{v}"

def keyP : PFinding → String
  | .norm f => keyNorm f
  | .table s f => keyT s "T" f
  | .reader s f => keyT s "R" f

def kindA {S P : Type} : Result S P → String
  | .conflict .. => "conflict"
  | .conditionalConflict .. => "conditional"
  | .consistentOn .. => "consistent"
  | .unknown .. => "unknown"
  | .invalid _ => "invalid"

def pairStr (l : List (Nat × Nat)) : String :=
  ",".intercalate (l.map fun p => s!"{p.1}-{p.2}")

/-- IC-A: P14 (parameter atom 0, value 1) implies S16 (situation atom 4, value 1). -/
def icA {ts tp : AtomTable} (π : Valuation tp) (s : Valuation ts) : Bool :=
  !(π.get 0 == 1 && !(s.get 4 == 1))

/-- (a) full-domain enumeration with the existing checker's `Internal.isConflictAt`.
Returns (pairs with a conflicting point, pairs with a conflicting point that satisfies IC-A).
Pairs with different acts are skipped (the first conjunct of `Conflict`). -/
def fullPairs (m : Mut) : List (Nat × Nat) × List (Nat × Nat) :=
  let A := atomsOf m.ts m.tp m.rs m.rp
  let pts := (Finite.enum (α := Valuation m.tp)).flatMap fun π =>
    (Finite.enum (α := Valuation m.ts)).map fun s => (π, s)
  let n := m.norms.length
  let rows := (List.range n).flatMap fun i => (List.range n).filterMap fun j =>
    if i < j && m.norms[i]!.act == m.norms[j]!.act then
      let bad := pts.filter fun p => Internal.isConflictAt A m.norms[i]! m.norms[j]! p.1 p.2
      some ((i, j), !bad.isEmpty, bad.any fun p => icA p.1 p.2)
    else none
  (rows.filterMap fun r => if r.2.1 then some r.1 else none,
   rows.filterMap fun r => if r.2.2 then some r.1 else none)

def timedP (m : Mut) : IO (String × List (Nat × Nat) × Nat × Nat × Nat) := do
  let t0 ← IO.monoNanosNow
  let r ← IO.lazyPure fun _ =>
    let idx := fun (x : String) => m.norms.findIdx (·.id == x)
    match analyzeP m.ts m.tp m.rs m.rp catalog m.norms with
    | .invalid _ => ("invalid", ([] : List (Nat × Nat)), 0, 0)
    | .conflicts hs sc => ("conflicts", hs.map (fun (h : ProjHit) => (idx h.left, idx h.right)), sc.pairsChecked,
        sc.pointsPerPair.foldl (fun (a : Nat) (e : NormId × NormId × Nat) => a + e.2.2) 0)
    | .consistentOn sc => ("consistent", ([] : List (Nat × Nat)), sc.pairsChecked,
        sc.pointsPerPair.foldl (fun (a : Nat) (e : NormId × NormId × Nat) => a + e.2.2) 0)
  let t1 ← IO.monoNanosNow
  return (r.1, r.2.1, r.2.2.1, r.2.2.2, (t1 - t0) / 1000)

def runOne (m : Mut) : IO Unit := do
  let A := atomsOf m.ts m.tp m.rs m.rp
  let keys := (pfindings m.ts m.tp m.rs m.rp catalog m.norms).map keyP
  let (unc, con) := fullPairs m
  let ka := kindA (analyze A catalog m.norms)
  let (kp, hits, chk, pts, us) ← timedP m
  IO.println ("\\t".intercalate [m.id, ";".intercalate keys, pairStr unc, pairStr con, ka, kp,
    pairStr hits, toString chk, toString pts, toString us])
'''


class Pool:
    def __init__(self, prefix, emit):
        self.prefix, self.emit, self.names, self.defs = prefix, emit, {}, []

    def get(self, obj, typ):
        text = self.emit(obj)
        if text not in self.names:
            nm = "%s%d" % (self.prefix, len(self.names))
            self.names[text] = nm
            self.defs.append("def %s : %s :=\n  %s\n" % (nm, typ, text))
        return self.names[text]


def emit_lean(muts, path):
    tabs = Pool("T", lean_table)
    rds = Pool("R", lean_readers)
    nrs = Pool("N", lean_norm)
    entries = []
    for m in muts:
        sp = m["spec"]
        t1 = tabs.get(sp["ts"], "AtomTable")
        t2 = tabs.get(sp["tp"], "AtomTable")
        r1 = rds.get(sp["rs"], "List ReaderSpec")
        r2 = rds.get(sp["rp"], "List ReaderSpec")
        ns = [nrs.get(n, "Norm") for n in sp["norms"]]
        entries.append('  ⟨%s, %s, %s, %s, %s, [%s]⟩' % (s(m["id"]), t1, t2, r1, r2, ", ".join(ns)))
    out = [HEADER]
    out += tabs.defs + rds.defs + nrs.defs
    out.append("def muts : List Mut :=\n  [\n" + ",\n".join(entries) + "\n  ]\n")
    out.append('''def main : IO Unit := do
  let b0 := muts.head!
  IO.println s!"CHECK B0 equals module: ts={decide (b0.ts = LexProof.Laws.AlcoholSale.tS)} tp={decide (b0.tp = LexProof.Laws.AlcoholSale.tP)} rs={decide (b0.rs = LexProof.Laws.AlcoholSale.rS)} rp={decide (b0.rp = LexProof.Laws.AlcoholSale.rP)} norms={decide (b0.norms = LexProof.Laws.AlcoholSale.norms)}"
  for m in muts do
    runOne m
''')
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(out))


def write_csv(muts, path):
    with open(path, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["id", "base", "op", "group", "description", "expected_finding_keys"])
        for m in muts:
            w.writerow([m["id"], m["base"], m["op"], m["group"], m["desc"],
                        "" if m["expect"] is None else ";".join(m["expect"])])


if __name__ == "__main__":
    ms = generate()
    write_csv(ms, os.path.join(HERE, "mutants.csv"))
    emit_lean(ms, os.path.join(HERE, "Run.lean"))
    from collections import Counter
    print(len(ms), "mutants;", dict(Counter(m["op"] for m in ms)))
