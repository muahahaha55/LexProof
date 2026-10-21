# ADR-0009: Miền hữu hạn, không Mathlib, tự viết lớp `Finite`

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0003](0003-open-concepts-as-finite-parameters.md), [ADR-0010](0010-axiom-whitelist-decide-only.md), N8, N9

## Bối cảnh

Để tìm xung đột **tự động**, miền tình huống phải hữu hạn và quét được. Lean core
cho `Decidable` trên nhiều thứ, nhưng **không** tổng hợp được
`Decidable (∀ a : α, p a)` cho một enum thường — đã kiểm: với
`inductive Party | buyer | seller | third`, `by decide` trên `∀ p : Party, …`
báo `failed to synthesize Decidable`.

Mathlib có `Fintype` giải quyết việc này. Nhưng thêm Mathlib là thêm một phụ
thuộc rất lớn vào cơ sở tin cậy và vào thời gian build, cho một đồ án mà toàn bộ
nhu cầu toán học là "liệt kê một danh sách".

## Quyết định

Không dùng Mathlib. Tự khai một lớp tối thiểu trong `LexProof/Core/Finite.lean`:

```lean
class Finite (α : Type) where
  enum     : List α
  complete : ∀ a : α, a ∈ enum
```

Cùng với `Finite.card` và bổ đề cầu `Finite.forall_of_all` (từ `enum.all p = true`
sang `∀ a, p a = true`). Instance có sẵn: `Unit`, `Bool`, `α × β`.

Lean core cung cấp đúng những gì cần cho hướng ngược lại: `List.all_eq_true`,
`List.mem_flatMap`, `List.mem_map`, `List.find?_some`,
`List.mem_of_find?_eq_some`, `List.find?_eq_none`.

## Hệ quả

**Tốt**
- Cơ sở tin cậy nhỏ: chỉ kernel + Lean core. Build nhanh, không có gì để ghim
  phiên bản ngoài `lean-toolchain`.
- `complete` là **chứng minh**, không phải lời hứa: nhờ nó mà `consistentOn` phủ
  được *mọi* tình huống chứ không chỉ những cái tình cờ có trong danh sách. Đây
  là mắt nối then chốt trong `mem_cands`.
- Quét cạn chạy được bằng `decide` thuần, nên giữ được whitelist axiom
  ([ADR-0010](0010-axiom-whitelist-decide-only.md)).

**Xấu**
- Phải tự chứng minh mọi thứ. Mỗi kiểu tình huống mới cần **viết tay** một
  instance `Finite` (xem `Smoke.lean`), vì không có deriving handler. Liên quan N9.
- Chỉ có ba instance; chưa có `Fin n`, chưa có kiểu tổng.
- Miền hữu hạn là một giới hạn thật: không mô hình được số tiền, khoảng thời
  gian, hay số lượng không chặn — xem [ADR-0006](0006-defer-subject-and-time.md).
- Chi phí nổ theo cấp số nhân: trần đo được là 2^14 cho thời gian chấp nhận
  được, 2^18 thì thất bại (N8).
- `Finite.forall_of_all` **hiện chưa được dùng ở đâu** — `Verify/Conflict.lean`
  đi đường `List.find?_eq_none`. Nó sẽ cần cho [ADR-0015](0015-characterize-conflict-labels.md).

## Kiểm chứng

Proof (`complete` của mỗi instance được kernel kiểm) + Test (`lake build` không
có phụ thuộc ngoài).

## Trong code

`LexProof/Core/Finite.lean` toàn bộ. `lake-manifest.json` có `"packages": []`.
