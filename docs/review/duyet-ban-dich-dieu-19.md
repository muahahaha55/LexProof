# Phiếu duyệt bản dịch: Điều 19 (44/2019/QH14)

Đánh dấu **đúng một** ô ở mỗi hàng bằng cách đổi `☐` thành `☒`. Đọc từng norm với chữ của luật (cột «Trích dẫn» và văn bản gốc). Bác một norm thì phải ghi lý do; norm đó sẽ được ghi là «không mã hóa» kèm lý do của bạn.
Bác một giả định, hoặc không đồng ý để một khoản ngoài phạm vi, thì bản dịch **không** được đưa vào thư viện: phải dịch lại.

Bản dịch: `eval/translate/article19.llm.json`

sha256 bản dịch: 043f2377c73c490ce9c31a4ae11877d6d02039c8acc85ddd10dcacbe1bbb42f3

Người duyệt: Vũ Đức Phong

Ngày duyệt (YYYY-MM-DD): 2026-11-20

## 1. Norm

| Mã | Nguồn | Trích dẫn | Tính chất | Hành vi | Áp dụng khi | Ngoại lệ | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|---|---|
| N:19.1 | Điều 19 khoản 1 | «Cơ sở y tế» | cấm | `ban_ruou_bia` | «S1 Địa điểm là cơ sở y tế» | — | [x] ☐ Chấp nhận<br>☐ Bác |  |
| N:19.2 | Điều 19 khoản 2 | «Cơ sở giáo dục» | cấm | `ban_ruou_bia` | «S2 Địa điểm là cơ sở giáo dục» | — | [x] ☐ Chấp nhận<br>☐ Bác |  |
| N:19.3 | Điều 19 khoản 3 | «Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi» | cấm | `ban_ruou_bia` | («S3 Địa điểm là cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí» VÀ «P1 Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí là nơi dành cho người chưa đủ 18 tuổi» (khái niệm mở, người dùng tự quyết)) | — | [x] ☐ Chấp nhận<br>☐ Bác |  |
| N:19.4 | Điều 19 khoản 4 | «Cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân và cơ sở giam giữ khác» | cấm | `ban_ruou_bia` | («S4 Địa điểm là cơ sở cai nghiện» HOẶC «S5 Địa điểm là cơ sở giáo dục bắt buộc» HOẶC «S6 Địa điểm là trường giáo dưỡng» HOẶC «S7 Địa điểm là cơ sở giam giữ phạm nhân» HOẶC «S8 Địa điểm là cơ sở giam giữ khác») | — | [x] ☐ Chấp nhận<br>☐ Bác |  |
| N:19.5 | Điều 19 khoản 5 | «Cơ sở bảo trợ xã hội» | cấm | `ban_ruou_bia` | «S9 Địa điểm là cơ sở bảo trợ xã hội» | — | [x] ☐ Chấp nhận<br>☐ Bác |  |
| N:19.6 | Điều 19 khoản 6 | «Nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập, trừ địa điểm được phép kinh doanh rượu, bia» | cấm | `ban_ruou_bia` | («S10 Địa điểm là nơi làm việc của cơ quan nhà nước» HOẶC «S11 Địa điểm là nơi làm việc của tổ chức chính trị» HOẶC «S12 Địa điểm là nơi làm việc của tổ chức chính trị - xã hội» HOẶC «S13 Địa điểm là nơi làm việc của tổ chức chính trị xã hội - nghề nghiệp» HOẶC «S14 Địa điểm là nơi làm việc của đơn vị sự nghiệp công lập») | «S15 Địa điểm là địa điểm được phép kinh doanh rượu, bia» | [x] ☐ Chấp nhận<br>☐ Bác |  |

## 2. Giả định của bản dịch

| Mã | Giả định | Quyết định |
|---|---|---|
| A:1 | Tiêu đề Điều 19 («Địa điểm không bán rượu, bia») được áp dụng cho cả 6 khoản: mỗi khoản là một lệnh cấm (prohibition) đối với hành vi bán rượu, bia tại địa điểm nêu; act dùng chung là ban_ruou_bia. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:2 | Ngày hiệu lực 2020-01-01 không có trong đoạn văn bản được cung cấp; đây là thông tin ngoài văn bản, cần người đối chiếu xác nhận. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:3 | Mỗi khoản được mã hóa thành một norm, các loại địa điểm liệt kê trong cùng khoản được nối bằng «or» (không tách thành nhiều norm bằng «nhánh»). | [x] ☐ Chấp nhận<br>☐ Bác |
| A:4 | Khoản 3: «dành cho người chưa đủ 18 tuổi» là khái niệm mở nên đặt thành tham số P1, không tự quyết giá trị; đọc cụm này bổ nghĩa cho cả bốn loại (chăm sóc, nuôi dưỡng, vui chơi, giải trí), nên điều kiện là S3 và P1. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:5 | Khoản 4: «cơ sở giam giữ phạm nhân» và «cơ sở giam giữ khác» được tách thành hai atom riêng (S7, S8); «cơ sở giáo dục bắt buộc» được hiểu là một loại cơ sở duy nhất. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:6 | Khoản 6: «trừ địa điểm được phép kinh doanh rượu, bia» là ngoại lệ (exceptions), không phải quyền được phép; việc một địa điểm được phép kinh doanh do quy định khác xác định nên được mã hóa là atom tình huống S15 và không suy ra giá trị. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:7 | Khoản 6: ngoại lệ S15 được áp dụng cho toàn bộ danh sách nơi làm việc trong khoản (cơ quan nhà nước, các tổ chức chính trị, đơn vị sự nghiệp công lập), không chỉ cho mục cuối. | [x] ☐ Chấp nhận<br>☐ Bác |
| A:8 | Chỉ mã hóa hành vi «bán» theo tiêu đề điều; không mở rộng sang các hành vi khác như uống hay mang vào. | [x] ☐ Chấp nhận<br>☐ Bác |

## 3. Khoản để ngoài (`not_encoded`)

| Mã | Khoản | Lý do của bản dịch | Quyết định |
|---|---|---|---|
| — | (không có) | | |
