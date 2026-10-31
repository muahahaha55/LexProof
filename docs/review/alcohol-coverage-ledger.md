# Sổ phủ: từng khoản và điểm của Luật 44/2019/QH14 so với mô-đun `Laws/AlcoholSale.lean` (BẢN NHÁP)

> **«encoded» ở đây nghĩa là: có một norm nháp, CHƯA AI DUYỆT, trích dẫn đơn vị này. Nó không nói gì về việc norm đó có khớp luật hay không.** Sổ này chỉ đếm xem đơn vị nào được nhắc tới và đơn vị nào không; nó không kiểm nội dung.

Nguồn: `data/segmented/44-2019-QH14.json` (do `pipeline/segment.py` tạo; bộ tách là công cụ chưa được kiểm độc lập), `eval/ledger/module.json` (do `Dump.lean` in từ mô-đun, tham chiếu đã qua `ClauseRef`), và bảng act mục C của `docs/slice1-notes.md`. Tạo bằng `python eval/ledger/make_ledger.py`; chạy hai lần cho kết quả giống nhau.

Mỗi đơn vị có đúng một trạng thái, xét theo thứ tự: *encoded* (norm trích dẫn đơn vị hoặc cha của nó) → *encoded (một phần)* (có norm nhưng một nhánh của đơn vị nằm trong `notEncoded`) → *not encoded* (mục `notEncoded` phủ đơn vị, kèm lý do của mô-đun) → *outside this module* (đơn vị nằm trong nhóm act mục C, tức thuộc mô-đun khác) → *UNACCOUNTED* (điều nằm trong phạm vi mô-đun mà không thuộc gì ở trên) → *chưa phân loại*.

**«Phạm vi mô-đun»** do tôi định nghĩa: các điều mà một norm đã mã hóa hoặc một mục `notEncoded` nhắc tới: Điều 2, Điều 5, Điều 11, Điều 15, Điều 16, Điều 19, Điều 32. Đây là một lựa chọn; nếu hiểu là khoảng từ điều nhỏ nhất đến lớn nhất thì UNACCOUNTED sẽ nhiều hơn rất nhiều.

Tiêu đề điều không được tính là khoản hay điểm. Các đoạn không đánh số (đoạn dẫn, Điều không chia khoản) được liệt kê riêng và không nằm trong tổng khoản/điểm.

## Tổng

| Trạng thái | Khoản | Điểm | Đoạn không đánh số |
|---|---|---|---|
| encoded | 8 | 0 | 0 |
| encoded (một phần) | 1 | 0 | 0 |
| not encoded | 11 | 2 | 1 |
| not encoded (một phần) | 0 | 0 | 1 |
| outside this module | 25 | 6 | 1 |
| chưa phân loại | 83 | 29 | 3 |
| UNACCOUNTED | 13 | 8 | 0 |
| **Cộng** | **141** | **45** | **6** |

**UNACCOUNTED: 21 đơn vị (khoản + điểm + đoạn không đánh số).** Số này chỉ có nghĩa theo định nghĩa «phạm vi mô-đun» ở trên.

Mọi tham chiếu cụ thể (khoản trở xuống) của norm và `notEncoded` đều có đơn vị tương ứng trong văn bản đã tách.

## UNACCOUNTED (đọc trước)

| Đơn vị | Dòng | Đầu đoạn |
|---|---|---|
| Điều 2 khoản 3 | 33–35 | 3. Cồn thực phẩm là hợp chất hữu cơ có công thức phân tử là C2H5OH và  |
| Điều 2 khoản 5 | 41–43 | 5. Tác hại của rượu, bia là ảnh hưởng, tác động có hại của rượu, bia đ |
| Điều 2 khoản 6 | 45–47 | 6. Nghiện rượu, bia là tình trạng lệ thuộc vào rượu, bia với biểu hiện |
| Điều 2 khoản 7 | 49–50 | 7. Sản xuất rượu thủ công là hoạt động sản xuất rượu bằng dụng cụ truy |
| Điều 2 khoản 8 | 52–53 | 8. Sản xuất rượu công nghiệp là hoạt động sản xuất rượu bằng máy móc,  |
| Điều 15 khoản 1 | 258–259 | 1. Điều kiện cấp phép sản xuất rượu công nghiệp có độ cồn từ 5,5 độ tr |
| Điều 15 khoản 1 điểm a | 260–260 | a) Doanh nghiệp được thành lập theo quy định của pháp luật; |
| Điều 15 khoản 1 điểm b | 261–262 | b) Có dây chuyền máy móc, thiết bị công nghiệp, quy trình công nghệ sả |
| Điều 15 khoản 1 điểm c | 263–264 | c) Bảo đảm điều kiện về an toàn thực phẩm và bảo vệ môi trường theo qu |
| Điều 15 khoản 1 điểm d | 265–266 | d) Có nhân viên kỹ thuật có trình độ, chuyên môn phù hợp với ngành, ng |
| Điều 15 khoản 2 | 267–268 | 2. Điều kiện cấp phép sản xuất rượu thủ công có độ cồn từ 5,5 độ trở l |
| Điều 15 khoản 2 điểm a | 269–270 | a) Doanh nghiệp, hợp tác xã, liên hiệp hợp tác xã hoặc hộ kinh doanh đ |
| Điều 15 khoản 2 điểm b | 271–271 | b) Bảo đảm điều kiện về an toàn thực phẩm theo quy định của pháp luật. |
| Điều 15 khoản 3 | 274–275 | 3. Điều kiện đối với hộ gia đình, cá nhân sản xuất rượu thủ công có độ |
| Điều 15 khoản 3 điểm a | 277–278 | a) Có hợp đồng mua bán với cơ sở có giấy phép sản xuất rượu và có đăng |
| Điều 15 khoản 3 điểm b | 280–280 | b) Bảo đảm điều kiện về an toàn thực phẩm theo quy định của pháp luật. |
| Điều 15 khoản 5 | 284–285 | 5. Chính phủ quy định chi tiết Điều này và quy định việc quản lý kinh  |
| Điều 32 khoản 1 | 544–547 | 1. Tuân thủ quy định của pháp luật về điều kiện kinh doanh rượu, bia;  |
| Điều 32 khoản 2 | 549–550 | 2. Cung cấp thông tin đầy đủ, chính xác về hoạt động kinh doanh của cơ |
| Điều 32 khoản 4 | 555–556 | 4. Thu hồi và xử lý rượu, bia không bảo đảm chất lượng, an toàn thực p |
| Điều 32 khoản 6 | 562–565 | 6. Cơ sở bán rượu, bia tiêu dùng tại chỗ nhắc nhở và có hình thức thôn |

## Toàn bộ đơn vị

| Đơn vị | Dòng | Trạng thái | Chi tiết |
|---|---|---|---|
| Điều 1 (đoạn không đánh số) | 21–24 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 2 (đoạn không đánh số) | 26–26 | not encoded (một phần) | Điều 2 khoản 1, 2, 4; Điều 2 khoản 1, 2, 4; Điều 2 khoản 1, 2, 4 |
| Điều 2 khoản 1 | 27–29 | not encoded | Điều 2 khoản 1, 2, 4 — định nghĩa rượu, bia, độ cồn: dùng làm từ vựng (atom S02), không phải norm |
| Điều 2 khoản 2 | 30–32 | not encoded | Điều 2 khoản 1, 2, 4 — định nghĩa rượu, bia, độ cồn: dùng làm từ vựng (atom S02), không phải norm |
| Điều 2 khoản 3 | 33–35 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 2 khoản 4 | 36–38 | not encoded | Điều 2 khoản 1, 2, 4 — định nghĩa rượu, bia, độ cồn: dùng làm từ vựng (atom S02), không phải norm |
| Điều 2 khoản 5 | 41–43 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 2 khoản 6 | 45–47 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 2 khoản 7 | 49–50 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 2 khoản 8 | 52–53 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 3 khoản 1 | 56–56 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 3 khoản 2 | 57–60 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 3 khoản 3 | 62–64 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 3 khoản 4 | 66–67 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 3 khoản 5 | 69–70 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 4 khoản 1 | 75–75 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 4 khoản 2 | 76–77 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 4 khoản 3 | 79–81 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 4 khoản 4 | 83–83 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 5 khoản 1 | 89–89 | outside this module | nhóm act (mục C): xui_giuc_ep_uong |
| Điều 5 khoản 2 | 90–90 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 5 khoản 3 | 91–91 | encoded | norm: 5.3-ban, 5.3-cung-cap, 5.3-khuyen-mai |
| Điều 5 khoản 4 | 92–93 | outside this module | nhóm act (mục C): su_dung_lao_dong_duoi_18_trong_ruou_bia |
| Điều 5 khoản 5 | 94–97 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 5 khoản 6 | 98–99 | outside this module | nhóm act (mục C): dieu_khien_phuong_tien_khi_co_nong_do_con |
| Điều 5 khoản 7 | 100–100 | outside this module | nhóm act (mục C): quang_cao_ruou_tu_15_do |
| Điều 5 khoản 8 | 101–102 | outside this module | nhóm act (mục C): cung_cap_thong_tin_suc_khoe_sai |
| Điều 5 khoản 9 | 103–104 | encoded | norm: 5.9-i, 5.9-ii |
| Điều 5 khoản 10 | 105–108 | outside this module | nhóm act (mục C): dung_nguyen_lieu_khong_dat |
| Điều 5 khoản 11 | 109–110 | encoded (một phần) | norm: 5.11-ii; phần KHÔNG mã hóa: Điều 5 khoản 11 nhánh (i) — khác nhóm act (kinh_doanh_ruou_khong_phep_hoac_dang_ky): thuộc mô-đun cấp phép (G12); thực chất là nghĩa vụ có giấy phép/đăng ký, phụ thuộc Điều 15 |
| Điều 5 khoản 12 | 111–112 | outside this module | nhóm act (mục C): kinh_doanh_tang_tru_van_chuyen_ruou_bia_khong_hop_phap, nhap_lau_ruou_bia |
| Điều 5 khoản 13 | 113–113 | outside this module | nhóm act (mục C): hanh_vi_cam_khac_do_luat_dinh |
| Điều 6 khoản 1 | 122–125 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 6 khoản 2 | 127–128 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 6 khoản 2 điểm a | 130–130 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 6 khoản 2 điểm b | 132–135 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 1 | 140–143 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 2 | 145–146 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 3 | 148–150 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 4 | 152–153 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 5 | 155–156 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 6 | 158–159 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 7 | 161–162 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 7 khoản 8 | 164–169 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 8 khoản 1 | 174–175 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 8 khoản 2 | 177–178 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 8 khoản 3 | 180–180 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 8 khoản 4 | 181–181 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 8 khoản 5 | 182–184 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 9 khoản 1 | 187–188 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 9 khoản 2 | 189–191 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 10 khoản 1 | 193–193 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 10 khoản 2 | 194–194 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 10 khoản 3 | 195–196 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 10 khoản 4 | 197–198 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 10 khoản 5 | 199–199 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 10 khoản 6 | 200–202 | outside this module | nhóm act (mục C): uong_ruou_bia |
| Điều 10 khoản 7 | 203–203 | outside this module | nhóm act (mục C): chinh_phu_quy_dinh_chi_tiet, uong_ruou_bia |
| Điều 11 (đoạn không đánh số) | 207–208 | not encoded | Điều 11 — ngoài lát cắt 1; chỉ yêu cầu «tuân thủ» luật này và pháp luật về khuyến mại (dẫn chiếu văn bản khác); chưa đọc phân tích |
| Điều 12 khoản 1 | 210–211 | outside this module | nhóm act (mục C): tuan_thu_quy_dinh_ve_quang_cao |
| Điều 12 khoản 2 | 212–212 | outside this module | nhóm act (mục C): quang_cao_co_noi_dung_cam |
| Điều 12 khoản 2 điểm a | 213–215 | outside this module | nhóm act (mục C): quang_cao_co_noi_dung_cam |
| Điều 12 khoản 2 điểm b | 216–218 | outside this module | nhóm act (mục C): quang_cao_co_noi_dung_cam |
| Điều 12 khoản 3 | 219–220 | outside this module | nhóm act (mục C): chinh_phu_quy_dinh_chi_tiet, quang_cao_o_noi_khong_duoc_phep |
| Điều 12 khoản 3 điểm a | 221–222 | outside this module | nhóm act (mục C): quang_cao_o_noi_khong_duoc_phep |
| Điều 12 khoản 3 điểm b | 223–223 | outside this module | nhóm act (mục C): quang_cao_o_noi_khong_duoc_phep |
| Điều 12 khoản 3 điểm c | 224–227 | outside this module | nhóm act (mục C): chinh_phu_quy_dinh_chi_tiet, quang_cao_o_noi_khong_duoc_phep |
| Điều 12 khoản 3 điểm d | 228–230 | outside this module | nhóm act (mục C): quang_cao_o_noi_khong_duoc_phep |
| Điều 12 khoản 4 | 231–231 | outside this module | nhóm act (mục C): quang_cao_phai_co_canh_bao |
| Điều 12 khoản 5 | 232–235 | outside this module | nhóm act (mục C): quang_cao_dien_tu_phai_chan_loc_tuoi |
| Điều 12 khoản 6 | 236–236 | outside this module | nhóm act (mục C): chinh_phu_quy_dinh_chi_tiet |
| Điều 13 (đoạn không đánh số) | 242–244 | outside this module | nhóm act (mục C): quang_cao_o_noi_khong_duoc_phep, tuan_thu_quy_dinh_ve_quang_cao |
| Điều 13 khoản 1 | 246–246 | outside this module | nhóm act (mục C): quang_cao_o_noi_khong_duoc_phep, tuan_thu_quy_dinh_ve_quang_cao |
| Điều 13 khoản 2 | 247–248 | outside this module | nhóm act (mục C): quang_cao_o_noi_khong_duoc_phep, tuan_thu_quy_dinh_ve_quang_cao |
| Điều 14 (đoạn không đánh số) | 250–252 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 15 khoản 1 | 258–259 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 1 điểm a | 260–260 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 1 điểm b | 261–262 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 1 điểm c | 263–264 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 1 điểm d | 265–266 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 2 | 267–268 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 2 điểm a | 269–270 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 2 điểm b | 271–271 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 3 | 274–275 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 3 điểm a | 277–278 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 3 điểm b | 280–280 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 15 khoản 4 | 281–281 | not encoded | Điều 15 khoản 4 — ngoài lát cắt 1; điều kiện cấp phép mua bán rượu từ 5,5 độ; định nghĩa «được phép kinh doanh» dùng ở 19.6 (S20) nằm ở đây; chưa đọc phân tích |
| Điều 15 khoản 4 điểm a | 282–282 | not encoded | Điều 15 khoản 4 — ngoài lát cắt 1; điều kiện cấp phép mua bán rượu từ 5,5 độ; định nghĩa «được phép kinh doanh» dùng ở 19.6 (S20) nằm ở đây; chưa đọc phân tích |
| Điều 15 khoản 4 điểm b | 283–283 | not encoded | Điều 15 khoản 4 — ngoài lát cắt 1; điều kiện cấp phép mua bán rượu từ 5,5 độ; định nghĩa «được phép kinh doanh» dùng ở 19.6 (S20) nằm ở đây; chưa đọc phân tích |
| Điều 15 khoản 5 | 284–285 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 16 khoản 1 | 287–287 | not encoded | Điều 16 — ngoài lát cắt 1; điều kiện bán qua thương mại điện tử (nghĩa vụ hình thức, giao Chính phủ quy định biện pháp, dẫn pháp luật thương mại điện tử); chưa đọc phân tích |
| Điều 16 khoản 2 | 288–288 | not encoded | Điều 16 — ngoài lát cắt 1; điều kiện bán qua thương mại điện tử (nghĩa vụ hình thức, giao Chính phủ quy định biện pháp, dẫn pháp luật thương mại điện tử); chưa đọc phân tích |
| Điều 16 khoản 3 | 289–290 | not encoded | Điều 16 — ngoài lát cắt 1; điều kiện bán qua thương mại điện tử (nghĩa vụ hình thức, giao Chính phủ quy định biện pháp, dẫn pháp luật thương mại điện tử); chưa đọc phân tích |
| Điều 16 khoản 4 | 291–291 | not encoded | Điều 16 — ngoài lát cắt 1; điều kiện bán qua thương mại điện tử (nghĩa vụ hình thức, giao Chính phủ quy định biện pháp, dẫn pháp luật thương mại điện tử); chưa đọc phân tích |
| Điều 17 khoản 1 | 294–298 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 17 khoản 2 | 299–301 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 18 (đoạn không đánh số) | 303–305 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 19 khoản 1 | 309–309 | encoded | norm: 19.1 |
| Điều 19 khoản 2 | 310–310 | encoded | norm: 19.2 |
| Điều 19 khoản 3 | 312–313 | encoded | norm: 19.3 |
| Điều 19 khoản 4 | 315–316 | encoded | norm: 19.4 |
| Điều 19 khoản 5 | 318–318 | encoded | norm: 19.5 |
| Điều 19 khoản 6 | 319–321 | encoded | norm: 19.6 |
| Điều 20 khoản 1 | 326–328 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 20 khoản 2 | 330–332 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 20 khoản 3 | 334–337 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 21 khoản 1 | 343–344 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 21 khoản 2 | 345–350 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 21 khoản 3 | 352–354 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 21 khoản 4 | 356–358 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 22 khoản 1 | 363–364 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 22 khoản 1 điểm a | 366–367 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 22 khoản 1 điểm b | 369–371 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 22 khoản 1 điểm c | 373–375 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 22 khoản 1 điểm d | 377–378 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 22 khoản 2 | 380–381 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 1 | 384–384 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 1 điểm a | 385–385 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 1 điểm b | 386–387 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 2 | 388–389 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 2 điểm a | 390–390 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 2 điểm b | 393–393 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 2 điểm c | 394–395 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 2 điểm d | 396–396 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 2 điểm đ | 397–397 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 3 | 398–400 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 4 | 401–402 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 23 khoản 5 | 403–404 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 24 khoản 1 | 406–408 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 24 khoản 2 | 409–411 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 24 khoản 3 | 412–413 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 24 khoản 4 | 414–415 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 24 khoản 5 | 416–417 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 25 khoản 1 | 420–421 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 25 khoản 1 điểm a | 422–427 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 25 khoản 1 điểm b | 429–431 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 25 khoản 1 điểm c | 433–433 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 25 khoản 2 | 435–437 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 25 khoản 3 | 439–440 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 26 khoản 1 | 448–448 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 26 khoản 1 điểm a | 449–449 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 26 khoản 1 điểm b | 450–450 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 26 khoản 2 | 451–452 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 26 khoản 3 | 453–454 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 27 khoản 1 | 457–458 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 27 khoản 2 | 459–461 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 28 khoản 1 | 466–469 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 28 khoản 2 | 471–473 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 28 khoản 3 | 475–476 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 29 khoản 1 | 484–485 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 29 khoản 2 | 486–487 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 29 khoản 3 | 488–488 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 29 khoản 4 | 489–490 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 29 khoản 5 | 491–492 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 29 khoản 6 | 493–494 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 30 khoản 1 | 497–498 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 30 khoản 2 | 501–502 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 30 khoản 3 | 504–505 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 30 khoản 4 | 507–508 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 1 | 513–519 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 2 | 521–521 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 2 điểm a | 522–522 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 2 điểm b | 523–524 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 2 điểm c | 525–526 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 2 điểm d | 527–528 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 3 | 529–529 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 3 điểm a | 530–530 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 3 điểm b | 531–532 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 3 điểm c | 533–533 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 31 khoản 4 | 534–540 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 32 khoản 1 | 544–547 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 32 khoản 2 | 549–550 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 32 khoản 3 | 552–553 | not encoded | Điều 32 khoản 3, 5, 7 — ngoài lát cắt 1; trách nhiệm của cơ sở kinh doanh: 32.3 lao động dưới 18 (liên quan 5.4), 32.5 nghĩa vụ niêm yết (hình thức), 32.7 cấm mở điểm bán mới trong bán kính 100 m — khoảng cách không biểu diễn được bằng Core hiện tại |
| Điều 32 khoản 4 | 555–556 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 32 khoản 5 | 558–560 | not encoded | Điều 32 khoản 3, 5, 7 — ngoài lát cắt 1; trách nhiệm của cơ sở kinh doanh: 32.3 lao động dưới 18 (liên quan 5.4), 32.5 nghĩa vụ niêm yết (hình thức), 32.7 cấm mở điểm bán mới trong bán kính 100 m — khoảng cách không biểu diễn được bằng Core hiện tại |
| Điều 32 khoản 6 | 562–565 | UNACCOUNTED | điều nằm trong phạm vi mô-đun nhưng đơn vị không thuộc norm, notEncoded hay nhóm act nào |
| Điều 32 khoản 7 | 567–569 | not encoded | Điều 32 khoản 3, 5, 7 — ngoài lát cắt 1; trách nhiệm của cơ sở kinh doanh: 32.3 lao động dưới 18 (liên quan 5.4), 32.5 nghĩa vụ niêm yết (hình thức), 32.7 cấm mở điểm bán mới trong bán kính 100 m — khoảng cách không biểu diễn được bằng Core hiện tại |
| Điều 33 khoản 1 | 574–577 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 33 khoản 2 | 579–581 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 33 khoản 3 | 584–585 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 33 khoản 3 điểm a | 587–589 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 33 khoản 3 điểm b | 591–593 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 34 khoản 1 | 598–600 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 34 khoản 2 | 602–604 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 34 khoản 3 | 606–607 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 35 khoản 1 | 614–619 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 35 khoản 2 | 621–628 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 35 khoản 3 | 630–632 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 35 khoản 3 điểm a | 634–635 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 35 khoản 3 điểm b | 637–638 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 36 khoản 1 | 642–642 | chưa phân loại | không thuộc mô-đun và không có trong mục C |
| Điều 36 khoản 2 | 644–647 | chưa phân loại | không thuộc mô-đun và không có trong mục C |

## Giới hạn

* «encoded» là bản nháp chưa duyệt; không phải «đúng luật».
* Một norm trích dẫn «Điều 5 khoản 11» được tính phủ cả khoản; phần «nhánh (i)» (ký hiệu của dự án, không phải đơn vị pháp lý) nằm trong `notEncoded` nên khoản 11 là *encoded (một phần)*.
* «outside this module» chỉ dựa vào cột «Khoản dùng» của mục C trong `slice1-notes.md`, do cùng một mô hình viết; Điều 12, 13 chỉ nằm ở đó vì sáu điều đã được phân tích.
* Sổ không biết đơn vị nào *nên* được mã hóa; nó chỉ cho thấy đơn vị nào không được nhắc tới.

