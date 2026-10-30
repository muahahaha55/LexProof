# Phiếu duyệt — nhóm «bán / cung cấp / khuyến mại rượu, bia» (Luật 44/2019/QH14)

> ## ⚠ BẢN NHÁP DO AI SOẠN — CHƯA AI DUYỆT
>
> Phiếu này và mô-đun `LexProof/Laws/AlcoholSale.lean` là **bản nháp**. Không điều nào ở đây được coi là đã duyệt, đã đối chiếu với luật, hay là cách đọc đúng. Máy chỉ kiểm được **tính nhất quán của phần đã mã hóa**; việc bản mã hóa có **khớp luật** hay không chỉ người duyệt trả lời được. Các mặc định G1, G4, G7, G12 dưới đây là **tạm dùng**, chưa ai quyết định.

## Cách dùng (đọc trước khi nhìn bản mã hóa)

1. Với **mỗi khoản**, đọc cột «Nguyên văn» trước và **tự quyết định cách đọc của mình**: khoản này là cấm, nghĩa vụ hay cho phép; có ngoại lệ không; ranh giới ngưỡng (từ/dưới) nằm ở đâu; «và»/«hoặc» nối gì.
2. **Sau đó** mới đọc cột «Checker thấy». Đó là đầu ra của một bộ in tất định (`LexProof/Core/Render.lean`) từ chính dữ liệu Lean: act, loại, điều kiện, ngoại lệ, tên atom, nhãn dải, khoản nguồn của từng dải. Không có LLM, không diễn giải.
3. Đánh dấu **Đúng / Sai / Không chắc**, ghi chú, tên người duyệt và ngày vào các cột trống. Nếu «Không chắc» hoặc «Sai», ghi cách đọc của bạn.
4. Cột «Độ tin cậy» là cảm nhận của người soạn, **không phải** bằng chứng.

Nguyên văn được cắt tự động theo số dòng từ `data/extracted/44-2019-QH14.txt` (bản trích từ PDF, xem `data/README.md`; không phải nguồn chính thức); script `eval/sale-group/check_sheet.py` đối chiếu lại cột này với file.

## 1. Nhóm và các mặc định tạm dùng

**Nhóm** (mục C của `docs/slice1-notes.md`, theo act, không theo độ dễ): `ban_ruou_bia`, `cung_cap_ruou_bia`, `khuyen_mai_ruou_bia`, `dung_ruou_bia_lam_qua_khuyen_mai`, `ban_ruou_bia_bang_may_tu_dong` — Điều 5 khoản 3, 9, 11 (nhánh ii) và Điều 19 khoản 1 đến 6.

| Mặc định tạm | Nội dung |
|---|---|
| G1 (bảo thủ) | điều kiện/loại của tiêu đề áp dụng cho mọi khoản dưới nó |
| G4 | «trừ …» là **ngoại lệ**, không phải cho phép |
| G7 (mịn) | mỗi hành vi pháp lý một act; yêu cầu hình thức không chung act với lệnh cấm |
| G12 | một mô-đun `Laws` cho mỗi nhóm act |

## 2. Từng khoản

| id | Nguyên văn (`data/extracted/44-2019-QH14.txt`) | Checker thấy (bộ in tất định) | Mặc định đã dùng | Độ tin cậy (của người soạn) | Đúng / Sai / Không chắc | Ghi chú của người duyệt | Người duyệt | Ngày |
|---|---|---|---|---|---|---|---|---|
| Điều 5 (tiêu đề) | «Điều 5. Các hành vi bị nghiêm cấm trong phòng, chống tác hại của rượu, bia»<br>(dòng 86–87) | Không có norm riêng: nội dung được truyền xuống từng khoản (xem mục 6). | G1: modality «cấm» truyền từ tiêu đề xuống từng khoản | trung bình: Tiêu đề là nguồn duy nhất của loại «cấm» ở Điều 5 (slice1-notes: «cấm qua tiêu đề»). | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 5 khoản 3<br>(norm: 5.3-ban, 5.3-cung-cap, 5.3-khuyen-mai) | «3. Bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi.»<br>(dòng 91) | [5.3-ban] act = ban_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 5 khoản 3<br>điều kiện: S04 tuổi của người nhận = chưa đủ 18 tuổi<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>[5.3-cung-cap] act = cung_cap_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 5 khoản 3<br>điều kiện: S04 tuổi của người nhận = chưa đủ 18 tuổi<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>[5.3-khuyen-mai] act = khuyen_mai_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 5 khoản 3<br>điều kiện: S04 tuổi của người nhận = chưa đủ 18 tuổi<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S04 tuổi của người nhận [enum 2] — nguồn: Điều 5 khoản 3<br>· chưa đủ 18 tuổi — nguồn: Điều 5 khoản 3: «cho người chưa đủ 18 tuổi»<br>· từ đủ 18 tuổi trở lên — nguồn: KHÔNG có khoản nào nêu; là phần bù của «chưa đủ 18 tuổi» (Điều 5 khoản 3), giả định của người mã hóa | G1 (cấm qua tiêu đề; «cho người chưa đủ 18 tuổi» gắn cả ba động từ); G7 (ba act riêng) | trung bình: Ba động từ tách thành ba act (G7) nên không so với nhau; «cung cấp» có thể bao «bán». Dải tuổi trên là phần bù tôi thêm. «cho người chưa đủ 18 tuổi» gắn cả ba động từ là cách đọc tự nhiên nhưng chữ không khóa. | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 5 khoản 9<br>(norm: 5.9-i, 5.9-ii) | «9. Khuyến mại trong hoạt động kinh doanh rượu, bia có độ cồn từ 15 độ trở lên; sử dụng rượu, bia có độ cồn từ 15 độ trở lên để khuyến mại dưới mọi hình thức.»<br>(dòng 103–104) | [5.9-i] act = khuyen_mai_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 5 khoản 9<br>điều kiện: S02 độ cồn của rượu, bia = từ 15 độ trở lên<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>[5.9-ii] act = dung_ruou_bia_lam_qua_khuyen_mai \| loại = cấm \| nguồn = 44/2019/QH14, Điều 5 khoản 9<br>điều kiện: S02 độ cồn của rượu, bia = từ 15 độ trở lên<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S02 độ cồn của rượu, bia [enum 2] — nguồn: Điều 2 khoản 4 (định nghĩa độ cồn); Điều 5 khoản 9<br>· dưới 15 độ — nguồn: Điều 11 tiêu đề: «có độ cồn dưới 15 độ»; phần bù của «từ 15 độ trở lên» (Điều 5 khoản 9)<br>· từ 15 độ trở lên — nguồn: Điều 5 khoản 9: «có độ cồn từ 15 độ trở lên» | G1 (cấm qua tiêu đề); G7 (tách khuyến mại sản phẩm và dùng làm quà; «trong hoạt động kinh doanh rượu, bia» gộp vào act, không có atom) | thấp: Hai nhánh chung một khoản; «trong hoạt động kinh doanh» và «dưới mọi hình thức» không được biểu diễn; ranh giới 15 chỉ đối chiếu được với tiêu đề Điều 11 (ngoài lát cắt). | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 5 khoản 11<br>(norm: 5.11-ii) | «11. Kinh doanh rượu không có giấy phép hoặc không đăng ký; bán rượu, bia bằng máy bán hàng tự động.»<br>(dòng 109–110) | [5.11-ii] act = ban_ruou_bia_bang_may_tu_dong \| loại = cấm \| nguồn = 44/2019/QH14, Điều 5 khoản 11<br>điều kiện: luôn đúng<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Nhánh (i) «Kinh doanh rượu không có giấy phép hoặc không đăng ký» **không** được mã hóa (xem mục 5). | G1; G7 (act riêng «bán bằng máy», điều kiện luôn đúng); G12 (nhánh (i) để mô-đun cấp phép) | trung bình: Chỉ nhánh (ii) được mã hóa. Vì act riêng nên 5.11(ii) không bao giờ được so với Điều 19. Điều kiện «luôn đúng» do act đã mang nội dung. | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 19 (tiêu đề) | «Điều 19. Địa điểm không bán rượu, bia»<br>(dòng 308) | Không có norm riêng: nội dung được truyền xuống từng khoản (xem mục 6). | G1: modality «cấm» và act «bán» truyền xuống khoản 1 đến 6 | trung bình: Tiêu đề chỉ nói «bán»; không nói «cung cấp» hay «khuyến mại» (khác Điều 5 khoản 3). | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 19 khoản 1<br>(norm: 19.1) | «1. Cơ sở y tế.»<br>(dòng 309) | [19.1] act = ban_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 19 khoản 1<br>điều kiện: S14 địa điểm là cơ sở y tế<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S14 địa điểm là cơ sở y tế [Bool] — nguồn: Điều 19 khoản 1 | G1; G7 (act ban_ruou_bia) | trung bình: «cơ sở y tế» không được định nghĩa (căng-tin trong bệnh viện?). | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 19 khoản 2<br>(norm: 19.2) | «2. Cơ sở giáo dục.»<br>(dòng 310) | [19.2] act = ban_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 19 khoản 2<br>điều kiện: S15 địa điểm là cơ sở giáo dục<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S15 địa điểm là cơ sở giáo dục [Bool] — nguồn: Điều 19 khoản 2 | G1; G7 | trung bình: Không có khung thời gian, mã hóa đúng chữ (Điều 10 khoản 2 có «trong thời gian giảng dạy, học tập, làm việc»). | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 19 khoản 3<br>(norm: 19.3) | «3. Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí dành cho người chưa đủ 18 tuổi.»<br>(dòng 312–313) | [19.3] act = ban_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 19 khoản 3<br>điều kiện: (S16 địa điểm là cơ sở hoặc khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí VÀ [tham số] P14 địa điểm «dành cho» người chưa đủ 18 tuổi)<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S16 địa điểm là cơ sở hoặc khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí [Bool] — nguồn: Điều 19 khoản 3<br>P14 địa điểm «dành cho» người chưa đủ 18 tuổi [Bool] — nguồn: Điều 19 khoản 3 («dành cho người chưa đủ 18 tuổi»: khái niệm mở, luật không định nghĩa) | G1; G7; ngoài mặc định: «dành cho» làm tham số P14 (khái niệm mở) | thấp: Tôi tách «cơ sở/khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí» (S16) khỏi «dành cho người chưa đủ 18 tuổi» (P14, tham số) — khác từ vựng B1, nơi S16 là một Bool gộp. | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 19 khoản 4<br>(norm: 19.4) | «4. Cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân và cơ sở giam giữ khác.»<br>(dòng 315–316) | [19.4] act = ban_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 19 khoản 4<br>điều kiện: S17 địa điểm là cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân hoặc cơ sở giam giữ khác<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S17 địa điểm là cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân hoặc cơ sở giam giữ khác [Bool] — nguồn: Điều 19 khoản 4 | G1; G7 | trung bình: Danh sách nối bằng «và» được đọc là hoặc; «cơ sở giam giữ khác» là khe mở. | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 19 khoản 5<br>(norm: 19.5) | «5. Cơ sở bảo trợ xã hội.»<br>(dòng 318) | [19.5] act = ban_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 19 khoản 5<br>điều kiện: S18 địa điểm là cơ sở bảo trợ xã hội<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): không có<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S18 địa điểm là cơ sở bảo trợ xã hội [Bool] — nguồn: Điều 19 khoản 5 | G1; G7 | cao: Không phát hiện đa nghĩa trong slice1-notes. | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |
| Điều 19 khoản 6<br>(norm: 19.6) | «6. Nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập, trừ địa điểm được phép kinh doanh rượu, bia.»<br>(dòng 319–321) | [19.6] act = ban_ruou_bia \| loại = cấm \| nguồn = 44/2019/QH14, Điều 19 khoản 6<br>điều kiện: S19 địa điểm là nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập<br>ngoại lệ (norm không áp dụng nếu bất kỳ cái nào đúng): S20 địa điểm được phép kinh doanh rượu, bia<br>ưu tiên: không khai báo<br><br>Atom và dải mà norm đọc:<br>S19 địa điểm là nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập [Bool] — nguồn: Điều 19 khoản 6<br>S20 địa điểm được phép kinh doanh rượu, bia [Bool] — nguồn: Điều 19 khoản 6 (ngoại lệ «trừ địa điểm được phép kinh doanh rượu, bia») | G1; G4 (ngoại lệ, không phải cho phép); G7 | thấp: «trừ địa điểm được phép kinh doanh» mã hóa thành ngoại lệ S20; S20 phụ thuộc chế độ cấp phép (Điều 15) và có thể trùng 5.11(i). Khác Điều 10 khoản 6, không có «trong thời gian làm việc». | ☐ Đúng<br>☐ Sai<br>☐ Không chắc | | | |

## 3. Dải ngưỡng: các ranh giới có khớp không?

Bộ kiểm **không phát hiện** khe hở hay chồng lấn giữa các dải: với nó một dải chỉ là nhãn. Phép kiểm dưới đây chạy **ngoài Lean** (`eval/sale-group/boundaries.py`); các khoảng số do người soạn khai tay từ khoản quy định từng đầu mút.

```
== S02 độ cồn (đơn vị: độ = % thể tích, Điều 2 khoản 4)
  band dưới 15 độ               [0, 15)   label in Lean: yes
     hi end fixed by clause 11 (lines 206-208): 'có độ cồn dưới 15 độ' -> found
  band từ 15 độ trở lên         [15, 100]   label in Lean: yes
     lo end fixed by clause 5.9 (lines 103-104): 'có độ cồn từ 15 độ trở lên' -> found
  'dưới 15 độ' | 'từ 15 độ trở lên' : meet exactly = True, gap = False, overlap = False
== S04 tuổi của người nhận (năm)
  band chưa đủ 18 tuổi          [0, 18)   label in Lean: yes
     hi end fixed by clause 5.3 (lines 91-91): 'người chưa đủ 18 tuổi' -> found
  band từ đủ 18 tuổi trở lên    [18, ∞)   label in Lean: yes
     (no clause states this band; it is the complement of the previous one)
  'chưa đủ 18 tuổi' | 'từ đủ 18 tuổi trở lên' : meet exactly = True, gap = False, overlap = False
```

Đọc kết quả: các dải **khớp nhau chính xác** (một đầu đóng, một đầu mở), không hở, không chồng. Nhưng: (a) ranh giới **15** được hai khoản độc lập cùng xác nhận (Điều 11 tiêu đề «dưới 15 độ» ở dòng 206, Điều 5 khoản 9 «từ 15 độ trở lên» ở dòng 103); (b) ranh giới **18** chỉ có **một** khoản (cạnh «chưa đủ 18 tuổi»), dải «từ đủ 18 tuổi trở lên» là **phần bù do người soạn thêm**, không khoản nào nêu; (c) cận trên 100 của độ cồn là giới hạn vật lý, **luật không nêu**; (d) «độ» được hiểu là phần trăm thể tích theo Điều 2 khoản 4 — Điều 2 không nói rõ 1 độ = 1% thể tích (slice1-notes, Điều 2 khoản 4).

## 4. Bảng act

| Act | Hành vi | Norm | Khoản |
|---|---|---|---|
| `ban_ruou_bia` | bán rượu, bia | 5.3-ban, 19.1, 19.2, 19.3, 19.4, 19.5, 19.6 | Điều 19 khoản 1; Điều 19 khoản 2; Điều 19 khoản 3; Điều 19 khoản 4; Điều 19 khoản 5; Điều 19 khoản 6; Điều 5 khoản 3 |
| `cung_cap_ruou_bia` | cung cấp rượu, bia | 5.3-cung-cap | Điều 5 khoản 3 |
| `khuyen_mai_ruou_bia` | khuyến mại rượu, bia | 5.3-khuyen-mai, 5.9-i | Điều 5 khoản 3; Điều 5 khoản 9 |
| `dung_ruou_bia_lam_qua_khuyen_mai` | dùng rượu, bia làm phương tiện khuyến mại | 5.9-ii | Điều 5 khoản 9 |
| `ban_ruou_bia_bang_may_tu_dong` | bán rượu, bia bằng máy bán hàng tự động | 5.11-ii | Điều 5 khoản 11 |

Chỉ các norm **cùng act** được so với nhau: `ban_ruou_bia` có 7 norm (21 cặp), `khuyen_mai_ruou_bia` có 2 (1 cặp), ba act còn lại mỗi act một norm.

## 5. Điều khoản của nhóm hoặc sát nhóm **không** được mã hóa

| Điều khoản | Nguyên văn (dòng) | Lý do không mã hóa |
|---|---|---|
| Điều 5 tiêu đề | xem mục 2 | không phải norm riêng: modality «cấm» được áp dụng cho từng khoản qua G1 conservative |
| Điều 19 tiêu đề | xem mục 2 | không phải norm riêng: modality «cấm» và act «bán» được áp dụng cho từng khoản 1 đến 6 qua G1 conservative |
| Điều 5 khoản 11 nhánh (i) | «11. Kinh doanh rượu không có giấy phép hoặc không đăng ký»<br>(dòng 109–110, phần trước dấu chấm phẩy) | khác nhóm act (kinh_doanh_ruou_khong_phep_hoac_dang_ky): thuộc mô-đun cấp phép (G12); thực chất là nghĩa vụ có giấy phép/đăng ký, phụ thuộc Điều 15 |
| Điều 2 khoản 1, 2, 4 | «1. Rượu là đồ uống có cồn thực phẩm, được sản xuất từ quá trình lên men từ một hoặc hỗn hợp của các loại nguyên liệu chủ yếu gồm tinh bột của ngũ cốc, dịch đường của cây, hoa, củ, quả hoặc là đồ uống được pha chế từ cồn thực phẩm.»<br>(dòng 27–29)<br><br>«2. Bia là đồ uống có cồn thực phẩm, được sản xuất từ quá trình lên men từ hỗn hợp của các loại nguyên liệu chủ yếu gồm mạch nha (malt), đại mạch, nấm men bia, hoa bia (hoa houblon), nước.»<br>(dòng 30–32)<br><br>«4. Độ cồn là số đo chỉ hàm lượng cồn thực phẩm có trong rượu, bia tính theo phần trăm thể tích. Độ cồn được tính bằng số mililít ethanol nguyên chất trong 100 ml dung dịch ở 20°C.»<br>(dòng 36–39) | định nghĩa rượu, bia, độ cồn: dùng làm từ vựng (atom S02), không phải norm |
| Điều 11 | «Điều 11. Quản lý việc khuyến mại rượu, bia có độ cồn dưới 15 độ Tổ chức, cá nhân thực hiện khuyến mại rượu, bia có độ cồn dưới 15 độ phải tuân thủ các quy định của Luật này và quy định khác của pháp luật về khuyến mại.»<br>(dòng 206–208) | ngoài lát cắt 1; chỉ yêu cầu «tuân thủ» luật này và pháp luật về khuyến mại (dẫn chiếu văn bản khác); chưa đọc phân tích |
| Điều 15 khoản 4 | «4. Điều kiện cấp phép mua bán rượu có độ cồn từ 5,5 độ trở lên bao gồm: a) Đăng ký kinh doanh theo quy định của pháp luật; b) Đáp ứng điều kiện theo từng loại hình mua bán rượu.»<br>(dòng 281–283) | ngoài lát cắt 1; điều kiện cấp phép mua bán rượu từ 5,5 độ; định nghĩa «được phép kinh doanh» dùng ở 19.6 (S20) nằm ở đây; chưa đọc phân tích |
| Điều 16 | «Điều 16. Điều kiện bán rượu, bia theo hình thức thương mại điện tử 1. Đáp ứng quy định tại khoản 4, khoản 5 Điều 15 và Điều 18 của Luật này. 2. Đáp ứng điều kiện theo quy định của pháp luật về thương mại điện tử. 3. Thực hiện biện pháp theo quy định của Chính phủ để ngăn ngừa người chưa đủ 18 tuổi tiếp cận, truy cập, tìm kiếm thông tin và mua rượu, bia. 4. Áp dụng hình thức thanh toán không dùng tiền mặt.»<br>(dòng 286–291) | ngoài lát cắt 1; điều kiện bán qua thương mại điện tử (nghĩa vụ hình thức, giao Chính phủ quy định biện pháp, dẫn pháp luật thương mại điện tử); chưa đọc phân tích |
| Điều 32 khoản 3, 5, 7 | «3. Không sử dụng lao động là người chưa đủ 18 tuổi trực tiếp tham gia vào việc kinh doanh, quảng cáo rượu, bia.»<br>(dòng 552–553)<br><br>«5. Cơ sở bán rượu, bia phải niêm yết thông báo không bán rượu, bia cho người chưa đủ 18 tuổi. Trường hợp nghi ngờ về độ tuổi của người mua rượu, bia thì người bán có quyền yêu cầu người mua xuất trình giấy tờ chứng minh.»<br>(dòng 558–560)<br><br>«7. Kể từ ngày Luật này có hiệu lực, không được mở mới điểm bán rượu, bia để tiêu dùng tại chỗ trong bán kính 100 m tính từ khuôn viên của cơ sở y tế, nhà trẻ, trường mẫu giáo, trường mầm non, cơ sở giáo dục phổ thông.»<br>(dòng 567–569) | ngoài lát cắt 1; trách nhiệm của cơ sở kinh doanh: 32.3 lao động dưới 18 (liên quan 5.4), 32.5 nghĩa vụ niêm yết (hình thức), 32.7 cấm mở điểm bán mới trong bán kính 100 m — khoảng cách không biểu diễn được bằng Core hiện tại |

Các điều ngoài lát cắt 1 (11, 15, 16, 32) **chưa được phân tích** trong `slice1-notes.md`; việc liệt kê ở đây chỉ để không bỏ im lặng, không phải đánh giá nội dung.

## 6. Những chỗ đã dựa vào mặc định tạm

| Mặc định | Dùng ở đâu | Nếu người duyệt chọn khác |
|---|---|---|
| G1 bảo thủ | Điều 5 tiêu đề → loại «cấm» của 5.3, 5.9, 5.11(ii); Điều 19 tiêu đề → loại «cấm» và act «bán» của 19.1 đến 19.6; «cho người chưa đủ 18 tuổi» gắn cả ba động từ ở 5.3 | Nếu tiêu đề chỉ là nhãn, các khoản 19.1 đến 19.6 (chỉ ghi địa điểm) không có động từ nên phải mã hóa lại; nếu «cho người chưa đủ 18 tuổi» chỉ gắn «khuyến mại», 5.3 đổi thành hai norm không điều kiện tuổi |
| G4 | 19.6 «trừ địa điểm được phép kinh doanh rượu, bia» → ngoại lệ S20 | Nếu là cho phép: thêm một norm «cho phép bán» (S19 và S20) cùng act `ban_ruou_bia`; nó sẽ xung đột về modality với 19.1 đến 19.5 ở mọi điểm hai điều kiện cùng đúng (kiểu cặp «chéo» ở scaling-analysis 3.2) |
| G7 mịn | 5.3 ba act; 5.9 hai act; 5.11(ii) act «bán bằng máy» riêng | Nếu gộp «bán/cung cấp/khuyến mại» thành một act, số cặp được so tăng; vì mọi norm đều là cấm nên vẫn không có xung đột modality |
| G12 | một mô-đun cho nhóm này; 5.11(i) (cấp phép) để mô-đun khác; bảng atom riêng | Nếu một mô-đun chung, bảng lớn hơn nhưng kiểm theo cặp chỉ duyệt atom mà từng cặp đọc |

## 7. Chỗ lệch khỏi từ vựng B1/B2 của `slice1-notes.md` và các giả định khác của người soạn

- **S04** (người nhận chưa đủ 18 tuổi): B1 là Bool; ở đây là enum hai dải để mỗi dải mang khoản nguồn và để kiểm ranh giới.
- **S02** (độ cồn): B1 có ba dải (dưới 5,5 · 5,5 đến dưới 15 · từ 15); ở đây chỉ hai dải (dưới 15 · từ 15) vì nhóm này không dùng ranh giới 5,5.
- **S16** và **P14**: B1 có S16 là một Bool «cơ sở/khu vực dành cho người chưa đủ 18 tuổi»; ở đây tách thành S16 (loại cơ sở) và tham số mở P14 («dành cho»), theo nguyên tắc khái niệm mở là tham số. P14 là id **mới**.
- **S01** (rượu/bia) không dùng: 5.9 và 5.11(ii) áp dụng cho cả rượu lẫn bia.
- «trong hoạt động kinh doanh rượu, bia» (5.9) và «dưới mọi hình thức» (5.9 nhánh ii) **không** có atom.
- 19.6 không có điều kiện «trong thời gian làm việc» vì chữ của khoản không có (khác 10.6).
- Danh sách «và» ở 19.4 được đọc là hoặc (các loại cơ sở).
- `effective` của mọi norm đặt 2020-01-01 theo Điều 36 khoản 1 (dòng 642); Core không kiểm ngày.

## 8. Kết quả `analyzeP` và ý nghĩa của nó

`analyzeP` trả **`consistentOn`** (kernel chứng minh: `decide +kernel`, định lý `consistent` và `silent` trong mô-đun). Không có finding nào của `validate`, bảng hay bộ đọc.

| Mục | Giá trị |
|---|---|
| Số norm | 12 |
| Số cặp không thứ tự | 66 |
| Cặp đã kiểm (cùng act) | 22 |
| Cặp bỏ qua (khác act) | 44 |
| Điểm duyệt mỗi cặp | từ 4 đến 16; tổng 140 |
| Miền đầy đủ (tích, không liệt kê) | 512 tình huống × 2 tham số |
| Dùng ràng buộc toàn vẹn | **không** (`constraintsUsed = false`) |
| Thời gian | tệp mô-đun chạy `lake env lean`: 9,13 / 9,23 / 8,68 giây (ba lượt, gồm nạp thư viện ≈ 0,7 giây); kernel: `silent` 3,6 giây, `consistent` 7,5 giây |

**Điều kết quả này KHÔNG cho biết.** Mọi norm trong nhóm là *cấm*; hai lệnh cấm không có cặp modality khắc nhau, nên `consistentOn` ở đây **đúng với mọi nội dung điều kiện**: nó sẽ y hệt nếu điều kiện của mọi khoản bị thay bằng điều kiện khác. Nó không nói gì về việc bản mã hóa có khớp luật; không phát hiện khe hở/chồng lấn giữa các dải (mục 3); không biết 5.11(ii) và Điều 19 cùng nói về «bán» (G7 mịn tách act); và có thể che xung đột thật ở những khoản chưa mã hóa (mục 5).

## 9. Tái lập

```
python eval/sale-group/check_sources.py          # danh mục Điều 1..36, các khoản, cụm từ
python eval/sale-group/boundaries.py             # ranh giới các dải
lake env lean --run eval/sale-group/Print.lean > eval/sale-group/print_output.txt
python eval/sale-group/build_sheet.py            # sinh lại phiếu này
python eval/sale-group/check_sheet.py            # đối chiếu cột «Nguyên văn» với file trích xuất
```
