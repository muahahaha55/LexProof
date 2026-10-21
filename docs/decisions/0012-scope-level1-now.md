# ADR-0012: Phạm vi — Level 1 bây giờ, Level 2 về sau

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0007](0007-keep-level2-fields-in-sourceid.md), [ADR-0006](0006-defer-subject-and-time.md), FR13

## Bối cảnh

Có hai mức nhất quán:

- **Level 1**: trong *một* văn bản — cùng tình huống mà có nghĩa vụ/cấm/cho phép
  xung đột và không có ưu tiên rõ ràng; cộng tham chiếu treo.
- **Level 2**: *giữa* nhiều văn bản — cần thứ bậc hiệu lực pháp lý (luật > nghị
  định > thông tư), ngày hiệu lực, và quy tắc văn bản sau thay thế văn bản trước.

Level 2 hấp dẫn hơn về mặt nghiên cứu, nhưng nó **chứa** Level 1: nếu quan hệ
xung đột trong một văn bản còn chưa đúng thì so sánh giữa các văn bản vô nghĩa.

## Quyết định

Chỉ làm **Level 1**. Không cài Level 2. Nhưng giữ sẵn các trường lược đồ mà
Level 2 sẽ cần (`docId`, `docType`, `effective` —
[ADR-0007](0007-keep-level2-fields-in-sourceid.md)) để sau này không phải duyệt
lại dữ liệu đã duyệt.

Phạm vi lĩnh vực: văn bản pháp luật tiếng Việt nói chung, **không** phải quy chế
đào tạo của trường đại học.

## Hệ quả

**Tốt**
- Phạm vi đủ nhỏ để làm xong và làm *đúng* trong khuôn một đồ án.
- `check` chỉ cần nhận một `List Norm` và không cần biết gì về thứ bậc văn bản.
- Đường mở rộng rõ ràng: cùng `Conflict`, thêm một bước phân xử theo thứ bậc.

**Xấu**
- Loại xung đột thường gặp nhất trong thực tế — thông tư trái nghị định — **nằm
  ngoài phạm vi**. Cần nói rõ điều này trong mọi báo cáo để không gây hiểu nhầm
  về giá trị của công cụ.
- `Scope` hiện có `docId` nhưng không có cơ chế nào bảo đảm mọi norm trong một
  lần `check` thuộc cùng một văn bản. `scopeOf` chỉ lấy `docId` từ
  `ns.head?` — nếu danh sách lẫn norm từ hai văn bản, `Scope` sẽ **báo sai** và
  không ai phát hiện. Đây là một khoảng trống đã biết.

## Kiểm chứng

Review (mọi báo cáo nêu rõ chỉ Level 1) + Test (ca kiểm thử chỉ dùng một văn bản).

## Trong code

`check (A : Atoms S P) (ns : List Norm)` nhận đúng một danh sách norm, không có
khái niệm nhiều văn bản. `Scope.docId` lấy từ `ns.head?` trong `scopeOf`
(`LexProof/Verify/Conflict.lean`). `LexProof/Laws/` sẽ có một module mỗi văn bản.
