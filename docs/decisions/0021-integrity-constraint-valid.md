# ADR-0021: Ràng buộc toàn vẹn `Atoms.valid`

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-22
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0003](0003-open-concepts-as-finite-parameters.md), [ADR-0006](0006-defer-subject-and-time.md), [ADR-0011](0011-trust-boundary-human-approval.md), [ADR-0018](0018-scope-lists-parameter-names.md), N2, N8

## Bối cảnh

Tình huống được mô hình bằng một structure các trường hữu hạn
([ADR-0006](0006-defer-subject-and-time.md)), nên không gian tình huống là
**tích Descartes** của các trường. Tích đó chứa những tổ hợp **không thể xảy
ra**: "chưa quá hạn" cùng với "đã quá 30 ngày kể từ hạn", hay "doanh nghiệp
nhỏ" cùng với "doanh nghiệp niêm yết".

Hai hậu quả, cả hai đều xấu:

1. **Báo nhiễu.** Bộ kiểm báo một xung đột tại một tình huống không tồn tại.
   Người duyệt mất thời gian, và tệ hơn, mất niềm tin vào công cụ.
2. **Lãng phí ngân sách.** Những điểm bất khả thi vẫn tốn thời gian kernel, mà
   ngân sách thì rất chật (N8).

Cách khắc phục sai lầm là nhúng điều kiện bất khả thi vào từng `Cond` của từng
norm — lặp lại, dễ sai, và làm lẫn "luật nói gì" với "thế giới ra sao".

## Quyết định

`Atoms` mang thêm một trường:

```lean
structure Atoms (S P : Type) where
  sit   : List (String × (S → Bool))
  param : List (String × (P → Bool))
  valid : P → S → Bool := fun _ _ => true
```

`valid π s` nói cặp đó **có thể xảy ra**. Bộ kiểm chỉ xét cặp `valid`. Mặc định
nhận tất cả, nên văn bản không cần ràng buộc thì không bị ảnh hưởng gì.

Mọi định lý được phát biểu **tường minh** trên phần `valid`:

- (a) phản ví dụ được báo kèm `A.valid c.params c.situation = true`;
- (b) `consistentOn` chỉ loại trừ xung đột tại các điểm có `valid = true`;
- (e) hai nhãn được phân biệt bằng cách lượng hóa trên các `π` **valid**.

Và `Scope` ghi **số điểm bị loại trên tổng số** (`validExcluded`,
`validTotal`), không chỉ một `Bool` — để người đọc thấy được kết luận hẹp hơn
các con số thô bao nhiêu.

## Hệ quả

**Tốt**
- Giảm báo nhiễu đúng chỗ, bằng một khai báo duy nhất cho cả văn bản thay vì
  lặp trong từng norm.
- Tách rành mạch "luật quy định gì" (`Cond`) khỏi "thế giới có thể thế nào"
  (`valid`).
- Giảm ngân sách thật: `validExcluded` điểm không bao giờ được quét.
- Vì mỗi định lý đều nói rõ "trên phần valid", không có khẳng định nào bị phóng
  đại một cách âm thầm.

**Xấu — và đây là điều phải nhớ**
- **`valid` mở rộng trust base.** Một `valid` quá mạnh **che xung đột thật**, và
  **không định lý nào phát hiện được**: mọi định lý đều có dạng "trên phần
  valid", nên chúng vẫn đúng và vẫn vô nghĩa. Đây là bề mặt tin cậy *mới*, và
  là bề mặt dễ bị lạm dụng nhất trong toàn hệ thống — vô tình hay cố ý, viết
  `valid := fun _ _ => false` làm mọi văn bản trở nên "nhất quán".
- `valid` phải được **duyệt như duyệt một norm**: nó là một khẳng định về thế
  giới, không phải một tối ưu hóa. Checklist duyệt trong
  [../conventions.md](../conventions.md) phải có nó.
- `Scope.validExcluded` chỉ là một **con số**: nó nói *bao nhiêu* điểm bị loại,
  không nói *điểm nào*. Người đọc chưa thể kiểm `valid` từ báo cáo.
- `validIsTrivial`/`validExcludedOf` phải quét toàn miền để đếm, nên bản thân
  việc báo cáo cũng tốn một lần quét.

## Kiểm chứng

Proof (mọi định lý mang điều kiện `valid` tường minh; `scopeOf_spec` chứng minh
`validExcluded ≤ validTotal`) + Test (`Tests.restriction_is_counted`,
`Tests.valid_excludes_the_conflict`, `Tests.no_restriction_counted`) + **Review**
— và Review là phần quan trọng nhất ở đây, vì đó là bằng chứng duy nhất cho
việc `valid` không quá mạnh.

## Trong code

`Atoms.valid` trong `LexProof/Core/Norm.lean`. `validPoints`, `validExcludedOf`,
`Scope.validExcluded`, `Scope.validTotal`, `Scope.isRestricted`,
`Internal.cands` (lọc theo `valid`), `coApplyPoint?` trong
`LexProof/Verify/Conflict.lean`. Bảng trust base:
[../traceability.md](../traceability.md) mục 3.
