# eval/sale-group — kiểm tra và phiếu duyệt cho `LexProof/Laws/AlcoholSale.lean` (BẢN NHÁP, CHƯA AI DUYỆT)

File thử bỏ đi, ngoài thư viện `lake`. Chạy từ gốc repo (cần `lake build` xong).

| File | Việc |
|---|---|
| `common.py` | đọc `data/extracted/44-2019-QH14.txt`, cắt khoản theo số dòng (bỏ dòng đầu trang) |
| `check_sources.py` | danh mục Điều 1..36 khớp file; các khoản; các cụm từ dùng cho nhãn dải có trong luật |
| `boundaries.py` | các dải ngưỡng có khớp nhau chính xác không (bộ kiểm Lean **không** phát hiện hở/chồng); ghi `boundaries_output.txt` |
| `Print.lean` | in bằng `Core/Render.lean` đúng cái bộ kiểm thấy + kết quả `analyzeP`; `lake env lean --run eval/sale-group/Print.lean > eval/sale-group/print_output.txt` |
| `build_sheet.py` | sinh `docs/review/sale-group-review.md` từ `print_output.txt` và file trích xuất |
| `check_sheet.py` | đối chiếu cột «Nguyên văn» của phiếu với file trích xuất |
| `AlcoholSale_prof.lean` | bản sao có `set_option profiler true` để tách thời gian kernel |
