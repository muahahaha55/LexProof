# ADR-0023: Báo cáo do một lệnh sinh, kèm định lý kernel của từng kết quả chính

- **Status**: **Accepted** cho công cụ nháp
- **Trạng thái cài đặt**: **Implemented** (Python, không tin cậy): `pipeline/report.py`, `eval/report/Dump.lean`
- **Ngày**: 2026-10-31
- **Liên quan**: [ADR-0011](0011-trust-boundary-human-approval.md), FR9, FR10

## Bối cảnh

Một kết quả như «consistentOn» dễ bị đọc quá mức, nhất là khi mô-đun không có cặp modality nào có thể xung đột.

## Quyết định

Báo cáo tiếng Việt chỉ do `pipeline/report.py` sinh, không sửa tay. Nó luôn có biểu ngữ trạng thái, mục phạm vi và mục «KHÔNG nói gì». Với mỗi kết quả chính nó nêu tên định lý kernel (đọc từ mã nguồn) và việc máy diễn giải có khớp phát biểu không; không có định lý thì ghi «chưa có định lý kernel cho kết quả này». `reviewed` bị từ chối nếu phiếu ca thử chưa đủ hoặc mô-đun đã đổi so với mã băm trong phiếu.

## Hệ quả

- Công cụ không tin cậy: nó có thể trình bày sai; test (`pipeline/tests/test_report.py`) chỉ bắt các sai đã nghĩ tới.
- `reviewed` chỉ ghi nhận phiếu đủ chữ; không kiểm danh tính hay nội dung.
- Mã băm tệp phụ thuộc kết thúc dòng (Git LF, Windows CRLF); báo cáo ghi cả hai cách băm.
