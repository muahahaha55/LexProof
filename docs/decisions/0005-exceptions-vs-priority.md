# ADR-0005: Ngoại lệ đổi *khi nào* áp dụng; ưu tiên giải quyết hai norm *cùng* áp dụng

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0013](0013-directional-priority-and-cycles.md), FR6, FR8

## Bối cảnh

Văn bản luật dùng nhiều cách diễn đạt trông giống nhau nhưng khác hẳn về logic:

- "Điều này không áp dụng đối với doanh nghiệp nhỏ" → thu hẹp phạm vi áp dụng.
- "Trừ trường hợp quy định tại Điều 7" → nói rằng khi cả hai điều cùng áp dụng
  thì Điều 7 thắng.

Nếu trộn hai thứ này vào một trường, không còn phân biệt được "norm không áp
dụng" với "norm áp dụng nhưng bị norm khác lấn".

## Quyết định

Hai trường riêng biệt, hai vai trò riêng biệt:

- `Norm.exceptions : List Cond` — đổi **khi nào** norm áp dụng.
  `applies = condition && !(OR các exceptions)`.
- `Norm.priority : Option Priority` với `Priority.overrides : List NormId` —
  giải quyết trường hợp **hai norm đều áp dụng**.

Và: **không có lex specialis ngầm**. Không có ưu tiên tường minh thì coi là
*chưa* giải quyết, tức là vẫn báo xung đột (fail closed). Hệ thống không tự suy
ra rằng điều khoản cụ thể hơn thì thắng.

## Hệ quả

**Tốt**
- Phân biệt được rõ hai hiện tượng, nên phản ví dụ nói đúng bản chất vấn đề.
- Fail closed: một văn bản *quên* nói điều nào ưu tiên sẽ bị báo, chứ không
  được hệ thống "chữa" hộ. Đó chính là loại lỗi lập pháp cần tìm.
- `Option` làm cho "luật không nói gì" khác hẳn "luật nói không ai ưu tiên".

**Xấu**
- Người mã hóa phải phán đoán xem một câu "trừ trường hợp..." là ngoại lệ hay
  ưu tiên. Hai cách mã hóa cho kết quả kiểm tra khác nhau, nên **đây là một
  nguồn sai faithfulness** và phải nằm trong checklist duyệt.
- Việc không có lex specialis ngầm sẽ sinh ra nhiều báo nhiễu trên văn bản thật,
  vì luật Việt Nam thường dựa vào nguyên tắc này mà không viết ra.
- Bản cài đặt hiện tại của `resolved` còn **đối xứng** và không ghi ai thắng —
  xem [ADR-0013](0013-directional-priority-and-cycles.md) (Planned).

## Kiểm chứng

Review (checklist duyệt: ngoại lệ hay ưu tiên?) + Proof (`Conflict` đòi
`resolved = false`, nên không có đường nào bỏ qua bước này).

## Trong code

`Norm.exceptions`, `Norm.priority`, `Priority`, `Norm.applies`, `Norm.resolved`
trong `LexProof/Core/Norm.lean`. `Conflict` đòi `Norm.resolved n₁ n₂ = false`
trong `LexProof/Verify/Conflict.lean`. Smoke test dùng ngoại lệ (`normBFixed`);
nhánh ưu tiên **chưa có test**.
