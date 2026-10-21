# ADR-0004: `act` là id mờ lấy từ glossary

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0001](0001-incompatible-modalities.md), [ADR-0006](0006-defer-subject-and-time.md), FR2

## Bối cảnh

Hai norm chỉ xung đột khi nói về **cùng một hành vi**. Vậy "hành vi" được định
danh thế nào?

1. **Có cấu trúc**: động từ + đối tượng + chủ thể + thời hạn. Cho phép suy luận
   như "nộp thuế trước ngày 10" là một trường hợp đặc biệt của "nộp thuế".
2. **Id mờ**: một chuỗi, hai norm cùng act khi và chỉ khi chuỗi bằng nhau.

Cách 1 kéo theo cả một lý thuyết về hành vi, phân cấp, và hợp nhất (unification)
— nhiều hơn hẳn phạm vi Level 1.

## Quyết định

`abbrev Act := String`. Act là một **id mờ khai báo theo từng văn bản** trong
glossary. So sánh act là so sánh chuỗi. Không có cấu trúc, không có phân cấp.

## Hệ quả

**Tốt**
- Việc so act là tầm thường, `decide` xử lý được, không có suy luận ẩn.
- Đẩy toàn bộ phần khó — quyết định hai cách diễn đạt có phải cùng một hành vi
  hay không — ra **glossary**, nơi có người duyệt (FR2). Đó là đúng chỗ: đây là
  phán đoán pháp lý, không phải phép tính.

**Xấu**
- Quan hệ bao hàm giữa các hành vi **không** bắt được: "công bố thông tin" và
  "công bố thông tin trên cổng điện tử" là hai act khác nhau, nên một xung đột
  giữa chúng sẽ bị bỏ sót (false negative).
- Chất lượng kết quả phụ thuộc hoàn toàn vào việc chuẩn hóa act trong glossary.
  Hai bản dịch gọi cùng một hành vi bằng hai id khác nhau là bỏ sót im lặng —
  và **không có cơ chế nào trong Lean phát hiện được** việc đó.
- Chuỗi tự do nên lỗi chính tả không bị kiểu kiểm tra.

## Kiểm chứng

Review (người duyệt xác nhận act id trong glossary) + Test (ca chuyên gia có
cặp act gần giống nhau để đo tỉ lệ bỏ sót, FR12).

## Trong code

`abbrev Act := String` và `Norm.act` trong `LexProof/Core/Norm.lean`. So sánh
nằm ở `Conflict` (`n₁.act = n₂.act`) và `conflictsAt` (`n₁.act == n₂.act`).
