# Phân tích quy mô cho lát cắt 1 — Luật 44/2019/QH14

> **Cập nhật 2026-10-30 — số đo quy mô.** Các số kiểu "2^12 ≈ 1 s … 2^16 ≈ 50 s" trong tài liệu này đến từ phép đo **đại diện** (`(List.range N).all`), thấp hơn chi phí thật khoảng 5–8 lần. Chi phí đo bằng `analyze` thật là **2,3 đến 3,5 ms mỗi điểm** (N8 trong [requirements.md](requirements.md), [situation-model-experiment.md](situation-model-experiment.md)). Phần còn lại của tài liệu giữ nguyên.

> ## ⚠ PHÂN TÍCH TRÊN GIẤY, DO AI SOẠN — CHƯA CHẠY GÌ TRONG LEAN
>
> Không có dòng Lean nào được viết hay đề xuất ở đây, và **chưa có bộ kiểm nào
> được chạy** trên các norm của lát cắt. Mọi con số đến từ một **mô hình tôi tự
> dựng bằng tay** (Phụ lục A) từ từ vựng đề xuất ở
> [`slice1-notes.md`](slice1-notes.md) (mục B1, B2, C). Mô hình là cách *tôi*
> đọc từng khoản, không phải luật. Các ước lượng công sức chứng minh đều ghi
> **"chưa kiểm"**.
>
> Tài liệu **không trả lời** G1, G4, G7, G12 của `slice1-notes.md`. Chỗ nào kết
> quả phụ thuộc vào chúng, tôi giữ **cả hai phương án**.

**Nguồn đã đọc (chỉ đọc)**: `CLAUDE.md`, `docs/slice1-notes.md`,
`docs/decisions/` (đặc biệt ADR-0003, 0006, 0009, 0010, 0020, 0021),
`LexProof/Core/Norm.lean`, `LexProof/Core/Finite.lean`,
`LexProof/Verify/Conflict.lean`, `LexProof/Verify/Validate.lean`.

## Các biến thể được giữ song song

| Quyết định | Phương án | Cách tôi mô hình hóa |
|---|---|---|
| **G1** — phạm vi Điều 12 | **a** | Các khoản của Điều 12 áp dụng cho **mọi** dải độ cồn; Điều 13 chỉ thêm lệnh cấm riêng |
| | **b** | Các khoản của Điều 12 chỉ áp dụng dải dưới 5,5 độ; Điều 13 **mở rộng** bằng cách **nhân bản** các khoản đó cho dải từ 5,5 độ (hậu tố `'`) |
| **G4** — ngoại lệ hay cho phép | **ngoại lệ** | Ngoại lệ "trừ …" nằm trong `exceptions` của chính norm cấm (10.6, 19.6, 12.3.c, 13.2) |
| | **cho phép** | Mỗi ngoại lệ được viết **thêm** thành một norm *cho phép* cùng act (hậu tố `P`), norm cấm mất ngoại lệ |
| **G7** — độ mịn của act | **mịn** | Đúng bảng act ở mục C của `slice1-notes.md` |
| | **thô** | Gộp "bán / cung cấp / khuyến mại / dùng làm quà / bán bằng máy" thành một act, và **mọi** act quảng cáo (trừ "Chính phủ quy định") thành một act |
| **G12** — một S chung hay nhiều mô-đun | một S chung · mô-đun theo chủ đề (uống / bán / khuyến mại / quảng cáo) · mô-đun theo act | Chỉ ảnh hưởng cột "thiết kế hiện tại" ở mục 1.5; **không** ảnh hưởng phép đo theo cặp |

Tám tổ hợp G1 × G4 × G7 đều được tính. **Biến thể trình bày chi tiết** (Phụ lục B)
là *(G1 a, ngoại lệ, mịn)* — đó là lựa chọn trình bày, **không phải** quyết định.

---

## 0. Tóm tắt kết quả

1. **Chiếu theo cặp đưa mọi cặp về dưới 2^12 điểm** (nhiều nhất **10,58 bit** ở biến thể
   chi tiết, **11,58 bit** ở biến thể tệ nhất), ở **cả tám** tổ hợp. Dư địa còn
   lại đến 2^14 là 3,4 bit, đến 2^16 là 5,4 bit.
2. **Thiết kế hiện tại không đạt được điều đó**, bất kể G12: một S chung cho
   2^46,6 điểm mỗi cặp; mô-đun theo chủ đề cho 2^15 (`uong`) và 2^18,6
   (`quang cao`) ở hai mô-đun lớn; mô-đun theo act cho 2^2,6 đến 2^15 với act
   mịn, 2^18,6 với act thô. Chỉ khoảng **18% đến 72%** số cặp cùng act lọt dưới
   2^14 tùy biến thể và tùy G12 (bảng ở mục 1.5).
3. **Tổng số điểm phải duyệt** theo cặp là 2^11,9 đến 2^15,7 (3,8 nghìn đến 54
   nghìn) so với 2^20,4 đến 2^26,7 của mô-đun và 2^56,5 đến 2^57,2 của một S chung.
4. `check` hiện tại duyệt **mọi cặp** của danh sách (946 đến 1 596 cặp), **không
   chỉ cặp cùng act**: lọc cặp theo act *trước* khi liệt kê miền đã là một
   thay đổi nhỏ có giá trị riêng (mục 2.6).
5. **Chi phí ngoài vòng tìm kiếm cũng tỷ lệ với toàn miền** (`scopeOf`,
   `coApplyPoint?`, `Finite.card`) và với S chung 2^33,6 phần tử thì **không thể
   dựng được cả danh sách `enum`** (mục 1.6). Đây là chướng ngại độc lập với
   việc chiếu.
6. Với bốn ràng buộc toàn vẹn tôi có thể biện minh từ chữ, **không cặp nào đổi
   kết quả** khi bỏ chúng. Khi tôi *giả định thêm* một ràng buộc "một quảng cáo
   chỉ nằm trên một phương tiện", việc **bỏ hẳn `valid` mờ** sinh thêm tới **14**
   cặp báo động giả trong 156, còn **chiếu từng ràng buộc** (đòi ràng buộc là
   cây cú pháp) khớp kết quả chính xác ở mọi ca thử.
7. **Kết quả kỳ vọng**: ở các biến thể **(ngoại lệ, mịn)** có **0** cặp đối
   nghịch modality, nên `analyze` sạch nhiều khả năng trả `consistentOn` —
   nhưng đó là kết quả **rỗng về xung đột modality**. Ở **(ngoại lệ, thô)** có
   **35 đến 42** cặp báo động giả; ở **(cho phép, mịn)** có **24 đến 27** cặp
   "chéo" cần người duyệt.
8. **Khuyến nghị** (độ tin cậy ở mục 4): lọc cặp theo act → (b) ràng buộc là cây
   cú pháp → (a) chiếu theo cặp; (c) làm hướng dẫn mô hình hóa ngay, chưa cần
   mã. Thí nghiệm nhỏ nhất: chứng minh bổ đề "chỉ phụ thuộc atom đã đọc", và
   chạy **một** cặp tệ nhất qua bộ kiểm hiện tại.

---

## 1. Đo trên giấy

### 1.1 Cách đo

Với mỗi biến thể:

1. **Dựng danh sách norm** (Phụ lục A) từ từ vựng B1, B2: mỗi khoản sinh một hay
   vài norm, mỗi norm có **tập fact/tham số mà điều kiện hoặc ngoại lệ đọc**.
2. **Tự kiểm bảng**: một script (không thuộc kho mã) chạy từng norm trên toàn bộ
   miền của chính nó và xác nhận (i) norm **không đọc** fact nào chưa khai báo,
   (ii) **mỗi fact khai báo thật sự ảnh hưởng** tới việc norm áp dụng hay không.
   Cả hai đều đạt ở cả bốn bảng norm (G1 × G4; G7 chỉ đổi cách gom act).
3. **Cặp** = hai norm **khác nhau, cùng chuỗi act** (đúng điều kiện `Conflict`
   đòi), tính một lần cho mỗi cặp không thứ tự. Norm có act đơn lẻ không thuộc
   cặp nào.
4. **F của cặp** = hợp tập fact/tham số mà một trong hai norm đọc. **Số bit** =
   Σ log₂(số giá trị) trên F (fact Bool = 1 bit, enum 3 giá trị = 1,585 bit, enum
   4 giá trị = 2 bit). **Miền** = tích số giá trị.
5. **Ràng buộc toàn vẹn chạm vào cặp** = các IC có chung fact với F. "**Bit nếu
   giữ IC**" = số bit của F cộng mọi fact của các IC đó (bao đóng bắc cầu).
6. **Cặp đối nghịch** (mục 3): modality khắc nhau theo bảng `Incompatible` hiện
   có. "Cùng áp dụng được" được kiểm **bằng cách duyệt hết miền của chính cặp
   đó** và tính `applies` của cả hai norm.

Fact và tham số **tính như nhau về bit** (mỗi cái nhân miền lên theo số giá trị
của nó), nên quyết định G6 (cái nào là S, cái nào là P) **không** đổi các con số
ở đây; nó chỉ đổi cách báo cáo.

### 1.2 Ràng buộc toàn vẹn dùng trong mô hình

Bốn IC này là **đề xuất của tôi**, rút từ chữ của từng khoản; **không có bản
duyệt**. Rất có thể còn thiếu.

| IC | Ràng buộc (đề xuất của tôi) | Fact | Lấy từ chữ nào |
|---|---|---|---|
| IC1 | S31 → S24 ∧ S27 | S24, S27, S31 | 12.3.c: quảng cáo có sẵn trong chương trình thể thao tiếp sóng thì nằm trên báo nói/báo hình và trong một chương trình thể thao |
| IC2 | S28 → S25 | S25, S28 | 13.2: biển hiệu là một phương tiện quảng cáo ngoài trời |
| IC3 | S29 → S24 | S24, S29 | 12.3.c: "ngay trước, trong và ngay sau chương trình" chỉ có nghĩa với phát sóng |
| IC4 | S06 ∧ S22 → S07 ∈ {trong giờ, nghỉ giữa giờ} | S06, S07, S22 | 5.5 và 10.6: người thuộc nhóm 5.5 đang trong thời gian làm việc thì thời điểm uống không thể là "ngoài giờ" |

Hai tập IC **giả định thêm** chỉ dùng cho phép thử độ nhạy ở mục 1.7 và 2.4:
`IC_B` (B15 → B55, chỉ cần khi ngưỡng độ cồn là hai Bool rời) và `ICX` ("một
quảng cáo nằm trên nhiều nhất một trong bốn phương tiện S23–S26"). **ICX là giả
định của tôi, không phải điều văn bản nói.**

### 1.3 Kết quả theo cặp

**Biểu đồ số cặp theo số bit, biến thể trình bày chi tiết** *(G1 a, ngoại lệ,
mịn)* — 44 norm, 75 cặp cùng act:

| Số bit của F | ≤ 12 | ≤ 14 | ≤ 16 | ≤ 20 | > 20 |
|---|---|---|---|---|---|
| Số cặp | **75** | 0 | 0 | 0 | 0 |
| … nếu giữ cả IC | **75** | 0 | 0 | 0 | 0 |

Cặp lớn nhất là **12.3.c × 13.2** (10,58 bit, 1 536 điểm). Cặp lớn thứ hai là
12.3.c × 13.1 (9,58 bit). Cả hai đều có 12.3.c — norm có nhiều điều kiện và một
ngoại lệ mở nhất lát cắt (6 bit một mình).

**Ma trận tám biến thể**:

| G1 | G4 | G7 | Norm | Cặp cùng act | Cặp `check` hiện tại duyệt | Chiếu theo cặp (≤12 / ≤14 / ≤16 / ≤20 / >20) | … khi giữ IC | Bit lớn nhất | Σ điểm (chiếu) |
|---|---|---|---|---|---|---|---|---|---|
| a | ngoại lệ | mịn | 44 | 75 | 946 | 75 / 0 / 0 / 0 / 0 | 75 / 0 / 0 / 0 / 0 | 10,58 | 3.83e+03 |
| a | ngoại lệ | thô | 44 | 180 | 946 | 180 / 0 / 0 / 0 / 0 | 180 / 0 / 0 / 0 / 0 | 10,58 | 6.81e+03 |
| a | cho phép | mịn | 48 | 104 | 1128 | 104 / 0 / 0 / 0 / 0 | 104 / 0 / 0 / 0 / 0 | 10,58 | 5.83e+03 |
| a | cho phép | thô | 48 | 228 | 1128 | 228 / 0 / 0 / 0 / 0 | 228 / 0 / 0 / 0 / 0 | 10,58 | 9.46e+03 |
| b | ngoại lệ | mịn | 52 | 112 | 1326 | 112 / 0 / 0 / 0 / 0 | 109 / 3 / 0 / 0 / 0 | 10,58 | 1.69e+04 |
| b | ngoại lệ | thô | 52 | 312 | 1326 | 312 / 0 / 0 / 0 / 0 | 306 / 6 / 0 / 0 / 0 | 11,58 | 4.19e+04 |
| b | cho phép | mịn | 57 | 161 | 1596 | 161 / 0 / 0 / 0 / 0 | 158 / 3 / 0 / 0 / 0 | 10,58 | 2.41e+04 |
| b | cho phép | thô | 57 | 399 | 1596 | 399 / 0 / 0 / 0 / 0 | 393 / 6 / 0 / 0 / 0 | 11,58 | 5.44e+04 |

Nhận xét:

- **Không biến thể nào có cặp trên 12 bit** khi chiếu. Khi giữ cả IC, tối đa 6
  cặp (trong biến thể G1 b) cần 12 đến 14 bit.
- G1 b làm tăng số cặp (112 đến 399) vì nhân bản norm của Điều 12; G7 "thô" làm
  tăng số cặp (180 đến 399) vì gộp act; G4 "cho phép" thêm 4 đến 5 norm.
- **Σ điểm** (cột cuối) là tổng chi phí liệt kê nếu *mọi* cặp được kiểm: từ
  3,8 nghìn đến 54 nghìn điểm.

**Tóm tắt theo act** (biến thể chi tiết):

| Act | Norm | Cặp | Bit nhỏ nhất | Trung vị | Bit lớn nhất | Cặp lớn nhất |
|---|---|---|---|---|---|---|
| `qc_o_noi` | 6 | 15 | 2,00 | 5,58 | 10,58 | 12.3c × 13.2 |
| `uong` | 9 | 36 | 2,00 | 3,00 | 7,00 | 5.5 × 10.6 |
| `qc_noi_dung_cam` | 2 | 1 | 5,00 | 5,00 | 5,00 | 12.2a × 12.2b |
| `ban` | 7 | 21 | 2,00 | 2,00 | 3,00 | 5.3a × 19.6 |
| `khuyen_mai` | 2 | 1 | 2,58 | 2,58 | 2,58 | 5.3c × 5.9a |
| `tuan_thu` | 2 | 1 | 2,58 | 2,58 | 2,58 | 12.1 × 13.0 |

### 1.4 Cách tôi biết số này không bị "gian lận"

Số nhỏ đến mức đáng ngờ, nên ghi rõ **vì sao nó nhỏ**: mỗi norm đọc rất ít fact
(trung vị **1 bit**, trung bình 1,65 bit; 25 trong 44 norm đọc không quá 1 bit; 7 norm
không đọc fact nào; nhiều nhất là 12.3.c với 6 bit), và hai norm chỉ chung vài fact. Bảng chiếu **không** nhỏ
vì tôi bỏ fact: bước tự kiểm ở 1.1 (ii) xác nhận mọi fact khai báo thật sự đổi
được kết quả `applies`. Điều có thể sai là **từ vựng** (xem 1.7), không phải
phép chiếu.

### 1.5 So với thiết kế hiện tại

`check` hiện tại (`Internal.check` trong `LexProof/Verify/Conflict.lean`) duyệt
**mọi cặp không thứ tự của cả danh sách**, và với mỗi cặp duyệt **toàn bộ** miền
`|P| × |S|` của S, P được truyền vào, rồi mới lọc theo act và `valid`
(`Internal.cands`). Chi phí do đó là `C(n,2) × |S| × |P|`, trong đó S, P là kiểu
của **mô-đun** — đúng nội dung G12.

**Các mô-đun theo chủ đề** (biến thể chi tiết):

| Mô-đun | Norm | Bit của S và P của mô-đun | Cặp mà `check` duyệt | Cặp cùng act |
|---|---|---|---|---|
| `M_uong` | 9 | 15,00 | 36 | 36 |
| `M_ban` | 7 | 8,00 | 21 | 21 |
| `M_km` | 2 | 2,58 | 1 | 1 |
| `M_qc` | 13 | 18,58 | 78 | 17 |

Cột "Cặp mà `check` duyệt" lớn hơn "Cặp cùng act" ở `M_qc` (78 so với 17): bộ
kiểm hiện tại **tốn công cho 61 cặp mà `Conflict` không bao giờ đúng**, vì khác
act.

**So sánh ba cách đặt S, tám biến thể** (số trong ô: số cặp cùng act rơi vào mỗi
mức bit của miền *của mô-đun chứa nó*, theo đúng thứ tự ≤12 / ≤14 / ≤16 / ≤20 / >20;
"2^x" là tổng điểm `check` phải duyệt):

| G1 | G4 | G7 | Một S chung (bit/cặp · cặp duyệt · tổng điểm) | Mô-đun theo chủ đề (biểu đồ trên cặp cùng act · tổng điểm) | Mô-đun theo act (biểu đồ · tổng điểm) | Chiếu theo cặp (tổng điểm) |
|---|---|---|---|---|---|---|
| a | ngoại lệ | mịn | 46,58 b · 946 · 2^56.5 | 22 / 0 / 36 / 17 / 0 · 2^24.9 | 24 / 15 / 36 / 0 / 0 · 2^20.4 | 2^11.9 |
| a | ngoại lệ | thô | 46,58 b · 946 · 2^56.5 | 66 / 0 / 36 / 78 / 0 · 2^24.9 | 66 / 0 / 36 / 78 / 0 · 2^24.9 | 2^12.7 |
| a | cho phép | mịn | 46,58 b · 1128 · 2^56.7 | 29 / 0 / 45 / 30 / 0 · 2^25.4 | 31 / 28 / 45 / 0 / 0 · 2^20.8 | 2^12.5 |
| a | cho phép | thô | 46,58 b · 1128 · 2^56.7 | 78 / 0 / 45 / 105 / 0 · 2^25.4 | 78 / 0 / 45 / 105 / 0 · 2^25.4 | 2^13.2 |
| b | ngoại lệ | mịn | 46,58 b · 1326 · 2^57.0 | 22 / 0 / 36 / 54 / 0 · 2^26.3 | 31 / 45 / 36 / 0 / 0 · 2^20.7 | 2^14.0 |
| b | ngoại lệ | thô | 46,58 b · 1326 · 2^57.0 | 66 / 0 / 36 / 210 / 0 · 2^26.3 | 66 / 0 / 36 / 210 / 0 · 2^26.3 | 2^15.4 |
| b | cho phép | mịn | 46,58 b · 1596 · 2^57.2 | 29 / 0 / 45 / 87 / 0 · 2^26.7 | 38 / 78 / 45 / 0 / 0 · 2^21.2 | 2^14.6 |
| b | cho phép | thô | 46,58 b · 1596 · 2^57.2 | 78 / 0 / 45 / 276 / 0 · 2^26.7 | 78 / 0 / 45 / 276 / 0 · 2^26.7 | 2^15.7 |

Đọc bảng:

- **Một S chung**: 46,58 bit mỗi cặp — mọi cặp ở mức > 20. Không dùng được.
- **Mô-đun theo chủ đề**: chỉ **18% đến 37%** số cặp cùng act lọt dưới 2^14; mô-đun
  quảng cáo (18,58 bit) vượt ngưỡng 2^18 đã đo là thất bại (bằng vị từ rẻ,
  **chưa** bằng `check`).
- **Mô-đun theo act**: **52% đến 72%** lọt dưới 2^14 với act mịn, nhưng chỉ **20% đến
  37%** với act thô (khi đó mô-đun theo act trùng mô-đun theo chủ đề). Mô-đun `uong`
  luôn 15 bit cho cả 36 hoặc 45 cặp (≈ 1,2 đến 1,5 triệu điểm).
- **Chiếu theo cặp**: **100%**, tổng 2^11,9 đến 2^15,7.

**Trả lời "phần lớn cặp có dưới 2^14 không?"**: theo cặp thì **có, tất cả**
(tối đa 2^11,6). Theo thiết kế hiện tại thì **không** trong phần lớn các tổ hợp
G12 × G1 × G7 (chỉ có mô-đun theo act với G7 mịn cho 52% đến 72%). Về **tổng**:
trần kế hoạch 2^14 (N8) đạt ở bốn trong tám biến thể (các biến thể G1 a), vượt nhẹ
ở bốn biến thể G1 b (2^14,0 đến 2^15,7, vẫn dưới mức 2^16 đã đo ≈ 50 giây cho
một vị từ rẻ).

### 1.6 Chi phí nằm ngoài vòng tìm kiếm

Đây là phát hiện từ đọc code, **chưa đo**:

| Chỗ | Làm gì | Chi phí |
|---|---|---|
| `Finite.card` (`Core/Finite.lean`) | Độ dài của `enum` | Phải **dựng danh sách `enum` của S**. Với S chung, 12 884 901 888 phần tử: không thể |
| `validPoints` | Danh sách mọi cặp `(π, s)` | `\|S\| × \|P\|` phần tử |
| `validExcludedOf`, `excludedPoints` | Đếm hoặc liệt kê điểm bị `valid` loại | quét hết `validPoints` |
| `scopeOf` | Điền `validExcluded`, `validTotal`, `situations`, `params` | các lần quét trên, **một lần mỗi kết quả** |
| `coApplyPoint?` (qua `resolutionOf?`, `auditOf`) | Tìm điểm cả hai norm cùng áp dụng | quét `validPoints` **cho mỗi cặp cùng act có modality khắc nhau** |
| `Internal.cands` | Sinh danh sách ứng viên | tích đầy đủ rồi mới lọc: **bộ nhớ tỷ lệ với số điểm**, không chỉ thời gian |

Hệ quả: **chiếu theo cặp một mình không cứu được `Scope`**. `Scope.situations`,
`params`, `validExcluded`, `validTotal` và `Audit.resolutions` hiện đều cần quét
toàn miền; nếu giữ nguyên thì báo cáo đắt bằng chính phép kiểm mà ta vừa rút
gọn. Điều này tác động vào các định lý (d) (`scopeOf_spec`, `analyze_scope`) và
D23 (`resolution_has_witness`) — xem 2.1.

### 1.7 Nơi tôi có thể sai

1. **Từ vựng**. Nếu người duyệt thêm fact cho một norm, bit của cặp tăng đúng
   bằng số bit thêm. Dư địa của cặp tệ nhất (10,58 bit): thêm **3 Bool** vẫn dưới 2^14,
   thêm **4** thì vượt; thêm **5** vẫn dưới 2^16, thêm **6** thì vượt.
2. **Cách đọc điều kiện**. Ví dụ 12.3.c: tôi đọc ngoại lệ gắn vào cả hai nhánh;
   nếu chỉ gắn vào nhánh "18 giờ đến 21 giờ" thì F không đổi nhưng
   `applies` đổi. Các ambiguity ở `slice1-notes.md` mục "đa nghĩa" đều có thể
   đổi F.
3. **Bốn IC có thể thiếu**. Phép thử ICX ở dưới cho thấy một IC *khả dĩ* thay
   đổi tới 14 trong 156 cặp đối nghịch; người duyệt có thể biết nhiều hơn tôi.
4. **Mọi cặp được tính độc lập**. Đo theo cặp bỏ qua chi phí của phần còn lại
   của báo cáo (1.6).
5. **Tôi chưa chạy bộ kiểm**. Số liệu 2^12 ≈ 1 giây … 2^16 ≈ 50 giây đo bằng
   `(List.range N).all`; một điểm của `check` thật còn phải tính `applies` của
   hai norm (`Cond.eval` trả `Option`, tra bảng theo chỉ số) nên **có thể đắt hơn
   nhiều lần** — chưa kiểm.
6. **Số norm** phụ thuộc cách tách khoản thành norm (ví dụ 5.3 thành 3 norm). Tôi
   đã chọn tách theo từng động từ liệt kê.

**Phép thử độ nhạy 1 — ngưỡng độ cồn là hai Bool rời thay vì một enum** (đối
tượng của (c); `valid` mờ nghĩa là không có `IC_B`):

| G1 | G4 | G7 | Đối nghịch | Chính xác | Bỏ mọi IC (`valid` mờ) | Cặp giả | Bit lớn nhất (Bool rời) | Bit lớn nhất (enum) |
|---|---|---|---|---|---|---|---|---|
| a | ngoại lệ | thô | 36 | 35 | 35 | 0 | 11,00 | 10,58 |
| a | cho phép | mịn | 28 | 28 | 28 | 0 | 11,00 | 10,58 |
| a | cho phép | thô | 75 | 73 | 73 | 0 | 11,00 | 10,58 |
| b | ngoại lệ | thô | 90 | 42 | 45 | 3 | 12,00 | 11,58 |
| b | cho phép | mịn | 46 | 32 | 32 | 0 | 11,00 | 10,58 |
| b | cho phép | thô | 156 | 85 | 89 | 4 | 12,00 | 11,58 |

Số bit chỉ tăng **0,42** (11,00 so với 10,58). Nhưng khi `valid` bị bỏ, bộ kiểm
thấy cả "B15 đúng và B55 sai", nên **3 đến 4 cặp** co-applicable giả xuất hiện
(ví dụ 5.7 × 12.1, 5.7 × 12.4, 5.7 × 12.5 ở G1 b thô). Enum không có vấn đề này.

**Phép thử độ nhạy 2 — thêm ràng buộc ICX** (giả định của tôi), bốn cách đối xử
với `valid`:

| G1 | G4 | G7 | Đối nghịch | Chính xác (giữ IC + hoàn tất) | Chiếu từng IC (∃ ngoài F) | Bỏ IC không nằm hẳn trong F | Bỏ mọi IC (`valid` mờ) |
|---|---|---|---|---|---|---|---|
| a | ngoại lệ | thô | 36 | 31 | 31 | 35 | 35 |
| a | cho phép | mịn | 28 | 23 | 23 | 28 | 28 |
| a | cho phép | thô | 75 | 64 | 64 | 73 | 73 |
| b | ngoại lệ | thô | 90 | 35 | 35 | 42 | 42 |
| b | cho phép | mịn | 46 | 25 | 25 | 32 | 32 |
| b | cho phép | thô | 156 | 71 | 71 | 85 | 85 |

- **Chính xác**: giữ nguyên mọi IC, hoàn tất bằng cách duyệt cả các fact ngoài F.
- **Chiếu từng IC**: mỗi IC được ép dưới dạng "tồn tại giá trị cho fact ngoài F
  để IC thỏa". **Khớp "chính xác" ở mọi ca thử.** Cần biết IC đọc những fact nào.
- **Bỏ IC không nằm hẳn trong F** và **bỏ mọi IC (`valid` mờ)**: báo động giả
  thêm 4 đến 14 cặp.

Giới hạn: "khớp ở mọi ca thử" đúng cho **các IC tôi đã đưa ra** (phép kéo theo và
"nhiều nhất một"), không phải định lý. Với ràng buộc kiểu khác, hợp các phép
chiếu từng IC chỉ là xấp xỉ **trên** của chiếu cả hội (vẫn an toàn, kém chính xác).

---

## 2. Đánh giá thiết kế (trên giấy)

### 2.0 Hiện trạng cần nhớ

- `Atoms` có `sit`, `param` (bảng đọc Bool từ S, P) và `valid : P → S → Bool` — một
  **hàm mờ**. `Cond` đọc atom theo chỉ số.
- `Conflict A n₁ n₂ π s` đòi: cùng act, cả hai `applies`, modality khắc nhau,
  `resolved = false`. **Chỉ hai vế `applies` phụ thuộc `(π, s)`**, và mỗi vế chỉ
  qua các atom mà điều kiện/ngoại lệ của norm đó nhắc tới. Đây là cơ sở của (a).
- Định lý (b) hiện tại: `consistentOn` ⇒ với mọi cặp, mọi `(π, s)` **valid**,
  không `Conflict`. Chứng minh dùng `Finite.complete` (qua `mem_cands`).

**Bốn điều kiện mọi thay đổi phải giữ**: (I1) `consistentOn` chỉ nói về norm đã
mã hóa; (I2) mọi `conflict` có một điểm cụ thể mà kernel kiểm được; (I3) axiom
trong whitelist, không `native_decide`; (I4) không bỏ im lặng cặp nào.

### 2.1 (a) Chiếu theo cặp lên fact mà hai norm đọc

**Ý tưởng** (không phải mã): với mỗi cặp cùng act có modality khắc nhau, chỉ
liệt kê các **giá trị của tập F** (không liệt kê S, P đầy đủ), kiểm xem có giá
trị nào làm cả hai norm cùng áp dụng. Các ràng buộc toàn vẹn **bị bỏ hoặc được
chiếu theo hướng an toàn** (đủ rộng, không bao giờ hẹp hơn thật).

**Cần chứng minh** (mỗi dòng là một mảnh; số dòng là **ước lượng, chưa kiểm**):

| # | Mảnh | Dòng ước lượng |
|---|---|---|
| A1 | **Bổ đề "chỉ phụ thuộc atom đã đọc"**: `Cond.eval` (và `evalAny`, `applies`, rồi `Conflict`) cho cùng kết quả ở hai điểm cùng giá trị trên các atom điều kiện nhắc tới. Cần một cách liệt kê atom của một `Cond` | 100 đến 120 |
| A2 | Một **cách biểu diễn "gán trị cho tập atom"** và bộ đánh giá điều kiện trên gán trị, kèm bổ đề: đánh giá trên gán trị rút từ điểm thật bằng đánh giá trực tiếp | 70 đến 100 |
| A3 | **Liệt kê đầy đủ mọi gán trị** trên tập atom (như `forall_of_all` nhưng cho gán trị) | 60 đến 90 |
| A4 | **Bộ kiểm theo cặp** và định lý chính (b′): không cặp nào có gán trị làm cả hai norm áp dụng ⇒ không `Conflict` ở bất kỳ điểm nào | 100 đến 150 |
| A5 | **Nâng nhân chứng** thành điểm cụ thể (mục "extra check" bên dưới); hình dạng `Result` mới; đối chiếu `conflict_of_witness` (a)+(c) | 70 đến 100 |
| A6 | Giữ (e): nhãn `.conflict` ("mọi `π` valid ở tình huống đó") cần duyệt cả `P` **tại điểm đã nâng**, không phải tại gán trị | 20 đến 50 |
| A7 | `scopeOf` và `Audit.resolutions` **không dùng `Finite S`** (xem 1.6): đếm bằng phép nhân thay vì `enum.length`, `coApplyPoint?` viết lại trên gán trị. Đây là chỗ tác động đến (d) và D23 | 120 đến 200 |
| A8 | Phát biểu lại (a)–(f) cho `Result` mới | 120 đến 180 |
| A9 | Cập nhật `Smoke`, `Tests` | 50 đến 80 |
| | **Tổng** | **≈ 710 đến 1 070** |

A7 là mảnh dễ bị đánh giá thấp nhất (nó chạm vào định lý (d) và D23, không chỉ vào
bộ tìm kiếm). Tất cả các con số **chưa kiểm**.

**`consistentOn` có còn đúng không?** Có, **với điều kiện** phép chiếu là xấp xỉ
**trên**: nó liệt kê *mọi* gán trị của F (A3) và chỉ **bỏ hoặc nới** ràng buộc,
không bao giờ siết. Khi đó, nếu mọi gán trị đều không làm cả hai norm áp dụng thì
càng không có điểm thật nào làm vậy. Hai hệ quả:

- (b′) **mạnh hơn** (b): nó đúng ở *mọi* điểm, không cần giả thiết `valid`, nếu
  bỏ hẳn IC. `consistentOn` khi đó **không còn phụ thuộc vào `valid`**.
- Nhưng nó **kém chính xác**: một cặp chỉ xung đột ở gán trị *vi phạm* IC sẽ bị
  báo ứng viên. Đo ở 1.7: 0 cặp với bốn IC của tôi; 4 đến 14 cặp với ICX nếu bỏ
  hẳn IC; 0 nếu chiếu từng IC.

Cách an toàn là coi một ứng viên chưa nâng được là **`unknown`**, không phải
`consistentOn` (fail-closed).

**Nhân chứng cần kiểm thêm gì để là xung đột thật?** (1) một **điểm đầy đủ**
`(π, s)` thực hiện gán trị đó; (2) `valid π s = true`; (3) `Conflict` đúng tại
điểm đó — ba điều này kernel kiểm được **bằng một lần tính ở một điểm**. Việc
**tìm** điểm là không tin cậy (hợp với ADR-0020), nhưng nó đòi hỏi **dựng được
`s` từ giá trị của các fact**: điều đó chỉ tự nhiên khi S là **tích các trường
độc lập**. Nếu các atom là hàm tùy ý của S thì không có cách dựng tổng quát ngoài
quét `enum S` — đúng thứ ta muốn tránh.

**Trust base**: không thêm định nghĩa nào cần tin nếu A1 đến A8 được chứng minh.
Thêm một **quy ước** (S là tích các trường) cho `Laws`. `valid` vẫn nằm trong
trust base nhưng **chỉ ở bước nâng nhân chứng và bước loại ứng viên**, không còn
ở chính khẳng định `consistentOn` — nếu chọn bỏ hẳn IC.

### 2.2 (b) `valid` thành danh sách ràng buộc dạng cây `Cond`

**Ý tưởng**: thay hàm mờ bằng một **danh sách** ràng buộc, mỗi cái là một cây
cú pháp với danh sách atom riêng; "điểm valid" nghĩa là mọi ràng buộc đúng.

**Cần chứng minh** (chưa kiểm):

| # | Mảnh | Dòng ước lượng |
|---|---|---|
| B1 | Định nghĩa `valid` từ danh sách; bổ đề `valid π s = true ↔ mọi ràng buộc đúng` | 15 đến 30 |
| B2 | Thêm vào validator: chỉ số atom trong ràng buộc phải hợp lệ; chứng minh `eval` không trả `none` sau validator (tái dùng `Cond.eval_isSome_of_wf`) | 40 đến 70 |
| B3 | Đổi các nơi dựng `Atoms` (`Smoke`, `Tests`) | 20 đến 40 |
| B4 | Hiển thị danh sách ràng buộc trong báo cáo thay cho (hoặc ngoài) con số `validExcluded` | 15 đến 30 |
| | **Lõi** | **≈ 90 đến 170** |
| B5 | *(tùy chọn)* đếm điểm bị loại **không cần liệt kê**, bằng cách tách các ràng buộc thành thành phần liên thông qua atom chung và nhân số đếm | 200 đến 350 |

Các định lý (a)–(f) hiện nay đều phát biểu qua `A.valid π s = true`, nên **giữ
nguyên** nếu `valid` vẫn là một hàm dẫn xuất từ danh sách. Đó là lý do công sức
lõi nhỏ.

**`consistentOn` giữ nguyên** (không đổi phát biểu). **Nhân chứng**: không cần
kiểm thêm gì ngoài hiện tại.

**Trust base** — thay đổi có nghĩa: `valid` từ "**bất kỳ hàm Bool nào**" thành "**một
danh sách hữu hạn các công thức đọc được, in ra được, có kiểm hợp lệ chỉ số**".
Người duyệt **đọc từng dòng** ràng buộc thay vì phải tin một hàm; báo cáo có thể
**liệt kê ràng buộc nào đã loại một ứng viên**. Điều còn lại: **bộ đọc** (`S →
Bool`) vẫn được tin; và một danh sách ràng buộc **quá mạnh vẫn che xung đột thật**
(ADR-0021) — chỉ là nay nhìn thấy được. Kernel **không** kiểm ràng buộc có đúng
với thực tế không.

Điều (b) **mở khóa** cho (a): chiếu từng IC (1.7) cần biết IC đọc fact nào, và
điều đó chỉ có khi IC là cây cú pháp có danh sách atom.

### 2.3 (c) Nhóm ngưỡng thành enum với dải rời nhau

**Ý tưởng**: một trường enum cho mỗi nhóm ngưỡng (độ cồn, tuổi, giờ) thay vì
nhiều Bool.

**Cần chứng minh**: **không có gì** về tính đúng — đây là cách khai báo S của
mô-đun `Laws`, dùng kiểu hiện có. Loại trừ nhau và phủ kín **đúng theo cấu
trúc** (hàm tạo của một kiểu quy nạp rời nhau), không cần ràng buộc.

**Đo ở lát cắt này** (mục 1.7, phép thử 1):

- **Độ cồn**: enum 3 dải thay hai Bool: tiết kiệm **0,42 bit** mỗi cặp đọc dải;
  tránh **một IC** (B15 → B55); và tránh **3 đến 4 cặp co-applicable giả** khi
  `valid` mờ bị bỏ.
- **Tuổi**: mỗi vai chỉ có **một** ngưỡng (18), enum hai giá trị = Bool → **không
  thay đổi gì**. "Trẻ em", "thanh niên" không có ngưỡng trong văn bản.
- **Giờ**: S07 đã là enum 4 dải; S29 và S30 là **hai chiều khác nhau** (so với
  chương trình, so với giờ đồng hồ), không phải một nhóm ngưỡng.

Nghĩa là trong từ vựng đã đề xuất, **(c) đã được áp dụng** ở chỗ có ích (S02,
S07). Giá trị còn lại của (c) là **khi (a) được dùng**: nếu phép chiếu liệt kê
**atom Bool** thì các atom suy từ cùng một trường enum sẽ được liệt kê như độc
lập → thêm gán trị không thể xảy ra. **An toàn** (xấp xỉ trên) nhưng **kém chính
xác**, trừ khi (i) phép chiếu **biết "trường"** (thêm khoảng 100 đến 200 dòng,
chưa kiểm) hoặc (ii) có ràng buộc "đúng một" (rẻ nếu đã có (b)).

**Trust base**: bớt ràng buộc cần tin; **vẫn tin** biên của dải (≥ hay >), và việc
rượu/bia loại trừ nhau.

### 2.4 Nếu `valid` vẫn là hàm mờ, (a) hỏng ở đâu

1. **Không chiếu được `valid`**: không biết nó đọc fact nào → buộc phải **bỏ hẳn**.
   Đo: tới **14** cặp báo động giả trong 156 (ICX) và 3 đến 4 cặp khi ngưỡng là
   Bool rời. Với bốn IC chắc chắn của tôi thì **0**.
2. **Không có bổ đề phụ thuộc cục bộ cho `valid`** (A1 chỉ chứng minh được cho
   `Cond`). Do đó `valid` không thể đánh giá trên gán trị một phần.
3. **Nâng nhân chứng đắt**: tìm một hoàn tất hợp lệ cho gán trị là tìm kiếm trên
   hộp đen — trường hợp xấu nhất quét `S × P`. Nếu `valid` loại hầu hết điểm thì
   thật sự xấu.
4. **`Scope` không sửa được**: `validExcludedOf`, `excludedPoints` buộc quét
   toàn miền (1.6). Ngoài việc bỏ con số, không có lối thoát.
5. **D23** (`coApplyPoint?`) vẫn quét toàn miền; phải viết lại trên gán trị mà
   không dùng được `valid`.
6. **`Finite S`** vẫn bị đòi bởi `scopeOf` và nâng nhân chứng; với S chung 2^33,6
   thì không dựng được.

Tóm lại: (a) **làm được** với `valid` mờ chỉ khi chấp nhận (i) bỏ hẳn IC, (ii)
bỏ các con số `Scope` dựa trên quét, (iii) không nâng nhân chứng bằng tìm kiếm.
Đó là một phiên bản **yếu hơn rất nhiều**.

### 2.5 Bảng tóm tắt

| | (a) chiếu theo cặp | (b) IC là cây cú pháp | (c) enum dải |
|---|---|---|---|
| **Chứng minh thêm** | A1–A9 | B1–B4 (+B5 tùy chọn) | không (nếu (a) biết "trường": + ≈ 100–200) |
| **Dòng ước lượng (chưa kiểm)** | ≈ 710–1 070 | ≈ 90–170 (+ 200–350) | 0 |
| **`consistentOn` còn đúng?** | **Có**, nếu xấp xỉ trên; mạnh hơn nhưng kém chính xác | **Có**, giữ nguyên | **Có** (lựa chọn mô hình hóa) |
| **Nhân chứng cần thêm** | điểm đầy đủ valid + `Conflict` tại điểm | không | không |
| **Trust base** | không thêm định nghĩa; thêm quy ước "S là tích trường"; `valid` rút khỏi `consistentOn` nếu bỏ IC | `valid` thành danh sách đọc được; vẫn tin bộ đọc và độ đủ của IC | bớt IC; vẫn tin biên dải |
| **Rủi ro chính** | A7 (`Scope`, D23) lớn hơn dự kiến; nâng nhân chứng | quá mạnh vẫn che xung đột (nhưng nhìn thấy) | không có |
| **Giải quyết ngay chướng ngại chính?** | **Có**: mọi cặp ≤ 2^11,6 | **Không** (chỉ mở đường) | **Một phần**: −0,42 bit, bớt cặp giả |

### 2.6 Một thay đổi nhỏ nằm ngoài ba cái trên

**Lọc cặp theo act trước khi liệt kê miền.** Hiện `check` duyệt **mọi** cặp
(946 đến 1 596) trong khi chỉ 75 đến 399 cặp cùng act. Đây là thay đổi nhỏ trong
`cands` (ước lượng 30 đến 80 dòng, **chưa kiểm**, chủ yếu sửa `mem_cands` và
`mem_of_mem_cands`). Nó giảm số cặp từ 4,0 đến 12,6 lần (trên toàn danh sách) **nhưng không đổi chi phí
mỗi cặp**, nên **một mình không đủ** (1.5).

---

## 3. Kết quả kỳ vọng trên luật này

### 3.1 Đếm cặp đối nghịch modality

"Đối nghịch" theo `Incompatible` hiện có: nghĩa vụ × cấm, cho phép × cấm, cùng act.
Ba lớp (do tôi định nghĩa để phân loại, **không phải khái niệm của Core**):

- **có sẵn do xây dựng**: norm *cho phép* sinh ra từ chính ngoại lệ của norm *cấm* mà
  nó đứng cạnh (chỉ có ở G4 "cho phép"). Một khai báo ưu tiên một chiều sẽ giải
  quyết đúng cặp này; nó **không** là xung đột pháp lý.
- **hình thức hoặc dẫn chiếu × cấm**: nghĩa vụ "phải có cảnh báo" (12.4), "phải
  có hệ thống chặn lọc" (12.5), "phải tuân thủ" (12.1, 13.0) đặt cạnh một lệnh
  cấm quảng cáo. **Chỉ có thể là báo động giả**: các nghĩa vụ đó không buộc ai
  phải quảng cáo (E1 trong `slice1-notes.md`).
- **chéo**: norm *cho phép* (sinh từ một ngoại lệ) × một norm *cấm* **khác** trên
  cùng act.

| G1 | G4 | G7 | Cặp đối nghịch modality | … cùng áp dụng được | có sẵn do xây dựng | hình thức hoặc dẫn chiếu × cấm | chéo (cho phép × cấm khác) | Không thể cùng áp dụng |
|---|---|---|---|---|---|---|---|---|
| a | ngoại lệ | mịn | 0 | 0 | 0 | 0 | 0 | 0 |
| a | ngoại lệ | thô | 36 | 35 | 0 | 35 | 0 | 1 |
| a | cho phép | mịn | 28 | 28 | 4 | 0 | 24 | 0 |
| a | cho phép | thô | 75 | 73 | 4 | 35 | 34 | 2 |
| b | ngoại lệ | mịn | 0 | 0 | 0 | 0 | 0 | 0 |
| b | ngoại lệ | thô | 90 | 42 | 0 | 42 | 0 | 48 |
| b | cho phép | mịn | 46 | 32 | 5 | 0 | 27 | 14 |
| b | cho phép | thô | 156 | 85 | 5 | 42 | 38 | 71 |

Đọc bảng:

- **G7 mịn × G4 ngoại lệ**: **0** cặp đối nghịch — theo bảng act ở mục C, không act
  nào có cả nghĩa vụ lẫn cấm. Đúng cả hai G1.
- **G7 thô × G4 ngoại lệ**: **35** (G1 a) hoặc **42** (G1 b) cặp co-applicable,
  **tất cả là báo động giả** (hình thức × cấm). 1 cặp (G1 a) hoặc 48 cặp (G1 b)
  không thể co-applicable vì khác dải độ cồn (ví dụ 13.0 × 5.7).
- **G7 mịn × G4 cho phép**: **28** (G1 a) hoặc **46** (G1 b) cặp, trong đó **4 đến 5
  có sẵn do xây dựng**, còn lại là **chéo**: **24** (G1 a), hoặc **27** co-applicable
  và 14 không (G1 b).
- **G7 thô × G4 cho phép**: lẫn cả hai (75 hoặc 156 cặp).

Danh sách đầy đủ ở Phụ lục C (hai biến thể G1 a).

### 3.2 24 cặp "chéo" (G1 a, cho phép, mịn) theo chiều của chồng lấn

Những cặp này **chỉ tồn tại nếu người mã hóa chọn viết ngoại lệ thành cho
phép** (G4). Tôi nhóm theo chiều chung của điều kiện:

| Chiều | Cặp | Số | Nhận định (ứng viên, chưa kiểm chứng) |
|---|---|---|---|
| **Địa điểm / thời gian** | 10.6P × {5.5, 10.1, 10.2, 10.3, 10.4, 10.5, 10.7}; 19.6P × {19.1, 19.2, 19.3, 19.4, 19.5} | 12 | **Căng thẳng ngữ nghĩa có thể thật**: nơi làm việc của đơn vị sự nghiệp công lập rất thường **đồng thời** là cơ sở y tế, giáo dục… (10.1–10.5, 10.7; 19.1–19.5), mà các khoản đó **không có** ngoại lệ "trừ địa điểm được phép kinh doanh". Nếu đọc ngoại lệ ở 10.6, 19.6 như một quyền thì nó **va chạm** với các khoản đó; nếu đọc như phạm vi thì ngoại lệ **vô hiệu** ở những nơi chồng lấn |
| **Tuổi** | 10.6P × 5.2; 19.6P × 5.3a | 2 | **Có vẻ là sản phẩm của mô hình**: lệnh cấm theo tuổi độc lập với ngoại lệ về địa điểm. Ngoại lệ không "cho phép" người dưới 18 uống |
| **Phương tiện quảng cáo** | 12.3cP × {12.3a, 12.3b, 12.3d, 13.1, 13.2}; 13.2P × {12.3a, 12.3b, 12.3c, 12.3d, 13.1} | 10 | **Phụ thuộc IC**: các cặp chỉ co-applicable nếu một quảng cáo có thể đồng thời nằm trên hai phương tiện. Với ICX ("một phương tiện") **5 trong 10** biến mất (cặp mà hai norm đều đọc hai fact trong S23–S26) |

Nghĩa là: ngay cả khi G4 chọn "cho phép", **một nửa** các cặp "chéo" là hệ quả của
mô hình một-tình-huống chứ không phải của luật.

### 3.3 `analyze` sạch có trả `consistentOn` không?

**Có khả năng ở các biến thể (ngoại lệ, mịn)** — với điều kiện validator im lặng:
id duy nhất (kể cả các bản nhân bản G1 b), chỉ số atom hợp lệ, **mọi tham chiếu
đã nêu trong `references` có trong catalog** (các dẫn chiếu tới "pháp luật về
quảng cáo", "luật định", "quy định của Chính phủ" không phải điều khoản của luật
này: nếu ghi vào `references` mà không có trong catalog thì `.invalid`; nếu không
ghi thì phải ghi nhận ở chỗ khác là chưa mã hóa), không dùng ưu tiên nên không có
chu trình, và `Atoms` đã qua `Finite`.

**Ở các biến thể khác** kết quả sẽ là `conflict` hoặc `conditionalConflict`:
- (thô, ngoại lệ): xung đột **giả** (35 đến 42 cặp) — `check` chỉ báo **một nhân
  chứng mỗi lần chạy** (`find?`), nên người duyệt phải xử lý lần lượt, trừ khi
  tách act hay khai báo ưu tiên.
- (mịn, cho phép): ít nhất một trong 4 đến 5 cặp "có sẵn do xây dựng", rồi các cặp
  chéo ở 3.2.

**Một `consistentOn` ở (mịn, ngoại lệ) cho thấy**:

- Với 44 đến 52 norm đã mã hóa, **không có cặp cùng act nào** có hai modality khắc
  nhau cùng áp dụng được trên điểm valid (định lý (b), kernel kiểm).
- Không norm nào không đánh giá được (`Audit.unevaluable` rỗng); không chu trình
  ưu tiên (D40).
- Quy mô: các con số ở mục 1 là cỡ phép kiểm.

**Và không cho thấy**:

- **Nó rỗng về xung đột modality.** Ở biến thể này lát cắt chỉ có cấm và nghĩa vụ
  hình thức trên **act khác nhau**; `Conflict` không thể đúng cho **bất kỳ** tập
  lệnh cấm nào. Kết quả này sẽ y hệt nếu thay mọi điều kiện bằng điều kiện khác.
- Luật **nhất quán** (faithfulness): hoàn toàn chưa nói.
- Độ phủ: các khoản chưa mã hóa (5.13, 12.6, các khe ủy quyền, Điều 2) không được
  nhắc đến.
- Đúng/sai của các **biên dải**, của **`valid`**, của **việc gom act**.

### 3.4 Các loại lỗi khác mà bộ kiểm hiện tại không bắt

Bộ kiểm hiện tại (Level 1) chỉ bắt: cùng act, modality khắc nhau, cùng áp dụng,
không có ưu tiên một chiều. Validator chỉ bắt lỗi **cấu trúc** (id trùng, chỉ số
atom, tham chiếu treo, chu trình ưu tiên, lẫn `docId`). Những loại sau, mà luật
này có thể chứa, **không được phát hiện**:

1. **Hở hoặc chồng giữa các dải ngưỡng**: Điều 5.7 (từ 15), 12.t (dưới 5,5), 13.t
   (5,5 đến dưới 15 với rượu, từ 5,5 với bia). Dải của rượu **phủ kín và không
   chồng**; của bia chỉ có hai dải nhưng 5.7 **không** nói "bia" nên bia từ 15
   độ chỉ bị hạn chế, không bị cấm. Biên (≥ hay >) và cận dưới của "có cồn" là chỗ
   người mã hóa có thể sai mà không ai thấy.
2. **Ngoại lệ vô hiệu hoặc bị vô hiệu bởi điều khác**: ngoại lệ 12.3.c (thể thao
   tiếp sóng nước ngoài) so với lệnh cấm 13.1 cho dải từ 5,5 độ; ngoại lệ 10.6 và
   19.6 ở những nơi cũng thuộc 10.1–10.5, 10.7 / 19.1–19.5 (3.2).
3. **Bất đối xứng giữa điều song song**: 10 so với 19 (khung thời gian ở 10.2,
   10.6; không có tương ứng cho 10.7).
4. **Norm không bao giờ áp dụng** (mục Should của validator, chưa làm).
5. **Trùng lặp**: 5.2 và 10.3; 5.5 với 10.2, 10.6; 5.4 và 32.3.
6. **Khác biệt thuật ngữ**: "độ cồn" (2.4) so với "nồng độ cồn" (5.6, chưa định
   nghĩa); "bán" so với "cung cấp"; ranh giới "rượu"/"bia".
7. **Phụ thuộc ngầm không được nêu**: 5.11 → Điều 15; 5.9 ↔ Điều 11; 5.12 → Điều 20.
8. **Chưa hoàn tất do ủy quyền**: 10.7, 12.3.c, 12.3.d/12.4/12.5 (qua 12.6).
9. **Cùng modality, khác chế tài** (Điều 28): hai lệnh cấm trùng nhưng hậu quả
   khác nhau — Core không mô hình chế tài.
10. **Soạn thảo không nhất quán**: "và" so với "hoặc" (5.5, 5.10, 5.12, 12.3.c);
    tiêu đề Điều 12 so với nội dung.
11. **Nhầm vai**: ai bị ràng buộc (người bán hay người mua) — Core không có chủ
    thể.
12. **Điều khoản chuyển tiếp/hiệu lực theo thời gian** (Điều 36).
13. **Xung đột với luật khác** (Level 2, ngoài phạm vi).
14. **Cùng khái niệm mở dùng khác nghĩa** ("dành cho" ở 10.3, 12.2.b, 12.3.a).

---

## 4. Khuyến nghị

### 4.1 Thứ tự thay đổi

Mỗi bước giúp **cả hai** phương án G12 (và độc lập với G1, G4, G7), nên thứ tự
không phụ thuộc vào các quyết định đó. Độ tin cậy là **đánh giá chủ quan** của
tôi, ghi để bạn cân.

| # | Thay đổi | Vì sao đứng ở đây | Độ tin cậy |
|---|---|---|---|
| 0 | **Lọc cặp theo act trước khi liệt kê miền**; không quét `S × P` để dựng `Scope` | Nhỏ, độc lập, giảm số cặp 4,0 đến 12,6 lần; là tiền đề cho các bước sau | **Cao** (~90%) rằng cần; **trung bình** (~60%) rằng ước lượng 30–80 dòng đúng |
| 1 | **(b) IC là cây cú pháp** | Lõi nhỏ (90–170 dòng); biến `valid` thành thứ đọc được; mở khóa chiếu từng IC; không đổi định lý nào | **Trung bình đến cao** (~75%) |
| 2 | **(a) chiếu theo cặp** | **Giải quyết chướng ngại chính**: mọi cặp ≤ 2^11,6, tổng 2^11,9 đến 2^15,7 | **Cao** (~85%) rằng nó đưa lát cắt này vào ngân sách *nếu từ vựng không phình quá +3 bit trên cặp tệ nhất*; **thấp** (~35%) rằng ước lượng 710–1 070 dòng đúng (A7 là phần tôi chưa kiểm) |
| 3 | **(c) làm hướng dẫn mô hình hóa ngay** (độ cồn, các nhóm giờ); chỉ làm phép chiếu biết "trường" nếu (a) đã làm mà báo động giả vì atom Bool còn nhiều | Không tốn mã; tránh 3–4 cặp giả | **Cao** (~85%) |

**Lối đi thứ hai không sửa Core** (chỉ để cân nhắc): sinh **một mô-đun nhỏ cho mỗi
cặp** bằng pipeline và kiểm từng cái bằng `analyze` hiện có. Mỗi cặp ≤ 2^11,6 nên
bộ kiểm hiện tại đủ sức. **Cái giá**: (i) việc đánh lại chỉ số atom cho mô-đun
cặp do pipeline không tin cậy thực hiện; (ii) phải có một mảnh Lean chứng minh
rằng tập mô-đun **phủ mọi cặp cùng act** — nếu thiếu thì chính là "bỏ im lặng một
cặp" (I4); (iii) kết luận `consistentOn` **cho từng cặp** không tự suy ra kết luận
cho cả tài liệu nếu không có bổ đề nối (A1). Tôi **không khuyến nghị** lối này
như đích cuối, nhưng nó là **cách rẻ nhất để kiểm chứng giả thiết**.

**Liên hệ ADR-0020**: ADR đó kết luận rằng tìm kiếm biên dịch **không giúp gì** cho
khẳng định `consistentOn` vì nó là mệnh đề phổ quát cần kernel quét toàn miền.
Kết luận đó **đúng với toàn miền** nhưng với chiếu theo cặp thì phép quét của
kernel chỉ còn **2^11,9 đến 2^15,7 điểm** — nằm trong phạm vi đã đo (2^12 ≈ 1 giây
đến 2^16 ≈ 50 giây với vị từ rẻ). Nếu (a) được làm, nhận định "không được lợi
gì" nên được xem lại cho lát cắt này.

### 4.2 Thí nghiệm nhỏ nhất để xác nhận hoặc bác bỏ

Giả thiết cần kiểm: **(H) phép chiếu theo cặp làm được và rẻ, và thiết kế hiện
tại không làm được cho miền mô-đun**.

1. **Rẻ nhất — chứng minh bổ đề A1 trong Lean** (khoảng 100 dòng, chưa kiểm). Nếu
   *không* chứng minh được gọn (ví dụ vì bộ đọc của `Atoms` cho phép phụ thuộc
   ngầm), (a) **thiết kế như trên là bác bỏ**. Đây là phép thử rẻ nhất vì nó
   quyết định tính khả thi trước khi viết 700 dòng.
2. **Một cặp qua bộ kiểm hiện tại** — **12.3.c × 13.2** (10,58 bit, 1 536 điểm) làm
   mô-đun hai norm với S, P riêng chỉ gồm 10 fact của nó, đo thời gian `analyze`
   qua `decide`. **Dự đoán** (từ ADR-0010, vị từ rẻ): ≈ 1 giây; nếu ≫ 7 giây thì
   chi phí mỗi điểm cao hơn tôi giả định và ngân sách ở 1.5 phải nhân lên. Đây là
   phép đo **chưa từng làm** trên `check` thật.
3. **Phản chứng cho thiết kế hiện tại** — cùng bộ kiểm trên một mô-đun có 15 bit
   (kích thước của nhóm `uong`) với 9 norm giả; dự đoán là vượt xa 50 giây (36
   cặp × 2^15). Nếu chạy được trong vài chục giây thì kết luận ở 1.5 về "không
   làm được" phải nhẹ đi.

Cả ba **không cần sửa kho mã**: thí nghiệm 1 là một file chứng minh ngoài thư
viện, 2 và 3 là file thử bỏ đi, như đã làm với negative test của audit.

### 4.3 Điều tôi không xác minh được

- **Không chạy gì trong Lean.** Mọi chi phí thực là dự đoán từ số đo thô ở ADR-0010
  và ADR-0020.
- **Mô hình norm do tôi viết tay**; sai ở cách đọc khoản sẽ đổi F. Bảng tự kiểm
  chỉ bảo đảm nhất quán nội bộ (không đọc ngầm, không fact thừa), **không** bảo
  đảm đúng với luật.
- **Bốn IC** là của tôi và có thể thiếu; ICX là **giả định**, không phải suy ra từ
  văn bản.
- **Ước lượng số dòng chứng minh** (A1–A9, B1–B5, 2.6) **chưa kiểm**; lớn
  nhất là A7, vốn không có trong ước lượng ban đầu của tôi.
- **Văn bản của Chính phủ** và các luật được dẫn chiếu: chưa đọc.
- **"Tự tin x%"** ở 4.1 là cảm nhận chủ quan, không phải xác suất đã hiệu chỉnh.
- Tôi **không tính** tới việc `Finite` cho S trong mô-đun nhỏ có thể tự nó đắt
  trong kernel (chưa kiểm cách `decide` rút gọn các instance tích lồng nhau).

### 4.4 Quyết định cần bạn

Không trả lời G1, G4, G7, G12; chỉ nêu **điều gì đổi** nhờ phân tích này.

1. **G12** (một S chung hay nhiều mô-đun): nếu (a) được làm thì chi phí tìm xung
   đột **không còn phụ thuộc** vào cách chia mô-đun. G12 vẫn đổi cách `Scope`
   và `Audit` được tính (1.6) và việc `Finite S` có dựng được không.
2. **G7** (độ mịn act): là nhân tố quyết định số cặp báo động giả (0 so với 35–42)
   và số cặp phải xử lý. Độ mịn **thô** buộc phải có cách khai báo ưu tiên hoặc
   tách act.
3. **G4** (ngoại lệ hay cho phép): quyết định có tồn tại cặp "chéo" ở 3.2 hay
   không. Dù chọn gì, **12 cặp địa điểm/thời gian** ở 3.2 nêu một câu hỏi pháp lý
   có thật về hiệu lực của ngoại lệ ở 10.6, 19.6 mà nên có người duyệt đọc.
4. **G1** (phạm vi Điều 12): quyết định có nhân bản norm (số cặp 75 hay 112 trở
   lên) và có nhân đôi báo động giả hay không.
5. **Có đồng ý thứ tự ở 4.1** và có chạy thí nghiệm 1 trước khi viết A2–A9 không.
6. **Có chấp nhận `consistentOn` "không phụ thuộc `valid`"** (bỏ hẳn IC, an toàn
   nhưng kém chính xác) hay muốn IC tham gia (đòi (b) trước).
7. **Có làm thêm "báo cáo mọi cặp xung đột"** thay vì chỉ nhân chứng đầu tiên —
   cần cho việc xử lý hàng chục cặp ở 3.3.

---

## Phụ lục A — Bảng norm dùng trong mô hình (G1 a, ngoại lệ, mịn)

44 norm. "Fact/tham số đọc" gồm cả điều kiện lẫn ngoại lệ. Các biến thể khác sinh
thêm: **bản nhân bản** (`'`, G1 b: gắn điều kiện dải cho dải từ 5,5 độ) và **norm
cho phép** (`P`, G4 "cho phép": ngoại lệ thành một norm cho phép cùng act, norm cấm mất
ngoại lệ).

| # | Khoản | Loại | Act (mịn) | Fact/tham số đọc (điều kiện + ngoại lệ) | Bit |
|---|---|---|---|---|---|
| 1 | 5.1 | cấm | `xui_giuc` | — | 0,00 |
| 2 | 5.2 | cấm | `uong` | S03 | 1,00 |
| 3 | 5.3 | cấm | `ban` | S04 | 1,00 |
| 4 | 5.3 | cấm | `cung_cap` | S04 | 1,00 |
| 5 | 5.3 | cấm | `khuyen_mai` | S04 | 1,00 |
| 6 | 5.4 | cấm | `lao_dong` | S05, P02 | 2,00 |
| 7 | 5.5 | cấm | `uong` | S06, S07, P01 | 4,00 |
| 8 | 5.6 | cấm | `dieu_khien` | S08, S09 | 2,00 |
| 9 | 5.7 | cấm | `qc_15` | S01, S02 | 2,58 |
| 10 | 5.8 | cấm | `tin_sai` | P03 | 1,00 |
| 11 | 5.9 | cấm | `khuyen_mai` | S02 | 1,58 |
| 12 | 5.9 | cấm | `dung_lam_qua` | S02 | 1,58 |
| 13 | 5.10 | cấm | `nguyen_lieu` | P04, P05, P06 | 3,00 |
| 14 | 5.11 | cấm | `kd_khong_phep` | S01, S10, S11 | 3,00 |
| 15 | 5.11 | cấm | `ban_may` | — | 0,00 |
| 16 | 5.12 | cấm | `kd_hang_cam` | S12, S13, P04, P05 | 4,00 |
| 17 | 5.12 | cấm | `nhap_lau` | — | 0,00 |
| 18 | 5.13 | cấm | `cam_khac` | — | 0,00 |
| 19 | 10.1 | cấm | `uong` | S14 | 1,00 |
| 20 | 10.2 | cấm | `uong` | S15, S21 | 2,00 |
| 21 | 10.3 | cấm | `uong` | S16 | 1,00 |
| 22 | 10.4 | cấm | `uong` | S17 | 1,00 |
| 23 | 10.5 | cấm | `uong` | S18 | 1,00 |
| 24 | 10.7 | cấm | `uong` | P07 | 1,00 |
| 25 | 10.6 | cấm | `uong` | S19, S20, S22 | 3,00 |
| 26 | 19.1 | cấm | `ban` | S14 | 1,00 |
| 27 | 19.2 | cấm | `ban` | S15 | 1,00 |
| 28 | 19.3 | cấm | `ban` | S16 | 1,00 |
| 29 | 19.4 | cấm | `ban` | S17 | 1,00 |
| 30 | 19.5 | cấm | `ban` | S18 | 1,00 |
| 31 | 19.6 | cấm | `ban` | S19, S20 | 2,00 |
| 32 | 12.1 | nghĩa vụ | `tuan_thu` | — | 0,00 |
| 33 | 12.2 | cấm | `qc_noi_dung_cam` | P08, P09, P10 | 3,00 |
| 34 | 12.2 | cấm | `qc_noi_dung_cam` | S32, P11 | 2,00 |
| 35 | 12.3 | cấm | `qc_o_noi` | P11 | 1,00 |
| 36 | 12.3 | cấm | `qc_o_noi` | S23 | 1,00 |
| 37 | 12.3c | cấm | `qc_o_noi` | S24, S29, S30, S31, P11, P13 | 6,00 |
| 38 | 12.3 | cấm | `qc_o_noi` | S25, P12 | 2,00 |
| 39 | 12.4 | nghĩa vụ | `canh_bao` | — | 0,00 |
| 40 | 12.5 | nghĩa vụ | `chan_loc` | S26 | 1,00 |
| 41 | 12.6 | nghĩa vụ | `chinh_phu` | — | 0,00 |
| 42 | 13 | nghĩa vụ | `tuan_thu` | S01, S02 | 2,58 |
| 43 | 13.1 | cấm | `qc_o_noi` | S01, S02, S27 | 3,58 |
| 44 | 13.2 | cấm | `qc_o_noi` | S01, S02, S25, S28 | 4,58 |

## Phụ lục B — 75 cặp cùng act (G1 a, ngoại lệ, mịn)

Cột "Loại": chữ cái đầu của modality của hai norm (c = cấm, n = nghĩa vụ; biến thể
này không có norm cho phép). "Miền" = tích số giá trị của F. "Bit nếu giữ IC" gồm cả fact của
các IC chạm vào F.

| # | Cặp | Act | Loại | Fact/tham số trong F | Bit | Miền | IC chạm | Bit nếu giữ IC |
|---|---|---|---|---|---|---|---|---|
| 1 | 5.3a × 19.6 | `ban` | c/c | S04, S19, S20 | 3,00 | 8 | — | 3,00 |
| 2 | 19.1 × 19.6 | `ban` | c/c | S14, S19, S20 | 3,00 | 8 | — | 3,00 |
| 3 | 19.2 × 19.6 | `ban` | c/c | S15, S19, S20 | 3,00 | 8 | — | 3,00 |
| 4 | 19.3 × 19.6 | `ban` | c/c | S16, S19, S20 | 3,00 | 8 | — | 3,00 |
| 5 | 19.4 × 19.6 | `ban` | c/c | S17, S19, S20 | 3,00 | 8 | — | 3,00 |
| 6 | 19.5 × 19.6 | `ban` | c/c | S18, S19, S20 | 3,00 | 8 | — | 3,00 |
| 7 | 5.3a × 19.1 | `ban` | c/c | S04, S14 | 2,00 | 4 | — | 2,00 |
| 8 | 5.3a × 19.2 | `ban` | c/c | S04, S15 | 2,00 | 4 | — | 2,00 |
| 9 | 5.3a × 19.3 | `ban` | c/c | S04, S16 | 2,00 | 4 | — | 2,00 |
| 10 | 5.3a × 19.4 | `ban` | c/c | S04, S17 | 2,00 | 4 | — | 2,00 |
| 11 | 5.3a × 19.5 | `ban` | c/c | S04, S18 | 2,00 | 4 | — | 2,00 |
| 12 | 19.1 × 19.2 | `ban` | c/c | S14, S15 | 2,00 | 4 | — | 2,00 |
| 13 | 19.1 × 19.3 | `ban` | c/c | S14, S16 | 2,00 | 4 | — | 2,00 |
| 14 | 19.1 × 19.4 | `ban` | c/c | S14, S17 | 2,00 | 4 | — | 2,00 |
| 15 | 19.1 × 19.5 | `ban` | c/c | S14, S18 | 2,00 | 4 | — | 2,00 |
| 16 | 19.2 × 19.3 | `ban` | c/c | S15, S16 | 2,00 | 4 | — | 2,00 |
| 17 | 19.2 × 19.4 | `ban` | c/c | S15, S17 | 2,00 | 4 | — | 2,00 |
| 18 | 19.2 × 19.5 | `ban` | c/c | S15, S18 | 2,00 | 4 | — | 2,00 |
| 19 | 19.3 × 19.4 | `ban` | c/c | S16, S17 | 2,00 | 4 | — | 2,00 |
| 20 | 19.3 × 19.5 | `ban` | c/c | S16, S18 | 2,00 | 4 | — | 2,00 |
| 21 | 19.4 × 19.5 | `ban` | c/c | S17, S18 | 2,00 | 4 | — | 2,00 |
| 22 | 5.3c × 5.9a | `khuyen_mai` | c/c | S02, S04 | 2,58 | 6 | — | 2,58 |
| 23 | 12.2a × 12.2b | `qc_noi_dung_cam` | c/c | S32, P08, P09, P10, P11 | 5,00 | 32 | — | 5,00 |
| 24 | 12.3c × 13.2 | `qc_o_noi` | c/c | S01, S02, S24, S25, S28, S29, S30, S31, P11, P13 | 10,58 | 1536 | IC1, IC2, IC3 | 11,58 |
| 25 | 12.3c × 13.1 | `qc_o_noi` | c/c | S01, S02, S24, S27, S29, S30, S31, P11, P13 | 9,58 | 768 | IC1, IC3 | 9,58 |
| 26 | 12.3c × 12.3d | `qc_o_noi` | c/c | S24, S25, S29, S30, S31, P11, P12, P13 | 8,00 | 256 | IC1, IC2, IC3 | 10,00 |
| 27 | 12.3b × 12.3c | `qc_o_noi` | c/c | S23, S24, S29, S30, S31, P11, P13 | 7,00 | 128 | IC1, IC3 | 8,00 |
| 28 | 12.3a × 12.3c | `qc_o_noi` | c/c | S24, S29, S30, S31, P11, P13 | 6,00 | 64 | IC1, IC3 | 7,00 |
| 29 | 12.3a × 13.2 | `qc_o_noi` | c/c | S01, S02, S25, S28, P11 | 5,58 | 48 | IC2 | 5,58 |
| 30 | 12.3b × 13.2 | `qc_o_noi` | c/c | S01, S02, S23, S25, S28 | 5,58 | 48 | IC2 | 5,58 |
| 31 | 12.3d × 13.1 | `qc_o_noi` | c/c | S01, S02, S25, S27, P12 | 5,58 | 48 | IC1, IC2 | 9,58 |
| 32 | 12.3d × 13.2 | `qc_o_noi` | c/c | S01, S02, S25, S28, P12 | 5,58 | 48 | IC2 | 5,58 |
| 33 | 13.1 × 13.2 | `qc_o_noi` | c/c | S01, S02, S25, S27, S28 | 5,58 | 48 | IC1, IC2 | 8,58 |
| 34 | 12.3a × 13.1 | `qc_o_noi` | c/c | S01, S02, S27, P11 | 4,58 | 24 | IC1 | 7,58 |
| 35 | 12.3b × 13.1 | `qc_o_noi` | c/c | S01, S02, S23, S27 | 4,58 | 24 | IC1 | 7,58 |
| 36 | 12.3a × 12.3d | `qc_o_noi` | c/c | S25, P11, P12 | 3,00 | 8 | IC2 | 4,00 |
| 37 | 12.3b × 12.3d | `qc_o_noi` | c/c | S23, S25, P12 | 3,00 | 8 | IC2 | 4,00 |
| 38 | 12.3a × 12.3b | `qc_o_noi` | c/c | S23, P11 | 2,00 | 4 | — | 2,00 |
| 39 | 12.1 × 13.0 | `tuan_thu` | n/n | S01, S02 | 2,58 | 6 | — | 2,58 |
| 40 | 5.5 × 10.6 | `uong` | c/c | S06, S07, S19, S20, S22, P01 | 7,00 | 128 | IC4 | 7,00 |
| 41 | 5.5 × 10.2 | `uong` | c/c | S06, S07, S15, S21, P01 | 6,00 | 64 | IC4 | 7,00 |
| 42 | 5.2 × 5.5 | `uong` | c/c | S03, S06, S07, P01 | 5,00 | 32 | IC4 | 6,00 |
| 43 | 5.5 × 10.1 | `uong` | c/c | S06, S07, S14, P01 | 5,00 | 32 | IC4 | 6,00 |
| 44 | 5.5 × 10.3 | `uong` | c/c | S06, S07, S16, P01 | 5,00 | 32 | IC4 | 6,00 |
| 45 | 5.5 × 10.4 | `uong` | c/c | S06, S07, S17, P01 | 5,00 | 32 | IC4 | 6,00 |
| 46 | 5.5 × 10.5 | `uong` | c/c | S06, S07, S18, P01 | 5,00 | 32 | IC4 | 6,00 |
| 47 | 5.5 × 10.7 | `uong` | c/c | S06, S07, P01, P07 | 5,00 | 32 | IC4 | 6,00 |
| 48 | 10.2 × 10.6 | `uong` | c/c | S15, S19, S20, S21, S22 | 5,00 | 32 | IC4 | 8,00 |
| 49 | 5.2 × 10.6 | `uong` | c/c | S03, S19, S20, S22 | 4,00 | 16 | IC4 | 7,00 |
| 50 | 10.1 × 10.6 | `uong` | c/c | S14, S19, S20, S22 | 4,00 | 16 | IC4 | 7,00 |
| 51 | 10.3 × 10.6 | `uong` | c/c | S16, S19, S20, S22 | 4,00 | 16 | IC4 | 7,00 |
| 52 | 10.4 × 10.6 | `uong` | c/c | S17, S19, S20, S22 | 4,00 | 16 | IC4 | 7,00 |
| 53 | 10.5 × 10.6 | `uong` | c/c | S18, S19, S20, S22 | 4,00 | 16 | IC4 | 7,00 |
| 54 | 10.7 × 10.6 | `uong` | c/c | S19, S20, S22, P07 | 4,00 | 16 | IC4 | 7,00 |
| 55 | 5.2 × 10.2 | `uong` | c/c | S03, S15, S21 | 3,00 | 8 | — | 3,00 |
| 56 | 10.1 × 10.2 | `uong` | c/c | S14, S15, S21 | 3,00 | 8 | — | 3,00 |
| 57 | 10.2 × 10.3 | `uong` | c/c | S15, S16, S21 | 3,00 | 8 | — | 3,00 |
| 58 | 10.2 × 10.4 | `uong` | c/c | S15, S17, S21 | 3,00 | 8 | — | 3,00 |
| 59 | 10.2 × 10.5 | `uong` | c/c | S15, S18, S21 | 3,00 | 8 | — | 3,00 |
| 60 | 10.2 × 10.7 | `uong` | c/c | S15, S21, P07 | 3,00 | 8 | — | 3,00 |
| 61 | 5.2 × 10.1 | `uong` | c/c | S03, S14 | 2,00 | 4 | — | 2,00 |
| 62 | 5.2 × 10.3 | `uong` | c/c | S03, S16 | 2,00 | 4 | — | 2,00 |
| 63 | 5.2 × 10.4 | `uong` | c/c | S03, S17 | 2,00 | 4 | — | 2,00 |
| 64 | 5.2 × 10.5 | `uong` | c/c | S03, S18 | 2,00 | 4 | — | 2,00 |
| 65 | 5.2 × 10.7 | `uong` | c/c | S03, P07 | 2,00 | 4 | — | 2,00 |
| 66 | 10.1 × 10.3 | `uong` | c/c | S14, S16 | 2,00 | 4 | — | 2,00 |
| 67 | 10.1 × 10.4 | `uong` | c/c | S14, S17 | 2,00 | 4 | — | 2,00 |
| 68 | 10.1 × 10.5 | `uong` | c/c | S14, S18 | 2,00 | 4 | — | 2,00 |
| 69 | 10.1 × 10.7 | `uong` | c/c | S14, P07 | 2,00 | 4 | — | 2,00 |
| 70 | 10.3 × 10.4 | `uong` | c/c | S16, S17 | 2,00 | 4 | — | 2,00 |
| 71 | 10.3 × 10.5 | `uong` | c/c | S16, S18 | 2,00 | 4 | — | 2,00 |
| 72 | 10.3 × 10.7 | `uong` | c/c | S16, P07 | 2,00 | 4 | — | 2,00 |
| 73 | 10.4 × 10.5 | `uong` | c/c | S17, S18 | 2,00 | 4 | — | 2,00 |
| 74 | 10.4 × 10.7 | `uong` | c/c | S17, P07 | 2,00 | 4 | — | 2,00 |
| 75 | 10.5 × 10.7 | `uong` | c/c | S18, P07 | 2,00 | 4 | — | 2,00 |

## Phụ lục C — Cặp đối nghịch

### C.1 G1 a · ngoại lệ · thô (36 cặp, 35 co-applicable)

| Cặp | Act | Lớp | Cùng áp dụng được | Fact chung của hai norm |
|---|---|---|---|---|
| 12.1 (nghĩa vụ) × 12.2a (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.1 (nghĩa vụ) × 12.2b (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.1 (nghĩa vụ) × 12.3a (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.1 (nghĩa vụ) × 12.3b (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.1 (nghĩa vụ) × 12.3c (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.1 (nghĩa vụ) × 12.3d (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.1 (nghĩa vụ) × 13.1 (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.1 (nghĩa vụ) × 13.2 (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.2a (cấm) × 12.4 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.2a (cấm) × 12.5 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.2a (cấm) × 13.0 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.2b (cấm) × 12.4 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.2b (cấm) × 12.5 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.2b (cấm) × 13.0 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3a (cấm) × 12.4 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3a (cấm) × 12.5 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3a (cấm) × 13.0 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3b (cấm) × 12.4 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3b (cấm) × 12.5 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3b (cấm) × 13.0 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3c (cấm) × 12.4 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3c (cấm) × 12.5 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3c (cấm) × 13.0 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3d (cấm) × 12.4 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3d (cấm) × 12.5 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.3d (cấm) × 13.0 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 12.4 (nghĩa vụ) × 13.1 (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.4 (nghĩa vụ) × 13.2 (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.5 (nghĩa vụ) × 13.1 (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 12.5 (nghĩa vụ) × 13.2 (cấm) | `quang_cao` | hình thức × cấm | có | không có |
| 13.0 (nghĩa vụ) × 13.1 (cấm) | `quang_cao` | hình thức × cấm | có | S01, S02 |
| 13.0 (nghĩa vụ) × 13.2 (cấm) | `quang_cao` | hình thức × cấm | có | S01, S02 |
| 5.7 (cấm) × 12.1 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 5.7 (cấm) × 12.4 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 5.7 (cấm) × 12.5 (nghĩa vụ) | `quang_cao` | hình thức × cấm | có | không có |
| 5.7 (cấm) × 13.0 (nghĩa vụ) | `quang_cao` | hình thức × cấm | không | S01, S02 |

### C.2 G1 a · cho phép · mịn (28 cặp, 28 co-applicable)

| Cặp | Act | Lớp | Cùng áp dụng được | Fact chung của hai norm |
|---|---|---|---|---|
| 10.6 (cấm) × 10.6P (cho phép) | `uong` | có sẵn do xây dựng | có | S19, S22 |
| 12.3c (cấm) × 12.3cP (cho phép) | `qc_o_noi` | có sẵn do xây dựng | có | P11, S24, S29, S30 |
| 13.2 (cấm) × 13.2P (cho phép) | `qc_o_noi` | có sẵn do xây dựng | có | S01, S02, S25 |
| 19.6 (cấm) × 19.6P (cho phép) | `ban` | có sẵn do xây dựng | có | S19 |
| 10.1 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
| 10.2 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
| 10.3 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
| 10.4 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
| 10.5 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
| 10.7 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
| 12.3a (cấm) × 12.3cP (cho phép) | `qc_o_noi` | chéo | có | P11 |
| 12.3a (cấm) × 13.2P (cho phép) | `qc_o_noi` | chéo | có | không có |
| 12.3b (cấm) × 12.3cP (cho phép) | `qc_o_noi` | chéo | có | không có |
| 12.3b (cấm) × 13.2P (cho phép) | `qc_o_noi` | chéo | có | không có |
| 12.3c (cấm) × 13.2P (cho phép) | `qc_o_noi` | chéo | có | không có |
| 12.3cP (cho phép) × 12.3d (cấm) | `qc_o_noi` | chéo | có | không có |
| 12.3cP (cho phép) × 13.1 (cấm) | `qc_o_noi` | chéo | có | không có |
| 12.3cP (cho phép) × 13.2 (cấm) | `qc_o_noi` | chéo | có | không có |
| 12.3d (cấm) × 13.2P (cho phép) | `qc_o_noi` | chéo | có | S25 |
| 13.1 (cấm) × 13.2P (cho phép) | `qc_o_noi` | chéo | có | S01, S02 |
| 19.1 (cấm) × 19.6P (cho phép) | `ban` | chéo | có | không có |
| 19.2 (cấm) × 19.6P (cho phép) | `ban` | chéo | có | không có |
| 19.3 (cấm) × 19.6P (cho phép) | `ban` | chéo | có | không có |
| 19.4 (cấm) × 19.6P (cho phép) | `ban` | chéo | có | không có |
| 19.5 (cấm) × 19.6P (cho phép) | `ban` | chéo | có | không có |
| 5.2 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
| 5.3a (cấm) × 19.6P (cho phép) | `ban` | chéo | có | không có |
| 5.5 (cấm) × 10.6P (cho phép) | `uong` | chéo | có | không có |
