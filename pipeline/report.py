# -*- coding: utf-8 -*-
"""Report command (FR9, FR10). Untrusted: it formats what Lean printed; it proves nothing.

    python pipeline/report.py --module alcohol-sale --status draft
    python pipeline/report.py --module alcohol-sale --status reviewed --by NAME --date YYYY-MM-DD

Writes reports/alcohol-sale-<date>.md (Vietnamese). Reports are produced only by this command and are never edited
by hand. `reviewed` is REFUSED unless the case review sheet has every row answered with a reviewer and a date, and
declares the sha256 of the module file it was reviewed against (which must equal the current one).

The Lean side is `eval/report/Dump.lean` (run with `lake env lean --run`, prints JSON). `lake build LexProof` runs
first: no report is written if the build fails (fail closed).
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

TOOL = "report.py 1.0"
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
LAWS = "LexProof/Laws/"

MODULES = {
    "alcohol-sale": {
        "title": "Luật 44/2019/QH14, nhóm bán / cung cấp / khuyến mại rượu, bia",
        "module_file": LAWS + "AlcoholSale.lean",
        "files": {"AlcoholSale": LAWS + "AlcoholSale.lean", "Cases": LAWS + "AlcoholSaleCases.lean",
                  "Refs": LAWS + "AlcoholSaleRefs.lean", "Bands": LAWS + "AlcoholSaleBands.lean"},
        "ns": {"AlcoholSale": "LexProof.Laws.AlcoholSale", "Cases": "LexProof.Laws.AlcoholSaleCases",
               "Refs": "LexProof.Laws.AlcoholSaleRefs", "Bands": "LexProof.Laws.AlcoholSaleBands"},
        "dump": "eval/report/Dump.lean",
        "segmented": "data/segmented/44-2019-QH14.json",
        "input": "data/extracted/44-2019-QH14.txt",
        "ledger": "docs/review/alcohol-coverage-ledger.md",
        "sheet": "docs/review/sale-group-cases.md",
    },
}

NO_KERNEL = "chưa có định lý kernel cho kết quả này"


# ---------------------------------------------------------------- files

def path_of(rel):
    return os.path.join(ROOT, *rel.split("/"))


def read_bytes(rel):
    with open(path_of(rel), "rb") as f:
        return f.read()


def read_text(rel):
    return read_bytes(rel).decode("utf-8").replace("\r\n", "\n")


def sha_raw(rel):
    return hashlib.sha256(read_bytes(rel)).hexdigest()


def sha_lf(rel):
    """sha256 of the content with CRLF read as LF: the same on Windows (autocrlf) and Linux checkouts."""
    return hashlib.sha256(read_bytes(rel).replace(b"\r\n", b"\n")).hexdigest()


# ---------------------------------------------------------------- ledger and sheet

def parse_ledger(text):
    """The totals table under «## Tổng»: {status: (khoản, điểm, đoạn)}, plus the UNACCOUNTED rows."""
    sec = text.split("## Tổng", 1)[1].split("\n## ", 1)[0]
    rows = {}
    for line in sec.splitlines():
        cells = [c.strip().strip("*") for c in line.strip().strip("|").split("|")]
        if len(cells) == 4 and cells[1].isdigit():
            rows[cells[0]] = (int(cells[1]), int(cells[2]), int(cells[3]))
    m = re.search(r"UNACCOUNTED: (\d+) đơn vị", text)
    un = text.split("## UNACCOUNTED", 1)[1].split("\n## ", 1)[0] if "## UNACCOUNTED" in text else ""
    units = [ln.strip().strip("|").split("|")[0].strip() for ln in un.splitlines()
             if ln.startswith("| Điều")]
    return {"rows": rows, "unaccounted_total": int(m.group(1)) if m else None, "unaccounted_units": units}


SHEET_HASH = re.compile(r"^\s*sha256 mô-đun khi duyệt:\s*`?([0-9a-fA-F]{64})`?\s*$", re.M)


def parse_sheet(text):
    rows = {}
    for line in text.splitlines():
        if not re.match(r"^\|\s*C\d+\s*\|", line):
            continue
        cells = [c.strip() for c in re.split(r"(?<!\\)\|", line.strip())[1:-1]]
        rows[cells[0]] = cells
    m = SHEET_HASH.search(text)
    return {"rows": rows, "module_sha": m.group(1).lower() if m else None}


# columns of the sheet: Đúng ý/Sai ý, Câu trả lời của bạn, Người duyệt, Ngày
ANSWER_COLS = {5: "Đúng ý / Sai ý", 6: "Câu trả lời", 8: "Người duyệt", 9: "Ngày"}


TICKS = "☑☒✓✔"   # ballot box with check / with x, check marks


def answered(cell):
    """A checkbox cell (it has the empty box) is answered when exactly one option is ticked; any other cell, when it
    is not empty."""
    if "☐" in cell or any(t in cell for t in TICKS):
        return sum(cell.count(t) for t in TICKS) + len(re.findall(r"\[[xX]\]", cell)) == 1
    return bool(cell.strip())


def review_problems(sheet, case_ids, module_sha):
    """Reasons to refuse `reviewed`; empty if the sheet is complete and refers to this module file."""
    out = []
    for cid in case_ids:
        cells = sheet["rows"].get(cid)
        if cells is None or len(cells) < 10:
            out.append("phiếu không có hàng cho ca %s" % cid)
            continue
        miss = [name for i, name in ANSWER_COLS.items() if not answered(cells[i])]
        if miss:
            out.append("ca %s chưa điền: %s" % (cid, ", ".join(miss)))
    if sheet["module_sha"] is None:
        out.append("phiếu không có dòng «sha256 mô-đun khi duyệt: <64 ký tự hex>»")
    elif sheet["module_sha"] != module_sha:
        out.append("sha256 mô-đun trong phiếu (%s…) khác tệp mô-đun hiện tại (%s…): mô-đun đã đổi sau khi duyệt"
                   % (sheet["module_sha"][:12], module_sha[:12]))
    return out


# ---------------------------------------------------------------- kernel claims

def theorem_text(src, name):
    m = re.search(r"theorem\s+" + re.escape(name) + r"\b(.*?):=", src, re.S)
    return m.group(1) if m else None


def ids_in(stmt):
    return re.findall(r'"([^"]+)"', stmt.split("=", 1)[1]) if stmt and "=" in stmt else None


def kernel_claims(cfg, data):
    """For each headline result: the kernel theorem that states it (if the source has one), and whether the
    interpreter output (the dump) agrees with that statement. The statement is read from the source text; that
    the theorem is true is what `lake build` established just before this report."""
    srcs = {k: read_text(v) for k, v in cfg["files"].items()}
    a = data["analyze"]
    cs = data["cases"]

    def thm(key, name):
        return theorem_text(srcs[key], name)

    def full(key, name):
        return cfg["ns"][key] + "." + name

    out = []

    def add(headline, key, name, agree_fn):
        t = thm(key, name) if name else None
        if t is None:
            out.append({"headline": headline, "theorem": None, "agree": None})
        else:
            out.append({"headline": headline, "theorem": full(key, name), "agree": bool(agree_fn(t))})

    add("kết quả phân tích (consistentOn)", "AlcoholSale", "consistent",
        lambda t: "consistentOn" in t and a["result"] == "consistentOn")
    add("không có xung đột giữa hai norm nào (suy ra từ trên)", "AlcoholSale", "no_conflict_in_group",
        lambda t: a["result"] == "consistentOn")
    add("không có phát hiện cấu trúc (bảng, bộ đọc, validate)", "AlcoholSale", "silent",
        lambda t: "= []" in t and a["module_findings"] == [])
    pass_ids = [c["id"] for c in cs if c["outcome"] == "pass"]
    add("tập ca đạt (runCase)", "Cases", "pass_set",
        lambda t: ids_in(t) == pass_ids)
    out_ids = [c["id"] for c in cs if c["scope"]["kind"] == "outOfScope"]
    add("tập ca ngoài phạm vi (theo tham chiếu)", "Refs", "refOutOfScope_set",
        lambda t: ids_in(t) == out_ids)
    add("các ca số đều đạt", "Bands", "num_pass_all",
        lambda t: all(n["outcome"] == "pass" for n in data["num_cases"]))
    fr = data["ref_findings"]
    add("không có chuỗi tham chiếu không phân tích được", "Refs", "unparsable_none",
        lambda t: not any(f.startswith("không phân tích được") for f in fr))
    add("không có tham chiếu ngoài catalog", "Refs", "notInCatalog_none",
        lambda t: not any(f.startswith("không có trong catalog") for f in fr))
    add("hai chuỗi khác nhau cùng một tham chiếu (C37)", "Refs", "sameRef_c37",
        lambda t: sum(f.startswith("hai chuỗi") for f in fr) == 1 and "Điều 19" in t)
    # results with no theorem about THIS module: look for any theorem that mentions the instance
    allsrc = "\n".join(srcs.values())
    for headline, needle in (("cờ rỗng về modality (noModalityClash)", "noModalityClash norms"),
                             ("các cặp được ưu tiên giải quyết (resolutions)", "resolvedPairs norms"),
                             ("phát hiện về act (act dùng một lần, act ngoài danh mục)", "actFindings norms")):
        hit = re.search(r"theorem[^:]*:[^=]*" + re.escape(needle), allsrc)
        out.append({"headline": headline, "theorem": "?" if hit else None, "agree": None})
    out.append({"headline": "tổng của sổ phủ (ledger)", "theorem": None, "agree": None})
    out.append({"headline": "kết quả từng ca không đạt (loại kết quả «got»)", "theorem": None, "agree": None})
    return out


def claim_text(c):
    if c["theorem"] is None:
        return NO_KERNEL
    ag = {True: "máy diễn giải KHỚP", False: "máy diễn giải KHÔNG KHỚP phát biểu", None: "không so được"}[c["agree"]]
    return "định lý `%s`; %s" % (c["theorem"], ag)


# ---------------------------------------------------------------- collecting from Lean and git

def run(cmd):
    return subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True, encoding="utf-8")


def collect(cfg, build=True):
    lake = shutil.which("lake")
    if lake is None:
        raise SystemExit("không tìm thấy `lake` trong PATH: không thể chạy Lean, không tạo báo cáo")
    info = {"ran": False, "ok": None, "audit": None}
    if build:
        p = run([lake, "build", "LexProof"])
        m = re.search(r"axiom audit: (\d+) declarations, all within", p.stdout + p.stderr)
        info = {"ran": True, "ok": p.returncode == 0, "audit": int(m.group(1)) if m else None}
        if not info["ok"]:
            raise SystemExit("`lake build LexProof` thất bại: không tạo báo cáo.\n" + (p.stdout + p.stderr)[-2000:])
    p = run([lake, "env", "lean", "--run", cfg["dump"]])
    if p.returncode != 0:
        raise SystemExit("chạy %s thất bại:\n%s" % (cfg["dump"], (p.stdout + p.stderr)[-2000:]))
    data = json.loads(p.stdout)
    data["build"] = info
    ver = run([lake, "env", "lean", "--version"])
    data["lean_version"] = ver.stdout.strip() if ver.returncode == 0 else None
    return data


def git_info():
    g = shutil.which("git")
    if g is None:
        return None
    h = run([g, "rev-parse", "HEAD"])
    if h.returncode != 0:
        return None
    st = run([g, "status", "--porcelain"])
    return {"commit": h.stdout.strip(), "dirty": len([ln for ln in st.stdout.splitlines() if ln.strip()])}


# ---------------------------------------------------------------- rendering

STATUS_VI = {"pass": "PASS", "fail": "FAIL", "underspecified": "UNDERSPECIFIED", "malformed": "MALFORMED"}


def ids_line(ids):
    return ", ".join(ids) if ids else "(không có)"


def case_row(c):
    return "| %s | %s | %s | %s | %s |" % (c["id"], c["act"], c["clause"], c["expected"], c["description"].replace("|", "/"))


def scope_text(c):
    s = c["scope"]
    if s["kind"] == "ran":
        return "trong phạm vi (khoản đã mã hóa)"
    if s["kind"] == "outOfScope":
        return "NGOÀI PHẠM VI (khoản «%s» không được mã hóa)" % s["entry"]
    return "tham chiếu hỏng: %s" % s.get("why", "")


def render(cfg, data, status, review=None, today=None, extra=None):
    """Pure function of its inputs: the same inputs give the same text (the date line aside)."""
    extra = extra or {}
    a = data["analyze"]
    cs = data["cases"]
    led = extra["ledger"]
    claims = kernel_claims(cfg, data)
    L = []
    w = L.append

    # 1
    w("# Báo cáo nhất quán: %s" % cfg["title"])
    w("")
    if status == "draft":
        w("## 1. Trạng thái")
        w("")
        w("> # BẢN NHÁP, CHƯA CÓ NGƯỜI DUYỆT")
        w(">")
        w("> Bản mã hóa do AI soạn và chưa ai đối chiếu với luật. «Đã mã hóa» trong báo cáo này chỉ nghĩa là có một norm nháp "
          "trích dẫn khoản đó.")
    else:
        w("## 1. Trạng thái")
        w("")
        w("> # PHIẾU CA THỬ ĐÃ ĐƯỢC ĐIỀN: người duyệt %s, ngày %s" % (review["by"], review["date"]))
        w(">")
        w("> Đây là ghi nhận: công cụ chỉ kiểm phiếu đủ hàng, đủ người duyệt và ngày, và mô-đun không đổi từ lúc duyệt. "
          "Công cụ không kiểm danh tính, không kiểm nội dung câu trả lời, và việc này không có nghĩa bản mã hóa khớp luật.")
    w("")

    # 2
    w("## 2. Phạm vi")
    w("")
    rows = led["rows"]
    tot = rows["Cộng"]

    def row(name):
        return rows.get(name, (0, 0, 0))
    enc = [x + y for x, y in zip(row("encoded"), row("encoded (một phần)"))]
    notenc = [x + y for x, y in zip(row("not encoded"), row("not encoded (một phần)"))]
    w("Nguồn: sổ phủ `%s` (sha256 ở mục 7). Số đơn vị của toàn văn bản: %d khoản, %d điểm, %d đoạn dẫn không đánh số "
      "(đếm theo điều có đoạn dẫn)." % (cfg["ledger"], tot[0], tot[1], tot[2]))
    w("")
    w("| Trạng thái | Khoản | Điểm | Đoạn dẫn không đánh số |")
    w("|---|---|---|---|")
    for name, vals in (("đã mã hóa (nháp), gồm một phần", enc), ("trong đó một phần", row("encoded (một phần)")),
                       ("chưa mã hóa (not encoded), gồm một phần", notenc), ("ngoài mô-đun (outside this module)", row("outside this module")),
                       ("UNACCOUNTED (trong phạm vi mô-đun nhưng không được nhắc)", row("UNACCOUNTED")),
                       ("chưa phân loại", row("chưa phân loại")), ("tổng", tot)):
        w("| %s | %d / %d | %d / %d | %d / %d |" % (name, vals[0], tot[0], vals[1], tot[1], vals[2], tot[2]))
    w("")
    w("UNACCOUNTED: %s đơn vị (khoản + điểm + đoạn): %s." % (led["unaccounted_total"], "; ".join(led["unaccounted_units"]) or "không có"))
    w("")
    w("**Bảng này đếm xem đơn vị của luật có được một norm nháp hay một mục chưa-mã-hóa nhắc tới hay không. "
      "Nó không phải thước đo độ trung thực của bản mã hóa với luật.**")
    w("")
    w("Các mục chưa mã hóa mà mô-đun tự khai (notEncoded):")
    w("")
    for e in data["not_encoded"]:
        w("- %s: %s" % (e["clause"], e["reason"]))
    w("")

    # 3
    w("## 3. Kết quả nhất quán")
    w("")
    if a["result"] == "consistentOn" and a["no_modality_clash"]:
        w("> **Nói trước: mô-đun này không có act nào có hai modality khắc nhau (mọi norm đều là cấm), nên không xung đột "
          "modality nào có thể xảy ra. «consistentOn» ở đây RỖNG về thông tin: nó đúng với mọi nội dung điều kiện, kể cả "
          "điều kiện sai.**")
        w("")
    verdict = {"consistentOn": "NHẤT QUÁN TRÊN PHẦN ĐÃ MÃ HÓA (consistentOn)",
               "conflicts": "TÌM THẤY XUNG ĐỘT hình thức (conflicts)",
               "invalid": "KHÔNG BIẾT (invalid): đầu vào có phát hiện, chưa kiểm xung đột nào"}[a["result"]]
    w("Kết quả có ba giá trị: tìm thấy xung đột / nhất quán trên phần đã mã hóa / không biết. Với mô-đun này: **%s**." % verdict)
    w("")
    if a["result"] == "consistentOn":
        w("- Đã kiểm %d cặp norm cùng act; bỏ qua %d cặp khác act." % (a["pairs_checked"], a["pairs_skipped"]))
        w("- Miền tình huống đầy đủ %d tổ hợp, tham số %d; mỗi cặp được tìm trên các atom nó đọc." % (a["full_situations"], a["full_params"]))
        w("- Ràng buộc toàn vẹn: %s." % ("có dùng" if a["constraints_used"] else "KHÔNG dùng"))
    elif a["result"] == "conflicts":
        w("- Các cặp: " + "; ".join(a["hits"]))
    else:
        for f in a["findings"]:
            w("- " + f)
    w("- Kết quả này chỉ nói về phần đã mã hóa ở mục 2, không nói gì về cả văn bản.")
    w("")
    w("Định lý kernel và máy diễn giải cho từng kết quả chính:")
    w("")
    w("| Kết quả | Định lý kernel / máy diễn giải |")
    w("|---|---|")
    for c in claims:
        w("| %s | %s |" % (c["headline"], claim_text(c)))
    w("")
    if any(c["agree"] is False for c in claims):
        w("**CẢNH BÁO: có kết quả mà máy diễn giải KHÔNG KHỚP phát biểu định lý trong mã nguồn. Đừng dùng báo cáo này.**")
        w("")
    w("Định lý kernel nói về mã hóa nháp theo đúng phát biểu của nó; không định lý nào nói bản mã hóa khớp luật.")
    w("")

    # 4
    w("## 4. Phát hiện cấu trúc")
    w("")
    w("- Phát hiện của bảng atom, bộ đọc và validate: %s." % (str(len(a["module_findings"])) + " (" + "; ".join(a["module_findings"]) + ")" if a["module_findings"] else "không có"))
    w("- Phát hiện về act (act ngoài danh mục): %s." % ("; ".join(a["act_findings"]) or "không có"))
    w("- Act chỉ dùng một norm: %s." % (", ".join(a["single_use_acts"]) or "không có"))
    w("- Act trong danh mục nhưng không norm nào dùng: %s." % (", ".join(a["unused_catalog_acts"]) or "không có"))
    w("- Cặp norm được ưu tiên giải quyết: %d." % len(a["resolutions"]))
    w("- Act: " + "; ".join("%s (%d norm, có cặp khắc nhau: %s)" % (x["act"], x["norms"], "có" if x["clash"] else "không") for x in a["acts"]))
    w("- Phát hiện về tham chiếu:")
    for f in data["ref_findings"]:
        w("  - " + f)
    w("")

    # 5
    w("## 5. Kết quả các ca thử")
    w("")
    w("Các ca do cùng tác giả viết bản mã hóa và đọc cùng một cách; ca đạt cho thấy bản mã hóa khớp cách đọc của tác giả; nó không cho thấy bản mã hóa khớp luật. "
      "**noNormApplies và outOfScope không nói gì về luật**: noNormApplies chỉ nghĩa là không norm nào của mô-đun này áp dụng, "
      "outOfScope nghĩa là khoản đó không được mã hóa và ca không được chạy như một phép thử.")
    w("")
    outs = [c for c in cs if c["scope"]["kind"] == "outOfScope"]
    bad = [c for c in cs if c["scope"]["kind"] == "badRef"]
    inscope = [c for c in cs if c["scope"]["kind"] == "ran"]
    by = lambda o: [c for c in inscope if c["outcome"] == o]
    w("Tổng %d ca: PASS %d, FAIL %d, UNDERSPECIFIED %d, MALFORMED %d (trong phạm vi); outOfScope %d; tham chiếu hỏng %d." % (
        len(cs), len(by("pass")), len(by("fail")), len(by("underspecified")), len(by("malformed")), len(outs), len(bad)))
    w("")
    header = ["| Ca | Act | Khoản | Kỳ vọng | Tình huống |", "|---|---|---|---|---|"]
    w("### FAIL")
    w("")
    if by("fail"):
        w("| Ca | Act | Khoản | Kỳ vọng | Mô-đun cho | Phạm vi |")
        w("|---|---|---|---|---|---|")
        for c in by("fail"):
            w("| %s | %s | %s | %s | %s | %s |" % (c["id"], c["act"], c["clause"], c["expected"], c.get("got", "?"), scope_text(c)))
    else:
        w("(không có)")
    w("")
    for o, title in (("underspecified", "UNDERSPECIFIED"), ("malformed", "MALFORMED")):
        w("### " + title)
        w("")
        w("; ".join("%s (%s)" % (c["id"], ", ".join(c.get("missing", [])) or c.get("why", "")) for c in by(o)) or "(không có)")
        w("")
    w("### outOfScope (liệt kê riêng; không phải PASS, không nói gì về luật)")
    w("")
    if outs:
        w("| Ca | Act | Khoản | Kỳ vọng | Phạm vi | Chạy không xét phạm vi |")
        w("|---|---|---|---|---|---|")
        for c in outs:
            w("| %s | %s | %s | %s | %s | %s |" % (c["id"], c["act"], c["clause"], c["expected"], scope_text(c), STATUS_VI[c["outcome"]]))
    else:
        w("(không có)")
    w("")
    w("Cột cuối chỉ để nhìn; ca ngoài phạm vi không được tính là đạt.")
    w("")
    w("### PASS (trong phạm vi; noNormApplies luôn kèm trạng thái phạm vi)")
    w("")
    w("| Ca | Act | Khoản | Kỳ vọng | Phạm vi |")
    w("|---|---|---|---|---|")
    for c in by("pass"):
        w("| %s | %s | %s | %s | %s |" % (c["id"], c["act"], c["clause"], c["expected"], scope_text(c)))
    w("")
    if bad:
        w("### Tham chiếu hỏng")
        w("")
        for c in bad:
            w("- %s: %s" % (c["id"], scope_text(c)))
        w("")
    nc = data["num_cases"]
    npass = [n["id"] for n in nc if n["outcome"] == "pass"]
    nbad = [n for n in nc if n["outcome"] != "pass"]
    w("### Ca số (dải số)")
    w("")
    w("%d ca, PASS %d. Không đạt: %s." % (len(nc), len(npass), ", ".join("%s (%s)" % (n["id"], n["outcome"]) for n in nbad) or "không có"))
    w("")
    w("Giới hạn thang không có trong luật (giả định của người mã hóa):")
    w("")
    for b in data["assumed_bounds"]:
        w("- " + b)
    w("")
    w("### So hai cách xác định phạm vi")
    w("")
    w("Cách cũ (bảng ghi đè `keyOverride` + so chuỗi, nay chỉ để so sánh) và cách mới (theo tham chiếu `ClauseRef`) khác nhau ở: %s." % ids_line(data["scoping_diff"]))
    w("")

    # 6
    w("## 6. Báo cáo này KHÔNG nói gì")
    w("")
    for s in (
        "Không phải tư vấn pháp lý. Không nói hành vi nào là hợp pháp hay trái luật.",
        "Không được đối chiếu với luật: bản mã hóa chưa được kiểm chứng với văn bản luật, và không có ý nào trong báo cáo khẳng định điều đó. "
        "Chỉ người duyệt mới làm được việc đó.",
        "Không nói bản mã hóa đúng luật. Kernel chỉ kiểm chứng các định lý về mã hóa nháp ở mục 3; độ trung thực không được kiểm bằng máy.",
        "Ràng buộc toàn vẹn không được dùng: một xung đột được báo (nếu có) có thể nằm ở tình huống bất khả thi, và một kết quả nhất quán không nói gì về tình huống đó.",
        "Ngưỡng, dải số và bộ đọc chỉ được kiểm là phủ kín và nhất quán nội bộ; ý nghĩa của chúng (ví dụ «15 độ», «chưa đủ 18 tuổi») không được kiểm.",
        "Khái niệm mở («dành cho người chưa đủ 18 tuổi», «được phép kinh doanh») là tham số; hệ thống không quyết định chúng.",
        "Bản trích xuất văn bản chưa được so với văn bản in; bộ tách đoạn chưa được kiểm độc lập (chỉ kiểm nhất quán nội bộ và băm đầu vào).",
        "Không nói gì về các khoản chưa phân loại, ngoài mô-đun hay UNACCOUNTED ở mục 2, và không nói gì về các văn bản khác.",
        "noNormApplies và outOfScope không có nghĩa là hợp pháp hay đúng luật.",
    ):
        w("- " + s)
    w("")

    # 7
    w("## 7. Nguồn gốc")
    w("")
    seg = extra["segmented"]
    w("- Đầu vào `%s`: sha256 trong bộ tách `%s`; sha256 hiện tại của tệp `%s` (đọc nguyên byte); khớp: %s." % (
        cfg["input"], seg["input"]["sha256"], extra["input_raw"], "có" if seg["input"]["sha256"] == extra["input_raw"] else "KHÔNG"))
    w("- Đầu vào, sha256 khi đọc CRLF như LF: `%s`." % extra["input_lf"])
    w("- Bộ tách: %s; %d dòng; stray_paragraphs = %d (dòng thụt đầu dòng trong khoản/điểm; không phải số đoạn dẫn ở mục 2)." % (
        seg["tool"], seg["input"]["lines"], seg["stray_paragraphs"]))
    w("- Tệp mô-đun `%s`: sha256 (CRLF như LF) `%s`; nguyên byte `%s`." % (cfg["module_file"], extra["module_lf"], extra["module_raw"]))
    for k, v in cfg["files"].items():
        if v != cfg["module_file"]:
            w("- Tệp `%s`: sha256 (CRLF như LF) `%s`." % (v, extra["files_lf"][k]))
    w("- Sổ phủ `%s`: sha256 (CRLF như LF) `%s`." % (cfg["ledger"], extra["ledger_lf"]))
    w("- Toolchain: `%s`; %s." % (extra["toolchain"], data.get("lean_version") or "không đọc được phiên bản lean"))
    b = data["build"]
    if b["ran"]:
        w("- `lake build LexProof`: %s; kiểm toán axiom: %s." % ("xanh" if b["ok"] else "THẤT BẠI",
          ("%d khai báo, đều trong danh sách cho phép" % b["audit"]) if b["audit"] is not None else "không đọc được số khai báo"))
    else:
        w("- `lake build LexProof` không được chạy cho báo cáo này; số khai báo kiểm toán không có.")
    g = extra["git"]
    w("- Git: %s." % (("commit %s; %d tệp thay đổi chưa commit" % (g["commit"], g["dirty"])) if g else "không có thông tin"))
    w("- Công cụ: %s; Lean đọc `%s` (sha256, CRLF như LF: `%s`)." % (TOOL, cfg["dump"], extra["dump_lf"]))
    if review:
        w("- Phiếu ca thử `%s`: sha256 (CRLF như LF) `%s`; người duyệt ghi trong phiếu: %s." % (
            cfg["sheet"], review["sheet_sha"], ", ".join(review["reviewers"])))
        w("- sha256 mô-đun ghi trong phiếu khi duyệt (bằng tệp mô-đun hiện tại): `%s`." % review["module_sha"])
    w("- Ngày tạo báo cáo: %s" % (today or datetime.date.today().isoformat()))
    w("")
    return "\n".join(L)


# ---------------------------------------------------------------- main

def build_extra(cfg):
    return {
        "ledger": parse_ledger(read_text(cfg["ledger"])),
        "segmented": json.loads(read_text(cfg["segmented"])),
        "input_raw": sha_raw(cfg["input"]), "input_lf": sha_lf(cfg["input"]),
        "module_lf": sha_lf(cfg["module_file"]), "module_raw": sha_raw(cfg["module_file"]),
        "files_lf": {k: sha_lf(v) for k, v in cfg["files"].items()},
        "ledger_lf": sha_lf(cfg["ledger"]), "dump_lf": sha_lf(cfg["dump"]),
        "toolchain": read_text("lean-toolchain").strip(),
        "git": git_info(),
    }


def make_report(cfg, data, status, by=None, review_date=None, sheet_path=None, today=None, extra=None):
    """Returns the report text, or raises SystemExit with the reasons for a refusal."""
    extra = extra or build_extra(cfg)
    review = None
    if status == "reviewed":
        if not by or not review_date:
            raise SystemExit("`--status reviewed` cần --by NAME và --date D")
        try:
            datetime.date.fromisoformat(review_date)
        except ValueError:
            raise SystemExit("--date phải có dạng YYYY-MM-DD")
        text = open(sheet_path, encoding="utf-8").read().replace("\r\n", "\n") if sheet_path else read_text(cfg["sheet"])
        sheet = parse_sheet(text)
        probs = review_problems(sheet, [c["id"] for c in data["cases"]], extra["module_lf"])
        if probs:
            raise SystemExit("TỪ CHỐI `reviewed`:\n  - " + "\n  - ".join(probs))
        reviewers = sorted({cells[8] for cells in sheet["rows"].values()})
        review = {"by": by, "date": review_date, "sheet_sha": hashlib.sha256(text.encode("utf-8")).hexdigest(),
                  "module_sha": extra["module_lf"], "reviewers": reviewers}
    return render(cfg, data, status, review, today, extra)


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--module", choices=sorted(MODULES), default="alcohol-sale")
    ap.add_argument("--status", choices=["draft", "reviewed"])
    ap.add_argument("--print-module-sha256", action="store_true",
                    help="print the sha256 (CRLF read as LF) of the module file, for the review sheet, and stop")
    ap.add_argument("--by")
    ap.add_argument("--date", help="ngày duyệt (YYYY-MM-DD), chỉ với --status reviewed")
    ap.add_argument("--sheet", help="đường dẫn phiếu ca thử (mặc định: phiếu của mô-đun)")
    ap.add_argument("--out-dir", default=os.path.join(ROOT, "reports"))
    ap.add_argument("--no-build", action="store_true", help="không chạy `lake build` (báo cáo ghi rõ là không chạy)")
    a = ap.parse_args(argv)
    cfg = MODULES[a.module]
    if a.print_module_sha256:
        print(sha_lf(cfg["module_file"]))
        return
    if a.status is None:
        ap.error("--status là bắt buộc")
    data = collect(cfg, build=not a.no_build)
    today = datetime.date.today().isoformat()
    text = make_report(cfg, data, a.status, a.by, a.date, a.sheet, today)
    os.makedirs(a.out_dir, exist_ok=True)
    name = "%s-%s%s.md" % (a.module, today, "" if a.status == "draft" else "-reviewed")
    out = os.path.join(a.out_dir, name)
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print(out)


if __name__ == "__main__":
    main()
