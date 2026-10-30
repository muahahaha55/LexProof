# -*- coding: utf-8 -*-
"""Builds docs/review/sale-group-review.md.

Inputs:  eval/sale-group/print_output.txt   (output of Print.lean = what the checker sees)
         data/extracted/44-2019-QH14.txt    (verbatim clause text, cut by line number)
         eval/sale-group/boundaries_output.txt
Nothing in the "Nguyên văn" column is written by hand: it is cut from the file by line range.
Run:  python build_sheet.py   (after: lake env lean --run eval/sale-group/Print.lean > print_output.txt)
"""
import os
import re

from common import *

OUT = os.path.join(ROOT, "docs", "review", "sale-group-review.md")
PRINT = io.open(os.path.join(HERE := os.path.dirname(os.path.abspath(__file__)), "print_output.txt"), encoding="utf-8").read().split("\n")
BOUND = io.open(os.path.join(HERE, "boundaries_output.txt"), encoding="utf-8").read().rstrip("\n")

# ---- measured (see report); wall-clock of `lake env lean LexProof/Laws/AlcoholSale.lean`, three runs
MEASURED = {"file_runs": "9,13 / 9,23 / 8,68 giây", "kernel_silent": "3,6 giây", "kernel_consistent": "7,5 giây"}


def section(title):
    i = PRINT.index("== " + title)
    j = i + 1
    while j < len(PRINT) and not PRINT[j].startswith("== "):
        j += 1
    return PRINT[i + 1:j]


def esc(s):
    return s.replace("|", "\\|")


# ---- what the checker sees
norm_lines = {}
cur = None
for l in section("NORM"):
    m = re.match(r"^\[([^\]]+)\]", l)
    if m:
        cur = m.group(1)
        norm_lines[cur] = []
    if cur and l.strip():
        norm_lines[cur].append(l.strip())

atom_lines = {}
cur = None
for l in section("BẢNG TÌNH HUỐNG") + section("BẢNG THAM SỐ"):
    if l.startswith("    ·"):
        atom_lines[cur].append(l.strip())
    elif l.strip():
        cur = l.split(" ")[0]
        atom_lines[cur] = [l.strip()]

not_enc = [tuple(x.strip() for x in l.split("‖", 1)) for l in section("CHƯA MÃ HÓA") if "‖" in l]
result_txt = "\n".join(section("KẾT QUẢ analyzeP"))
pts = [int(x) for x in re.findall(r'\("[^"]+", "[^"]+", (\d+)\)', result_txt)]
pairs_checked = int(re.search(r"pairsChecked := (\d+)", result_txt).group(1))
pairs_skipped = int(re.search(r"pairsSkipped := (\d+)", result_txt).group(1))
full_s = int(re.search(r"fullSituations := (\d+)", result_txt).group(1))
full_p = int(re.search(r"fullParams := (\d+)", result_txt).group(1))
assert len(pts) == pairs_checked, (len(pts), pairs_checked)
assert "consistentOn" in result_txt and "constraintsUsed := false" in result_txt

# ---- per-clause information written by the drafter (not by the checker)
INFO = {
    "D5H": dict(norms=[], atoms=[], defaults="G1: modality «cấm» truyền từ tiêu đề xuống từng khoản",
                conf="trung bình", why="Tiêu đề là nguồn duy nhất của loại «cấm» ở Điều 5 (slice1-notes: «cấm qua tiêu đề»)."),
    "5.3": dict(norms=["5.3-ban", "5.3-cung-cap", "5.3-khuyen-mai"], atoms=["S04"],
                defaults="G1 (cấm qua tiêu đề; «cho người chưa đủ 18 tuổi» gắn cả ba động từ); G7 (ba act riêng)",
                conf="trung bình",
                why="Ba động từ tách thành ba act (G7) nên không so với nhau; «cung cấp» có thể bao «bán». Dải tuổi trên là phần bù tôi thêm. «cho người chưa đủ 18 tuổi» gắn cả ba động từ là cách đọc tự nhiên nhưng chữ không khóa."),
    "5.9": dict(norms=["5.9-i", "5.9-ii"], atoms=["S02"],
                defaults="G1 (cấm qua tiêu đề); G7 (tách khuyến mại sản phẩm và dùng làm quà; «trong hoạt động kinh doanh rượu, bia» gộp vào act, không có atom)",
                conf="thấp",
                why="Hai nhánh chung một khoản; «trong hoạt động kinh doanh» và «dưới mọi hình thức» không được biểu diễn; ranh giới 15 chỉ đối chiếu được với tiêu đề Điều 11 (ngoài lát cắt)."),
    "5.11": dict(norms=["5.11-ii"], atoms=[],
                 defaults="G1; G7 (act riêng «bán bằng máy», điều kiện luôn đúng); G12 (nhánh (i) để mô-đun cấp phép)",
                 conf="trung bình",
                 why="Chỉ nhánh (ii) được mã hóa. Vì act riêng nên 5.11(ii) không bao giờ được so với Điều 19. Điều kiện «luôn đúng» do act đã mang nội dung."),
    "D19H": dict(norms=[], atoms=[], defaults="G1: modality «cấm» và act «bán» truyền xuống khoản 1 đến 6",
                 conf="trung bình", why="Tiêu đề chỉ nói «bán»; không nói «cung cấp» hay «khuyến mại» (khác Điều 5 khoản 3)."),
    "19.1": dict(norms=["19.1"], atoms=["S14"], defaults="G1; G7 (act ban_ruou_bia)", conf="trung bình",
                 why="«cơ sở y tế» không được định nghĩa (căng-tin trong bệnh viện?)."),
    "19.2": dict(norms=["19.2"], atoms=["S15"], defaults="G1; G7", conf="trung bình",
                 why="Không có khung thời gian, mã hóa đúng chữ (Điều 10 khoản 2 có «trong thời gian giảng dạy, học tập, làm việc»)."),
    "19.3": dict(norms=["19.3"], atoms=["S16", "P14"], defaults="G1; G7; ngoài mặc định: «dành cho» làm tham số P14 (khái niệm mở)",
                 conf="thấp",
                 why="Tôi tách «cơ sở/khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí» (S16) khỏi «dành cho người chưa đủ 18 tuổi» (P14, tham số) — khác từ vựng B1, nơi S16 là một Bool gộp."),
    "19.4": dict(norms=["19.4"], atoms=["S17"], defaults="G1; G7", conf="trung bình",
                 why="Danh sách nối bằng «và» được đọc là hoặc; «cơ sở giam giữ khác» là khe mở."),
    "19.5": dict(norms=["19.5"], atoms=["S18"], defaults="G1; G7", conf="cao", why="Không phát hiện đa nghĩa trong slice1-notes."),
    "19.6": dict(norms=["19.6"], atoms=["S19", "S20"], defaults="G1; G4 (ngoại lệ, không phải cho phép); G7",
                 conf="thấp",
                 why="«trừ địa điểm được phép kinh doanh» mã hóa thành ngoại lệ S20; S20 phụ thuộc chế độ cấp phép (Điều 15) và có thể trùng 5.11(i). Khác Điều 10 khoản 6, không có «trong thời gian làm việc»."),
}

ACT_NOTES = {
    "ban_ruou_bia": "bán rượu, bia",
    "cung_cap_ruou_bia": "cung cấp rượu, bia",
    "khuyen_mai_ruou_bia": "khuyến mại rượu, bia",
    "dung_ruou_bia_lam_qua_khuyen_mai": "dùng rượu, bia làm phương tiện khuyến mại",
    "ban_ruou_bia_bang_may_tu_dong": "bán rượu, bia bằng máy bán hàng tự động",
}


def quote(a, b):
    t = text(a, b)
    assert "|" not in t
    where = "dòng %d" % a if a == b else "dòng %d–%d" % (a, b)
    return "«%s»<br>(%s)" % (t, where)


def cell_lines(lines):
    return "<br>".join(esc(l) for l in lines)


REVIEW_COLS = "☐ Đúng<br>☐ Sai<br>☐ Không chắc"

L = []
A = L.append
A("# Phiếu duyệt — nhóm «bán / cung cấp / khuyến mại rượu, bia» (Luật 44/2019/QH14)")
A("")
A("> ## ⚠ BẢN NHÁP DO AI SOẠN — CHƯA AI DUYỆT")
A(">")
A("> Phiếu này và mô-đun `LexProof/Laws/AlcoholSale.lean` là **bản nháp**. Không điều nào ở đây được coi là đã duyệt, đã đối chiếu với luật, hay là cách đọc đúng. Máy chỉ kiểm được **tính nhất quán của phần đã mã hóa**; việc bản mã hóa có **khớp luật** hay không chỉ người duyệt trả lời được. Các mặc định G1, G4, G7, G12 dưới đây là **tạm dùng**, chưa ai quyết định.")
A("")
A("## Cách dùng (đọc trước khi nhìn bản mã hóa)")
A("")
A("1. Với **mỗi khoản**, đọc cột «Nguyên văn» trước và **tự quyết định cách đọc của mình**: khoản này là cấm, nghĩa vụ hay cho phép; có ngoại lệ không; ranh giới ngưỡng (từ/dưới) nằm ở đâu; «và»/«hoặc» nối gì.")
A("2. **Sau đó** mới đọc cột «Checker thấy». Đó là đầu ra của một bộ in tất định (`LexProof/Core/Render.lean`) từ chính dữ liệu Lean: act, loại, điều kiện, ngoại lệ, tên atom, nhãn dải, khoản nguồn của từng dải. Không có LLM, không diễn giải.")
A("3. Đánh dấu **Đúng / Sai / Không chắc**, ghi chú, tên người duyệt và ngày vào các cột trống. Nếu «Không chắc» hoặc «Sai», ghi cách đọc của bạn.")
A("4. Cột «Độ tin cậy» là cảm nhận của người soạn, **không phải** bằng chứng.")
A("")
A("Nguyên văn được cắt tự động theo số dòng từ `data/extracted/44-2019-QH14.txt` (bản trích từ PDF, xem `data/README.md`; không phải nguồn chính thức); script `eval/sale-group/check_sheet.py` đối chiếu lại cột này với file.")
A("")
A("## 1. Nhóm và các mặc định tạm dùng")
A("")
A("**Nhóm** (mục C của `docs/slice1-notes.md`, theo act, không theo độ dễ): `ban_ruou_bia`, `cung_cap_ruou_bia`, `khuyen_mai_ruou_bia`, `dung_ruou_bia_lam_qua_khuyen_mai`, `ban_ruou_bia_bang_may_tu_dong` — Điều 5 khoản 3, 9, 11 (nhánh ii) và Điều 19 khoản 1 đến 6.")
A("")
A("| Mặc định tạm | Nội dung |")
A("|---|---|")
A("| G1 (bảo thủ) | điều kiện/loại của tiêu đề áp dụng cho mọi khoản dưới nó |")
A("| G4 | «trừ …» là **ngoại lệ**, không phải cho phép |")
A("| G7 (mịn) | mỗi hành vi pháp lý một act; yêu cầu hình thức không chung act với lệnh cấm |")
A("| G12 | một mô-đun `Laws` cho mỗi nhóm act |")
A("")
A("## 2. Từng khoản")
A("")
A("| id | Nguyên văn (`data/extracted/44-2019-QH14.txt`) | Checker thấy (bộ in tất định) | Mặc định đã dùng | Độ tin cậy (của người soạn) | Đúng / Sai / Không chắc | Ghi chú của người duyệt | Người duyệt | Ngày |")
A("|---|---|---|---|---|---|---|---|---|")
for key, label, a, b in ENCODED:
    info = INFO[key]
    if info["norms"]:
        parts = []
        for nid in info["norms"]:
            parts.append(cell_lines(norm_lines[nid]))
        see = "<br><br>".join(parts)
        atoms = []
        for pre in info["atoms"]:
            atoms.append(cell_lines(atom_lines[pre]))
        if atoms:
            see += "<br><br>Atom và dải mà norm đọc:<br>" + "<br>".join(atoms)
    else:
        see = "Không có norm riêng: nội dung được truyền xuống từng khoản (xem mục 6)."
    if key == "5.11":
        see += "<br><br>Nhánh (i) «Kinh doanh rượu không có giấy phép hoặc không đăng ký» **không** được mã hóa (xem mục 5)."
    idcell = "%s<br>(norm: %s)" % (label, ", ".join(info["norms"])) if info["norms"] else label
    A("| %s | %s | %s | %s | %s: %s | %s | | | |" % (idcell, quote(a, b), see, esc(info["defaults"]), info["conf"], esc(info["why"]), REVIEW_COLS))
A("")
A("## 3. Dải ngưỡng: các ranh giới có khớp không?")
A("")
A("Bộ kiểm **không phát hiện** khe hở hay chồng lấn giữa các dải: với nó một dải chỉ là nhãn. Phép kiểm dưới đây chạy **ngoài Lean** (`eval/sale-group/boundaries.py`); các khoảng số do người soạn khai tay từ khoản quy định từng đầu mút.")
A("")
A("```")
A(BOUND)
A("```")
A("")
A("Đọc kết quả: các dải **khớp nhau chính xác** (một đầu đóng, một đầu mở), không hở, không chồng. Nhưng: (a) ranh giới **15** được hai khoản độc lập cùng xác nhận (Điều 11 tiêu đề «dưới 15 độ» ở dòng 206, Điều 5 khoản 9 «từ 15 độ trở lên» ở dòng 103); (b) ranh giới **18** chỉ có **một** khoản (cạnh «chưa đủ 18 tuổi»), dải «từ đủ 18 tuổi trở lên» là **phần bù do người soạn thêm**, không khoản nào nêu; (c) cận trên 100 của độ cồn là giới hạn vật lý, **luật không nêu**; (d) «độ» được hiểu là phần trăm thể tích theo Điều 2 khoản 4 — Điều 2 không nói rõ 1 độ = 1% thể tích (slice1-notes, Điều 2 khoản 4).")
A("")
A("## 4. Bảng act")
A("")
A("| Act | Hành vi | Norm | Khoản |")
A("|---|---|---|---|")
acts = {}
for nid, lines in norm_lines.items():
    act = re.search(r"act = (\S+)", lines[0]).group(1)
    art = re.search(r"nguồn = [^,]+, (.+)$", lines[0]).group(1)
    acts.setdefault(act, []).append((nid, art))
for act, items in acts.items():
    A("| `%s` | %s | %s | %s |" % (act, ACT_NOTES[act], ", ".join(i for i, _ in items), "; ".join(sorted({a for _, a in items}))))
A("")
A("Chỉ các norm **cùng act** được so với nhau: `ban_ruou_bia` có 7 norm (21 cặp), `khuyen_mai_ruou_bia` có 2 (1 cặp), ba act còn lại mỗi act một norm.")
A("")
A("## 5. Điều khoản của nhóm hoặc sát nhóm **không** được mã hóa")
A("")
A("| Điều khoản | Nguyên văn (dòng) | Lý do không mã hóa |")
A("|---|---|---|")
keymap = {"Điều 5 tiêu đề": ["D5H"], "Điều 19 tiêu đề": ["D19H"], "Điều 5 khoản 11 nhánh (i)": ["5.11"],
          "Điều 2 khoản 1, 2, 4": ["2.1", "2.2", "2.4"], "Điều 11": ["11"], "Điều 15 khoản 4": ["15.4"],
          "Điều 16": ["16"], "Điều 32 khoản 3, 5, 7": ["32.3", "32.5", "32.7"]}
allrows = {k: (a, b) for k, _, a, b in ENCODED + NOT_ENCODED}
for clause_label, reason in not_enc:
    cells = []
    for k in keymap[clause_label]:
        a, b = allrows[k]
        if k == "5.11":
            full = text(a, b)
            part = full.split(";")[0]
            assert part in full
            cells.append("«%s»<br>(dòng %d–%d, phần trước dấu chấm phẩy)" % (part, a, b))
        elif k in ("D5H", "D19H"):
            cells.append("xem mục 2")
        else:
            cells.append(quote(a, b))
    A("| %s | %s | %s |" % (clause_label, "<br><br>".join(cells), esc(reason)))
A("")
A("Các điều ngoài lát cắt 1 (11, 15, 16, 32) **chưa được phân tích** trong `slice1-notes.md`; việc liệt kê ở đây chỉ để không bỏ im lặng, không phải đánh giá nội dung.")
A("")
A("## 6. Những chỗ đã dựa vào mặc định tạm")
A("")
A("| Mặc định | Dùng ở đâu | Nếu người duyệt chọn khác |")
A("|---|---|---|")
A("| G1 bảo thủ | Điều 5 tiêu đề → loại «cấm» của 5.3, 5.9, 5.11(ii); Điều 19 tiêu đề → loại «cấm» và act «bán» của 19.1 đến 19.6; «cho người chưa đủ 18 tuổi» gắn cả ba động từ ở 5.3 | Nếu tiêu đề chỉ là nhãn, các khoản 19.1 đến 19.6 (chỉ ghi địa điểm) không có động từ nên phải mã hóa lại; nếu «cho người chưa đủ 18 tuổi» chỉ gắn «khuyến mại», 5.3 đổi thành hai norm không điều kiện tuổi |")
A("| G4 | 19.6 «trừ địa điểm được phép kinh doanh rượu, bia» → ngoại lệ S20 | Nếu là cho phép: thêm một norm «cho phép bán» (S19 và S20) cùng act `ban_ruou_bia`; nó sẽ xung đột về modality với 19.1 đến 19.5 ở mọi điểm hai điều kiện cùng đúng (kiểu cặp «chéo» ở scaling-analysis 3.2) |")
A("| G7 mịn | 5.3 ba act; 5.9 hai act; 5.11(ii) act «bán bằng máy» riêng | Nếu gộp «bán/cung cấp/khuyến mại» thành một act, số cặp được so tăng; vì mọi norm đều là cấm nên vẫn không có xung đột modality |")
A("| G12 | một mô-đun cho nhóm này; 5.11(i) (cấp phép) để mô-đun khác; bảng atom riêng | Nếu một mô-đun chung, bảng lớn hơn nhưng kiểm theo cặp chỉ duyệt atom mà từng cặp đọc |")
A("")
A("## 7. Chỗ lệch khỏi từ vựng B1/B2 của `slice1-notes.md` và các giả định khác của người soạn")
A("")
A("- **S04** (người nhận chưa đủ 18 tuổi): B1 là Bool; ở đây là enum hai dải để mỗi dải mang khoản nguồn và để kiểm ranh giới.")
A("- **S02** (độ cồn): B1 có ba dải (dưới 5,5 · 5,5 đến dưới 15 · từ 15); ở đây chỉ hai dải (dưới 15 · từ 15) vì nhóm này không dùng ranh giới 5,5.")
A("- **S16** và **P14**: B1 có S16 là một Bool «cơ sở/khu vực dành cho người chưa đủ 18 tuổi»; ở đây tách thành S16 (loại cơ sở) và tham số mở P14 («dành cho»), theo nguyên tắc khái niệm mở là tham số. P14 là id **mới**.")
A("- **S01** (rượu/bia) không dùng: 5.9 và 5.11(ii) áp dụng cho cả rượu lẫn bia.")
A("- «trong hoạt động kinh doanh rượu, bia» (5.9) và «dưới mọi hình thức» (5.9 nhánh ii) **không** có atom.")
A("- 19.6 không có điều kiện «trong thời gian làm việc» vì chữ của khoản không có (khác 10.6).")
A("- Danh sách «và» ở 19.4 được đọc là hoặc (các loại cơ sở).")
A("- `effective` của mọi norm đặt 2020-01-01 theo Điều 36 khoản 1 (dòng 642); Core không kiểm ngày.")
A("")
A("## 8. Kết quả `analyzeP` và ý nghĩa của nó")
A("")
A("`analyzeP` trả **`consistentOn`** (kernel chứng minh: `decide +kernel`, định lý `consistent` và `silent` trong mô-đun). Không có finding nào của `validate`, bảng hay bộ đọc.")
A("")
A("| Mục | Giá trị |")
A("|---|---|")
A("| Số norm | 12 |")
A("| Số cặp không thứ tự | %d |" % (pairs_checked + pairs_skipped))
A("| Cặp đã kiểm (cùng act) | %d |" % pairs_checked)
A("| Cặp bỏ qua (khác act) | %d |" % pairs_skipped)
A("| Điểm duyệt mỗi cặp | từ %d đến %d; tổng %d |" % (min(pts), max(pts), sum(pts)))
A("| Miền đầy đủ (tích, không liệt kê) | %d tình huống × %d tham số |" % (full_s, full_p))
A("| Dùng ràng buộc toàn vẹn | **không** (`constraintsUsed = false`) |")
A("| Thời gian | tệp mô-đun chạy `lake env lean`: %s (ba lượt, gồm nạp thư viện ≈ 0,7 giây); kernel: `silent` %s, `consistent` %s |" % (MEASURED["file_runs"], MEASURED["kernel_silent"], MEASURED["kernel_consistent"]))
A("")
A("**Điều kết quả này KHÔNG cho biết.** Mọi norm trong nhóm là *cấm*; hai lệnh cấm không có cặp modality khắc nhau, nên `consistentOn` ở đây **đúng với mọi nội dung điều kiện**: nó sẽ y hệt nếu điều kiện của mọi khoản bị thay bằng điều kiện khác. Nó không nói gì về việc bản mã hóa có khớp luật; không phát hiện khe hở/chồng lấn giữa các dải (mục 3); không biết 5.11(ii) và Điều 19 cùng nói về «bán» (G7 mịn tách act); và có thể che xung đột thật ở những khoản chưa mã hóa (mục 5).")
A("")
A("## 9. Tái lập")
A("")
A("```")
A("python eval/sale-group/check_sources.py          # danh mục Điều 1..36, các khoản, cụm từ")
A("python eval/sale-group/boundaries.py             # ranh giới các dải")
A("lake env lean --run eval/sale-group/Print.lean > eval/sale-group/print_output.txt")
A("python eval/sale-group/build_sheet.py            # sinh lại phiếu này")
A("python eval/sale-group/check_sheet.py            # đối chiếu cột «Nguyên văn» với file trích xuất")
A("```")
A("")

os.makedirs(os.path.dirname(OUT), exist_ok=True)
io.open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(L))
print("wrote", OUT, len(L), "lines")
