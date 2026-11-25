# Phiếu duyệt cạnh kéo theo: 44/2019/QH14

Mỗi hàng là một **cách đọc**: «làm việc ở cột A thì nhất thiết cũng làm việc ở cột B» (ADR-0029). Luật không viết thẳng các câu này. Đánh dấu **đúng một** ô bằng cách đổi `☐` thành `☒`; đừng xóa lựa chọn hay cột nào.

- **Chấp nhận**: trong mọi tình huống luật nói tới, ai làm A thì cũng làm B.
- **Bác**: có tình huống làm A mà không làm B, hoặc hai việc không liên quan. Phải ghi lý do.
- **Để sau**: chưa quyết.

Một cạnh được chấp nhận sẽ làm lệnh cấm B áp cho A, và nghĩa vụ A kéo theo nghĩa vụ B. Một cạnh sai tạo xung đột giả; thiếu một cạnh có thể che xung đột thật.

Tệp cạnh: `data/edges/44-2019-QH14.json`

sha256 tệp cạnh: 95d9b63981a7c7cf3a36530e72cc1245f8644a6231ac8011567a3a86399f54ed

Người duyệt: 

Ngày duyệt (YYYY-MM-DD): 

| Mã | A (làm việc này) | B (thì cũng làm việc này) | Nguồn | Cách đọc | Quyết định | Lý do (bắt buộc nếu bác) |
|---|---|---|---|---|---|---|
| E:E9 | `thu_hoi_xu_ly_ruou_bia` | `van_chuyen_ruou_bia` | Điều 32 khoản 4 | Thu hồi rượu, bia đã bán ra thì phải chở hàng về; KÉM CHẮC: có thể xử lý tại chỗ mà không chở. (đề xuất bởi Claude (AI), 2026-11-25) | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
| E:E10 | `thu_hoi_xu_ly_ruou_bia` | `tang_tru_ruou_bia` | Điều 32 khoản 4 | Thu hồi rồi mới xử lý thì phải giữ hàng trong lúc chờ xử lý; KÉM CHẮC: «tàng trữ» có thể chỉ việc cất giữ để buôn bán. (đề xuất bởi Claude (AI), 2026-11-25) | ☐ Chấp nhận<br>☐ Bác<br>☐ Để sau |  |
