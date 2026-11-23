# Phiếu duyệt bản dịch: Điều 21 (44/2019/QH14)

Đánh dấu **đúng một** ô ở mỗi hàng bằng cách đổi `☐` thành `☒`. Đọc từng norm với chữ của luật (cột «Trích dẫn» và văn bản gốc). Bác một norm thì phải ghi lý do; norm đó sẽ được ghi là «không mã hóa» kèm lý do của bạn.
Bác một giả định, hoặc không đồng ý để một khoản ngoài phạm vi, thì bản dịch **không** được đưa vào thư viện: phải dịch lại.

Bản dịch: `eval/translate/article21.glossary.llm.json`

sha256 bản dịch: ccf9b20701b2b5ca828c5a92e2e98cc1b72aee1f4da17ae3f6f9910cf944593e

Bảng thuật ngữ: `data/glossary/44-2019-QH14.json`

sha256 bảng thuật ngữ: 2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe

## 0. Thuật ngữ bản dịch dùng (chỉ để đọc; duyệt ở phiếu bảng thuật ngữ, trước phiếu này)

- act uong_ruou_bia [approved]: uống rượu, bia (nguồn: Điều 5 khoản 2; Điều 5 khoản 5)
- act thuc_hien_bien_phap_phong_ngua_phat_hien_ngan_chan_nguoi_dieu_khien_phuong_tien_van_tai_uong_ruou_bia [approved]: chủ động thực hiện biện pháp phòng ngừa, phát hiện, ngăn chặn người điều khiển phương tiện vận tải uống rượu, bia ngay trước và trong khi tham gia giao thông (nguồn: Điều 21 khoản 2)
- atom uong_truoc_hoac_trong_khi_tham_gia_giao_thong_voi_tu_cach_nguoi_dieu_khien [approved]: người uống rượu, bia là người điều khiển phương tiện giao thông và việc uống diễn ra trước hoặc trong khi tham gia giao thông (nguồn: Điều 21 khoản 1)

Một id dùng ở nhiều điều là **một** khái niệm. Nếu norm dưới đây dùng id theo nghĩa khác giải thích ở trên, hãy bác norm đó và ghi lý do.

Người duyệt: 

Ngày duyệt (YYYY-MM-DD): 

## 1. Norm

| Mã | Nguồn | Trích dẫn | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|---|---|
| N:21.1 | Điều 21 khoản 1 | «Người điều khiển phương tiện giao thông không uống rượu, bia trước và trong khi tham gia giao thông» | cấm | `uong_ruou_bia` | «uong_truoc_hoac_trong_khi_tham_gia_giao_thong_voi_tu_cach_nguoi_dieu_khien» | — | ☐ Chấp nhận<br>☐ Bác |  |
| N:21.2 | Điều 21 khoản 2 | «có trách nhiệm chủ động thực hiện biện pháp phòng ngừa, phát hiện, ngăn chặn người điều khiển phương tiện vận tải uống rượu, bia ngay trước và trong khi tham gia giao thông» | bắt buộc | `thuc_hien_bien_phap_phong_ngua_phat_hien_ngan_chan_nguoi_dieu_khien_phuong_tien_van_tai_uong_ruou_bia` | luôn áp dụng | — | ☐ Chấp nhận<br>☐ Bác |  |

## 2. Giả định của bản dịch

| Mã | Giả định | Quyết định |
|---|---|---|
| A:1 | «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu. | ☐ Chấp nhận<br>☐ Bác |
| A:2 | Khoản 1 chỉ có một lệnh cấm; chữ «trước và trong khi» được gộp vào một atom bool («trước hoặc trong khi»), vì luật cấm cả hai thời điểm, mỗi thời điểm đủ để vi phạm. | ☐ Chấp nhận<br>☐ Bác |
| A:3 | Act uong_ruou_bia trùng act của Điều 5 khoản 2 và khoản 5; đó đều là lệnh cấm nên không tạo xung đột phương thức, nhưng người duyệt cần xem việc dùng chung act có đúng ý hay không. | ☐ Chấp nhận<br>☐ Bác |
| A:4 | Khoản 2 dùng điều kiện true vì chủ thể (người đứng đầu cơ sở kinh doanh vận tải, chủ phương tiện) không được mã hóa thành atom; ghi nhận đây là nghĩa vụ chung của nhóm chủ thể đó. | ☐ Chấp nhận<br>☐ Bác |
| A:5 | «Chủ động thực hiện biện pháp» là một act nguyên khối, không mã hóa nội dung biện pháp. | ☐ Chấp nhận<br>☐ Bác |

## 3. Khoản để ngoài (`not_encoded`)

| Mã | Khoản | Lý do của bản dịch | Quyết định |
|---|---|---|---|
| X:1 | Điều 21 khoản 3 | Nghĩa vụ kiểm tra nồng độ cồn là của cơ quan, người có thẩm quyền. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định. | ☐ Đồng ý để ngoài<br>☐ Không đồng ý |
| X:2 | Điều 21 khoản 4 | Trách nhiệm đào tạo của Bộ Giao thông vận tải là việc của cơ quan nhà nước. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định. | ☐ Đồng ý để ngoài<br>☐ Không đồng ý |
