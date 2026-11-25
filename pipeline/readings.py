# -*- coding: utf-8 -*-
"""Alternative readings of the law (ADR-0029, step «nhiều cách đọc»). UNTRUSTED tool; it proves nothing.

    python pipeline/readings.py check data/readings/44-2019-QH14.json
    python pipeline/readings.py run   data/readings/44-2019-QH14.json [--out-dir eval/readings]
    python pipeline/readings.py sheet data/readings/44-2019-QH14.json -o SHEET.md     choose one reading (R0 = as reviewed)
    python pipeline/readings.py apply data/readings/44-2019-QH14.json SHEET.md

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
import glossary as G    # noqa: E402

ROOT = T.ROOT
ID = re.compile(r"^R\d+$")
REVIEW_KEYS = ("status", "reviewed_by", "reviewed_on", "review_note", "reviewed_content_sha256")
SHA_LINE = re.compile(r"^sha256 tệp cách đọc:\s*`?([0-9a-f]{64})`?\s*$", re.M)
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
        if r.get("id") == "R0" and (r.get("atoms") or r.get("patches")):
            out.append("%s: R0 là cách đọc theo đúng các bản dịch đã duyệt, không được có atom hay patch" % w)
        G.check_status(dict(r, status=r.get("status", "proposed")), w, out)
        if r.get("status") in ("approved", "rejected"):
            if not r.get("reviewed_content_sha256"):
                out.append("%s: trạng thái «%s» chỉ được ghi bằng `readings.py apply`" % (w, r["status"]))
            elif r["reviewed_content_sha256"] != content_sha(r):
                out.append("%s: nội dung đã đổi sau khi duyệt; đặt lại «status» thành «proposed» và duyệt lại" % w)
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
    chosen = [r.get("id") for r in dd["readings"] if r.get("status") == "approved"]
    if len(chosen) > 1:
        out.append("các cách đọc là phương án thay thế nhau; chỉ được chấp nhận một, đang có %s" % ", ".join(chosen))
    return out


def content_sha(r):
    import hashlib
    body = {k: r[k] for k in r if k not in REVIEW_KEYS}
    return hashlib.sha256(json.dumps(body, ensure_ascii=False, sort_keys=True).encode("utf-8")).hexdigest()


R0 = {"id": "R0", "reading": "Theo đúng các bản dịch đã duyệt, không thêm gì: nếu một cặp xung đột hiện ra ở đây thì đó là mâu thuẫn theo chữ luật.", "proposed_by": "—", "status": "proposed"}


def candidates(dd):
    """R0 (from the file if it is there, else the implicit one) and the other readings, in file order."""
    rs = dd["readings"]
    return rs if any(r.get("id") == "R0" for r in rs) else [R0] + rs


def make_sheet(path, dd):
    import promote as P   # noqa: E402
    esc = P.esc
    L = ["# Phiếu chọn cách đọc: %s, module %s" % (dd["doc_id"], dd["module"]), "",
         "Các hàng dưới đây là **các cách đọc thay thế nhau** của cùng một chỗ trong luật. Chấp nhận **nhiều nhất một** hàng "
         "(cách đọc đúng); bác các hàng sai, kèm lý do. Đổi `☐` thành `☒` ở đúng một ô mỗi hàng.", "",
         "Bảng kết quả theo từng cách đọc: chạy `python pipeline/readings.py run %s`." % RUN.rel(path), "",
         "Tệp cách đọc: `%s`" % RUN.rel(path), "", "sha256 tệp cách đọc: %s" % RUN.sha_lf(path), "",
         "Người duyệt: ", "", "Ngày duyệt (YYYY-MM-DD): ", "",
         "| Mã | Cách đọc | Thay đổi so với bản dịch đã duyệt | Quyết định | Lý do (bắt buộc nếu bác) |",
         "|---|---|---|---|---|"]
    for r in candidates(dd):
        if r.get("status", "proposed") != "proposed":
            continue
        ch = "; ".join("%s: %s%s" % (x["norm"], ("thêm điều kiện " + P.words(x["add_condition"])) if x.get("add_condition") else "",
                                      (" thêm ngoại lệ " + P.words(x["add_exception"])) if x.get("add_exception") else "")
                       for x in r.get("patches", [])) or "không đổi gì"
        L.append("| R:%s | %s (đề xuất bởi %s) | %s | %s |  |" % (r["id"], esc(r["reading"]), esc(r["proposed_by"]), esc(ch), G.OPTIONS))
    L.append("")
    return "\n".join(L)


def sheet_problems(dd, path, text):
    import promote as P   # noqa: E402
    sheet = P.parse_sheet(text, kinds="R")
    out, dec = [], {}
    s = SHA_LINE.search(text)
    if not s or s.group(1) != RUN.sha_lf(path):
        out.append("sha256 tệp cách đọc trong phiếu khác tệp hiện tại")
    if not sheet["reviewer"]:
        out.append("chưa ghi người duyệt")
    try:
        datetime.date.fromisoformat(sheet["date"])
    except ValueError:
        out.append("ngày duyệt phải có dạng YYYY-MM-DD")
    known = {r["id"]: r for r in candidates(dd)}
    for (_, i), cells in sheet["rows"].items():
        if i not in known or known[i].get("status", "proposed") != "proposed":
            out.append("%s: không phải cách đọc đang chờ duyệt" % i)
            continue
        t, why = P.decision(cells, 3, i)
        if why:
            out.append(why)
        elif G.DECISIONS[t] == "rejected" and not P.reason_of(cells, 4):
            out.append("%s: bác nhưng không ghi lý do" % i)
        else:
            dec[i] = (G.DECISIONS[t], P.reason_of(cells, 4))
    if sum(1 for st, _ in dec.values() if st == "approved") > 1:
        out.append("chấp nhận nhiều hơn một cách đọc; các cách đọc thay thế nhau")
    return out, dec, sheet


def apply_sheet(path, sheet_path):
    dd = load(path)
    with open(sheet_path, encoding="utf-8") as f:
        ps, dec, sheet = sheet_problems(dd, path, f.read())
    if ps:
        raise SystemExit("TỪ CHỐI:\n  - " + "\n  - ".join(ps))
    if "R0" in dec and not any(r.get("id") == "R0" for r in dd["readings"]):
        dd["readings"].insert(0, dict(R0))
    n = {st: 0 for st in G.DECISIONS}
    for r in dd["readings"]:
        if r["id"] in dec:
            st, why = dec[r["id"]]
            n[st] += 1
            r.setdefault("status", "proposed")
            if why:
                r["review_note"] = why
            if st != "proposed":
                r.update(status=st, reviewed_by=sheet["reviewer"], reviewed_on=sheet["date"])
                r["reviewed_content_sha256"] = content_sha(r)
    fs = check(dd)
    if fs:
        raise SystemExit("TỪ CHỐI: sau khi áp phiếu tệp có phát hiện (không ghi): %s" % fs)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(dd, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return "đã ghi %s: chấp nhận %d, bác %d, để sau %d." % (RUN.rel(path), n["approved"], n["rejected"], n["proposed"])


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
    for r in candidates(dd):
        lp = os.path.join(out_dir, "%s-%s.lean" % (today, r["id"]))
        with open(lp, "w", encoding="utf-8", newline="\n") as f:
            f.write(lean_text(apply(merged, r), seg, es))
        res = RUN.run_lean(lp)
        pairs = RUN.conflict_pairs(res)
        origins = sorted({tuple(sorted((E.chain(a)[1], E.chain(b)[1]))) for a, b in pairs})
        rows.append({"id": r["id"], "reading": r["reading"], "by": r["proposed_by"], "ok": res["ok"],
                     "status": r.get("status", "proposed"),
                     "pfindings": res.get("pfindings"), "result": res.get("result"), "origins": origins})
    allo = sorted({o for x in rows for o in x["origins"]})
    L = ["# Chạy theo nhiều cách đọc: %s, %s" % (dd["module"], today), "",
         "> NHÁP, CHƯA AI DUYỆT. Mỗi cách đọc là một đề xuất; cạnh dùng mọi cạnh chưa bị bác (kể cả `proposed`). Kết quả nói "
         "về cách đọc, **không** nói về luật, và không đổi kết luận của module. Tệp này không phải báo cáo trong `reports/`.", "",
         "- Tệp cách đọc: `%s` (sha256 `%s`)" % (RUN.rel(path), RUN.sha_lf(path)),
         "- Tệp cạnh: `%s` (sha256 `%s`), %d cạnh dùng" % (dd["edges"], RUN.sha_lf(os.path.join(ROOT, dd["edges"])), len(es)),
         "- Lean: Evaluated (chạy mã), không phải định lý kernel", "", "## Các cách đọc", ""]
    for x in rows:
        L.append("- **%s** (%s; %s): %s" % (x["id"], x["by"], {"approved": "ĐƯỢC CHỌN bởi người duyệt", "rejected": "bị bác",
                                                               "proposed": "chưa duyệt"}[x["status"]], x["reading"]))
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
    p = sub.add_parser("sheet")
    p.add_argument("file")
    p.add_argument("-o", "--out", required=True)
    p = sub.add_parser("apply")
    p.add_argument("file")
    p.add_argument("sheet")
    a = ap.parse_args(argv)
    if a.cmd == "apply":
        print(apply_sheet(a.file, a.sheet))
        return 0
    if a.cmd == "sheet":
        dd = load(a.file)
        fs = check(dd)
        if fs:
            print("TỪ CHỐI: tệp có %d phát hiện; chạy `check` và sửa trước." % len(fs))
            return 1
        with open(a.out, "w", encoding="utf-8", newline="\n") as f:
            f.write(make_sheet(a.file, dd))
        print(a.out)
        return 0
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
