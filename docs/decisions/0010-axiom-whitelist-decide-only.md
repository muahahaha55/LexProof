# ADR-0010: Chính sách axiom — whitelist, chỉ `decide`, cấm `native_decide` và `bv_decide`

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented (chính sách) / Planned (audit tự động)
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0009](0009-own-finite-class-no-mathlib.md), FR11, N1, N8

## Bối cảnh

Soundness (G1) là mục tiêu số một: kết luận phải được kernel Lean chấp nhận.
Nhưng một chứng minh "qua được" vẫn có thể rỗng nếu nó dựa vào axiom thêm vào,
hoặc vào một `sorry` mà không ai thấy.

Có ba chiến thuật quét cạn đáng cân nhắc, và tôi đã **đo thực tế** trên toolchain
`v4.35.0` bằng `#print axioms`:

| Chiến thuật | Axiom sinh ra |
|---|---|
| `decide` | **không axiom nào** |
| `native_decide` | `<tên định lý>._native.native_decide.ax_1_1` |
| `bv_decide` trên goal tầm thường (chỉ cần normalize) | chỉ 3 axiom được phép — **bẫy** |
| `bv_decide` trên goal thực sự gọi SAT solver | `<tên định lý>._native.bv_decide.ax_1_5` |

Và một quan sát nữa: khi `decide` **thất bại** vì hết heartbeat (đo được ở 2^18:
`(deterministic) timeout at whnf, maximum number of heartbeats (200000)`), Lean
chèn `sorryAx` vào định lý. Thất bại đó **im lặng** nếu chỉ nhìn kết quả build
chứ không nhìn lỗi.

## Quyết định

1. Whitelist axiom: **`{propext, Classical.choice, Quot.sound}`**. Mọi thứ khác
   là lỗi, kể cả `sorryAx`.
2. Chỉ dùng `decide` hoặc chứng minh term/tactic thuần. **Cấm** `native_decide`
   và `bv_decide` trong bất cứ thứ gì chống lưng một kết luận.
3. Audit bằng cách **whitelist**, không phải blacklist theo tên.

Điểm 3 là hệ quả trực tiếp của số đo: tên axiom do `native_decide` sinh ra
**không** phải `Lean.ofReduceBool` mà là một axiom **sinh riêng theo từng định
lý**. Một bộ audit tìm theo tên `Lean.ofReduceBool` sẽ **không bắt được gì**.

## Hệ quả

**Tốt**
- Cơ sở tin cậy là kernel + ba axiom chuẩn của Lean, không hơn.
- Đã đạt, đo được: mọi định lý hiện có chỉ dùng `propext` và `Quot.sound` —
  thậm chí còn chưa cần `Classical.choice`.
- Chính sách whitelist miễn nhiễm với việc Lean đổi tên hoặc đổi cách sinh axiom
  ở bản sau.

**Xấu**
- Mất `bv_decide`, tức mất khả năng dùng SAT solver, nên trần quy mô thấp hơn
  hẳn (N8). Đổi lại bằng việc giữ miền nhỏ và nhóm norm theo `act`.
- `decide` chạy trong kernel nên chậm: 2^16 mất ~50s, 2^18 thất bại.
- **`bv_decide` sạch một lần không chứng minh được gì** — phải kiểm trên đúng
  goal thật, vì goal tầm thường được đóng bằng normalize và không gọi solver.
- Audit đang làm **thủ công**; `LexProof/Cert/` rỗng (FR11). Rủi ro này nghiêm
  trọng hơn vì CI hiện còn chưa build các module đó (N12).
- Khả năng nâng trần bằng `decide +kernel`: **chưa kiểm**.

## Kiểm chứng

Test — `#print axioms` cho mọi định lý kết luận, chạy trong CI (FR11, chưa cài).
Hiện kiểm thủ công, cách chạy xem [conventions.md](../conventions.md).

## Trong code

Không có khai báo nào cưỡng chế chính sách này — đó chính là lý do `Cert` cần
tồn tại. Hiện bằng chứng là kết quả `#print axioms` ghi trong
[design-core.md](../design-core.md) mục 5.
