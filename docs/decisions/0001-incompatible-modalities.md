# ADR-0001: Cặp modality nào được coi là xung đột

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0005](0005-exceptions-vs-priority.md), FR6, FR7

## Bối cảnh

Logic deontic có nhiều cách xử lý quan hệ giữa ba modality. Cặp
obligation–prohibition là mâu thuẫn hiển nhiên. Hai cặp còn lại thì phải chọn:

- **permission–prohibition**: chỉ xung đột nếu coi "được phép" là *cho phép
  mạnh* (một sự bảo đảm), không phải chỉ là "không bị cấm".
- **obligation–permission**: "phải làm X" và "được làm X" cùng tồn tại thì
  không có gì sai; cái sau chỉ yếu hơn cái trước.

Nếu chọn sai, bộ kiểm sẽ báo nhiễu (false positive) hoặc bỏ sót.

## Quyết định

Coi là xung đột: **obligation ~ prohibition** và **permission ~ prohibition**.
**Không** coi obligation ~ permission là xung đột.

Quan hệ này **đối xứng** và **phản xạ-sai** (không modality nào xung đột với
chính nó).

## Hệ quả

**Tốt**
- Văn bản cho phép tường minh một việc rồi chỗ khác lại cấm chính việc đó sẽ bị
  phát hiện — đây là một dạng lỗi lập pháp thật.
- Tính phản xạ-sai làm cho việc so cặp `(n, n)` trong `cands` trở nên vô hại,
  nên bản cài đặt hiện tại không cần lọc cặp tự-ghép.

**Xấu**
- Phụ thuộc vào giả định "cho phép mạnh". Nếu một văn bản dùng "được phép" chỉ
  theo nghĩa "không bị cấm", sẽ có báo nhiễu, và phải sửa bằng ngoại lệ hoặc ưu
  tiên tường minh.
- Hai nghĩa vụ *trái nhau về nội dung* (phải làm X trước ngày 1, phải làm X sau
  ngày 10) **không** bị bắt, vì cả hai đều là obligation. Việc đó cần mô hình
  nội dung hành vi, mà [ADR-0004](0004-act-as-opaque-glossary-id.md) chủ động
  không làm.
- Tính phản xạ-sai đang *gánh* một việc mà nó không nên gánh: nếu sau này mở
  rộng để bắt hai obligation trái nhau, cặp `(n, n)` sẽ báo nhầm ngay. Xem
  [ADR-0014](0014-compare-pairs-by-index.md).

## Kiểm chứng

Review (quyết định có tính pháp lý, người duyệt xác nhận) + Proof (bảng là một
hàm toàn phần, kiểm được bằng `decide`).

## Trong code

`Incompatible : Modality → Modality → Bool` trong `LexProof/Core/Norm.lean`.
Được dùng trong `Conflict` và `conflictsAt` ở `LexProof/Verify/Conflict.lean`.
