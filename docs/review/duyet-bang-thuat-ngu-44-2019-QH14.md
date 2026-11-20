# Phiếu duyệt bảng thuật ngữ: 44/2019/QH14

Mỗi hàng là một act (hành vi) hoặc một atom (khái niệm dùng trong điều kiện). Đánh dấu **đúng một** ô bằng cách đổi `☐` thành `☒`. Đừng xóa lựa chọn hay cột nào.

- **Chấp nhận**: giải thích đúng nghĩa của luật, các nguồn đúng, và (với atom có nhãn) các nhãn tách nhau và đủ. Một id dùng ở nhiều điều sẽ là **một** khái niệm: chỉ chấp nhận nếu mọi điều nêu ở «Nguồn» đều nói cùng một thứ.
- **Bác**: sai nghĩa, gộp hai khái niệm khác nhau, hoặc nhãn sai. Phải ghi lý do. Mục bị bác không được dùng nữa.
- **Để sau**: chưa quyết; mục vẫn chưa duyệt và mọi norm dùng nó vẫn bị chặn.

Duyệt bảng đi **trước** phiếu norm: sau khi áp phiếu này, mọi phiếu norm lập trước đó hết hiệu lực (chúng ghim sha256 của bảng).

Bảng thuật ngữ: `data/glossary/44-2019-QH14.json`

sha256 bảng thuật ngữ: c7d31df9f14d90d5996982c010421188fb6595e4095a032f4b1e89b050eeb37f

Người duyệt: 

Ngày duyệt (YYYY-MM-DD): 

## 1. Mục chờ duyệt

| Mã | Loại | Giải thích | Giá trị | Nguồn | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|
| T:act:ban_ruou_bia | act | bán rượu, bia (trao đổi có trả tiền) | — | Điều 5 khoản 3; Điều 19 tiêu đề | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:act:cung_cap_ruou_bia | act | cung cấp rượu, bia (gồm cả cho không, tặng — theo ý kiến người duyệt 2026-11-18, Q3) | — | Điều 5 khoản 3 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:act:khuyen_mai_ruou_bia | act | khuyến mại rượu, bia trong hoạt động kinh doanh | — | Điều 5 khoản 3; Điều 5 khoản 9 nhánh (i) | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:act:dung_ruou_bia_lam_qua_khuyen_mai | act | dùng rượu, bia để khuyến mại dưới mọi hình thức (làm quà, hàng tặng) | — | Điều 5 khoản 9 nhánh (ii) | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:act:ban_ruou_bia_bang_may_tu_dong | act | bán rượu, bia bằng máy bán hàng tự động | — | Điều 5 khoản 11 nhánh (ii) | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:tuoi_nguoi_nhan | tình huống | tuổi của người được bán, cung cấp hoặc khuyến mại rượu, bia | «chưa đủ 18 tuổi» (Điều 5 khoản 3)<br>«từ đủ 18 tuổi trở lên» (KHÔNG có nguồn — ghi chú: không khoản nào nêu; là phần bù của «chưa đủ 18 tuổi» (Điều 5 khoản 3), giả định của người mã hóa) | Điều 5 khoản 3 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:do_con | tình huống | độ cồn của rượu, bia (Điều 2 khoản 4 định nghĩa độ cồn) | «dưới 15 độ» (KHÔNG có nguồn — ghi chú: phần bù của «từ 15 độ trở lên» (Điều 5 khoản 9); Điều 11 có tiêu đề «có độ cồn dưới 15 độ». Chưa tách ngưỡng 5,5 độ của Điều 12, 13, 15)<br>«từ 15 độ trở lên» (Điều 5 khoản 9) | Điều 2 khoản 4; Điều 5 khoản 9 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:dia_diem_co_so_y_te | tình huống | địa điểm là cơ sở y tế | đúng / sai | Điều 19 khoản 1 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:dia_diem_co_so_giao_duc | tình huống | địa điểm là cơ sở giáo dục | đúng / sai | Điều 19 khoản 2 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:dia_diem_cham_soc_vui_choi | tình huống | địa điểm là cơ sở hoặc khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí | đúng / sai | Điều 19 khoản 3 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:dia_diem_cai_nghien_giam_giu | tình huống | địa điểm là cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân hoặc cơ sở giam giữ khác | đúng / sai | Điều 19 khoản 4 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:dia_diem_bao_tro_xa_hoi | tình huống | địa điểm là cơ sở bảo trợ xã hội | đúng / sai | Điều 19 khoản 5 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:dia_diem_noi_lam_viec_co_quan | tình huống | địa điểm là nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập | đúng / sai | Điều 19 khoản 6 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:dia_diem_duoc_phep_kinh_doanh | tình huống | địa điểm được phép kinh doanh rượu, bia (ngoại lệ của Điều 19 khoản 6) | đúng / sai | Điều 19 khoản 6 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| T:atom:danh_cho_nguoi_chua_du_18 | tham số | địa điểm «dành cho» người chưa đủ 18 tuổi (khái niệm mở, luật không định nghĩa) | đúng / sai | Điều 19 khoản 3 | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |

## 2. Đã quyết trước đây (chỉ để đọc)

- (không có)
