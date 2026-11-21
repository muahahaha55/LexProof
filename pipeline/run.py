# -*- coding: utf-8 -*-
"""One command for the draft path (roadmap step 1). UNTRUSTED: it proves nothing.

    python pipeline/run.py [--doc 44/2019/QH14] TRANSLATION.json [TRANSLATION.json ...] [--out-dir eval/run] [--no-lean]

Takes the translation files of one document (one JSON per article, made with `translate.py prompt` and a pasted LLM
answer), and:

1. checks that the segmented text still matches the extracted file it was made from (else stops);
2. runs `translate.check` on every file; a file with any finding is REFUSED and listed, never merged;
3. merges the accepted files into one Lean draft: glossary atoms (ADR-0027) keep their id and are one atom across
   articles; every other atom name is prefixed by its article, so two articles never share it by accident;
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
import derived as D     # noqa: E402

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


def rename_cond(c, art, keep=frozenset()):
    """Prefix every atom name by its article, except the shared (glossary) names in `keep`."""
    if c in ("true", "false"):
        return c
    for k in ("sit", "param"):
        if k in c:
            return dict(c, **{k: c[k] if c[k] in keep else prefixed(c[k], art)})
    if "not" in c:
        return {"not": rename_cond(c["not"], art, keep)}
    k = "and" if "and" in c else "or"
    return {k: [rename_cond(x, art, keep) for x in c[k]]}


def shared_atoms(d):
    """{id: (kind, atom)} for the glossary atoms of a materialized translation."""
    return {a["name"]: (kind, a) for kind in ("situation", "parameters") for a in d["atoms"][kind] if a.get("shared")}


def shared_conflicts(accepted, d):
    """Reasons why `d` cannot be merged with `accepted`: one glossary id with two kinds or two label lists (two
    proposals with one id that disagree), or two different glossary files."""
    out = []
    for prev in accepted:
        if "glossary_sha256" in d and "glossary_sha256" in prev and d["glossary_sha256"] != prev["glossary_sha256"]:
            out.append("Điều %d và Điều %d dùng hai phiên bản khác nhau của bảng thuật ngữ" % (prev["article"], d["article"]))
        mine, theirs = shared_atoms(d), shared_atoms(prev)
        for i in sorted(mine.keys() & theirs.keys()):
            (k1, a1), (k2, a2) = mine[i], theirs[i]
            if T.shape({"kind": k1, "domain": a1["domain"]}) != T.shape({"kind": k2, "domain": a2["domain"]}):
                out.append("atom «%s» có định nghĩa khác nhau ở Điều %d và Điều %d; không gộp" % (i, prev["article"], d["article"]))
    return out


def with_derived(merged, m):
    """`merged` plus the derived norms of `m` (a materialized `derived.as_translation`): glossary atoms are shared by
    id, so a derived norm speaks of the same atoms as the articles. Returns a new dict; `merged` is unchanged."""
    out = json.loads(json.dumps(merged))
    have = {a["name"]: (kind, a) for kind in ("situation", "parameters") for a in out["atoms"][kind]}
    for kind in ("situation", "parameters"):
        for a in m["atoms"][kind]:
            if a["name"] in have:
                k2, a2 = have[a["name"]]
                if T.shape({"kind": kind, "domain": a["domain"]}) != T.shape({"kind": k2, "domain": a2["domain"]}):
                    raise SystemExit("TỪ CHỐI: atom «%s» của norm suy ra khác atom cùng id của bản dịch" % a["name"])
            else:
                out["atoms"][kind].append(a)
    out["norms"] += m["norms"]
    out["assumptions"] += m["assumptions"]
    out["glossary_terms"] = out.get("glossary_terms", []) + [t for t in m["glossary_terms"] if t not in out.get("glossary_terms", [])]
    out["unapproved"] = sorted(set(out.get("unapproved", [])) | set(m["unapproved"]))
    out["glossary"], out["glossary_sha256"] = m["glossary"], m["glossary_sha256"]
    out["label"] = merged["label"] + " + norm suy ra"
    return out


PAIR = re.compile(r"^  · (.+) × (.+)$")


def conflict_pairs(lean):
    """The (left, right) pairs of a «XUNG ĐỘT» result, from the rendered report."""
    if not lean or not lean.get("ok") or lean.get("result") != "XUNG ĐỘT":
        return []
    return [m.groups() for m in map(PAIR.match, lean["stdout"].splitlines()) if m]


def merge(accepted):
    """One translation dict from several accepted ones (already checked and materialized, one article each, no
    `shared_conflicts`). Glossary atoms keep their id and appear once; every other atom is prefixed by its article."""
    first = accepted[0]
    out = {"doc_id": first["doc_id"], "doc_type": first["doc_type"], "effective": first["effective"],
           "atoms": {"situation": [], "parameters": []}, "norms": [], "not_encoded": [], "assumptions": []}
    seen, terms = set(), []
    for d in accepted:
        art = d["article"]
        keep = frozenset(shared_atoms(d))
        for kind in ("situation", "parameters"):
            for a in d["atoms"][kind]:
                if a["name"] in keep:
                    if a["name"] not in seen:
                        seen.add(a["name"])
                        out["atoms"][kind].append(a)
                else:
                    out["atoms"][kind].append(dict(a, name=prefixed(a["name"], art)))
        for n in d["norms"]:
            out["norms"].append(dict(n, id="Điều %d:%s" % (art, n["id"]), condition=rename_cond(n["condition"], art, keep),
                                     exceptions=[rename_cond(e, art, keep) for e in n["exceptions"]]))
        out["not_encoded"] += d["not_encoded"]
        out["assumptions"] += ["Điều %d: %s" % (art, a) for a in d["assumptions"]]
        if "glossary" in d:
            out["glossary"], out["glossary_sha256"] = d["glossary"], d["glossary_sha256"]
            terms += [t for t in d["glossary_terms"] if t not in terms]
            out["unapproved"] = sorted(set(out.get("unapproved", [])) | set(d["unapproved"]))
    if terms:
        out["glossary_terms"] = terms
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
        if not fs:
            d = T.materialize(d)
        if not fs and d["doc_id"] != seg["doc_id"]:
            fs = ["doc_id «%s» khác văn bản đang chạy «%s»" % (d["doc_id"], seg["doc_id"])]
        if not fs and d["article"] in seen:
            fs = ["Điều %d đã có ở %s; mỗi điều chỉ một bản dịch" % (d["article"], seen[d["article"]])]
        if not fs and accepted and (d["doc_type"], d["effective"]) != (accepted[0]["doc_type"], accepted[0]["effective"]):
            fs = ["doc_type/effective khác các tệp đã nhận (%s, %s)" % (d["doc_type"], d["effective"])]
        if not fs:
            fs = shared_conflicts(accepted, d)
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


def render_derived(w, dres):
    """Section 5b: the run with derived norms. Its result is about the readings, never about the law."""
    w("## 5b. Kiểm thêm với norm suy ra (KHÔNG phải chữ luật)")
    w("")
    w("Tệp `%s` (sha256 `%s`). Mỗi norm dưới đây là một **cách đọc** mà luật không viết thẳng (ADR-0028); kết quả mục này "
      "chỉ nói về các cách đọc đó." % (rel(dres["file"]), dres["sha256"]))
    w("")
    for e in dres["entries"]:
        w("- **%s%s** [%s, đề xuất bởi %s], suy ra từ %s: %s" % (D.PREFIX, e.get("id"), e.get("status"), e.get("proposed_by"),
                                                             "; ".join(e.get("derived_from") or []), e.get("reading")))
    w("")
    if dres["findings"]:
        w("**KHÔNG BIẾT** — tệp norm suy ra có %d phát hiện, không chạy:" % len(dres["findings"]))
        for f in dres["findings"]:
            w("  - %s" % f)
        w("")
        return
    if not D.live({"derived": dres["entries"]}):
        w("Không chạy: mọi norm suy ra trong tệp đều đã bị bác. Mục này không thêm gì vào kết quả.")
        w("")
        return
    head, why = verdict(dres["lean"], True)
    w("**%s** (khi thêm norm suy ra) — %s." % (head.upper(), why))
    w("")
    pairs = conflict_pairs(dres["lean"])
    dep = [p for p in pairs if p[0].startswith(D.PREFIX) or p[1].startswith(D.PREFIX)]
    if pairs:
        w("Cặp xung đột chỉ có vì một norm suy ra: %d/%d. Mỗi cặp như vậy nghĩa là: **nếu** đọc luật theo cách suy ra đó thì "
          "hai norm khắc nhau ở một tình huống; đó là lý do để sửa hoặc thêm ngoại lệ cho cách đọc (hoặc bác nó), "
          "**không** phải bằng chứng luật mâu thuẫn." % (len(dep), len(pairs)))
        w("")
        for a, b in pairs:
            w("- %s × %s%s" % (a, b, "" if (a, b) in dep else " (không dính norm suy ra: xem mục 1)"))
        w("")
    w("Bản nháp: `%s`." % rel(dres["lean_path"]))
    w("")
    if dres["lean"] is not None:
        w("```")
        w((dres["lean"]["stdout"] or "").rstrip() or "(không có đầu ra)")
        if not dres["lean"]["ok"]:
            w("--- stderr ---")
            w((dres["lean"]["stderr"] or "").rstrip()[:4000])
        w("```")
        w("")


def render(doc, seg, extracted_ok, accepted, refused, info, merged, lean, lean_path, today, dres=None):
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
    if dres:
        w("Kết quả trên chỉ xét các norm dịch từ chữ luật. Lần kiểm thêm với norm suy ra ở mục 5b và không đổi kết quả này.")
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
    if merged and merged.get("glossary_terms"):
        w("Cách gộp: atom của bảng thuật ngữ (`%s`, sha256 `%s`) giữ id và là **một** atom dù nhiều điều dùng; atom riêng "
          "của một điều (bản dịch không dùng bảng) được gắn tên điều («Điều 5 · ...»). Gộp nhầm hai khái niệm khác nhau "
          "dưới một id chỉ người duyệt bảng chặn được." % (merged["glossary"], merged["glossary_sha256"]))
        w("")
        un = merged.get("unapproved", [])
        w("Thuật ngữ đang dùng mà **chưa duyệt** trong bảng: %s. `promote.py` từ chối cho tới khi bảng duyệt hết." % (
            ", ".join(un) if un else "không có"))
        w("")
        for t in merged["glossary_terms"]:
            w(("  - " + t.strip()) if t.startswith("  ") else ("- " + t))
    else:
        w("Giới hạn của cách gộp: mỗi atom được gắn tên điều («Điều 5 · ...»), nên hai điều nói cùng một khái niệm vẫn có hai "
          "atom khác nhau. Nhờ vậy không có gộp nhầm, nhưng xung đột phụ thuộc vào khái niệm dùng chung có thể bị bỏ sót. "
          "Bản dịch dùng bảng thuật ngữ (`translate.py prompt --glossary`, ADR-0027) thì dùng chung được atom.")
    w("")
    if dres:
        render_derived(w, dres)
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

def run_derived(path, merged, seg, lean_path, lean):
    """Second run with the derived norms of `path` added (ADR-0028). Returns a dict for `render`."""
    out = {"file": path, "sha256": sha_lf(path), "findings": [], "lean": None, "lean_path": lean_path, "entries": []}
    dd = D.load(path)
    out["entries"] = dd.get("derived", [])
    try:
        out["findings"] = D.check(dd)
    except (AttributeError, KeyError, TypeError) as e:
        out["findings"] = ["tệp không đúng lược đồ: %r" % e]
    if out["findings"] or not merged or not D.live(dd):
        return out
    m = T.materialize(D.as_translation(dd, merged["doc_type"], merged["effective"]))
    with open(lean_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(T.to_lean(with_derived(merged, m), seg))
    if lean:
        out["lean"] = run_lean(lean_path)
    return out


def run(doc, files, out_dir, lean=True, today=None, derived=None):
    """Returns (report path, report text, headline). The headline is about the text as translated; the derived run
    (if any) never changes it."""
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
    dres = run_derived(derived, merged, seg, os.path.join(out_dir, stem + "-suy-ra.lean"), lean) if derived else None
    text = render(doc, seg, extracted_ok, accepted, refused, info, merged, result, lean_path, today, dres)
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
    ap.add_argument("--derived", help="tệp norm suy ra (ADR-0028); Lean chạy thêm một lần có các norm đó, báo riêng")
    a = ap.parse_args(argv)
    rep, _, head = run(a.doc, a.files, a.out_dir, lean=not a.no_lean, derived=a.derived)
    print("%s\nkết quả: %s" % (rep, head))
    return 0


if __name__ == "__main__":
    sys.exit(main())
