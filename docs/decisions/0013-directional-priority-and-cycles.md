# ADR-0013: Ưu tiên có hướng, override lẫn nhau là một finding, `Result` ghi ai thắng

- **Status**: Accepted
- **Trạng thái cài đặt**: **Planned**
- **Ngày**: 2026-10-21
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0005](0005-exceptions-vs-priority.md), FR8, FR9

## Bối cảnh

Bản cài đặt hiện tại:

```lean
def resolved (n₁ n₂ : Norm) : Bool :=
  (match n₁.priority with | some p => p.overrides.contains n₂.id | none => false) ||
  (match n₂.priority with | some p => p.overrides.contains n₁.id | none => false)
```

Đây là phép **HOẶC đối xứng**, và nó có ba vấn đề:

1. "A ưu tiên hơn B" và "A và B ưu tiên hơn nhau" cho **cùng** kết quả
   `resolved = true`. Trường hợp thứ hai là một văn bản tự mâu thuẫn về thứ tự
   ưu tiên — đúng ra phải là một phát hiện, lại đang bị coi là đã giải quyết xong.
2. Chu trình ưu tiên dài hơn (A > B, B > C, C > A) cũng không bị phát hiện.
3. Khi đã giải quyết, hệ thống **không ghi lại norm nào thắng**, nên báo cáo
   không nói được điều khoản nào thực sự áp dụng.

Vấn đề 1 nguy hiểm nhất: nó làm một lỗi lập pháp *biến mất* thay vì được báo —
ngược hẳn nguyên tắc fail closed.

## Quyết định

1. `resolved` chỉ đúng khi **đúng một** trong hai norm override norm kia
   (XOR thay vì OR).
2. Override lẫn nhau, và chu trình ưu tiên nói chung, là một **finding** riêng
   do validator phát hiện ([ADR-0017](0017-wellformedness-validator-first.md)),
   không phải một `unknown` và cũng không phải một `conflict`.
3. `Result` ghi lại `NormId` của norm thắng khi một xung đột được ưu tiên giải
   quyết, để báo cáo nói được điều khoản nào áp dụng.

## Hệ quả

**Tốt**
- Văn bản tự mâu thuẫn về thứ tự ưu tiên bị báo thay vì bị bỏ qua.
- Báo cáo trả lời được câu hỏi người đọc thực sự quan tâm: "vậy cuối cùng phải
  làm theo điều nào?"
- Khớp với nguyên tắc fail closed của [ADR-0005](0005-exceptions-vs-priority.md).

**Xấu**
- Sửa `resolved` **làm thay đổi ngữ nghĩa của `Conflict`**, nên
  `isConflictAt_eq_true_iff` và cả hai định lý chính phải chứng minh lại. Phải
  làm **trước** khi có module `Laws` thật, nếu không sẽ phải duyệt lại dữ liệu.
- Phát hiện chu trình cần duyệt đồ thị trên `Priority.overrides`, tức một thuật
  toán mới cần chứng minh tính đúng (hoặc ít nhất tính kết thúc).
- `Result` phình thêm một trường.

## Kiểm chứng

Proof (chứng minh lại định lý cầu và hai định lý chính) + Test (ca tiêm chu
trình ưu tiên và ca override lẫn nhau).

## Trong code

Hiện tại: `Norm.resolved` trong `LexProof/Core/Norm.lean` — **đối xứng**, chưa
sửa. Chưa có phát hiện chu trình. `Result` chưa có trường norm thắng.
