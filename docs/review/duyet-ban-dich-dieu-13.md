# Phiếu duyệt bản dịch: Điều 13 (44/2019/QH14)

Đánh dấu **đúng một** ô ở mỗi hàng bằng cách đổi `☐` thành `☒`. Đọc từng norm với chữ của luật (cột «Trích dẫn» và văn bản gốc). Bác một norm thì phải ghi lý do; norm đó sẽ được ghi là «không mã hóa» kèm lý do của bạn.
Bác một giả định, hoặc không đồng ý để một khoản ngoài phạm vi, thì bản dịch **không** được đưa vào thư viện: phải dịch lại.

Bản dịch: `eval/translate/article13.glossary.llm.json`

sha256 bản dịch: cb543b4dec68babb7169e2c8f90189c9a7a14a502b2c97caeafc86995ff51ebf

Bảng thuật ngữ: `data/glossary/44-2019-QH14.json`

sha256 bảng thuật ngữ: c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758

## 0. Thuật ngữ bản dịch dùng (chỉ để đọc; duyệt ở phiếu bảng thuật ngữ, trước phiếu này)

- act quang_cao_ruou_bia [approved]: quảng cáo rượu, bia (nguồn: Điều 5 khoản 7)
- atom do_con [approved]: độ cồn của rượu, bia (Điều 2 khoản 4 định nghĩa độ cồn) (nguồn: Điều 2 khoản 4; Điều 5 khoản 9)
  - nhãn «dưới 15 độ» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 2 khoản 4». Ghi chú: phần bù của «từ 15 độ trở lên» (Điều 5 khoản 9); Điều 11 có tiêu đề «có độ cồn dưới 15 độ». Chưa tách ngưỡng 5,5 độ của Điều 12, 13, 15
- atom loai_do_uong [approved]: đồ uống là rượu hay bia (nguồn: Điều 5 khoản 7; Điều 5 khoản 11 nhánh (i))
- atom do_con_nguong_5_5 [approved]: độ cồn của rượu so với ngưỡng 5,5 độ (nguồn: Điều 15 khoản 1; Điều 15 khoản 5)
- atom do_con_bia_nguong_5_5 [approved]: độ cồn của bia so với ngưỡng 5,5 độ (tương ứng với do_con_nguong_5_5 nhưng dành cho bia, vì mục đó chỉ nói về rượu) (nguồn: Điều 13)
  - nhãn «dưới 5,5 độ» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 13». Ghi chú: Điều 13 chỉ nêu bia «có độ cồn từ 5,5 độ trở lên»; nhãn này là phần bù để miền giá trị đầy đủ
- atom quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao [approved]: việc quảng cáo diễn ra trong các chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao (nguồn: Điều 13 khoản 1)
- atom quang_cao_tren_phuong_tien_quang_cao_ngoai_troi [approved]: việc quảng cáo được thực hiện trên phương tiện quảng cáo ngoài trời (nguồn: Điều 13 khoản 2)
- atom la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia [approved]: phương tiện quảng cáo là biển hiệu của cơ sở kinh doanh rượu, bia (nguồn: Điều 13 khoản 2)

Một id dùng ở nhiều điều là **một** khái niệm. Nếu norm dưới đây dùng id theo nghĩa khác giải thích ở trên, hãy bác norm đó và ghi lý do.

Người duyệt: 

Ngày duyệt (YYYY-MM-DD): 

## 1. Norm

| Mã | Nguồn | Trích dẫn | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|---|---|
| N:13.1 | Điều 13 khoản 1 | «Trong các chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao» | cấm | `quang_cao_ruou_bia` | (((«loai_do_uong = rượu» VÀ «do_con_nguong_5_5 = từ 5,5 độ trở lên» VÀ «do_con = dưới 15 độ») HOẶC («loai_do_uong = bia» VÀ «do_con_bia_nguong_5_5 = từ 5,5 độ trở lên»)) VÀ «quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao») | — | ☐ Chấp nhận<br>☐ Bác |  |
| N:13.2 | Điều 13 khoản 2 | «Trên các phương tiện quảng cáo ngoài trời, trừ biển hiệu của cơ sở kinh doanh rượu, bia» | cấm | `quang_cao_ruou_bia` | (((«loai_do_uong = rượu» VÀ «do_con_nguong_5_5 = từ 5,5 độ trở lên» VÀ «do_con = dưới 15 độ») HOẶC («loai_do_uong = bia» VÀ «do_con_bia_nguong_5_5 = từ 5,5 độ trở lên»)) VÀ «quang_cao_tren_phuong_tien_quang_cao_ngoai_troi») | «la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia» | ☐ Chấp nhận<br>☐ Bác |  |

## 2. Giả định của bản dịch

| Mã | Giả định | Quyết định |
|---|---|---|
| A:1 | Tính chất cấm của cả hai khoản lấy từ cụm «không quảng cáo trong trường hợp sau đây» của đoạn dẫn, vì các khoản 1 và 2 chỉ là phần nêu trường hợp. | ☐ Chấp nhận<br>☐ Bác |
| A:2 | Phạm vi của đoạn dẫn được lặp lại trong condition của từng norm: rượu từ 5,5 độ đến dưới 15 độ, hoặc bia từ 5,5 độ trở lên. | ☐ Chấp nhận<br>☐ Bác |
| A:3 | Với rượu, dùng do_con_nguong_5_5 «từ 5,5 độ trở lên» cùng do_con «dưới 15 độ» để biểu diễn «từ 5,5 độ đến dưới 15 độ». | ☐ Chấp nhận<br>☐ Bác |
| A:4 | Mục do_con_nguong_5_5 của bảng được định nghĩa là «độ cồn của rượu» nên không dùng cho bia. Quy tắc 14 không cho mở rộng mục đó, vì vậy đề xuất do_con_bia_nguong_5_5 riêng cho bia. | ☐ Chấp nhận<br>☐ Bác |
| A:5 | Với bia, điều luật không đặt giới hạn trên, nên không dùng do_con trong nhánh bia. | ☐ Chấp nhận<br>☐ Bác |
| A:6 | Ở khoản 1, cụm «chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao» được biểu diễn bằng một atom bool duy nhất, không tách riêng từng lĩnh vực hay tách «chương trình» với «hoạt động». | ☐ Chấp nhận<br>☐ Bác |
| A:7 | Chữ «trừ biển hiệu của cơ sở kinh doanh rượu, bia» ở khoản 2 được mã hóa là exception: nó làm lệnh cấm không áp dụng chứ không tạo ra quyền được phép quảng cáo. | ☐ Chấp nhận<br>☐ Bác |
| A:8 | Biển hiệu của cơ sở kinh doanh được hiểu là một loại phương tiện quảng cáo ngoài trời, nên exception chỉ có tác dụng khi quang_cao_tren_phuong_tien_quang_cao_ngoai_troi đúng. | ☐ Chấp nhận<br>☐ Bác |
| A:9 | Đoạn dẫn có dẫn chiếu tới Điều 12, nhưng chữ của chính khoản 1 và khoản 2 không dẫn chiếu tới đơn vị nào khác, nên «references» của hai norm để rỗng. | ☐ Chấp nhận<br>☐ Bác |
| A:10 | Ngày hiệu lực 2020-01-01 không có trong đoạn văn được cung cấp mà lấy từ hiểu biết chung về Luật 44/2019/QH14; người duyệt cần đối chiếu lại. | ☐ Chấp nhận<br>☐ Bác |

## 3. Khoản để ngoài (`not_encoded`)

| Mã | Khoản | Lý do của bản dịch | Quyết định |
|---|---|---|---|
| X:1 | Điều 13 | Phần «phải tuân thủ quy định tại Điều 12 của Luật này» trong đoạn dẫn chỉ dẫn chiếu sang Điều 12, không tự đặt ra nội dung nghĩa vụ. Nghĩa vụ đó thuộc phần mã hóa Điều 12, nên ở đây không tạo norm riêng. | ☐ Đồng ý để ngoài<br>☐ Không đồng ý |
