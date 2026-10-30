# Thí nghiệm chi phí kernel: V-lite có chịu được không?

**Ngày chốt ba mục dưới đây: 2026-10-30.** Ba mục này (tiêu chí, dự đoán, ngày) được
viết **trước khi viết bất kỳ dòng Lean nào** của thí nghiệm và **không được sửa**
sau đó. Phần "Kết quả" ở cuối được thêm sau; không đụng vào ba mục này.

Bối cảnh: [situation-model.md](situation-model.md) §5 và §6 rủi ro 1 — chi phí kernel
của bảng tra (V-lite) so với bộ đọc là chiếu trường (thiết kế hiện tại) **chưa đo**.

## Mục 1 — Tiêu chí (cố định)

- Mã hóa **A** = thiết kế hiện tại (structure tình huống, bộ đọc là chiếu trường).
  Mã hóa **B** = V-lite (bảng atom `(tên, miền)`, tình huống là phép gán tra danh sách,
  mỗi nhóm ngưỡng là các dải có chú thích khoản luật). Hai mã hóa phải phủ **cùng tập
  điểm** và **cùng các norm**.
- Mỗi mã hóa chứng minh "không có xung đột trên toàn miền của cặp" bằng `decide`
  (kernel). Không `native_decide`, không `bv_decide`, không axiom mới.
- **V-lite bị BÁC BỎ** nếu: (i) tổng thời gian kernel dự đoán cho **B** trên cả 75 cặp
  của biến thể mặc định vượt **60 giây**, **hoặc** (ii) thời gian rõ ràng **siêu
  tuyến tính** theo số điểm (so sánh cặp (a) và cặp (b)).
- Ngược lại là **ĐƯỢC ỦNG HỘ**, bất kể tỉ lệ A/B.
- Tỉ lệ A/B vẫn được báo cáo, đặt cạnh dự đoán dưới đây.

## Mục 2 — Dự đoán số (cố định)

- Tỉ lệ chi phí mỗi điểm **B / A ≈ 4** (khoảng tin cậy chủ quan 2 đến 10).
- Thời gian kernel một cặp 1 536 điểm (cặp (a)): A ≈ 1 giây, B ≈ 4 giây.
- Tổng dự đoán cho **B** trên 75 cặp (Σ điểm ≈ 3,83 nghìn, scaling-analysis §1.3):
  **≈ 10 giây** (khoảng 3 đến 40 giây).
- Thời gian tăng gần tuyến tính theo số điểm (không siêu tuyến tính).

## Mục 3 — Ngày

2026-10-30.

---

# Kết quả (thêm sau; ba mục trên không bị sửa)

Mã, spec và số đo thô: [`eval/situation-model/`](../eval/situation-model/) (`gen.py` sinh các file
Lean; `time_runs.py` đo; `timings.csv` chứa **mọi** lượt chạy; README ghi cách chạy). Các file Lean là
file thử bỏ đi, chạy bằng `lake env lean`, **không** thuộc thư viện và không được `LexProof.lean`
import. Không sửa file có sẵn nào.

## 1. Hai cặp và nguồn của chúng trong luật

Cả hai cặp đều là cặp **cấm × cấm** trong biến thể mặc định (G1 a, G4 ngoại lệ, G7 mịn của
[scaling-analysis.md](scaling-analysis.md)); tôi không chọn giữa các biến thể đó. Act (`qc_o_noi`, `uong`)
lấy từ bảng act mục C của [slice1-notes.md](slice1-notes.md).

### Cặp (a): 12.3.c × 13.2 — 10,58 bit, 1 536 điểm (lớn nhất của lát cắt)

| Norm | Điều kiện | Ngoại lệ | Nguồn |
|---|---|---|---|
| **12.3.c** (cấm, `qc_o_noi`) | S24 ∧ ((S29 ∧ P11) ∨ S30) | S31 ∨ P13 | «Báo nói, báo hình ngay trước, trong và ngay sau chương trình dành cho trẻ em; trong thời gian từ 18 giờ đến 21 giờ hằng ngày, trừ trường hợp quảng cáo có sẵn trong các chương trình thể thao mua bản quyền tiếp sóng trực tiếp từ nước ngoài và trường hợp khác theo quy định của Chính phủ» (Điều 12 khoản 3 điểm c); loại *cấm* từ đoạn dẫn khoản 3 |
| **13.2** (cấm, `qc_o_noi`) | B13 ∧ S25, với B13 = (rượu ∧ 5,5 đến dưới 15) ∨ (bia ∧ từ 5,5) | S28 | Điều 13 đoạn dẫn: «rượu có độ cồn từ 5,5 độ đến dưới 15 độ và bia có độ cồn từ 5,5 độ trở lên»; khoản 2: «Trên các phương tiện quảng cáo ngoài trời, trừ biển hiệu của cơ sở kinh doanh rượu, bia» |

| Atom | Miền | Khoản |
|---|---|---|
| S01 loại đồ uống | enum 2: rượu · bia | Điều 2 khoản 1–2; Điều 13 đoạn dẫn |
| S02 dải độ cồn | enum 3: dưới 5,5 · từ 5,5 đến dưới 15 · từ 15 trở lên | Điều 13 đoạn dẫn (5,5; 15); Điều 12 (dưới 5,5); Điều 5 khoản 7 (từ 15) |
| S24 báo nói/báo hình | Bool | 12.3.c |
| S25 phương tiện ngoài trời | Bool | 13.2 |
| S28 biển hiệu của cơ sở kinh doanh rượu, bia | Bool | 13.2 (ngoại lệ) |
| S29 ngay trước/trong/sau chương trình dành cho trẻ em | Bool | 12.3.c |
| S30 trong khung 18–21 giờ | Bool | 12.3.c |
| S31 quảng cáo có sẵn trong chương trình thể thao tiếp sóng từ nước ngoài | Bool | 12.3.c (ngoại lệ) |
| P11 chương trình "dành cho" trẻ em | tham số Bool | 12.3.c (khái niệm mở) |
| P13 "trường hợp khác theo quy định của Chính phủ" | tham số Bool | 12.3.c (khe ủy quyền) |

2 × 3 × 2⁶ = 384 tình huống × 2² tham số = **1 536 điểm**. Khớp với mô hình Python.

### Cặp (b): 5.5 × 10.6 — 7 bit, 128 điểm (chọn là cặp lớn nhất của act `uong`)

| Norm | Điều kiện | Ngoại lệ | Nguồn |
|---|---|---|---|
| **5.5** (cấm, `uong`) | S06 ∧ (S07 ∈ {trong giờ, nghỉ giữa giờ} ∨ (S07 = ngay trước ∧ P01)) | — | «… uống rượu, bia ngay trước, trong giờ làm việc, học tập và nghỉ giữa giờ làm việc, học tập» (Điều 5 khoản 5); loại *cấm* qua tiêu đề |
| **10.6** (cấm, `uong`) | S19 ∧ S22 | S20 | «Nơi làm việc của cơ quan nhà nước, … trong thời gian làm việc, trừ địa điểm được phép kinh doanh rượu, bia» (Điều 10 khoản 6) |

Atom: S06 (Bool), S07 (enum 4: ngay trước · trong giờ · nghỉ giữa giờ · ngoài), S19, S20, S22 (Bool),
P01 (tham số Bool "ngay trước"). 2 × 4 × 2³ × 2 = **128 điểm**.

### Những chỗ là **giả định của tôi** (không phải điều luật nói)

1. **"và" đọc là "hoặc"** ở "ngay trước, trong **và** ngay sau" (12.3.c) và "ngay trước, trong giờ … **và** nghỉ
   giữa giờ" (5.5); ở 12.3.c tôi gộp ba thời điểm vào một fact S29. Chữ viết là "và"
   (slice1-notes, ô (13) của hai khoản).
2. **Hai nhánh của 12.3.c nối bằng ∨**, và **ngoại lệ gắn vào cả hai nhánh** (không chỉ nhánh 18–21 giờ);
   "và trường hợp khác" trong ngoại lệ cũng đọc là ∨ (S31 ∨ P13). Slice1-notes 12.3.c (13)(a).
3. **P11 chỉ gắn với nhánh S29**, không với S30.
4. **Biên 21 giờ** không rõ; S30 là Bool, không mã hóa biên (slice1-notes 12.3.c (9)).
5. **13.2 chỉ mang điều kiện dải + S25**; việc Điều 13 "kéo" Điều 12 vào qua đoạn dẫn không nằm trong cặp
   này (đó là norm 13.0 riêng).
6. **Không có ràng buộc toàn vẹn** (`valid` mặc định): miền là tích các miền atom hai norm đọc. Các IC1–IC3 của
   tôi có chạm vào S24, S25, S28, S29, S31 nhưng chúng là đề xuất chưa duyệt nên không đưa vào.
7. Atom S02 có dải "dưới 5,5" chỉ để S02 đúng là enum 3; không norm nào của cặp (a) đọc dải đó.

## 2. Hai mã hóa

- **A (hiện tại)**: `structure Sit` mỗi atom một trường (enum là `inductive`), `structure Params`, hai instance
  `Finite` viết bằng `flatMap` lồng nhau, bộ đọc là `fun s => s.fS24`, `fun s => s.fS02 == .v1`, …
- **B (V-lite)**: một **bảng atom** `(tên + nhãn miền, các dải, khoản nguồn)`; kiểu tình huống `Val doms`
  là một danh sách chỉ số giá trị kèm bằng chứng `legal`; **một instance `Finite` chung** (`allVals`,
  `mem_allVals`, `List.attach`); bộ đọc là `s.vs.getD i 0 == v`. Mỗi dải của S01/S02/S07 mang nhãn và khoản
  nguồn trong bảng.
- Cả hai dùng **cùng danh sách bộ đọc (cùng thứ tự, cùng chỉ số), cùng cây `Cond`, cùng norm**; chỉ khác kiểu.
  Kiểm tra tương đương (`#eval`, `*_check.lean`): hai mã hóa cho **cùng** số tình huống/tham số/điểm, cùng số điểm
  mà từng norm áp dụng, cùng số điểm mà cả hai áp dụng, và **0** điểm không đánh giá được:

  | Cặp | Điểm | 1 norm áp dụng | Cả hai áp dụng | Không đánh giá được |
  |---|---|---|---|---|
  | (a) | 1 536 (384 × 4) | 12.3.c: 120 · 13.2: 192 | 15 | 0 |
  | (b) | 128 (64 × 2) | 5.5: 40 · 10.6: 16 | 5 | 0 |

  A và B trùng từng con số. Việc có điểm cả hai norm cùng áp dụng cho thấy phép đo không rỗng.

## 3. Khẳng định chứng minh bằng `decide` và axiom

`theorem search : (analyze atoms catalog norms).isConsistentOn = true := by decide +kernel`, kèm hệ quả
`strong : ∀ n₁ ∈ norms, ∀ n₂ ∈ norms, ∀ π s, atoms.valid π s = true → ¬ Conflict atoms n₁ n₂ π s`
(qua `not_conflict_of_consistentOn`) và, riêng một lượt, `analyze … = .consistentOn (scopeOf …) (auditOf …)`
như `Smoke.lean`. Chạy qua **`analyze`** thật (có validator), không qua vị từ rẻ.

- **Không dùng `set_option` nào.** `decide` thường (không `+kernel`) chạy được cặp (b) ở cả A và B
  (1,8 giây, không option), nhưng **thất bại ở cặp (a)** với "maximum recursion depth has been reached" ở cả A
  lẫn B (không thử nâng `maxRecDepth`). Vì thế mọi số đo dùng `decide +kernel` (kernel tự tính, không
  `Lean.ofReduceBool`).
- `#print axioms search`, `strong`, `full`, ở **cả A lẫn B, cả hai cặp**:
  `[propext, Classical.choice, Quot.sound]`, tức nằm trong whitelist. Không `sorry`, `native_decide`, `bv_decide`.
- **Lưu ý trung thực**: cả hai cặp là cấm × cấm, nên "không xung đột" đúng ngay theo `Incompatible` — khẳng định
  đúng một cách tầm thường về mặt pháp lý. Chi phí vẫn thật vì `Internal.conflictsAt` xét `act`, rồi `applies` của
  norm thứ nhất (và của norm thứ hai khi norm thứ nhất áp dụng) **trước** khi xét modality, và vì `cands` lập
  toàn bộ tích. Cặp đối nghịch thật sẽ tốn cùng công đánh giá cộng một so sánh modality.

## 4. Số đo

Máy: Windows 11, một máy, `lake env lean <file>`. **Wall-clock lạnh mỗi lượt** (mỗi lượt là một tiến trình mới;
ba lượt mỗi file; bảng dưới là **trung vị**, "ròng" = trừ trung vị của `baseline.lean` = **0,70 giây**, thời
gian nạp thư viện). Đây là file chỉ chứa **một** khẳng định (`*_one.lean`). Mọi lượt thô nằm trong `timings.csv`.

| Cặp | Điểm | A (giây, ròng) | B (giây, ròng) | B/A | ms/điểm A | ms/điểm B |
|---|---|---|---|---|---|---|
| (b) | 128 | 0,40 | 0,44 | 1,10 | 3,1 | 3,4 |
| (b)+1 atom | 256 | 0,68 | 0,74 | 1,09 | 2,7 | 2,9 |
| (b)+2 atom | 512 | 1,24 | 1,31 | 1,06 | 2,4 | 2,6 |
| **(a)** | **1 536** | 4,71 | 4,90 | 1,04 | 3,1 | 3,2 |
| (a)+1 atom | 3 072 | 9,74 | 10,92 | 1,12 | 3,2 | 3,6 |
| (a)+2 atom | 6 144 | 19,76 | 21,23 | 1,07 | 3,2 | 3,5 |

("+k atom" = thêm k atom Bool mà không norm nào đọc, nhân số điểm lên 2^k; dùng để kiểm tuyến tính.)

Phân tách bằng `set_option profiler true` (một lượt, cặp (a), `*_one_prof.lean`): **kernel type checking
4,45 giây (A) và 4,74 giây (B)**; phần còn lại của thời gian ròng (khoảng 0,25 giây) là elaboration các
structure, instance và bảng. Tỉ lệ kernel B/A = **1,07**, khớp tỉ lệ wall-clock.

Lần đo đầu (hai khẳng định trong file: `search` cộng hệ quả `strong`) cho gần gấp đôi: A 10,7 và B 9,4 giây
ròng ở cặp (a), có vẻ vì chứng minh `strong` kích hoạt thêm một lượt kernel (cơ chế chưa kiểm). Không dùng cho bảng trên. Dãy đó
còn có 12 288 điểm: A 83,5 giây, B 86,6 giây ròng. Một lượt A (A_a_x1, lượt 3) mất 67,7 giây thay vì 18,2 giây
— nhiễu của máy; trung vị loại nó, nó vẫn nằm trong `timings.csv`.

### Tuyến tính?

- Trong một cặp, thời gian ròng tăng **×1,94 đến ×2,23 mỗi lần nhân đôi số điểm**. Số mũ ước từ 1 536 đến 6 144
  điểm: **A ≈ 1,04, B ≈ 1,06** — tuyến tính, nghiêng nhẹ về phía siêu tuyến tính (≤ 6%), không "rõ ràng
  siêu tuyến tính".
- Giữa hai cặp: chi phí mỗi điểm **không đồng nhất** — khoảng 2,2–2,3 ms/điểm ở cặp (b) (độ dốc từ 128 đến 512)
  so với 3,3–3,5 ms/điểm ở cặp (a). Cặp (a) có 10 atom và norm lớn hơn, cặp (b) có 6 atom. Nên "tuyến tính theo số
  điểm" đúng trong từng cặp, nhưng hệ số phụ thuộc kích thước norm và số atom (khoảng ×1,5 giữa hai cặp này;
  hai điểm dữ liệu không đủ để nói hàm của số atom là gì).
- Hằng số cố định mỗi cặp ≈ 0,12–0,15 giây (giao điểm trục tung của độ dốc ở cặp (b)).

## 5. Ngoại suy sang cả 75 cặp (biến thể mặc định)

Từ eval/scaling: 75 cặp cùng act, **Σ điểm = 3 832**, cặp lớn nhất 1 536 điểm, cặp lớn thứ nhì 768 điểm; số atom
trung bình theo trọng số điểm ≈ 7,9 (nằm giữa cặp (b), 6 atom, và cặp (a), 10 atom).

**Giả định** (chưa kiểm hết): (i) mỗi cặp là **một module riêng** kiểm bằng `analyze` hiện có trên miền của
chính nó (miền = tích các atom hai norm đọc) — chính là "lối đi thứ hai" ở scaling-analysis 4.1, không phải bộ
kiểm chiếu A4/A5; (ii) chi phí mỗi điểm nằm giữa độ dốc cặp (b) (cận dưới) và độ dốc cặp (a) (cận trên) — (a) là
cặp có norm lớn nhất lát cắt nên là cận trên hợp lý nhưng chưa được kiểm trên cặp thứ ba; (iii) cộng 75 hằng số
mỗi cặp; (iv) một khẳng định mỗi cặp. Công thức: T = 75 × c₀ + 3 832 × c₁.

| | c₀ (giây) | c₁ (ms/điểm) | Tổng (giây) |
|---|---|---|---|
| **B**, cận dưới (độ dốc cặp (b)) | 0,15 | 2,3 | **≈ 20** |
| **B**, cận trên (độ dốc cặp (a)) | 0,15 | 3,54 | **≈ 25** |
| A, cận dưới | 0,12 | 2,2 | ≈ 17 |
| A, cận trên | 0,12 | 3,27 | ≈ 22 |
| B, cận trên, **không** tính hằng số mỗi cặp | 0 | 3,54 | ≈ 14 |
| B, cận trên, **có** hệ quả `strong` (thêm một lượt kernel mỗi cặp) | 0,15 | 7,1 | ≈ 38 |

Để B vượt ngưỡng 60 giây cần chi phí mỗi điểm khoảng **12,7 ms**, tức khoảng **3,6 lần** độ dốc đo được ở cặp
(a) (với c₀ = 0,15). Ngoại suy tuyến tính cho thấy B nằm cách ngưỡng ít nhất 1,6 lần ở trường hợp xấu nhất tôi đo
được (có hệ quả `strong`, cận trên), và 2,4 lần ở trường hợp một khẳng định.

## 6. Kết luận theo tiêu chí đã cố định

- Tiêu chí (i): tổng dự đoán cho **B** là khoảng **20–25 giây** (một khẳng định) và tối đa khoảng **38 giây**
  (kèm hệ quả) — **không vượt 60 giây**.
- Tiêu chí (ii): thời gian **không** rõ ràng siêu tuyến tính (số mũ ≈ 1,06; ×1,94–2,23 mỗi lần nhân đôi).
- Do đó, theo đúng các tiêu chí đã chốt: **V-lite được ỦNG HỘ** ở phạm vi này (hai cặp; mô-đun theo cặp;
  `analyze` hiện có).

Tỉ lệ B/A (kernel và wall-clock) đo được **≈ 1,07 (khoảng 1,04–1,12)**, so với dự đoán **≈ 4 (2 đến 10)**:
**dự đoán sai**. Chi phí của bảng tra hầu như không thấy được so với phần còn lại.

### Dự đoán đối chiếu với đo

| Dự đoán (Mục 2) | Đo | Nhận xét |
|---|---|---|
| B/A ≈ 4 (2–10) | ≈ 1,07 (1,04–1,12) | **Sai**, thấp hơn nhiều: bộ đọc không phải phần đắt |
| Cặp (a): A ≈ 1 giây, B ≈ 4 giây | A 5,4 giây (ròng 4,7), B 5,6 giây (ròng 4,9) | **Sai**: A đắt hơn dự đoán khoảng 5,4 lần, B khoảng 1,4 lần |
| Tổng B 75 cặp ≈ 10 giây (3–40) | ≈ 20–25 giây (14–38 tùy giả định) | Nằm **trong** khoảng, nhưng gấp đôi ước điểm giữa |
| Gần tuyến tính | Đúng (số mũ ≈ 1,06) | Đúng |

Lý do tỉ lệ A/B gần 1 mà tôi **chưa kiểm**: chi phí đo được (~3 ms/điểm) lớn hơn nhiều so với một phép tra danh sách
ngắn, nên khả năng cao nằm ở phần chung của hai mã hóa (`cands` lập toàn bộ tích cặp × tham số × tình huống rồi
lọc; `find?`; `isConflictAt`). Đó là suy đoán, chưa có thí nghiệm cô lập.

## 7. Điều tôi không xác minh được

- **Chỉ một máy, ba lượt, Windows**; có một lượt nhiễu 67 giây (đã ghi). Chưa chạy trên Linux/CI.
- **Chỉ hai cặp**, cả hai cấm × cấm, cả hai act nhỏ. Chi phí mỗi điểm khác nhau ×1,5 giữa hai cặp; ngoại suy sang
  73 cặp còn lại là nội suy giữa hai điểm, chưa kiểm trên cặp thứ ba (ví dụ cặp có nghĩa vụ × cấm, hay cặp 768 điểm).
- **Ngoại suy giả định mô-đun mỗi cặp** và `analyze` hiện có. Nó **không** đo bộ kiểm chiếu theo cặp (A4/A5), vốn
  không lập tích `cands` và có thể rẻ hơn mỗi điểm — hay đắt hơn do thêm bước nâng nhân chứng; chưa viết nên chưa đo.
- **Thí nghiệm đo bảng tra, không đo toàn bộ V-lite**: B ở đây là bảng + `Val` + instance `Finite` chung + bộ
  đọc tra danh sách. Tôi **không** chứng minh `card = tích` hay bổ đề nâng phép gán một phần (T4 của situation-model.md), không
  dựng IC, và `Scope` vẫn dùng `Finite.card` qua `enum` (khả thi ở 1 536 điểm, không ở 2^34).
- Chưa đo tình huống chung toàn tài liệu (2^33,6): thí nghiệm không nói gì về nó; ngưỡng 60 giây áp cho tổng của
  các cặp theo mô-đun.
- Thời gian ròng trừ baseline 0,70 giây (nạp thư viện); số "ròng" gồm cả elaboration (≈ 0,25 giây ở cặp (a)).
- `decide +kernel` thay `decide` thường vì thường thất bại ở cặp (a) do độ sâu đệ quy; nếu dự án muốn `decide`
  thường, cần `maxRecDepth` (chưa thử giá trị nào).
- Phép tương đương A–B kiểm bằng đếm điểm, không bằng chứng minh.
