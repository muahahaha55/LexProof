# Kết quả thí nghiệm đột biến

Thiết kế, toán tử, kỳ vọng, chỉ số, seed (`20261031`) và ngày (2026-10-31) đã chốt trước ở
[mutation-experiment.md](mutation-experiment.md) và **không được sửa**. Tệp này chỉ ghi kết quả. Mã và số đo thô: `eval/mutation/`
(`mutants.csv`, `results.csv`, `disagreements.txt`, `summary.json`).

**Các mutant là tổng hợp.** Các con số dưới đây nói về *các toán tử này trên bản mã hóa nháp này*; chúng **không** nói gì về tần suất lỗi thật
trong luật thật. Không có «tỉ lệ phát hiện» tổng hợp nào được báo. Kiểm hồi quy (mục 2) là hệ quả của định lý W4, không phải bằng chứng phát hiện lỗi pháp lý.

## 1. Bất đồng giữa (a) Lean toàn miền, (b) Python và (c) `analyzeP` — báo trước hết

**410 mutant** (407 mutant đã đột biến + 3 gốc không đột biến): **0 bất đồng** giữa ba cách tính ở cả bốn mặt — tập finding (khóa chuẩn hóa),
tập cặp xung đột không ràng buộc, tập cặp xung đột có ràng buộc IC-A, và số cặp đã kiểm/số điểm duyệt của `analyzeP` (đối chiếu với số điểm tính độc lập bằng Python).
Quy tắc dừng (Python phải khớp Lean trên bản chưa đột biến) **không** bị kích hoạt; bản mã hóa gốc B0 kiểm bằng `decide` là **bằng đúng** mô-đun
`Laws/AlcoholSale.lean` (bảng, bộ đọc, norm).

Hai điều cần ghi dù không phải bất đồng giữa (a), (b), (c):

1. **FINDING — `analyze` hiện có im lặng với lỗi bảng và bộ đọc.** Với 84 mutant chỉ có finding của bảng hoặc của bộ đọc (M8b, M8c, M11a–d),
   `validate` (do đó `analyze`) không thấy gì: `analyze` trả `consistentOn` cho 59 mutant và `conflict` cho 25 mutant, như thể bảng đúng.
   Chỉ `analyzeP` trả `.invalid` kèm finding nêu tên. (Ví dụ nặng nhất: enum không có dải nào, không gian rỗng, `analyze` → `consistentOn` rỗng; xem A0 trong
   [design-core.md](design-core.md) mục 11.)
2. **Lỗi của chính script phân tích (đã sửa, không phải của bộ kiểm).** Lần chạy đầu tôi so `analyze` với «phải trả `invalid` khi có bất kỳ finding nào» và thu được 84 «bất đồng»
   — thực chất do kỳ vọng sai của tôi (`analyze` chỉ chạy `validate`). Sau đó một kỳ vọng của M7b sai vì dấu «:» thừa khi tách chuỗi (1 «kỳ vọng sai» giả).
   Cả hai đã sửa trong `run_all.py`; kỳ vọng ở `mutation-experiment.md` không đổi.

## 2. Kiểm hồi quy

Trên 236 mutant không `.invalid` (kể cả 3 gốc): tập cặp trong hit của `analyzeP` bằng tập cặp xung đột của kiểm toàn miền ở **236/236** mutant;
số cặp được báo mà kiểm toàn miền không xác nhận: **0**; số cặp xung đột bị bỏ sót: **0**. Đúng như định lý W4 bảo đảm.

## 3. Số đếm theo nhóm và toán tử

Định nghĩa các cột ở `mutation-experiment.md` mục 5. «unconstrained-only» đếm *cặp* xung đột `analyzeP` báo mà mọi điểm xung đột đều vi phạm IC-A.
«kỳ vọng sai» = kết cục thực khác kỳ vọng đặt trước ở mục 3 của `mutation-experiment.md`.

### Nhóm A — lỗi cấu trúc (kỳ vọng: bắt được, nêu đúng đối tượng, không finding thừa)

| Toán tử | n | detected (đúng loại, nêu đúng đối tượng) | missed | kỳ vọng sai (finding thừa hoặc thiếu) | bất đồng |
|---|---|---|---|---|---|
| M5 id trùng | 18 | 18 | 0 | 0 | 0 |
| M6a tham chiếu treo | 18 | 18 | 0 | 0 | 0 |
| M8b bộ đọc: atom trong khoảng, giá trị ngoài miền | 18 | 18 | 0 | 0 | 0 |
| M8c bộ đọc: atom ngoài khoảng | 18 | 18 | 0 | 0 | 0 |
| M8e `Cond.sit` ngoài khoảng | 18 | 18 | 0 | 0 | 0 |
| M9b chu trình ưu tiên | 18 | 18 | 0 | 0 | 0 |
| M9c ưu tiên tới id không có | 18 | 18 | 0 | 0 | 0 |
| M11a trùng tên atom | 18 | 18 | 0 | 0 | 0 |
| M11b enum không có dải | 6 | 6 | 0 | 0 | 0 |
| M11c nguồn rỗng | 18 | 18 | 0 | 0 | 0 |
| M11d trùng nhãn dải | 6 | 6 | 0 | 0 | 0 |

### Nhóm B — điểm mù mô hình hóa

| Toán tử | n | detected | missed-invisible | missed-hiding | false alarm | unconstrained-only (cặp) | kỳ vọng sai | bất đồng |
|---|---|---|---|---|---|---|---|---|
| M1 đổi modality | 18 | 15 | 3 | 0 | 0 | 0 | 0 | 0 |
| M2 thêm norm modality đối | 30 | 29 | 1 | 0 | 0 | 0 | 0 | 0 |
| M3 bỏ ngoại lệ | 3 | 0 | 3 | 0 | 0 | 0 | 0 | 0 |
| M4 đổi tập dải | 18 | 1 | 15 | 2 | 0 | 0 | 0 | 0 |
| M7a đổi act sang act có sẵn | 18 | 3 | 14 | 1 | 0 | 0 | 0 | 0 |
| M7b đổi act sang act mới | 18 | 0 | 17 | 1 | 0 | 0 | 0 | 0 |
| M8a bộ đọc đọc atom khác (hợp lệ) | 18 | 2 | 16 | 0 | 0 | 0 | 0 | 0 |
| M8d `Cond.sit` sang bộ đọc khác (trong khoảng) | 18 | 4 | 14 | 0 | 0 | 0 | 0 | 0 |
| M9a thêm cạnh ưu tiên | 18 | 0 | 18 | 0 | 0 | 0 | 0 | 0 |

Theo gốc (B0 chỉ gồm lệnh cấm; B1 thêm một cho phép rời; B2 có sẵn một xung đột):

| Gốc | n | detected | missed-invisible | missed-hiding |
|---|---|---|---|---|
| B0 | 53 | 14 | 39 | 0 |
| B1 | 53 | 21 | 32 | 0 |
| B2 | 53 | 19 | 30 | 4 |

### Nhóm C — thiếu ràng buộc toàn vẹn

| Toán tử | n | detected | missed-invisible | missed-hiding | false alarm | unconstrained-only (cặp) | kỳ vọng sai | bất đồng |
|---|---|---|---|---|---|---|---|---|
| M10a norm chỉ xung đột ở vùng bất khả thi | 10 | 10 | 0 | 0 | 10 | 60 | 0 | 0 |
| M10b đối chứng: xung đột ở vùng khả thi | 10 | 10 | 0 | 0 | 0 | 0 | 0 | 0 |

### Nhóm D — đối chứng lành

| Toán tử | n | im lặng (đúng) | false alarm |
|---|---|---|---|
| C1 đổi id duy nhất | 18 | 18 | 0 |
| C2 tham chiếu có thật | 18 | 18 | 0 |
| C3 đảo thứ tự | 18 | 18 | 0 |

## 4. Điểm mù tìm thấy (mỗi loại một ví dụ)

* **Norm đứng một mình trên act của nó (M1).** `B0.M1.00` — norm 5.3-cung-cap: modality prohibition -> permission — `missed-invisible`: đổi modality của một norm không có norm cùng act thì bộ kiểm không thấy gì.
* **Nhóm toàn lệnh cấm.** Ở B0 hầu hết đột biến ngữ nghĩa là `missed-invisible`: không cặp nào có modality khắc nhau. Ví dụ M3 (bỏ ngoại lệ): `B0.M3.00` — drop exception of 19.6; M4 (thu hẹp dải): `B0.M4.00` — 5.3-ban: narrow band reader 0.
* **Bộ đọc đọc sai atom nhưng vẫn trong khoảng (M8a).** `B0.M8a.00` — reader S02 dưới 15 (1,0) -> (3,0) in range — `missed-invisible`; `readerFindings` chỉ kiểm khoảng, không kiểm nghĩa.
* **`Cond.sit` trỏ sang bộ đọc khác nhưng vẫn trong khoảng (M8d).** `B0.M8d.00` — 5.3-ban: Cond.sit 0 -> 10 (in range) — `missed-invisible`.
* **Đổi độ mịn act (M7).** Sang act mới: `B0.M7b.00` — norm 5.3-ban: act ban_ruou_bia -> new act_moi_5.3-ban — `missed-invisible`. Ở B2: `B2.M7b.05` — norm SYN-P: act khuyen_mai_ruou_bia -> new act_moi_SYN-P — `missed-hiding` (xung đột đã có biến mất, không finding).
  Sang act có sẵn có thể *tạo* xung đột hình thức chỉ vì việc gộp: `B1.M7a.03` — norm 5.11-ii: act ban_ruou_bia_bang_may_tu_dong -> existing khuyen_mai_ruou_bia.
* **Che xung đột bằng đột biến dải (M4) hoặc gộp act (M7a) ở B2.** `B2.M4.04` — 5.9-i: narrow band reader 3; `B2.M7a.01` — norm 5.9-i: act khuyen_mai_ruou_bia -> existing ban_ruou_bia.
* **Cạnh ưu tiên (M9a).** `B0.M9a.00` — 5.3-khuyen-mai overrides 5.9-i — thêm ưu tiên một chiều đúng thiết kế (ADR-0013) nhưng lặng lẽ. Ở B2 mẫu của tôi không rơi vào cặp xung đột duy nhất nên không có ca `missed-hiding`
  nào của M9a trong mẫu (không có nghĩa là không thể xảy ra: nó là hệ quả trực tiếp của định nghĩa `resolved`).
* **Xung đột thêm ngẫu nhiên không giao (M2).** `B0.M2.04` — add permission M2new-10 on act dung_ruou_bia_lam_qua_khuyen_mai, cond ('and', ('sit', 2), ('sit', 8)).

## 5. Xung đột chỉ tồn tại ở tình huống bất khả thi (unconstrained-only)

Tổng cộng **60 cặp** trên 10 mutant M10a (mỗi mutant 6 cặp); mọi mutant M10a đều là `detected` *và* `false alarm`: `analyzeP` báo xung đột nhưng IC-A loại mọi điểm xung đột.
Đối chứng M10b (cùng cấu trúc, bỏ vế `P14 ∧ ¬S16`): **0** cặp unconstrained-only — các xung đột nằm ở tình huống khả thi. Ngoài M10 không có mutant nào có cặp unconstrained-only.
Điều này **chỉ** cho thấy bộ kiểm không phân biệt hai loại; IC-A là giả định của người soạn, chưa ai duyệt.

## 6. Thời gian `analyzeP` mỗi mutant

Trong trình thông dịch Lean (`lake env lean --run`), **không** phải kernel: trung vị **4829 µs**, phân vị 90 **6331 µs**, lớn nhất **9543 µs** (trên 235 mutant hợp lệ, không tính 3 gốc).
Lần gọi đầu (B0) mất 53398 µs do khởi động. Không so sánh được với số đo `decide +kernel`. Toàn bộ phần Lean của thí nghiệm (410 mutant, gồm kiểm toàn miền) chạy khoảng 5 phút.

## 7. Điều tôi không xác minh được

* Các mutant là **tổng hợp**; mẫu giới hạn **6 ứng viên mỗi (toán tử, gốc)** theo seed nên số đếm nhỏ (ví dụ M3 chỉ có 3 mutant; M9a không rơi vào cặp xung đột duy nhất ở B2).
* **(a) và (b) cùng do một người viết** từ cùng định nghĩa; chúng độc lập về mã nhưng có thể chung cách hiểu sai. (a) bỏ qua cặp khác act trước khi gọi `isConflictAt` (mệnh đề đầu của `Conflict`) để rút ngắn thời gian.
* **IC-A** là giả định của tôi về «bất khả thi trong thực tế»; **`SYN-P`** là norm tổng hợp, không có trong luật. Không điều nào được duyệt.
* Không đột biến: `docId` lẫn, hoa/thường trong tên act, thứ tự bộ đọc trong bảng, đột biến tổ hợp (hai lỗi cùng lúc), ngoại lệ phức tạp, và ràng buộc toàn vẹn sai (quá mạnh che xung đột — `valid` vẫn là điểm tin cậy).
* Không có số liệu nào ở đây nói về lỗi thật trong luật thật hay về độ tin cậy của người mã hóa.
