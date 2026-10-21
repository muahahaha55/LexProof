# ADR-0015: Định nghĩa chính xác hai nhãn, và bắt buộc có định lý đặc trưng trước `Laws`

- **Status**: Accepted
- **Trạng thái cài đặt**: **Planned**
- **Ngày**: 2026-10-21
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0008](0008-report-conditional-conflicts.md), [ADR-0003](0003-open-concepts-as-finite-parameters.md), FR7, N1

## Bối cảnh

`mkResult` phân biệt hai nhãn bằng cách giữ nguyên tình huống `s₀` của nhân
chứng rồi kiểm `(Finite.enum P).all (fun π => isConflictAt … π s₀)`.

Hai vấn đề:

1. **Ngữ nghĩa chưa chốt.** "Xung đột vô điều kiện" có thể hiểu là (a) *có một
   tình huống* mà mọi gán trị tham số đều xung đột, hay (b) *với mọi gán trị
   tham số đều có* một tình huống xung đột (tình huống có thể khác nhau theo
   `π`). Code đang làm (a). Hai cách cho nhãn khác nhau trên cùng dữ liệu.
2. **Không có định lý nào nối nhãn với ngữ nghĩa.** Hai định lý hiện có
   (`conflict_of_witness`, `not_conflict_of_consistentOn`) đi qua `witness?` nên
   **không phân biệt** `conflict` với `conditionalConflict`. Nhãn hiện chỉ *được
   tính*, chưa *được chứng minh* — tức là một khẳng định không có kernel chống
   lưng, đúng loại thứ mà N1 cấm.

Đáng chú ý: `Finite.forall_of_all` đã có sẵn trong `Core/Finite.lean` chính là
bổ đề cần cho việc này, nhưng **hiện chưa ai dùng**.

## Quyết định

1. Chốt ngữ nghĩa **(a)**: `conflict` nghĩa là **một tình huống xung đột dưới
   mọi gán trị tham số**; mọi trường hợp còn lại là `conditionalConflict`.
2. **Bắt buộc** có một định lý đặc trưng cho *cả hai* nhãn **trước khi** viết
   module `Laws` đầu tiên. Dự kiến dạng:

   ```lean
   theorem conflict_iff_all_params (h : check A ns = .conflict c) :
       ∀ π : P, Conflict A n₁ n₂ π c.situation

   theorem conditionalConflict_iff_some_params
       (h : check A ns = .conditionalConflict c ps) :
       (∃ π, Conflict A n₁ n₂ π c.situation) ∧ (∃ π, ¬ Conflict A n₁ n₂ π c.situation)
   ```

   Phát biểu chính xác sẽ chốt khi chứng minh; `Finite.forall_of_all` là bước
   đầu của chiều thứ nhất.

## Hệ quả

**Tốt**
- Lấp đúng khoảng trống còn lại giữa code và chứng minh trong `Verify`.
- Báo cáo được phép dùng từ "xung đột vô điều kiện" với bảo đảm từ kernel.
- Khiến `Finite.forall_of_all` có người dùng, đúng mục đích nó được viết ra.

**Xấu**
- Ngữ nghĩa (a) **chặt hơn** (b): một xung đột xảy ra với mọi cách hiểu nhưng ở
  các tình huống khác nhau sẽ bị dán nhãn `conditionalConflict`, nghe nhẹ hơn
  thực tế. Chấp nhận, vì nói nhẹ đi an toàn hơn nói quá (G3).
- Chiều `conditionalConflict` cần **hai** nhân chứng ngược nhau, nên khó chứng
  minh hơn chiều kia, và có thể phải cho `mkResult` trả về luôn nhân chứng phủ
  định thay vì chỉ một cờ Bool.
- Là một cửa chặn: không có định lý này thì không được viết `Laws`.

## Kiểm chứng

Proof. Chưa có; đây là mục nợ chứng minh được theo dõi (R3 trong
[architecture.md](../architecture.md)).

## Trong code

Hiện tại: `mkResult` trong `LexProof/Verify/Conflict.lean` tính nhãn nhưng không
có định lý. `Finite.forall_of_all` trong `LexProof/Core/Finite.lean` chưa được
dùng. Nhánh `conditionalConflict` chưa có test.
