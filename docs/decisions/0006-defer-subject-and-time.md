# ADR-0006: Hoãn chủ thể và thời gian

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented (dưới dạng *không* có trong lược đồ)
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0004](0004-act-as-opaque-glossary-id.md), [ADR-0012](0012-scope-level1-now.md), N8

## Bối cảnh

Một norm đầy đủ còn có chủ thể ("doanh nghiệp phải...") và chiều thời gian
("trong vòng 30 ngày", "kể từ ngày có hiệu lực"). Cả hai đều ảnh hưởng tới việc
hai norm có thật sự chạm nhau hay không.

Nhưng chủ thể cần phân cấp (doanh nghiệp nhỏ là một loại doanh nghiệp), và thời
gian cần hoặc miền thời gian hữu hạn hoặc số học khoảng — cả hai đều đắt, và
đều làm nổ ngân sách liệt kê (N8).

## Quyết định

**Không** đưa chủ thể và thời gian thành khái niệm hạng nhất trong `Core` ở giai
đoạn này. Kiểu tình huống `S` do **người gọi cung cấp** dưới dạng một structure
hữu hạn; nếu một văn bản cần phân biệt chủ thể hay mốc thời gian, nó tự mã hóa
thành các trường của `S` (ví dụ `isSmallEnterprise : Bool`, `afterDeadline : Bool`).

## Hệ quả

**Tốt**
- `Core` nhỏ và không đoán trước. `Norm` không mang tham số kiểu nào.
- Mỗi văn bản chỉ trả giá cho những phân biệt nó thực sự cần, nên `|S|` nhỏ.
- Vẫn mã hóa được chủ thể/thời gian ở mức thô, chỉ là không có suy luận riêng
  cho chúng.

**Xấu**
- Không có suy luận về phân cấp chủ thể: "doanh nghiệp" và "doanh nghiệp nhỏ"
  là hai trường Bool rời nhau, nên quan hệ bao hàm phải tự viết thành `Cond`,
  và dễ viết sai.
- Không có số học thời gian: "trong 30 ngày" và "trong 45 ngày" chỉ so sánh được
  nếu người mã hóa tự tạo trường tương ứng.
- Hai văn bản khác nhau sẽ mã hóa cùng một khái niệm theo cách khác nhau, nên
  khó dùng lại — đây là cái giá phải trả, chấp nhận ở Level 1.

## Kiểm chứng

Review (xem lại khi làm module `Laws` thật: `S` có đủ diễn đạt điều khoản không).

## Trong code

Không có khai báo nào — đây là quyết định *không* thêm gì. Dấu vết: `Conflict`,
`check` nhận `S` trừu tượng với `[Finite S]`; `LexProof/Verify/Smoke.lean` khai
`structure Sit where overdue : Bool ; disputed : Bool` làm ví dụ.
