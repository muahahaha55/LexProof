# ADR-0017: Validator well-formedness chạy trước bộ kiểm; `unknown` dành cho lý do khác

- **Status**: Accepted
- **Trạng thái cài đặt**: **Planned**
- **Ngày**: 2026-10-21
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0002](0002-cond-syntax-tree-option-eval.md), [ADR-0013](0013-directional-priority-and-cycles.md), [ADR-0014](0014-compare-pairs-by-index.md), [ADR-0016](0016-reference-catalog-from-segmenter.md), FR8, N3

## Bối cảnh

Hiện lỗi cấu trúc chỉ lộ ra **muộn**, lúc `eval`, dưới dạng `Result.unknown`.
Ba hành vi đã kiểm bằng `#eval` cho thấy việc này hỏng ở đâu:

| Đầu vào | Kết quả thực tế | Vấn đề |
|---|---|---|
| `check atoms [normA, badNorm]` với `badNorm.condition = .sit 99` | `unknown (malformedCondition "A")` | **Báo sai tên norm**: `"A"` là norm *lành*. Code lấy `k.left.id` còn norm dị dạng là `k.right` |
| `check atoms [normA, normB, badNorm]` | `conflict` của A~B, **không nhắc** `badNorm` | Xung đột được ưu tiên báo trước, nên việc còn một norm chưa đánh giá được **bị che** |
| `check atoms []` | `consistentOn` với scope rỗng | "Nhất quán" trên không có gì |

Vấn đề thứ nhất làm phản ví dụ không phát lại được. Vấn đề thứ hai là một lỗ
fail-closed thật: người đọc báo cáo **không biết** là có norm chưa được đánh giá.

Thêm vào đó, các loại lỗi cấu trúc khác — ID trùng
([ADR-0014](0014-compare-pairs-by-index.md)), chu trình ưu tiên
([ADR-0013](0013-directional-priority-and-cycles.md)), tham chiếu treo
([ADR-0016](0016-reference-catalog-from-segmenter.md)) — hiện **không bị phát
hiện gì cả**.

## Quyết định

Một **validator chạy trước** bộ kiểm xung đột, trả về danh sách finding, phát
hiện ít nhất:

1. chỉ số atom không hợp lệ (`sit i` / `param i` ngoài bảng `Atoms`) — **nêu
   đúng norm nào**,
2. `NormId` trùng,
3. tham chiếu treo (đối chiếu danh mục của [ADR-0016](0016-reference-catalog-from-segmenter.md)),
4. chu trình ưu tiên / override lẫn nhau,
5. *(Should)* norm không bao giờ áp dụng được — `applies` là `some false` trên
   toàn miền.

Nếu có finding, **không chạy** bộ kiểm xung đột và không phát hành kết luận
nhất quán. `Result.unknown` khi đó được **dành cho lý do khác** (ví dụ vượt ngân
sách, N8), chứ không dùng cho lỗi cấu trúc nữa.

Danh sách norm rỗng cũng là một finding của validator, không phải `consistentOn`.

## Hệ quả

**Tốt**
- Lỗi được báo **đúng chỗ, đúng tên norm**, nên phản ví dụ phát lại được (FR9).
- Xung đột không còn che được lỗi cấu trúc: validator chạy trước nên không có
  thứ tự ưu tiên nào bỏ sót nó.
- `UnknownReason` trở nên có nghĩa hẹp và rõ.
- Mục 5 bắt được norm chết, thường là dấu hiệu bản dịch sai.

**Xấu**
- Thêm một tầng, và một kiểu kết quả nữa phải định nghĩa và chứng minh.
- Mục 5 **tốn bằng một lần quét toàn miền** cho mỗi norm, nên tính vào ngân
  sách N8 — có thể phải để tùy chọn.
- `Cond.eval` vẫn phải trả `Option Bool` dù validator đã chạy trước, vì kiểu
  không ghi lại được việc "đã được validate". Lựa chọn khác là dùng kiểu phụ
  thuộc cho `Cond` hợp lệ, nhưng như thế `Norm` mất tính dữ liệu thuần — không
  đáng đổi.
- `Result.unknown` đổi nghĩa, nên mọi chỗ sinh và đọc nó phải sửa.

## Kiểm chứng

Test — mỗi loại lỗi một ca trên văn bản đã cố tình tiêm lỗi (AC của FR8), và
một ca kiểm rằng validator **nêu đúng** norm dị dạng chứ không nêu norm lành.

## Trong code

Chưa có. Hiện tại: `Cond.eval` trả `none`, `Norm.applies` lan truyền, và `check`
biến nó thành `unknown (.malformedCondition k.left.id)` trong
`LexProof/Verify/Conflict.lean`. Không có kiểm tra ID trùng, chu trình ưu tiên
hay tham chiếu treo.
