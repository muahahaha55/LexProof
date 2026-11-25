# Lộ trình và tiến độ

Cập nhật: 2026-11-25 (sau [ADR-0031](decisions/0031-scope-down-for-thesis.md): thu gọn yêu cầu cho bản đồ án). Con số % dưới đây là **ước lượng theo kế hoạch của repo**, không phải theo đề bài môn học (chưa có rubric).

## Mục tiêu

Hệ thống **Level 1**: nhận một văn bản luật tiếng Việt, kiểm tra các điều khoản **trong văn bản đó** có mâu thuẫn không, trả một trong ba kết quả (tìm thấy xung đột / nhất quán trên phần đã mã hóa / không biết), kèm phạm vi đã mã hóa và trạng thái duyệt. Không bao giờ kết luận «văn bản đúng». Level 2 (nhiều văn bản, thứ bậc, hiệu lực theo thời gian) để sau.

Đường đi: văn bản → tách điều khoản → AI dịch thành dữ liệu → **người duyệt** → Lean kiểm tra → báo cáo.

## Tiến độ theo các yêu cầu Must (`requirements.md`, sau ADR-0031)

Cách tính: Implemented = 1, Tested = 0.6, Partial = 0.5, Planned/Open = 0. FR4 đã chuyển sang Won't; N5, N8, N9 sang Should.

| Nhóm | Yêu cầu | Ước lượng |
|---|---|---|
| Chức năng (10 Must) | FR1, FR2, FR5, FR6, FR7, FR8, FR9, FR10, FR11 Implemented; FR3 Tested (dán tay) | ~96% (9.6 / 10) |
| Phi chức năng (9 Must) | N1, N2, N3, N6, N7, N11, N12 Implemented; N4, N10 Partial | ~89% (8 / 9) |
| Tổng | | ~92% (17.6 / 19) |

**Đọc con số này cẩn thận.** So với ~55% ngày 2026-11-24, phần tăng đến từ ba nguồn: việc mới (module gộp, cạnh kéo theo,
lỗi soạn thảo, báo cáo `law44`), cập nhật các trạng thái đã lỗi thời, và **hạ mức** FR4, N5, N8, N9. Mẫu số cũng đổi
(trước chỉ tính 11 FR). **Độ trung thực vẫn là chỗ yếu nhất**: một người duyệt, chưa có bộ ca độc lập (FR12), kết luận
nhất quán chính rỗng về thông tin.

Việc kỹ thuật trước đóng gói: xong (FR9, 2026-11-25). Còn lại: N10 (thử với một người không biết Lean ngoài Phong), N4 (người duyệt thứ hai, FR12), và viết quyển, slide.

**Tiến độ dữ liệu (2026-11-24, chi tiết ở `docs/coverage.md`)**: 15/36 điều đã qua người duyệt và vào `LexProof/Laws/` (Điều 5, 10, 12–21, 32–34); 21/36 là phân loại «không mã hóa» của AI, Phong đồng ý để ngoài (21/21). Bản gộp 14 bản dịch (Điều 19 đã dịch lại theo bảng thuật ngữ, Phong duyệt 13/13, module thay) cho 69 norm, `consistentOn`, vẫn rỗng về xung đột modality. Con số % ở trên **chưa tính lại**: các điều mới là dữ liệu, không thêm chức năng.

## Lộ trình

| Bước | Việc | Trạng thái |
|---|---|---|
| 1 | Một lệnh: bản dịch đã kiểm → bản nháp Lean gộp → kiểm tra Lean → báo cáo nháp (`pipeline/run.py`, ADR-0025) | **xong** (2026-11-18); kết quả Lean là Evaluated, chưa có định lý kernel |
| 2 | Đường từ bản nháp đã duyệt sang module `LexProof/Laws/` (`pipeline/promote.py`, ADR-0026) | **xong** (2026-11-21): hai module thật đầu tiên, `LexProof/Laws/Article19.lean` và `Article15.lean`, từ phiếu của Phong; kernel chứng minh `no_conflict`, nhưng cả hai **rỗng về xung đột modality** (Điều 19 chỉ có cấm, Điều 15 chỉ có cho phép). Điều 5 bị bác (N:5.11.1, A:13): phải dịch lại |
| 3 | Dịch cả một điều dài theo lô (thử Điều 15, có điểm lồng) | **làm một điều** (2026-11-20): Điều 15 qua `check` lần đầu, Lean 0 finding; đã duyệt và vào thư viện (2026-11-21); chưa làm theo lô nhiều điều |
| 4 | Bộ ca của người học luật, trả lời độc lập (FR12) | chưa; phụ thuộc người ngoài |
| 5 | Kiểm trên cả văn bản và qua quan hệ giữa hành vi: module gộp `Law44`, cạnh kéo theo (ADR-0029), dấu hiệu lỗi soạn thảo (ADR-0030), báo cáo `law44` | **xong** (2026-11-25); cạnh chờ duyệt |
| 6 | FR9: phản ví dụ bằng lời | **xong** (2026-11-25) |
| 7 | Đóng gói đồ án: demo một lệnh (`pipeline/demo.py`), `README.md`, dàn ý quyển và slide (`docs/thesis-outline.md`) | **phần repo xong** (2026-11-25); quyển và slide chưa viết |

Sau bước 1 và 2: có hệ thống cơ bản chạy từ đầu đến cuối. Bước 3–5: mở rộng và bằng chứng chất lượng.

Bảng thuật ngữ dùng chung (FR2, ADR-0027, Accepted 2026-11-20): theo từng văn bản, Phong duyệt, ba act bán / cung cấp / khuyến mại riêng. Bước 1/5 xong (lược đồ, `check`, bảng hạt giống `data/glossary/44-2019-QH14.json`, mọi mục chưa duyệt). Bước 2/5 xong (câu lệnh `--glossary`, `glossary_proposals`, `check` theo id). Bước 3/5 xong (gộp theo id; `promote.py` chặn thuật ngữ chưa duyệt; phiếu norm ghim sha256 của bảng). Bước 4/5 xong (`glossary.py sheet`/`apply`; phiếu trống cho Phong `docs/review/duyet-bang-thuat-ngu-44-2019-QH14.md`, 15 mục). Bước 5/5 đã đo, kết quả âm: Điều 5 + 15 với bảng có 3 cặp được kiểm (không dùng bảng là 5), không act chung, vẫn rỗng về thông tin, vì hai điều điều chỉnh hai hành vi khác nhau (ADR-0027 «Bước 5: kết quả»). Phong đã duyệt bảng (2026-11-21): 60 chấp nhận, 1 bác (`co_giay_phep_hoac_dang_ky_kinh_doanh_ruou`). Kiểm Điều 5 với Điều 15 qua **norm suy ra** (ADR-0028, Accepted 2026-11-20). Bước 1 xong: `derived.py check`, `run.py --derived` chạy Lean thêm một lần và báo riêng ở mục 5b. Kết quả đầu tiên: 3 cặp xung đột, cả 3 dính norm suy ra; công cụ bác được cách đọc «đủ điều kiện cấp phép thì được kinh doanh». Bước 2 xong: phiếu duyệt `derived.py sheet`/`apply` (ghim sha256 tệp suy ra và bảng thuật ngữ; sửa mục đã duyệt thì `check` báo); phiếu trống cho Phong `docs/review/duyet-norm-suy-ra-44-2019-QH14.md`. Phong đã duyệt (2026-11-21): bác cả D1 và D2; mục bị bác không còn được chạy. Còn: đề xuất cách đọc mới, rồi đưa norm suy ra đã duyệt vào `promote.py`. Cần trước khi dịch theo lô, vì không có nó các điều không so được với nhau.

Việc đang chờ người duyệt: phiếu 2 cạnh E9, E10 (`docs/review/duyet-canh-keo-theo-44-2019-QH14.md`); câu hỏi R0/R1/R2 về Điều 32 khoản 4 × Điều 5 khoản 12; câu hỏi (a)/(b) về ngoại lệ của norm 15.2 (ADR-0030).

## Tạm gác (không chặn lộ trình)

- **Nghị quyết 66.18/2026/NQ-CP và ca C24**: Level 2. Chỉ ghi giới hạn vào báo cáo. Câu hỏi Q8–Q10 đang chờ người đối chiếu (`docs/review/huong-dan-doi-chieu.md`).
- **G4** (ngoại lệ «trừ…» có tạo quyền không): Phong cho là có; chờ ý kiến người thứ hai trước khi đổi bản mã hóa.
- **Tệp của Phong**: C37 mâu thuẫn với Q4; ô «Đúng ý / Sai ý» ghi nhầm ở C26, C28, C30, C35; 15 ca «được phép» so với «không điều chỉnh». Chờ Phong trả lời.
