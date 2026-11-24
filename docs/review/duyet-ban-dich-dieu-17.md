# Phiếu duyệt bản dịch: Điều 17 (44/2019/QH14)

Đánh dấu **đúng một** ô ở mỗi hàng bằng cách đổi `☐` thành `☒`. Đọc từng norm với chữ của luật (cột «Trích dẫn» và văn bản gốc). Bác một norm thì phải ghi lý do; norm đó sẽ được ghi là «không mã hóa» kèm lý do của bạn.
Bác một giả định, hoặc không đồng ý để một khoản ngoài phạm vi, thì bản dịch **không** được đưa vào thư viện: phải dịch lại.

Bản dịch: `eval/translate/article17.glossary.llm.json`

sha256 bản dịch: 9403e9b68ea848941d040289451d43325f18466f06c6e108320bb01818f3740a

Bảng thuật ngữ: `data/glossary/44-2019-QH14.json`

sha256 bảng thuật ngữ: 2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe

## 0. Thuật ngữ bản dịch dùng (chỉ để đọc; duyệt ở phiếu bảng thuật ngữ, trước phiếu này)

- act san_xuat_ruou_thu_cong [approved]: sản xuất rượu thủ công (bản thân hành vi sản xuất, không phải việc cấp phép) (nguồn: Điều 15 khoản 3)
- atom muc_dich_kinh_doanh [approved]: việc sản xuất rượu nhằm mục đích kinh doanh (nguồn: Điều 15 khoản 2)
- atom chu_the_la_ho_gia_dinh_ca_nhan [approved]: chủ thể sản xuất là hộ gia đình hoặc cá nhân (khác hộ kinh doanh) (nguồn: Điều 15 khoản 3)
- atom co_ban_ke_khai_gui_ubnd_cap_xa_ve_san_xuat_ruou_thu_cong [approved]: có bản kê khai gửi Ủy ban nhân dân cấp xã về lượng rượu được sản xuất, phạm vi sử dụng, cam kết bảo đảm an toàn thực phẩm và không bán rượu ra thị trường, theo mẫu do Bộ trưởng Bộ Công Thương quy định (nguồn: Điều 17 khoản 1)

Một id dùng ở nhiều điều là **một** khái niệm. Nếu norm dưới đây dùng id theo nghĩa khác giải thích ở trên, hãy bác norm đó và ghi lý do.

Người duyệt: Vũ Đức Phong

Ngày duyệt (YYYY-MM-DD): 2026-11-24

## 1. Norm

| Mã | Nguồn | Trích dẫn | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|---|---|
| N:17.1 | Điều 17 khoản 1 | «phải có bản kê khai gửi Ủy ban nhân dân cấp xã về lượng rượu được sản xuất, phạm vi sử dụng, cam kết bảo đảm an toàn thực phẩm và không bán rượu ra thị trường theo mẫu do Bộ trưởng Bộ Công Thương quy định» | cấm | `san_xuat_ruou_thu_cong` | («chu_the_la_ho_gia_dinh_ca_nhan» VÀ KHÔNG («muc_dich_kinh_doanh») VÀ KHÔNG («co_ban_ke_khai_gui_ubnd_cap_xa_ve_san_xuat_ruou_thu_cong»)) | — | [x] ☐ Chấp nhận<br>☐ Bác |  |

## 2. Giả định của bản dịch

| Mã | Giả định | Quyết định |
|---|---|---|
| A:1 | «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:2 | Nghĩa vụ «phải có bản kê khai» được biểu diễn là lệnh cấm sản xuất rượu thủ công khi hộ gia đình, cá nhân không nhằm mục đích kinh doanh mà chưa có bản kê khai; không biểu diễn là nghĩa vụ sản xuất. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:3 | Act san_xuat_ruou_thu_cong trùng act của Điều 15 khoản 3; đây là cùng hành vi sản xuất, nên hai điều có thể gặp nhau trong cùng tình huống và người duyệt cần xem đây có phải xung đột thật hay chỉ do mức hạt của act. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:4 | Dùng lại chu_the_la_ho_gia_dinh_ca_nhan và muc_dich_kinh_doanh của bảng; «không nhằm mục đích kinh doanh» là phủ định của muc_dich_kinh_doanh. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:5 | Mẫu bản kê khai do Bộ trưởng Bộ Công Thương quy định (văn bản khác); chỉ có atom bool «có bản kê khai», không mã hóa nội dung mẫu. | [x] ☐ Chấp nhận<br>☐ Bác |

## 3. Khoản để ngoài (`not_encoded`)

| Mã | Khoản | Lý do của bản dịch | Quyết định |
|---|---|---|---|
| X:1 | Điều 17 khoản 1 | Câu sau «Việc kê khai không phải nộp phí, lệ phí» chỉ miễn phí, không đặt nghĩa vụ hay cấm đoán về hành vi nào trong bảng thuật ngữ, nên không mã hóa. | [x] ☐ Đồng ý để ngoài<br>☐ Không đồng ý |
| X:2 | Điều 17 khoản 2 | Nghĩa vụ của Ủy ban nhân dân các cấp (hướng dẫn, báo cáo) là việc của cơ quan nhà nước, không có hành vi tương ứng trong bảng thuật ngữ. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định. | [x] ☐ Đồng ý để ngoài<br>☐ Không đồng ý |
