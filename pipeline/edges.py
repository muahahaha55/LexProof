# -*- coding: utf-8 -*-
"""Entailment edges between acts («A kéo theo B», ADR-0029). UNTRUSTED tool; it proves nothing.

    python pipeline/edges.py check  data/edges/44-2019-QH14.json
    python pipeline/edges.py draft  data/edges/44-2019-QH14.json [--module Law44] [--out-dir eval/edges]
        runs Lean on the reviewed module plus every edge not rejected, and lists the conflicts and the edges on
        their paths: those, and only those, are the edges a reviewer must decide first.
    python pipeline/edges.py sheet  data/edges/44-2019-QH14.json -o SHEET.md [--ids E9 E10]
    python pipeline/edges.py apply  data/edges/44-2019-QH14.json SHEET.md
    python pipeline/edges.py module data/edges/44-2019-QH14.json --name Law44Edges [--module Law44] [--no-build]
        writes a `LexProof/Laws/` module from the APPROVED edges only, with kernel theorems.

An edge says: doing `src` entails doing `dst`. It is a reading of the law that the text does not state, so it is
data with a source, a reading in words and a review status, like a derived norm (ADR-0028). The derivation itself is
done in Lean (`LexProof/Verify/Entail.lean`, `derive`), where it is proved sound (`derive_sound`,
`conflict_derived_meaning`). A result that uses edges is about the edges, never a fact about the law, and it never
changes the conclusion of the module it builds on.
"""
import argparse
import datetime
import hashlib
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402
import glossary as G    # noqa: E402

ROOT = T.ROOT
ID = re.compile(r"^E\d+$")
REVIEW_KEYS = ("status", "reviewed_by", "reviewed_on", "review_note", "reviewed_content_sha256")
SHA_LINE = re.compile(r"^sha256 tệp cạnh:\s*`?([0-9a-f]{64})`?\s*$", re.M)
LABEL = re.compile(r"SUY RA \[([^\]]+?) ⇒ ([^\]]+?)\] ")


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def content_sha(e):
    body = {k: e[k] for k in e if k not in REVIEW_KEYS}
    return hashlib.sha256(json.dumps(body, ensure_ascii=False, sort_keys=True).encode("utf-8")).hexdigest()


def live(dd):
    """Edges that take part in a draft run: every edge not rejected (proposed ones too, marked as such)."""
    return [e for e in dd.get("edges", []) if e.get("status") != "rejected"]


def approved(dd):
    return [e for e in dd.get("edges", []) if e.get("status") == "approved"]


# ------------------------------------------------------------------ check

def check(dd):
    """Findings (strings); empty means no structural finding, NOT that an edge is right."""
    out = []
    for k in ("doc_id", "glossary", "edges"):
        if k not in dd:
            out.append("thiếu khóa «%s»" % k)
    if out:
        return out
    seg = T.load_segmented(dd["doc_id"])
    probe = {"doc_id": dd["doc_id"], "glossary": dd["glossary"], "atoms": {"situation": [], "parameters": []}}
    acts, _, _, rejected = T.glossary_terms(probe, out)
    ids = [e.get("id") for e in dd["edges"]]
    for i in sorted({i for i in ids if ids.count(i) > 1}, key=str):
        out.append("id trùng: %s" % i)
    pairs = [(e.get("src"), e.get("dst")) for e in dd["edges"]]
    for p in sorted({p for p in pairs if pairs.count(p) > 1}, key=str):
        out.append("cạnh trùng: %s ⇒ %s" % p)
    for e in dd["edges"]:
        w = "cạnh «%s»" % e.get("id")
        if not isinstance(e.get("id"), str) or not ID.match(e["id"]):
            out.append("%s: id phải có dạng E1, E2, ..." % w)
        if e.get("status") != "rejected":
            for k in ("src", "dst"):
                if e.get(k) not in acts:
                    out.append("%s: %s «%s» %s" % (w, k, e.get(k), "là mục bị bác" if e.get(k) in rejected
                                                   else "không có trong bảng thuật ngữ"))
        if e.get("src") == e.get("dst"):
            out.append("%s: hai đầu cạnh trùng nhau" % w)
        if any(ch in str(e.get(k, "")) for k in ("src", "dst") for ch in "[]⇒"):
            out.append("%s: id act không được chứa «[», «]» hay «⇒» (chúng đánh dấu norm suy ra)" % w)
        T.check_ref(seg, e.get("source"), w + ", source", out)
        for k, why in (("reading", "cách đọc, bằng lời"), ("proposed_by", "ai đề xuất")):
            if not e.get(k):
                out.append("%s: thiếu «%s» (%s)" % (w, k, why))
        G.check_status(e, w, out)
        if e.get("status") in ("approved", "rejected"):
            if not e.get("reviewed_content_sha256"):
                out.append("%s: trạng thái «%s» chỉ được ghi bằng `edges.py apply`" % (w, e["status"]))
            elif e["reviewed_content_sha256"] != content_sha(e):
                out.append("%s: nội dung đã đổi sau khi duyệt; đặt lại «status» thành «proposed» và duyệt lại" % w)
    return out


# ------------------------------------------------------------------ Lean text

def edges_lean(es):
    q = T.lq
    if not es:
        return "def edges : List Edge := []"
    return "def edges : List Edge :=\n  [ " + "\n  , ".join(
        "{ src := %s, dst := %s, source := %s, reading := %s }" % (q(e["src"]), q(e["dst"]), q(e["source"]), q(e["reading"]))
        for e in es) + " ]"


def header(es, what):
    L = ["/-!", "# %s" % what, "",
         "Edges («doing src entails doing dst», ADR-0029); every derived norm carries its edge in its id («SUY RA [A ⇒ B] …»).",
         "A result here is about these edges, never a fact about the law, and it does not change the conclusion of the",
         "module the norms come from.", ""]
    L += ["* %s `%s ⇒ %s` [%s, đề xuất bởi %s; nguồn %s]: %s" % (
        e["id"], e["src"], e["dst"], e["status"] + (", %s %s" % (e.get("reviewed_by"), e.get("reviewed_on"))
                                                   if e["status"] != "proposed" else ""),
        e["proposed_by"], e["source"], e["reading"].replace("-/", "- /")) for e in es]
    return L + ["-/", ""]


def draft_text(es, module):
    m = "LexProof.Laws.%s" % module
    return "\n".join(["import %s" % m, "import LexProof.Verify.Entail", ""] +
                     header(es, "DRAFT, NOT HUMAN-REVIEWED: %s with the edges below (proposed edges included)" % module) +
                     ["namespace DraftEdges", "open LexProof %s" % m, "", edges_lean(es), "",
                      "def allNorms : List Norm := norms ++ derive edges norms",
                      "def allActs : List Act := (allNorms.map (·.act)).eraseDups", "", "end DraftEdges", "",
                      "open LexProof %s DraftEdges in" % m, "def main : IO Unit := do",
                      "  IO.println s!\"derived: {(derive edges norms).length}\"",
                      "  IO.println s!\"pfindings: {(pfindings tS tP rS rP catalog allNorms).length}\"",
                      "  for l in (analyzeReport .draft allActs tS tP rS rP catalog allNorms).render do IO.println l", ""])


def module_text(es, name, module, consistent):
    m = "LexProof.Laws.%s" % module
    L = ["import %s" % m, "import LexProof.Verify.Entail", ""]
    L += header(es, "%s — %s with the edges a reviewer approved" % (name, module))
    L += ["namespace LexProof.Laws.%s" % name, "", "open LexProof %s" % m, "", edges_lean(es), "",
          "/-- The reviewed norms of `%s` and the norms derived from them through the approved edges. -/" % module,
          "def allNorms : List Norm := norms ++ derive edges norms", "",
          "def allActs : List Act := (allNorms.map (·.act)).eraseDups", "",
          "/-! ## Checked by the kernel -/", "",
          "theorem silent : pfindings tS tP rS rP catalog allNorms = [] := by decide +kernel", ""]
    if consistent:
        L += ["theorem consistent :",
              "    analyzeP tS tP rS rP catalog allNorms = .consistentOn (projScope tS tP rS rP allNorms) := by",
              "  decide +kernel", ""]
    else:
        L += ["/-- At least one formal conflict once the edges are read into the law; `report` lists the pairs, and",
              "    `conflict_derived_meaning` says what a pair with a derived norm means. -/",
              "theorem has_conflict : (analyzeP tS tP rS rP catalog allNorms).isConsistentOn = false := by decide +kernel", ""]
    L += ["/-- What `analyzeReport` prints (the status is the one of `%s`; the edges have their own, above). -/" % module,
          "def report : List String := (analyzeReport status allActs tS tP rS rP catalog allNorms).render", "",
          "end LexProof.Laws.%s" % name, ""]
    return "\n".join(L)


def run_lean(path):
    r = subprocess.run(["lake", "env", "lean", "--run", path], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    return r.returncode == 0, r.stdout, r.stderr


PAIR = re.compile(r"^  · (.+) × (.+)$")


def chain(norm_id):
    """The edges in a derived norm's id, outermost first, and the id of the original norm."""
    edges = []
    while True:
        m = LABEL.match(norm_id)
        if not m:
            return edges, norm_id
        edges.append((m.group(1), m.group(2)))
        norm_id = norm_id[m.end():]


def draft(path, module="Law44", out_dir=None, today=None):
    dd = load(path)
    fs = check(dd)
    if fs:
        raise SystemExit("TỪ CHỐI: tệp cạnh có %d phát hiện; chạy `check` và sửa trước" % len(fs))
    es = live(dd)
    today = today or datetime.date.today().isoformat()
    out_dir = out_dir or os.path.join(ROOT, "eval", "edges")
    os.makedirs(out_dir, exist_ok=True)
    stem = "%s-%s" % (dd["doc_id"].replace("/", "-"), today)
    lp = os.path.join(out_dir, stem + ".lean")
    with open(lp, "w", encoding="utf-8", newline="\n") as f:
        f.write(draft_text(es, module))
    ok, out, err = run_lean(lp)
    by_label = {(e["src"], e["dst"]): e for e in es}
    pairs = [m.groups() for m in map(PAIR.match, out.splitlines()) if m] if ok else []
    need = {}
    for p in pairs:
        for x in p:
            for lab in chain(x)[0]:
                if lab in by_label:
                    need[by_label[lab]["id"]] = by_label[lab]
    res = next((l for l in out.splitlines() if l.startswith("KẾT QUẢ")), "KẾT QUẢ: không chạy được Lean")
    der = next((l for l in out.splitlines() if l.startswith("derived:")), "")
    L = ["# Chạy nháp với cạnh kéo theo: %s, %s" % (module, today), "",
         "> NHÁP, CHƯA AI DUYỆT. Dùng mọi cạnh chưa bị bác, kể cả cạnh `proposed` do AI đề xuất. Kết quả nói về các cạnh, "
         "**không** nói về luật, và không đổi kết luận của `%s`. Tệp này không phải báo cáo trong `reports/`." % module, "",
         "- Tệp cạnh: `%s` (sha256 `%s`)" % (G.rel(path), G.sha_lf(path)),
         "- Cạnh dùng: %d (approved %d, proposed %d); %s" % (len(es), len(approved(dd)), len(es) - len(approved(dd)),
                                                              der.replace("derived:", "norm suy ra:")),
         "- Lean: %s (Evaluated, chạy mã; định lý kernel chỉ có trong module do `edges.py module` viết)" % (
             "chạy được" if ok else "LỖI"), "", "## Kết quả", "", res, ""]
    if not ok:
        L += ["```", (err or out)[-3000:], "```", ""]
    for l, r in pairs:
        L.append("- `%s` × `%s`" % (l, r))
        for x in (l, r):
            es_x, orig = chain(x)
            if es_x:
                L.append("  - `%s` suy ra từ `%s` qua %s" % (x, orig, " ; ".join("%s ⇒ %s" % e for e in reversed(es_x))))
    origins = sorted({tuple(sorted((chain(l)[1], chain(r)[1]))) for l, r in pairs})
    if pairs:
        L += ["", "Theo norm gốc (một cặp hiện hai lần khi cả hai chiều truyền đều cho ra nó): %d cặp norm gốc." % len(origins)]
        L += ["- `%s` × `%s`" % o for o in origins]
    L += ["", "## Cạnh cần người duyệt trước (nằm trên đường dẫn tới một cặp xung đột)", ""]
    L += ["- %s `%s ⇒ %s` [%s]: %s (nguồn %s)" % (e["id"], e["src"], e["dst"], e["status"], e["reading"], e["source"])
          for e in sorted(need.values(), key=lambda e: int(e["id"][1:]))] or ["- (không có)"]
    rest = [e for e in es if e["id"] not in need]
    L += ["", "Các cạnh còn lại (%d) không nằm trên đường xung đột nào: đúng hay sai, chúng không đổi kết quả này." % len(rest), ""]
    rp = os.path.join(out_dir, stem + ".md")
    with open(rp, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(L))
    return rp, res, sorted(need, key=lambda i: int(i[1:])), pairs


# ------------------------------------------------------------------ review

def make_sheet(path, dd, ids=None):
    import promote as P   # noqa: E402
    esc = P.esc
    pending = [e for e in dd["edges"] if e.get("status") == "proposed" and (not ids or e["id"] in ids)]
    L = ["# Phiếu duyệt cạnh kéo theo: %s" % dd["doc_id"], "",
         "Mỗi hàng là một **cách đọc**: «làm việc ở cột A thì nhất thiết cũng làm việc ở cột B» (ADR-0029). Luật không viết "
         "thẳng các câu này. Đánh dấu **đúng một** ô bằng cách đổi `☐` thành `☒`; đừng xóa lựa chọn hay cột nào.", "",
         "- **Chấp nhận**: trong mọi tình huống luật nói tới, ai làm A thì cũng làm B.",
         "- **Bác**: có tình huống làm A mà không làm B, hoặc hai việc không liên quan. Phải ghi lý do.",
         "- **Để sau**: chưa quyết.", "",
         "Một cạnh được chấp nhận sẽ làm lệnh cấm B áp cho A, và nghĩa vụ A kéo theo nghĩa vụ B. Một cạnh sai tạo xung đột giả; "
         "thiếu một cạnh có thể che xung đột thật.", "",
         "Tệp cạnh: `%s`" % G.rel(path), "", "sha256 tệp cạnh: %s" % G.sha_lf(path), "",
         "Người duyệt: ", "", "Ngày duyệt (YYYY-MM-DD): ", "",
         "| Mã | A (làm việc này) | B (thì cũng làm việc này) | Nguồn | Cách đọc | Quyết định | Lý do (bắt buộc nếu bác) |",
         "|---|---|---|---|---|---|---|"]
    for e in pending:
        L.append("| E:%s | `%s` | `%s` | %s | %s (đề xuất bởi %s) | %s |  |" % (
            esc(e["id"]), esc(e["src"]), esc(e["dst"]), esc(e["source"]), esc(e["reading"]), esc(e["proposed_by"]), G.OPTIONS))
    if not pending:
        L.append("| — | (không có cạnh nào chờ duyệt) | | | | | |")
    L.append("")
    return "\n".join(L)


def sheet_problems(dd, path, text):
    import promote as P   # noqa: E402
    sheet = P.parse_sheet(text, kinds="E")
    out, dec = [], {}
    s = SHA_LINE.search(text)
    if not s or s.group(1) != G.sha_lf(path):
        out.append("sha256 tệp cạnh trong phiếu khác tệp hiện tại (tệp đã đổi sau khi lập phiếu, hoặc phiếu của tệp khác)")
    if not sheet["reviewer"]:
        out.append("chưa ghi người duyệt")
    try:
        datetime.date.fromisoformat(sheet["date"])
    except ValueError:
        out.append("ngày duyệt phải có dạng YYYY-MM-DD")
    if not sheet["rows"]:
        out.append("phiếu không có hàng nào")
    known = {e["id"]: e for e in dd["edges"]}
    for (_, i), cells in sheet["rows"].items():
        e = known.get(i)
        if e is None or e.get("status") != "proposed":
            out.append("%s: không phải cạnh đang chờ duyệt" % i)
            continue
        t, why = P.decision(cells, 5, i)
        if why:
            out.append(why)
        elif G.DECISIONS[t] == "rejected" and not P.reason_of(cells, 6):
            out.append("%s: bác nhưng không ghi lý do" % i)
        else:
            dec[i] = (G.DECISIONS[t], P.reason_of(cells, 6))
    return out, dec, sheet


def apply_sheet(path, sheet_path):
    dd = load(path)
    fs = check(dd)
    if fs:
        raise SystemExit("TỪ CHỐI: tệp cạnh có %d phát hiện; sửa trước" % len(fs))
    with open(sheet_path, encoding="utf-8") as f:
        ps, dec, sheet = sheet_problems(dd, path, f.read())
    if ps:
        raise SystemExit("TỪ CHỐI:\n  - " + "\n  - ".join(ps))
    n = {s: 0 for s in G.DECISIONS}
    for e in dd["edges"]:
        if e["id"] in dec:
            st, why = dec[e["id"]]
            n[st] += 1
            if why:
                e["review_note"] = why
            if st != "proposed":
                e.update(status=st, reviewed_by=sheet["reviewer"], reviewed_on=sheet["date"])
                e["reviewed_content_sha256"] = content_sha(e)
    fs = check(dd)
    if fs:
        raise SystemExit("TỪ CHỐI: sau khi áp phiếu tệp có phát hiện (không ghi): %s" % fs)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(dd, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return "đã ghi %s: chấp nhận %d, bác %d, để sau %d." % (G.rel(path), n["approved"], n["rejected"], n["proposed"])


# ------------------------------------------------------------------ module (approved edges only)

def module(path, name, base="Law44", build=True):
    import promote as P   # noqa: E402
    dd = load(path)
    fs = check(dd)
    if fs:
        raise SystemExit("TỪ CHỐI: tệp cạnh có %d phát hiện" % len(fs))
    es = approved(dd)
    if not es:
        raise SystemExit("TỪ CHỐI: chưa có cạnh nào được duyệt (approved); chỉ cạnh đã duyệt mới vào thư viện")
    if not re.match(r"^[A-Z][A-Za-z0-9]*$", name):
        raise SystemExit("--name phải là tên module Lean dạng PascalCase")
    target = os.path.join(P.LAWS, name + ".lean")
    if os.path.exists(target):
        raise SystemExit("đã có %s; không ghi đè" % G.rel(target))
    tmp = os.path.join(ROOT, "eval", "edges", "_module_%s.lean" % name)
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    with open(tmp, "w", encoding="utf-8", newline="\n") as f:
        f.write(draft_text(es, base))
    ok, out, err = run_lean(tmp)
    res = next((l for l in out.splitlines() if l.startswith("KẾT QUẢ")), None)
    pf = re.search(r"^pfindings: (\d+)$", out, re.M)
    if not ok or not pf or pf.group(1) != "0" or not res:
        raise SystemExit("TỪ CHỐI: bản nháp không qua Lean (%s)" % ((err or out)[-500:]))
    text = module_text(es, name, base, res.startswith("KẾT QUẢ: consistentOn"))
    if not build:
        return target, text
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
    return target, text


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("check")
    p.add_argument("file")
    p = sub.add_parser("draft")
    p.add_argument("file")
    p.add_argument("--module", default="Law44")
    p.add_argument("--out-dir")
    p = sub.add_parser("sheet")
    p.add_argument("file")
    p.add_argument("-o", "--out", required=True)
    p.add_argument("--ids", nargs="+", help="chỉ các cạnh này (mặc định: mọi cạnh đang chờ duyệt)")
    p = sub.add_parser("apply")
    p.add_argument("file")
    p.add_argument("sheet")
    p = sub.add_parser("module")
    p.add_argument("file")
    p.add_argument("--name", required=True)
    p.add_argument("--module", default="Law44")
    p.add_argument("--no-build", action="store_true")
    a = ap.parse_args(argv)
    if a.cmd == "apply":
        print(apply_sheet(a.file, a.sheet))
        return 0
    if a.cmd == "draft":
        rp, res, need, pairs = draft(a.file, a.module, a.out_dir)
        print("%s\n%s; %d cặp; cạnh cần duyệt trước: %s" % (rp, res, len(pairs), ", ".join(need) or "không có"))
        return 0
    if a.cmd == "module":
        target, text = module(a.file, a.name, a.module, build=not a.no_build)
        if a.no_build:
            sys.stdout.write(text)
        else:
            print("đã ghi %s và chạy `lake build` thành công" % G.rel(target))
        return 0
    dd = load(a.file)
    fs = check(dd)
    if a.cmd == "sheet":
        if fs:
            print("TỪ CHỐI: tệp có %d phát hiện; chạy `check` và sửa trước." % len(fs))
            return 1
        with open(a.out, "w", encoding="utf-8", newline="\n") as f:
            f.write(make_sheet(a.file, dd, a.ids))
        print(a.out)
        return 0
    if fs:
        print("TỪ CHỐI: %d phát hiện:" % len(fs))
        for f in fs:
            print("  - " + f)
        return 1
    n = {s: sum(1 for e in dd["edges"] if e.get("status") == s) for s in G.STATUSES}
    print("không có phát hiện cấu trúc; %d cạnh; proposed %d, approved %d, rejected %d. "
          "Điều này KHÔNG nói cạnh nào đúng." % (len(dd["edges"]), n["proposed"], n["approved"], n["rejected"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
