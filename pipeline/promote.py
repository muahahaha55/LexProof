# -*- coding: utf-8 -*-
"""Roadmap step 2: from a reviewed translation to a `LexProof/Laws/` module. UNTRUSTED tool; the Lean kernel
checks the theorems it writes, a human decides what goes in.

    python pipeline/promote.py sheet   TRANSLATION.json -o SHEET.md
        writes a review sheet: one row per norm, per assumption and per `not_encoded` entry, with the sha256 of
        the translation it is about.
    python pipeline/promote.py promote --name ModuleName --pair TRANSLATION.json SHEET.md [--pair ...] [--no-build]
        refuses unless every sheet is complete and names the sha256 of its translation (see `sheet_problems`);
        then writes LexProof/Laws/ModuleName.lean, imports it in LexProof.lean and Cert/Audit.lean, and runs
        `lake build`. If the build fails, all three files are put back as they were.

What a filled sheet means: a person ticked every row. The tool does not check who the person is, nor whether the
answers are right. A rejected norm becomes a `notEncoded` entry with the reviewer's reason (never silently dropped).
A rejected assumption or a refused `not_encoded` entry stops the promotion: the translation must be redone.
"""
import argparse
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402
import run as RUN       # noqa: E402

ROOT = T.ROOT
TOOL = "promote.py 1.0"
LAWS = os.path.join(ROOT, "LexProof", "Laws")
ROOT_FILE = os.path.join(ROOT, "LexProof.lean")
AUDIT_FILE = os.path.join(ROOT, "LexProof", "Cert", "Audit.lean")
TICKS = "☑☒✓✔"
SHA_LINE = re.compile(r"^sha256 bản dịch:\s*`?([0-9a-f]{64})`?\s*$", re.M)
GSHA_LINE = re.compile(r"^sha256 bảng thuật ngữ:\s*`?([0-9a-f]{64})`?\s*$", re.M)
FIELD = re.compile(r"^(Người duyệt|Ngày duyệt \(YYYY-MM-DD\)):[ \t]*(.*)$", re.M)
MOD = {"prohibition": "cấm", "obligation": "bắt buộc", "permission": "được phép"}


def sha_lf(path):
    return RUN.sha_lf(path)


def esc(s):
    return str(s).replace("|", "\\|").replace("\n", " ")


# ------------------------------------------------------------------ sheet

def words(c):
    """A condition in plain words, for the reviewer."""
    if c == "true":
        return "luôn áp dụng"
    if c == "false":
        return "không bao giờ áp dụng"
    if "sit" in c:
        return "«%s%s»" % (c["sit"], (" = " + c["value"]) if "value" in c else "")
    if "param" in c:
        return "«%s» (khái niệm mở, người dùng tự quyết)" % c["param"]
    if "not" in c:
        return "KHÔNG (%s)" % words(c["not"])
    k = "and" if "and" in c else "or"
    return "(" + (" VÀ " if k == "and" else " HOẶC ").join(words(x) for x in c[k]) + ")"


def make_sheet(path, data):
    rel = RUN.rel(path)
    L = ["# Phiếu duyệt bản dịch: Điều %d (%s)" % (data["article"], data["doc_id"]), "",
         "Đánh dấu **đúng một** ô ở mỗi hàng bằng cách đổi `☐` thành `☒`. Đọc từng norm với chữ của luật (cột «Trích dẫn» và "
         "văn bản gốc). Bác một norm thì phải ghi lý do; norm đó sẽ được ghi là «không mã hóa» kèm lý do của bạn.",
         "Bác một giả định, hoặc không đồng ý để một khoản ngoài phạm vi, thì bản dịch **không** được đưa vào thư viện: phải dịch lại.",
         "", "Bản dịch: `%s`" % rel, "", "sha256 bản dịch: %s" % sha_lf(path), ""]
    if "glossary" in data:
        m = T.materialize(data)
        L += ["Bảng thuật ngữ: `%s`" % data["glossary"], "", "sha256 bảng thuật ngữ: %s" % m["glossary_sha256"], "",
              "## 0. Thuật ngữ bản dịch dùng (chỉ để đọc; duyệt ở phiếu bảng thuật ngữ, trước phiếu này)", ""]
        L += [("  - " + t.strip()) if t.startswith("  ") else ("- " + t) for t in m["glossary_terms"]]
        L += ["", "Một id dùng ở nhiều điều là **một** khái niệm. Nếu norm dưới đây dùng id theo nghĩa khác giải thích ở trên, "
              "hãy bác norm đó và ghi lý do.", ""]
    L += ["Người duyệt: ", "", "Ngày duyệt (YYYY-MM-DD): ", "",
          "## 1. Norm", "",
         "| Mã | Nguồn | Trích dẫn | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Quyết định | Lý do (bắt buộc nếu bác) |",
         "|---|---|---|---|---|---|---|---|---|"]
    for n in data["norms"]:
        ex = "; ".join(words(e) for e in n["exceptions"]) or "—"
        L.append("| N:%s | %s | «%s» | %s | `%s` | %s | %s | ☐ Chấp nhận<br>☐ Bác |  |" % (
            esc(n["id"]), esc(n["source"]), esc(n["quote"]), MOD[n["modality"]], esc(n["act"]), esc(words(n["condition"])), esc(ex)))
    L += ["", "## 2. Giả định của bản dịch", "", "| Mã | Giả định | Quyết định |", "|---|---|---|"]
    for i, a in enumerate(data["assumptions"], 1):
        L.append("| A:%d | %s | ☐ Chấp nhận<br>☐ Bác |" % (i, esc(a)))
    L += ["", "## 3. Khoản để ngoài (`not_encoded`)", "", "| Mã | Khoản | Lý do của bản dịch | Quyết định |", "|---|---|---|---|"]
    for i, e in enumerate(data["not_encoded"], 1):
        L.append("| X:%d | %s | %s | ☐ Đồng ý để ngoài<br>☐ Không đồng ý |" % (i, esc(e["clause"]), esc(e["reason"])))
    if not data["not_encoded"]:
        L.append("| — | (không có) | | |")
    L.append("")
    return "\n".join(L)


def ticked(cell):
    """Index of the one ticked option (0, 1, ...) or None if zero or several are ticked."""
    opts = [o.strip() for o in cell.split("<br>")]
    marks = [i for i, o in enumerate(opts) if o[:1] in TICKS or o.lower().startswith("[x]")]
    return marks[0] if len(marks) == 1 else None


def parse_sheet(text):
    rows = {}
    for line in text.splitlines():
        m = re.match(r"^\|\s*([NAX]):(.+?)\s*\|", line)
        if m:
            body = line.strip()[1:]
            if body.endswith("|") and not body.endswith("\\|"):
                body = body[:-1]
            cells = [c.strip() for c in re.split(r"(?<!\\)\|", body)]   # works with or without the closing «|»
            rows[(m.group(1), m.group(2))] = cells
    fields = dict((k, v.strip()) for k, v in FIELD.findall(text))
    s = SHA_LINE.search(text)
    gs = GSHA_LINE.search(text)
    return {"rows": rows, "sha": s.group(1) if s else None, "glossary_sha": gs.group(1) if gs else None, "reviewer": fields.get("Người duyệt", ""),
            "date": fields.get("Ngày duyệt (YYYY-MM-DD)", "")}


def decision(cells, col, what):
    """(index of the ticked option or None, problem text or None) for one row's decision cell."""
    if len(cells) <= col:
        return None, ("%s: hàng bị hỏng định dạng (thiếu cột «Quyết định»; có %d cột, cần ít nhất %d). "
                      "Đừng xóa hay nối dòng; chỉ đổi ☐ thành ☒." % (what, len(cells), col + 1))
    t = ticked(cells[col])
    if t is not None:
        return t, None
    n_opts = len([o for o in cells[col].split("<br>") if o.strip()])
    if n_opts < 2:
        return None, ("%s: ô quyết định chỉ còn một lựa chọn («%s»): có thể đã xóa lựa chọn kia. "
                      "Giữ cả hai lựa chọn và đổi ☐ thành ☒ ở đúng một ô." % (what, cells[col].strip()[:40]))
    return None, "%s: cần đánh dấu đúng một ô" % what


def reason_of(cells, col):
    return cells[col].strip() if len(cells) > col else ""


def sheet_problems(data, tr_path, sheet):
    """Reasons to refuse; empty if the sheet is complete, about this exact translation, and accepts everything it must."""
    out = []
    if sheet["sha"] != sha_lf(tr_path):
        out.append("sha256 trong phiếu khác bản dịch hiện tại (bản dịch đã đổi sau khi lập phiếu, hoặc phiếu của tệp khác)")
    if "glossary" in data and sheet.get("glossary_sha") != T.glossary_sha(T.glossary_rel(data["doc_id"])):
        out.append("sha256 bảng thuật ngữ trong phiếu khác bảng hiện tại (bảng đã đổi sau khi lập phiếu, nghĩa của các id có thể "
                   "đã khác): lập lại phiếu và duyệt lại")
    if not sheet["reviewer"]:
        out.append("chưa ghi người duyệt")
    try:
        datetime.date.fromisoformat(sheet["date"])
    except ValueError:
        out.append("ngày duyệt phải có dạng YYYY-MM-DD")
    decisions = {"accepted": [], "rejected": []}
    for n in data["norms"]:
        cells = sheet["rows"].get(("N", n["id"]))
        if cells is None:
            out.append("phiếu không có hàng cho norm %s" % n["id"])
            continue
        t, why = decision(cells, 7, "norm %s" % n["id"])
        if why:
            out.append(why)
        elif t == 1 and not reason_of(cells, 8):
            out.append("norm %s: bác nhưng không ghi lý do" % n["id"])
        else:
            decisions["accepted" if t == 0 else "rejected"].append((n["id"], reason_of(cells, 8)))
    for i, a in enumerate(data["assumptions"], 1):
        cells = sheet["rows"].get(("A", str(i)))
        if cells is None:
            out.append("phiếu không có hàng cho giả định A:%d" % i)
            continue
        t, why = decision(cells, 2, "giả định A:%d" % i)
        if why:
            out.append(why)
        elif t == 1:
            out.append("giả định A:%d bị bác: bản dịch phải làm lại, không đưa vào thư viện" % i)
    for i, e in enumerate(data["not_encoded"], 1):
        cells = sheet["rows"].get(("X", str(i)))
        if cells is None:
            out.append("phiếu không có hàng cho khoản để ngoài X:%d" % i)
            continue
        t, why = decision(cells, 3, "khoản để ngoài X:%d" % i)
        if why:
            out.append(why)
        elif t == 1:
            out.append("không đồng ý để ngoài %s: bản dịch phải làm lại" % e["clause"])
    if not out and not decisions["accepted"]:
        out.append("không có norm nào được chấp nhận")
    return out, decisions


# ------------------------------------------------------------------ module

def apply_decisions(data, decisions, reviewer, date):
    """The translation with rejected norms moved to not_encoded (with the reviewer's reason)."""
    rej = dict(decisions["rejected"])
    d = dict(data)
    d["norms"] = [n for n in data["norms"] if n["id"] not in rej]
    d["not_encoded"] = list(data["not_encoded"]) + [
        {"clause": n["source"], "reason": "norm %s bị bác bởi người duyệt %s (%s): %s" % (n["id"], reviewer, date, rej[n["id"]])}
        for n in data["norms"] if n["id"] in rej]
    return d


def module_text(name, merged, seg, reviews, consistent):
    """Lean module for LexProof/Laws/<name>.lean. `reviews`: [(translation rel path, sha, sheet rel path, sheet sha,
    reviewer, date, accepted ids, rejected ids)]. `consistent`: the evaluated result is consistentOn."""
    sit, par = merged["atoms"]["situation"], merged["atoms"]["parameters"]
    rs, sl = T.readers(sit)
    rp, pl = T.readers(par)
    y, m, d = (int(x) for x in merged["effective"].split("-"))
    acts = sorted({n["act"] for n in merged["norms"]})
    reviewer, rdate = reviews[0][4], reviews[0][5]
    ry, rm, rd = (int(x) for x in rdate.split("-"))
    q = T.lq
    L = ["import LexProof.Verify.AnalyzeReport", "import LexProof.Core.Render", "import LexProof.Core.ClauseRef", "",
         "/-!", "# %s — %s (%s), norms from an AI translation accepted on a review sheet" % (name, merged["label"], merged["doc_id"]), "",
         "Written by `pipeline/%s`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and" % TOOL,
         "the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor",
         "whether the answers are right. Faithfulness to the law is not proved by anything in this file.", "",
         ] + ([
         "Atoms of the glossary keep their id and are shared by every article that uses them; every term used was",
         "`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.",
         "A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer."]
         if merged.get("glossary_terms") else [
         "Atom names and norm ids carry their article («Điều 5 · ...»): two articles never share an atom, so a",
         "conflict that depends on a concept shared by two articles can be missed (no translation here uses the glossary)."]
         ) + ["", "Review sheets:"]
    for tr, tsha, sh, ssha, who, when, acc, rej in reviews:
        L.append("* `%s` (sha256 `%s`), sheet `%s` (sha256 `%s`), %s, %s: accepted %d, rejected %d%s" % (
            tr, tsha, sh, ssha, who.replace("-/", "- /"), when, len(acc), len(rej), (" (" + ", ".join(rej) + ")") if rej else ""))
    L += ["", "Assumptions accepted on the sheets:"]
    L += ["* " + a.replace("-/", "- /") for a in merged["assumptions"]] or ["* (none)"]
    L += T.glossary_header(merged)
    L += ["-/", "", "namespace LexProof.Laws.%s" % name, "", "open LexProof", "",
          "def tS : AtomTable :=", ("  [ " + "\n  , ".join(T.atom_lean(a) for a in sit) + " ]") if sit else "  []", "",
          "def tP : AtomTable :=", ("  [ " + "\n  , ".join(T.atom_lean(a) for a in par) + " ]") if par else "  []", "",
          "def rS : List ReaderSpec :=", ("  [ " + "\n  , ".join("(%s, %d, %d)" % (q(n), i, j) for n, i, j in rs) + " ]") if rs else "  []", "",
          "def rP : List ReaderSpec :=", ("  [ " + "\n  , ".join("(%s, %d, %d)" % (q(n), i, j) for n, i, j in rp) + " ]") if rp else "  []", "",
          "/-- Every legal unit of the document (articles, clauses, points), for the dangling-reference check. -/",
          T.catalog_lean(seg), "",
          "private def nrm (id : String) (mo : Modality) (act : String) (c : Cond) (ex : List Cond) (art : String)",
          "    (refs : List String) : Norm :=",
          "  { id := id, modality := mo, act := act, condition := c, exceptions := ex, priority := none",
          "  , source := { docId := %s, docType := %s, effective := ⟨%d, %d, %d⟩, article := art }" % (
              q(merged["doc_id"]), T.DOC_TYPES[merged["doc_type"]], y, m, d),
          "  , references := refs }", "", "def norms : List Norm :="]
    ns = ["nrm %s %s %s %s [%s] %s %s" % (q(n["id"]), T.MODALITIES[n["modality"]], q(n["act"]), T.cond_lean(n["condition"], sl, pl),
                                          ", ".join(T.cond_lean(e, sl, pl) for e in n["exceptions"]), q(n["source"]), T.refs_lean(n))
          for n in merged["norms"]]
    L += ["  [ " + "\n  , ".join(ns) + " ]", "",
          "/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/",
          "def notEncoded : List (String × String) :=",
          ("  [ " + "\n  , ".join("(%s, %s)" % (q(e["clause"]), q(e["reason"])) for e in merged["not_encoded"]) + " ]")
          if merged["not_encoded"] else "  []", "",
          "def acts : List Act := [" + ", ".join(q(a) for a in acts) + "]", "",
          "def status : ReviewStatus := .reviewed %s ⟨%d, %d, %d⟩" % (q(reviewer), ry, rm, rd), "",
          "/-- Every clause reference of the module, as written. -/",
          "def usedRefs : List String :=",
          "  norms.map (fun n => n.source.article) ++ norms.flatMap (·.references) ++ notEncoded.map (·.1) ++",
          "  (tS ++ tP).map (·.source) ++",
          "  (tS ++ tP).flatMap fun a => match a.domain with | .bool => [] | .enum vs => vs.map (·.source)", "",
          "def unparsable : List String :=",
          "  usedRefs.filter fun s => match parseEntry s with | .ok _ => false | .error _ => true", "",
          "/-! ## Checked by the kernel -/", "",
          "theorem refs_parse : unparsable = [] := by decide +kernel", "",
          "theorem silent : pfindings tS tP rS rP catalog norms = [] := by decide +kernel", ""]
    if consistent:
        L += ["theorem consistent :", "    analyzeP tS tP rS rP catalog norms = .consistentOn (projScope tS tP rS rP norms) := by",
              "  decide +kernel", "",
              "theorem no_conflict :", "    ∀ n₁ ∈ norms, ∀ n₂ ∈ norms, ∀ (π : Valuation tP) (s : Valuation tS),",
              "      ¬ Conflict (atomsOf tS tP rS rP) n₁ n₂ π s :=", "  not_conflict_of_consistentOnP consistent", ""]
    else:
        L += ["/-- The module has at least one formal conflict; `analyzeReport` lists the pairs. -/",
              "theorem has_conflict : (analyzeP tS tP rS rP catalog norms).isConsistentOn = false := by decide +kernel", ""]
    L += ["/-- What `analyzeReport` prints for this module (always print this, not only the core result). -/",
          "def report : List String := (analyzeReport status acts tS tP rS rP catalog norms).render", "",
          "end LexProof.Laws.%s" % name, ""]
    return "\n".join(L)


def add_import(path, name, before):
    with open(path, encoding="utf-8", newline="") as f:
        s = f.read()
    line = "import LexProof.Laws.%s" % name
    if line in s:
        return s, s
    nl = "\r\n" if "\r\n" in s else "\n"
    if before not in s:
        raise SystemExit("không tìm thấy «%s» trong %s" % (before, path))
    return s, s.replace(before, line + nl + before, 1)


def promote(name, pairs, build=True):
    """Returns the module path. Raises SystemExit with the reasons on refusal."""
    if not re.match(r"^[A-Z][A-Za-z0-9]*$", name):
        raise SystemExit("--name phải là tên module Lean dạng PascalCase, ví dụ Article19")
    target = os.path.join(LAWS, name + ".lean")
    if os.path.exists(target):
        raise SystemExit("đã có %s; không ghi đè" % RUN.rel(target))
    seg = T.load_segmented("44/2019/QH14")
    accepted, reviews, problems, seen = [], [], [], set()
    for tr, sh in pairs:
        data = json.load(open(tr, encoding="utf-8"))
        fs = T.check(data)
        if fs:
            problems += ["%s: bản dịch có %d phát hiện của `check`: %s" % (RUN.rel(tr), len(fs), fs[0])]
            continue
        if data["article"] in seen:
            problems.append("%s: Điều %d có hai bản dịch" % (RUN.rel(tr), data["article"]))
            continue
        seen.add(data["article"])
        sheet = parse_sheet(open(sh, encoding="utf-8").read())
        ps, dec = sheet_problems(data, tr, sheet)
        if ps:
            problems += ["%s: %s" % (RUN.rel(sh), p) for p in ps]
            continue
        m = T.materialize(apply_decisions(data, dec, sheet["reviewer"], sheet["date"]))
        if m.get("unapproved"):     # FR2 AC: a term the glossary reviewer has not approved never enters the library
            problems.append("%s: norm được chấp nhận dùng %d thuật ngữ chưa duyệt trong bảng: %s. Duyệt bảng thuật ngữ trước "
                            "(ADR-0027), rồi lập lại phiếu" % (RUN.rel(tr), len(m["unapproved"]), ", ".join(m["unapproved"])))
            continue
        cs = RUN.shared_conflicts(accepted, m)
        if cs:
            problems += ["%s: %s" % (RUN.rel(tr), c) for c in cs]
            continue
        accepted.append(m)
        reviews.append((RUN.rel(tr), sha_lf(tr), RUN.rel(sh), sha_lf(sh), sheet["reviewer"], sheet["date"],
                        [i for i, _ in dec["accepted"]], [i for i, _ in dec["rejected"]]))
    if problems:
        raise SystemExit("TỪ CHỐI:\n  - " + "\n  - ".join(problems))
    if len({(r[4], r[5]) for r in reviews}) > 1:
        raise SystemExit("TỪ CHỐI: các phiếu có người duyệt hoặc ngày khác nhau; gộp vào một module cần cùng một lần duyệt")
    merged = RUN.merge(accepted)
    # evaluate first, so the theorem written matches the result (the kernel then checks it in `lake build`)
    tmp = os.path.join(ROOT, "eval", "run", "_promote_%s.lean" % name)
    os.makedirs(os.path.dirname(tmp), exist_ok=True)
    with open(tmp, "w", encoding="utf-8", newline="\n") as f:
        f.write(T.to_lean(merged, seg))
    ev = RUN.run_lean(tmp)
    if not ev["ok"] or ev.get("pfindings") != 0 or ev.get("result") not in ("consistentOn", "XUNG ĐỘT"):
        raise SystemExit("TỪ CHỐI: bản nháp không qua Lean (%s)" % (ev.get("why") or "pfindings %s, kết quả %s" % (ev.get("pfindings"), ev.get("result"))))
    text = module_text(name, merged, seg, reviews, ev["result"] == "consistentOn")
    if not build:
        return target, text
    old_root, new_root = add_import(ROOT_FILE, name, "import LexProof.Cert.Audit")
    old_audit, new_audit = add_import(AUDIT_FILE, name, "import LexProof.Verify.Smoke")
    try:
        with open(target, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        for p, s in ((ROOT_FILE, new_root), (AUDIT_FILE, new_audit)):
            with open(p, "w", encoding="utf-8", newline="") as f:
                f.write(s)
        r = subprocess.run(["lake", "build"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
        if r.returncode != 0:
            raise RuntimeError((r.stdout + r.stderr)[-3000:])
    except Exception as e:   # put everything back: a failed promotion leaves no trace in the library
        for p, s in ((ROOT_FILE, old_root), (AUDIT_FILE, old_audit)):
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
    p = sub.add_parser("sheet")
    p.add_argument("translation")
    p.add_argument("-o", "--out", required=True)
    p = sub.add_parser("promote")
    p.add_argument("--name", required=True)
    p.add_argument("--pair", nargs=2, action="append", required=True, metavar=("TRANSLATION", "SHEET"))
    p.add_argument("--no-build", action="store_true", help="chỉ in module ra màn hình, không ghi vào thư viện")
    a = ap.parse_args(argv)
    if a.cmd == "sheet":
        data = json.load(open(a.translation, encoding="utf-8"))
        fs = T.check(data)
        if fs:
            print("TỪ CHỐI: bản dịch có %d phát hiện; sửa trước khi lập phiếu duyệt. Đầu tiên: %s" % (len(fs), fs[0]))
            return 1
        with open(a.out, "w", encoding="utf-8", newline="\n") as f:
            f.write(make_sheet(a.translation, data))
        print(a.out)
        return 0
    target, text = promote(a.name, a.pair, build=not a.no_build)
    if a.no_build:
        sys.stdout.write(text)
    else:
        print("đã ghi %s và chạy `lake build` thành công" % RUN.rel(target))
    return 0


if __name__ == "__main__":
    sys.exit(main())
