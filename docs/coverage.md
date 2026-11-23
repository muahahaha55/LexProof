# Sổ phủ sóng: Luật 44/2019/QH14 (36 điều)

Cập nhật: 2026-11-23 (sau khi áp phiếu của Phong cùng ngày). Tệp này do tay viết, **không** phải báo cáo của hệ thống (báo cáo chỉ do `pipeline/report.py` tạo). Nó trả lời một câu hỏi: mỗi điều của luật đang ở đâu trong đường ống, và vì sao.

Cách đọc: cột «ai quyết» cho biết ai đã chốt trạng thái. «Phong» là người duyệt; «AI, chưa duyệt» nghĩa là chỉ một bản đọc của AI, chưa ai đối chiếu. Một điều «không mã hóa» chưa duyệt **không** có nghĩa là điều đó không có chuẩn mực.

## Tóm tắt

| Trạng thái | Điều | Số điều |
|---|---|---|
| Đã vào `LexProof/Laws/` (Phong đã duyệt phiếu; kernel chứng minh `no_conflict`) | 5, 10, 12, 13, 14, 15, 19 | 7 |
| Đã dịch lại (Phong bác giả định A:9), có phiếu mới, chờ Phong | 32 | 1 |
| Đã dịch, đã qua `check`; chưa nhập thuật ngữ, chưa lập phiếu | 16, 17, 18, 20, 21, 33, 34 | 7 |
| Chưa mã hóa, AI đề xuất «không có chuẩn mực mã hóa được» (chưa duyệt) | 1, 2, 3, 4, 6, 7, 8, 9, 11, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 35, 36 | 21 |

Tổng 36. Chỉ 7/36 điều đã qua người duyệt; 8 điều đã dịch (AI) chờ duyệt; 21 điều chưa có bản mã hóa (AI đề xuất không mã hóa).

## Từng điều

| Điều | Nội dung | Trạng thái | Ai quyết | Ghi chú |
|---|---|---|---|---|
| 1 | Phạm vi điều chỉnh | không mã hóa | AI, chưa duyệt | không có nội dung chuẩn mực |
| 2 | Giải thích từ ngữ | không mã hóa | AI, chưa duyệt | định nghĩa; độ cồn dùng làm atom `do_con` ở các điều khác |
| 3 | Chính sách của Nhà nước | không mã hóa | AI, chưa duyệt | chính sách, không đặt nghĩa vụ lên hành vi cụ thể |
| 4 | Quyền và nghĩa vụ của cá nhân, tổ chức | không mã hóa | AI, chưa duyệt | khoản 4 «tuân thủ pháp luật» không có nội dung riêng; khoản 1–3 là quyền |
| 5 | Hành vi bị nghiêm cấm | **vào `Laws`** | Phong | 19 norm, đều là cấm |
| 6 | Mục đích, yêu cầu truyền thông | không mã hóa | AI, chưa duyệt | yêu cầu đối với hoạt động truyền thông của cơ quan |
| 7 | Nội dung truyền thông | không mã hóa | AI, chưa duyệt | danh mục nội dung |
| 8 | Hình thức truyền thông | không mã hóa | AI, chưa duyệt | danh mục hình thức |
| 9 | Trách nhiệm truyền thông | không mã hóa | AI, chưa duyệt | khoản 2 giao Chính phủ quy định (văn bản khác) |
| 10 | Địa điểm không uống rượu, bia | **vào `Laws`** | Phong | 6 norm cấm |
| 11 | Quản lý khuyến mại | không mã hóa | AI, chưa duyệt | chỉ dẫn chiếu sang pháp luật khác |
| 12 | Quảng cáo rượu, bia dưới 5,5 độ | **vào `Laws`** | Phong | dùng `do_con_nguong_5_5` cho cả rượu và bia (xem «Điểm cần người duyệt xem») |
| 13 | Quảng cáo rượu 5,5–dưới 15 độ, bia từ 5,5 độ | **vào `Laws`** | Phong | 2 norm cấm |
| 14 | Tài trợ | **vào `Laws`** | Phong | phần «tuân thủ pháp luật liên quan» không mã hóa |
| 15 | Quản lý kinh doanh rượu | **vào `Laws`** | Phong | 4 norm «được phép» trên 4 act riêng (bản dịch `article15.llm.json`, trước bảng thuật ngữ) |
| 16 | Điều kiện bán qua thương mại điện tử | dịch (`eval/translate/article16.glossary.llm.json`) | AI | 4 lệnh cấm bán khi thiếu điều kiện; 5 thuật ngữ mới chưa vào bảng |
| 17 | Rượu thủ công không kinh doanh | dịch | AI | xem «Điểm cần người duyệt xem» |
| 18 | Chất lượng, an toàn thực phẩm | dịch | AI | chữ «lưu hành» chưa mã hóa |
| 19 | Địa điểm không bán rượu, bia | **vào `Laws`** | Phong | chỉ có cấm |
| 20 | Rượu, bia giả, nhập lậu | dịch | AI | khoản 1 và 3 không mã hóa (việc của cơ quan nhà nước) |
| 21 | Phòng ngừa tai nạn giao thông | dịch | AI | khoản 3 và 4 không mã hóa (việc của cơ quan nhà nước) |
| 22 | Phòng ngừa, can thiệp, giảm tác hại về sức khỏe | không mã hóa | AI, chưa duyệt | biện pháp của cơ sở y tế theo hướng dẫn của Bộ |
| 23 | Tư vấn | không mã hóa | AI, chưa duyệt | |
| 24 | Phòng ngừa tại cộng đồng | không mã hóa | AI, chưa duyệt | «vận động», «tuyên truyền» |
| 25 | Chăm sóc, bảo vệ đối tượng yếu thế | không mã hóa | AI, chưa duyệt | |
| 26 | Kinh phí | không mã hóa | AI, chưa duyệt | |
| 27 | Đào tạo, bồi dưỡng | không mã hóa | AI, chưa duyệt | |
| 28 | Xử lý vi phạm | không mã hóa | AI, chưa duyệt | chế tài chung, không nêu hành vi |
| 29 | Nội dung quản lý nhà nước | không mã hóa | AI, chưa duyệt | |
| 30 | Trách nhiệm quản lý nhà nước | không mã hóa | AI, chưa duyệt | |
| 31 | Mặt trận, tổ chức xã hội | không mã hóa | AI, chưa duyệt | |
| 32 | Trách nhiệm của cơ sở kinh doanh | dịch lại, chờ Phong | AI + phiếu mới | Phong bác A:9 (cụm «sau khi uống rượu, bia» áp dụng cho cả hai nhánh khoản 6); bản `-2` đã sửa |
| 33 | Trách nhiệm của người đứng đầu cơ quan, tổ chức | dịch | AI | 6 nghĩa vụ; chủ thể không thành atom nên điều kiện phần lớn là true |
| 34 | Trách nhiệm của gia đình | dịch | AI | 3 nghĩa vụ; hai vế «hạn chế», «động viên» của khoản 1 không mã hóa |
| 35 | Sửa luật khác | không mã hóa | AI, chưa duyệt | sửa văn bản khác, ngoài Level 1 |
| 36 | Hiệu lực thi hành | không mã hóa | AI, chưa duyệt | ngày hiệu lực dùng làm trường `effective` |

## Quy ước phân loại «không mã hóa» (AI đề xuất, chưa duyệt)

1. Định nghĩa, chính sách, phạm vi, hiệu lực, kinh phí, tổ chức: không đặt nghĩa vụ hay cấm đoán lên hành vi của một chủ thể.
2. Nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu, đào tạo): không mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân. Đây là lựa chọn phạm vi, không phải nhận định rằng các nghĩa vụ đó không có hiệu lực.
3. Dẫn chiếu sang văn bản khác (Chính phủ quy định, pháp luật về…): không mã hóa nội dung; nêu trong `assumptions`.
4. Điều chỉ nêu mục tiêu hay «vận động»: không có chuẩn mực kiểm tra được.

Nếu quy ước 2 bị bác, các điều 9, 20 (khoản 1 và 3), 21 (khoản 3 và 4), 22, 23, 28–30 phải xem lại. Chúng không làm xuất hiện thêm xung đột phương thức nếu chỉ là nghĩa vụ, nhưng làm thay đổi phạm vi đã mã hóa.

## Điểm cần người duyệt xem

- **Điều 17 và Điều 15 khoản 3.** Điều 17 cấm `san_xuat_ruou_thu_cong` khi hộ gia đình, cá nhân không kinh doanh mà chưa kê khai. Điều 15 khoản 3 trong `Laws` dùng act riêng (`san_xuat_ruou_thu_cong_ban_cho_co_so_che_bien_lai`, được phép) nên hai điều không so được với nhau. Chạy thử Điều 15 (bản dịch theo bảng thuật ngữ, `article15.glossary.llm.json`, chưa vào `Laws`) cùng Điều 17: cả hai cùng dùng act `san_xuat_ruou_thu_cong` nhưng đều là cấm, nên kết quả vẫn nhất quán rỗng (không có cặp khắc nhau). Hai norm chồng lên nhau chỉ khi cách đọc Điều 15 khoản 3 đổi thành «được phép sản xuất».
- **Điều 12** dùng `do_con_nguong_5_5` (gloss chỉ ghi «rượu») cho cả rượu và bia. Điều 13 dùng `do_con_bia_nguong_5_5`. Phong đã chấp nhận cả hai trong bảng và chấp nhận cách đọc này ở phiếu Điều 12 (A:3) mà không ghi chú.
- **Điều 16, 17, 18**: nghĩa vụ «phải có/đáp ứng» được biểu diễn là lệnh cấm khi thiếu điều kiện; không biểu diễn là nghĩa vụ làm hành vi chính.

## Giới hạn và kết quả trung thực

Tất cả điều dưới đây là phát biểu về **phần đã mã hóa**, không phải về luật.

1. **Nhất quán rỗng.** Các module đã vào `Laws` cho `no_conflict`, nhưng cờ vacuity nêu rõ không có hành vi nào mang hai phương thức khác nhau. Điều 5 và 19 chỉ có cấm; Điều 15 chỉ có cho phép; chúng điều chỉnh hành vi khác nhau. Kết quả «nhất quán» do đó **không nói gì về điều kiện** của các norm.
2. **Luật này gần như chỉ có cấm và bắt buộc.** «Được phép» chỉ có ở Điều 15 (đã vào `Laws`) và Điều 32 khoản 5 nhánh (ii) (chờ duyệt). Cặp cấm–cho phép trên cùng một hành vi, nguồn xung đột modality thông thường, hầu như không xuất hiện trong chữ luật. Một xung đột Level 1 thật có thể không tồn tại trong văn bản này.
3. **So sánh giữa các điều cần norm suy ra.** Điều 5 với Điều 15 chỉ so được qua norm suy ra (ADR-0028). Lần đo đầu cho 3 cặp xung đột, cả ba dính norm suy ra; Phong bác cả hai cách đọc D1 và D2 (2026-11-21). Công cụ đã bác được cách đọc «đủ điều kiện cấp phép thì được kinh doanh»; đó là kết quả về cách đọc, không phải về luật.
4. **Độ trung thực chưa có nhiều bằng chứng.** Bản mã hóa đúng luật chỉ do con người đối chiếu: một người duyệt (Phong), không có người học luật độc lập (FR12 chưa làm). Kernel chỉ chứng minh tính hợp lệ của phần đã mã hóa.
5. **Mức phủ.** 7/36 điều đã qua người duyệt. Phần còn lại hoặc đang chờ duyệt hoặc là phân loại của AI chưa duyệt. Các thuật ngữ mở («hợp lý», «dành cho», «ngay trước») là tham số; hệ thống không quyết giá trị.
6. **Bản dịch AI không tin cậy.** 29 điều chưa vào `Laws` chưa có định lý kernel nào. `translate.py check` chỉ kiểm cấu trúc, trích dẫn nguyên văn và id; không kiểm nghĩa.
