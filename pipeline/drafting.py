# -*- coding: utf-8 -*-
"""Drafting-defect check (ADR-0030): dead norms, redundant norms, exceptions that never fire. UNTRUSTED tool: it
only SEARCHES for witnesses; the Lean kernel checks every witness it writes (`LexProof/Verify/Drafting.lean`).

    python pipeline/drafting.py scan   --base Law44
        searches, prints what it found; writes nothing.
    python pipeline/drafting.py module --base Law44 --name Law44Drafting [--no-build]
        writes LexProof/Laws/<name>.lean with the certificates and the kernel theorems, imports it, runs `lake build`.

A witness is one point (a value for every atom) at which the statement holds. If no witness is found for some norm,
pair or exception, it goes in the module's `unknown` list and the theorems exclude exactly it: «không biết», a
possible defect that only a person (or a universal proof, not implemented) can settle. The tool never claims a norm
is dead or redundant.
"""
import argparse
import itertools
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402
import run as RUN       # noqa: E402
import readings as RD   # noqa: E402
import promote as P     # noqa: E402

ROOT = T.ROOT


def merged_of(module):
    """The merged translation a promoted module was built from (same files, same order, sha256 checked)."""
    return RD.base({"doc_id": "44/2019/QH14", "module": module})[0]


class Model:
    """Atom order and value indices exactly as `translate.readers` lays them out for the Lean module."""

    def __init__(self, m):
        self.sit, self.par = m["atoms"]["situation"], m["atoms"]["parameters"]
        self.size = {}
        self.label = {}
        for a in self.sit + self.par:
            if a["domain"] == "bool":
                self.size[a["name"]] = 2
            else:
                self.size[a["name"]] = len(a["domain"])
                for j, b in enumerate(a["domain"]):
                    self.label[(a["name"], b["label"])] = j

    def ev(self, c, v):
        if c == "true":
            return True
        if c == "false":
            return False
        if "and" in c:
            return all(self.ev(x, v) for x in c["and"])
        if "or" in c:
            return any(self.ev(x, v) for x in c["or"])
        if "not" in c:
            return not self.ev(c["not"], v)
        name = c.get("sit", c.get("param"))
        want = self.label[(name, c["value"])] if "value" in c else 1
        return v.get(name, 0) == want

    def applies(self, n, v):
        return self.ev(n["condition"], v) and not any(self.ev(e, v) for e in n["exceptions"])

    def search(self, conds_of, pred, limit=1 << 16):
        """A point (dict atom -> value index) over the atoms the conditions use, or None. `conds_of`: conditions whose
        atoms are enumerated; atoms not used default to 0. Fails closed (None) beyond `limit` points."""
        names = sorted(set().union(*[T.cond_atoms(c, set()) for c in conds_of]))
        total = 1
        for a in names:
            total *= self.size[a]
        if total > limit:
            return None
        for combo in itertools.product(*[range(self.size[a]) for a in names]):
            v = dict(zip(names, combo))
            if pred(v):
                return v
        return None

    def lean_point(self, v):
        vs = lambda atoms: "[" + ", ".join(str(v.get(a["name"], 0)) for a in atoms) + "]"
        return "(%s, %s)" % (vs(self.par), vs(self.sit))


def same_duty(a, b):
    return a["act"] == b["act"] and a["modality"] == b["modality"]


def scan(m):
    """(live, notsub, exc, unknown): witnesses found, and what could not be witnessed."""
    M = Model(m)
    ns = m["norms"]
    live, notsub, exc, unknown = [], [], [], []
    for n in ns:
        v = M.search([n["condition"]] + n["exceptions"], lambda v: M.applies(n, v))
        (live.append((n["id"], v)) if v is not None else
         unknown.append(("live", n["id"], None, "norm chết? không tìm thấy tình huống nào %s áp dụng" % n["id"])))
    for a, b in itertools.permutations(ns, 2):
        if a["id"] != b["id"] and same_duty(a, b):
            conds = [a["condition"], b["condition"]] + a["exceptions"] + b["exceptions"]
            v = M.search(conds, lambda v: M.applies(a, v) and not M.applies(b, v))
            (notsub.append((a["id"], b["id"], v)) if v is not None else
             unknown.append(("sub", a["id"], b["id"], "norm thừa? mọi tình huống %s áp dụng thì %s cũng áp dụng "
                             "(hoặc vượt ngân sách tìm)" % (a["id"], b["id"]))))
    for n in ns:
        for k, e in enumerate(n["exceptions"]):
            v = M.search([n["condition"], e], lambda v: M.ev(n["condition"], v) and M.ev(e, v))
            (exc.append((n["id"], k, v)) if v is not None else
             unknown.append(("exc", n["id"], k, "ngoại lệ không kích hoạt? %s, ngoại lệ %d: không tìm thấy tình huống nào "
                             "điều kiện chính và ngoại lệ cùng đúng" % (n["id"], k))))
    return M, live, notsub, exc, unknown


def module_text(name, base, M, live, notsub, exc, unknown):
    q = T.lq
    ns = "LexProof.Laws.%s" % base
    L = ["import %s" % ns, "import LexProof.Verify.Drafting", "",
         "/-!", "# %s — drafting-defect check of `%s` (ADR-0030)" % (name, base), "",
         "Written by `pipeline/drafting.py`. Each certificate is one point found by an untrusted search; the kernel",
         "checks it. The theorems say: no norm is dead, no norm is covered by another norm on the same act with the same",
         "modality, and every exception fires somewhere. About the encoded part only; not a statement that the law is",
         "well drafted (a law may repeat a rule on purpose), and nothing here is about conflicts.", "-/", "",
         "namespace LexProof.Laws.%s" % name, "", "open LexProof %s" % ns, "",
         "def liveCert : List (String × List Nat × List Nat) :="]
    L.append(("  [ " + "\n  , ".join("(%s, %s)" % (q(i), M.lean_point(v)[1:-1]) for i, v in live) + " ]") if live else "  []")
    L += ["", "def notSubsumedCert : List (String × String × List Nat × List Nat) :="]
    L.append(("  [ " + "\n  , ".join("(%s, %s, %s)" % (q(a), q(b), M.lean_point(v)[1:-1]) for a, b, v in notsub) + " ]")
             if notsub else "  []")
    L += ["", "def excCert : List (String × Nat × List Nat × List Nat) :="]
    L.append(("  [ " + "\n  , ".join("(%s, %d, %s)" % (q(i), k, M.lean_point(v)[1:-1]) for i, k, v in exc) + " ]")
             if exc else "  []")
    sk = lambda kind: [u for u in unknown if u[0] == kind]
    L += ["", "/-- Items the search found no witness for: possible defects, «không biết». The theorems below exclude",
          "    exactly these; nothing here says they ARE defects. -/",
          "def unknown : List (String × String) :=",
          ("  [ " + "\n  , ".join("(%s, %s)" % (q(u[1] if u[2] is None else "%s / %s" % (u[1], u[2])), q(u[3])) for u in unknown) + " ]")
          if unknown else "  []", "",
          "def liveSkip : List String := [%s]" % ", ".join(q(u[1]) for u in sk("live")),
          "def subSkip : List (String × String) := [%s]" % ", ".join("(%s, %s)" % (q(u[1]), q(u[2])) for u in sk("sub")),
          "def excSkip : List (String × Nat) := [%s]" % ", ".join("(%s, %d)" % (q(u[1]), u[2]) for u in sk("exc")), "",
          "/-! ## Checked by the kernel -/", "",
          "theorem no_dead : ∀ n ∈ norms, n.id ∉ liveSkip → Live (atomsOf tS tP rS rP) n :=",
          "  live_of_check (dec := decodeVal (ts := tS) (tp := tP)) (c := liveCert) (skip := liveSkip) (by decide +kernel)", "",
          "theorem no_redundant : ∀ a ∈ norms, ∀ b ∈ norms, a.id ≠ b.id → SameDuty a b = true → (a.id, b.id) ∉ subSkip →",
          "    NotSubsumed (atomsOf tS tP rS rP) a b :=",
          "  notSubsumed_of_check (dec := decodeVal (ts := tS) (tp := tP)) (c := notSubsumedCert) (skip := subSkip) (by decide +kernel)", "",
          "theorem exceptions_fire : ∀ n ∈ norms, ∀ (k : Nat) (hk : k < n.exceptions.length), (n.id, k) ∉ excSkip →",
          "    ExcFires (atomsOf tS tP rS rP) n n.exceptions[k] :=",
          "  excFires_of_check (dec := decodeVal (ts := tS) (tp := tP)) (c := excCert) (skip := excSkip) (by decide +kernel)", "",
          "end LexProof.Laws.%s" % name, ""]
    return "\n".join(L)


def module(base, name, build=True):
    if not re.match(r"^[A-Z][A-Za-z0-9]*$", name):
        raise SystemExit("--name phải là tên module Lean dạng PascalCase")
    target = os.path.join(P.LAWS, name + ".lean")
    if os.path.exists(target):
        raise SystemExit("đã có %s; không ghi đè" % RUN.rel(target))
    m = merged_of(base)
    M, live, notsub, exc, unknown = scan(m)
    text = module_text(name, base, M, live, notsub, exc, unknown)
    if not build:
        return target, text, (len(live), len(notsub), len(exc), len(unknown))
    old_root, new_root = P.add_import(P.ROOT_FILE, name, "import LexProof.Cert.Audit")
    old_audit, new_audit = P.add_import(P.AUDIT_FILE, name, "import LexProof.Verify.Smoke")
    try:
        with open(target, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        for p, s in ((P.ROOT_FILE, new_root), (P.AUDIT_FILE, new_audit)):
            with open(p, "w", encoding="utf-8", newline="") as f:
                f.write(s)
        r = subprocess.run(["lake", "build"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
        if r.returncode != 0:
            raise RuntimeError((r.stdout + r.stderr)[-3000:])
    except Exception as e:
        for p, s in ((P.ROOT_FILE, old_root), (P.AUDIT_FILE, old_audit)):
            with open(p, "w", encoding="utf-8", newline="") as f:
                f.write(s)
        if os.path.exists(target):
            os.remove(target)
        raise SystemExit("TỪ CHỐI: `lake build` thất bại, đã hoàn tác:\n%s" % e)
    return target, text, (len(live), len(notsub), len(exc), len(unknown))


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("scan")
    p.add_argument("--base", default="Law44")
    p = sub.add_parser("module")
    p.add_argument("--base", default="Law44")
    p.add_argument("--name", required=True)
    p.add_argument("--no-build", action="store_true")
    a = ap.parse_args(argv)
    if a.cmd == "scan":
        _, live, notsub, exc, unknown = scan(merged_of(a.base))
        print("chứng nhân: %d norm sống, %d cặp không bao trùm, %d ngoại lệ có kích hoạt; không biết: %d"
              % (len(live), len(notsub), len(exc), len(unknown)))
        for u in unknown:
            print("  - " + u[3])
        return 0
    target, text, n = module(a.base, a.name, build=not a.no_build)
    if a.no_build:
        sys.stdout.write(text)
    else:
        print("đã ghi %s (%d, %d, %d chứng nhân; %d không biết) và chạy `lake build` thành công" % ((RUN.rel(target),) + n))
    return 0


if __name__ == "__main__":
    sys.exit(main())
