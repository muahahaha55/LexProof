# Thí nghiệm đột biến trên bản nháp mã hóa nhóm «bán / cung cấp / khuyến mại rượu, bia»

**Ngày chốt tài liệu này: 2026-10-31. Hạt giống ngẫu nhiên: `20261031`.** Tài liệu này được viết **trước khi chạy bất kỳ
đột biến nào** và **không được sửa** sau đó (kết quả đi vào `docs/mutation-results.md`). Nếu cần đổi một toán tử, một kỳ vọng
hay một chỉ số, phải thêm ghi chú *cuối* tài liệu, không viết đè.

## 0. Cái thí nghiệm này KHÔNG đo

* `conflicts_complete` (W4) đã bảo đảm: mọi cặp norm cùng act thật sự xung đột ở một điểm của miền đầy đủ **đều được liệt kê**.
  Nên «độ phủ so với định nghĩa xung đột của chính bộ kiểm» là **100% theo xây dựng** và **không** được trình bày như bằng chứng
  rằng bộ kiểm phát hiện lỗi pháp lý.
* Các đột biến là **tổng hợp** (do toán tử sinh ra, không phải lỗi thật của người mã hóa thật). Mọi con số chỉ nói về *các toán tử này
  trên bản mã hóa này*; **không nói gì** về tần suất lỗi thật trong luật thật. Không có «tỉ lệ phát hiện» tổng hợp nào được báo như tiêu đề.

Thí nghiệm chỉ đo những gì định lý **không** bao phủ:

* **(A)** lỗi *cấu trúc*: `validate`, `tableFindings`, `readerFindings` bắt được bao nhiêu và bỏ sót gì;
* **(B)** *điểm mù mô hình hóa*: lỗi người mã hóa có thể gây ra mà bộ kiểm không thấy;
* **(C)** *báo động giả do thiếu ràng buộc toàn vẹn*: xung đột được báo ở một tình huống người mã hóa coi là không thể xảy ra;
* cộng với **kiểm hồi quy**: mọi xung đột hình thức đều được tìm thấy (kỳ vọng 100%) và không có xung đột nào được báo mà kiểm toàn miền
  không xác nhận (kỳ vọng 0).

## 1. Ba bản mã hóa gốc

| Gốc | Nội dung | Kỳ vọng ở gốc |
|---|---|---|
| **B0** | `LexProof/Laws/AlcoholSale.lean` nguyên trạng: 12 norm, đều là *cấm* | `consistentOn`, 22 cặp cùng act đã kiểm, không finding |
| **B1** | B0 + một norm **tổng hợp** `SYN-P`: *cho phép*, act `khuyen_mai_ruou_bia`, điều kiện «S02 = dưới 15 độ **và** S04 = từ đủ 18 tuổi». Không có trong luật (nguồn ghi «(tổng hợp, không có trong luật)»). Điều kiện rời với 5.3-khuyen-mai (tuổi) và 5.9-i (độ cồn) | `consistentOn` (cho phép × cấm có modality khắc nhau nhưng dải rời nhau) |
| **B2** | B1 với điều kiện `SYN-P` nới thành «S04 = từ đủ 18 tuổi» (bỏ dải độ cồn) | **một** cặp xung đột hình thức: `SYN-P` × `5.9-i`, ở các điểm «đủ 18 tuổi và từ 15 độ trở lên» |

Lý do có B1 và B2: B0 chỉ gồm lệnh cấm nên mọi đột biến ngữ nghĩa trên B0 đều vô hình với mọi bộ kiểm modality (xem phiếu duyệt, mục 8). B1
cho phép đột biến dải/act tạo ra hoặc không tạo ra xung đột; B2 cho phép đo việc đột biến **che** một xung đột đã có.

## 2. Ràng buộc toàn vẹn dùng cho (C) — «ràng buộc còn thiếu»

Chỉ **một** ràng buộc, do người soạn đề xuất, chưa ai duyệt:

> **IC-A**: nếu tham số **P14** («địa điểm *dành cho* người chưa đủ 18 tuổi») đúng thì **S16** (loại cơ sở/khu vực chăm sóc, nuôi dưỡng,
> vui chơi, giải trí) phải đúng. Tức tổ hợp `P14 ∧ ¬S16` **không thể xảy ra**: «dành cho» chỉ bổ nghĩa cho một cơ sở/khu vực ở 19.3.

`valid π s = ¬P14(π) ∨ S16(s)`. Bộ kiểm hiện tại **không** dùng ràng buộc (`analyzeP` ghi `constraintsUsed = false`); ràng buộc chỉ được áp
dụng ở ground truth (a) và (b) bên dưới để tách «xung đột chỉ nằm ở tình huống bất khả thi».

## 3. Toán tử đột biến (mức dữ liệu) và kỳ vọng

Nhãn kết cục cho từng mutant (định nghĩa chính xác ở mục 5):
**detected** = bộ kiểm báo ra một kết quả khác kết quả của gốc, đúng loại và nêu tên đối tượng; **missed-invisible** = kết quả y hệt gốc;
**missed-hiding** = gốc có xung đột mà mutant không còn báo (đột biến che xung đột); **false alarm** và **unconstrained-only**: mục 5.

Mỗi toán tử lấy tối đa **6** ứng viên mỗi gốc (M2: 10), chọn ngẫu nhiên có seed từ danh sách ứng viên đã liệt kê đầy đủ; M10 liệt kê hết
(trên B0). «Ngẫu nhiên» luôn là `random.Random("20261031-<mã toán tử>-<gốc>")`.

### Nhóm A — lỗi cấu trúc (kỳ vọng: bắt được)

| Mã | Đột biến | Kỳ vọng | Lý do |
|---|---|---|---|
| **M5** | đặt id của norm j trùng id của norm i | **detected**: `duplicateId <id>` | `validate` có `duplicateIds` |
| **M6a** | thêm `references := ["Điều 99"]` (không có trong danh mục Điều 1..36) cho một norm | **detected**: `danglingReference <norm> Điều 99` | `danglingFindings` |
| **M8b** | đặc tả bộ đọc: đổi chỉ số atom sang atom khác **trong** khoảng, nhưng giá trị vượt miền của atom mới | **detected**: `readerValueOutOfRange <bộ đọc>` | `readerFindings` |
| **M8c** | đặc tả bộ đọc: chỉ số atom **ngoài** khoảng | **detected**: `readerAtomOutOfRange <bộ đọc>` | `readerFindings` |
| **M8e** | `Cond.sit i`/`param i` trong một norm đổi sang chỉ số **ngoài** danh sách bộ đọc | **detected**: `atomIndexOutOfRange <norm>` | `malformedFindings` (`Norm.wf`) |
| **M9b** | hai norm đặt `overrides` lẫn nhau (chu trình hai đỉnh) | **detected**: `priorityCycle` cho cả hai | `cycleFindings` |
| **M9c** | `overrides` trỏ tới id không tồn tại | **detected**: `unknownOverride <norm> <đích>` | `unknownOverrideFindings` |
| **M11a** | bảng: hai atom trùng tên | **detected**: `duplicateAtomName` | `tableFindings` |
| **M11b** | bảng: một atom enum không có dải nào | **detected**: `emptyDomain <atom>` | `tableFindings` |
| **M11c** | bảng: chuỗi nguồn rỗng (atom hoặc dải) | **detected**: `emptyAtomSource`/`emptyBandSource` | `tableFindings` |
| **M11d** | bảng: hai dải cùng nhãn trong một atom | **detected**: `duplicateBandLabel` | `tableFindings` |

Phần kiểm này còn có hai kỳ vọng phụ: một finding **nêu đúng** đối tượng bị đột biến (không chỉ «có finding»), và **không** có finding
thừa nào ngoài những cái được dự đoán.

### Nhóm B — điểm mù mô hình hóa (kỳ vọng: bộ kiểm không thấy, trừ khi nó tình cờ tạo ra xung đột hình thức)

| Mã | Đột biến | Kỳ vọng | Lý do |
|---|---|---|---|
| **M1** | đổi modality của một norm sang *nghĩa vụ* hoặc *cho phép* | **detected** nếu act của norm có norm cùng act, modality khắc nhau, không được giải quyết bằng ưu tiên, và điều kiện cùng đúng ở một điểm; ngược lại **missed-invisible** | xung đột hình thức chỉ cần cùng act + khắc nhau + cùng áp dụng. Norm một mình trên act (`cung_cap`, `dung_...lam_qua`, `bán bằng máy`) không bao giờ lộ ra |
| **M2** | thêm một norm modality **đối** (nghĩa vụ hoặc cho phép) trên một act có sẵn, điều kiện là một biểu thức ngẫu nhiên (1–2 bộ đọc lấy từ `rS`/`rP`, nối VÀ/HOẶC, có thể phủ định) | **detected** nếu điều kiện giao với điều kiện một norm cấm cùng act; ngược lại **missed-invisible** | như M1; điều kiện ngẫu nhiên thường giao nên phần lớn là detected, phần còn lại cho biết cỡ điểm mù |
| **M3** | bỏ ngoại lệ (chỉ 19.6 có ngoại lệ) | **missed-invisible** ở B0/B1; ở B2 cũng vậy | mọi norm trong nhóm là cấm; 19.6 không có đối tác khắc modality |
| **M4** | nới / đổi / thu hẹp tập dải mà một điều kiện kiểm: **nới** = bộ đọc dải → «dải HOẶC dải còn lại» (luôn đúng); **đổi** = sang dải còn lại (sai ranh giới); **thu hẹp** = bộ đọc dải → `ff` | B0: **missed-invisible** (không có đối tác). B1: **detected** với *nới* hoặc *đổi* nếu tạo giao với norm khắc modality (`SYN-P` ↔ 5.3-khuyen-mai, 5.9-i); *thu hẹp* **missed-invisible** (thu hẹp không thể tạo xung đột mới). B2: *thu hẹp*/*đổi* điều kiện của `SYN-P` có thể **missed-hiding** | ranh giới sai chỉ lộ ra nếu nó làm hai điều kiện giao nhau |
| **M7a** | đổi act của một norm sang một act **đã có** khác | B0: **missed-invisible** (đều là cấm). B1/B2: **detected** nếu norm (hoặc `SYN-P`) nay chung act với norm khắc modality có điều kiện giao | gộp act mịn → thô |
| **M7b** | đổi act của một norm sang một act **mới** | B0/B1: **missed-invisible**. B2: **missed-hiding** nếu norm đổi act là `SYN-P` hoặc `5.9-i` | tách act che xung đột; bộ kiểm không biết hai act «đáng ra giống nhau» (ADR-0004) |
| **M8a** | đặc tả bộ đọc: đổi chỉ số atom sang atom khác **trong** khoảng, giá trị cũng trong miền | **missed-invisible** (hoặc detected nếu tình cờ tạo xung đột hình thức) | bộ đọc đọc sai atom mà vẫn hợp lệ: bộ kiểm không biết nghĩa |
| **M8d** | `Cond.sit i` trong một norm đổi sang chỉ số bộ đọc khác **trong** khoảng | như M8a | như M8a |
| **M9a** | thêm một cạnh ưu tiên hợp lệ (norm A `overrides` norm B) | B0/B1: **missed-invisible** (không có xung đột để giải quyết). B2: **missed-hiding** nếu cặp (A,B) là cặp xung đột `SYN-P` × `5.9-i` | ưu tiên một chiều làm `resolved = true` nên cặp không còn bị báo (đúng theo thiết kế, ADR-0013); đo xem việc này lặng lẽ cỡ nào |

### Nhóm C — báo động giả do thiếu ràng buộc

| Mã | Đột biến | Kỳ vọng | Lý do |
|---|---|---|---|
| **M10a** | thêm norm `Z` (cho phép hoặc nghĩa vụ) act `ban_ruou_bia`, điều kiện `P14 ∧ ¬S16 ∧ X` với `X` lần lượt là điều kiện của 19.1, 19.2, 19.4, 19.5, 19.6 | **detected** (xung đột hình thức) **và** mọi cặp được báo là **unconstrained-only**: mọi điểm xung đột đều vi phạm IC-A | `Z` chỉ áp dụng ở vùng `P14 ∧ ¬S16` mà IC-A loại. Toàn bộ xung đột của `Z` nằm ở tình huống bất khả thi |
| **M10b** | như M10a nhưng bỏ vế `P14 ∧ ¬S16` (điều kiện chỉ `X`) | **detected** và các cặp được báo có điểm xung đột **hợp lệ** theo IC-A (không phải unconstrained-only) | đối chứng: cùng cấu trúc, xung đột nằm ở tình huống có thể xảy ra |

### Nhóm D — đối chứng lành (kỳ vọng: im lặng)

| Mã | Đột biến | Kỳ vọng |
|---|---|---|
| **C1** | đổi id của một norm sang một id **mới, duy nhất** | kết quả như gốc; mọi finding hay xung đột thừa là **false alarm** |
| **C2** | thêm `references := ["Điều 5"]` (có trong danh mục) | không finding; finding thừa là **false alarm** |
| **C3** | đảo thứ tự hai norm trong danh sách | kết quả như gốc (cùng tập cặp xung đột theo id) |

## 4. Ground truth — tính hai cách độc lập, so sánh trước khi tính bất kỳ tỉ lệ nào

* **(a) Lean, miền đầy đủ.** Với từng mutant, liệt kê **mọi** `(π, s)` của hai bảng bằng `Finite.enum` và gọi `Internal.isConflictAt` của bộ kiểm
  hiện có (cùng `analyze`) cho mọi cặp vị trí `i < j`; ghi tập cặp có ít nhất một điểm xung đột. Làm hai lần: `valid` mặc định (không ràng buộc) và
  `valid := IC-A`. Cũng ghi `analyze` (kết quả đầu tiên) và `validate`/`tableFindings`/`readerFindings`.
* **(b) Python, cài lại độc lập** từ định nghĩa trong `LexProof/Core/Norm.lean`, `Core/AtomTable.lean`, `Verify/Conflict.lean`, `Verify/Validate.lean`,
  `Verify/ProjectedCheck.lean` (không gọi Lean): `Cond.eval` ba trị (`none` khi chỉ số ngoài khoảng), `applies = cond ∧ ¬(∨ ngoại lệ)`,
  `Incompatible`, `resolved` là XOR, bộ đọc `s.vs.getD i 0 == v`, miền = tích các miền atom; cùng tập finding (khóa chuẩn hóa) và cùng tập cặp xung đột.
* **(c) `analyzeP`** (đã có định lý): tập cặp trong các hit và tập finding.

Mọi bất đồng giữa (a), (b), (c) — tập finding, tập cặp không ràng buộc, tập cặp có ràng buộc — là một **FINDING** và được báo **trước hết**, kèm mutant.
**Quy tắc dừng**: nếu bản Python không khớp được với Lean trên bản mã hóa **chưa đột biến** (B0, B1, B2), dừng và báo sự khác biệt.

## 5. Chỉ số (đếm, không có tỉ lệ tổng)

Với mỗi toán tử và mỗi nhóm (A, B, C, D), bảng gồm: **n**, **detected**, **missed-invisible**, **missed-hiding**, **false alarm**,
**unconstrained-only**, **bất đồng**, **kỳ vọng sai** (mutant mà kết cục thực khác kỳ vọng ở mục 3).

Định nghĩa chính xác:

* **detected** — Nhóm A: `analyzeP` trả `.invalid` và có finding đúng loại **nêu đúng đối tượng bị đột biến**. Nhóm B/C: `analyzeP` trả
  `.invalid` hoặc `.conflicts` mà tập cặp xung đột **có phần không có ở gốc** (xung đột mới).
* **missed-invisible** — kết quả của `analyzeP` giống hệt gốc (cùng tập finding rỗng, cùng tập cặp xung đột).
* **missed-hiding** — gốc có cặp xung đột mà mutant không còn (cặp biến mất mà `analyzeP` không có finding nào).
* **unconstrained-only** — số cặp xung đột `analyzeP` báo mà **mọi** điểm xung đột của cặp đều vi phạm IC-A (nghĩa là kiểm có ràng buộc không còn
  xung đột ở cặp đó). Tính trên mọi mutant có `.conflicts`, không chỉ M10.
* **false alarm** — (i) mutant ở nhóm D mà bộ kiểm báo finding/xung đột thừa; hoặc (ii) mutant mà **mọi** cặp xung đột `analyzeP` báo đều
  unconstrained-only.
* **bất đồng** — chênh lệch giữa (a), (b), (c) (mục 4).
* **kỳ vọng sai** — kết cục thực ≠ kỳ vọng ở mục 3 (tính theo luật kỳ vọng của từng toán tử; mutant «detected nếu điều kiện giao» được đối chiếu với
  ground truth (a)).

**Kiểm hồi quy** (mọi mutant không `.invalid`): (1) tập cặp trong hit của `analyzeP` = tập cặp xung đột không ràng buộc của (a) — kỳ vọng bằng nhau 100%;
(2) số cặp được báo mà (a) không xác nhận — kỳ vọng 0.

**Thời gian**: ms mỗi mutant của `analyzeP` (trung vị, lớn nhất), đo trong trình thông dịch Lean (`lake env lean --run`), **không** phải kernel —
chỉ để thấy cỡ; không so sánh được với số đo `decide +kernel`.

## 6. Quy trình và tệp

`eval/mutation/`: `gen_mutants.py` (sinh mutant từ seed, ghi `mutants.csv` và `Run.lean`), `reference.py` (bản Python (b)), `run_all.py`,
`results.csv`, `README.md`. Cách chạy: `python eval/mutation/run_all.py` (gọi `lake env lean --run eval/mutation/Run.lean`).
Các tệp Lean là tệp thử bỏ đi, **không** thuộc thư viện và không được `LexProof.lean` import.

## 7. Điều kỳ vọng sẽ lộ ra (đặt trước để khỏi chọn lọc sau)

* Nhóm A: tôi kỳ vọng **tất cả** detected và không có finding thừa; nếu không, đó là phát hiện.
* Nhóm B: tôi kỳ vọng phần lớn mutant ở B0 là **missed-invisible** (điểm mù lớn do mọi norm là cấm); ở B1/B2 một phần detected nhờ xung đột hình thức;
  M7b và M9a ở B2 là **missed-hiding**; M8a/M8d là điểm mù thuần túy.
* Nhóm C: M10a tất cả **unconstrained-only**; M10b không.
* Nhóm D: không false alarm.
* Không có bất đồng (a)/(b)/(c). Nếu có, đó là ưu tiên số một.
