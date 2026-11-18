# -*- coding: utf-8 -*-
"""One command for the draft path (roadmap step 1). UNTRUSTED: it proves nothing.

    python pipeline/run.py [--doc 44/2019/QH14] TRANSLATION.json [TRANSLATION.json ...] [--out-dir eval/run] [--no-lean]

Takes the translation files of one document (one JSON per article, made with `translate.py prompt` and a pasted LLM
answer), and:

1. checks that the segmented text still matches the extracted file it was made from (else stops);
2. runs `translate.check` on every file; a file with any finding is REFUSED and listed, never merged;
3. merges the accepted files into one Lean draft (atom names are prefixed by their article, so two articles never
   share an atom by accident; see the report for what this costs);
4. runs Lean on the draft (`pfindings`, `analyzeReport`) with `lake env lean --run`;
5. writes a Markdown report next to the draft.

The output goes to `eval/run/`, not to `reports/` (that folder is only for `pipeline/report.py`). The Lean result is
**Evaluated** (compiled code was run), not a kernel theorem: no `decide +kernel` proof is made for the draft.
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

ROOT = T.ROOT
TOOL = "run.py 1.0"
DOC_FILES = {"44/2019/QH14": {"title": "Luật Phòng, chống tác hại của rượu, bia", "extracted": "data/extracted/44-2019-QH14.txt",
                              "stem": "44-2019-QH14"}}


def sha_lf(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read().replace(b"\r\n", b"\n")).hexdigest()


def sha_raw(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()


# ------------------------------------------------------------------ merge

def prefixed(name, art):
    return "Điều %d · %s" % (art, name)


def rename_cond(c, art):
    if c in ("true", "false"):
        return c
    if "sit" in c:
        return dict(c, sit=prefixed(c["sit"], art))
    if "param" in c:
        return dict(c, param=prefixed(c["param"], art))
    if "not" in c:
        return {"not": rename_cond(c["not"], art)}
    k = "and" if "and" in c else "or"
    return {k: [rename_cond(x, art) for x in c[k]]}


def merge(accepted):
    """One translation dict from several accepted ones (already checked, one article each)."""
    first = accepted[0]
    out = {"doc_id": first["doc_id"], "doc_type": first["doc_type"], "effective": first["effective"],
           "atoms": {"situation": [], "parameters": []}, "norms": [], "not_encoded": [], "assumptions": []}
    for d in accepted:
        art = d["article"]
        for kind in ("situation", "parameters"):
            out["atoms"][kind] += [dict(a, name=prefixed(a["name"], art)) for a in d["atoms"][kind]]
        for n in d["norms"]:
            out["norms"].append(dict(n, id="Điều %d:%s" % (art, n["id"]), condition=rename_cond(n["condition"], art),
                                     exceptions=[rename_cond(e, art) for e in n["exceptions"]]))
        out["not_encoded"] += d["not_encoded"]
        out["assumptions"] += ["Điều %d: %s" % (art, a) for a in d["assumptions"]]
    out["label"] = "Điều " + ", ".join(str(d["article"]) for d in accepted)
    return out


def admit(files, seg):
    """(accepted dicts, refused [(file, reasons)], per-file info)."""
    accepted, refused, info, seen = [], [], [], {}
    for p in files:
        try:
            with open(p, encoding="utf-8") as f:
                d = json.load(f)
        except (OSError, ValueError) as e:
            refused.append((p, ["không đọc được JSON: %s" % e]))
            continue
        try:
            fs = T.check(d)
        except (AttributeError, KeyError, TypeError) as e:   # a shape check.check did not foresee: refuse, never crash
            fs = ["tệp không đúng lược đồ: %r" % e]
        if not fs and d["doc_id"] != seg["doc_id"]:
            fs = ["doc_id «%s» khác văn bản đang chạy «%s»" % (d["doc_id"], seg["doc_id"])]
        if not fs and d["article"] in seen:
            fs = ["Điều %d đã có ở %s; mỗi điều chỉ một bản dịch" % (d["article"], seen[d["article"]])]
        if not fs and accepted and (d["doc_type"], d["effective"]) != (accepted[0]["doc_type"], accepted[0]["effective"]):
            fs = ["doc_type/effective khác các tệp đã nhận (%s, %s)" % (d["doc_type"], d["effective"])]
        info.append({"file": p, "sha256": sha_lf(p), "article": d.get("article") if isinstance(d, dict) else None})
        if fs:
            refused.append((p, fs))
        else:
            seen[d["article"]] = p
            accepted.append(d)
    return accepted, refused, info


# ------------------------------------------------------------------ Lean

RESULT = re.compile(r"^KẾT QUẢ: (INVALID|XUNG ĐỘT|consistentOn)")


def run_lean(lean_path):
    try:
        r = subprocess.run(["lake", "env", "lean", "--run", lean_path], cwd=ROOT, capture_output=True,
                           text=True, encoding="utf-8")
    except OSError as e:
        return {"ok": False, "why": "không chạy được lake: %s" % e, "stdout": "", "stderr": ""}
    out = {"ok": r.returncode == 0, "stdout": r.stdout, "stderr": r.stderr, "why": None}
    if not out["ok"]:
        out["why"] = "Lean thoát với mã %d" % r.returncode
        return out
    m = re.search(r"^pfindings: (\d+)$", r.stdout, re.M)
    res = next((RESULT.match(l).group(1) for l in r.stdout.splitlines() if RESULT.match(l)), None)
    out["pfindings"] = int(m.group(1)) if m else None
    out["result"] = res
    out["vacuous"] = "rỗng về xung đột modality" in r.stdout
    return out


def verdict(lean, merged_ok):
    """Three-valued headline: (label, reason)."""
    if not merged_ok:
        return "không biết", "không có bản dịch nào qua kiểm tra, nên không có gì để chạy"
    if lean is None:
        return "không biết", "Lean không được chạy (--no-lean)"
    if not lean["ok"]:
        return "không biết", lean["why"]
    if lean.get("pfindings") is None or lean.get("result") is None:
        return "không biết", "không đọc được kết quả từ đầu ra của Lean"
    if lean["pfindings"] > 0 or lean["result"] == "INVALID":
        return "không biết", "bản nháp có %s finding (bảng atom, reader hoặc norm không hợp lệ); chưa kiểm xung đột" % lean["pfindings"]
    if lean["result"] == "XUNG ĐỘT":
        return "tìm thấy xung đột", "xem các cặp ở mục Lean"
    return "nhất quán trên phần đã mã hóa", ("cảnh báo: không act nào có hai modality khắc nhau, nên kết quả này rỗng về thông tin"
                                            if lean["vacuous"] else "chỉ trên các norm của bản nháp, không phải cả văn bản")


# ------------------------------------------------------------------ report

def git_commit():
    try:
        c = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=ROOT, capture_output=True, text=True).stdout.strip()
        dirty = subprocess.run(["git", "status", "--porcelain"], cwd=ROOT, capture_output=True, text=True).stdout
        return "%s; %d tệp thay đổi chưa commit" % (c, len([l for l in dirty.splitlines() if l.strip()]))
    except OSError:
        return "không có thông tin"


def render(doc, seg, extracted_ok, accepted, refused, info, merged, lean, lean_path, today):
    L = []
    w = L.append
    head, why = verdict(lean, bool(accepted) and extracted_ok)
    w("# Báo cáo nháp (đường dịch AI): %s %s" % (DOC_FILES[doc]["title"], doc))
    w("")
    w("> # BẢN NHÁP, CHƯA CÓ NGƯỜI DUYỆT")
    w(">")
    w("> Các norm ở đây do AI dịch (dán tay) và chỉ qua kiểm tra máy. Chưa ai đối chiếu với luật. Tệp này không phải báo cáo "
      "trong `reports/` và không thay cho bản mã hóa đã duyệt.")
    w("")
    w("## 1. Kết quả")
    w("")
    w("**%s** — %s." % (head.upper(), why))
    w("")
    w("Kết quả chỉ nhận một trong ba giá trị: tìm thấy xung đột / nhất quán trên phần đã mã hóa / không biết. Kết quả Lean ở "
      "đây là **Evaluated** (chạy mã đã biên dịch), không phải định lý kernel.")
    w("")
    w("## 2. Phạm vi")
    w("")
    arts = [a["number"] for a in seg["articles"]]
    got = sorted(d["article"] for d in accepted)
    bad = sorted({x["article"] for x in info if x["file"] in {p for p, _ in refused} and isinstance(x["article"], int)})
    missing = [a for a in arts if a not in got and a not in bad]
    w("| | Số điều | Điều |")
    w("|---|---|---|")
    w("| văn bản | %d | 1–%d |" % (len(arts), max(arts)))
    w("| đã dịch và qua kiểm tra | %d | %s |" % (len(got), ", ".join(map(str, got)) or "—"))
    w("| tệp dịch bị từ chối | %d | %s |" % (len(refused), ", ".join(
        ("%d (đã có bản khác của điều này được nhận)" % b) if b in got else str(b) for b in bad)
        or ("có tệp không đọc được" if refused else "—")))
    w("| chưa dịch | %d | %s |" % (len(missing), compact(missing)))
    w("")
    if merged:
        w("Trong các điều đã dịch: %d norm; %d mục `not_encoded` (dưới đây). Một điều «đã dịch» không có nghĩa mọi khoản của nó "
          "được mã hóa." % (len(merged["norms"]), len(merged["not_encoded"])))
        w("")
        for e in merged["not_encoded"]:
            w("- `not_encoded` %s: %s" % (e["clause"], e["reason"]))
        if merged["not_encoded"]:
            w("")
    w("**Không xét**: văn bản khác (nghị định, nghị quyết, luật khác) có thể làm một khoản tạm không được thực hiện hoặc thay đổi; "
      "đó là Level 2, chưa làm. Ví dụ đã biết: Nghị quyết 66.18/2026/NQ-CP (xem `docs/review/huong-dan-doi-chieu.md`).")
    w("")
    if refused:
        w("## 3. Bản dịch bị từ chối")
        w("")
        for p, fs in refused:
            w("- `%s` (%d phát hiện):" % (rel(p), len(fs)))
            for f in fs[:10]:
                w("  - %s" % f)
            if len(fs) > 10:
                w("  - … và %d phát hiện nữa" % (len(fs) - 10))
        w("")
    w("## 4. Giả định của bản dịch (người duyệt phải chấp nhận hoặc bác từng câu)")
    w("")
    for a in (merged["assumptions"] if merged else []):
        w("- " + a)
    if not merged or not merged["assumptions"]:
        w("- (không có)")
    w("")
    w("## 5. Lean")
    w("")
    if lean is None:
        w("Không chạy.")
    else:
        w("Bản nháp: `%s`." % rel(lean_path))
        w("")
        w("```")
        w((lean["stdout"] or "").rstrip() or "(không có đầu ra)")
        if not lean["ok"]:
            w("--- stderr ---")
            w((lean["stderr"] or "").rstrip()[:4000])
        w("```")
    w("")
    w("Giới hạn của cách gộp: mỗi atom được gắn tên điều («Điều 5 · ...»), nên hai điều nói cùng một khái niệm vẫn có hai "
      "atom khác nhau. Nhờ vậy không có gộp nhầm, nhưng xung đột phụ thuộc vào khái niệm dùng chung có thể bị bỏ sót. "
      "Sửa đúng cách là một bảng thuật ngữ chung (FR2, chưa làm).")
    w("")
    w("## 6. Báo cáo này KHÔNG nói gì")
    w("")
    w("- Không nói bản dịch khớp luật; chỉ người đọc luật kiểm được điều đó.")
    w("- Không nói văn bản không có mâu thuẫn: chỉ xét các norm của các điều đã dịch.")
    w("- «Nhất quán» không có nghĩa là hợp pháp; «không biết» không phải lỗi của luật.")
    w("")
    w("## 7. Nguồn gốc")
    w("")
    w("- Công cụ: %s; `translate.py` (kiểm tra cấu trúc)." % TOOL)
    w("- Văn bản đã tách: `%s` (công cụ %s); đầu vào `%s` sha256 ghim `%s`; khớp tệp hiện tại: %s." % (
        T.SEGMENTED[doc], seg["tool"], seg["input"]["path"], seg["input"]["sha256"], "có" if extracted_ok else "KHÔNG"))
    for x in info:
        w("- Bản dịch `%s`: sha256 (CRLF như LF) `%s`." % (rel(x["file"]), x["sha256"]))
    w("- Git: %s." % git_commit())
    w("- Ngày chạy: %s" % today)
    w("")
    return "\n".join(L)


def rel(p):
    """Path relative to the repo, with forward slashes; the absolute path if it is on another drive."""
    try:
        r = os.path.relpath(p, ROOT)
    except ValueError:
        r = os.path.abspath(p)
    return r.replace("\\", "/")


def compact(nums):
    """'1–4, 6, 8–18' for a sorted list of ints."""
    if not nums:
        return "—"
    out, start, prev = [], nums[0], nums[0]
    for n in nums[1:] + [None]:
        if n is not None and n == prev + 1:
            prev = n
            continue
        out.append(str(start) if start == prev else "%d–%d" % (start, prev))
        if n is not None:
            start = prev = n
    return ", ".join(out)


# ------------------------------------------------------------------ main

def run(doc, files, out_dir, lean=True, today=None):
    """Returns (report path, report text, headline)."""
    today = today or datetime.date.today().isoformat()
    seg = T.load_segmented(doc)
    seg["doc_id"] = doc
    extracted = os.path.join(ROOT, *DOC_FILES[doc]["extracted"].split("/"))
    extracted_ok = os.path.exists(extracted) and sha_raw(extracted) == seg["input"]["sha256"]
    accepted, refused, info = admit(files, seg) if extracted_ok else ([], [(f, ["văn bản đã tách không khớp tệp trích hiện tại; chạy lại pipeline/segment.py"]) for f in files], [])
    merged = merge(accepted) if accepted else None
    os.makedirs(out_dir, exist_ok=True)
    stem = "%s-%s" % (DOC_FILES[doc]["stem"], today)
    lean_path = os.path.join(out_dir, stem + ".lean")
    result = None
    if merged:
        with open(lean_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(T.to_lean(merged, seg))
        if lean:
            result = run_lean(lean_path)
    text = render(doc, seg, extracted_ok, accepted, refused, info, merged, result, lean_path, today)
    rep = os.path.join(out_dir, stem + ".md")
    with open(rep, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    return rep, text, verdict(result, bool(accepted) and extracted_ok)[0]


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("files", nargs="+", help="bản dịch JSON, mỗi tệp một điều")
    ap.add_argument("--doc", default="44/2019/QH14", choices=sorted(DOC_FILES))
    ap.add_argument("--out-dir", default=os.path.join(ROOT, "eval", "run"))
    ap.add_argument("--no-lean", action="store_true")
    a = ap.parse_args(argv)
    rep, _, head = run(a.doc, a.files, a.out_dir, lean=not a.no_lean)
    print("%s\nkết quả: %s" % (rep, head))
    return 0


if __name__ == "__main__":
    sys.exit(main())
