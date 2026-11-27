# Lộ trình và tiến độ

Cập nhật: 2026-11-27 (Level 1 tạm coi là xong; thêm mục «Giai đoạn 2»). Phần tiến độ Level 1 bên dưới giữ số liệu sau [ADR-0031](decisions/0031-scope-down-for-thesis.md). Con số % dưới đây là **ước lượng theo kế hoạch của repo**, không phải theo đề bài môn học (chưa có rubric).

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
(trước chỉ tính 11 FR). **Độ trung thực vẫn là chỗ yếu nhất**: một người duyệt, chưa có bộ ca độc lập (FR12). Kết luận
nhất quán chính không còn rỗng (2026-11-25), nhưng chỉ có nghĩa ở 4 act của Điều 15.

Việc kỹ thuật trước đóng gói: xong (FR9, 2026-11-25). Còn lại: N10 (thử với một người không biết Lean ngoài Phong), N4 (người duyệt thứ hai, FR12), và viết báo cáo dự án (bản giấy và slide).

**Tiến độ dữ liệu (2026-11-25, chi tiết ở `docs/coverage.md`)**: 15/36 điều đã qua người duyệt và vào `LexProof/Laws/` (Điều 5, 10, 12–21, 32–34); 21/36 là phân loại «không mã hóa» của AI, Phong đồng ý để ngoài (21/21). Module gộp `Law44`: 77 norm, kernel chứng minh `consistent`, không còn rỗng (4 act của Điều 15 có cả cấm lẫn được phép); `Law44Drafting`: 0 «không biết». Con số % ở trên **chưa tính lại**: các điều mới là dữ liệu, không thêm chức năng.

## Lộ trình

| Bước | Việc | Trạng thái |
|---|---|---|
| 1 | Một lệnh: bản dịch đã kiểm → bản nháp Lean gộp → kiểm tra Lean → báo cáo nháp (`pipeline/run.py`, ADR-0025) | **xong** (2026-11-18); kết quả Lean là Evaluated, chưa có định lý kernel |
| 2 | Đường từ bản nháp đã duyệt sang module `LexProof/Laws/` (`pipeline/promote.py`, ADR-0026) | **xong** (2026-11-21): hai module thật đầu tiên, `LexProof/Laws/Article19.lean` và `Article15.lean`, từ phiếu của Phong; kernel chứng minh `no_conflict`, nhưng cả hai **rỗng về xung đột modality** (Điều 19 chỉ có cấm, Điều 15 chỉ có cho phép). Điều 5 bị bác (N:5.11.1, A:13): phải dịch lại |
| 3 | Dịch cả một điều dài theo lô (thử Điều 15, có điểm lồng) | **làm một điều** (2026-11-20): Điều 15 qua `check` lần đầu, Lean 0 finding; đã duyệt và vào thư viện (2026-11-21); chưa làm theo lô nhiều điều |
| 4 | Bộ ca của người học luật, trả lời độc lập (FR12) | chưa; phụ thuộc người ngoài |
| 5 | Kiểm trên cả văn bản và qua quan hệ giữa hành vi: module gộp `Law44`, cạnh kéo theo (ADR-0029), dấu hiệu lỗi soạn thảo (ADR-0030), báo cáo `law44` | **xong** (2026-11-25); Phong bác E9, E10 (ứng viên Điều 32 × Điều 5 không còn), chọn cách đọc R2; Điều 15 dịch lại lần 3, dấu hiệu 15.2 hết |
| 6 | FR9: phản ví dụ bằng lời | **xong** (2026-11-25) |
| 7 | Đóng gói: demo một lệnh (`pipeline/demo.py`), `README.md`, báo cáo dự án (`docs/report/bao-cao-du-an.pdf`, 25 trang) và slide | **xong** (2026-11-26). **Level 1 tạm coi là xong** (2026-11-27) |

Sau bước 1 và 2: có hệ thống cơ bản chạy từ đầu đến cuối. Bước 3–5: mở rộng và bằng chứng chất lượng.

Bảng thuật ngữ dùng chung (FR2, ADR-0027, Accepted 2026-11-20): theo từng văn bản, Phong duyệt, ba act bán / cung cấp / khuyến mại riêng. Bước 1/5 xong (lược đồ, `check`, bảng hạt giống `data/glossary/44-2019-QH14.json`, mọi mục chưa duyệt). Bước 2/5 xong (câu lệnh `--glossary`, `glossary_proposals`, `check` theo id). Bước 3/5 xong (gộp theo id; `promote.py` chặn thuật ngữ chưa duyệt; phiếu norm ghim sha256 của bảng). Bước 4/5 xong (`glossary.py sheet`/`apply`; phiếu trống cho Phong `docs/review/duyet-bang-thuat-ngu-44-2019-QH14.md`, 15 mục). Bước 5/5 đã đo, kết quả âm: Điều 5 + 15 với bảng có 3 cặp được kiểm (không dùng bảng là 5), không act chung, vẫn rỗng về thông tin, vì hai điều điều chỉnh hai hành vi khác nhau (ADR-0027 «Bước 5: kết quả»). Phong đã duyệt bảng (2026-11-21): 60 chấp nhận, 1 bác (`co_giay_phep_hoac_dang_ky_kinh_doanh_ruou`). Kiểm Điều 5 với Điều 15 qua **norm suy ra** (ADR-0028, Accepted 2026-11-20). Bước 1 xong: `derived.py check`, `run.py --derived` chạy Lean thêm một lần và báo riêng ở mục 5b. Kết quả đầu tiên: 3 cặp xung đột, cả 3 dính norm suy ra; công cụ bác được cách đọc «đủ điều kiện cấp phép thì được kinh doanh». Bước 2 xong: phiếu duyệt `derived.py sheet`/`apply` (ghim sha256 tệp suy ra và bảng thuật ngữ; sửa mục đã duyệt thì `check` báo); phiếu trống cho Phong `docs/review/duyet-norm-suy-ra-44-2019-QH14.md`. Phong đã duyệt (2026-11-21): bác cả D1 và D2; mục bị bác không còn được chạy. Còn: đề xuất cách đọc mới, rồi đưa norm suy ra đã duyệt vào `promote.py`. Cần trước khi dịch theo lô, vì không có nó các điều không so được với nhau.

Việc đang chờ người duyệt: không còn (2026-11-25). Phong đã quyết phiếu cạnh E9, E10 (bác cả hai), phiếu cách đọc (chọn R2) và câu hỏi 15.2 (chọn (a); Điều 15 dịch lại lần 3, duyệt 24/24).

## Giai đoạn 2: công trình nghiên cứu và khóa luận (từ 2026-11-27)

Level 1 tạm coi là xong. Giai đoạn này có hai sản phẩm dùng chung một nền: **bài tạp chí** (ưu tiên, *Artificial
Intelligence and Law*, xem [publication-q1.md](publication-q1.md)) và **khóa luận** ([thesis-outline.md](thesis-outline.md)).
Định vị và câu hỏi nghiên cứu: [research-plan.md](research-plan.md).

| # | Đầu mục | Kết quả cần có | Trạng thái |
|---|---|---|---|
| 1 | Định vị nghiên cứu và câu hỏi nghiên cứu (RQ) | Một câu tuyên bố đóng góp; RQ1–RQ4; bảng so sánh với L4L, LexGuard, Yadamsuren 2025, Catala | bản nháp: `research-plan.md` |
| 2 | Level 2: nhiều văn bản | Thứ bậc hiệu lực (cấp trên thắng cấp dưới, sau thắng trước), ngày hiệu lực, dẫn chiếu chéo; định lý liên kết mở rộng | chưa; **chờ quyết định Q1** |
| 3 | Mở rộng lõi hình thức | (a) ràng buộc giữa atom, chứng minh phép chiếu vẫn đúng khi có ràng buộc; (b) cách đọc là tham số, kết luận ∀/∃ theo cách đọc; (c) ngữ nghĩa cạnh kéo theo hoàn chỉnh | chưa |
| 4 | Mở rộng dữ liệu | ≥ 3 văn bản khác lĩnh vực, có nhiều quyền; ≥ 300 khoản qua pipeline; dịch theo lô | chưa; chờ Q3, Q5 |
| 5 | Ground truth và độ trung thực | ≥ 2 người có chuyên môn luật gán nhãn độc lập, không xem bản nháp AI; kappa; bộ ca chuyên gia (FR12); đồng ý tham gia | chưa; **nút thắt lớn nhất**, chờ Q2 |
| 6 | Baseline và đánh giá | LLM hỏi thẳng; LLM có bước tự kiểm; LLM + SMT kiểu L4L. Precision/recall trên xung đột gieo vào và thật; chi phí duyệt; thời gian kernel | chưa |
| 7 | Phát hiện có ý nghĩa | Xung đột hoặc mơ hồ được chuyên gia xác nhận, có trích điều khoản; nếu không có thì kết quả âm có lập luận | chưa |
| 8 | Tái lập và công bố | Repo công khai, DOI Zenodo, phiên bản LLM và prompt; bài tiếng Anh 25–40 trang; khai báo dùng AI | chưa |
| 9 | Khóa luận | Báo cáo dự án làm nền, cộng chương cho đầu mục 2, 3, 6; bảo vệ | dàn ý: `thesis-outline.md` |

**Thứ tự.** Làm ngay và song song: 1 (viết) và 5 (tìm người, chậm nhất, không phụ thuộc mã). Phần kỹ thuật chính: 2 rồi 3;
Level 2 trước vì là đường ngắn nhất tới một phát hiện thật (ví dụ Luật 44 với nghị định hướng dẫn). Sau đó 4 → 6 → 7 → 8.
Khóa luận (9) cần 2, 3, một phần 6 và dữ liệu mở rộng vừa phải; bài Q1 cần đủ 5, 6, 7.

```
1 Định vị ──► quyết định 2 và 3 làm đến đâu
5 Tìm người gán nhãn ── bắt đầu ngay
2 Level 2 ─┐
3 Lõi      ├─► 4 Dữ liệu ─► 6 Đánh giá ─► 7 Phát hiện ─► 8 Bài báo
           └────────────────────────────────────────────► 9 Khóa luận
```

**Quyết định đang chờ người phụ trách dự án:**

- **Q1.** Mở Level 2: `CLAUDE.md` hiện ghi «không làm Level 2». Khi đồng ý: sửa `CLAUDE.md` và viết một ADR mới.
- **Q2.** Có ≥ 2 người có chuyên môn luật gán nhãn độc lập (ngoài Phong) không? Có ai đứng đồng tác giả không?
- **Q3.** Kinh phí gọi API cho dịch theo lô, hay tiếp tục dán tay?
- **Q4.** Hạn nộp khóa luận.
- **Q5.** Văn bản thứ hai, thứ ba: nghị định hướng dẫn Luật 44 (cho Level 2), một luật khác lĩnh vực có nhiều quyền (cho Level 1 có nội dung), hay cả hai.

## Tạm gác (không chặn lộ trình)

- **Nghị quyết 66.18/2026/NQ-CP và ca C24**: Level 2. Chỉ ghi giới hạn vào báo cáo. Câu hỏi Q8–Q10 đang chờ người đối chiếu (`docs/review/huong-dan-doi-chieu.md`).
- **G4** (ngoại lệ «trừ…» có tạo quyền không): Phong cho là có; chờ ý kiến người thứ hai trước khi đổi bản mã hóa.
- **Tệp của Phong**: C37 mâu thuẫn với Q4; ô «Đúng ý / Sai ý» ghi nhầm ở C26, C28, C30, C35; 15 ca «được phép» so với «không điều chỉnh». Chờ Phong trả lời.
