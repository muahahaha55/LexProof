# LexProof

LexProof kiểm **tính nhất quán logic trong một văn bản luật tiếng Việt** (Level 1) bằng Lean 4. Văn bản thử nghiệm:
Luật Phòng, chống tác hại của rượu, bia số 44/2019/QH14 (36 điều).

> **Không phải tư vấn pháp lý.** Kết quả là công cụ hỗ trợ người đọc luật. Hệ thống không nói hành vi nào hợp pháp hay
> trái luật, và không bao giờ kết luận cả văn bản «đúng».

## Bài toán

Đầu vào là văn bản luật. Đường đi: tách điều khoản → AI dịch từng điều thành dữ liệu (norm: cấm / bắt buộc / được phép,
điều kiện, ngoại lệ, nguồn) → **người duyệt** từng dòng → kernel Lean kiểm → báo cáo tiếng Việt.

Kết quả có ba giá trị: **tìm thấy xung đột** / **nhất quán trên phần đã mã hóa** / **không biết**. Mỗi kết quả kèm phạm
vi đã mã hóa, trạng thái duyệt, và điều **không** được chứng minh. Hai loại đúng được tách bạch:

- **Đúng hình thức (soundness):** kernel Lean chấp nhận chứng minh; không `sorry`, chỉ ba axiom chuẩn (audit chạy mỗi lần build).
- **Trung thực với luật (faithfulness):** bản mã hóa khớp chữ luật. Chỉ kiểm được bằng người duyệt và ca kiểm của chuyên gia.

Khái niệm mở («dành cho», «hợp lý», …) là tham số: hệ thống không tự quyết giá trị.

## Kết quả hiện tại (Luật 44/2019/QH14)

| | |
|---|---|
| Phạm vi | 15 điều mã hóa và được một người duyệt (73 norm); 21 điều ngoài phạm vi mã hóa, người duyệt đồng ý; 36/36 điều có trạng thái |
| Nhất quán (kernel) | `consistent` trên cả 73 norm. **Rỗng về thông tin**: không hành vi nào mang hai tính chất trái nhau |
| Xung đột qua quan hệ giữa hành vi | 1 ứng viên: Điều 32 khoản 4 (bắt buộc thu hồi) × Điều 5 khoản 12 (cấm tàng trữ, vận chuyển rượu, bia không bảo đảm chất lượng). Dựa trên 2 cạnh «thu hồi ⇒ vận chuyển / tàng trữ» **chưa duyệt**; mất đi dưới hai cách đọc khác |
| Dấu hiệu lỗi soạn thảo (kernel) | 73/73 norm sống, 322 cặp không bao trùm, 5/6 ngoại lệ có kích hoạt; 1 «không biết»: ngoại lệ của norm 15.2 |
| Gieo lỗi | Bộ kiểm bắt 23/23 xung đột gieo cùng hành vi, 0/23 báo nhầm (`eval/entailment/`) |

Báo cáo chính: [`reports/law44-2026-11-25.md`](reports/law44-2026-11-25.md). Giới hạn: một người duyệt; chưa có bộ ca của
người học luật (FR12); Level 2 (nhiều văn bản, thứ bậc hiệu lực) chưa làm.

## Cài đặt

- **Lean 4** qua [elan](https://github.com/leanprover/elan); phiên bản được ghim trong `lean-toolchain` (`v4.35.0`). Không dùng Mathlib.
- **Python 3.12**, chỉ thư viện chuẩn. Test dùng `pytest` (`pipeline/requirements-dev.txt`) hoặc `unittest`.
- Windows (PowerShell) là môi trường phát triển; lệnh dưới đây chạy được trong PowerShell hoặc Git Bash.

## Chạy

```
lake build                              # kernel kiểm mọi định lý, audit axiom, audit đóng gói (~5–6 phút lần đầu)
python pipeline/demo.py                 # một lệnh: build, báo cáo, gieo xung đột, cạnh, cách đọc, lỗi soạn thảo
python pipeline/demo.py --no-build      # như trên, dùng bản đã build
python pipeline/report.py --module law44 --status draft     # sinh báo cáo vào reports/
python -m unittest discover -s pipeline/tests               # test Python
```

`demo.py` chỉ ghi vào `eval/demo/` (không vào `reports/`, `LexProof/` hay `data/`).

## Bố cục

| Thư mục | Nội dung |
|---|---|
| `LexProof/Core` | Norm, tính chất, điều kiện, ngoại lệ, ưu tiên, nguồn, bảng atom, tham chiếu điều khoản |
| `LexProof/Verify` | Kiểm xung đột (`analyzeP`), cạnh kéo theo (`Entail`), lỗi soạn thảo (`Drafting`), báo cáo, test |
| `LexProof/Laws` | Một module mỗi điều đã duyệt, module gộp `Law44`, `Law44Drafting` |
| `LexProof/Cert` | Audit axiom và audit đóng gói, chạy lúc build |
| `pipeline/` | Công cụ Python (không tin cậy): tách văn bản, dịch dán tay, bảng thuật ngữ, phiếu duyệt, promote, cạnh, cách đọc, báo cáo |
| `data/` | Văn bản gốc (Công báo), bản tách, bảng thuật ngữ, cạnh, cách đọc |
| `docs/` | Yêu cầu, kiến trúc, thiết kế, truy vết, ADR, lộ trình |
| `docs/review/` | Phiếu duyệt đã điền |
| `eval/` | Bản dịch, thử nghiệm và số đo |
| `reports/` | Báo cáo, chỉ do `pipeline/report.py` tạo |

Đọc trước: [`docs/traceability.md`](docs/traceability.md) (cái gì được chứng minh, cái gì được tin) và
[`docs/roadmap.md`](docs/roadmap.md) (tiến độ).

## Nguồn dữ liệu và điều kiện dùng

- Văn bản luật lấy từ **Công báo** (Văn phòng Chính phủ), số 559 + 560 ngày 17-7-2019; tệp gốc, URL và sha256 trong
  [`data/README.md`](data/README.md). Văn bản quy phạm pháp luật không thuộc đối tượng bảo hộ quyền tác giả (Luật Sở hữu trí
  tuệ, Điều 15).
- `data/` chỉ chứa văn bản công khai.
- Bản dịch thành norm do AI soạn và được một người duyệt; không dùng làm căn cứ pháp lý.
