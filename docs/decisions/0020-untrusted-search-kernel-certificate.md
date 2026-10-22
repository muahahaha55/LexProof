# ADR-0020: Tìm kiếm không tin cậy, kết luận có chứng chỉ kernel kiểm

- **Status**: Proposed — **chưa cài** (`Cert` vẫn rỗng, theo đúng D21)
- **Trạng thái cài đặt**: **Planned**
- **Ngày**: 2026-10-22
- **Người quyết định**: Tác giả đồ án (cần chốt)
- **Liên quan**: [ADR-0010](0010-axiom-whitelist-decide-only.md), [ADR-0009](0009-own-finite-class-no-mathlib.md), [ADR-0015](0015-characterize-conflict-labels.md), FR11, N1, N8

## Bối cảnh

Hai ràng buộc đang kéo ngược nhau.

**Ràng buộc soundness** ([ADR-0010](0010-axiom-whitelist-decide-only.md)): chỉ
`decide`, tức kernel Lean phải tự tính toàn bộ phép quét. Đo được trên máy dev:
2^12 ≈ 1s, 2^14 ≈ 7s, 2^16 ≈ 50s, 2^18 **thất bại** (hết heartbeat ở `whnf`,
và định lý khi đó mang `sorryAx` — thất bại *im lặng* nếu chỉ xem build có xanh).

**Ràng buộc quy mô** (N8): chi phí là `|S| × |P| × số cặp`. Mỗi khái niệm mở
nhân đôi `|P|` ([ADR-0003](0003-open-concepts-as-finite-parameters.md)). Một
văn bản thật sẽ vượt 2^14 rất nhanh.

Lối thoát hiển nhiên là chạy phép quét **đã biên dịch** — nhanh hơn kernel nhiều
bậc. Nhưng `native_decide` sinh một axiom **đặt tên theo từng định lý**
(`<tên>._native.native_decide.ax_1_1`), và `bv_decide` cũng vậy ngay khi goal
thật sự phải gọi SAT solver (`<tên>._native.bv_decide.ax_1_5`). Cả hai phá
whitelist. Dùng chúng là đổi soundness lấy tốc độ, mà soundness là G1 — mục tiêu
số một.

## Quyết định được đề xuất

Tách **tìm kiếm** khỏi **kết luận**.

1. Phép tìm kiếm **được phép** chạy đã biên dịch, ngoài kernel, và được coi là
   **không tin cậy** — cùng hạng với `pipeline/`
   ([ADR-0011](0011-trust-boundary-human-approval.md)).
2. Bất cứ điều gì báo cáo **là đã kiểm chứng** phải được chống lưng bởi một định
   lý mà **kernel đã tự tính** (`decide`, hoặc `decide +kernel`), và phải qua
   audit axiom theo whitelist.
3. Mọi thứ không có chứng chỉ như vậy phải được **dán nhãn rõ là chưa kiểm
   chứng**, không được trình bày lẫn với kết luận đã kiểm.

### Điều cốt lõi: bất đối xứng giữa tồn tại và phổ quát

Đây là lý do quyết định này khả thi, và cũng là giới hạn của nó.

| Loại khẳng định | Chứng chỉ | Chi phí kernel |
|---|---|---|
| **Tồn tại** — "hai điều này xung đột tại `(π, s)`" | Chính `(π, s)` và hai `NormId` | **Một điểm**: `isConflictAt A n₁ n₂ π s = true` bằng `decide`. Hằng số, không phụ thuộc `\|S\|` |
| **Phổ quát** — "nhất quán trên toàn scope" | Không có chứng chỉ nhỏ nào | **Toàn miền**: kernel phải quét hết. Đúng bằng chi phí hiện tại |

Nói cách khác: tìm kiếm biên dịch giúp được **phát hiện xung đột**, và **không
giúp gì** cho khẳng định nhất quán. Đó không phải thiếu sót của bản thiết kế mà
là bản chất của hai loại mệnh đề.

### Bản thực thi đã biên dịch ĐƯỢC phép khẳng định

- "Đây là một phản ví dụ ứng viên": hai `NormId`, một `π`, một `s`. Sau đó
  kernel kiểm lại **một điểm** đó và cấp chứng chỉ. Đây là đường đi chính và nó
  giữ nguyên soundness.
- "Phép quét này không tìm thấy xung đột nào" — như một **báo cáo tìm kiếm**,
  nêu rõ đã quét gì. Đây **không** phải `consistentOn`.
- "Validator thấy các khuyết điểm cấu trúc sau" — nhưng mỗi finding phải hoặc
  được kernel kiểm lại, hoặc dán nhãn chưa kiểm chứng. Lưu ý phát hiện chu trình
  ưu tiên hiện **chưa có chứng minh đúng đắn** nào, kể cả trong bản chạy bằng
  kernel.

### Bản thực thi đã biên dịch KHÔNG được khẳng định

- **`consistentOn`, hay bất kỳ mệnh đề phổ quát nào.** Không có chứng chỉ nhỏ;
  cho phép điều này là đánh đổi G1 lấy tốc độ.
- **Nhãn `conflict` so với `conditionalConflict`.** Phân biệt hai nhãn là một
  mệnh đề phổ quát trên `P` ([ADR-0015](0015-characterize-conflict-labels.md)),
  nên nó phải do kernel tính. Bản biên dịch chỉ được đề xuất nhãn.
- **Không xung đột trên phần `valid` loại bỏ** — việc này còn chưa được khẳng
  định ngay cả bây giờ, và không được phép lẫn vào.
- Bất cứ điều gì về **faithfulness** (G2). Không liên quan đến tốc độ; không
  bản thực thi nào khẳng định được.

## Hệ quả

**Tốt**
- Tốc độ ở đúng chỗ cần: tìm xung đột trên văn bản lớn.
- Whitelist axiom không đổi; `Cert` vẫn là một cổng whitelist đơn giản.
- Cơ sở tin cậy không rộng ra: bộ tìm kiếm nằm cùng hạng với `pipeline/`.
- Khớp với cách báo cáo đã có: `Result` vốn phân biệt phát hiện với khẳng định
  phạm vi.

**Xấu**
- **Khẳng định nhất quán không được lợi gì.** Trần 2^14 vẫn là trần cho
  `consistentOn`. Vì "nhất quán trên phần đã mã hóa" là đầu ra hay dùng nhất,
  lợi ích thực tế hẹp hơn vẻ ngoài.
- Hai đường code (biên dịch và kernel) có thể **lệch nhau**; lệch đó không phải
  lỗi soundness nhưng gây nhầm lẫn và cần test đối chiếu.
- Thêm một chế độ "chưa kiểm chứng" vào đầu ra, tức thêm chỗ cho người đọc hiểu
  sai. Nhãn phải rất rõ (N10).
- Lối thoát cho chiều phổ quát là một **định dạng chứng chỉ unsat** kiểu LRAT.
  Nhưng chính `bv_decide` đi đường đó, và trong 4.35 phần kiểm LRAT của nó lại
  chạy qua một native axiom — nên áp dụng ngây thơ sẽ **đưa axiom trở lại**.

## Những điều CHƯA kiểm

Nói rõ để không ai đọc ADR này như một kết quả đã đo:

1. **`decide +kernel` có nâng được trần hay không: chưa kiểm.** Chưa chạy thử
   lần nào.
2. **Tốc độ bộ tìm kiếm biên dịch so với `decide` trong kernel: chưa kiểm.** Số
   2^12…2^18 ở trên đo bằng `(List.range N).all` làm đại diện, **không** phải
   bằng `check` thật.
3. **Chi phí kiểm lại một điểm bằng kernel ở `|S|` thực tế: chưa kiểm.** Lập
   luận rằng nó là hằng số nghe hợp lý nhưng chưa đo.
4. **Một định dạng chứng chỉ cho chiều phổ quát mà không cần native axiom: chưa
   khảo sát.**
5. Toàn bộ ADR này **chưa có code**. `LexProof/Cert/` rỗng, đúng theo D21.

## Kiểm chứng

Proof (mọi kết luận đã kiểm chứng có `#print axioms` sạch) + Test (đối chiếu
đường biên dịch với đường kernel trên cùng đầu vào) + Review (nhãn "chưa kiểm
chứng" phải đọc hiểu được, N10).

## Trong code

Chưa có gì. Hiện mọi phép quét chạy trong kernel qua `decide`, nên câu hỏi này
còn là lý thuyết — và nó sẽ trở thành cấp thiết đúng lúc module `Laws` thật đầu
tiên vượt trần.
