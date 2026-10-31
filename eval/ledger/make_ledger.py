# -*- coding: utf-8 -*-
"""Builds docs/review/alcohol-coverage-ledger.md.

Inputs: data/segmented/44-2019-QH14.json (segment.py), eval/ledger/module.json (Dump.lean: encoded norm sources and
not-encoded entries, each parsed by ClauseRef), docs/slice1-notes.md section C (act groups).
Every clause and point of the law gets exactly one status. Deterministic: no timestamp.
usage: python eval/ledger/make_ledger.py
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
SEG = os.path.join(ROOT, "data", "segmented", "44-2019-QH14.json")
MOD = os.path.join(HERE, "module.json")
NOTES = os.path.join(ROOT, "docs", "slice1-notes.md")
OUT = os.path.join(ROOT, "docs", "review", "alcohol-coverage-ledger.md")

PT = list("abcdđeghiklmnopqrstuvxy")


# ---------------------------------------------------------------- references as tuples (article, clause, point)
def covers(a, b):
    """a covers b: same article and a is equal to b or an ancestor of b (None = whole). Tuples are
    (article, clause, point, branch); a branch is project notation («nhánh (i)»), the lowest level."""
    if a[0] != b[0]:
        return False
    for i in (1, 2, 3):
        if a[i] is None:
            return all(a[j] is None for j in range(i, 4))
        if a[i] != b[i]:
            return False
    return True


def ref_tuple(r):
    return (r["article"], r["clause"], r["point"], r["branch"])


def section_c(path):
    """{act: [(article, clause, point)...]} from the 'Khoản dùng' column of section C."""
    text = open(path, encoding="utf-8").read()
    a = text.index("### C. Act đề xuất")
    b = text.index("### D.", a)
    acts = {}
    for line in text[a:b].splitlines():
        m = re.match(r"^\| `([a-z_0-9]+)` \|.*\| ([^|]+) \|$", line)
        if not m:
            continue
        cell = re.sub(r"(\d+\.\d+)\((i+)\)", r"\1", m.group(2))     # 5.11(i) -> 5.11
        cell = re.sub(r"\([^)]*\)", "", cell)                         # remove remarks
        cell = cell.split(";")[0]                                     # «; có thể cả …» is tentative: not used
        toks = []
        for t in [x.strip() for x in cell.split(",")]:
            t = t.replace("–", "-")
            if not t:
                continue
            m1 = re.fullmatch(r"(\d+)\.(\d+)-(\d+)\.(\d+)", t)
            m2 = re.fullmatch(r"(\d+)\.(\d+)\.([a-zđ])-([a-zđ])", t)
            m3 = re.fullmatch(r"(\d+)\.(\d+)\.([a-zđ])", t)
            m4 = re.fullmatch(r"(\d+)\.(\d+)", t)
            m5 = re.fullmatch(r"(\d+)", t)
            if m1:
                for k in range(int(m1.group(2)), int(m1.group(4)) + 1):
                    toks.append((int(m1.group(1)), k, None, None))
            elif m2:
                for p in PT[PT.index(m2.group(3)):PT.index(m2.group(4)) + 1]:
                    toks.append((int(m2.group(1)), int(m2.group(2)), p, None))
            elif m3:
                toks.append((int(m3.group(1)), int(m3.group(2)), m3.group(3), None))
            elif m4:
                toks.append((int(m4.group(1)), int(m4.group(2)), None, None))
            elif m5:
                toks.append((int(m5.group(1)), None, None, None))
            else:
                raise SystemExit("không đọc được ô «Khoản dùng»: %r (act %s)" % (t, m.group(1)))
        acts[m.group(1)] = toks
    return acts


def main():
    seg = json.load(open(SEG, encoding="utf-8"))
    mod = json.load(open(MOD, encoding="utf-8"))
    acts = section_c(NOTES)

    norms = [(n["id"], ref_tuple(r), n["act"]) for n in mod["norms"] for r in n["refs"]]
    entries = [(e["clause"], ref_tuple(r), e["reason"], r["heading"]) for e in mod["notEncoded"] for r in e["refs"]]
    module_articles = sorted({r[0] for _, r, _ in norms} | {r[0] for _, r, _, _ in entries})

    units = []   # (kind, id, ref, lines, text)
    for a in seg["articles"]:
        n = a["number"]
        if a["lead_in"]:
            units.append(("đoạn không đánh số", a["id"] + " (đoạn không đánh số)", (n, None, None, None),
                          (a["lead_in"]["start"], a["lead_in"]["end"]), a["lead_in"]["text"]))
        for c in a["clauses"]:
            if c["number"] != 0:
                units.append(("khoản", c["id"], (n, c["number"], None, None), (c["start"], c["end"]), c["text"]))
            for p in c["points"]:
                units.append(("điểm", p["id"], (n, c["number"] or None, p["letter"], None), (p["start"], p["end"]), p["text"]))

    rows = []
    for kind, uid, ref, ln, text in units:
        enc_full = [i for i, r, _ in norms if covers(r, ref)]
        enc_in = [i for i, r, _ in norms if not covers(r, ref) and covers(ref, r) and r != ref]
        ne_full = [(c, rs) for c, r, rs, h in entries if not h and covers(r, ref)]
        ne_in = [(c, rs) for c, r, rs, h in entries if not h and not covers(r, ref) and covers(ref, r) and r != ref]
        grp = sorted({act for act, toks in acts.items() if any(covers(t, ref) or (covers(ref, t) and t != ref) for t in toks)})
        if enc_full and not ne_in:
            st, detail = "encoded", "norm: " + ", ".join(enc_full)
        elif (enc_full or enc_in) and ne_in:
            st = "encoded (một phần)"
            detail = "norm: %s; phần KHÔNG mã hóa: %s — %s" % (", ".join(enc_full + enc_in), "; ".join(c for c, _ in ne_in),
                                                              "; ".join(r for _, r in ne_in))
        elif enc_in:
            st, detail = "encoded (một phần)", "norm trong đơn vị: " + ", ".join(enc_in)
        elif ne_full:
            st, detail = "not encoded", "%s — %s" % (ne_full[0][0], ne_full[0][1])
        elif ne_in:
            st, detail = "not encoded (một phần)", "; ".join(c for c, _ in ne_in)
        elif grp:
            st, detail = "outside this module", "nhóm act (mục C): " + ", ".join(grp)
        elif ref[0] in module_articles:
            st, detail = "UNACCOUNTED", "điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào"
        else:
            st, detail = "chưa phân loại", "không thuộc mô-đun và không có trong mục C"
        rows.append((kind, uid, ln, st, detail, text))

    # cited references that do not exist in the segmented law
    exist = {u[2] for u in units}
    articles_with_units = {u[2][0] for u in units}
    missing = []
    for src, items in (("norm", [(i, r) for i, r, _ in norms]), ("notEncoded", [(c, r) for c, r, _, h in entries if not h])):
        for who, r in items:
            if r[1] is None and r[0] <= 36:
                continue
            if not any(covers(r[:3] + (None,), e) for e in exist):
                missing.append("%s %s → %s" % (src, who, r))

    def count(kind, st):
        return sum(1 for r in rows if r[0] == kind and r[3] == st)

    order = ["encoded", "encoded (một phần)", "not encoded", "not encoded (một phần)", "outside this module",
             "chưa phân loại", "UNACCOUNTED"]
    out = []
    w = out.append
    w("# Sổ phủ: từng khoản và điểm của Luật 44/2019/QH14 so với mô-đun `Laws/AlcoholSale.lean` (BẢN NHÁP)\n")
    w("> **«encoded» ở đây nghĩa là: có một norm nháp, CHƯA AI DUYỆT, trích dẫn đơn vị này. Nó không nói gì về việc norm đó có khớp luật hay không.** "
      "Sổ này chỉ đếm xem đơn vị nào được nhắc tới và đơn vị nào không; nó không kiểm nội dung.\n")
    w("Nguồn: `data/segmented/44-2019-QH14.json` (do `pipeline/segment.py` tạo; bộ tách là công cụ chưa được kiểm độc lập), "
      "`eval/ledger/module.json` (do `Dump.lean` in từ mô-đun, tham chiếu đã qua `ClauseRef`), và bảng act mục C của `docs/slice1-notes.md`. "
      "Tạo bằng `python eval/ledger/make_ledger.py`; chạy hai lần cho kết quả giống nhau.\n")
    w("Mỗi đơn vị có đúng một trạng thái, xét theo thứ tự: *encoded* (norm trích dẫn đơn vị hoặc cha của nó) → *encoded (một phần)* "
      "(có norm nhưng một nhánh của đơn vị nằm trong `notEncoded`) → *not encoded* (mục `notEncoded` phủ đơn vị, kèm lý do của mô-đun) → "
      "*outside this module* (đơn vị nằm trong nhóm act mục C, tức thuộc mô-đun khác) → *UNACCOUNTED* (điều nằm trong phạm vi mô-đun mà không thuộc gì ở trên) → "
      "*chưa phân loại*.\n")
    w("**«Phạm vi mô-đun»** do tôi định nghĩa: các điều mà một norm đã mã hóa hoặc một mục `notEncoded` nhắc tới: %s. "
      "Đây là một lựa chọn; nếu hiểu là khoảng từ điều nhỏ nhất đến lớn nhất thì UNACCOUNTED sẽ nhiều hơn rất nhiều.\n"
      % ", ".join("Điều %d" % a for a in module_articles))
    w("Tiêu đề điều không được tính là khoản hay điểm. Các đoạn không đánh số (đoạn dẫn, Điều không chia khoản) được liệt kê riêng và không nằm trong tổng khoản/điểm.\n")

    w("## Tổng\n")
    nK = sum(1 for r in rows if r[0] == "khoản"); nP = sum(1 for r in rows if r[0] == "điểm"); nU = sum(1 for r in rows if r[0] == "đoạn không đánh số")
    w("| Trạng thái | Khoản | Điểm | Đoạn không đánh số |\n|---|---|---|---|")
    for st in order:
        w("| %s | %d | %d | %d |" % (st, count("khoản", st), count("điểm", st), count("đoạn không đánh số", st)))
    w("| **Cộng** | **%d** | **%d** | **%d** |\n" % (nK, nP, nU))
    unacc = [r for r in rows if r[3] == "UNACCOUNTED"]
    w("**UNACCOUNTED: %d đơn vị (khoản + điểm + đoạn không đánh số).** Số này chỉ có nghĩa theo định nghĩa «phạm vi mô-đun» ở trên.\n" % len(unacc))
    if missing:
        w("**Tham chiếu của mô-đun không tìm thấy đơn vị tương ứng trong văn bản đã tách:** " + "; ".join(missing) + "\n")
    else:
        w("Mọi tham chiếu cụ thể (khoản trở xuống) của norm và `notEncoded` đều có đơn vị tương ứng trong văn bản đã tách.\n")

    w("## UNACCOUNTED (đọc trước)\n")
    if unacc:
        w("| Đơn vị | Dòng | Đầu đoạn |\n|---|---|---|")
        for kind, uid, ln, st, detail, text in unacc:
            w("| %s | %d–%d | %s |" % (uid, ln[0], ln[1], " ".join(text.split()).replace("|", "/")[:70]))
        w("")
    else:
        w("(không có)\n")

    w("## Toàn bộ đơn vị\n")
    w("| Đơn vị | Dòng | Trạng thái | Chi tiết |\n|---|---|---|---|")
    for kind, uid, ln, st, detail, text in rows:
        w("| %s | %d–%d | %s | %s |" % (uid, ln[0], ln[1], st, detail.replace("|", "/")))
    w("")
    w("## Giới hạn\n")
    w("* «encoded» là bản nháp chưa duyệt; không phải «đúng luật».\n"
      "* Một norm trích dẫn «Điều 5 khoản 11» được tính phủ cả khoản; phần «nhánh (i)» (ký hiệu của dự án, không phải đơn vị pháp lý) nằm trong `notEncoded` nên khoản 11 là *encoded (một phần)*.\n"
      "* «outside this module» chỉ dựa vào cột «Khoản dùng» của mục C trong `slice1-notes.md`, do cùng một mô hình viết; Điều 12, 13 chỉ nằm ở đó vì sáu điều đã được phân tích.\n"
      "* Sổ không biết đơn vị nào *nên* được mã hóa; nó chỉ cho thấy đơn vị nào không được nhắc tới.\n")
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(out) + "\n")
    sys.stdout.reconfigure(encoding="utf-8")
    print("units: khoản %d, điểm %d, đoạn %d" % (nK, nP, nU))
    for st in order:
        print("%-24s k=%3d p=%3d u=%2d" % (st, count("khoản", st), count("điểm", st), count("đoạn không đánh số", st)))
    print("UNACCOUNTED:", len(unacc), "| missing refs:", missing)


if __name__ == "__main__":
    main()
