# ADR-0003: Khái niệm mở là tham số hữu hạn `P`

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0008](0008-report-conditional-conflicts.md), [ADR-0009](0009-own-finite-class-no-mathlib.md), FR6, N8

## Bối cảnh

Văn bản pháp luật đầy khái niệm mở: "hợp lý", "nghiêm trọng", "kịp thời", "gây
hậu quả lớn". Một hệ thống hình thức **không được** tự quyết định những khái
niệm này — đó là việc của người có thẩm quyền, và tự quyết là cách nhanh nhất
để công cụ trở nên nguy hiểm.

Nhưng nếu để chúng hoàn toàn trừu tượng thì không tìm xung đột tự động được nữa.

## Quyết định

Mỗi khái niệm mở là **một bit trong một kiểu tham số hữu hạn `P`** (một `Bool`
cho mỗi khái niệm). `Cond` tham chiếu chúng qua `param i`. Hệ thống **lượng hóa
trên mọi gán trị của `P`** thay vì chọn một giá trị, và các bit của `P` **tính
vào ngân sách liệt kê**: chi phí là `|S| × |P| × số cặp`.

## Hệ quả

**Tốt**
- Hệ thống không bao giờ quyết định một khái niệm mở; nó chỉ nói kết luận phụ
  thuộc vào khái niệm nào (FR6).
- Cho phép phân biệt xung đột *vô điều kiện* với xung đột *chỉ xảy ra với một
  số cách hiểu* — chính là [ADR-0008](0008-report-conditional-conflicts.md).
- Tên khái niệm nằm trong `Atoms.param`, nên báo cáo nêu được bằng tiếng Việt.

**Xấu**
- Mỗi khái niệm mở **nhân đôi** không gian tìm kiếm. Mười khái niệm là 2^10,
  đã ăn gần hết trần 2^14 trước khi tính tới tình huống và số cặp (N8).
- Chỉ hai giá trị cho mỗi khái niệm. Những khái niệm có mức độ ("nghiêm trọng"
  nhẹ/vừa/nặng) phải hoặc nén về một bit, hoặc tốn nhiều bit.
- `Core` **không cưỡng chế** "mỗi khái niệm một Bool": `P` chỉ cần có instance
  `Finite`. Ràng buộc này là quy ước, người viết `Laws` phải tự giữ.

## Kiểm chứng

Review (người duyệt xác nhận mỗi khái niệm mở đã thành tham số, không bị nhúng
thành hằng) + Test (đếm `Finite.card P` so với ngân sách).

## Trong code

Tham số kiểu `P` xuyên suốt `Atoms`, `Cond.eval`, `Norm.applies`, `Conflict`,
`check`. `Atoms.param : List (String × (P → Bool))` giữ tên. Ví dụ:
`LexProof/Verify/Smoke.lean` dùng `structure Params where serious : Bool`
(`Finite.card Params = 2`).
