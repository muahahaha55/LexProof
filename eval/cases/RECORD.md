# Bản ghi: danh sách ca được viết TRƯỚC khi chạy với mã hóa

- Tệp: `eval/cases/cases_draft.py`
- SHA-256 lúc ghi: `97a345e9bf5409db86bc163392e5a27e377dd92d234427c7b077b6c52c6117cc`
- Thời điểm ghi: 2026-10-31T12:28:07 (giờ máy)
- Tại thời điểm này **chưa** có `Cases.lean` nào được chạy với `AlcoholSale.lean` trên danh sách này; mọi kết quả chạy được tạo sau mốc này.
- Giới hạn trung thực: tôi (cùng một người soạn) đã viết `AlcoholSale.lean` trước đó trong cùng phiên, nên các ca **không độc lập** với hiểu biết của tôi về mã hóa.
  Điều tôi làm được là chốt kỳ vọng từ chữ của khoản luật trước khi chạy và không sửa kỳ vọng sau khi thấy kết quả (xem phần «Sửa sau khi chạy» cuối tệp nếu có).

## D54 — thử đổi mức chi tiết của nguồn (đã HOÀN TÁC, không có thay đổi nào được giữ)

Thử: norm `5.11-ii` «Điều 5 khoản 11» → «Điều 5 khoản 11 nhánh (ii)»; C22 và C23 → «… nhánh (ii)» (trích dẫn của cả hai là «bán rượu, bia bằng máy bán hàng tự động», chỉ thuộc nhánh (ii)); C24 → «… nhánh (i)» (trích dẫn «Kinh doanh rượu không có giấy phép hoặc không đăng ký», chỉ thuộc nhánh (i)). Không đổi điều kiện, kỳ vọng hay ngữ nghĩa mã hóa.

Kết quả build (cùng một thay đổi, hai biến thể):

| Biến thể | Định lý buộc phải đổi | Lý do |
|---|---|---|
| norm + C22 + C23 + C24 | `AlcoholSaleRefs.refOutOfScope_set` (`["C23","C24"]` → `["C24"]`) | C23 không còn trích khoản 11 nguyên, nên không còn là tổ tiên của nhánh (i) chưa mã hóa; C23 vào phạm vi |
| norm + C22 + C24 (giữ C23) | `AlcoholSaleBands.unmentioned_set` (`["Điều 19 (tiêu đề)"]` → thêm «Điều 5 khoản 11») | C23 vẫn trích «Điều 5 khoản 11», nhưng không norm nào còn dùng đúng chuỗi đó và danh sách notEncoded cũng không có |

Quy tắc (d): định lý hiện có không được đổi → hoàn tác D54 (`git checkout` hai tệp). Ghi nhận: không ca nào đổi trạng thái vì không có thay đổi nào được giữ. Muốn làm D54 cần được phép sửa `AlcoholSaleBands.lean` và `AlcoholSaleRefs.lean` (hai định lý nêu trên); cũng cần sửa `eval/cases/cases_draft.py` vì tệp Lean được sinh từ đó.
