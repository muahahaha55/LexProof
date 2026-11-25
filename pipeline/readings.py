# -*- coding: utf-8 -*-
"""Alternative readings of the law (ADR-0029, step «nhiều cách đọc»). UNTRUSTED tool; it proves nothing.

    python pipeline/readings.py check data/readings/44-2019-QH14.json
    python pipeline/readings.py run   data/readings/44-2019-QH14.json [--out-dir eval/readings]

Where the text admits more than one reading, the translation picks one and records it as an assumption. A reading
here is a small patch on the reviewed norms of a module (add a conjunct to a condition, add an exception, with new
atoms for what the patch speaks of). `run` checks the module once per reading, with the edges of the edge file that
are not rejected, and prints a table: which conflicts appear under which reading. A conflict that appears under
one reading and not under another is decided by the reading, not by the law; that is what a legal reviewer is
asked to settle.

Nothing here changes a module or a report conclusion. Readings are proposals until a person decides them.
"""
import argparse
import datetime
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402
import run as RUN       # noqa: E402
import edges as E       # noqa: E402

ROOT = T.ROOT
ID = re.compile(r"^R\d+$")
TRANSLATION = re.compile(r"^\* `(eval/translate/[^`]+\.json)` \(sha256 `([0-9a-f]{64})`\)", re.M)


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def module_translations(module):
    """The translation files a promoted module was built from, with the sha256 it recorded."""
    src = open(os.path.join(ROOT, "LexProof", "Laws", module + ".lean"), encoding="utf-8").read()
    return TRANSLATION.findall(src)


def base(dd):
    """The merged norms of the module, from the very translation files it records (refused if one has changed)."""
    files = module_translations(dd["module"])
    if not files:
        raise SystemExit("TỪ CHỐI: module %s không ghi tệp bản dịch nào" % dd["module"])
    for f, sha in files:
        if RUN.sha_lf(os.path.join(ROOT, f)) != sha:
            raise SystemExit("TỪ CHỐI: %s đã đổi sau khi module %s được viết" % (f, dd["module"]))
    seg = T.load_segmented(dd["doc_id"])
    seg["doc_id"] = dd["doc_id"]
    acc, ref, _ = RUN.admit([os.path.join(ROOT, f) for f, _ in files], seg)
    if ref:
        raise SystemExit("TỪ CHỐI: bản dịch không qua `check`: %s" % ref[0][0])
    return RUN.merge(acc), seg


def check(dd, merged=None):
    out = []
    for k in ("doc_id", "module", "edges", "readings"):
        if k not in dd:
            out.append("thiếu khóa «%s»" % k)
    if out:
        return out
    merged = merged or base(dd)[0]
    ids = {n["id"] for n in merged["norms"]}
    have = {a["name"] for k in ("situation", "parameters") for a in merged["atoms"][k]}
    seg = T.load_segmented(dd["doc_id"])
    rids = [r.get("id") for r in dd["readings"]]
    for i in sorted({i for i in rids if rids.count(i) > 1}, key=str):
        out.append("id trùng: %s" % i)
    for r in dd["readings"]:
        w = "cách đọc «%s»" % r.get("id")
        if not isinstance(r.get("id"), str) or not ID.match(r["id"]):
            out.append("%s: id phải có dạng R0, R1, ..." % w)
        for k in ("reading", "proposed_by"):
            if not r.get(k):
                out.append("%s: thiếu «%s»" % (w, k))
        new = set()
        for a in r.get("atoms", []):
            if a.get("name") in have:
                out.append("%s: atom «%s» đã có trong module; atom của cách đọc phải mới" % (w, a.get("name")))
            if a.get("domain") != "bool":
                out.append("%s: atom «%s»: chỉ hỗ trợ miền bool" % (w, a.get("name")))
            T.check_ref(seg, a.get("source"), "%s, atom %s" % (w, a.get("name")), out)
            new.add(a.get("name"))
        for p in r.get("patches", []):
            if p.get("norm") not in ids:
                out.append("%s: không có norm «%s» trong module" % (w, p.get("norm")))
            if not (p.get("add_condition") or p.get("add_exception")):
                out.append("%s: patch của «%s» phải có add_condition hoặc add_exception" % (w, p.get("norm")))
            for k in ("add_condition", "add_exception"):
                if p.get(k):
                    atoms = T.cond_atoms(p[k], set())
                    for a in atoms - new - have:
                        out.append("%s: patch dùng atom «%s» không có" % (w, a))
    return out


def apply(merged, r):
    """`merged` with reading `r` applied: new atoms appended, patched norms changed. Returns a new dict."""
    m = json.loads(json.dumps(merged))
    for a in r.get("atoms", []):
        m["atoms"]["situation"].append({"name": a["name"], "source": a["source"], "domain": "bool"})
    for p in r.get("patches", []):
        for n in m["norms"]:
            if n["id"] == p["norm"]:
                if p.get("add_condition"):
                    n["condition"] = {"and": [n["condition"], p["add_condition"]]}
                if p.get("add_exception"):
                    n["exceptions"] = n["exceptions"] + [p["add_exception"]]
    return m


def lean_text(m, seg, es):
    """The draft of `translate.to_lean` with the edges added: its `main` checks `norms ++ derive edges norms`."""
    t = T.to_lean(m, seg)
    head, _, _ = t.partition("open LexProof Draft in\ndef main")
    head = head.replace("import LexProof.Core.Render\n", "import LexProof.Core.Render\nimport LexProof.Verify.Entail\n", 1)
    head = head.replace("end Draft\n", E.edges_lean(es) + "\n\ndef allNorms : List Norm := norms ++ derive edges norms\n"
                        "def allActs : List Act := (allNorms.map (·.act)).eraseDups\n\nend Draft\n", 1)
    return head + "\n".join(["open LexProof Draft in", "def main : IO Unit := do",
                             "  IO.println s!\"pfindings: {(pfindings tS tP rS rP catalog allNorms).length}\"",
                             "  for l in (analyzeReport .draft allActs tS tP rS rP catalog allNorms).render do IO.println l",
                             "  for l in counterexampleLines tS tP (analyzeP tS tP rS rP catalog allNorms) do IO.println l", ""])


def run(path, out_dir=None, today=None):
    dd = load(path)
    merged, seg = base(dd)
    fs = check(dd, merged)
    ed = E.load(os.path.join(ROOT, dd["edges"]))
    fs += ["tệp cạnh: " + f for f in E.check(ed)]
    if fs:
        raise SystemExit("TỪ CHỐI: %d phát hiện:\n  - %s" % (len(fs), "\n  - ".join(fs)))
    es = E.live(ed)
    today = today or datetime.date.today().isoformat()
    out_dir = out_dir or os.path.join(ROOT, "eval", "readings")
    os.makedirs(out_dir, exist_ok=True)
    rows = []
    for r in [{"id": "R0", "reading": "như các bản dịch đã duyệt (không sửa gì)", "proposed_by": "—"}] + dd["readings"]:
        lp = os.path.join(out_dir, "%s-%s.lean" % (today, r["id"]))
        with open(lp, "w", encoding="utf-8", newline="\n") as f:
            f.write(lean_text(apply(merged, r), seg, es))
        res = RUN.run_lean(lp)
        pairs = RUN.conflict_pairs(res)
        origins = sorted({tuple(sorted((E.chain(a)[1], E.chain(b)[1]))) for a, b in pairs})
        rows.append({"id": r["id"], "reading": r["reading"], "by": r["proposed_by"], "ok": res["ok"],
                     "pfindings": res.get("pfindings"), "result": res.get("result"), "origins": origins})
    allo = sorted({o for x in rows for o in x["origins"]})
    L = ["# Chạy theo nhiều cách đọc: %s, %s" % (dd["module"], today), "",
         "> NHÁP, CHƯA AI DUYỆT. Mỗi cách đọc là một đề xuất; cạnh dùng mọi cạnh chưa bị bác (kể cả `proposed`). Kết quả nói "
         "về cách đọc, **không** nói về luật, và không đổi kết luận của module. Tệp này không phải báo cáo trong `reports/`.", "",
         "- Tệp cách đọc: `%s` (sha256 `%s`)" % (RUN.rel(path), RUN.sha_lf(path)),
         "- Tệp cạnh: `%s` (sha256 `%s`), %d cạnh dùng" % (dd["edges"], RUN.sha_lf(os.path.join(ROOT, dd["edges"])), len(es)),
         "- Lean: Evaluated (chạy mã), không phải định lý kernel", "", "## Các cách đọc", ""]
    for x in rows:
        L.append("- **%s** (%s): %s" % (x["id"], x["by"], x["reading"]))
    L += ["", "## Cặp norm gốc xung đột theo từng cách đọc", "",
          "| Cặp | " + " | ".join(x["id"] for x in rows) + " |", "|---|" + "---|" * len(rows)]
    for o in allo:
        L.append("| `%s` × `%s` | " % o + " | ".join("XUNG ĐỘT" if o in x["origins"] else "—" for x in rows) + " |")
    if not allo:
        L.append("| (không có cặp nào) | " + " | ".join("—" for _ in rows) + " |")
    L += ["| *kết quả Lean* | " + " | ".join(
        (x["result"] or "lỗi") + ("" if x["pfindings"] in (0, None) else " (pfindings %s)" % x["pfindings"]) for x in rows) + " |", ""]
    dep = [o for o in allo if not all(o in x["origins"] for x in rows)]
    L += ["## Đọc kết quả", "",
          "Cặp nào có ở cách đọc này mà không có ở cách đọc kia thì **do cách đọc quyết định**, không do chữ luật: người học "
          "luật cần chọn cách đọc. Cặp có ở mọi cách đọc thì bền theo các cách đọc đã thử (không phải theo mọi cách đọc có thể).", ""]
    L += ["- Phụ thuộc cách đọc: %d cặp; bền theo các cách đọc đã thử: %d cặp." % (len(dep), len(allo) - len(dep)), ""]
    rp = os.path.join(out_dir, "%s-%s.md" % (dd["doc_id"].replace("/", "-"), today))
    with open(rp, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(L))
    return rp, rows


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("check")
    p.add_argument("file")
    p = sub.add_parser("run")
    p.add_argument("file")
    p.add_argument("--out-dir")
    a = ap.parse_args(argv)
    if a.cmd == "run":
        rp, rows = run(a.file, a.out_dir)
        print(rp)
        for x in rows:
            print("  %s: %s; %d cặp norm gốc" % (x["id"], x["result"], len(x["origins"])))
        return 0
    fs = check(load(a.file))
    if fs:
        print("TỪ CHỐI: %d phát hiện:" % len(fs))
        for f in fs:
            print("  - " + f)
        return 1
    print("không có phát hiện cấu trúc. Điều này KHÔNG nói cách đọc nào đúng.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
