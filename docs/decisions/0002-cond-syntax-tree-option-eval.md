# ADR-0002: `Cond` là cây cú pháp, `eval` trả `Option Bool`

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0011](0011-trust-boundary-human-approval.md), [ADR-0017](0017-wellformedness-validator-first.md), FR3, FR5, N3

## Bối cảnh

Điều kiện áp dụng của một norm có thể biểu diễn hai cách:

1. **Hàm mờ** `P → S → Bool`. Viết nhanh, nhưng không in ra được, không so sánh
   được, không kiểm tra được, và nếu LLM sinh ra thì nó là **mã Lean tự do** —
   tức là một lỗ hổng ở biên tin cậy.
2. **Cây cú pháp** có `eval` riêng. Dài hơn, nhưng là dữ liệu.

Thêm một câu hỏi thứ hai: `eval` làm gì khi gặp điều kiện dị dạng (atom trỏ ra
ngoài bảng)? Trả `false` là *im lặng làm norm không áp dụng*, và như vậy có thể
**che mất** một xung đột thật — vi phạm nguyên tắc fail closed.

## Quyết định

`Cond` là một `inductive` đóng: `tt`, `ff`, `sit i`, `param i`, `not`, `and`,
`or`, có `deriving Repr, DecidableEq`. Atom trỏ vào bảng `Atoms` bằng **chỉ số**,
nên `Cond` không phụ thuộc kiểu tình huống.

`Cond.eval` trả **`Option Bool`**: `none` nghĩa là dị dạng, và `and`/`or` lan
truyền `none`. Giá trị `none` đi tiếp lên thành `Result.unknown`, không bao giờ
bị quy về `false`.

## Hệ quả

**Tốt**
- LLM sinh **dữ liệu**, không sinh mã. Bản dịch in được cho người duyệt đọc
  (FR5) và so sánh được bằng `DecidableEq`.
- Vì `Cond` độc lập với `S`/`P`, **`Norm` trở thành dữ liệu thuần** và cũng
  `deriving DecidableEq` được. Đây là hệ quả ngoài dự tính nhưng rất có lợi:
  `Norm` không mang tham số kiểu, nên `Laws` nhẹ đi nhiều.
- `Cond.paramIdxs` đọc được ngay từ cây cú pháp, nhờ đó
  [ADR-0008](0008-report-conditional-conflicts.md) nêu tên được tham số liên quan.
- Dị dạng thành `unknown` chứ không thành "không áp dụng" (N3).

**Xấu**
- Phải tự viết `eval`, `paramIdxs`, `evalAny`, và tự chứng minh mọi tính chất —
  không mượn được gì từ hàm Lean sẵn có.
- Liên kết bằng **chỉ số** rất dễ sai và không được kiểu kiểm tra: `.sit 99`
  hợp kiểu nhưng vô nghĩa. Lỗi chỉ lộ ra lúc `eval`, dưới dạng `unknown`, và
  hiện còn **báo sai tên norm** (xem `design-core.md` mục 3.5). Đó là lý do
  [ADR-0017](0017-wellformedness-validator-first.md) tồn tại.
- `Option Bool` làm mọi hàm phía trên phức tạp hơn một bậc.

## Kiểm chứng

Proof (`isConflictAt_eq_true_iff` chứng minh `applies` dùng đúng `eval`) +
Review (người duyệt đọc `Cond` in ra).

## Trong code

`Cond`, `Atoms`, `Cond.eval`, `Cond.evalAny`, `Cond.paramIdxs` trong
`LexProof/Core/Norm.lean`. `Norm.applies` lan truyền `none`.
