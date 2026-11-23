# Phiếu duyệt bản dịch: Điều 18 (44/2019/QH14)

Đánh dấu **đúng một** ô ở mỗi hàng bằng cách đổi `☐` thành `☒`. Đọc từng norm với chữ của luật (cột «Trích dẫn» và văn bản gốc). Bác một norm thì phải ghi lý do; norm đó sẽ được ghi là «không mã hóa» kèm lý do của bạn.
Bác một giả định, hoặc không đồng ý để một khoản ngoài phạm vi, thì bản dịch **không** được đưa vào thư viện: phải dịch lại.

Bản dịch: `eval/translate/article18.glossary.llm.json`

sha256 bản dịch: 8202d1e53167433814df39e761a340cf13668063a996e43bb62fa73fe040c5d0

Bảng thuật ngữ: `data/glossary/44-2019-QH14.json`

sha256 bảng thuật ngữ: 2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe

## 0. Thuật ngữ bản dịch dùng (chỉ để đọc; duyệt ở phiếu bảng thuật ngữ, trước phiếu này)

- act kinh_doanh_ruou_bia [approved]: kinh doanh rượu, bia (nguồn: Điều 5 khoản 11 nhánh (i); Điều 5 khoản 12 nhánh (i))
- atom ruou_bia_khong_bao_dam_chat_luong [approved]: rượu, bia không bảo đảm chất lượng (nguồn: Điều 5 khoản 12 nhánh (i))
- atom ruou_bia_khong_bao_dam_an_toan_thuc_pham [approved]: rượu, bia không bảo đảm an toàn thực phẩm (khác ruou_bia_khong_bao_dam_chat_luong) (nguồn: Điều 32 khoản 4)
- atom ruou_bia_khong_bao_dam_tieu_chuan_quy_chuan_ky_thuat [approved]: rượu, bia không bảo đảm tiêu chuẩn, quy chuẩn kỹ thuật (nội dung tiêu chuẩn do văn bản khác quy định) (nguồn: Điều 18)

Một id dùng ở nhiều điều là **một** khái niệm. Nếu norm dưới đây dùng id theo nghĩa khác giải thích ở trên, hãy bác norm đó và ghi lý do.

Người duyệt: 

Ngày duyệt (YYYY-MM-DD): 

## 1. Norm

| Mã | Nguồn | Trích dẫn | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|---|---|
| N:18.1 | Điều 18 | «Rượu, bia được kinh doanh, lưu hành tại Việt Nam phải bảo đảm tiêu chuẩn, quy chuẩn kỹ thuật, chất lượng sản phẩm, hàng hóa và an toàn thực phẩm» | cấm | `kinh_doanh_ruou_bia` | («ruou_bia_khong_bao_dam_tieu_chuan_quy_chuan_ky_thuat» HOẶC «ruou_bia_khong_bao_dam_chat_luong» HOẶC «ruou_bia_khong_bao_dam_an_toan_thuc_pham») | — | ☐ Chấp nhận<br>☐ Bác |  |

## 2. Giả định của bản dịch

| Mã | Giả định | Quyết định |
|---|---|---|
| A:1 | «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu. | ☐ Chấp nhận<br>☐ Bác |
| A:2 | Điều 18 chỉ có một đoạn, không chia khoản, nên «source» là «Điều 18». | ☐ Chấp nhận<br>☐ Bác |
| A:3 | Nghĩa vụ «phải bảo đảm» được biểu diễn là lệnh cấm kinh doanh khi rượu, bia không bảo đảm một trong ba yêu cầu (tiêu chuẩn, quy chuẩn kỹ thuật; chất lượng; an toàn thực phẩm), tức đủ cả ba mới được kinh doanh. | ☐ Chấp nhận<br>☐ Bác |
| A:4 | Dùng lại ruou_bia_khong_bao_dam_chat_luong và ruou_bia_khong_bao_dam_an_toan_thuc_pham của bảng; chữ «chất lượng sản phẩm, hàng hóa» được coi là cùng nghĩa với «chất lượng». | ☐ Chấp nhận<br>☐ Bác |
| A:5 | Cụm «theo quy định của pháp luật» dẫn chiếu văn bản khác nên không ghi vào «references». | ☐ Chấp nhận<br>☐ Bác |

## 3. Khoản để ngoài (`not_encoded`)

| Mã | Khoản | Lý do của bản dịch | Quyết định |
|---|---|---|---|
| X:1 | Điều 18 | Chữ «lưu hành» không có act tương ứng trong bảng thuật ngữ (bảng chỉ có kinh_doanh_ruou_bia); phần «lưu hành» của nghĩa vụ chưa được mã hóa. Để người duyệt quyết định có thêm act mới hay không. | ☐ Đồng ý để ngoài<br>☐ Không đồng ý |
