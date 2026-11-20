# -*- coding: utf-8 -*-
"""Derived norms (ADR-0028). UNTRUSTED tool; it proves nothing.

    python pipeline/derived.py check data/derived/44-2019-QH14.json
    python pipeline/derived.py sheet data/derived/44-2019-QH14.json -o SHEET.md    review sheet for the `proposed` readings
    python pipeline/derived.py apply data/derived/44-2019-QH14.json SHEET.md       write a complete sheet's decisions

A derived norm is a norm the text does **not** state in words but that a reader infers from it, for example
«có giấy phép thì được kinh doanh rượu» from the prohibition in Điều 5 khoản 11 and the licensing regime of Điều 15.
Two articles that regulate different acts (a business; an authority granting a licence) can only be checked against
each other through such a reading, so the reading is written down, sourced, and reviewed like any other term.

A derived norm uses glossary ids only (ADR-0027), names the units it is inferred from (`derived_from`) and says the
inference in words (`reading`). `run.py --derived FILE` checks the law twice: as written, and with the derived norms
added; a result of the second run depends on the readings and is reported as such, never as a fact about the law.
"""
import argparse
import datetime
import hashlib
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402
import glossary as G    # noqa: E402

DERIVED = {"44/2019/QH14": "data/derived/44-2019-QH14.json"}
ID = re.compile(r"^D\d+$")
PREFIX = "SUY RA "      # norm ids in Lean: «SUY RA D1», so a reader of any report sees which norms are not the text


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def check(dd):
    """Findings (strings); empty means no structural finding, NOT that a reading is right."""
    out = []
    for k in ("doc_id", "glossary", "derived"):
        if k not in dd:
            out.append("thiếu khóa «%s»" % k)
    if out:
        return out
    seg = T.load_segmented(dd["doc_id"])
    probe = {"doc_id": dd["doc_id"], "glossary": dd["glossary"], "atoms": {"situation": [], "parameters": []}}
    acts, sit, par, rejected = T.glossary_terms(probe, out)
    ids = [e.get("id") for e in dd["derived"]]
    dup = sorted({i for i in ids if ids.count(i) > 1})
    if dup:
        out.append("id trùng: %s" % ", ".join(map(str, dup)))
    for e in dd["derived"]:
        w = "norm suy ra «%s»" % e.get("id")
        if not isinstance(e.get("id"), str) or not ID.match(e["id"]):
            out.append("%s: id phải có dạng D1, D2, ..." % w)
        if e.get("modality") not in T.MODALITIES:
            out.append("%s: modality phải là một trong %s" % (w, sorted(T.MODALITIES)))
        if e.get("act") not in acts:
            out.append("%s: act «%s» %s" % (w, e.get("act"), "là mục bị bác" if e.get("act") in rejected
                                            else "không có trong bảng thuật ngữ"))
        T.walk_cond(e.get("condition"), sit, par, w + ".condition", out)
        if not isinstance(e.get("exceptions"), list):
            out.append("%s: exceptions phải là danh sách" % w)
        else:
            for i, c in enumerate(e["exceptions"]):
                T.walk_cond(c, sit, par, "%s.exceptions[%d]" % (w, i), out)
        src = e.get("derived_from")
        if not isinstance(src, list) or not src:
            out.append("%s: «derived_from» phải là danh sách không rỗng các đơn vị suy ra từ đó" % w)
        else:
            for s in src:
                T.check_ref(seg, s, w + ", derived_from", out)
        if not e.get("reading"):
            out.append("%s: thiếu «reading» (cách suy ra, bằng lời)" % w)
        if not e.get("proposed_by"):
            out.append("%s: thiếu «proposed_by» (ai đề xuất cách đọc này)" % w)
        G.check_status(e, w, out)
        out += review_findings(e, w)
    for t in sorted(cond_terms(dd) & rejected):
        out.append("atom «%s» là mục bị bác của bảng thuật ngữ; không được dùng" % t)
    return out


# ------------------------------------------------------------------ review (ADR-0028 step 2)

REVIEW_KEYS = ("status", "reviewed_by", "reviewed_on", "review_note", "reviewed_content_sha256")
SHA_LINE = re.compile(r"^sha256 tệp norm suy ra:\s*`?([0-9a-f]{64})`?\s*$", re.M)


def content_sha(e):
    """sha256 of what a reviewer decides on: every field but the review fields, canonical JSON."""
    body = {k: e[k] for k in e if k not in REVIEW_KEYS}
    return hashlib.sha256(json.dumps(body, ensure_ascii=False, sort_keys=True).encode("utf-8")).hexdigest()


def review_findings(e, w):
    """A decided entry must carry the content hash written by `apply`, and still match it: an approved reading that
    was edited afterwards is not the reading that was approved."""
    if e.get("status") not in ("approved", "rejected"):
        return []
    if not e.get("reviewed_content_sha256"):
        return ["%s: trạng thái «%s» chỉ được ghi bằng `derived.py apply` (thiếu «reviewed_content_sha256»)" % (w, e["status"])]
    if e["reviewed_content_sha256"] != content_sha(e):
        return ["%s: nội dung đã đổi sau khi duyệt; đặt lại «status» thành «proposed» và duyệt lại" % w]
    return []


def make_sheet(path, dd):
    import promote as P   # noqa: E402
    esc = P.esc
    m = T.materialize(as_translation(dd, "law", "2000-01-01"))
    L = ["# Phiếu duyệt norm suy ra: %s" % dd["doc_id"], "",
         "Mỗi hàng là một **cách đọc** mà luật không viết thẳng (ADR-0028). Đánh dấu **đúng một** ô bằng cách đổi `☐` thành `☒`; "
         "đừng xóa lựa chọn hay cột nào.", "",
         "- **Chấp nhận**: từ các đơn vị ở «Suy ra từ», một người đọc luật cẩn thận sẽ rút ra đúng norm này, với đúng điều kiện "
         "và ngoại lệ ghi ở đây (không rộng hơn, không hẹp hơn).",
         "- **Bác**: cách đọc sai, hoặc rộng hơn hay hẹp hơn luật. Phải ghi lý do. Nếu chỉ thiếu một ngoại lệ, ghi ngoại lệ đó "
         "vào lý do; người sửa sẽ thêm và mục được duyệt lại.",
         "- **Để sau**: chưa quyết.", "",
         "Gợi ý: mục «Kết quả đầu tiên» của `docs/decisions/0028-derived-norms.md` cho biết mỗi cách đọc va chạm với norm nào "
         "của luật. Một va chạm không tự nó là lý do bác, nhưng cho thấy chỗ cần đọc kỹ.", "",
         "Sau khi duyệt, sửa một mục đã duyệt làm nó hết hiệu lực (công cụ ghi sha256 nội dung lúc duyệt).", "",
         "Tệp norm suy ra: `%s`" % G.rel(path), "", "sha256 tệp norm suy ra: %s" % G.sha_lf(path), "",
         "sha256 bảng thuật ngữ: %s" % m["glossary_sha256"], "",
         "Người duyệt: ", "", "Ngày duyệt (YYYY-MM-DD): ", "",
         "## 0. Thuật ngữ các norm suy ra dùng (chỉ để đọc; duyệt ở phiếu bảng thuật ngữ)", ""]
    L += [("  - " + t.strip()) if t.startswith("  ") else ("- " + t) for t in m["glossary_terms"]]
    L += ["", "## 1. Norm suy ra chờ duyệt", "",
          "| Mã | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Suy ra từ | Cách suy ra | Quyết định | Lý do (bắt buộc nếu bác) |",
          "|---|---|---|---|---|---|---|---|---|"]
    pending = [e for e in dd["derived"] if e.get("status") == "proposed"]
    for e in pending:
        ex = "; ".join(P.words(c) for c in e["exceptions"]) or "—"
        L.append("| D:%s | %s | `%s` | %s | %s | %s | %s (đề xuất bởi %s) | %s |  |" % (
            esc(e["id"]), P.MOD[e["modality"]], esc(e["act"]), esc(P.words(e["condition"])), esc(ex),
            esc("; ".join(e["derived_from"])), esc(e["reading"]), esc(e["proposed_by"]), G.OPTIONS))
    if not pending:
        L.append("| — | (không có mục nào chờ duyệt) | | | | | | | |")
    done = [e for e in dd["derived"] if e.get("status") != "proposed"]
    L += ["", "## 2. Đã quyết trước đây (chỉ để đọc)", ""]
    L += ["- `%s`: **%s** bởi %s, %s%s" % (e["id"], e["status"], e.get("reviewed_by"), e.get("reviewed_on"),
                                         (": " + e["review_note"]) if e.get("review_note") else "") for e in done] or ["- (không có)"]
    L.append("")
    return "\n".join(L)


def sheet_problems(dd, path, text):
    """(reasons to refuse, {id: (new status, reason)}, parsed sheet)."""
    import promote as P   # noqa: E402
    sheet = P.parse_sheet(text, kinds="D")
    out, dec = [], {}
    s = SHA_LINE.search(text)
    if not s or s.group(1) != G.sha_lf(path):
        out.append("sha256 tệp norm suy ra trong phiếu khác tệp hiện tại (tệp đã đổi sau khi lập phiếu, hoặc phiếu của tệp khác)")
    if sheet["glossary_sha"] != T.glossary_sha(T.glossary_rel(dd["doc_id"])):
        out.append("sha256 bảng thuật ngữ trong phiếu khác bảng hiện tại (nghĩa của các id có thể đã khác): lập lại phiếu")
    if not sheet["reviewer"]:
        out.append("chưa ghi người duyệt")
    try:
        datetime.date.fromisoformat(sheet["date"])
    except ValueError:
        out.append("ngày duyệt phải có dạng YYYY-MM-DD")
    for e in dd["derived"]:
        if e.get("status") != "proposed":
            continue
        cells = sheet["rows"].get(("D", e["id"]))
        if cells is None:
            out.append("phiếu không có hàng cho %s" % e["id"])
            continue
        t, why = P.decision(cells, 7, e["id"])
        if why:
            out.append(why)
        elif t > 2:
            out.append("%s: cần đánh dấu đúng một ô" % e["id"])
        elif G.DECISIONS[t] == "rejected" and not P.reason_of(cells, 8):
            out.append("%s: bác nhưng không ghi lý do" % e["id"])
        else:
            dec[e["id"]] = (G.DECISIONS[t], P.reason_of(cells, 8))
    return out, dec, sheet


def apply_sheet(path, sheet_path):
    """Writes the decisions of a complete sheet into the derived file. Returns a summary; SystemExit on refusal."""
    dd = load(path)
    fs = check(dd)
    if fs:
        raise SystemExit("TỪ CHỐI: tệp norm suy ra có %d phát hiện; sửa trước" % len(fs))
    with open(sheet_path, encoding="utf-8") as f:
        ps, dec, sheet = sheet_problems(dd, path, f.read())
    if ps:
        raise SystemExit("TỪ CHỐI:\n  - " + "\n  - ".join(ps))
    n = {s: 0 for s in G.DECISIONS}
    for e in dd["derived"]:
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


def cond_terms(dd):
    atoms = set()
    for e in dd.get("derived", []):
        for c in [e.get("condition")] + (e["exceptions"] if isinstance(e.get("exceptions"), list) else []):
            T.cond_atoms(c, atoms)
    return atoms


def as_translation(dd, doc_type, effective):
    """The derived norms as a glossary-mode translation, so that `translate.materialize` and `run.merge` treat them
    like any article: one atom per glossary id. Lean needs one parsable source per norm: the first `derived_from`;
    the id («SUY RA D1») and the header say it is not the text. Call only on a file `check` accepted."""
    norms = [{"id": PREFIX + e["id"], "modality": e["modality"], "act": e["act"], "condition": e["condition"],
              "exceptions": e["exceptions"], "source": e["derived_from"][0], "quote": "", "references": []}
             for e in dd["derived"]]
    return {"doc_id": dd["doc_id"], "doc_type": doc_type, "effective": effective, "article": 0,
            "glossary": dd["glossary"], "atoms": {"situation": [], "parameters": []}, "glossary_proposals": {},
            "norms": norms, "not_encoded": [],
            "assumptions": ["%s%s [%s, đề xuất bởi %s] suy ra từ %s: %s" % (PREFIX, e["id"], e["status"], e["proposed_by"],
                                                                        "; ".join(e["derived_from"]), e["reading"])
                            for e in dd["derived"]]}


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("check")
    p.add_argument("file")
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
    dd = load(a.file)
    if a.cmd == "sheet":
        fs = check(dd)
        if fs:
            print("TỪ CHỐI: tệp có %d phát hiện; chạy `check` và sửa trước." % len(fs))
            return 1
        with open(a.out, "w", encoding="utf-8", newline="\n") as f:
            f.write(make_sheet(a.file, dd))
        print(a.out)
        return 0
    fs = check(dd)
    if fs:
        print("TỪ CHỐI: %d phát hiện:" % len(fs))
        for f in fs:
            print("  - " + f)
        return 1
    n = {s: sum(1 for e in dd["derived"] if e.get("status") == s) for s in G.STATUSES}
    print("không có phát hiện cấu trúc; %d norm suy ra; proposed %d, approved %d, rejected %d. "
          "Điều này KHÔNG nói cách suy ra đúng." % (len(dd["derived"]), n["proposed"], n["approved"], n["rejected"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
