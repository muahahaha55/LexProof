# Dàn ý quyển đồ án và slide bảo vệ

Tài liệu làm việc: dàn ý để viết quyển, mỗi chương chỉ tới nguồn đã có trong repo. Không lặp nội dung các tài liệu đó.
Số liệu trích vào quyển phải lấy từ báo cáo do `pipeline/report.py` tạo hoặc từ `eval/`, kèm commit.

## Quyển

| Chương | Nội dung | Nguồn trong repo | Còn phải viết |
|---|---|---|---|
| 1. Mở đầu | Vấn đề mâu thuẫn trong văn bản luật; vì sao cần kiểm hình thức; mục tiêu và phạm vi (Level 1); đóng góp | `CLAUDE.md` (Scope), `docs/roadmap.md` (Mục tiêu) | viết văn xuôi; nêu 4 đóng góp: lõi có chứng minh, quy trình duyệt có ghim sha256, cạnh kéo theo, kiểm lỗi soạn thảo bằng chứng nhân |
| 2. Cơ sở lý thuyết và công trình liên quan | Logic chuẩn tắc, định nghĩa xung đột (Kelsen, Vranes); hình thức hóa luật (Catala, L4L, Prolog cho luật thuế); Lean và chứng minh bằng kernel; LLM dịch sang dạng hình thức | `docs/related-work.md` | chọn 10–15 công trình; bảng so sánh |
| 3. Yêu cầu | FR/NFR, ưu tiên, tiêu chí chấp nhận; ADR-0031 (thu gọn cho đồ án) | `docs/requirements.md`, ADR-0031 | rút gọn thành bảng |
| 4. Kiến trúc | 4 tầng, ranh giới tin cậy, hai vòng phản hồi | `docs/architecture.md` | hình C4 |
| 5. Thiết kế lõi Lean | Norm, Cond, bảng atom; `analyzeP` và phép chiếu theo cặp; các định lý liên kết; cạnh kéo theo (`derive_sound`, `conflict_derived_meaning`); lỗi soạn thảo bằng chứng nhân; phản ví dụ bằng lời; trust base | `docs/design-core.md` (mục 2–21), `docs/traceability.md` (mục 3) | chọn định lý chính, giải thích bằng lời |
| 6. Quy trình đưa văn bản vào | Tách văn bản; bảng thuật ngữ dùng chung; dịch dán tay; phiếu duyệt ghim sha256; promote; module gộp | ADR-0024 đến ADR-0029, `docs/review/` | sơ đồ quy trình; số vòng duyệt và số dòng |
| 7. Thực nghiệm trên Luật 44/2019/QH14 | Phạm vi 15 + 21 điều; kết quả nhất quán và cảnh báo rỗng; gieo lỗi E2, E5; cạnh E4; cách đọc E7; lỗi soạn thảo và dấu hiệu 15.2; thời gian kernel | `reports/law44-*.md`, `eval/entailment/README.md`, ADR-0030 | bảng số liệu; thảo luận ứng viên Điều 32 × Điều 5 |
| 8. Giới hạn và đe dọa tính hợp lệ | Một người duyệt; chưa có FR12; kết luận chính rỗng; cạnh và cách đọc chưa duyệt; bộ dò E9 khớp quá mức; Level 2 | mục 7 của báo cáo `law44`, `docs/traceability.md`, `eval/entailment/README.md` (Đính chính) | viết thẳng, không giảm nhẹ |
| 9. Kết luận và hướng phát triển | Tóm tắt; bài báo (FR12, dịch vòng, văn bản thứ hai có nhiều quyền); Level 2 | `docs/publication-q1.md`, `docs/roadmap.md` | |
| Phụ lục | Hướng dẫn chạy (`README.md`, `pipeline/demo.py`); danh sách định lý; phiếu duyệt mẫu | | |

## Slide bảo vệ (khoảng 15 slide)

1. Bài toán và ví dụ một cặp norm trái nhau.
2. Vì sao cần kernel: tách soundness và faithfulness.
3. Kiến trúc và ranh giới tin cậy.
4. Norm, điều kiện, bảng atom (một norm thật của Điều 19).
5. Định lý chính: `consistent` ⇒ `no_conflict`; kết quả ba giá trị.
6. Quy trình duyệt: phiếu, sha256, số dòng đã duyệt.
7. Kết quả trên Luật 44: phạm vi, nhất quán, **cảnh báo rỗng**.
8. Gieo lỗi: hệ thống bắt được khi có xung đột.
9. Cạnh kéo theo và duyệt theo nhu cầu (2/13 cạnh).
10. Ứng viên Điều 32 khoản 4 × Điều 5 khoản 12, phản ví dụ bằng lời.
11. Cách đọc R0/R1/R2: ai quyết.
12. Lỗi soạn thảo: chứng nhân, dấu hiệu 15.2.
13. Giới hạn.
14. Hướng tiếp theo.
15. Demo trực tiếp: `python pipeline/demo.py --no-build`.
