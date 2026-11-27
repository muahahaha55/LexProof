# Dàn ý khóa luận

Cập nhật: 2026-11-27. Tài liệu làm việc: dàn ý khóa luận tốt nghiệp. Khóa luận dùng **báo cáo dự án**
([docs/report/bao-cao-du-an.pdf](report/bao-cao-du-an.pdf), kết quả Level 1) làm nền, cộng các chương mới của giai đoạn 2
([roadmap.md](roadmap.md), mục «Giai đoạn 2»; [research-plan.md](research-plan.md)). Mỗi chương chỉ tới nguồn trong repo.
Số liệu trích vào khóa luận phải lấy từ bản kết quả kiểm tra do `pipeline/report.py` sinh hoặc từ `eval/`, kèm commit.

Hạn nộp: chưa chốt (roadmap, Q4). Phạm vi chương 5 và 6 phụ thuộc quyết định mở Level 2 (roadmap, Q1).

## Khóa luận

| Chương | Nội dung | Nguồn đã có | Phải làm thêm |
|---|---|---|---|
| 1. Mở đầu | Bối cảnh; đề bài và sản phẩm; hai loại «đúng»; câu hỏi nghiên cứu; đóng góp | Báo cáo dự án mục 1; `research-plan.md` mục 1, 3 | Viết lại theo RQ1–RQ4 |
| 2. Cơ sở lý thuyết và công trình liên quan | Logic chuẩn tắc; xung đột (Kelsen, Vranes); thứ bậc hiệu lực và nguyên tắc ưu tiên; Lean 4; LLM dịch luật; bảng so sánh | Báo cáo dự án mục 2; `related-work.md` | Thêm phần thứ bậc văn bản (Level 2); cập nhật so sánh với L4L, LexGuard |
| 3. Vai trò của Lean 4 và kiến trúc | Vì sao Lean; sáu vai trò; cơ sở tin cậy; HLD, LLD | Báo cáo dự án mục 3, 4; `architecture.md`; `design-core.md` | Cập nhật HLD, LLD khi có Level 2 |
| 4. Lõi kiểm trong một văn bản (Level 1) | Norm, `Conflict`, kiểm theo cặp, định lý W1–W4, cạnh kéo theo, lỗi soạn thảo, phản ví dụ | Báo cáo dự án mục 5; `design-core.md` mục 2–21 | Rút gọn từ báo cáo |
| 5. Mở rộng lõi hình thức | (a) ràng buộc giữa atom; (b) cách đọc là tham số, kết luận ∀/∃; (c) ngữ nghĩa cạnh kéo theo | `related-work.md` Ý tưởng 1; ADR-0029 | **Mới**: thiết kế, định lý, ADR |
| 6. Kiểm giữa nhiều văn bản (Level 2) | Thứ bậc hiệu lực, ngày hiệu lực, dẫn chiếu chéo; định lý liên kết mở rộng | (chưa có) | **Mới**: toàn bộ; cần quyết định Q1 |
| 7. Dữ liệu và quy trình duyệt | Văn bản đã đưa vào; bảng thuật ngữ; phiếu duyệt; người gán nhãn và kappa | Báo cáo dự án mục 4.4, 6.1; `coverage.md`; `docs/review/` | Văn bản mới; ground truth độc lập |
| 8. Đánh giá | RQ1–RQ4: xung đột được xác nhận; phụ thuộc cách đọc; so với baseline; độ trung thực và chi phí duyệt | Báo cáo dự án mục 6; `eval/entailment/`, `eval/mutation/` | **Mới**: baseline, nhãn chuyên gia, số đo |
| 9. Vấn đề gặp phải và cách giải quyết | Bảng vấn đề, cách giải quyết, kết quả | Báo cáo dự án mục 7 (Bảng 14) | Bổ sung vấn đề của giai đoạn 2 |
| 10. Giới hạn và đe dọa tính hợp lệ | Viết thẳng, không giảm nhẹ | Báo cáo dự án mục 8; `traceability.md` | Cập nhật theo kết quả mới |
| 11. Kết luận và hướng phát triển | Tóm tắt; bài tạp chí | Báo cáo dự án mục 9; `publication-q1.md` | |
| Phụ lục | Hướng dẫn chạy; danh sách định lý; phiếu duyệt mẫu; gói tái lập | `README.md`, `pipeline/demo.py` | DOI Zenodo khi công bố |

## Quan hệ với bài tạp chí

Khóa luận và bài P1 (*Artificial Intelligence and Law*) dùng chung chương 5, 6, 8. Khóa luận bằng tiếng Việt, đủ chi tiết; bài báo bằng
tiếng Anh, 25–40 trang, tập trung vào RQ và đánh giá. Khóa luận không cần chờ bài báo: nó cần chương 5, 6, một phần chương 8, và dữ liệu
mở rộng vừa phải; bài Q1 cần thêm ground truth độc lập (đầu mục 5) và một phát hiện có ý nghĩa (đầu mục 7).

## Slide bảo vệ

Dựng lại từ slide báo cáo dự án (đã có, 33 slide, cùng cách đánh số với báo cáo; bộ slide là một Artifact trên claude.ai:
https://claude.ai/artifact/Qdjqgoqd3y3KQo4apv6Pm9), thêm phần chương 5, 6, 8. Giữ hình HLD, LLD dùng chung với văn bản
(`docs/report/fig-*.tex`).
