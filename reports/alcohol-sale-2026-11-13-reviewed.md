# Báo cáo nhất quán: Luật 44/2019/QH14, nhóm bán / cung cấp / khuyến mại rượu, bia

## 1. Trạng thái

> # PHIẾU CA THỬ ĐÃ ĐƯỢC ĐIỀN: người duyệt Phong, ngày 2026-11-13
>
> Đây là ghi nhận: công cụ chỉ kiểm phiếu đủ hàng, đủ người duyệt và ngày, và mô-đun không đổi từ lúc duyệt. Công cụ không kiểm danh tính, không kiểm nội dung câu trả lời, và việc này không có nghĩa bản mã hóa khớp luật.
>
> **37/37 hàng của phiếu ghi là câu trả lời lấy theo bản nháp do AI soạn, không phải trả lời độc lập (mù).** AI cũng là người viết bản mã hóa và các ca thử, nên việc phiếu khớp kỳ vọng không phải bằng chứng độc lập về độ trung thực.

## 2. Phạm vi

Nguồn: sổ phủ `docs/review/alcohol-coverage-ledger.md` (sha256 ở mục 7). Số đơn vị của toàn văn bản: 141 khoản, 45 điểm, 6 đoạn dẫn không đánh số (đếm theo điều có đoạn dẫn).

| Trạng thái | Khoản | Điểm | Đoạn dẫn không đánh số |
|---|---|---|---|
| đã mã hóa (nháp), gồm một phần | 9 / 141 | 0 / 45 | 0 / 6 |
| trong đó một phần | 1 / 141 | 0 / 45 | 0 / 6 |
| chưa mã hóa (not encoded), gồm một phần | 11 / 141 | 2 / 45 | 2 / 6 |
| ngoài mô-đun (outside this module) | 25 / 141 | 6 / 45 | 1 / 6 |
| UNACCOUNTED (trong phạm vi mô-đun nhưng không được nhắc) | 13 / 141 | 8 / 45 | 0 / 6 |
| chưa phân loại | 83 / 141 | 29 / 45 | 3 / 6 |
| tổng | 141 / 141 | 45 / 45 | 6 / 6 |

UNACCOUNTED: 21 đơn vị (khoản + điểm + đoạn): Điều 2 khoản 3; Điều 2 khoản 5; Điều 2 khoản 6; Điều 2 khoản 7; Điều 2 khoản 8; Điều 15 khoản 1; Điều 15 khoản 1 điểm a; Điều 15 khoản 1 điểm b; Điều 15 khoản 1 điểm c; Điều 15 khoản 1 điểm d; Điều 15 khoản 2; Điều 15 khoản 2 điểm a; Điều 15 khoản 2 điểm b; Điều 15 khoản 3; Điều 15 khoản 3 điểm a; Điều 15 khoản 3 điểm b; Điều 15 khoản 5; Điều 32 khoản 1; Điều 32 khoản 2; Điều 32 khoản 4; Điều 32 khoản 6.

**Bảng này đếm xem đơn vị của luật có được một norm nháp hay một mục chưa-mã-hóa nhắc tới hay không. Nó không phải thước đo độ trung thực của bản mã hóa với luật.**

Các mục chưa mã hóa mà mô-đun tự khai (notEncoded):

- Điều 5 tiêu đề: không phải norm riêng: modality «cấm» được áp dụng cho từng khoản qua G1 conservative
- Điều 19 tiêu đề: không phải norm riêng: modality «cấm» và act «bán» được áp dụng cho từng khoản 1 đến 6 qua G1 conservative
- Điều 5 khoản 11 nhánh (i): khác nhóm act (kinh_doanh_ruou_khong_phep_hoac_dang_ky): thuộc mô-đun cấp phép (G12); thực chất là nghĩa vụ có giấy phép/đăng ký, phụ thuộc Điều 15
- Điều 2 khoản 1, 2, 4: định nghĩa rượu, bia, độ cồn: dùng làm từ vựng (atom S02), không phải norm
- Điều 11: ngoài lát cắt 1; chỉ yêu cầu «tuân thủ» luật này và pháp luật về khuyến mại (dẫn chiếu văn bản khác); chưa đọc phân tích
- Điều 15 khoản 4: ngoài lát cắt 1; điều kiện cấp phép mua bán rượu từ 5,5 độ; định nghĩa «được phép kinh doanh» dùng ở 19.6 (S20) nằm ở đây; chưa đọc phân tích
- Điều 16: ngoài lát cắt 1; điều kiện bán qua thương mại điện tử (nghĩa vụ hình thức, giao Chính phủ quy định biện pháp, dẫn pháp luật thương mại điện tử); chưa đọc phân tích
- Điều 32 khoản 3, 5, 7: ngoài lát cắt 1; trách nhiệm của cơ sở kinh doanh: 32.3 lao động dưới 18 (liên quan 5.4), 32.5 nghĩa vụ niêm yết (hình thức), 32.7 cấm mở điểm bán mới trong bán kính 100 m — khoảng cách không biểu diễn được bằng Core hiện tại

## 3. Kết quả nhất quán

> **Nói trước: mô-đun này không có act nào có hai modality khắc nhau (mọi norm đều là cấm), nên không xung đột modality nào có thể xảy ra. «consistentOn» ở đây RỖNG về thông tin: nó đúng với mọi nội dung điều kiện, kể cả điều kiện sai.**

Kết quả có ba giá trị: tìm thấy xung đột / nhất quán trên phần đã mã hóa / không biết. Với mô-đun này: **NHẤT QUÁN TRÊN PHẦN ĐÃ MÃ HÓA (consistentOn)**.

- Đã kiểm 22 cặp norm cùng act; bỏ qua 44 cặp khác act.
- Miền tình huống đầy đủ 512 tổ hợp, tham số 2; mỗi cặp được tìm trên các atom nó đọc.
- Ràng buộc toàn vẹn: KHÔNG dùng.
- Kết quả này chỉ nói về phần đã mã hóa ở mục 2, không nói gì về cả văn bản.

Định lý kernel và máy diễn giải cho từng kết quả chính:

| Kết quả | Định lý kernel / máy diễn giải |
|---|---|
| kết quả phân tích (consistentOn) | định lý `LexProof.Laws.AlcoholSale.consistent`; máy diễn giải KHỚP |
| không có xung đột giữa hai norm nào (suy ra từ trên) | định lý `LexProof.Laws.AlcoholSale.no_conflict_in_group`; máy diễn giải KHỚP |
| không có phát hiện cấu trúc (bảng, bộ đọc, validate) | định lý `LexProof.Laws.AlcoholSale.silent`; máy diễn giải KHỚP |
| tập ca đạt (runCase) | định lý `LexProof.Laws.AlcoholSaleCases.pass_set`; máy diễn giải KHỚP |
| tập ca ngoài phạm vi (theo tham chiếu) | định lý `LexProof.Laws.AlcoholSaleRefs.refOutOfScope_set`; máy diễn giải KHỚP |
| các ca số đều đạt | định lý `LexProof.Laws.AlcoholSaleBands.num_pass_all`; máy diễn giải KHỚP |
| không có chuỗi tham chiếu không phân tích được | định lý `LexProof.Laws.AlcoholSaleRefs.unparsable_none`; máy diễn giải KHỚP |
| không có tham chiếu ngoài catalog | định lý `LexProof.Laws.AlcoholSaleRefs.notInCatalog_none`; máy diễn giải KHỚP |
| hai chuỗi khác nhau cùng một tham chiếu (C37) | định lý `LexProof.Laws.AlcoholSaleRefs.sameRef_c37`; máy diễn giải KHỚP |
| cờ rỗng về modality (noModalityClash) | chưa có định lý kernel cho kết quả này |
| các cặp được ưu tiên giải quyết (resolutions) | chưa có định lý kernel cho kết quả này |
| phát hiện về act (act dùng một lần, act ngoài danh mục) | chưa có định lý kernel cho kết quả này |
| tổng của sổ phủ (ledger) | chưa có định lý kernel cho kết quả này |
| kết quả từng ca không đạt (loại kết quả «got») | chưa có định lý kernel cho kết quả này |

Định lý kernel nói về mã hóa nháp theo đúng phát biểu của nó; không định lý nào nói bản mã hóa khớp luật.

## 4. Phát hiện cấu trúc

- Phát hiện của bảng atom, bộ đọc và validate: không có.
- Phát hiện về act (act ngoài danh mục): không có.
- Act chỉ dùng một norm: cung_cap_ruou_bia, dung_ruou_bia_lam_qua_khuyen_mai, ban_ruou_bia_bang_may_tu_dong.
- Act trong danh mục nhưng không norm nào dùng: không có.
- Cặp norm được ưu tiên giải quyết: 0.
- Act: cung_cap_ruou_bia (1 norm, có cặp khắc nhau: không); khuyen_mai_ruou_bia (2 norm, có cặp khắc nhau: không); dung_ruou_bia_lam_qua_khuyen_mai (1 norm, có cặp khắc nhau: không); ban_ruou_bia_bang_may_tu_dong (1 norm, có cặp khắc nhau: không); ban_ruou_bia (7 norm, có cặp khắc nhau: không)
- Phát hiện về tham chiếu:
  - hai chuỗi khác nhau cùng một tham chiếu: «Điều 19 (tiêu đề)» và «Điều 19 tiêu đề»

## 5. Kết quả các ca thử

Các ca do cùng tác giả viết bản mã hóa và đọc cùng một cách; ca đạt cho thấy bản mã hóa khớp cách đọc của tác giả; nó không cho thấy bản mã hóa khớp luật. **noNormApplies và outOfScope không nói gì về luật**: noNormApplies chỉ nghĩa là không norm nào của mô-đun này áp dụng, outOfScope nghĩa là khoản đó không được mã hóa và ca không được chạy như một phép thử.

Tổng 37 ca: PASS 36, FAIL 0, UNDERSPECIFIED 0, MALFORMED 0 (trong phạm vi); outOfScope 1; tham chiếu hỏng 0.

### FAIL

(không có)

### UNDERSPECIFIED

(không có)

### MALFORMED

(không có)

### outOfScope (liệt kê riêng; không phải PASS, không nói gì về luật)

| Ca | Act | Khoản | Kỳ vọng | Phạm vi | Chạy không xét phạm vi |
|---|---|---|---|---|---|
| C24 | kinh_doanh_ruou_khong_phep_hoac_dang_ky | Điều 5 khoản 11 nhánh (i) | forbidden | NGOÀI PHẠM VI (khoản «Điều 5 khoản 11 nhánh (i)» không được mã hóa) | FAIL |

Cột cuối chỉ để nhìn; ca ngoài phạm vi không được tính là đạt.

### PASS (trong phạm vi; noNormApplies luôn kèm trạng thái phạm vi)

| Ca | Act | Khoản | Kỳ vọng | Phạm vi |
|---|---|---|---|---|
| C01 | ban_ruou_bia | Điều 5 khoản 3 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C02 | ban_ruou_bia | Điều 5 khoản 3 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C03 | ban_ruou_bia | Điều 5 khoản 3 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C04 | ban_ruou_bia | Điều 5 khoản 3 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C05 | cung_cap_ruou_bia | Điều 5 khoản 3 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C06 | cung_cap_ruou_bia | Điều 5 khoản 3 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C07 | cung_cap_ruou_bia | Điều 5 khoản 3 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C08 | cung_cap_ruou_bia | Điều 5 khoản 3 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C09 | khuyen_mai_ruou_bia | Điều 5 khoản 3 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C10 | khuyen_mai_ruou_bia | Điều 5 khoản 3 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C11 | khuyen_mai_ruou_bia | Điều 5 khoản 3 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C12 | khuyen_mai_ruou_bia | Điều 5 khoản 3 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C13 | khuyen_mai_ruou_bia | Điều 5 khoản 9 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C14 | khuyen_mai_ruou_bia | Điều 5 khoản 9 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C15 | khuyen_mai_ruou_bia | Điều 5 khoản 9 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C16 | khuyen_mai_ruou_bia | Điều 5 khoản 9 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C17 | khuyen_mai_ruou_bia | Điều 5 khoản 9 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C18 | dung_ruou_bia_lam_qua_khuyen_mai | Điều 5 khoản 9 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C19 | dung_ruou_bia_lam_qua_khuyen_mai | Điều 5 khoản 9 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C20 | dung_ruou_bia_lam_qua_khuyen_mai | Điều 5 khoản 9 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C21 | dung_ruou_bia_lam_qua_khuyen_mai | Điều 5 khoản 9 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C22 | ban_ruou_bia_bang_may_tu_dong | Điều 5 khoản 11 nhánh (ii) | forbidden | trong phạm vi (khoản đã mã hóa) |
| C23 | ban_ruou_bia | Điều 5 khoản 11 nhánh (ii) | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C25 | ban_ruou_bia | Điều 19 khoản 1 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C26 | ban_ruou_bia | Điều 19 khoản 1 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C27 | ban_ruou_bia | Điều 19 khoản 2 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C28 | ban_ruou_bia | Điều 19 khoản 2 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C29 | ban_ruou_bia | Điều 19 khoản 3 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C30 | ban_ruou_bia | Điều 19 khoản 3 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C31 | ban_ruou_bia | Điều 19 khoản 4 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C32 | ban_ruou_bia | Điều 19 khoản 5 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C33 | ban_ruou_bia | Điều 19 khoản 6 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C34 | ban_ruou_bia | Điều 19 khoản 6 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C35 | ban_ruou_bia | Điều 19 khoản 6 | noNormApplies | trong phạm vi (khoản đã mã hóa) |
| C36 | ban_ruou_bia | Điều 19 khoản 1 | forbidden | trong phạm vi (khoản đã mã hóa) |
| C37 | cung_cap_ruou_bia | Điều 19 (tiêu đề) | noNormApplies | trong phạm vi (khoản đã mã hóa) |

### Ca số (dải số)

20 ca, PASS 20. Không đạt: không có.

Giới hạn thang không có trong luật (giả định của người mã hóa):

- chưa đủ 18 tuổi: cận dưới 0 — assumed, not in the law (thang tuổi bắt đầu từ 0)
- từ đủ 18 tuổi trở lên: cận trên 150 — assumed, not in the law (giới hạn trên của thang tuổi)
- dưới 15 độ: cận dưới 0 — assumed, not in the law (thang độ cồn bắt đầu từ 0)
- từ 15 độ trở lên: cận trên 1000 — assumed, not in the law (giới hạn trên của thang độ cồn)

### So hai cách xác định phạm vi

Cách cũ (bảng ghi đè `keyOverride` + so chuỗi, nay chỉ để so sánh) và cách mới (theo tham chiếu `ClauseRef`) khác nhau ở: (không có).

## 6. Báo cáo này KHÔNG nói gì

- Không phải tư vấn pháp lý. Không nói hành vi nào là hợp pháp hay trái luật.
- Không được đối chiếu với luật: bản mã hóa chưa được kiểm chứng với văn bản luật, và không có ý nào trong báo cáo khẳng định điều đó. Chỉ người duyệt mới làm được việc đó.
- Không nói bản mã hóa đúng luật. Kernel chỉ kiểm chứng các định lý về mã hóa nháp ở mục 3; độ trung thực không được kiểm bằng máy.
- Ràng buộc toàn vẹn không được dùng: một xung đột được báo (nếu có) có thể nằm ở tình huống bất khả thi, và một kết quả nhất quán không nói gì về tình huống đó.
- Ngưỡng, dải số và bộ đọc chỉ được kiểm là phủ kín và nhất quán nội bộ; ý nghĩa của chúng (ví dụ «15 độ», «chưa đủ 18 tuổi») không được kiểm.
- Khái niệm mở («dành cho người chưa đủ 18 tuổi», «được phép kinh doanh») là tham số; hệ thống không quyết định chúng.
- Bản trích xuất văn bản chưa được so với văn bản in; bộ tách đoạn chưa được kiểm độc lập (chỉ kiểm nhất quán nội bộ và băm đầu vào).
- Không nói gì về các khoản chưa phân loại, ngoài mô-đun hay UNACCOUNTED ở mục 2, và không nói gì về các văn bản khác.
- noNormApplies và outOfScope không có nghĩa là hợp pháp hay đúng luật.

## 7. Nguồn gốc

- Đầu vào `data/extracted/44-2019-QH14.txt`: sha256 trong bộ tách `e0ca5a521ff91a604523bea006c082e38655855466f7bb2379414d36bf199752`; sha256 hiện tại của tệp `e0ca5a521ff91a604523bea006c082e38655855466f7bb2379414d36bf199752` (đọc nguyên byte); khớp: có.
- Đầu vào, sha256 khi đọc CRLF như LF: `46c2f4e0c00fce27ebd25df59528c1ed1128034e23ccfe61af0e4f9fda5b0f5a`.
- Bộ tách: segment.py 1.0; 655 dòng; stray_paragraphs = 2 (dòng thụt đầu dòng trong khoản/điểm; không phải số đoạn dẫn ở mục 2).
- Tệp mô-đun `LexProof/Laws/AlcoholSale.lean`: sha256 (CRLF như LF) `e90ad7fa767d1129c85573e9e75ebbb3535e385956029cc4b139277a095f19d8`; nguyên byte `a8fc28ad98e99bd2943bd25b901fa46bb9dfb61d69f4bfa4f49425945d04770d`.
- Tệp `LexProof/Laws/AlcoholSaleCases.lean`: sha256 (CRLF như LF) `806625d63738e466ff16893e1fbf711703f4d2785c595effdec750bb0110972a`.
- Tệp `LexProof/Laws/AlcoholSaleRefs.lean`: sha256 (CRLF như LF) `6691207abe77f49a4f1ec40828d5cce5281f66bdc2ebace1f6bf8897b709f399`.
- Tệp `LexProof/Laws/AlcoholSaleBands.lean`: sha256 (CRLF như LF) `bc16e69ac8ba559913ed69de25c819ae44ee04a98ba46f27bdf793be8b925e42`.
- Sổ phủ `docs/review/alcohol-coverage-ledger.md`: sha256 (CRLF như LF) `ed5ab66017e606526743a5f5f6ca85f342677bf0c994b6bb4cad48f3419cbbb6`.
- Toolchain: `leanprover/lean4:v4.35.0`; Lean (version 4.35.0, x86_64-w64-windows-gnu, commit eb6cafb7290e8bd5f2937522d8d804f58f02bafc, Release).
- `lake build LexProof`: xanh; kiểm toán axiom: 3118 khai báo, đều trong danh sách cho phép.
- Git: commit baaaa8f3f8db60849cf9d64711e50295528a412f; 4 tệp thay đổi chưa commit.
- Công cụ: report.py 1.0; Lean đọc `eval/report/Dump.lean` (sha256, CRLF như LF: `f898213db9eca226089a79cbeb4e809fed7aa510a5b05228fb16719983887a9f`).
- Phiếu ca thử `docs/review/sale-group-cases.md`: sha256 (CRLF như LF) `7a193f14749b1e57ec11bf16b730e824eb3d9dfa8f126397a5b0a7568d1c0755`; người duyệt ghi trong phiếu: Phong.
- sha256 mô-đun ghi trong phiếu khi duyệt (bằng tệp mô-đun hiện tại): `e90ad7fa767d1129c85573e9e75ebbb3535e385956029cc4b139277a095f19d8`.
- sha256 tệp ca thử `LexProof/Laws/AlcoholSaleCases.lean` ghi trong phiếu khi duyệt (bằng tệp hiện tại): `806625d63738e466ff16893e1fbf711703f4d2785c595effdec750bb0110972a`.
- Ngày tạo báo cáo: 2026-11-13
