# ADR-0018: `Scope` liệt kê tên tham số khái niệm mở và trạng thái duyệt

- **Status**: Accepted
- **Trạng thái cài đặt**: **Planned**
- **Ngày**: 2026-10-21
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0003](0003-open-concepts-as-finite-parameters.md), [ADR-0011](0011-trust-boundary-human-approval.md), FR10, N2

## Bối cảnh

`Scope` hiện có:

```lean
structure Scope where
  docId : String ; normIds : List NormId ; articles : List String
  situations : Nat ; params : Nat
```

`params : Nat` chỉ nói **số lượng** gán trị tham số (`Finite.card P`), không nói
**tham số nào**. Người đọc báo cáo thấy "params := 2" mà không biết bit đó là
"nghiêm trọng" hay "hợp lý". Khi đó câu "nhất quán trên phần đã mã hóa" vẫn
chưa đủ trung thực: nó im lặng về việc kết luận đã lượng hóa trên những cách
hiểu nào.

Thiếu sót nặng hơn: `Scope` **không nói gì về việc duyệt**. Theo N2, không được
khẳng định nhất quán cho toàn văn bản khi còn norm chưa mã hóa hoặc **chưa
duyệt** — nhưng `Scope` hiện không có chỗ để ghi điều đó, nên hiện tại N2 chỉ
được bảo đảm *một phần* (có scope, nhưng scope chưa đủ nội dung).

## Quyết định

`Scope` bổ sung:

1. **tên** các tham số khái niệm mở đã lượng hóa (lấy từ `Atoms.param`), không
   chỉ số lượng;
2. **trạng thái duyệt** — norm nào đã duyệt, norm nào chưa — ngay khi quy trình
   duyệt tồn tại;
3. danh sách điều khoản **đã bỏ qua / chưa mã hóa** (gắn với FR4 và
   [ADR-0016](0016-reference-catalog-from-segmenter.md)).

Mục tiêu: `Scope` tự nó đủ nghĩa để một người duyệt không biết Lean đọc hiểu
được kết luận bao trùm tới đâu.

## Hệ quả

**Tốt**
- Báo cáo tự nó trả lời được "kết luận này đã tính tới những gì" (FR10).
- Đóng nốt phần còn thiếu của N2: hiện chỉ có scope về *cấu trúc*, chưa có scope
  về *mức độ tin cậy*.
- Danh sách tên có sẵn trong `Atoms.param`, lấy ra không tốn gì.

**Xấu**
- `Scope` phình to; báo cáo dài hơn, và trên văn bản lớn thì rất dài — có thể
  cần tóm lược khi hiển thị, trong khi vẫn giữ bản đầy đủ.
- Trạng thái duyệt **không phải dữ liệu Lean** mà là siêu dữ liệu quy trình. Đưa
  nó vào `Scope` nghĩa là `Verify` phải nhận thêm một đầu vào không tin cậy (bản
  ghi duyệt), và đầu vào đó không có gì bảo đảm trung thực. Phải chốt cách biểu
  diễn để không tạo cảm giác an toàn giả.
- `smoke_consistent` và mọi test so khớp `Scope` nguyên khối sẽ phải viết lại.

## Kiểm chứng

Review (người duyệt không biết Lean đọc `Scope` và nói lại đúng phạm vi kết
luận — cũng là AC của N10) + Test (`Scope` luôn có mục tham số).

## Trong code

Hiện tại: `Scope` và `scopeOf` trong `LexProof/Verify/Conflict.lean` chỉ có
`params : Nat`. `paramNames` đã có nhưng chỉ dùng cho
`Result.conditionalConflict`, chưa dùng cho `Scope`.
