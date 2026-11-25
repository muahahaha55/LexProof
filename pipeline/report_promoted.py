# -*- coding: utf-8 -*-
"""Report for a promoted module (`--module law44` of `pipeline/report.py`). UNTRUSTED: it formats what Lean printed
and what the files say; it proves nothing. Called only from `report.py` (reports are produced only by that command).

A promoted module is built by `promote.py` from translations a person accepted on review sheets. Unlike the
alcohol-sale module it has no expert case set (FR12 not done), so a `reviewed` report is refused: the only
report is a draft whose section 1 says what was reviewed (the norms, row by row) and what was not (any case, any
answer of a legal expert).
"""
import datetime
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import report as R   # noqa: E402
import translate as T   # noqa: E402

TOOL = "report.py 1.0 (module đã promote)"


def lean_dump(cfg):
    """Runs a small generated program on the module and returns its tagged lines."""
    ns = cfg["ns"]
    src = "\n".join([
        "import %s" % ns, "open LexProof %s" % ns, "def main : IO Unit := do",
        "  for n in norms do IO.println s!\"N\\t{n.id}\\t{n.source.article}\\t{n.act}\"",
        "  for e in notEncoded do IO.println s!\"X\\t{e.1}\\t{e.2}\"",
        "  for l in report do IO.println s!\"R\\t{l}\"", ""])
    d = tempfile.mkdtemp()
    try:
        p = os.path.join(d, "Dump.lean")
        with open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(src)
        r = R.run([shutil.which("lake") or "lake", "env", "lean", "--run", p])
    finally:
        shutil.rmtree(d)
    if r.returncode != 0:
        raise SystemExit("chạy Lean trên %s thất bại: không tạo báo cáo.\n%s" % (ns, (r.stdout + r.stderr)[-2000:]))
    out = {"norms": [], "not_encoded": [], "render": []}
    for line in r.stdout.splitlines():
        tag, _, rest = line.partition("\t")
        if tag == "N":
            i, art, act = rest.split("\t")
            out["norms"].append({"id": i, "source": art, "act": act})
        elif tag == "X":
            c, _, why = rest.partition("\t")
            out["not_encoded"].append({"clause": c, "reason": why})
        elif tag == "R":
            out["render"].append(rest)
    return out


def build(cfg, build=True):
    lake = shutil.which("lake")
    if lake is None:
        raise SystemExit("không tìm thấy `lake` trong PATH: không thể chạy Lean, không tạo báo cáo")
    info = {"ran": False, "ok": None, "audit": None}
    if build:
        p = R.run([lake, "build", "LexProof"])
        m = re.search(r"axiom audit: (\d+) declarations, all within", p.stdout + p.stderr)
        info = {"ran": True, "ok": p.returncode == 0, "audit": int(m.group(1)) if m else None}
        if not info["ok"]:
            raise SystemExit("`lake build LexProof` thất bại: không tạo báo cáo.\n" + (p.stdout + p.stderr)[-2000:])
    return info


# ---------------------------------------------------------------- scope

def unit_of(ref):
    """The legal unit a norm source names: a branch («nhánh (i)») belongs to its clause or point."""
    return re.sub(r"\s+nhánh\s*\(.*?\)$", "", ref.strip())


def under(a, b):
    """Unit `a` is `b` or inside it (by its textual id: «Điều 5 khoản 3» is inside «Điều 5»)."""
    return a == b or a.startswith(b + " ")


def classification(path):
    """{article number: decision} from the hand-made classification sheet (ticks only; the tool reads, it does not judge)."""
    out = {}
    if not os.path.exists(R.path_of(path)):
        return out
    for line in R.read_text(path).splitlines():
        m = re.match(r"^\|\s*NE:(\d+)\s*\|", line)
        if not m:
            continue
        cells = [c.strip() for c in re.split(r"(?<!\\)\|", line.strip().strip("|"))]
        dec = cells[-2] if len(cells) >= 2 else ""
        opts = [o.strip() for o in dec.split("<br>")]
        ticked = [o for o in opts if o.lower().startswith("[x]") or o[:1] in "☑☒✓✔"]
        if len(ticked) != 1:
            out[int(m.group(1))] = "chưa duyệt"
        else:
            out[int(m.group(1))] = "đồng ý để ngoài" if "Đồng ý" in ticked[0] else "không đồng ý để ngoài: cần mã hóa"
    return out


def scope(cfg, dump):
    seg = json.loads(R.read_text(cfg["segmented"]))
    srcs = [unit_of(n["source"]) for n in dump["norms"]]
    nes = [e["clause"] for e in dump["not_encoded"]]
    cls = classification(cfg["classification"])
    arts, gaps = [], []
    for a in seg["articles"]:
        aid = a["id"]
        k = [s for s in srcs if under(s, aid)]
        x = [c for c in nes if under(c, aid)]
        units = [c["id"] for c in a["clauses"]] + [p["id"] for c in a["clauses"] for p in c["points"]]
        if k or x:
            status = "đã mã hóa"
            # every clause and point of an encoded article must be covered by a norm or by a not-encoded entry
            for u in units:
                if not any(under(s, u) or under(u, s) for s in srcs + nes):
                    gaps.append(u)
        else:
            status = {"đồng ý để ngoài": "ngoài phạm vi mã hóa (người duyệt đồng ý)"}.get(cls.get(a["number"]),
                                                                                          cls.get(a["number"], "chưa xét"))
        arts.append({"n": a["number"], "title": a["title"], "status": status, "norms": len(k), "not_encoded": len(x)})
    return arts, gaps


# ---------------------------------------------------------------- render

def theorems(src):
    return [(m.group(1), " ".join(m.group(2).split())) for m in re.finditer(r"^theorem\s+(\S+)\s*:(.*?):=", src, re.S | re.M)]


def edges_section(cfg):
    if not cfg.get("edges") or not os.path.exists(R.path_of(cfg["edges"])):
        return ["Không có tệp cạnh kéo theo."]
    import edges as E   # noqa: E402
    d = tempfile.mkdtemp()
    try:
        _, res, need, pairs = E.draft(R.path_of(cfg["edges"]), cfg["lean_module"], d)
    finally:
        shutil.rmtree(d)
    dd = E.load(R.path_of(cfg["edges"]))
    byid = {e["id"]: e for e in dd["edges"]}
    origins = sorted({tuple(sorted((E.chain(l)[1], E.chain(r)[1]))) for l, r in pairs})
    L = ["> Mục này dùng **cách đọc** (cạnh «làm A thì nhất thiết làm B», ADR-0029), kể cả cạnh do AI đề xuất chưa ai duyệt. "
         "Nó **không** đổi kết luận ở mục 1, và kết quả của nó không phải sự thật về luật.", "",
         "- Tệp cạnh: `%s` (sha256 `%s`): %d cạnh, approved %d, proposed %d, rejected %d" % (
             cfg["edges"], R.sha_lf(cfg["edges"]), len(dd["edges"]),
             *[sum(e["status"] == s for e in dd["edges"]) for s in ("approved", "proposed", "rejected")]),
         "- Kết quả Lean (Evaluated, chạy mã; không phải định lý kernel): %s" % res, ""]
    if origins:
        L.append("Cặp norm gốc va nhau qua cạnh (%d):" % len(origins))
        L += ["- `%s` × `%s`" % o for o in origins]
        L.append("")
    L.append("Cạnh nằm trên đường dẫn tới một cặp xung đột (chỉ các cạnh này cần quyết trước):")
    L += ["- %s `%s ⇒ %s` [%s]: %s" % (i, byid[i]["src"], byid[i]["dst"], byid[i]["status"], byid[i]["reading"]) for i in need] \
        or ["- (không có)"]
    return L


UNK = re.compile(r'^\s*[\[,] \("((?:[^"\\]|\\.)*)", "((?:[^"\\]|\\.)*)"\)', re.M)


def drafting_section(cfg):
    """From the drafting module's source: its kernel theorems and its `unknown` list (no witness found)."""
    name = cfg.get("drafting")
    path = R.LAWS + name + ".lean" if name else None
    if not path or not os.path.exists(R.path_of(path)):
        return ["Chưa có module kiểm lỗi soạn thảo cho module này."]
    src = R.read_text(path)
    thms = [t for t, _ in theorems(src)]
    body = src.split("def unknown", 1)[1].split("def liveSkip", 1)[0] if "def unknown" in src else ""
    unk = UNK.findall(body)
    L = ["Đây **không** phải kiểm xung đột và không đổi kết luận ở mục 1. Nó tìm ba dấu hiệu lỗi soạn thảo trong phần đã mã hóa: "
         "norm không bao giờ áp dụng (chết), norm bị một norm khác cùng hành vi, cùng tính chất bao trùm (thừa), ngoại lệ "
         "không bao giờ kích hoạt. Một luật có thể cố ý nhắc lại, nên «thừa» chưa chắc là lỗi.", "",
         "- Module: `%s` (sha256 `%s`); định lý kernel: %s" % (path, R.sha_lf(path), ", ".join("`%s`" % t for t in thms) or "(không có)"),
         "- Cách chứng minh: một công cụ không tin cậy tìm cho mỗi mục **một tình huống làm chứng**; kernel kiểm từng chứng nhân. "
         "Mục không tìm được chứng nhân thì bị loại khỏi định lý và ghi «không biết» dưới đây; hệ thống không khẳng định nó là lỗi.", ""]
    if unk:
        L.append("**Không biết (%d), cần người xem:**" % len(unk))
        L += ["- `%s`: %s" % (a, b) for a, b in unk]
    else:
        L.append("Mọi norm, mọi cặp cùng hành vi và cùng tính chất, mọi ngoại lệ đều có chứng nhân: không có dấu hiệu nào.")
    return L


def render(cfg, info, dump, today):
    src = R.read_text(cfg["module_file"])
    arts, gaps = scope(cfg, dump)
    res = next((l for l in dump["render"] if l.startswith("KẾT QUẢ")), None)
    vac = any("rỗng về xung đột modality" in l for l in dump["render"])
    thms = theorems(src)
    names = [t for t, _ in thms]
    L = []
    w = L.append
    w("# Báo cáo nhất quán: %s" % cfg["title"])
    w("")
    w("## 1. Kết luận")
    w("")
    w("> # BẢN NHÁP: CÁC NORM ĐÃ ĐƯỢC NGƯỜI DUYỆT, CHƯA CÓ CA KIỂM CỦA CHUYÊN GIA")
    w(">")
    w("> Từng norm được một người (xem mục 4) chấp nhận trên phiếu duyệt. Chưa có bộ ca kiểm thử của người học luật "
      "trả lời độc lập (FR12), nên báo cáo `reviewed` bị từ chối cho module này.")
    w("")
    if "consistent" in names and res and res.startswith("KẾT QUẢ: consistentOn"):
        w("**Nhất quán trên phần đã mã hóa** (định lý kernel `%s.consistent` và `%s.no_conflict`)." % (cfg["ns"], cfg["ns"]))
    elif "has_conflict" in names:
        w("**Tìm thấy xung đột hình thức** (định lý kernel `%s.has_conflict`)." % cfg["ns"])
    else:
        w("**Không biết**: module không có định lý kernel cho kết quả, hoặc kết quả chạy không khớp.")
    w("")
    if vac:
        w("**Cảnh báo rỗng:** không act nào mang hai modality khắc nhau, nên «nhất quán» ở đây đúng với **mọi** nội dung "
          "điều kiện. Nó chỉ nói: theo đúng chữ đã mã hóa, không có hai norm nào cùng một hành vi mà cấm / bắt buộc / "
          "cho phép trái nhau. Xem mục 5 cho phép kiểm qua quan hệ giữa các hành vi.")
        w("")
    w("Kết luận này **không** nói văn bản đúng hay không mâu thuẫn: nó chỉ nói về phần đã mã hóa (mục 2), và chỉ đúng nếu "
      "bản mã hóa trung thực với luật (mục 7).")
    w("")
    w("## 2. Phạm vi")
    w("")
    n_enc = sum(a["status"] == "đã mã hóa" for a in arts)
    n_out = sum(a["status"].startswith("ngoài phạm vi") for a in arts)
    n_other = len(arts) - n_enc - n_out
    w("| Trạng thái | Số điều |")
    w("|---|---|")
    w("| đã mã hóa (có norm hoặc khoản ghi «không mã hóa» kèm lý do) | %d |" % n_enc)
    w("| ngoài phạm vi mã hóa, người duyệt đồng ý (phiếu `%s`) | %d |" % (cfg["classification"], n_out))
    w("| khác (chưa xét, chưa duyệt, hoặc cần mã hóa) | %d |" % n_other)
    w("| **Cộng** | **%d** |" % len(arts))
    w("")
    w("«Ngoài phạm vi» **không** có nghĩa điều đó không có chuẩn mực; nó chỉ nghĩa là không có gì trong module đại diện cho nó.")
    w("")
    if gaps:
        w("**Đơn vị của điều đã mã hóa mà không có norm cũng không có lý do «không mã hóa» (%d):** %s. Đây là chỗ hở của "
          "phạm vi, không được coi là đã kiểm." % (len(gaps), ", ".join(gaps)))
    else:
        w("Mọi khoản, điểm của các điều đã mã hóa đều có norm hoặc có lý do «không mã hóa»: không có đơn vị nào bị bỏ qua im lặng.")
    w("")
    w("| Điều | Tên | Trạng thái | Norm | Mục «không mã hóa» |")
    w("|---|---|---|---|---|")
    for a in arts:
        w("| %d | %s | %s | %d | %d |" % (a["n"], a["title"].replace("|", "/"), a["status"], a["norms"], a["not_encoded"]))
    w("")
    w("Các khoản không mã hóa và lý do:")
    w("")
    for e in dump["not_encoded"]:
        w("- %s: %s" % (e["clause"], e["reason"].replace("\n", " ")))
    w("")
    w("## 3. Định lý kernel")
    w("")
    w("`lake build` %s%s. Các phát biểu dưới đây đọc từ mã nguồn; việc chúng đúng là do `lake build` vừa kiểm." % (
        "thành công" if info["ok"] else ("KHÔNG CHẠY (--no-build): các định lý dưới đây chưa được kiểm lại cho báo cáo này"
                                         if not info["ran"] else "THẤT BẠI"),
        (", audit axiom: %d khai báo, chỉ dùng propext, Classical.choice, Quot.sound" % info["audit"]) if info.get("audit") else ""))
    w("")
    for n, stmt in thms:
        w("- `%s`: `%s`" % (n, stmt[:300] + (" …" if len(stmt) > 300 else "")))
    w("")
    w("`covers_articles` và `covers_articles_source` nói danh sách norm của module gộp đúng bằng norm của các module từng "
      "điều (id, modality, act, nguồn, tham chiếu, số ngoại lệ). Chúng **không** so điều kiện.")
    w("")
    w("## 4. Duyệt")
    w("")
    hdr = src.split("Review sheets:", 1)[1].split("Assumptions accepted", 1)[0] if "Review sheets:" in src else ""
    for line in hdr.strip().splitlines():
        w(line.rstrip())
    w("")
    w("Một người duyệt cho toàn bộ. Công cụ chỉ kiểm phiếu đủ hàng và ghim đúng sha256; nó không kiểm danh tính, không kiểm "
      "câu trả lời.")
    w("")
    w("## 5. Kiểm qua quan hệ giữa các hành vi (cách đọc, tách riêng)")
    w("")
    L += edges_section(cfg)
    w("")
    w("## 6. Dấu hiệu lỗi soạn thảo (ADR-0030)")
    w("")
    L += drafting_section(cfg)
    w("")
    w("## 7. Điều KHÔNG được chứng minh")
    w("")
    for s in ("Độ trung thực của bản mã hóa với luật: chỉ có phiếu của một người duyệt; chưa có người học luật độc lập (FR12).",
              "`Atoms.valid` (tình huống nào được coi là không thể xảy ra) là giả định được tin, không được chứng minh.",
              "Các cạnh kéo theo ở mục 5: Lean chứng minh phép suy ra đúng **nếu** cạnh đúng (`derive_sound`, "
              "`conflict_derived_meaning`); cạnh đúng hay không là việc của người duyệt.",
              "Các văn bản khác (nghị định, luật khác) và thứ bậc hiệu lực: Level 2, chưa làm.",
              "Khái niệm mở («dành cho», «ngay trước», …) là tham số: hệ thống không quyết giá trị của chúng."):
        w("- " + s)
    w("")
    w("## 8. Đầu ra của Lean (`%s.report`)" % cfg["ns"])
    w("")
    w("```")
    L += dump["render"]
    w("```")
    w("")
    w("## 9. Nguồn gốc")
    w("")
    g = R.git_info()
    w("- Công cụ: %s; ngày tạo: %s" % (TOOL, today))
    w("- Module: `%s` (sha256, CRLF như LF: `%s`)" % (cfg["module_file"], R.sha_lf(cfg["module_file"])))
    w("- Văn bản đã tách: `%s` (sha256 `%s`)" % (cfg["segmented"], R.sha_lf(cfg["segmented"])))
    w("- Phiếu phân loại: `%s` (sha256 `%s`)" % (cfg["classification"], R.sha_lf(cfg["classification"])))
    w("- Lean: `%s`" % R.read_text("lean-toolchain").strip())
    if g:
        w("- Git: commit `%s`%s" % (g["commit"], ("; %d tệp đang sửa chưa commit" % g["dirty"]) if g["dirty"] else ""))
    w("")
    return "\n".join(L)


def make(cfg, status, do_build=True, today=None):
    if status == "reviewed":
        raise SystemExit("TỪ CHỐI `reviewed`: module %s chưa có bộ ca kiểm và phiếu ca (FR12). Chỉ tạo được `--status draft`."
                         % cfg["lean_module"])
    info = build(cfg, do_build)
    dump = lean_dump(cfg)
    return render(cfg, info, dump, today or datetime.date.today().isoformat())
