# POST-HOC: các mutant `missed-invisible` đi qua `analyzeReport`

**Nhãn: post-hoc.** D47 đến D50 (`LexProof/Verify/AnalyzeReport.lean`) được thiết kế **sau khi đã thấy** kết quả ở
[mutation-results.md](mutation-results.md); các trường báo cáo được chọn vì chúng liên quan tới điểm mù đã biết. Vì vậy đây **không phải tỉ lệ phát hiện** và không đo
khả năng bắt lỗi thật. Hai tài liệu thí nghiệm gốc không được sửa; tệp này chỉ thêm.

**Cách đếm.** Với mỗi mutant `missed-invisible` (kết quả `analyzeP` giống hệt gốc), so các trường của `analyzeReport` *ngoài* `core` với báo cáo của gốc cùng loại
(B0/B1/B2), dùng danh mục act do người gọi cung cấp = 5 act của nhóm (slice1-notes mục C). `core` bằng `analyzeP` ở cả 410 mutant (kiểm lúc chạy bằng `decide`).
«Trường cảnh báo» = cờ không-cặp-khắc-modality, ưu tiên mức cặp, act danh mục không dùng, act ngoài danh mục. «Bảng mô tả» = bảng act (số norm, modality) và danh sách act dùng một lần:
chúng đổi mỗi khi norm đổi modality hay act, nhưng chỉ là **số liệu để người duyệt đọc**, không phải cảnh báo.

| Toán tử | missed-invisible (n) | đổi ≥ 1 trường báo cáo | đổi trường «cảnh báo» | chỉ đổi bảng mô tả | không đổi gì | cờ «không có cặp khắc modality» | ưu tiên (mức cặp) | act danh mục không dùng | act ngoài danh mục | bảng act (số norm/modality) | act chỉ dùng một lần |
|---|---|---|---|---|---|---|---|---|---|---|---|
| M1 | 3 | 3 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 3 | 0 |
| M2 | 1 | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 1 |
| M3 | 3 | 0 | 0 | 0 | 3 | 0 | 0 | 0 | 0 | 0 | 0 |
| M4 | 15 | 0 | 0 | 0 | 15 | 0 | 0 | 0 | 0 | 0 | 0 |
| M7a | 14 | 14 | 2 | 12 | 0 | 0 | 0 | 2 | 0 | 14 | 12 |
| M7b | 17 | 17 | 17 | 0 | 0 | 0 | 0 | 2 | 17 | 17 | 17 |
| M8a | 16 | 0 | 0 | 0 | 16 | 0 | 0 | 0 | 0 | 0 | 0 |
| M8d | 14 | 0 | 0 | 0 | 14 | 0 | 0 | 0 | 0 | 0 | 0 |
| M9a | 18 | 0 | 0 | 0 | 18 | 0 | 0 | 0 | 0 | 0 | 0 |

**Cách đọc.** «đổi ≥ 1 trường» lớn một phần vì bảng act mô tả lại đúng cái đã đột biến (đổi modality hay act thì bảng đổi); con số đáng chú ý hơn là cột «đổi trường cảnh báo».
Các điểm mù mà **không trường nào đổi** (cột cuối) là điểm mù D47–D50 không chạm tới: bỏ ngoại lệ, đổi tập dải/ngưỡng, bộ đọc đọc sai atom, `Cond.sit` trỏ nhầm.
Mutant `missed-hiding` (4 mutant) không nằm trong bảng này.
