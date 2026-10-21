# ADR-0011: Biên tin cậy — pipeline không tin cậy, phải có người duyệt trước khi vào `Laws`

- **Status**: Accepted
- **Trạng thái cài đặt**: Planned (cơ chế) / Implemented (sự tách biệt về cấu trúc)
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0002](0002-cond-syntax-tree-option-eval.md), FR3, FR5, G2

## Bối cảnh

Bản dịch từ văn bản tiếng Việt sang `Norm` do LLM làm. LLM sai theo kiểu khó
thấy nhất: bản dịch *trông* hợp lý, qua được mọi kiểm tra hình thức, nhưng
**không khớp với luật**. Kernel Lean không phát hiện được loại sai này — nó chỉ
kiểm chứng minh, không kiểm ý nghĩa.

Nói cách khác: soundness (G1) không mua được faithfulness (G2).

## Quyết định

Vẽ một biên tin cậy rõ ràng và chỉ có **một** cổng qua biên đó:

```
KHÔNG TIN CẬY                       │  TIN CẬY
Tier 1, Tier 2                      │  Tier 3 (kernel + LexProof/)
Python, LLM, segmenter, glossary    │  Core, Laws, Verify, Cert
────────────────────────────────────┼──────────────────────────
     Cổng duy nhất: NGƯỜI DUYỆT PHÊ DUYỆT
```

Đầu ra của LLM **không bao giờ** vào `LexProof/Laws/` mà không qua người duyệt.
Thêm nữa, đầu ra của LLM là **dữ liệu, không phải mã**
([ADR-0002](0002-cond-syntax-tree-option-eval.md)), nên nó không thể mang theo
logic lạ kể cả khi lọt qua.

## Hệ quả

**Tốt**
- Một loại lỗi mà máy không thể bắt được giao cho đúng người có thể bắt được.
- Vì là dữ liệu, bản dịch in được và đối chiếu song song được (FR5).
- `Laws` trở thành ranh giới kiểm toán rõ ràng: mọi thứ trong đó, theo định
  nghĩa, đã có người duyệt.

**Xấu**
- Người duyệt trở thành **điểm nghẽn** và cũng là **điểm lỗi**: nếu người duyệt
  bỏ qua, không có lớp bảo vệ nào phía sau. Faithfulness bị chặn trên bởi chất
  lượng việc duyệt.
- Không mở rộng quy mô được: mỗi điều khoản cần thời gian của con người.
- **Hiện chưa có cơ chế cưỡng chế nào.** `LexProof/Laws/` rỗng, và không có gì
  trong Lean ngăn một ai đó thêm thẳng một `Norm` chưa duyệt vào đó. Hiện tại
  đây là **quy ước**, không phải ràng buộc kỹ thuật.
- Trust base còn **rộng hơn** cả kernel: năm định nghĩa `Conflict`,
  `Norm.applies`, `Norm.resolved`, `Incompatible`, `Cond.eval` do người viết và
  không có gì chứng minh chúng khớp với luật. Xem bảng trust base trong
  [traceability.md](../traceability.md).

## Kiểm chứng

Review — và đây là một kiểm chứng *quy trình*, không phải kỹ thuật. Cần: bản ghi
duyệt cho từng norm, và mỗi norm trong `Laws` truy được về một lần duyệt cụ thể.

## Trong code

Sự tách biệt về cấu trúc đã có: `LexProof/` (Lean) tách khỏi `pipeline/`
(Python, rỗng). `LexProof/Verify/Smoke.lean` ghi rõ trong docstring đầu file
rằng nó **không** phải module `Laws` và chưa ai duyệt về faithfulness — đúng
kiểu nhãn mà quyết định này đòi.
