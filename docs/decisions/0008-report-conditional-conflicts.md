# ADR-0008: Báo xung đột có điều kiện kèm tên tham số liên quan

- **Status**: Accepted
- **Trạng thái cài đặt**: Implemented (phần tính) / Planned (phần chứng minh)
- **Ngày**: 2026-10-20
- **Người quyết định**: Tác giả đồ án
- **Liên quan**: [ADR-0003](0003-open-concepts-as-finite-parameters.md), [ADR-0015](0015-characterize-conflict-labels.md), FR7, FR9

## Bối cảnh

Vì khái niệm mở là tham số ([ADR-0003](0003-open-concepts-as-finite-parameters.md)),
một xung đột có thể xảy ra với **mọi** cách hiểu, hoặc chỉ với **một số** cách
hiểu. Hai trường hợp này có ý nghĩa pháp lý rất khác nhau:

- Xung đột với mọi cách hiểu: văn bản có lỗi, bất kể ai đọc.
- Xung đột chỉ khi "nghiêm trọng" được hiểu theo một nghĩa: đây không phải lỗi
  của văn bản mà là một **điểm cần giải thích**, và người có thẩm quyền phải
  quyết định.

Gộp cả hai vào một nhãn "conflict" là nói quá, và vi phạm nguyên tắc hệ thống
không bao giờ tự quyết khái niệm mở.

## Quyết định

Hai nhãn riêng:

- `Result.conflict c` — xung đột tại tình huống đó với **mọi** gán trị của `P`.
- `Result.conditionalConflict c params` — ngược lại, kèm **tên** các tham số
  khái niệm mở mà hai norm nhắc tới, lấy từ `Atoms.param`.

Cách phân loại trong code: giữ nguyên tình huống `s₀` của nhân chứng, rồi kiểm
`(Finite.enum P).all (fun π => isConflictAt … π s₀)`.

## Hệ quả

**Tốt**
- Báo cáo nói đúng mức độ chắc chắn, và nêu rõ *khái niệm nào* quyết định kết
  quả, nên người duyệt biết phải phán đoán điều gì.
- Danh sách tên có được miễn phí nhờ `Cond` là cây cú pháp
  ([ADR-0002](0002-cond-syntax-tree-option-eval.md)) — `Cond.paramIdxs` đọc
  thẳng từ cú pháp.

**Xấu**
- `paramNames` trả về **mọi** tham số hai norm nhắc tới, **không phải** tập
  tham số thực sự làm thay đổi kết quả. Nó là một xấp xỉ quá rộng; một tham số
  xuất hiện trong điều kiện nhưng không ảnh hưởng gì vẫn bị nêu tên.
- Định nghĩa "có điều kiện" hiện **cố định tình huống** `s₀`. Một ngữ nghĩa khác
  là "với mọi `π` đều có xung đột, nhưng ở tình huống khác nhau". Hai ngữ nghĩa
  cho nhãn khác nhau trên cùng một dữ liệu — xem [ADR-0015](0015-characterize-conflict-labels.md).
- **Chưa có định lý** nào nối nhãn với ngữ nghĩa của nó. `mkResult` dùng
  `enum.all` nhưng không bổ đề nào chuyển nó sang `∀ π`. Nhãn hiện chỉ *được
  tính*, chưa *được chứng minh*.
- Nhánh `conditionalConflict` **chưa có test nào**.

## Kiểm chứng

Proof (theo [ADR-0015](0015-characterize-conflict-labels.md), còn thiếu) +
Review (người duyệt đọc danh sách tham số).

## Trong code

`Result.conditionalConflict`, `mkResult`, `paramNames` trong
`LexProof/Verify/Conflict.lean`; `Cond.paramIdxs`, `Norm.paramIdxs` trong
`LexProof/Core/Norm.lean`.
