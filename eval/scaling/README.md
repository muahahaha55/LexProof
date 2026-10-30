# eval/scaling — mô hình Python sau `docs/scaling-analysis.md`

Các file ở đây là bản sao **không sửa** của mô hình đã sinh ra các con số trong
`docs/scaling-analysis.md`. Chúng được lưu lại sau khi tài liệu đã viết; nội dung
đúng như lúc chạy (đã kiểm: `run_all.py` cho cùng đầu ra byte-for-byte với bản gốc).

## Cách chạy
Python 3 (chỉ dùng thư viện chuẩn), trong thư mục này:

    python run_all.py        # 8 biến thể G1 x G4 x G7: biểu đồ bit, so với thiết kế hiện tại
    python run_sens.py       # độ nhạy: IC, ngưỡng Bool
    python run_sens2.py      # độ nhạy bổ sung
    python gen_tables.py     # ghi tab_*.md (các bảng trong tài liệu) vào thư mục hiện tại

`scaling_model_v1.py`, `run_all_v1.py`, `cmp.py`: phiên bản đầu và script so sánh
hai phiên bản (kết quả giống nhau trên các ca đã thử). Không cần cho việc tái lập.

## Mô hình giả định gì
- **Bảng norm viết tay** cho Điều 5, 10, 12, 13, 19 của Luật 44/2019/QH14 theo
  `docs/slice1-notes.md` (mục B1, B2, C). Sai ở cách đọc một khoản sẽ đổi tập fact F.
- Miền: 32 fact tình huống (S01 enum 2, S02 enum 3, S07 enum 4, còn lại Bool) và 13
  tham số Bool; "bit" = log2 của tích kích thước miền các fact trong F của một cặp.
- Bốn ràng buộc toàn vẹn IC1–IC4 là của tôi; `ICX` ("một phương tiện quảng cáo") là
  **giả định**, không suy ra từ văn bản.
- 8 biến thể: G1 (a/b), G4 (ngoại lệ/cho phép), G7 (act mịn/thô). Các lựa chọn này
  **chưa được quyết định**; mô hình chỉ chạy cả hai phía.
- Kiểm tự nhất quán nội bộ (không đọc ngầm, không fact thừa), **không** kiểm tính
  đúng so với luật. Không chạy gì trong Lean; chi phí thực của `check` chưa đo.
