# ADR-0007: Giữ `docId`, `docType`, `effective` trong `SourceId` cho Level 2

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0012](0012-scope-level1-now.md), FR13, N6

## Bối cảnh

Level 2 (nhất quán **giữa** các văn bản, theo thứ bậc hiệu lực pháp lý) không
làm bây giờ. Nhưng nếu lược đồ `SourceId` chỉ có id điều khoản, thì khi làm Level
2 sẽ phải sửa lược đồ, và sửa lược đồ nghĩa là **mọi module `Laws` đã duyệt đều
phải duyệt lại** — chi phí cao nhất trong cả dự án, vì nó là chi phí *con người*.

## Quyết định

`SourceId` mang bốn trường ngay từ đầu:

```lean
structure SourceId where
  docId     : String
  docType   : DocType      -- law | decree | circular | decision | other
  effective : Date
  article   : String
```

Ba trường đầu **không được dùng** ở Level 1. Chúng được giữ chỉ để Level 2 và
FR13 (phiên bản theo ngày hiệu lực) không cần thay lược đồ.

## Hệ quả

**Tốt**
- Thêm Level 2 về sau không buộc duyệt lại dữ liệu đã duyệt.
- `DocType` đã có sẵn thứ hạng cần cho thứ bậc hiệu lực pháp lý.
- `effective : Date` phục vụ luôn FR13.

**Xấu**
- Trường không dùng là trường không được kiểm: người mã hóa có thể điền sai
  `docType` hay `effective` mà **không có gì phát hiện**, vì không có logic nào
  đọc chúng ở Level 1. Sai sót sẽ chỉ lộ ra khi làm Level 2.
- `Date` là ba số `Nat` không kiểm hợp lệ: `⟨2026, 99, 99⟩` hợp kiểu.
- Người mã hóa phải điền ba trường chưa có tác dụng gì — dễ làm cho qua.

## Kiểm chứng

Review (checklist duyệt có kiểm ba trường này, dù Level 1 chưa dùng).

## Trong code

`SourceId`, `DocType`, `Date` trong `LexProof/Core/Norm.lean`. Chỉ `article`
được dùng ở Level 1: trong `Counterexample.sources` và `Scope.articles`
(`LexProof/Verify/Conflict.lean`).
