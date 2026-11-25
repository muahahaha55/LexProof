# Thử nghiệm E1–E9: xung đột qua quan hệ giữa các hành vi (2026-11-25)

Bằng chứng cho [ADR-0029](../../docs/decisions/0029-act-entailment-edges.md). Mọi số liệu dưới đây đo trên 14 bản dịch
đã được người duyệt chấp nhận (Điều 5, 10, 12–14, 16–21, 32–34), gộp bằng `pipeline/run.py` (69 norm). Module `Law44`
thêm Điều 15 (bản dịch không theo bảng thuật ngữ), thành 73 norm.

**Tất cả cạnh, cách đọc và nhãn «nên bắt» ở đây do AI (Claude) đề xuất; chưa ai duyệt.** Kết quả nói về cách đọc, không
nói về luật. Các script được giữ nguyên như lúc chạy (Python, không tin cậy); kết quả Lean là Evaluated (chạy mã) trừ
chỗ ghi «kernel».

| Script | Thử nghiệm |
|---|---|
| `exp_e2_e7.py E2` / `E3` / `E3b` / `E4` / `E5` / `E7` | gieo lỗi, cạnh bao hàm, cạnh kéo theo, duyệt theo nhu cầu, gieo lỗi có cạnh, nhiều cách đọc |
| `exp_e6_e8.py` | norm chết, norm thừa, ngoại lệ không kích hoạt |
| `exp_e9.py FILE...` | bộ dò cụm điều kiện không được phủ (thay thế tất định cho dịch vòng) |

Chạy từ thư mục gốc repo: `python eval/entailment/exp_e2_e7.py E4`. Đầu ra Lean ghi vào `eval/entailment/out/` (bỏ qua bởi git).

## Kết quả

| Mã | Câu hỏi | Kết quả | Mức tin |
|---|---|---|---|
| E1 | Kernel chứng minh được bản gộp không? | `silent` và `consistent` trên 69 norm, 78 atom: qua, 195 giây. Module `Law44` (73 norm, thêm `covers_articles*`): build khoảng 330 giây | cao (kernel) |
| E2 | Bộ kiểm có bắt xung đột gieo vào luật thật? | Đổi modality cùng act: 23/23. Điều kiện phủ định (không thể cùng xảy ra): 0/23 báo nhầm. Đổi sang act gần nghĩa: 0/12 bị bắt | cao |
| E3a | Cạnh bao hàm (8 cạnh) có tạo xung đột? | 0. Cả 69 norm chỉ có 1 quyền (Điều 32 khoản 5 nhánh (ii)); bao hàm chỉ sinh thêm lệnh cấm | cao |
| E3b | Cạnh «thu hồi ⇒ vận chuyển / tàng trữ»? | XUNG ĐỘT: Điều 32 khoản 4 (bắt buộc thu hồi) × Điều 5 khoản 12 (cấm tàng trữ, vận chuyển rượu, bia không bảo đảm chất lượng) | cao về Lean; cạnh chưa duyệt |
| E4 | Duyệt theo nhu cầu: bao nhiêu cạnh phải duyệt? | 14 cạnh (13 của AI, 1 cạnh cố ý sai). Cạnh trên đường xung đột: 6; không tính đối chứng: 2/13. Cạnh sai tự lộ với 16 cặp xung đột vô lý | trung bình |
| E5 | Có cạnh thì bắt được ca khác act? | Ca M2 là xung đột theo định nghĩa: 0/3 khi không cạnh, 3/3 khi có cạnh. Ca M2 không phải xung đột: 0/9. M4: 0/23 | Lean đúng ngữ nghĩa cạnh; nhãn «nên bắt» tính từ chính các cạnh, mẫu dương 3 ca |
| E6 | Norm chết, norm thừa? | 0 và 0 (bộ đo tự kiểm: bản sao có điều kiện chặt hơn bị bắt đúng) | trung bình (Python, bỏ qua `Atoms.valid`) |
| E7 | Ứng viên E3b có bền theo cách đọc? | R0 (theo chữ): XUNG ĐỘT. R1 (cấm chỉ nhắm việc kinh doanh): nhất quán. R2 (ngoại lệ ngầm cho thu hồi): nhất quán. Nay chạy bằng `pipeline/readings.py` | cao về Lean; cách đọc chưa duyệt |
| E8 | Ngoại lệ không bao giờ kích hoạt? | 5 ngoại lệ ở 4 norm: đều có lúc kích hoạt, không cái nào nuốt hết norm | trung bình (Python) |
| E9 | Bộ dò cụm điều kiện có bắt lỗi người duyệt đã bác? | 0 cờ trên 14 bản dịch đã duyệt; đúng 1 cờ trên bản Điều 32 lần 1 (norm 32.6.i thiếu «sau khi uống rượu», chính là A:9 Phong bác) | **thấp**: luật của bộ dò được chỉnh 3 lần khi nhìn chính các ví dụ này; chỉ 1 lỗi đã biết |

## Đính chính

Lần đầu báo E2, AI viết «12/12 ca act gần nghĩa bị lọt: điểm mù». Đo lại theo định nghĩa chuẩn (tuân thủ norm này kéo
theo vi phạm norm kia) thì chỉ 3 trong 12 ca là xung đột thật; 9 ca chỉ đổi sang act khác. Lần đầu chạy E5, bộ đếm so khớp
id theo chuỗi con nên đếm sai; đã sửa trước khi ghi số ở trên.

## Việc phải làm để các số này thành bằng chứng

- Người duyệt quyết hai cạnh E9, E10 (`docs/review/duyet-canh-keo-theo-44-2019-QH14.md`).
- Người học luật chọn R0, R1 hay R2 cho ứng viên Điều 32 khoản 4 × Điều 5 khoản 12.
- E5: nhãn «nên bắt» do người gán trước, độc lập với cạnh, và nhiều ca dương hơn.
- E9: đo tiền đăng ký trên lần duyệt tới (chạy bộ dò trước, ghi dự đoán, rồi so với dòng bị bác).
