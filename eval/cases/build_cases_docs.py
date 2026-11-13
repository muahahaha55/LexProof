# -*- coding: utf-8 -*-
"""Builds the two review files from eval/cases/cases_draft.py, run_output.txt (made by Print.lean against the
encoding) and data/extracted/44-2019-QH14.txt:
  docs/review/sale-group-cases.md      for the human; NO expectation and NO encoding answer anywhere
  docs/review/sale-group-cases-key.md  the answers, results, coverage
"""
import os
import re
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "sale-group"))
sys.path.insert(0, HERE)
from common import *            # noqa
from cases_draft import CASES   # noqa

OUT_DIR = os.path.join(ROOT, "docs", "review")
KEYR = {k: (lab, a, b) for k, lab, a, b in ENCODED}
ACTTXT = {"ban_ruou_bia": "bán rượu, bia", "cung_cap_ruou_bia": "cung cấp rượu, bia",
          "khuyen_mai_ruou_bia": "khuyến mại rượu, bia", "dung_ruou_bia_lam_qua_khuyen_mai": "dùng rượu, bia làm phương tiện khuyến mại",
          "ban_ruou_bia_bang_may_tu_dong": "bán rượu, bia bằng máy bán hàng tự động",
          "kinh_doanh_ruou_khong_phep_hoac_dang_ky": "kinh doanh rượu không có giấy phép hoặc không đăng ký"}
# clauses of the module whose norms share the tested act (what a reader needs to look at) - structure only, no answer
READ = {"ban_ruou_bia": ["5.3", "D19H", "19.1", "19.2", "19.3", "19.4", "19.5", "19.6"],
        "cung_cap_ruou_bia": ["5.3"], "khuyen_mai_ruou_bia": ["5.3", "5.9"], "dung_ruou_bia_lam_qua_khuyen_mai": ["5.9"],
        "ban_ruou_bia_bang_may_tu_dong": ["5.11"], "kinh_doanh_ruou_khong_phep_hoac_dang_ky": ["5.11"]}
LABEL = {k: v[0] for k, v in KEYR.items()}


def quote(k):
    lab, a, b = KEYR[k]
    t = text(a, b)
    assert "|" not in t
    return "«%s»<br>(dòng %s)" % (t, ("%d" % a) if a == b else "%d–%d" % (a, b))


def esc(s):
    return s.replace("|", "\\|")


# ---------------------------------------------------------------- run results
res, applying, norm_act = {}, {}, {}
for line in open(os.path.join(HERE, "run_output.txt"), encoding="utf-8").read().split("\n"):
    m = re.match(r"^R\t(C\d+) \| (.+?) \| norm áp dụng: ?(.*)$", line)
    if m:
        cid, out, ap = m.groups()
        applying[cid] = [x.strip() for x in ap.split(",") if x.strip()]
        if out == "PASS": res[cid] = ("PASS", None)
        elif out.startswith("FAIL"):
            res[cid] = ("FAIL", re.search(r"cho (\w+)", out).group(1))
        else: res[cid] = (out.split(" ")[0], out)
for line in open(os.path.join(ROOT, "eval", "sale-group", "print_output.txt"), encoding="utf-8").read().split("\n"):
    m = re.match(r"^\[([^\]]+)\] act = (\S+)", line)
    if m: norm_act[m.group(1)] = m.group(2)
assert set(res) == {c["id"] for c in CASES}, "run_output.txt is stale"
got = {cid: (c["expected"] if r[0] == "PASS" else r[1]) for c in CASES for cid, r in [(c["id"], res[c["id"]])]}

# ================================================================= (a) sheet for the human
L = []
A = L.append
A("# Phiếu ca thử — nhóm «bán / cung cấp / khuyến mại rượu, bia» (Luật 44/2019/QH14)")
A("")
A("> ## ⚠ BẢN NHÁP — CHƯA AI DUYỆT")
A(">")
A("> Các tình huống dưới đây do AI soạn từ chữ của khoản luật. Chúng dùng để đo xem bản mã hóa có **khớp cách đọc của bạn** hay không; chúng **không** phải ví dụ đã được duyệt, và không có câu trả lời nào được coi là đúng trước khi bạn trả lời.")
A("")
A("## Cách làm (đọc kỹ)")
A("")
A("1. **Trả lời trước, chỉ dựa vào khoản được trích.** Đọc tình huống và khoản luật, rồi ghi câu trả lời của bạn ở cột «Câu trả lời của bạn» **trước khi** nhìn bất kỳ nơi nào khác (kể cả `docs/review/sale-group-cases-key.md` và `docs/review/sale-group-review.md`).")
A("2. Các lựa chọn: **cấm** · **bắt buộc** · **được phép** · **không biết**. «Không biết» là câu trả lời hợp lệ và hữu ích: nó cho thấy khoản trích chưa đủ để quyết.")
A("3. Nếu theo khoản trích hành vi này **không** bị cấm, không bị bắt buộc và cũng không được cho phép một cách rõ ràng (khoản không điều chỉnh nó), hãy ghi «**khoản này không điều chỉnh**». Đừng ghi «được phép» chỉ vì không thấy lệnh cấm: luật khác có thể cấm.")
A("4. Cột «Đúng ý / Sai ý» hỏi về **chính ca thử**: tình huống và câu hỏi có nêu đúng điều khoản muốn kiểm không (Đúng ý), hay đặt câu hỏi sai, mơ hồ, thiếu dữ kiện (Sai ý). Ghi lý do ở «Ghi chú».")
A("5. Điền «Người duyệt» và «Ngày». Tệp này không ghi sẵn câu trả lời nào.")
A("6. Sau khi điền xong mọi hàng, ghi ở mục 3 cuối phiếu mã sha256 của tệp mô-đun bạn đã đối chiếu. `pipeline/report.py --status reviewed` từ chối nếu mã này khác tệp mô-đun hiện tại (xem `docs/conventions.md`).")
A("")
A("Nguyên văn được cắt tự động theo số dòng từ `data/extracted/44-2019-QH14.txt` (bản trích từ PDF, không phải nguồn chính thức) và `eval/cases/check_cases_sheet.py` đối chiếu lại với file.")
A("")
A("## 1. Các ca")
A("")
A("| Mã | Tình huống | Câu hỏi | Khoản chính (nguyên văn) | Khoản cần xét thêm | Đúng ý / Sai ý | Câu trả lời của bạn | Ghi chú | Người duyệt | Ngày |")
A("|---|---|---|---|---|---|---|---|---|---|")
for c in CASES:
    rd = [LABEL[k] for k in READ[c["act"]] if k != c["clause"]]
    more = "; ".join(rd) if rd else "—"
    q = "Theo các khoản đã trích, hành vi «%s» trong tình huống này có bị **cấm** / **bắt buộc** / **được phép** không?" % ACTTXT[c["act"]]
    A("| %s | %s | %s | %s | %s | ☐ Đúng ý<br>☐ Sai ý | ☐ cấm<br>☐ bắt buộc<br>☐ được phép<br>☐ không biết<br>☐ khoản này không điều chỉnh | | | |" % (
        c["id"], esc(c["description"]), esc(q), quote(c["clause"]), esc(more)))
A("")
A("## 2. Nguyên văn các khoản cần xét thêm")
A("")
A("| Khoản | Nguyên văn |")
A("|---|---|")
for k in ["5.3", "5.9", "5.11", "D19H", "19.1", "19.2", "19.3", "19.4", "19.5", "19.6"]:
    A("| %s | %s |" % (LABEL[k], quote(k)))
A("")
A("## 3. Xác nhận mô-đun đã duyệt")
A("")
A("Điền sau khi trả lời xong mọi hàng ở mục 1. Hai mã là sha256 của `LexProof/Laws/AlcoholSale.lean` và của `LexProof/Laws/AlcoholSaleCases.lean` (các ca đang được duyệt), khi đọc CRLF như LF; `python pipeline/report.py --print-sheet-hashes` in cả hai dòng. Để trống thì báo cáo `reviewed` bị từ chối.")
A("")
A("sha256 mô-đun khi duyệt: ")
A("")
A("sha256 tệp ca thử khi duyệt: ")
A("")
os.makedirs(OUT_DIR, exist_ok=True)
io.open(os.path.join(OUT_DIR, "sale-group-cases.md"), "w", encoding="utf-8", newline="\n").write("\n".join(L))

# ================================================================= (b) key
STAT = {"forbidden": "bị cấm", "required": "bắt buộc", "explicitlyPermitted": "được phép rõ ràng", "clash": "xung đột",
        "noNormApplies": "không norm nào của mô-đun áp dụng (KHÔNG có nghĩa là hợp pháp)"}
K = []
B = K.append
B("# Đáp án và độ phủ — ca thử nhóm «bán / cung cấp / khuyến mại rượu, bia» (BẢN NHÁP)")
B("")
B("> ## ⚠ ĐÂY LÀ ĐÁP ÁN: KHÔNG ĐỌC TRƯỚC KHI TRẢ LỜI `sale-group-cases.md`")
B(">")
B("> Mọi thứ ở đây là bản nháp chưa ai duyệt. «Kỳ vọng» là cách đọc của người soạn từ chữ của khoản; «mã hóa cho» là kết quả của bản mã hóa nháp (`LexProof/Laws/AlcoholSale.lean`). **Hai thứ này cùng một tác giả**: ca đạt chỉ cho thấy mã hóa khớp người soạn, chưa cho thấy nó khớp luật.")
B("")
B("Danh sách ca được ghi trước khi chạy (`eval/cases/RECORD.md`, sha256 của `cases_draft.py`); kỳ vọng không sửa sau khi chạy. Trạng thái mọi ca: `draft`.")
B("")
n_pass = sum(1 for r in res.values() if r[0] == "PASS")
B("**Kết quả: %d ca, %d đạt, %d không đạt.** Kernel kiểm đúng tập ca đạt (`pass_set`, `decide +kernel`); ca không đạt được liệt kê lúc chạy (`notPassingNow`)." % (len(CASES), n_pass, len(CASES) - n_pass))
B("")
B("## 1. Từng ca")
B("")
B("| Mã | Loại | Act thử | Kỳ vọng (người soạn) | Mã hóa cho | Kết quả | Norm áp dụng | Độ tin cậy | Khoản |")
B("|---|---|---|---|---|---|---|---|---|")
KIND = {"positive": "dương", "negativeControl": "đối chứng âm", "boundary": "ranh giới", "exception": "ngoại lệ"}
for c in CASES:
    r = res[c["id"]]
    B("| %s | %s%s | `%s` | %s | %s | %s | %s | %s | %s |" % (
        c["id"], KIND[c["kind"]], " (gần giống)" if c["near_miss"] else "", c["act"], c["expected"], got[c["id"]],
        "**ĐẠT**" if r[0] == "PASS" else "**KHÔNG ĐẠT**", ", ".join(applying[c["id"]]) or "—", c["confidence"], LABEL[c["clause"]]))
B("")
B("### Ghi chú và lý do của các ca «gần giống» và ca độ tin cậy thấp")
B("")
for c in CASES:
    if c["note"]:
        B("* **%s** (%s, độ tin cậy %s): %s" % (c["id"], KIND[c["kind"]], c["confidence"], c["note"]))
B("")
B("## 2. Ca không đạt")
B("")
fails = [c for c in CASES if res[c["id"]][0] != "PASS"]
for c in fails:
    B("* **%s** — kỳ vọng `%s`, mã hóa cho `%s`. **Chẩn đoán: lỗ hổng phủ của mã hóa, không phải lỗi mã hóa hay lỗi ca.** Nhánh (i) của Điều 5 khoản 11 thuộc nhóm act `kinh_doanh_ruou_khong_phep_hoac_dang_ky`, không nằm trong mô-đun; không có norm nào cho act này nên kết quả là «không norm nào áp dụng», mà **không** có nghĩa là hợp pháp. Tôi đã dự báo ca này sẽ không đạt trước khi chạy (ghi trong ghi chú của ca)." % (c["id"], c["expected"], got[c["id"]]))
B("")
B("## 3. Độ phủ")
B("")
B("### 3.1 Số ca theo loại")
B("")
kc = Counter(c["kind"] for c in CASES)
B("| Loại | Số ca |")
B("|---|---|")
for k in ("positive", "negativeControl", "boundary", "exception"):
    B("| %s | %d |" % (KIND[k], kc[k]))
B("| trong đó «gần giống» (luật *không* cấm điều trông gần giống) | %d |" % sum(1 for c in CASES if c["near_miss"]))
B("| độ tin cậy thấp | %d |" % sum(1 for c in CASES if c["confidence"] == "low"))
B("")
B("### 3.2 Số ca theo norm (từ kết quả chạy)")
B("")
B("«Dương» = norm áp dụng trong ca; «âm» = ca thử đúng act của norm mà norm **không** áp dụng.")
B("")
B("| Norm | Act | Dương | Âm | Ghi chú |")
B("|---|---|---|---|---|")
for n, act in norm_act.items():
    pos = [c["id"] for c in CASES if n in applying[c["id"]]]
    neg = [c["id"] for c in CASES if c["act"] == act and n not in applying[c["id"]]]
    note = ""
    if n == "5.11-ii" and not neg:
        note = "**thiếu đối chứng âm đúng nghĩa**: điều kiện luôn đúng, phương thức bán nằm trong tên act; C23 (act khác) chỉ là phép thử yếu"
    B("| %s | `%s` | %d (%s) | %d (%s) | %s |" % (n, act, len(pos), ", ".join(pos) or "—", len(neg), ", ".join(neg) or "—", note))
B("")
B("### 3.3 Cặp ranh giới")
B("")
B("| Nhóm ngưỡng | Act | Phía «ngoài ranh giới» | Phía «trong» | Có đủ hai phía? |")
B("|---|---|---|---|---|")


def side(act, atom, val):
    # the other threshold atom (if the act reads both) is held at the value that does not trigger its own norm
    hold = {"S04": ("S02", "dưới 15 độ"), "S02": ("S04", "từ đủ 18 tuổi trở lên")}[atom]
    return [c["id"] for c in CASES if c["kind"] == "boundary" and c["act"] == act and c["situation"].get(atom) == val
            and c["situation"].get(hold[0], hold[1]) == hold[1]]


pairs = [("tuổi 18 (chưa đủ / đủ)", "S04", "ban_ruou_bia"), ("tuổi 18", "S04", "cung_cap_ruou_bia"), ("tuổi 18", "S04", "khuyen_mai_ruou_bia"),
         ("độ cồn 15 (dưới / từ)", "S02", "khuyen_mai_ruou_bia"), ("độ cồn 15", "S02", "dung_ruou_bia_lam_qua_khuyen_mai")]
for nm, atom, act in pairs:
    lo, hi = (("chưa đủ 18 tuổi", "từ đủ 18 tuổi trở lên") if atom == "S04" else ("từ 15 độ trở lên", "dưới 15 độ"))
    a, b = side(act, atom, lo), side(act, atom, hi)
    B("| %s | `%s` | %s | %s | %s |" % (nm, act, ", ".join(a) or "—", ", ".join(b) or "—", "có" if a and b else "**THIẾU**"))
B("")
B("Ghi chú: các ca ranh giới mô tả giá trị (ví dụ «đúng 15 độ», «14,9 độ», «17 tuổi 11 tháng», «đúng 18 tuổi») nhưng bộ kiểm chỉ thấy **nhãn dải**; nó không phân biệt 14,9 với 10. Ca ranh giới chỉ kiểm việc dải có được gắn nhãn đúng phía ranh giới, không kiểm số.")
B("")
B("### 3.4 Ngoại lệ")
B("")
exc = [c for c in CASES if c["kind"] == "exception"]
B("| Ngoại lệ | Ca khi ngoại lệ đúng | Ca khi ngoại lệ không đúng |")
B("|---|---|---|")
B("| 19.6 «trừ địa điểm được phép kinh doanh rượu, bia» | %s | %s |" % (
    ", ".join(c["id"] for c in exc if c["situation"].get("S20") == "đúng"), ", ".join(c["id"] for c in exc if c["situation"].get("S20") == "sai")))
B("")
B("### 3.5 Ca có độ tin cậy thấp")
B("")
for c in CASES:
    if c["confidence"] == "low":
        B("* **%s**: %s — %s" % (c["id"], c["description"], c["note"]))
B("")
B("### 3.6 Khoảng trống độ phủ (nói thẳng)")
B("")
B("* **Chỉ hai trạng thái được thử**: `forbidden` và `noNormApplies`. Mô-đun chỉ có lệnh cấm, nên `required`, `explicitlyPermitted` và `clash` không có ca nào ở mô-đun này (đã thử với mô-đun đồ chơi trong `Verify/Cases.lean`).")
B("* **Không có ca nào cho nhánh (i) của Điều 5 khoản 11** ngoài C24 (không đạt, đã biết).")
B("* **Điều 11, 15, 16, 32** không có ca nào: ngoài lát cắt, chưa phân tích.")
B("* **Ranh giới chỉ là nhãn dải** (xem mục 3.3). Các ca không phát hiện sai số ở chỗ cắt dải.")
B("* **Ca và mã hóa cùng một nguồn**: việc 36/37 ca đạt không phải bằng chứng khớp luật; chỉ người duyệt (`sale-group-cases.md`) trả lời được điều đó.")
B("")
io.open(os.path.join(OUT_DIR, "sale-group-cases-key.md"), "w", encoding="utf-8", newline="\n").write("\n".join(K))
print("written", len(CASES), "cases; pass", n_pass)
