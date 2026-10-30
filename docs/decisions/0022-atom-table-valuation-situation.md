# ADR-0022: Tình huống là phép gán trị cho bảng atom (V0, chỉ thêm)

- **Status**: Proposed — **chưa quyết định** có chuyển `Laws` sang mô hình này hay không
- **Trạng thái cài đặt**: **Implemented một phần** — chỉ tầng V0 (`LexProof/Core/AtomTable.lean`); chưa nối vào `check`/`analyze`
- **Ngày**: 2026-10-30
- **Người quyết định**: Tác giả đồ án (cần chốt)
- **Liên quan**: [ADR-0003](0003-open-concepts-as-finite-parameters.md), [ADR-0006](0006-defer-subject-and-time.md), [ADR-0009](0009-own-finite-class-no-mathlib.md), [ADR-0019](0019-back-translation-renderer.md), [ADR-0020](0020-untrusted-search-kernel-certificate.md), [ADR-0021](0021-integrity-constraint-valid.md), [../situation-model.md](../situation-model.md), [../situation-model-experiment.md](../situation-model-experiment.md), N8, N9

## Bối cảnh

Hiện tại mỗi văn bản tự khai một `structure S` và `structure P`, hai instance
`Finite` viết tay, và một bảng `Atoms` mà bộ đọc là hàm Lean tùy ý
([ADR-0006](0006-defer-subject-and-time.md), [ADR-0009](0009-own-finite-class-no-mathlib.md)).
Hệ quả đã phân tích ở [situation-model.md](../situation-model.md): kernel không
kiểm được "S là tích các trường độc lập", không đếm được miền lớn mà không
liệt kê, `valid` là hàm mờ ([ADR-0021](0021-integrity-constraint-valid.md)), và
một module `Laws` phải sinh mã Lean (hai structure và instance) thay vì dữ liệu.

[situation-model-experiment.md](../situation-model-experiment.md) đo rủi ro lớn
nhất của hướng thay thế (bảng tra có đắt trong kernel không): trên hai cặp thật,
tỉ lệ chi phí B/A ≈ 1,07 và thời gian gần tuyến tính theo số điểm.

## Quyết định (đề xuất)

Thêm — **không sửa gì có sẵn** — một tầng dữ liệu:

- **Bảng atom** (`AtomTable`): danh sách atom, mỗi atom có tên, miền (`Bool` hoặc
  enum có tên giá trị) và chuỗi nguồn (khoản luật). Mỗi dải của một nhóm ngưỡng là
  một giá trị enum mang khoản nguồn riêng, cho người duyệt.
- **Phép gán** (`Valuation t`): một chỉ số giá trị cho mỗi atom, nằm trong miền.
  Kiểu tình huống của văn bản là `Valuation bảng`.
- **Cắm vào API hiện tại**: `Finite (Valuation t)` là một instance của lớp `Finite`
  có sẵn; `atomsOf` dựng một `Atoms (Valuation ts) (Valuation tp)` thường (bộ đọc
  "atom `i` có giá trị `v`"), `valid` giữ mặc định. `check`, `analyze`, `scopeOf` nhận
  nó không đổi.
- **Ràng buộc toàn vẹn là cây `Cond`** trên cùng các bộ đọc; V0 chỉ định nghĩa dữ
  liệu và cách đánh giá (`icsEval`), **không** đưa vào bộ kiểm.

Đã chứng minh trong V0: (P1) mỗi phép gán xuất hiện đúng một lần trong `enum`;
(P2) `Finite.card = tích kích thước miền` (và `card_eq_prod`, phát biểu trên bảng);
(P3) một phép gán một phần nằm trong miền, không gán hai giá trị cho một atom, mở
rộng được thành phép gán đầy đủ nếu mọi miền khác rỗng (**chưa** có ràng buộc).

## Hệ quả

**Tốt**
- Tích các trường trở thành **định lý** thay vì quy ước; bộ đọc là tra bảng sinh từ
  dữ liệu, không còn là hàm tùy ý.
- Số điểm đếm được bằng phép nhân, không cần liệt kê (nền cho `Scope` mới).
- Module `Laws` có thể là **bảng + ràng buộc + norm**, đúng hình dạng các bảng B1/B2
  của slice1-notes; không còn phải viết instance `Finite` tay (N9).

**Xấu / chưa giải quyết**
- **Không giải quyết**: nâng phản ví dụ đã chiếu thành điểm thật **khi có ràng buộc**
  (cần thỏa mãn được ràng buộc trên các atom chung); `Scope` (`validExcluded`,
  `validTotal`, `excludedPoints` vẫn quét `enum`); D23 (`coApplyPoint?` vẫn quét toàn
  miền); `Finite.card` vẫn là `enum.length`.
- Bộ đọc đọc ngoài miền trả `0` im lặng nếu bảng/đặc tả sai; V0 chỉ có kiểm
  `readersOk`, chưa nối vào `validate`.
- **Trust base đổi hình dạng hơn là nhỏ đi**: biên dải, nhãn và tính đủ của ràng
  buộc chỉ còn là chữ trên bảng; kernel không kiểm.
- Ngưỡng số phải chia dải tay; thêm ngưỡng mới ở điều khác nghĩa là chia lại dải.
- Số đo chi phí chỉ từ hai cặp cấm × cấm, một máy; xem
  [situation-model-experiment.md](../situation-model-experiment.md) §7.
- Bảng phải là **mã Lean sinh ra** (kernel thấy được); nếu là dữ liệu đọc lúc chạy
  thì bộ phân tích cú pháp vào trust base. Chưa chốt.

## Kiểm chứng

Proof (`Valuation.nodup_enum`, `Valuation.count_enum`, `Valuation.card_eq`,
`card_eq_prod`, `PartialAssign.extend`; `#print axioms` ⊆ whitelist) + Test (các
`example` bằng `decide` trên bảng ba atom) + Experiment (đo chi phí kernel).

## Trong code

`LexProof/Core/AtomTable.lean` và hai dòng `import` (`LexProof.lean`,
`Cert/Audit.lean`). Không file Lean nào khác bị sửa.
