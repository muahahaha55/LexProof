# Lộ trình và tiến độ

Cập nhật: 2026-11-18. Con số % dưới đây là **ước lượng theo kế hoạch của repo**, không phải theo đề bài môn học (chưa có rubric).

## Mục tiêu

Hệ thống **Level 1**: nhận một văn bản luật tiếng Việt, kiểm tra các điều khoản **trong văn bản đó** có mâu thuẫn không, trả một trong ba kết quả (tìm thấy xung đột / nhất quán trên phần đã mã hóa / không biết), kèm phạm vi đã mã hóa và trạng thái duyệt. Không bao giờ kết luận «văn bản đúng». Level 2 (nhiều văn bản, thứ bậc, hiệu lực theo thời gian) để sau.

Đường đi: văn bản → tách điều khoản → AI dịch thành dữ liệu → **người duyệt** → Lean kiểm tra → báo cáo.

## Tiến độ theo 11 yêu cầu Must (`requirements.md`)

Cách tính: Implemented = 1, Tested = 0.6, Partial = 0.5, Planned/Open = 0.

| Nhóm | Yêu cầu | Ước lượng |
|---|---|---|
| Lõi kiểm tra (tin cậy) | FR6, FR7, FR8, FR11 Implemented; FR9, FR10 Partial | ~83% |
| Đưa văn bản vào (không tin cậy) | FR1 Partial; FR3 Tested (dán tay); FR2 Partial (bảng chưa duyệt); FR4 Planned; FR5 Open | ~25% |
| Tổng | | ~55% (6.1 / 11) |

Không tính: 13 yêu cầu phi chức năng, FR12 (Should), FR13 (Could). **Độ trung thực hầu như chưa có bằng chứng**: 9/141 khoản mã hóa tay; phiếu 37 ca là đồng thuận với bản nháp AI; một người duyệt độc lập (Phong, 2026-11-18); hai lần dịch AI (Điều 19, Điều 5) mới được đối chiếu một phần.

## Lộ trình

| Bước | Việc | Trạng thái |
|---|---|---|
| 1 | Một lệnh: bản dịch đã kiểm → bản nháp Lean gộp → kiểm tra Lean → báo cáo nháp (`pipeline/run.py`, ADR-0025) | **xong** (2026-11-18); kết quả Lean là Evaluated, chưa có định lý kernel |
| 2 | Đường từ bản nháp đã duyệt sang module `LexProof/Laws/` (`pipeline/promote.py`, ADR-0026) | **xong công cụ** (2026-11-18); chưa có module thật: chờ người điền `docs/review/duyet-ban-dich-dieu-19.md`, `...-dieu-5.md` |
| 3 | Dịch cả một điều dài theo lô (thử Điều 15, có điểm lồng) | **làm một điều** (2026-11-20): Điều 15 qua `check` lần đầu, Lean 0 finding; còn chờ người duyệt (`docs/review/duyet-ban-dich-dieu-15.md`); chưa làm theo lô nhiều điều |
| 4 | Bộ ca của người học luật, trả lời độc lập (FR12) | chưa; phụ thuộc người ngoài |
| 5 | Đóng gói đồ án: báo cáo, demo, phần giới hạn | chưa |

Sau bước 1 và 2: có hệ thống cơ bản chạy từ đầu đến cuối. Bước 3–5: mở rộng và bằng chứng chất lượng.

Bảng thuật ngữ dùng chung (FR2, ADR-0027, Accepted 2026-11-20): theo từng văn bản, Phong duyệt, ba act bán / cung cấp / khuyến mại riêng. Bước 1/5 xong (lược đồ, `check`, bảng hạt giống `data/glossary/44-2019-QH14.json`, mọi mục chưa duyệt). Bước 2/5 xong (câu lệnh `--glossary`, `glossary_proposals`, `check` theo id). Bước 3/5 xong (gộp theo id; `promote.py` chặn thuật ngữ chưa duyệt; phiếu norm ghim sha256 của bảng). Bước 4/5 xong (`glossary.py sheet`/`apply`; phiếu trống cho Phong `docs/review/duyet-bang-thuat-ngu-44-2019-QH14.md`, 15 mục). Còn: chạy lại Điều 5 + 15 với bảng (bước 5), và Phong duyệt bảng. Cần trước khi dịch theo lô, vì không có nó các điều không so được với nhau.

Việc đang chờ người duyệt (Phong): `docs/review/HUONG-DAN-TIEP-THEO-cho-Phong.md`.

## Tạm gác (không chặn lộ trình)

- **Nghị quyết 66.18/2026/NQ-CP và ca C24**: Level 2. Chỉ ghi giới hạn vào báo cáo. Câu hỏi Q8–Q10 đang chờ người đối chiếu (`docs/review/huong-dan-doi-chieu.md`).
- **G4** (ngoại lệ «trừ…» có tạo quyền không): Phong cho là có; chờ ý kiến người thứ hai trước khi đổi bản mã hóa.
- **Tệp của Phong**: C37 mâu thuẫn với Q4; ô «Đúng ý / Sai ý» ghi nhầm ở C26, C28, C30, C35; 15 ca «được phép» so với «không điều chỉnh». Chờ Phong trả lời.
