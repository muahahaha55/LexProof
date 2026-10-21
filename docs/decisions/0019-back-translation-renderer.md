# ADR-0019: Dịch ngược bằng LLM hay bằng renderer tất định?

- **Status**: Proposed — **chưa quyết định**
- **Trạng thái cài đặt**: **Open**
- **Ngày**: 2026-10-21
- **Người quyết định**: Tác giả đồ án (cần chốt)
- **Liên quan**: [ADR-0002](0002-cond-syntax-tree-option-eval.md), [ADR-0011](0011-trust-boundary-human-approval.md), FR5, N10, G2

## Bối cảnh

FR5 đòi diễn đạt lại mỗi `Norm` thành tiếng Việt để người duyệt đối chiếu song
song với văn bản gốc. Đây là **cơ chế duy nhất** để bắt lỗi faithfulness (G2),
nên chất lượng của nó quyết định chất lượng của cả biên tin cậy
([ADR-0011](0011-trust-boundary-human-approval.md)).

Hai phương án:

**A. Renderer tất định** — ánh xạ cố định từ `Cond`/`Norm` sang mẫu câu tiếng
Việt. Ví dụ `and (sit 0) (not (param 0))` → "khi quá hạn và không nghiêm trọng".

**B. LLM dịch ngược** — đưa `Norm` cho LLM diễn đạt thành câu tự nhiên.

Vấn đề cốt lõi của B: nếu **cùng một LLM** (hoặc cùng họ mô hình) làm cả dịch
xuôi và dịch ngược, nó có thể tái tạo lại *ý nó đã hiểu* thay vì *nội dung thật
sự có trong `Norm`*. Khi đó bản dịch ngược trông khớp với văn bản gốc trong khi
`Norm` thì không — một **lỗi tương quan** làm vô hiệu hóa đúng cái bước kiểm
tra mà nó được đặt vào để thực hiện.

## Phương án và đánh giá

| | A. Tất định | B. LLM |
|---|---|---|
| Trung thực với `Norm` | Đúng theo cấu trúc; không thêm không bớt | Có thể thêm bớt, không kiểm soát được |
| Lỗi tương quan với bước dịch xuôi | Không | **Có** — rủi ro chính |
| Dễ đọc | Cứng, lặp, câu dài dễ lủng củng | Tự nhiên, dễ đọc hơn (N10) |
| Nằm trong hay ngoài biên tin cậy | Có thể viết trong Lean, kiểm được | Ngoài biên, không tin cậy |
| Công sức | Phải viết và bảo trì bộ mẫu câu | Gần như không |
| Tất định / lặp lại được | Có (N7) | Không, trừ khi ghim seed và log |

## Khuynh hướng

**Ưu tiên A (tất định)**, vì B có lỗi tương quan ở đúng chỗ không được phép có.
Một phương án pha trộn đáng cân nhắc: A sinh bản dịch ngược **chuẩn tắc** để đối
chiếu, B chỉ dùng để *làm mượt* văn phong và luôn hiển thị **kèm** bản A, chứ
không thay thế.

## Điều cần quyết

1. Chọn A, B, hay bản pha trộn?
2. Nếu pha trộn: người duyệt phê duyệt dựa trên bản nào — bản A là bản có hiệu
   lực, hay bản đã làm mượt?
3. Nếu dùng LLM ở bất cứ vai nào: ghi log model và phiên bản prompt thế nào để
   thỏa N7?

## Hệ quả (chưa chốt)

Nếu chọn A, renderer **có thể viết trong Lean** — `Cond` là cây cú pháp
([ADR-0002](0002-cond-syntax-tree-option-eval.md)) nên việc này khả thi, và khi
đó nó nằm *trong* phần tin cậy, kiểm chứng được. Đây là một lợi thế mà quyết
định ADR-0002 vô tình tạo ra.

Nếu chọn B, nó nằm ngoài biên tin cậy và phải được xem như một đầu ra LLM nữa,
có log, có phiên bản.

## Kiểm chứng

Review + Demo — đo trên ca chuyên gia: người duyệt dùng bản dịch ngược có phát
hiện được `Norm` đã bị cố tình mã hóa sai hay không. Đây là phép thử trực tiếp
cho rủi ro lỗi tương quan, và nên chạy cho **cả hai** phương án trước khi chốt.

## Trong code

Chưa có. `pipeline/` rỗng.
