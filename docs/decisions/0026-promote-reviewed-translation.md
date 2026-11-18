# ADR-0026: Đưa bản dịch đã duyệt vào `LexProof/Laws/` bằng phiếu có ghim sha256, kèm định lý kernel

- **Status**: **Accepted** (bước 2 của `docs/roadmap.md`)
- **Trạng thái cài đặt**: **Tested** (Python, không tin cậy): `pipeline/promote.py`, `pipeline/tests/test_promote.py`. Chưa có module thật nào được đưa vào: cần một phiếu do người điền.
- **Ngày**: 2026-11-18
- **Liên quan**: [ADR-0011](0011-trust-boundary-human-approval.md), [ADR-0024](0024-translation-manual-paste.md), [ADR-0025](0025-run-command-draft-path.md)

## Bối cảnh

Ranh giới tin cậy (ADR-0011) đòi hỏi đầu ra LLM phải được người phê duyệt trước khi vào `Laws`. Trước đây việc này làm tay, không có bản ghi nào nối một module với lần duyệt.

## Quyết định

1. `promote.py sheet` lập phiếu duyệt Markdown cho một bản dịch: mỗi norm, mỗi giả định, mỗi khoản để ngoài là một hàng có ô đánh dấu; phiếu ghi sha256 của bản dịch.
2. `promote.py promote` từ chối nếu: bản dịch có phát hiện của `check`; sha256 trong phiếu khác bản dịch hiện tại; thiếu người duyệt hoặc ngày; hàng nào không có đúng một ô được đánh dấu; norm bị bác mà không có lý do; **bất kỳ giả định nào bị bác** hoặc **bất kỳ khoản để ngoài nào không được đồng ý** (khi đó bản dịch phải làm lại); không còn norm nào được chấp nhận; các phiếu gộp có người duyệt hoặc ngày khác nhau; module đã tồn tại.
3. Norm bị bác chuyển thành mục `notEncoded` kèm lý do của người duyệt, không bị bỏ lặng lẽ.
4. Module sinh ra có `status := .reviewed`, các định lý `refs_parse` (mọi tham chiếu phân tích được), `silent` (`pfindings = []`), và `consistent` + `no_conflict` hoặc `has_conflict`, tất cả `decide +kernel`. Kết quả được chạy thử trước để viết đúng định lý; kernel kiểm khi `lake build`.
5. Module được import vào `LexProof.lean` và `Cert/Audit.lean`; nếu `lake build` (gồm hai audit) thất bại thì cả ba tệp được trả về như cũ.

## Hệ quả

- «Đã duyệt» chỉ có nghĩa: một người đánh dấu mọi hàng của một phiếu gắn với đúng bản dịch đó. Công cụ không kiểm danh tính hay độ đúng.
- Thời gian kernel tăng theo số norm: 25 norm của Điều 5 và Điều 19 mất khoảng 90 giây.
- Các khái niệm dùng chung giữa các điều vẫn bị tách đôi (như ADR-0025) cho tới khi có bảng thuật ngữ (FR2).
