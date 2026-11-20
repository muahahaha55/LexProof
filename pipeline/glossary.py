# -*- coding: utf-8 -*-
"""Per-document glossary of acts and atoms (FR2, ADR-0027 step 1). UNTRUSTED tool; it proves nothing.

    python pipeline/glossary.py check data/glossary/44-2019-QH14.json
    python pipeline/glossary.py sheet data/glossary/44-2019-QH14.json -o SHEET.md    review sheet for the `proposed` entries
    python pipeline/glossary.py apply data/glossary/44-2019-QH14.json SHEET.md       write a complete sheet's decisions

A glossary is data reviewed by a person: every act and atom has an id, a gloss (what it means, in plain words), the
clauses it comes from, and a status (`proposed` until a reviewer approves it). This step only defines the file and
checks it. Translations use the ids (`translate.py prompt --glossary`), `run.py`/`promote.py` merge by id and
`promote.py` refuses terms not `approved` (ADR-0027 steps 2-3). `sheet`/`apply` are the review (step 4): a filled
sheet is the only way this tool changes a status. What it means: a person ticked every row; the tool does not check
who, nor whether the answers are right.
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

ID = re.compile(r"^[a-z0-9]+(?:_[a-z0-9]+)*$")
STATUSES = ("proposed", "approved", "rejected")
KINDS = ("situation", "parameter")


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def check_sources(seg, srcs, where, out):
    if not isinstance(srcs, list) or not srcs:
        out.append("%s: «sources» phải là danh sách không rỗng" % where)
        return
    for s in srcs:
        T.check_ref(seg, s, where, out)


def check_status(e, where, out):
    st = e.get("status")
    if st not in STATUSES:
        out.append("%s: «status» phải là một trong %s" % (where, list(STATUSES)))
    if st in ("approved", "rejected"):
        if not e.get("reviewed_by"):
            out.append("%s: trạng thái «%s» cần «reviewed_by»" % (where, st))
        try:
            datetime.date.fromisoformat(str(e.get("reviewed_on", "")))
        except ValueError:
            out.append("%s: trạng thái «%s» cần «reviewed_on» dạng YYYY-MM-DD" % (where, st))


def check(g):
    """Findings (strings); empty means no structural finding, NOT that the glossary is right."""
    out = []
    for k in ("doc_id", "acts", "atoms"):
        if k not in g:
            out.append("thiếu khóa «%s»" % k)
    if out:
        return out
    seg = T.load_segmented(g["doc_id"])
    for kind in ("acts", "atoms"):
        ids = [e.get("id") for e in g[kind]]
        dup = sorted({i for i in ids if ids.count(i) > 1})
        if dup:
            out.append("%s: id trùng: %s" % (kind, ", ".join(map(str, dup))))
    for e in g["acts"]:
        w = "act «%s»" % e.get("id")
        if not isinstance(e.get("id"), str) or not ID.match(e["id"]):
            out.append("%s: id phải là snake_case không dấu" % w)
        if not e.get("gloss"):
            out.append("%s: thiếu «gloss» (giải thích bằng lời)" % w)
        check_sources(seg, e.get("sources"), w, out)
        check_status(e, w, out)
    for e in g["atoms"]:
        w = "atom «%s»" % e.get("id")
        if not isinstance(e.get("id"), str) or not ID.match(e["id"]):
            out.append("%s: id phải là snake_case không dấu" % w)
        if e.get("kind") not in KINDS:
            out.append("%s: «kind» phải là situation hoặc parameter" % w)
        if not e.get("gloss"):
            out.append("%s: thiếu «gloss» (giải thích bằng lời)" % w)
        check_sources(seg, e.get("sources"), w, out)
        check_status(e, w, out)
        dom = e.get("domain")
        if dom == "bool":
            continue
        if e.get("kind") == "parameter":
            out.append("%s: tham số chỉ được là bool" % w)
        if not isinstance(dom, list) or len(dom) < 2:
            out.append("%s: domain phải là «bool» hoặc danh sách ≥ 2 nhãn" % w)
            continue
        labels = [b.get("label") for b in dom]
        if len(set(labels)) != len(labels):
            out.append("%s: nhãn trùng nhau" % w)
        for b in dom:
            wb = "%s, nhãn «%s»" % (w, b.get("label"))
            if b.get("source"):
                T.check_ref(seg, b["source"], wb, out)
            elif not b.get("note"):
                # a value no clause names (e.g. the complement of a band) must say so, never pass silently
                out.append("%s: không có «source» thì phải có «note» giải thích vì sao luật không nêu" % wb)
    return out


# ------------------------------------------------------------------ review sheet (ADR-0027 step 4)

OPTIONS = "☐ Chấp nhận<br>☐ Bác<br>☐ Để sau"
DECISIONS = ("approved", "rejected", "proposed")      # index of the ticked option -> new status


def entries(g):
    """(row id, kind word, entry) for every act and atom, in file order."""
    return [("act:" + e["id"], "act", e) for e in g["acts"]] + \
           [("atom:" + e["id"], "tham số" if e.get("kind") == "parameter" else "tình huống", e) for e in g["atoms"]]


def domain_words(e):
    if "domain" not in e:
        return "—"
    if e["domain"] == "bool":
        return "đúng / sai"
    return "<br>".join("«%s» (%s)" % (b["label"], b["source"] if b.get("source") else "KHÔNG có nguồn — ghi chú: " + b["note"])
                       for b in e["domain"])


def sha_lf(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read().replace(b"\r\n", b"\n")).hexdigest()


def make_sheet(path, g):
    import promote as P   # noqa: E402
    esc = P.esc
    L = ["# Phiếu duyệt bảng thuật ngữ: %s" % g["doc_id"], "",
         "Mỗi hàng là một act (hành vi) hoặc một atom (khái niệm dùng trong điều kiện). Đánh dấu **đúng một** ô bằng cách đổi "
         "`☐` thành `☒`. Đừng xóa lựa chọn hay cột nào.",
         "",
         "- **Chấp nhận**: giải thích đúng nghĩa của luật, các nguồn đúng, và (với atom có nhãn) các nhãn tách nhau và đủ. "
         "Một id dùng ở nhiều điều sẽ là **một** khái niệm: chỉ chấp nhận nếu mọi điều nêu ở «Nguồn» đều nói cùng một thứ.",
         "- **Bác**: sai nghĩa, gộp hai khái niệm khác nhau, hoặc nhãn sai. Phải ghi lý do. Mục bị bác không được dùng nữa.",
         "- **Để sau**: chưa quyết; mục vẫn chưa duyệt và mọi norm dùng nó vẫn bị chặn.",
         "",
         "Duyệt bảng đi **trước** phiếu norm: sau khi áp phiếu này, mọi phiếu norm lập trước đó hết hiệu lực (chúng ghim sha256 của bảng).",
         "", "Bảng thuật ngữ: `%s`" % rel(path), "", "sha256 bảng thuật ngữ: %s" % sha_lf(path), "",
         "Người duyệt: ", "", "Ngày duyệt (YYYY-MM-DD): ", "",
         "## 1. Mục chờ duyệt", "",
         "| Mã | Loại | Giải thích | Giá trị | Nguồn | Quyết định | Lý do (bắt buộc nếu bác) |",
         "|---|---|---|---|---|---|---|"]
    pending = [(r, k, e) for r, k, e in entries(g) if e.get("status") == "proposed"]
    for r, k, e in pending:
        L.append("| T:%s | %s | %s | %s | %s | %s |  |" % (esc(r), k, esc(e["gloss"]), esc(domain_words(e)).replace("\\|", "/"),
                                                         esc("; ".join(e["sources"])), OPTIONS))
    if not pending:
        L.append("| — | (không có mục nào chờ duyệt) | | | | | |")
    done = [(r, k, e) for r, k, e in entries(g) if e.get("status") != "proposed"]
    L += ["", "## 2. Đã quyết trước đây (chỉ để đọc)", ""]
    L += ["- `%s` (%s): **%s** bởi %s, %s%s" % (r, k, e["status"], e.get("reviewed_by"), e.get("reviewed_on"),
                                              (": " + e["review_note"]) if e.get("review_note") else "") for r, k, e in done] or ["- (không có)"]
    L.append("")
    return "\n".join(L)


def rel(p):
    import run as RUN   # noqa: E402
    return RUN.rel(p)


def sheet_problems(g, path, text):
    """(reasons to refuse, {row id: (new status, reason)})."""
    import promote as P   # noqa: E402
    sheet = P.parse_sheet(text, kinds="T")
    out, dec = [], {}
    if sheet["glossary_sha"] != sha_lf(path):
        out.append("sha256 trong phiếu khác bảng hiện tại (bảng đã đổi sau khi lập phiếu, hoặc phiếu của bảng khác)")
    if not sheet["reviewer"]:
        out.append("chưa ghi người duyệt")
    try:
        datetime.date.fromisoformat(sheet["date"])
    except ValueError:
        out.append("ngày duyệt phải có dạng YYYY-MM-DD")
    for r, _, e in entries(g):
        if e.get("status") != "proposed":
            continue
        cells = sheet["rows"].get(("T", r))
        if cells is None:
            out.append("phiếu không có hàng cho %s" % r)
            continue
        t, why = P.decision(cells, 5, r)
        if why:
            out.append(why)
        elif t > 2:
            out.append("%s: cần đánh dấu đúng một ô" % r)
        elif DECISIONS[t] == "rejected" and not P.reason_of(cells, 6):
            out.append("%s: bác nhưng không ghi lý do" % r)
        else:
            dec[r] = (DECISIONS[t], P.reason_of(cells, 6))
    return out, dec, sheet


def apply_sheet(path, sheet_path):
    """Writes the decisions of a complete sheet into the glossary file. Returns a summary line; SystemExit on refusal."""
    g = load(path)
    fs = check(g)
    if fs:
        raise SystemExit("TỪ CHỐI: bảng có %d phát hiện; sửa trước" % len(fs))
    with open(sheet_path, encoding="utf-8") as f:
        ps, dec, sheet = sheet_problems(g, path, f.read())
    if ps:
        raise SystemExit("TỪ CHỐI:\n  - " + "\n  - ".join(ps))
    n = {s: 0 for s in DECISIONS}
    for r, _, e in entries(g):
        if r in dec:
            st, why = dec[r]
            n[st] += 1
            if why:
                e["review_note"] = why
            if st != "proposed":
                e.update(status=st, reviewed_by=sheet["reviewer"], reviewed_on=sheet["date"])
    fs = check(g)
    if fs:
        raise SystemExit("TỪ CHỐI: sau khi áp phiếu bảng có phát hiện (không ghi): %s" % fs)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(g, f, ensure_ascii=False, indent=2)
        f.write("\n")
    return ("đã ghi %s: chấp nhận %d, bác %d, để sau %d. Mọi phiếu norm lập trước lúc này đã hết hiệu lực (sha256 bảng đổi)."
            % (rel(path), n["approved"], n["rejected"], n["proposed"]))


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
    g = load(a.file)
    if a.cmd == "sheet":
        fs = check(g)
        if fs:
            print("TỪ CHỐI: bảng có %d phát hiện; chạy `check` và sửa trước." % len(fs))
            return 1
        with open(a.out, "w", encoding="utf-8", newline="\n") as f:
            f.write(make_sheet(a.file, g))
        print(a.out)
        return 0
    fs = check(g)
    if fs:
        print("TỪ CHỐI: %d phát hiện:" % len(fs))
        for f in fs:
            print("  - " + f)
        return 1
    n = {s: sum(1 for e in g["acts"] + g["atoms"] if e.get("status") == s) for s in STATUSES}
    print("không có phát hiện cấu trúc; %d act, %d atom; proposed %d, approved %d, rejected %d. "
          "Điều này KHÔNG nói bảng đúng luật." % (len(g["acts"]), len(g["atoms"]), n["proposed"], n["approved"], n["rejected"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
