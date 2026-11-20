# Phiếu duyệt norm suy ra: 44/2019/QH14

Mỗi hàng là một **cách đọc** mà luật không viết thẳng (ADR-0028). Đánh dấu **đúng một** ô bằng cách đổi `☐` thành `☒`; đừng xóa lựa chọn hay cột nào.

- **Chấp nhận**: từ các đơn vị ở «Suy ra từ», một người đọc luật cẩn thận sẽ rút ra đúng norm này, với đúng điều kiện và ngoại lệ ghi ở đây (không rộng hơn, không hẹp hơn).
- **Bác**: cách đọc sai, hoặc rộng hơn hay hẹp hơn luật. Phải ghi lý do. Nếu chỉ thiếu một ngoại lệ, ghi ngoại lệ đó vào lý do; người sửa sẽ thêm và mục được duyệt lại.
- **Để sau**: chưa quyết.

Gợi ý: mục «Kết quả đầu tiên» của `docs/decisions/0028-derived-norms.md` cho biết mỗi cách đọc va chạm với norm nào của luật. Một va chạm không tự nó là lý do bác, nhưng cho thấy chỗ cần đọc kỹ.

Sau khi duyệt, sửa một mục đã duyệt làm nó hết hiệu lực (công cụ ghi sha256 nội dung lúc duyệt).

Tệp norm suy ra: `data/derived/44-2019-QH14.json`

sha256 tệp norm suy ra: be6ea9d2eb6ffaa453fa0e341acdc9a955bee29892933d0ecb5fedc0709379cb

sha256 bảng thuật ngữ: 65f3dc9f47036fd2315d7e2b094d78c0c061da87a1ef70b93a911aab48aba020

Người duyệt: Vũ Đức Phong

Ngày duyệt (YYYY-MM-DD): 2026-11-20

## 0. Thuật ngữ các norm suy ra dùng (chỉ để đọc; duyệt ở phiếu bảng thuật ngữ)

- act kinh_doanh_ruou_bia [proposed]: kinh doanh rượu, bia (nguồn: Điều 5 khoản 11 nhánh (i); Điều 5 khoản 12 nhánh (i))
- atom loai_do_uong [proposed]: đồ uống là rượu hay bia (nguồn: Điều 5 khoản 7; Điều 5 khoản 11 nhánh (i))
- atom co_giay_phep_hoac_dang_ky_kinh_doanh_ruou [proposed]: người kinh doanh rượu có giấy phép hoặc đã đăng ký theo hình thức mà loại hình kinh doanh đó phải có (nguồn: Điều 5 khoản 11 nhánh (i))
- atom do_con_nguong_5_5 [proposed]: độ cồn của rượu so với ngưỡng 5,5 độ (nguồn: Điều 15 khoản 1; Điều 15 khoản 5)
- atom co_dang_ky_kinh_doanh [proposed]: đã đăng ký kinh doanh theo quy định của pháp luật (đăng ký kinh doanh chung, khác co_giay_phep_hoac_dang_ky_kinh_doanh_ruou) (nguồn: Điều 15 khoản 4 điểm a)
- atom dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou [proposed]: đáp ứng điều kiện theo từng loại hình mua bán rượu (nội dung điều kiện do văn bản khác quy định) (nguồn: Điều 15 khoản 4 điểm b)

## 1. Norm suy ra chờ duyệt

| Mã | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Suy ra từ | Cách suy ra | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|---|---|
| D:D1 | được phép | `kinh_doanh_ruou_bia` | («loai_do_uong = rượu» VÀ «co_giay_phep_hoac_dang_ky_kinh_doanh_ruou») | — | Điều 5 khoản 11 nhánh (i); Điều 15 khoản 4 | Suy ngược từ Điều 5 khoản 11 nhánh (i): kinh doanh rượu bị cấm khi không có giấy phép hoặc không đăng ký, nên khi có thì được kinh doanh; Điều 15 khoản 4 cho thấy giấy phép mua bán rượu là cách có được quyền đó. Luật không viết câu «được kinh doanh» này. (đề xuất bởi Claude (AI), 2026-11-20) | ☐ Chấp nhận
| D:D2 | được phép | `kinh_doanh_ruou_bia` | («loai_do_uong = rượu» VÀ «do_con_nguong_5_5 = từ 5,5 độ trở lên» VÀ «co_dang_ky_kinh_doanh» VÀ «dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou») | — | Điều 15 khoản 4 | Đọc danh sách «Điều kiện cấp phép mua bán rượu ... bao gồm» (Điều 15 khoản 4) là điều kiện đủ, như bản dịch lần 3: đủ các điểm a, b thì được kinh doanh (mua bán) rượu từ 5,5 độ trở lên. Bản dịch lần 4 không chọn cách đọc này (coi là điều kiện cần); ghi ra để kiểm hệ quả của nó. (đề xuất bởi Claude (AI), 2026-11-20) |☐ Để sau (tôi đồng ý với bản dịch lần 3: đủ các điểm a, b thì đã đủ điều kiện để kinh doanh rượu từ 5,5 độ trở lên)

## 2. Đã quyết trước đây (chỉ để đọc)

- (không có)
