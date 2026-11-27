# Kế hoạch nghiên cứu: định vị, câu hỏi nghiên cứu, thiết kế đánh giá

Cập nhật: 2026-11-27. Tài liệu lập kế hoạch cho giai đoạn 2 (bài tạp chí và khóa luận), **không** phải quyết định
(không phải ADR), không đổi phạm vi kỹ thuật. Đầu mục và thứ tự công việc: [roadmap.md](roadmap.md), mục «Giai đoạn 2».
Chuẩn tạp chí và khoảng cách: [publication-q1.md](publication-q1.md). Công trình liên quan: [related-work.md](related-work.md).

## 1. Tuyên bố đóng góp (bản nháp)

> LexProof phát hiện xung đột chuẩn tắc trong văn bản luật thật bằng một quy trình mà **mọi kết luận là định lý được kernel
> Lean kiểm**, **mọi dữ liệu đi vào phần tin cậy đều qua người duyệt có truy vết**, và **các cách đọc luật khác nhau là đối
> tượng được duyệt**, nên một xung đột được báo kèm việc nó đứng vững dưới mọi cách đọc đã liệt kê hay chỉ dưới một số cách.
> Trên văn bản tiếng Việt, hệ thống [tìm ra / không tìm ra] các xung đột được chuyên gia xác nhận, với chi phí duyệt đo được.

Phần trong ngoặc vuông chỉ điền được sau đầu mục 5 và 7 của roadmap.

## 2. Khoảng trống

Theo [related-work.md](related-work.md), mục 3:

- «Kernel-checked» một mình **không** đủ mới: SpecGuard (2026) và LegalLean đã dùng Lean 4.
- Các hệ tìm mâu thuẫn trong luật (Yadamsuren 2025, N-Check 2024, L4L 2025, LexGuard 2026) dựa vào bộ giải hoặc Prolog phải tin,
  không có cổng duyệt người trước phần tin cậy, không có kết quả ba giá trị.
- Vernie & Grabmair (2026) và Yadamsuren (2025) cho thấy **cách đọc** quyết định có mâu thuẫn hay không, nhưng chưa ai đưa cách đọc
  thành đối tượng được duyệt và lượng hóa kết luận theo nó với chứng minh kernel.
- Chưa có công trình nào trên luật tiếng Việt.

Cái mới phải nằm ở: **độ trung thực có bằng chứng**, **xung đột lượng hóa theo cách đọc**, **xung đột giữa nhiều văn bản**
(Level 2), trên văn bản thật, với chi phí duyệt đo được.

## 3. Câu hỏi nghiên cứu (bản nháp)

| RQ | Câu hỏi | Cần đầu mục | Số đo |
|---|---|---|---|
| RQ1 | Trên N văn bản tiếng Việt (gồm cặp luật – nghị định), hệ thống báo bao nhiêu ứng viên xung đột, và bao nhiêu được chuyên gia xác nhận là có thật? | 2, 4, 5, 7 | số ứng viên, số được xác nhận, precision theo nhãn chuyên gia |
| RQ2 | Bao nhiêu xung đột phụ thuộc cách đọc: đứng vững dưới mọi cách đọc đã liệt kê, so với chỉ dưới một số cách? | 3(b), 5 | tỉ lệ ∀ / ∃; số câu hỏi phân biệt cần để chốt cách đọc |
| RQ3 | So với LLM hỏi thẳng, LLM có bước tự kiểm, và LLM + SMT kiểu L4L, LexProof khác thế nào về độ chính xác và về tính kiểm chứng được? | 6 | precision/recall trên xung đột gieo vào và xung đột thật; tỉ lệ kết luận có chứng minh |
| RQ4 | Độ trung thực và chi phí duyệt: quy trình duyệt bắt được bao nhiêu lỗi dịch gieo vào, tốn bao nhiêu thời gian cho mỗi khoản? | 5, 6 | số đột biến bị bắt; phút mỗi khoản; kappa giữa người gán nhãn |

## 4. Thiết kế đánh giá (bản nháp)

- **Dữ liệu.** Giữ Luật 44/2019/QH14. Thêm: (a) nghị định hướng dẫn Luật 44, cho Level 2; (b) ít nhất một luật khác lĩnh vực có nhiều
  quyền, để kết luận Level 1 có nội dung. Mục tiêu ≥ 300 khoản qua pipeline, ≥ 100 khoản duyệt đầy đủ (theo publication-q1.md, mục 6).
- **Ground truth.** ≥ 2 người có chuyên môn luật, gán nhãn độc lập, không xem bản nháp AI; khoảng 20–30% khoản gán đôi để tính kappa,
  một người có chuyên môn cao hơn phân xử bất đồng. Có văn bản đồng ý tham gia; hỏi trường về đạo đức nghiên cứu.
- **Xung đột gieo vào.** Dùng lại các toán tử đột biến đã có (`eval/mutation/`, thử nghiệm E2, E5). Nhãn «nên bắt» phải do người gán
  trước, độc lập với cạnh kéo theo (giới hạn đã ghi ở `eval/entailment/README.md`).
- **Baseline.** Cùng văn bản, cùng câu hỏi, ghi rõ mô hình, phiên bản, prompt, ngày chạy.
- **Ngưỡng của bài.** Phát hiện được chuyên gia xác nhận; nếu không có, viết thành kết quả âm có lập luận (ví dụ: luật này gần như chỉ
  có cấm và bắt buộc nên xung đột cùng hành vi hiếm, và đo điều đó).

## 5. Những gì đã có, dùng lại được

- Lõi Lean với định lý liên kết W1–W4, cạnh kéo theo (`derive_sound`), lỗi soạn thảo bằng chứng nhân, phản ví dụ bằng lời.
- Quy trình duyệt ghim sha256, bảng thuật ngữ dùng chung, quy tắc dùng tiếp phiếu khi bảng chỉ thêm mục.
- `pipeline/readings.py`: nhiều cách đọc đã chạy được (R0, R1, R2 cho Điều 32 × Điều 5), nhưng **chưa** có định lý ∀/∃ theo cách đọc.
- Thử nghiệm E1–E9 (`eval/entailment/`), 410 đột biến (`eval/mutation/`), báo cáo dự án (`docs/report/`).

## 6. Rủi ro

| Rủi ro | Hệ quả | Giảm thiểu |
|---|---|---|
| Không tìm được người gán nhãn có chuyên môn luật | Không có ground truth, bài Q1 không đứng được | Bắt đầu tìm ngay; gán đôi một phần thay vì toàn bộ; mời đồng tác giả luật |
| Level 2 không tìm ra xung đột thật | Mất phát hiện chính | Chọn cặp văn bản có tranh cãi đã biết; chuẩn bị kết quả âm có lập luận |
| Bùng nổ tổ hợp khi nhiều khoản cùng mơ hồ | Kernel quá chậm | Giới hạn số cách đọc; vượt ngưỡng thì «không biết» |
| Các cách đọc do một LLM đề xuất có lỗi tương quan | RQ2 thiên lệch | Lấy cách đọc từ hai nguồn (hai mô hình, hoặc người) |
| Dịch dán tay quá chậm cho 300 khoản | Trễ hạn | Quyết kinh phí API (roadmap, Q3) |

## 7. Quyết định đang chờ

Xem [roadmap.md](roadmap.md), mục «Giai đoạn 2», câu Q1–Q5.
