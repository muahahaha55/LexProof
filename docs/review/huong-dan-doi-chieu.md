# Hướng dẫn đối chiếu cho người duyệt

LexProof là một công cụ kiểm tra xem các điều khoản trong **một văn bản luật** có mâu thuẫn nhau không. Văn bản đang thử là **Luật Phòng, chống tác hại của rượu, bia số 44/2019/QH14**. Máy chỉ kiểm tra được phần *logic* trên dữ liệu đã nhập. Máy **không** biết dữ liệu đó có đúng ý của luật hay không. Chỗ đó chỉ người đọc luật mới đánh giá được, và đó là việc nhờ bạn.

Bạn không cần đọc hay chạy code. Mọi thứ bạn cần đều là tệp văn bản và PDF.

## Nguyên tắc

- Ghi theo **chữ của luật**, không đoán ý người soạn. Nếu chữ chưa đủ để quyết thì ghi «**không biết**» (đây là câu trả lời hợp lệ và có ích).
- Không viết «đúng luật» hay «hợp pháp». Chỉ ghi: khớp / không khớp / không chắc, kèm lý do.
- Không sửa tệp `.lean` hay `.py`. Kết quả của bạn ghi vào một tệp riêng (xem mục 4).

## 1. Đối chiếu bản chữ của luật với văn bản chính thức

Hiện bản chữ dùng trong dự án là **bản trích từ PDF Công báo số 559 + 560 (17/7/2019)**, chưa từng được so với nguồn chính thức.

- Toàn văn 36 điều có ở mục 2 của **`docs/review/ban-nhap-ai-phieu-ca-thu.pdf`** (các điều có nền vàng là điều quan trọng nhất), hoặc tệp `data/extracted/44-2019-QH14.txt`.
- Hãy so với văn bản chính thức (Công báo hoặc Cổng thông tin điện tử Chính phủ), ít nhất các điều: **5, 10, 11, 15, 16, 19, 32, 33, 36**. Ghi lại bất kỳ chỗ nào lệch chữ hoặc lệch số khoản.
- Kiểm tra luật **còn hiệu lực và chưa được sửa đổi** từ 2019, và xem có văn bản mới thay thế Nghị quyết 66.18/2026/NQ-CP (mục dưới) chưa.

### Nghị quyết 66.18/2026/NQ-CP (đã kiểm tra một phần, ngày 2026-11-18)

Nghị quyết của Chính phủ ngày 18/5/2026 **có thật** (Cổng thông tin điện tử Chính phủ, vanban.chinhphu.vn, số ký hiệu 66.18/2026/NQ-CP). Theo Điều 7 của nghị quyết, nó **chỉ có hiệu lực từ 01/7/2026 đến hết 28/02/2027**; trong thời gian đó, quy định của nghị quyết được ưu tiên hơn văn bản khác nếu hai bên khác nhau, và quy định tương ứng hết hiệu lực khi có văn bản khác về cùng nội dung có hiệu lực.

Ba mục liên quan tới Luật 44/2019/QH14 (chữ đọc được từ PDF chính thức, nguồn máy nhận chữ nên có lỗi chính tả):

1. Không thực hiện quy định «Kinh doanh rượu không có giấy phép hoặc không đăng ký» tại khoản 11 Điều 5.
2. Không thực hiện điều kiện quy định tại Điều 15.
3. Không thực hiện quy định «Đáp ứng quy định tại khoản 4, khoản 5 Điều 15» tại khoản 1 Điều 16.

Nhờ bạn **mở PDF gốc và xác nhận** ba điều chưa chắc:

- **Q8.** Ba mục trên nằm ở phụ lục nào, mục nào? (Một bài trên thuvienphapluat.vn nói Phụ lục I.2, Bộ Công Thương; chưa thấy tận mắt trong PDF.)
- **Q9.** Ngày bắt đầu của ba mục là 01/7/2026, hay 20/5/2026 (Điều 7 khoản 2 nêu một số phần của Phụ lục I.2 có hiệu lực từ 20/5/2026)?
- **Q10.** Trong thời gian nghị quyết có hiệu lực, một người bán rượu không có giấy phép (ca C24) có còn bị cấm theo khoản 11 Điều 5 vế đầu không? Cách hiểu của người soạn: không còn bị cấm trong thời gian đó (vì điều kiện giấy phép không được thực hiện), nhưng **chưa kiểm tra tác động lên nghị định xử phạt**.

Việc quan hệ giữa luật và một nghị quyết có hiệu lực theo thời gian thuộc phạm vi Level 2, chưa làm trong dự án này. Mọi kết quả của công cụ chỉ xét **văn bản luật gốc**.

## 2. Quyết cách đọc luật ở các chỗ còn tranh cãi

Đây là phần quan trọng nhất. Với mỗi câu hỏi, ghi: cách đọc của bạn, và «chắc» / «không chắc».

| # | Câu hỏi | Chữ của luật |
|---|---|---|
| Q1 | Điều 5 khoản 11 («Kinh doanh rượu không có giấy phép hoặc không đăng ký»): vi phạm khi thiếu **một trong hai**, hay chỉ khi thiếu **cả hai**? (AI đang mã hóa theo cách «thiếu cả hai».) | «Kinh doanh rượu không có giấy phép hoặc không đăng ký» |
| Q2 | Điều 5 khoản 10, vế sau: «không bảo đảm chất lượng **và** không rõ nguồn gốc» thì cần cả hai điều kiện, hay một trong hai là đủ? | «nguyên liệu, phụ gia thực phẩm, chất hỗ trợ chế biến thực phẩm không bảo đảm chất lượng và không rõ nguồn gốc, xuất xứ» |
| Q3 | Điều 5 khoản 3: «cung cấp» có gồm việc **cho không, tặng** không? | «Bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi» |
| Q4 | Điều 19 («Địa điểm không bán rượu, bia») chỉ cấm **bán**. Tặng rượu miễn phí tại phòng khám có bị Điều 19 cấm không? | Tiêu đề Điều 19; khoản 1 «Cơ sở y tế» |
| Q5 | Điều 19 khoản 6: cụm «trừ địa điểm được phép kinh doanh rượu, bia» chỉ thu hẹp lệnh cấm, hay còn **tạo ra quyền** bán ở địa điểm đó? | Điều 19 khoản 6 |
| Q6 | Điều 32 khoản 7 cấm *mở mới* điểm bán rượu, bia **để tiêu dùng tại chỗ** trong bán kính 100 m quanh cơ sở y tế, trường học. Một cửa hàng tạp hóa cách cổng bệnh viện 50 m bán một chai rượu mang về thì sao? | Điều 32 khoản 7 |
| Q7 | Điều 5 khoản 11 vế đầu chỉ nói «rượu», không nói «bia». Bán bia không giấy phép có bị khoản này cấm không? | Điều 2 khoản 1, 2 (định nghĩa rượu, bia riêng); Điều 5 khoản 11 |

## 3. (Tùy chọn) Trả lời độc lập 37 ca thử

37 tình huống ngắn nằm trong `docs/review/sale-group-cases.md`. **Tệp hiện tại đã được điền theo bản nháp của AI**, nên đừng dùng nó nếu bạn muốn trả lời độc lập. Bản **trống** lấy được bằng lệnh:

```
git show 3687e45:docs/review/sale-group-cases.md
```

Hoặc nhờ người giao repo xuất ra một tệp. Để độc lập, **đừng mở trước** `docs/review/sale-group-cases-ai-draft.md`, `ban-nhap-ai-phieu-ca-thu.pdf` và `docs/review/sale-group-cases-key.md`. Với mỗi ca chọn một: **cấm** / **bắt buộc** / **được phép** / **không biết** / **khoản này không điều chỉnh**.

## 4. Ghi kết quả

Tạo tệp `docs/review/ket-qua-doi-chieu-TEN-NGAY.md` (ví dụ `ket-qua-doi-chieu-Phong-2026-11-20.md`) gồm:

1. Tên người duyệt, ngày.
2. **Bạn có xem bản nháp của AI trước khi trả lời không?** (có / không / một phần.)
3. Mục 1: danh sách chỗ lệch chữ (nếu có), tình trạng hiệu lực của luật.
4. Mục 2: bảng Q1–Q7 và Q8–Q10 (mục Nghị quyết 66.18/2026/NQ-CP) với cách đọc, và «chắc» / «không chắc».
5. Mục 3 (nếu làm): danh sách `C01 cấm`, `C02 khoản này không điều chỉnh`, ...

Gửi lại tệp này cho người giao repo.

## Hiểu đúng kết quả của công cụ

- Công cụ chỉ báo «tìm thấy xung đột», «nhất quán trên phần đã mã hóa» hoặc «không biết». **Không bao giờ** là «văn bản này đúng».
- Hiện mới có **9 trong 141 khoản** của luật được mã hóa tay; phần dịch tự động bằng AI (`eval/translate/`) mới thử trên Điều 19 và Điều 5.
- Báo cáo ngày 2026-11-13 ghi người duyệt Phong nhưng **cả 37 hàng lấy theo bản nháp AI**, không phải trả lời độc lập. Vì thế ý kiến độc lập của bạn có giá trị hơn con số trong báo cáo đó.
