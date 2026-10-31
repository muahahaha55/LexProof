# Đáp án và độ phủ — ca thử nhóm «bán / cung cấp / khuyến mại rượu, bia» (BẢN NHÁP)

> ## ⚠ ĐÂY LÀ ĐÁP ÁN: KHÔNG ĐỌC TRƯỚC KHI TRẢ LỜI `sale-group-cases.md`
>
> Mọi thứ ở đây là bản nháp chưa ai duyệt. «Kỳ vọng» là cách đọc của người soạn từ chữ của khoản; «mã hóa cho» là kết quả của bản mã hóa nháp (`LexProof/Laws/AlcoholSale.lean`). **Hai thứ này cùng một tác giả**: ca đạt chỉ cho thấy mã hóa khớp người soạn, chưa cho thấy nó khớp luật.

Danh sách ca được ghi trước khi chạy (`eval/cases/RECORD.md`, sha256 của `cases_draft.py`); kỳ vọng không sửa sau khi chạy. Trạng thái mọi ca: `draft`.

**Kết quả: 37 ca, 36 đạt, 1 không đạt.** Kernel kiểm đúng tập ca đạt (`pass_set`, `decide +kernel`); ca không đạt được liệt kê lúc chạy (`notPassingNow`).

## 1. Từng ca

| Mã | Loại | Act thử | Kỳ vọng (người soạn) | Mã hóa cho | Kết quả | Norm áp dụng | Độ tin cậy | Khoản |
|---|---|---|---|---|---|---|---|---|
| C01 | dương | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-ban | high | Điều 5 khoản 3 |
| C02 | đối chứng âm | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | high | Điều 5 khoản 3 |
| C03 | ranh giới | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-ban | high | Điều 5 khoản 3 |
| C04 | ranh giới | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | high | Điều 5 khoản 3 |
| C05 | dương | `cung_cap_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-cung-cap | high | Điều 5 khoản 3 |
| C06 | đối chứng âm | `cung_cap_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | high | Điều 5 khoản 3 |
| C07 | ranh giới | `cung_cap_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-cung-cap | high | Điều 5 khoản 3 |
| C08 | ranh giới | `cung_cap_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | high | Điều 5 khoản 3 |
| C09 | dương | `khuyen_mai_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-khuyen-mai | high | Điều 5 khoản 3 |
| C10 | đối chứng âm (gần giống) | `khuyen_mai_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 5 khoản 3 |
| C11 | ranh giới | `khuyen_mai_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-khuyen-mai | high | Điều 5 khoản 3 |
| C12 | ranh giới | `khuyen_mai_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | high | Điều 5 khoản 3 |
| C13 | dương | `khuyen_mai_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.9-i | high | Điều 5 khoản 9 |
| C14 | ranh giới | `khuyen_mai_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.9-i | high | Điều 5 khoản 9 |
| C15 | ranh giới (gần giống) | `khuyen_mai_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 5 khoản 9 |
| C16 | đối chứng âm (gần giống) | `khuyen_mai_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 5 khoản 9 |
| C17 | dương | `khuyen_mai_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-khuyen-mai, 5.9-i | high | Điều 5 khoản 9 |
| C18 | dương | `dung_ruou_bia_lam_qua_khuyen_mai` | forbidden | forbidden | **ĐẠT** | 5.9-ii | high | Điều 5 khoản 9 |
| C19 | ranh giới | `dung_ruou_bia_lam_qua_khuyen_mai` | forbidden | forbidden | **ĐẠT** | 5.9-ii | high | Điều 5 khoản 9 |
| C20 | ranh giới (gần giống) | `dung_ruou_bia_lam_qua_khuyen_mai` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 5 khoản 9 |
| C21 | đối chứng âm (gần giống) | `dung_ruou_bia_lam_qua_khuyen_mai` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 5 khoản 9 |
| C22 | dương | `ban_ruou_bia_bang_may_tu_dong` | forbidden | forbidden | **ĐẠT** | 5.11-ii | high | Điều 5 khoản 11 |
| C23 | đối chứng âm | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 5 khoản 11 |
| C24 | dương | `kinh_doanh_ruou_khong_phep_hoac_dang_ky` | forbidden | noNormApplies | **KHÔNG ĐẠT** | — | high | Điều 5 khoản 11 |
| C25 | dương | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 19.1 | high | Điều 19 khoản 1 |
| C26 | đối chứng âm (gần giống) | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 19 khoản 1 |
| C27 | dương | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 19.2 | medium | Điều 19 khoản 2 |
| C28 | đối chứng âm (gần giống) | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 19 khoản 2 |
| C29 | dương | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 19.3 | high | Điều 19 khoản 3 |
| C30 | đối chứng âm (gần giống) | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 19 khoản 3 |
| C31 | dương | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 19.4 | high | Điều 19 khoản 4 |
| C32 | dương | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 19.5 | high | Điều 19 khoản 5 |
| C33 | ngoại lệ | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 19.6 | medium | Điều 19 khoản 6 |
| C34 | ngoại lệ (gần giống) | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | low | Điều 19 khoản 6 |
| C35 | đối chứng âm (gần giống) | `ban_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | medium | Điều 19 khoản 6 |
| C36 | dương | `ban_ruou_bia` | forbidden | forbidden | **ĐẠT** | 5.3-ban, 19.1 | high | Điều 19 khoản 1 |
| C37 | đối chứng âm (gần giống) | `cung_cap_ruou_bia` | noNormApplies | noNormApplies | **ĐẠT** | — | low | Điều 19 (tiêu đề) |

### Ghi chú và lý do của các ca «gần giống» và ca độ tin cậy thấp

* **C02** (đối chứng âm, độ tin cậy high): Chỉ có nghĩa là khoản này không cấm; không khẳng định việc bán là hợp pháp (còn giấy phép, v.v.).
* **C10** (đối chứng âm, độ tin cậy medium): Điều 5 chỉ cấm khuyến mại cho người chưa đủ 18 tuổi hoặc với rượu, bia từ 15 độ; khuyến mại rượu dưới 15 độ cho người lớn không bị cấm bởi Điều 5. Điều 11 chỉ yêu cầu «tuân thủ» pháp luật về khuyến mại (ngoài lát cắt).
* **C15** (ranh giới, độ tin cậy medium): Khoản 9 chỉ cấm từ 15 độ trở lên; dưới 15 độ thuộc Điều 11 (ngoài lát cắt).
* **C16** (đối chứng âm, độ tin cậy medium): Như C15: dưới 15 độ không bị khoản 9 cấm.
* **C20** (ranh giới, độ tin cậy medium): Khoản 9 chỉ cấm từ 15 độ trở lên.
* **C21** (đối chứng âm, độ tin cậy medium): Như C20.
* **C23** (đối chứng âm, độ tin cậy medium): Phép thử yếu: phương thức bán nằm trong tên act, không có atom 'bán bằng máy'. Câu hỏi thật là liệu khoản 11 cấm việc này (không).
* **C24** (dương, độ tin cậy high): Nhánh (i) của khoản 11 thuộc nhóm act khác, mô-đun bán/cung cấp/khuyến mại không mã hóa; dự kiến KHÔNG đạt (lỗ hổng phủ).
* **C26** (đối chứng âm, độ tin cậy medium): Khoản 19.1 chỉ nói «Cơ sở y tế»; cửa hàng bên ngoài không phải cơ sở y tế. Điều 32 khoản 7 (cấm mở mới điểm bán trong bán kính 100 m) có thể áp dụng nhưng ngoài mô-đun.
* **C27** (dương, độ tin cậy medium): Khoản 19.2 không có điều kiện thời gian (khác Điều 10 khoản 2): đọc theo chữ thì cấm cả ngoài giờ.
* **C28** (đối chứng âm, độ tin cậy medium): Quán không phải cơ sở giáo dục.
* **C30** (đối chứng âm, độ tin cậy medium): «dành cho người chưa đủ 18 tuổi» là khái niệm mở (luật không định nghĩa): thế nào là khu vực «dành cho» người dưới 18 tuổi?
* **C33** (ngoại lệ, độ tin cậy medium): Trường hợp ngoại lệ «trừ ...» không thỏa.
* **C34** (ngoại lệ, độ tin cậy low): Cần: (1) liệu «trừ ...» chỉ thu hẹp lệnh cấm hay còn tạo ra quyền bán (người duyệt có thể trả lời «được phép»); (2) «địa điểm được phép kinh doanh rượu, bia» nghĩa là gì (Điều 15, ngoài lát cắt).
* **C35** (đối chứng âm, độ tin cậy medium): Công ty tư nhân không thuộc danh sách tổ chức ở khoản 6 (danh sách coi là đóng; slice1-notes G10).
* **C36** (dương, độ tin cậy high): Cũng là Điều 5 khoản 3.
* **C37** (đối chứng âm, độ tin cậy low): Tiêu đề Điều 19 chỉ nói «bán»; Điều 5 khoản 3 phủ «cung cấp» chỉ với người chưa đủ 18 tuổi. Việc «cung cấp» cho người lớn tại cơ sở y tế có bị cấm không là chỗ luật không nói; cần biết liệu «bán» được hiểu rộng bao nhiêu.

## 2. Ca không đạt

* **C24** — kỳ vọng `forbidden`, mã hóa cho `noNormApplies`. **Chẩn đoán: lỗ hổng phủ của mã hóa, không phải lỗi mã hóa hay lỗi ca.** Nhánh (i) của Điều 5 khoản 11 thuộc nhóm act `kinh_doanh_ruou_khong_phep_hoac_dang_ky`, không nằm trong mô-đun; không có norm nào cho act này nên kết quả là «không norm nào áp dụng», mà **không** có nghĩa là hợp pháp. Tôi đã dự báo ca này sẽ không đạt trước khi chạy (ghi trong ghi chú của ca).

## 3. Độ phủ

### 3.1 Số ca theo loại

| Loại | Số ca |
|---|---|
| dương | 14 |
| đối chứng âm | 11 |
| ranh giới | 10 |
| ngoại lệ | 2 |
| trong đó «gần giống» (luật *không* cấm điều trông gần giống) | 11 |
| độ tin cậy thấp | 2 |

### 3.2 Số ca theo norm (từ kết quả chạy)

«Dương» = norm áp dụng trong ca; «âm» = ca thử đúng act của norm mà norm **không** áp dụng.

| Norm | Act | Dương | Âm | Ghi chú |
|---|---|---|---|---|
| 5.3-ban | `ban_ruou_bia` | 3 (C01, C03, C36) | 14 (C02, C04, C23, C25, C26, C27, C28, C29, C30, C31, C32, C33, C34, C35) |  |
| 5.3-cung-cap | `cung_cap_ruou_bia` | 2 (C05, C07) | 3 (C06, C08, C37) |  |
| 5.3-khuyen-mai | `khuyen_mai_ruou_bia` | 3 (C09, C11, C17) | 6 (C10, C12, C13, C14, C15, C16) |  |
| 5.9-i | `khuyen_mai_ruou_bia` | 3 (C13, C14, C17) | 6 (C09, C10, C11, C12, C15, C16) |  |
| 5.9-ii | `dung_ruou_bia_lam_qua_khuyen_mai` | 2 (C18, C19) | 2 (C20, C21) |  |
| 5.11-ii | `ban_ruou_bia_bang_may_tu_dong` | 1 (C22) | 0 (—) | **thiếu đối chứng âm đúng nghĩa**: điều kiện luôn đúng, phương thức bán nằm trong tên act; C23 (act khác) chỉ là phép thử yếu |
| 19.1 | `ban_ruou_bia` | 2 (C25, C36) | 15 (C01, C02, C03, C04, C23, C26, C27, C28, C29, C30, C31, C32, C33, C34, C35) |  |
| 19.2 | `ban_ruou_bia` | 1 (C27) | 16 (C01, C02, C03, C04, C23, C25, C26, C28, C29, C30, C31, C32, C33, C34, C35, C36) |  |
| 19.3 | `ban_ruou_bia` | 1 (C29) | 16 (C01, C02, C03, C04, C23, C25, C26, C27, C28, C30, C31, C32, C33, C34, C35, C36) |  |
| 19.4 | `ban_ruou_bia` | 1 (C31) | 16 (C01, C02, C03, C04, C23, C25, C26, C27, C28, C29, C30, C32, C33, C34, C35, C36) |  |
| 19.5 | `ban_ruou_bia` | 1 (C32) | 16 (C01, C02, C03, C04, C23, C25, C26, C27, C28, C29, C30, C31, C33, C34, C35, C36) |  |
| 19.6 | `ban_ruou_bia` | 1 (C33) | 16 (C01, C02, C03, C04, C23, C25, C26, C27, C28, C29, C30, C31, C32, C34, C35, C36) |  |

### 3.3 Cặp ranh giới

| Nhóm ngưỡng | Act | Phía «ngoài ranh giới» | Phía «trong» | Có đủ hai phía? |
|---|---|---|---|---|
| tuổi 18 (chưa đủ / đủ) | `ban_ruou_bia` | C03 | C04 | có |
| tuổi 18 | `cung_cap_ruou_bia` | C07 | C08 | có |
| tuổi 18 | `khuyen_mai_ruou_bia` | C11 | C12, C15 | có |
| độ cồn 15 (dưới / từ) | `khuyen_mai_ruou_bia` | C14 | C12, C15 | có |
| độ cồn 15 | `dung_ruou_bia_lam_qua_khuyen_mai` | C19 | C20 | có |

Ghi chú: các ca ranh giới mô tả giá trị (ví dụ «đúng 15 độ», «14,9 độ», «17 tuổi 11 tháng», «đúng 18 tuổi») nhưng bộ kiểm chỉ thấy **nhãn dải**; nó không phân biệt 14,9 với 10. Ca ranh giới chỉ kiểm việc dải có được gắn nhãn đúng phía ranh giới, không kiểm số.

### 3.4 Ngoại lệ

| Ngoại lệ | Ca khi ngoại lệ đúng | Ca khi ngoại lệ không đúng |
|---|---|---|
| 19.6 «trừ địa điểm được phép kinh doanh rượu, bia» | C34 | C33 |

### 3.5 Ca có độ tin cậy thấp

* **C34**: Bán một chai rượu cho người 30 tuổi tại căng-tin trong trụ sở một ủy ban nhân dân; căng-tin ĐƯỢC phép kinh doanh rượu, bia. — Cần: (1) liệu «trừ ...» chỉ thu hẹp lệnh cấm hay còn tạo ra quyền bán (người duyệt có thể trả lời «được phép»); (2) «địa điểm được phép kinh doanh rượu, bia» nghĩa là gì (Điều 15, ngoài lát cắt).
* **C37**: Một người cho không (không bán) một chai rượu cho người 30 tuổi tại một phòng khám. — Tiêu đề Điều 19 chỉ nói «bán»; Điều 5 khoản 3 phủ «cung cấp» chỉ với người chưa đủ 18 tuổi. Việc «cung cấp» cho người lớn tại cơ sở y tế có bị cấm không là chỗ luật không nói; cần biết liệu «bán» được hiểu rộng bao nhiêu.

### 3.6 Khoảng trống độ phủ (nói thẳng)

* **Chỉ hai trạng thái được thử**: `forbidden` và `noNormApplies`. Mô-đun chỉ có lệnh cấm, nên `required`, `explicitlyPermitted` và `clash` không có ca nào ở mô-đun này (đã thử với mô-đun đồ chơi trong `Verify/Cases.lean`).
* **Không có ca nào cho nhánh (i) của Điều 5 khoản 11** ngoài C24 (không đạt, đã biết).
* **Điều 11, 15, 16, 32** không có ca nào: ngoài lát cắt, chưa phân tích.
* **Ranh giới chỉ là nhãn dải** (xem mục 3.3). Các ca không phát hiện sai số ở chỗ cắt dải.
* **Ca và mã hóa cùng một nguồn**: việc 36/37 ca đạt không phải bằng chứng khớp luật; chỉ người duyệt (`sale-group-cases.md`) trả lời được điều đó.
