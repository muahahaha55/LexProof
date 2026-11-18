# ADR-0025: Một lệnh cho đường nháp: gộp các bản dịch đã kiểm, chạy Lean, báo cáo nháp ngoài `reports/`

- **Status**: **Accepted** cho đường nháp (bước 1 của `docs/roadmap.md`)
- **Trạng thái cài đặt**: **Tested** (Python, không tin cậy): `pipeline/run.py`, `pipeline/tests/test_run.py`
- **Ngày**: 2026-11-18
- **Liên quan**: [ADR-0023](0023-report-command.md), [ADR-0024](0024-translation-manual-paste.md), FR3, FR10

## Bối cảnh

Các mảnh (văn bản đã tách, bản dịch JSON, kiểm tra cấu trúc, bản nháp Lean, `analyzeReport`) chạy rời nhau; kiểm tra nhất quán *trong một văn bản* cần các điều được kiểm **cùng nhau**, không từng điều một.

## Quyết định

1. `pipeline/run.py FILE.json ...` nhận các bản dịch của **một** văn bản (mỗi tệp một điều) và dừng nếu văn bản đã tách không còn khớp tệp trích.
2. Mỗi tệp qua `translate.check`; tệp có phát hiện, đọc không được, sai lược đồ, trùng điều, hoặc khác `doc_type`/`effective` thì **bị từ chối và được liệt kê**, không gộp.
3. Các tệp được nhận gộp thành một bản nháp Lean; tên atom và id norm được gắn tên điều («Điều 5 · ...»). Hai điều không bao giờ dùng chung atom do trùng tên ngẫu nhiên; đổi lại, khái niệm thật sự dùng chung bị tách đôi (cần bảng thuật ngữ FR2).
4. Kết quả ba giá trị lấy từ đầu ra Lean (`pfindings`, dòng `KẾT QUẢ:`); mọi trường hợp không đọc được, Lean lỗi hoặc có finding đều là «không biết». Kết quả là **Evaluated**, không có định lý kernel cho bản nháp.
5. Báo cáo ghi vào `eval/run/` (không vào `reports/`, vốn chỉ dành cho `report.py`), luôn có: biểu ngữ BẢN NHÁP, phạm vi theo điều (đã dịch / bị từ chối / chưa dịch), `not_encoded`, các giả định của bản dịch, đầu ra Lean, mục «KHÔNG nói gì», và ghi chú rằng văn bản khác (Level 2) không được xét.

## Hệ quả

- Có một đường chạy từ bản dịch tới báo cáo; bước dán tay vẫn là của người.
- Chưa có đường từ bản nháp đã duyệt sang `LexProof/Laws/` (bước 2).
- Nếu muốn kết quả kernel cho bản nháp, cần sinh định lý `decide +kernel` như `AlcoholSale.consistent`; chưa làm vì kích thước bản nháp có thể làm kernel chậm.
