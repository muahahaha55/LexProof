# ADR-0024: Bước dịch điều khoản dán tay, đầu ra là JSON kiểm tra được, không phải mã Lean

- **Status**: **Accepted** cho bước dịch nháp
- **Trạng thái cài đặt**: **Tested** (Python, không tin cậy): `pipeline/translate.py`, `pipeline/tests/test_translate.py`, `eval/translate/article19.gold.json`. Chưa chạy với một câu trả lời LLM thật.
- **Ngày**: 2026-11-14
- **Liên quan**: [ADR-0011](0011-trust-boundary-human-approval.md), FR3, FR4

## Bối cảnh

FR3 cần một bước dịch điều khoản thành dữ liệu `Norm`. Gọi API cần thêm phụ thuộc, khóa và chi phí; người phụ trách chọn chưa làm việc đó (2026-11-14).

## Quyết định

1. `translate.py prompt --article N` in câu lệnh (chữ của điều từ `data/segmented`, lược đồ, quy tắc). Người dùng dán vào LLM và lưu câu trả lời thành JSON.
2. LLM chỉ trả **dữ liệu** (atom, norm, `not_encoded`, `assumptions`), không trả mã Lean. Các tham chiếu điều khoản là chuỗi theo văn phạm của `Core/ClauseRef.lean`.
3. `translate.py check` từ chối (thoát mã 1) khi: tham chiếu không phân tích được hoặc đơn vị không tồn tại; `quote` không nằm nguyên văn trong đơn vị nguồn; atom hoặc nhãn không tồn tại; norm thuộc điều khác; **có khoản không được norm hay `not_encoded` nhắc tới**; `not_encoded` thiếu lý do. Đây là fail closed ở mức cấu trúc.
4. `translate.py lean` chỉ chạy sau khi `check` sạch và ghi bản nháp Lean **ngoài** thư viện (`eval/translate/...`), có dòng «DRAFT, NOT HUMAN-REVIEWED» và các `assumptions` trong phần đầu. Đưa vào `LexProof/Laws/` là quyết định của người, sau khi duyệt.
5. Kiểm tra cuối cùng là `pfindings` và `analyzeReport` của Lean trên bản nháp, không phải script Python.
6. `translate.py compare` so từng norm với một bản dịch tay (nhận diện atom theo nguồn và nhãn, không theo tên) để đo độ lệch. Khác tên act cũng được báo.

## Hệ quả

- `check` sạch **không** nói bản dịch đúng luật. Nó chỉ bắt lỗi máy dễ bắt (bịa trích dẫn, bỏ khoản).
- Bản `article19.gold.json` do cùng người viết bản mã hóa tay chép lại từ `AlcoholSale.lean`; nó chứng tỏ đường ống chạy, không đo chất lượng LLM. Phép đo thật cần một câu trả lời LLM do người dán.
- Bước tự động gọi API và vòng sửa lỗi FR4 chưa làm.
