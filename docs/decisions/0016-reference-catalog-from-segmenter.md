# ADR-0016: Danh mục tham chiếu lấy từ segmenter, có người duyệt, ghi vào `Scope`

- **Status**: Accepted
- **Trạng thái cài đặt**: **Planned**
- **Ngày**: 2026-10-21
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0011](0011-trust-boundary-human-approval.md), [ADR-0017](0017-wellformedness-validator-first.md), FR1, FR8, N6

## Bối cảnh

Tham chiếu treo là một trong hai loại lỗi thuộc phạm vi Level 1. `Norm` đã có
trường `references : List String`, nhưng **chưa có checker nào đọc nó**.

Để kiểm một tham chiếu có treo hay không, cần biết **tập id điều khoản hợp lệ**
của văn bản. Tập đó từ đâu ra?

- Segmenter sinh ra nó khi tách văn bản (FR1) — nhưng segmenter **không tin cậy**.
- Tự suy từ các `Norm` đã mã hóa thì **sai**: một điều khoản có thể tồn tại
  trong văn bản mà chưa được mã hóa, nên tham chiếu tới nó không hề treo. Nếu
  suy theo cách này, mọi tham chiếu tới phần chưa mã hóa đều bị báo treo — một
  loạt báo nhiễu, và tệ hơn, nó **lẫn** hai khái niệm "không tồn tại" và "chưa
  mã hóa".

## Quyết định

Danh mục id điều khoản hợp lệ:

1. **do segmenter sinh** (FR1),
2. **có người duyệt**, như mọi dữ liệu khác qua biên tin cậy
   ([ADR-0011](0011-trust-boundary-human-approval.md)),
3. **được ghi vào `Scope`**, để báo cáo nói rõ nó đã đối chiếu với danh mục nào.

Phân biệt rành mạch ba trạng thái của một tham chiếu: **hợp lệ** / **treo**
(không có trong danh mục) / **trỏ tới phần chưa mã hóa** (có trong danh mục
nhưng chưa thành `Norm`). Trạng thái thứ ba **không** phải lỗi của văn bản, mà
là một giới hạn của phạm vi, và phải vào mục scope của báo cáo (FR10).

## Hệ quả

**Tốt**
- Tách được lỗi của *văn bản* khỏi giới hạn của *bản mã hóa* — đúng tinh thần G3.
- `Scope` trở thành bản ghi đầy đủ hơn về "đã đối chiếu những gì".
- Phục vụ luôn N6 (truy vết).

**Xấu**
- Thêm một tạo tác cần người duyệt, tức thêm việc cho điểm nghẽn con người.
- Danh mục phải đồng bộ với văn bản: văn bản sửa đổi thì danh mục cũ sai, và
  không có gì tự phát hiện việc lệch này.
- `Scope` phình thêm một danh sách, có thể dài.

## Kiểm chứng

Test (ca tiêm tham chiếu tới điều khoản không tồn tại, và ca tham chiếu tới điều
khoản chưa mã hóa — hai ca phải cho hai kết quả **khác nhau**) + Review (duyệt
danh mục).

## Trong code

Hiện tại: `Norm.references : List String` trong `LexProof/Core/Norm.lean` — có
trường, **không có checker**. `Scope` trong `LexProof/Verify/Conflict.lean` chưa
có danh mục tham chiếu.
