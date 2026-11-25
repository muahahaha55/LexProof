# ADR-0031: Thu gọn yêu cầu cho bản đồ án

- **Status**: **Accepted** 2026-11-25 (người phụ trách dự án đồng ý)
- **Ngày**: 2026-11-25
- **Liên quan**: [requirements.md](../requirements.md), [ADR-0019](0019-back-translation-renderer.md), [ADR-0024](0024-translation-manual-paste.md), [ADR-0030](0030-drafting-defects.md)

## Bối cảnh

Các yêu cầu Must do dự án tự đặt từ đầu, khi còn định gọi LLM tự động qua API. Đến 2026-11-25:

- Dự án không dùng API (không có kinh phí); bước dịch là dán tay (ADR-0024), người duyệt là hàng rào tin cậy.
- Nhiều trạng thái trong `requirements.md` đã lỗi thời: việc đã làm vẫn ghi Planned.
- Còn khoảng 5–7 ngày việc kỹ thuật cho các Must còn mở, trong khi phần quan trọng nhất còn lại của đồ án là đóng gói.

Mục tiêu: một danh sách yêu cầu đúng với sản phẩm thật, **không** hạ những yêu cầu bảo vệ tính đúng (soundness, phạm vi
trung thực, fail closed, truy vết nguồn, build kiểm tra).

## Quyết định

| Yêu cầu | Trước | Sau | Lý do |
|---|---|---|---|
| FR4 Sửa lỗi có giới hạn | Must, Planned | **Won't (bản đồ án)** | Chỉ có nghĩa khi dịch tự động qua API. Dịch lại khi bị bác do người làm, đã chạy thật (Điều 32 lần 2, Điều 5 lần 3). AC «không điều khoản nào bị loại mà không có lý do» vẫn đúng qua `not_encoded` và lý do bác ghi vào module |
| FR5 Dịch ngược | Must, Open | **Must, Implemented ở mức tối thiểu** | Phiếu duyệt in mỗi norm thành lời bằng bộ in tất định (`promote.words`), cạnh câu trích của luật. Đúng hướng «ưu tiên tất định» của ADR-0019. Dịch vòng bằng LLM (roundtrip) để lại cho nghiên cứu sau |
| N8 Scale | Must, Planned | **Should, «đo và ghi giới hạn»** | Kernel có giới hạn nhịp (`maxHeartbeats`): vượt thì build thất bại, không có kết quả, tức đã fail closed. Không làm `outOfBudget` |
| N9 Maintainability | Must, Planned | **Should, Implemented** | Đã kiểm thực tế: từ 2026-11-19 có 8 commit thêm 17 module `Laws` mà `Core/` không đổi |
| N5 Evaluability | Must, Planned | **Should, Partial** | Đã có gieo lỗi trên luật thật (`eval/entailment/`, E2, E5). Precision do người đánh giá thì phụ thuộc FR12 |
| N7, N10, N11 | Must, Planned | Must, **làm trong bước đóng gói** | Chủ yếu là tài liệu và một lệnh demo |
| FR12 | Should | Should, **ghi thành giới hạn** | Phụ thuộc người ngoài; không có thì chỉ có báo cáo nháp |

Giữ nguyên Must: FR1–FR3, FR5–FR11, N1–N4, N6, N7, N10–N12.

## Hệ quả

- Việc kỹ thuật còn lại trước đóng gói: FR9 (phản ví dụ bằng tiếng Việt) và cập nhật trạng thái.
- Câu trả lời trung thực khi được hỏi «hệ thống có tự sửa lỗi dịch không»: không; người duyệt bác, người dịch lại.
- Bài báo cần nhiều hơn bản đồ án: FR12, dịch vòng, đánh giá với nhãn độc lập. Quyết định này chỉ áp cho bản đồ án.
