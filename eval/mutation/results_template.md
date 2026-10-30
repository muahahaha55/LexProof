# Kết quả thí nghiệm đột biến

Thiết kế, toán tử, kỳ vọng, chỉ số, seed (`20261031`) và ngày (2026-10-31) đã chốt trước ở
[mutation-experiment.md](mutation-experiment.md) và **không được sửa**. Tệp này chỉ ghi kết quả. Mã và số đo thô: `eval/mutation/`
(`mutants.csv`, `results.csv`, `disagreements.txt`, `summary.json`).

**Các mutant là tổng hợp.** Các con số dưới đây nói về *các toán tử này trên bản mã hóa nháp này*; chúng **không** nói gì về tần suất lỗi thật
trong luật thật. Không có «tỉ lệ phát hiện» tổng hợp nào được báo. Kiểm hồi quy (mục 2) là hệ quả của định lý W4, không phải bằng chứng phát hiện lỗi pháp lý.

## 1. Bất đồng giữa (a) Lean toàn miền, (b) Python và (c) `analyzeP` — báo trước hết

**{{N_ALL}} mutant** ({{N_MUT}} mutant đã đột biến + 3 gốc không đột biến): **0 bất đồng** giữa ba cách tính ở cả bốn mặt — tập finding (khóa chuẩn hóa),
tập cặp xung đột không ràng buộc, tập cặp xung đột có ràng buộc IC-A, và số cặp đã kiểm/số điểm duyệt của `analyzeP` (đối chiếu với số điểm tính độc lập bằng Python).
Quy tắc dừng (Python phải khớp Lean trên bản chưa đột biến) **không** bị kích hoạt; bản mã hóa gốc B0 kiểm bằng `decide` là **bằng đúng** mô-đun
`Laws/AlcoholSale.lean` (bảng, bộ đọc, norm).

Hai điều cần ghi dù không phải bất đồng giữa (a), (b), (c):

1. **FINDING — `analyze` hiện có im lặng với lỗi bảng và bộ đọc.** Với {{N_TAB}} mutant chỉ có finding của bảng hoặc của bộ đọc (M8b, M8c, M11a–d),
   `validate` (do đó `analyze`) không thấy gì: `analyze` trả `consistentOn` cho {{TAB_CONS}} mutant và `conflict` cho {{TAB_CONF}} mutant, như thể bảng đúng.
   Chỉ `analyzeP` trả `.invalid` kèm finding nêu tên. (Ví dụ nặng nhất: enum không có dải nào, không gian rỗng, `analyze` → `consistentOn` rỗng; xem A0 trong
   [design-core.md](design-core.md) mục 11.)
2. **Lỗi của chính script phân tích (đã sửa, không phải của bộ kiểm).** Lần chạy đầu tôi so `analyze` với «phải trả `invalid` khi có bất kỳ finding nào» và thu được 84 «bất đồng»
   — thực chất do kỳ vọng sai của tôi (`analyze` chỉ chạy `validate`). Sau đó một kỳ vọng của M7b sai vì dấu «:» thừa khi tách chuỗi (1 «kỳ vọng sai» giả).
   Cả hai đã sửa trong `run_all.py`; kỳ vọng ở `mutation-experiment.md` không đổi.

## 2. Kiểm hồi quy

Trên {{REG_N}} mutant không `.invalid` (kể cả 3 gốc): tập cặp trong hit của `analyzeP` bằng tập cặp xung đột của kiểm toàn miền ở **{{REG_EQ}}/{{REG_N}}** mutant;
số cặp được báo mà kiểm toàn miền không xác nhận: **{{REG_BAD}}**; số cặp xung đột bị bỏ sót: **{{REG_MISS}}**. Đúng như định lý W4 bảo đảm.

## 3. Số đếm theo nhóm và toán tử

Định nghĩa các cột ở `mutation-experiment.md` mục 5. «unconstrained-only» đếm *cặp* xung đột `analyzeP` báo mà mọi điểm xung đột đều vi phạm IC-A.
«kỳ vọng sai» = kết cục thực khác kỳ vọng đặt trước ở mục 3 của `mutation-experiment.md`.

### Nhóm A — lỗi cấu trúc (kỳ vọng: bắt được, nêu đúng đối tượng, không finding thừa)

{{TABLE_A}}

### Nhóm B — điểm mù mô hình hóa

{{TABLE_B}}

Theo gốc (B0 chỉ gồm lệnh cấm; B1 thêm một cho phép rời; B2 có sẵn một xung đột):

{{TABLE_BBASE}}

### Nhóm C — thiếu ràng buộc toàn vẹn

{{TABLE_C}}

### Nhóm D — đối chứng lành

{{TABLE_D}}

## 4. Điểm mù tìm thấy (mỗi loại một ví dụ)

* **Norm đứng một mình trên act của nó (M1).** {{EX_M1}} — `missed-invisible`: đổi modality của một norm không có norm cùng act thì bộ kiểm không thấy gì.
* **Nhóm toàn lệnh cấm.** Ở B0 hầu hết đột biến ngữ nghĩa là `missed-invisible`: không cặp nào có modality khắc nhau. Ví dụ M3 (bỏ ngoại lệ): {{EX_M3}}; M4 (thu hẹp dải): {{EX_M4}}.
* **Bộ đọc đọc sai atom nhưng vẫn trong khoảng (M8a).** {{EX_M8A}} — `missed-invisible`; `readerFindings` chỉ kiểm khoảng, không kiểm nghĩa.
* **`Cond.sit` trỏ sang bộ đọc khác nhưng vẫn trong khoảng (M8d).** {{EX_M8D}} — `missed-invisible`.
* **Đổi độ mịn act (M7).** Sang act mới: {{EX_M7B}} — `missed-invisible`. Ở B2: {{EX_M7B_HIDE}} — `missed-hiding` (xung đột đã có biến mất, không finding).
  Sang act có sẵn có thể *tạo* xung đột hình thức chỉ vì việc gộp: {{EX_M7A_NEW}}.
* **Che xung đột bằng đột biến dải (M4) hoặc gộp act (M7a) ở B2.** {{EX_M4_HIDE}}; {{EX_M7A_HIDE}}.
* **Cạnh ưu tiên (M9a).** {{EX_M9A}} — thêm ưu tiên một chiều đúng thiết kế (ADR-0013) nhưng lặng lẽ. Ở B2 mẫu của tôi không rơi vào cặp xung đột duy nhất nên không có ca `missed-hiding`
  nào của M9a trong mẫu (không có nghĩa là không thể xảy ra: nó là hệ quả trực tiếp của định nghĩa `resolved`).
* **Xung đột thêm ngẫu nhiên không giao (M2).** {{EX_M2}}.

## 5. Xung đột chỉ tồn tại ở tình huống bất khả thi (unconstrained-only)

Tổng cộng **{{UNC_PAIRS}} cặp** trên {{UNC_N}} mutant M10a (mỗi mutant 6 cặp); mọi mutant M10a đều là `detected` *và* `false alarm`: `analyzeP` báo xung đột nhưng IC-A loại mọi điểm xung đột.
Đối chứng M10b (cùng cấu trúc, bỏ vế `P14 ∧ ¬S16`): **{{UNC_CTRL}}** cặp unconstrained-only — các xung đột nằm ở tình huống khả thi. Ngoài M10 không có mutant nào có cặp unconstrained-only.
Điều này **chỉ** cho thấy bộ kiểm không phân biệt hai loại; IC-A là giả định của người soạn, chưa ai duyệt.

## 6. Thời gian `analyzeP` mỗi mutant

Trong trình thông dịch Lean (`lake env lean --run`), **không** phải kernel: trung vị **{{MED}} µs**, phân vị 90 **{{P90}} µs**, lớn nhất **{{MAX}} µs** (trên {{TN}} mutant hợp lệ, không tính 3 gốc).
Lần gọi đầu (B0) mất {{FIRST}} µs do khởi động. Không so sánh được với số đo `decide +kernel`. Toàn bộ phần Lean của thí nghiệm (410 mutant, gồm kiểm toàn miền) chạy khoảng 5 phút.

## 7. Điều tôi không xác minh được

* Các mutant là **tổng hợp**; mẫu giới hạn **6 ứng viên mỗi (toán tử, gốc)** theo seed nên số đếm nhỏ (ví dụ M3 chỉ có 3 mutant; M9a không rơi vào cặp xung đột duy nhất ở B2).
* **(a) và (b) cùng do một người viết** từ cùng định nghĩa; chúng độc lập về mã nhưng có thể chung cách hiểu sai. (a) bỏ qua cặp khác act trước khi gọi `isConflictAt` (mệnh đề đầu của `Conflict`) để rút ngắn thời gian.
* **IC-A** là giả định của tôi về «bất khả thi trong thực tế»; **`SYN-P`** là norm tổng hợp, không có trong luật. Không điều nào được duyệt.
* Không đột biến: `docId` lẫn, hoa/thường trong tên act, thứ tự bộ đọc trong bảng, đột biến tổ hợp (hai lỗi cùng lúc), ngoại lệ phức tạp, và ràng buộc toàn vẹn sai (quá mạnh che xung đột — `valid` vẫn là điểm tin cậy).
* Không có số liệu nào ở đây nói về lỗi thật trong luật thật hay về độ tin cậy của người mã hóa.
