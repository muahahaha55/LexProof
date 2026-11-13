# Bản ghi: danh sách ca được viết TRƯỚC khi chạy với mã hóa

- Tệp: `eval/cases/cases_draft.py`
- SHA-256 lúc ghi: `97a345e9bf5409db86bc163392e5a27e377dd92d234427c7b077b6c52c6117cc`
- Thời điểm ghi: 2026-10-31T12:28:07 (giờ máy)
- Tại thời điểm này **chưa** có `Cases.lean` nào được chạy với `AlcoholSale.lean` trên danh sách này; mọi kết quả chạy được tạo sau mốc này.
- Giới hạn trung thực: tôi (cùng một người soạn) đã viết `AlcoholSale.lean` trước đó trong cùng phiên, nên các ca **không độc lập** với hiểu biết của tôi về mã hóa.
  Điều tôi làm được là chốt kỳ vọng từ chữ của khoản luật trước khi chạy và không sửa kỳ vọng sau khi thấy kết quả (xem phần «Sửa sau khi chạy» cuối tệp nếu có).

## D54 — mức chi tiết của nguồn. Lần đầu HOÀN TÁC (quy tắc (d)); làm lại trên nhánh `d54-c23-branch-source` sau khi được phép sửa `AlcoholSaleRefs.lean`

Thử: norm `5.11-ii` «Điều 5 khoản 11» → «Điều 5 khoản 11 nhánh (ii)»; C22 và C23 → «… nhánh (ii)» (trích dẫn của cả hai là «bán rượu, bia bằng máy bán hàng tự động», chỉ thuộc nhánh (ii)); C24 → «… nhánh (i)» (trích dẫn «Kinh doanh rượu không có giấy phép hoặc không đăng ký», chỉ thuộc nhánh (i)). Không đổi điều kiện, kỳ vọng hay ngữ nghĩa mã hóa.

Kết quả build (cùng một thay đổi, hai biến thể):

| Biến thể | Định lý buộc phải đổi | Lý do |
|---|---|---|
| norm + C22 + C23 + C24 | `AlcoholSaleRefs.refOutOfScope_set` (`["C23","C24"]` → `["C24"]`) | C23 không còn trích khoản 11 nguyên, nên không còn là tổ tiên của nhánh (i) chưa mã hóa; C23 vào phạm vi |
| norm + C22 + C24 (giữ C23) | `AlcoholSaleBands.unmentioned_set` (`["Điều 19 (tiêu đề)"]` → thêm «Điều 5 khoản 11») | C23 vẫn trích «Điều 5 khoản 11», nhưng không norm nào còn dùng đúng chuỗi đó và danh sách notEncoded cũng không có |

Quy tắc (d): định lý hiện có không được đổi → hoàn tác D54 (`git checkout` hai tệp). Ghi nhận: không ca nào đổi trạng thái vì không có thay đổi nào được giữ. Muốn làm D54 cần được phép sửa `AlcoholSaleBands.lean` và `AlcoholSaleRefs.lean` (hai định lý nêu trên); cũng cần sửa `eval/cases/cases_draft.py` vì tệp Lean được sinh từ đó.

### D54 làm lại (2026-11-13), nhánh `d54-c23-branch-source`

Biến thể 1 của bảng trên (norm + C22 + C23 + C24), được phép sửa `AlcoholSaleRefs.lean`, `AlcoholSaleBands.lean`, `eval/cases/cases_draft.py`. Đã đổi: `AlcoholSale.lean` (nguồn của 5.11-ii), `cases_draft.py` + `eval/sale-group/common.py` (hai khóa mới `5.11i`, `5.11ii`), `AlcoholSaleCases.lean` (sinh lại, chỉ ba dòng `clause`), `AlcoholSaleRefs.lean` (`refOutOfScope_set` thành `["C24"]`). `AlcoholSaleBands.lean` không phải sửa. `lake build` xanh, 34 test pass. Trạng thái ca: không ca nào đổi kết quả chạy; C23 chuyển từ ngoài phạm vi sang trong phạm vi và PASS. Phiếu `docs/review/sale-group-cases.md`: cột 1–5 của mọi hàng không đổi; hai dòng sha256 trong phiếu không còn khớp, cần người duyệt xác nhận lại trước khi sinh báo cáo `reviewed`.
