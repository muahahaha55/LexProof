import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef
import LexProof.Laws.Article5
import LexProof.Laws.Article10
import LexProof.Laws.Article12
import LexProof.Laws.Article13
import LexProof.Laws.Article14
import LexProof.Laws.Article16
import LexProof.Laws.Article17
import LexProof.Laws.Article18
import LexProof.Laws.Article20
import LexProof.Laws.Article21
import LexProof.Laws.Article33
import LexProof.Laws.Article34
import LexProof.Laws.Article19
import LexProof.Laws.Article32
import LexProof.Laws.Article15

/-!
# Law44 — Điều 5, 10, 12, 13, 14, 16, 17, 18, 20, 21, 33, 34, 19, 32, 15 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article5.glossary-3.llm.json` (sha256 `6dcb9cd81986af00e279bc29706f86e3fafaa7cdb6edebd0cb9bec1f87891f46`), sheet `docs/review/duyet-ban-dich-dieu-5-lan-3.md` (sha256 `0e5db49635721a165d6f3eda371481588db3128e6ff40d2939f7ebb2c9472c02`), Vũ Đức Phong, 2026-11-21: accepted 19, rejected 0
  (sheet made on glossary sha256 `b8057e2d02f92c8d814c7cd15c7b3891d65ecc5f4a5c68857675ddc50c4ddc0c`; every term this translation uses has the same meaning in the
  current glossary, so the review carries over: see `changed_terms` in promote.py)
* `eval/translate/article10.glossary.llm.json` (sha256 `def1c42962edf074ffe3e503f8488d95b553555658babb211b00e518aaecf3a6`), sheet `docs/review/duyet-ban-dich-dieu-10.md` (sha256 `6ddbcd61c3850e350af7d8862a2f84d08256ce030f494b0afa0b4d6902e10499`), Vũ Đức Phong, 2026-11-23: accepted 6, rejected 0
  (sheet made on glossary sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`; every term this translation uses has the same meaning in the
  current glossary, so the review carries over: see `changed_terms` in promote.py)
* `eval/translate/article12.glossary.llm.json` (sha256 `c77afeeb4a0e7a40187daf64ce5fd91ef5e9592a7971c43a513d6d3704cf417e`), sheet `docs/review/duyet-ban-dich-dieu-12.md` (sha256 `cb8c857f354c7b7aeff4e714630e58d27b46a26f4923a552f5f6bef8d24bf0b3`), Vũ Đức Phong, 2026-11-23: accepted 9, rejected 0
  (sheet made on glossary sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`; every term this translation uses has the same meaning in the
  current glossary, so the review carries over: see `changed_terms` in promote.py)
* `eval/translate/article13.glossary.llm.json` (sha256 `cb543b4dec68babb7169e2c8f90189c9a7a14a502b2c97caeafc86995ff51ebf`), sheet `docs/review/duyet-ban-dich-dieu-13.md` (sha256 `9092a79cf9507b77477cf9361d466bb16d5de83a4f1c1b2154120618d47ba160`), Vũ Đức Phong, 2026-11-23: accepted 2, rejected 0
  (sheet made on glossary sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`; every term this translation uses has the same meaning in the
  current glossary, so the review carries over: see `changed_terms` in promote.py)
* `eval/translate/article14.glossary.llm.json` (sha256 `7c90e63b066614d3211f8cf5ce627f42117568a17f5da009de51d592b0748df4`), sheet `docs/review/duyet-ban-dich-dieu-14.md` (sha256 `a8457ff7f92522ff3c9ea9cf01d44ab1c01463c9a5c5f43655b7e490de30f0d0`), Vũ Đức Phong, 2026-11-23: accepted 1, rejected 0
  (sheet made on glossary sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`; every term this translation uses has the same meaning in the
  current glossary, so the review carries over: see `changed_terms` in promote.py)
* `eval/translate/article16.glossary.llm.json` (sha256 `77d47d0e74a5b7eea5ab3fc7c89696883a08f6d6d83ea004edcf2acd908da2a8`), sheet `docs/review/duyet-ban-dich-dieu-16.md` (sha256 `40e6d1149df4f119aa65e7c47d198839c92c33b0bc567ba53b20bfc2f664b13d`), Vũ Đức Phong, 2026-11-24: accepted 4, rejected 0
* `eval/translate/article17.glossary.llm.json` (sha256 `9403e9b68ea848941d040289451d43325f18466f06c6e108320bb01818f3740a`), sheet `docs/review/duyet-ban-dich-dieu-17.md` (sha256 `040005d7f974fb20ec7a2039c1c716e15d2ea9d191518d2e63fb8b05f18a3eb1`), Vũ Đức Phong, 2026-11-24: accepted 1, rejected 0
* `eval/translate/article18.glossary.llm.json` (sha256 `8202d1e53167433814df39e761a340cf13668063a996e43bb62fa73fe040c5d0`), sheet `docs/review/duyet-ban-dich-dieu-18.md` (sha256 `14cf9c145bb2a143f165ee37fe8494f31f4f25a8be4a15e50db485383b42f3b0`), Vũ Đức Phong, 2026-11-24: accepted 1, rejected 0
* `eval/translate/article20.glossary.llm.json` (sha256 `08836e1b84ca68b306733937202d833bb8d0ce1ce81569a74ace332edadf2758`), sheet `docs/review/duyet-ban-dich-dieu-20.md` (sha256 `36eeebbd99cf5631172ead8b3c9e9a83d469ad981020046f4a8a562c7869b5aa`), Vũ Đức Phong, 2026-11-24: accepted 1, rejected 0
* `eval/translate/article21.glossary.llm.json` (sha256 `ccf9b20701b2b5ca828c5a92e2e98cc1b72aee1f4da17ae3f6f9910cf944593e`), sheet `docs/review/duyet-ban-dich-dieu-21.md` (sha256 `771ba04d84e27ed55147978587a0196bbe95c8dd88c296ce514fa5d40ae7f5a9`), Vũ Đức Phong, 2026-11-24: accepted 2, rejected 0
* `eval/translate/article33.glossary.llm.json` (sha256 `d86cc2f22edb7f74ca62072ce15db450406eda791f3344f9d0f156aee057f2ff`), sheet `docs/review/duyet-ban-dich-dieu-33.md` (sha256 `fa1e373b6a8fa3f3e197a0dfd3af6f11b793c0e6253c4208275a1f2770d09058`), Vũ Đức Phong, 2026-11-24: accepted 6, rejected 0
* `eval/translate/article34.glossary.llm.json` (sha256 `4d56cccf85d041dae698eebfa5575d347432f045418976483d3de94c1671f3b1`), sheet `docs/review/duyet-ban-dich-dieu-34.md` (sha256 `81a74effebd614b8814cb6e22618094ea6294c1aa1f2898a72bebc7630694b08`), Vũ Đức Phong, 2026-11-24: accepted 3, rejected 0
* `eval/translate/article19.glossary.llm.json` (sha256 `35347eacb9bfcd366544cb140e34a6d850e93795e347b535d15f368e74011b96`), sheet `docs/review/duyet-ban-dich-dieu-19-lan-2.md` (sha256 `5a0ed1c381bac7ed6df8975fa653f9a710713256351d615b7075894e43226d2b`), Vũ Đức Phong, 2026-11-24: accepted 6, rejected 0
* `eval/translate/article32.glossary-2.llm.json` (sha256 `02c516f06d9c99377489ba238b5a51fce32b85b873f850e84af8e3ff267c8f51`), sheet `docs/review/duyet-ban-dich-dieu-32-lan-2.md` (sha256 `d5e6f853cb83b9ad0ddc3bcfff99bbfea6d458de1d11fb6571998c35828582e5`), Vũ Đức Phong, 2026-11-23: accepted 8, rejected 0
  (sheet made on glossary sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`; every term this translation uses has the same meaning in the
  current glossary, so the review carries over: see `changed_terms` in promote.py)
* `eval/translate/article15.llm.json` (sha256 `98241e1293cf2b9b317ffa8915791493b801fe6dae50e8ad69b07ac02545e902`), sheet `docs/review/duyet-ban-dich-dieu-15.md` (sha256 `131389487aa77d1f1a63304b79c5e78e861d4e5684948c36bb59d6ff8d06982d`), Vũ Đức Phong, 2026-11-20: accepted 4, rejected 0
* Sheets reviewed on several dates; `status` carries the latest one.

Assumptions accepted on the sheets:
* Điều 5: Ngày hiệu lực 2020-01-01 không có trong đoạn chữ được cung cấp; giá trị này lấy từ hiểu biết bên ngoài về Luật 44/2019/QH14, người duyệt cần đối chiếu với điều khoản hiệu lực.
* Điều 5: Tiêu đề Điều 5 «Các hành vi bị nghiêm cấm» được áp dụng cho mọi khoản, nên mọi norm có modality «prohibition» (quy tắc 7).
* Điều 5: Khoản 2: chủ thể bị cấm là chính người chưa đủ 18 tuổi uống rượu, bia; trách nhiệm của người bán, cung cấp được mã hóa riêng ở khoản 3.
* Điều 5: Khoản 3 là một lệnh cấm với ba động từ; tôi tách thành ba norm (5.3a–c) cùng nguồn «Điều 5 khoản 3», không chia nhánh, theo cách bảng thuật ngữ ghi nguồn cho ban_ruou_bia, cung_cap_ruou_bia và khuyen_mai_ruou_bia.
* Điều 5: Khoản 3: việc tặng rượu, bia làm quà khuyến mại cho người chưa đủ 18 tuổi đã thuộc cung_cap_ruou_bia (gồm cả cho không, tặng), nên tôi không thêm norm dùng dung_ruou_bia_lam_qua_khuyen_mai cho khoản này.
* Điều 5: Khoản 5: chữ «và» giữa «ngay trước, trong giờ làm việc, học tập» và «nghỉ giữa giờ» được đọc là «hoặc», vì một thời điểm uống không thể đồng thời ở cả ba khoảng thời gian; nếu đọc là «và» thì lệnh cấm không bao giờ áp dụng.
* Điều 5: Khoản 5: «ngay trước» là khái niệm mở nên dùng tham số ngay_truoc_gio_lam_viec_hoc_tap; định ngữ «trong các cơ quan, tổ chức» đã nằm trong atom nguoi_uong_thuoc_doi_tuong_dieu_5_khoan_5.
* Điều 5: Khoản 6: mọi nồng độ cồn lớn hơn không đều làm thỏa điều kiện, vì luật không nêu ngưỡng; áp dụng cho mọi loại phương tiện giao thông.
* Điều 5: Khoản 7 chỉ nói «rượu», không nói «rượu, bia», nên điều kiện có loai_do_uong = «rượu»; bia từ 15 độ trở lên (nếu có) không thuộc khoản 7.
* Điều 5: Khoản 8: «không chính xác, sai sự thật» được biểu diễn bằng một atom gộp thong_tin_khong_chinh_xac_sai_su_that của bảng thuật ngữ.
* Điều 5: Khoản 9 gồm hai lệnh cấm ngăn bằng dấu «;», mã hóa thành nhánh (i) (khuyến mại trong kinh doanh) và nhánh (ii) (dùng rượu, bia làm hàng khuyến mại).
* Điều 5: Khoản 10 là một lệnh cấm duy nhất (dấu «;» chỉ ngăn hai nhóm nguyên liệu cùng chịu động từ «Sử dụng ... để sản xuất, pha chế»), nên nguồn là cả khoản, không chia nhánh.
* Điều 5: Khoản 10: chữ «không bảo đảm chất lượng và không rõ nguồn gốc, xuất xứ» được đọc đúng chữ là «và» (phải có cả hai), vì cách đọc này vẫn có thể thỏa và khoản 12 dùng dấu phẩy cho cùng các tính chất, cho thấy cách soạn khác nhau; nếu người duyệt muốn đọc là «hoặc» thì chỉ cần đổi «and» thành «or».
* Điều 5: Khoản 11 nhánh (i): theo lý do của người duyệt khi bác co_giay_phep_hoac_dang_ky_kinh_doanh_ruou («thiếu một trong hai đã vi phạm»), tôi mã hóa vi phạm là thiếu giấy phép HOẶC thiếu đăng ký; chữ luật vẫn có thể được hiểu là chỉ cần hình thức mà loại hình kinh doanh đó phải có (cách hiểu đã bị bác), và tôi không dùng cách hiểu đó (quy tắc 15).
* Điều 5: Khoản 11 nhánh (i): yêu cầu «đăng ký» dùng co_dang_ky_kinh_doanh, vì người duyệt đã bác co_dang_ky_kinh_doanh_ruou với lý do trùng với mục này; lệnh cấm chỉ áp dụng cho rượu (loai_do_uong = «rượu»), không cho bia.
* Điều 5: Khoản 12 nhánh (i): các tính chất «giả, nhập lậu, không bảo đảm chất lượng, không rõ nguồn gốc, xuất xứ» được đọc là các lựa chọn thay thế (hoặc); ba động từ kinh doanh, tàng trữ, vận chuyển được tách thành ba norm cùng nguồn.
* Điều 5: Khoản 12 nhánh (ii) cấm bản thân hành vi nhập lậu rượu, bia, không kèm điều kiện; nhánh (i) cấm việc kinh doanh, tàng trữ, vận chuyển hàng đã nhập lậu.
* Điều 5: Không khoản nào của Điều 5 dẫn chiếu tới đơn vị khác trong luật này, nên mọi «references» đều rỗng; khoản 13 dẫn chiếu tới các luật khác nên được ghi ở «not_encoded».
* Điều 5: Điều 5 không có khoản nào liệt kê điều kiện theo điểm a, b, c, nên quy tắc 11 không áp dụng; không cần đề xuất thuật ngữ mới vì mọi khái niệm đều có trong bảng.
* Điều 10: Tiêu đề «Địa điểm không uống rượu, bia» được đọc là lệnh cấm uống rượu, bia tại các địa điểm ở khoản 1–7 (quy tắc 7), nên mọi norm có modality prohibition và act uong_ruou_bia.
* Điều 10: Lệnh cấm áp dụng cho bất kỳ người uống nào; Điều 10 không giới hạn chủ thể nên không có điều kiện về người uống.
* Điều 10: Các atom địa điểm của bảng (dia_diem_co_so_y_te, dia_diem_co_so_giao_duc, dia_diem_cham_soc_vui_choi, dia_diem_cai_nghien_giam_giu, dia_diem_bao_tro_xa_hoi, dia_diem_noi_lam_viec_co_quan, dia_diem_duoc_phep_kinh_doanh) có nguồn là Điều 19 nhưng cùng nghĩa với các địa điểm ở Điều 10, nên được dùng lại theo quy tắc 12.
* Điều 10: «Trong thời gian giảng dạy, học tập, làm việc» (khoản 2) và «trong thời gian làm việc» (khoản 6) được đọc là thời gian hoạt động của cơ sở hay cơ quan, không phải giờ của riêng người uống, nên không dùng trong_gio_lam_viec_hoc_tap mà đề xuất hai atom mới.
* Điều 10: Ở khoản 3, cụm «dành cho người chưa đủ 18 tuổi» được đọc là bổ nghĩa cho toàn bộ «cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí»; đây là khái niệm mở nên dùng tham số danh_cho_nguoi_chua_du_18.
* Điều 10: Ở khoản 6, «trừ địa điểm được phép kinh doanh rượu, bia» được mã hóa là ngoại lệ (quy tắc 8), không phải quyền được uống.
* Điều 10: Khoản 7 dẫn chiếu tới quy định của Chính phủ (văn bản khác), nên không ghi vào «references».
* Điều 10: Ngày hiệu lực 2020-01-01 không có trong đoạn chữ được cung cấp; giá trị này lấy từ hiểu biết bên ngoài về Luật 44/2019/QH14 và cần người duyệt kiểm tra.
* Điều 12: effective 2020-01-01 là ngày hiệu lực của Luật 44/2019/QH14, lấy ngoài đoạn chữ được cung cấp vì đoạn chữ không nêu ngày hiệu lực; người duyệt cần xác nhận.
* Điều 12: Tiêu đề Điều 12 («rượu, bia có độ cồn dưới 5,5 độ») được đọc là phạm vi áp dụng của mọi khoản, nên mỗi norm có thêm điều kiện do_con_nguong_5_5 = «dưới 5,5 độ»; tiêu đề không nêu tính chất cấm hay bắt buộc nên quy tắc 7 không dùng tới.
* Điều 12: Dùng lại do_con_nguong_5_5 (bảng ghi «độ cồn của rượu», nguồn Điều 15) cho cả rượu và bia vì miền giá trị và ngưỡng 5,5 độ giống hệt nhau; nếu người duyệt coi mục đó chỉ dành cho rượu thì cần một atom mới có cùng ngưỡng cho «rượu, bia».
* Điều 12: Câu dẫn khoản 2 («Quảng cáo không thể hiện các nội dung sau đây») và câu dẫn khoản 3 («Không thực hiện quảng cáo ... trong trường hợp sau đây») được đọc là lệnh cấm; mỗi điểm được mã hóa thành một norm cấm quang_cao_ruou_bia, chữ dẫn chiếu lấy từ điểm.
* Điều 12: Trong mỗi điểm a, b của khoản 2, các nội dung cách nhau bằng dấu «;» được đọc là các trường hợp thay thế nhau (or): chỉ cần một trường hợp là đủ để bị cấm.
* Điều 12: «nhằm khuyến khích uống rượu, bia» (khoản 2 điểm a) được mã hóa là atom tình huống, coi như thuộc tính có thể xác định của nội dung quảng cáo; ngược lại «hướng đến» và «dành cho» được mã hóa là tham số vì là khái niệm mở.
* Điều 12: Không dùng lại danh_cho_nguoi_chua_du_18 cho khoản 3 điểm a vì nhóm người ở đây rộng hơn (thêm học sinh, sinh viên, thanh niên, phụ nữ mang thai) và đối tượng được xét là sự kiện, phương tiện, sản phẩm chứ không phải địa điểm.
* Điều 12: Khoản 3 điểm c được tách thành hai nhánh: (i) báo nói, báo hình ngay trước, trong và ngay sau chương trình dành cho trẻ em; (ii) báo nói, báo hình trong khung 18 giờ đến 21 giờ. Chủ thể «báo nói, báo hình» được đọc là áp dụng cho cả hai nhánh.
* Điều 12: Mệnh đề «trừ ...» của khoản 3 điểm c được đọc là chỉ là ngoại lệ của nhánh (ii) (khung 18 giờ đến 21 giờ), vì nó đứng sau dấu «;» và gắn với phần khung giờ; đây là cách đọc không chắc chắn, người duyệt cần xác nhận.
* Điều 12: «trường hợp khác theo quy định của Chính phủ» (khoản 3 điểm c) dẫn chiếu tới văn bản khác; được biểu diễn bằng atom ngoại lệ thuoc_truong_hop_ngoai_le_khac_theo_quy_dinh_chinh_phu_khung_gio_18_21, còn nội dung của nó không được mã hóa.
* Điều 12: Ở khoản 3 điểm d, «dành cho người chưa đủ 18 tuổi» được đọc là chỉ bổ nghĩa cho «cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí», còn «cơ sở giáo dục» đứng riêng (giống cách bảng tách Điều 19 khoản 2 và khoản 3).
* Điều 12: Không dùng lại dia_diem_co_so_giao_duc, dia_diem_cham_soc_vui_choi, danh_cho_nguoi_chua_du_18 cho khoản 3 điểm d vì các mục đó mô tả nơi diễn ra hành vi, còn ở đây cơ sở là mốc để tính khoảng cách đặt phương tiện quảng cáo; vì vậy đề xuất các atom co_so_lan_can_*.
* Điều 12: Quy định cụ thể về kích thước, khoảng cách (khoản 3 điểm d), về nội dung cảnh báo (khoản 4) và về hệ thống chặn lọc (khoản 5) do Chính phủ quy định (khoản 6, văn bản khác); các atom tương ứng chỉ ghi việc đáp ứng hay vi phạm các quy định đó.
* Điều 12: Nghĩa vụ của khoản 4 và khoản 5 («phải có ...») được biểu diễn thành lệnh cấm quảng cáo khi không có cảnh báo hoặc không có hệ thống chặn lọc, kiểm soát tuổi; không biểu diễn thành obligation của act quang_cao_ruou_bia vì như vậy sẽ thành bắt buộc phải quảng cáo.
* Điều 12: Ở khoản 5, «hệ thống công nghệ chặn lọc, phần mềm kiểm soát tuổi của người truy cập» được gộp thành một yêu cầu duy nhất (atom co_he_thong_chan_loc_kiem_soat_tuoi_truy_cap); chữ luật không rõ cần cả hai hay chỉ cần một, người duyệt cần xác nhận.
* Điều 12: Act quang_cao_ruou_bia của bảng được dùng cho mọi norm vì Điều 12 điều chỉnh chính hành vi quảng cáo rượu, bia; không đề xuất act mới.
* Điều 13: Tính chất cấm của cả hai khoản lấy từ cụm «không quảng cáo trong trường hợp sau đây» của đoạn dẫn, vì các khoản 1 và 2 chỉ là phần nêu trường hợp.
* Điều 13: Phạm vi của đoạn dẫn được lặp lại trong condition của từng norm: rượu từ 5,5 độ đến dưới 15 độ, hoặc bia từ 5,5 độ trở lên.
* Điều 13: Với rượu, dùng do_con_nguong_5_5 «từ 5,5 độ trở lên» cùng do_con «dưới 15 độ» để biểu diễn «từ 5,5 độ đến dưới 15 độ».
* Điều 13: Mục do_con_nguong_5_5 của bảng được định nghĩa là «độ cồn của rượu» nên không dùng cho bia. Quy tắc 14 không cho mở rộng mục đó, vì vậy đề xuất do_con_bia_nguong_5_5 riêng cho bia.
* Điều 13: Với bia, điều luật không đặt giới hạn trên, nên không dùng do_con trong nhánh bia.
* Điều 13: Ở khoản 1, cụm «chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao» được biểu diễn bằng một atom bool duy nhất, không tách riêng từng lĩnh vực hay tách «chương trình» với «hoạt động».
* Điều 13: Chữ «trừ biển hiệu của cơ sở kinh doanh rượu, bia» ở khoản 2 được mã hóa là exception: nó làm lệnh cấm không áp dụng chứ không tạo ra quyền được phép quảng cáo.
* Điều 13: Biển hiệu của cơ sở kinh doanh được hiểu là một loại phương tiện quảng cáo ngoài trời, nên exception chỉ có tác dụng khi quang_cao_tren_phuong_tien_quang_cao_ngoai_troi đúng.
* Điều 13: Đoạn dẫn có dẫn chiếu tới Điều 12, nhưng chữ của chính khoản 1 và khoản 2 không dẫn chiếu tới đơn vị nào khác, nên «references» của hai norm để rỗng.
* Điều 13: Ngày hiệu lực 2020-01-01 không có trong đoạn văn được cung cấp mà lấy từ hiểu biết chung về Luật 44/2019/QH14; người duyệt cần đối chiếu lại.
* Điều 14: Điều 14 chỉ có một đoạn, không chia khoản, nên «source» của norm là «Điều 14»; không dùng «nhánh» vì đoạn này chỉ có một lệnh cấm (vế còn lại là nghĩa vụ dẫn chiếu).
* Điều 14: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 14: Không dùng cung_cap_ruou_bia vì mục đó rộng hơn (mọi việc cung cấp đồ uống, kể cả cho không) và gắn với Điều 5 khoản 3; nếu dùng nó thì lệnh cấm sẽ bị mở rộng ra mọi việc cung cấp của doanh nghiệp rượu, bia.
* Điều 14: Không dùng dung_ruou_bia_lam_qua_khuyen_mai vì tài trợ khác khuyến mại trong hoạt động kinh doanh.
* Điều 14: Coi «Tổ chức, cá nhân kinh doanh rượu, bia» là điều kiện về chủ thể (atom mới), vì bảng chỉ có kinh_doanh_ruou_bia ở dạng act, không có atom chủ thể.
* Điều 14: Chữ «thực hiện tài trợ» đã nằm trong act, nên không thêm làm điều kiện riêng.
* Điều 14: Tiêu đề «Quản lý việc tài trợ...» không nêu tính chất cấm, bắt buộc hay được phép, nên không áp dụng quy tắc 7; tính chất cấm lấy từ chữ «không được».
* Điều 14: Cụm «pháp luật có liên quan đến việc tài trợ» dẫn chiếu sang văn bản khác nên không ghi vào «references».
* Điều 16: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 16: Tiêu đề «Điều kiện bán rượu, bia theo hình thức thương mại điện tử» cho biết các khoản là điều kiện của việc bán; áp dụng quy tắc 7 và 11: bốn khoản là bốn điều kiện cùng phải đủ.
* Điều 16: Mỗi điều kiện được biểu diễn là một lệnh cấm bán rượu, bia theo hình thức thương mại điện tử khi thiếu điều kiện đó (điều kiện: bán qua thương mại điện tử và không đáp ứng điều kiện); không biểu diễn là nghĩa vụ phải bán, vì nghĩa vụ đó sai nghĩa.
* Điều 16: Không dùng quyền được phép: luật nêu điều kiện, không trao quyền bán nào ngoài các điều khác.
* Điều 16: Khoản 1 dẫn chiếu Điều 15 khoản 4, khoản 5 và Điều 18; nội dung các đơn vị đó không được lặp lại ở đây, chỉ có một atom «đáp ứng» và «references» ghi nơi dẫn chiếu.
* Điều 16: Khoản 2 dẫn chiếu pháp luật về thương mại điện tử (văn bản khác), nên là một atom bool không có nội dung điều kiện; không ghi vào «references».
* Điều 16: Khoản 3 dẫn chiếu quy định của Chính phủ (văn bản khác); nội dung biện pháp không được mã hóa, chỉ có atom bool «thực hiện biện pháp».
* Điều 16: Chữ «hình thức thanh toán không dùng tiền mặt» ở khoản 4 giữ nguyên là atom bool, không định nghĩa thêm.
* Điều 17: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 17: Nghĩa vụ «phải có bản kê khai» được biểu diễn là lệnh cấm sản xuất rượu thủ công khi hộ gia đình, cá nhân không nhằm mục đích kinh doanh mà chưa có bản kê khai; không biểu diễn là nghĩa vụ sản xuất.
* Điều 17: Act san_xuat_ruou_thu_cong trùng act của Điều 15 khoản 3; đây là cùng hành vi sản xuất, nên hai điều có thể gặp nhau trong cùng tình huống và người duyệt cần xem đây có phải xung đột thật hay chỉ do mức hạt của act.
* Điều 17: Dùng lại chu_the_la_ho_gia_dinh_ca_nhan và muc_dich_kinh_doanh của bảng; «không nhằm mục đích kinh doanh» là phủ định của muc_dich_kinh_doanh.
* Điều 17: Mẫu bản kê khai do Bộ trưởng Bộ Công Thương quy định (văn bản khác); chỉ có atom bool «có bản kê khai», không mã hóa nội dung mẫu.
* Điều 18: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 18: Điều 18 chỉ có một đoạn, không chia khoản, nên «source» là «Điều 18».
* Điều 18: Nghĩa vụ «phải bảo đảm» được biểu diễn là lệnh cấm kinh doanh khi rượu, bia không bảo đảm một trong ba yêu cầu (tiêu chuẩn, quy chuẩn kỹ thuật; chất lượng; an toàn thực phẩm), tức đủ cả ba mới được kinh doanh.
* Điều 18: Dùng lại ruou_bia_khong_bao_dam_chat_luong và ruou_bia_khong_bao_dam_an_toan_thuc_pham của bảng; chữ «chất lượng sản phẩm, hàng hóa» được coi là cùng nghĩa với «chất lượng».
* Điều 18: Cụm «theo quy định của pháp luật» dẫn chiếu văn bản khác nên không ghi vào «references».
* Điều 20: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 20: Khoản 2 áp dụng cho mọi tổ chức, cá nhân nên điều kiện là true; nghĩa vụ này không có điều kiện nào khác trong chữ luật.
* Điều 20: Act mới được đề xuất vì bảng không có hành vi phối hợp với cơ quan có thẩm quyền; cung_cap_thong_tin_hoat_dong_kinh_doanh_cho_co_quan là việc khác (theo yêu cầu, về hoạt động kinh doanh).
* Điều 21: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 21: Khoản 1 chỉ có một lệnh cấm; chữ «trước và trong khi» được gộp vào một atom bool («trước hoặc trong khi»), vì luật cấm cả hai thời điểm, mỗi thời điểm đủ để vi phạm.
* Điều 21: Act uong_ruou_bia trùng act của Điều 5 khoản 2 và khoản 5; đó đều là lệnh cấm nên không tạo xung đột phương thức, nhưng người duyệt cần xem việc dùng chung act có đúng ý hay không.
* Điều 21: Khoản 2 dùng điều kiện true vì chủ thể (người đứng đầu cơ sở kinh doanh vận tải, chủ phương tiện) không được mã hóa thành atom; ghi nhận đây là nghĩa vụ chung của nhóm chủ thể đó.
* Điều 21: «Chủ động thực hiện biện pháp» là một act nguyên khối, không mã hóa nội dung biện pháp.
* Điều 33: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 33: Tiêu đề «Trách nhiệm của người đứng đầu...» và chữ «có trách nhiệm» cho biết các khoản là nghĩa vụ (quy tắc 7).
* Điều 33: Chủ thể (người đứng đầu cơ quan, tổ chức; người quản lý địa điểm) không được mã hóa thành atom vì bảng thuật ngữ không có atom chủ thể loại này; điều kiện của phần lớn norm là true.
* Điều 33: Khoản 1 có hai nghĩa vụ ngăn bằng dấu chấm phẩy, tách thành nhánh (i) và (ii).
* Điều 33: Khoản 3 điểm a có hai nghĩa vụ ngăn bằng dấu chấm phẩy: nhắc nhở và từ chối dịch vụ, tách thành nhánh (i) và (ii); nghĩa vụ thứ hai có điều kiện «tiếp tục vi phạm sau khi đã được nhắc nhở».
* Điều 33: Nội dung Điều 10 và Điều 19 không lặp lại ở đây; «references» ghi nơi dẫn chiếu. Điều 24 chỉ có «vận động», «tuyên truyền» nên không mã hóa, norm 33.2 dẫn chiếu tới nó mà không dựng lại nội dung.
* Điều 33: Các nghĩa vụ ở đây là nghĩa vụ làm một việc (tổ chức, nhắc nhở, từ chối), không trùng hành vi nào của các điều cấm trong bảng, nên không tạo cặp phương thức khắc nhau.
* Điều 34: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 34: Tiêu đề «Trách nhiệm của gia đình...» cho biết các khoản là nghĩa vụ của gia đình (quy tắc 7).
* Điều 34: Chủ thể «gia đình» không được mã hóa thành atom; điều kiện là true.
* Điều 34: Khoản 1 chỉ mã hóa phần giáo dục, giám sát, nhắc nhở thành viên chưa đủ 18 tuổi (nhánh (i)); hai phần còn lại ở not_encoded.
* Điều 34: Các nghĩa vụ là làm một việc, không trùng hành vi của các điều cấm trong bảng, nên không tạo cặp phương thức khắc nhau.
* Điều 19: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 19: Tiêu đề «Địa điểm không bán rượu, bia» được áp dụng cho cả 6 khoản: mỗi khoản là một lệnh cấm bán rượu, bia tại địa điểm nêu (quy tắc 7); act dùng chung là ban_ruou_bia.
* Điều 19: Mỗi khoản là một norm; các loại địa điểm liệt kê trong cùng khoản đã được gộp trong một atom của bảng thuật ngữ (dia_diem_cai_nghien_giam_giu, dia_diem_noi_lam_viec_co_quan), không tách «nhánh».
* Điều 19: Khoản 3: «dành cho người chưa đủ 18 tuổi» là khái niệm mở nên dùng tham số danh_cho_nguoi_chua_du_18; đọc cụm này bổ nghĩa cho cả bốn loại (chăm sóc, nuôi dưỡng, vui chơi, giải trí), nên điều kiện là địa điểm và tham số.
* Điều 19: Khoản 6: «trừ địa điểm được phép kinh doanh rượu, bia» là ngoại lệ (exceptions), không phải quyền được phép; việc một địa điểm được phép kinh doanh do quy định khác xác định nên là atom dia_diem_duoc_phep_kinh_doanh, không suy ra giá trị; ngoại lệ áp dụng cho toàn bộ danh sách nơi làm việc trong khoản.
* Điều 19: Khác Điều 10 khoản 2, Điều 19 khoản 2 chỉ ghi «Cơ sở giáo dục», không có điều kiện về thời gian; norm 19.2 vì vậy không có điều kiện thời gian.
* Điều 19: Chỉ mã hóa hành vi «bán» theo tiêu đề điều; không mở rộng sang uống hay mang vào.
* Điều 32: Ngày hiệu lực 2020-01-01 không có trong đoạn chữ được cung cấp; giá trị này lấy theo điều khoản thi hành của Luật 44/2019/QH14 và cần đối chiếu lại.
* Điều 32: Theo quy tắc 7, tiêu đề «Trách nhiệm của cơ sở kinh doanh rượu, bia» làm các khoản mang tính nghĩa vụ (obligation); riêng khoản 3 («Không sử dụng») và khoản 7 («không được mở mới») mã hóa là prohibition, còn câu «có quyền» ở khoản 5 mã hóa là permission.
* Điều 32: Chủ thể của các khoản 2, 3, 4 là cơ sở kinh doanh rượu, bia (theo tiêu đề điều), nên điều kiện không có atom chủ thể; khoản 5 và khoản 6 tự thu hẹp chủ thể nên dùng atom co_so_ban_ruou_bia và co_so_ban_ruou_bia_tieu_dung_tai_cho.
* Điều 32: Khoản 5 và khoản 6 mỗi khoản có hai norm (không phải lệnh cấm), nhưng vẫn tách thành «nhánh (i)», «nhánh (ii)» để source chỉ đúng đơn vị được mã hóa.
* Điều 32: Khoản 3: act su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia của bảng không gồm «quảng cáo», nên đề xuất act mới; tuổi dùng atom có sẵn tuoi_nguoi_lao_dong với nhãn «chưa đủ 18 tuổi».
* Điều 32: Khoản 4: «không bảo đảm chất lượng, an toàn thực phẩm» được đọc là thiếu một trong hai (or); phần «chất lượng» dùng atom có sẵn ruou_bia_khong_bao_dam_chat_luong, phần an toàn thực phẩm là atom mới. Cụm «theo quy định của pháp luật về an toàn thực phẩm» dẫn chiếu văn bản khác, nên không ghi vào references.
* Điều 32: Khoản 5 nhánh (ii): «nghi ngờ» được coi là một tình huống thực tế về nhận thức của người bán (situation), không phải khái niệm mở cần tham số; người duyệt có thể đổi sang parameter.
* Điều 32: Khoản 6 nhánh (i): chữ «phù hợp» là chuẩn mở về cách thực hiện nghĩa vụ chứ không phải điều kiện để nghĩa vụ áp dụng, nên không đưa vào condition và không tự quyết; nó vẫn nằm trong gloss của act.
* Điều 32: Khoản 6: cụm «sau khi uống rượu, bia» được đọc là gắn cho cả hai nghĩa vụ (nhánh (i) và (ii)), theo ý kiến người duyệt (Phong, 2026-11-23) khi bác cách đọc trước, vốn chỉ gắn cụm đó vào nhánh (ii); vì vậy cả hai norm đều có điều kiện khach_hang_da_uong_ruou_bia.
* Điều 32: Khoản 7: «Kể từ ngày Luật này có hiệu lực» được hiểu là chỉ cấm việc mở mới sau ngày hiệu lực; điểm bán đã mở trước đó không bị điều này điều chỉnh. «Luật này» là cả văn bản, không phải một đơn vị điều khoản, nên không ghi vào references.
* Điều 32: Khoản 7: không dùng dia_diem_co_so_y_te và dia_diem_co_so_giao_duc vì hai atom đó nói địa điểm chính là cơ sở, còn khoản này nói khoảng cách 100 m tính từ khuôn viên; ngoài ra danh sách cơ sở giáo dục ở đây (nhà trẻ, mẫu giáo, mầm non, phổ thông) hẹp hơn «cơ sở giáo dục». Vì vậy đề xuất atom mới theo quy tắc 14.
* Điều 32: Không khoản nào của Điều 32 dẫn chiếu tới một điều khoản khác trong cùng Luật, nên mọi references đều rỗng.
* Điều 15: Ngày hiệu lực 2020-01-01 không có trong đoạn chữ được cung cấp; giá trị này lấy theo hiệu lực chung đã biết của Luật 44/2019/QH14, người duyệt cần đối chiếu lại.
* Điều 15: Tiêu đề «Quản lý kinh doanh rượu» không cho biết tính chất cấm, bắt buộc hay cho phép, nên không áp dụng một tính chất chung nào từ tiêu đề cho các khoản.
* Điều 15: Các khoản 1, 2, 4 («Điều kiện cấp phép ... bao gồm:») được biểu diễn là permission: chủ thể được cấp phép khi đáp ứng ĐỦ MỌI điểm (and); chiều ngược lại (thiếu một điểm thì không được cấp phép) không được mã hóa thành norm riêng.
* Điều 15: Khoản 3 không nhắc tới giấy phép; nó được biểu diễn là permission cho chính hoạt động sản xuất thủ công để bán cho cơ sở chế biến lại khi đủ các điểm a và b, không phải là quyền được cấp phép.
* Điều 15: Điểm a khoản 3 gồm hai yêu cầu nối bằng «và» (có hợp đồng mua bán; có đăng ký với UBND cấp xã), nên được tách thành hai atom S9 và S10 và cả hai đều bắt buộc.
* Điều 15: Điểm c khoản 1 được tách thành hai tham số P3 (an toàn thực phẩm) và P4 (bảo vệ môi trường); P3 được dùng lại cho điểm b khoản 2 và điểm b khoản 3 vì đó là cùng một khái niệm, dù «source» của P3 ghi điểm c khoản 1.
* Điều 15: S1 (độ cồn từ 5,5 độ trở lên) xuất hiện ở các khoản 1 đến 4 và được dùng chung một atom, «source» ghi khoản 1.
* Điều 15: Ngoại lệ ở khoản 2 («trừ trường hợp quy định tại khoản 3 Điều này») được hiểu là trường hợp hộ gia đình, cá nhân sản xuất rượu thủ công để bán cho cơ sở có giấy phép chế biến lại; trường hợp này loại khỏi phạm vi norm 15.2 chứ không phải là một quyền.
* Điều 15: Enum S6 chỉ liệt kê các loại chủ thể có tên trong Điều 15; nó không đầy đủ cho mọi chủ thể có thể có.
* Điều 15: Các cụm «được thành lập theo quy định của pháp luật» (điểm a khoản 1, điểm a khoản 2), «theo quy định của pháp luật» về an toàn thực phẩm và môi trường (điểm c khoản 1, điểm b khoản 2, điểm b khoản 3) và «Đăng ký kinh doanh theo quy định của pháp luật» (điểm a khoản 4) dẫn chiếu tới văn bản pháp luật khác, nên không ghi vào «references»; các điều kiện phụ thuộc văn bản khác được để là tham số P1, P3, P4.
* Điều 15: S11 (có đăng ký kinh doanh) được xem là một sự kiện kiểm tra được và đặt trong «situation»; phần «theo quy định của pháp luật» của nó không được mã hóa.
* Điều 15: «đáp ứng quy mô dự kiến sản xuất» (P2) và «trình độ, chuyên môn phù hợp» (P5) là khái niệm mở, nên được để là tham số và không tự quyết giá trị.
* Điều 15: «Đáp ứng điều kiện theo từng loại hình mua bán rượu» (điểm b khoản 4) không được Điều 15 định nghĩa, có thể do Chính phủ quy định theo khoản 5, nên được để là tham số P6.

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe`); an id shared by two articles is ONE atom:
* act ban_ruou_bia [approved]: bán rượu, bia (trao đổi có trả tiền) (nguồn: Điều 5 khoản 3; Điều 19 tiêu đề)
* act cung_cap_ruou_bia [approved]: cung cấp rượu, bia (gồm cả cho không, tặng — theo ý kiến người duyệt 2026-11-18, Q3) (nguồn: Điều 5 khoản 3)
* act khuyen_mai_ruou_bia [approved]: khuyến mại rượu, bia trong hoạt động kinh doanh (nguồn: Điều 5 khoản 3; Điều 5 khoản 9 nhánh (i))
* act dung_ruou_bia_lam_qua_khuyen_mai [approved]: dùng rượu, bia để khuyến mại dưới mọi hình thức (làm quà, hàng tặng) (nguồn: Điều 5 khoản 9 nhánh (ii))
* act ban_ruou_bia_bang_may_tu_dong [approved]: bán rượu, bia bằng máy bán hàng tự động (nguồn: Điều 5 khoản 11 nhánh (ii))
* act xui_giuc_ep_buoc_uong_ruou_bia [approved]: xúi giục, kích động, lôi kéo, ép buộc người khác uống rượu, bia (nguồn: Điều 5 khoản 1)
* act uong_ruou_bia [approved]: uống rượu, bia (nguồn: Điều 5 khoản 2; Điều 5 khoản 5)
* act su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia [approved]: sử dụng người lao động trực tiếp tham gia vào việc sản xuất, mua bán rượu, bia (nguồn: Điều 5 khoản 4)
* act dieu_khien_phuong_tien_giao_thong [approved]: điều khiển phương tiện giao thông (mọi loại) (nguồn: Điều 5 khoản 6)
* act quang_cao_ruou_bia [approved]: quảng cáo rượu, bia (nguồn: Điều 5 khoản 7)
* act cung_cap_thong_tin_ve_anh_huong_suc_khoe_cua_ruou_bia [approved]: cung cấp thông tin về ảnh hưởng của rượu, bia đối với sức khỏe (khác cung_cap_ruou_bia là cung cấp đồ uống) (nguồn: Điều 5 khoản 8)
* act su_dung_nguyen_lieu_san_xuat_pha_che_ruou_bia [approved]: sử dụng nguyên liệu, phụ gia, chất hỗ trợ chế biến để sản xuất, pha chế rượu, bia (nguồn: Điều 5 khoản 10)
* act kinh_doanh_ruou_bia [approved]: kinh doanh rượu, bia (nguồn: Điều 5 khoản 11 nhánh (i); Điều 5 khoản 12 nhánh (i))
* act tang_tru_ruou_bia [approved]: tàng trữ rượu, bia (nguồn: Điều 5 khoản 12 nhánh (i))
* act van_chuyen_ruou_bia [approved]: vận chuyển rượu, bia (nguồn: Điều 5 khoản 12 nhánh (i))
* act nhap_lau_ruou_bia [approved]: nhập lậu rượu, bia (bản thân hành vi đưa hàng vào trái phép) (nguồn: Điều 5 khoản 12 nhánh (ii))
* atom tuoi_nguoi_nhan [approved]: tuổi của người được bán, cung cấp hoặc khuyến mại rượu, bia (nguồn: Điều 5 khoản 3)
*   nhãn «từ đủ 18 tuổi trở lên» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 5 khoản 3». Ghi chú: không khoản nào nêu; là phần bù của «chưa đủ 18 tuổi» (Điều 5 khoản 3), giả định của người mã hóa
* atom do_con [approved]: độ cồn của rượu, bia (Điều 2 khoản 4 định nghĩa độ cồn) (nguồn: Điều 2 khoản 4; Điều 5 khoản 9)
*   nhãn «dưới 15 độ» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 2 khoản 4». Ghi chú: phần bù của «từ 15 độ trở lên» (Điều 5 khoản 9); Điều 11 có tiêu đề «có độ cồn dưới 15 độ». Chưa tách ngưỡng 5,5 độ của Điều 12, 13, 15
* atom tuoi_nguoi_uong [approved]: tuổi của người uống rượu, bia (nguồn: Điều 5 khoản 2)
*   nhãn «từ đủ 18 tuổi trở lên» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 5 khoản 2». Ghi chú: nhãn bù để miền đầy đủ; không khoản nào nêu trực tiếp
* atom tuoi_nguoi_lao_dong [approved]: tuổi của người lao động được sử dụng (nguồn: Điều 5 khoản 4)
*   nhãn «từ đủ 18 tuổi trở lên» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 5 khoản 4». Ghi chú: nhãn bù để miền đầy đủ; không khoản nào nêu trực tiếp
* atom nguoi_uong_thuoc_doi_tuong_dieu_5_khoan_5 [approved]: người uống là cán bộ, công chức, viên chức, người lao động trong các cơ quan, tổ chức, sĩ quan, hạ sĩ quan, quân nhân chuyên nghiệp, chiến sĩ, người làm việc trong lực lượng vũ trang nhân dân, học sinh hoặc sinh viên (nguồn: Điều 5 khoản 5)
* atom ngay_truoc_gio_lam_viec_hoc_tap [approved]: thời điểm uống là «ngay trước» giờ làm việc, học tập của người đó (khái niệm mở, luật không định lượng) (nguồn: Điều 5 khoản 5)
* atom trong_gio_lam_viec_hoc_tap [approved]: thời điểm uống nằm trong giờ làm việc, học tập của người đó (nguồn: Điều 5 khoản 5)
* atom nghi_giua_gio_lam_viec_hoc_tap [approved]: thời điểm uống là lúc nghỉ giữa giờ làm việc, học tập của người đó (nguồn: Điều 5 khoản 5)
* atom co_nong_do_con_trong_mau_hoac_hoi_tho [approved]: trong máu hoặc hơi thở của người điều khiển có nồng độ cồn (nguồn: Điều 5 khoản 6)
* atom loai_do_uong [approved]: đồ uống là rượu hay bia (nguồn: Điều 5 khoản 7; Điều 5 khoản 11 nhánh (i))
* atom thong_tin_khong_chinh_xac_sai_su_that [approved]: thông tin được cung cấp không chính xác, sai sự thật (nguồn: Điều 5 khoản 8)
* atom nguyen_lieu_khong_duoc_phep_dung_trong_thuc_pham [approved]: nguyên liệu, phụ gia, chất hỗ trợ chế biến được sử dụng là loại không được phép dùng trong thực phẩm (nguồn: Điều 5 khoản 10)
* atom nguyen_lieu_khong_bao_dam_chat_luong [approved]: nguyên liệu, phụ gia thực phẩm, chất hỗ trợ chế biến thực phẩm được sử dụng không bảo đảm chất lượng (nguồn: Điều 5 khoản 10)
* atom nguyen_lieu_khong_ro_nguon_goc_xuat_xu [approved]: nguyên liệu, phụ gia thực phẩm, chất hỗ trợ chế biến thực phẩm được sử dụng không rõ nguồn gốc, xuất xứ (nguồn: Điều 5 khoản 10)
* atom ruou_bia_gia [approved]: rượu, bia là hàng giả (nguồn: Điều 5 khoản 12 nhánh (i))
* atom ruou_bia_nhap_lau [approved]: rượu, bia là hàng nhập lậu (nguồn: Điều 5 khoản 12 nhánh (i))
* atom ruou_bia_khong_bao_dam_chat_luong [approved]: rượu, bia không bảo đảm chất lượng (nguồn: Điều 5 khoản 12 nhánh (i))
* atom ruou_bia_khong_ro_nguon_goc_xuat_xu [approved]: rượu, bia không rõ nguồn gốc, xuất xứ (nguồn: Điều 5 khoản 12 nhánh (i))
* atom co_dang_ky_kinh_doanh [approved]: đã đăng ký kinh doanh theo quy định của pháp luật (đăng ký kinh doanh chung, khác co_giay_phep_hoac_dang_ky_kinh_doanh_ruou) (nguồn: Điều 15 khoản 4 điểm a)
* atom co_giay_phep_kinh_doanh_ruou [approved]: người kinh doanh rượu có giấy phép (yêu cầu «có giấy phép» của Điều 5 khoản 11 nhánh (i), xét riêng, không gộp với việc đăng ký) (nguồn: Điều 5 khoản 11 nhánh (i))
* atom dia_diem_co_so_y_te [approved]: địa điểm là cơ sở y tế (nguồn: Điều 19 khoản 1)
* atom dia_diem_co_so_giao_duc [approved]: địa điểm là cơ sở giáo dục (nguồn: Điều 19 khoản 2)
* atom dia_diem_cham_soc_vui_choi [approved]: địa điểm là cơ sở hoặc khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí (nguồn: Điều 19 khoản 3)
* atom dia_diem_cai_nghien_giam_giu [approved]: địa điểm là cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân hoặc cơ sở giam giữ khác (nguồn: Điều 19 khoản 4)
* atom dia_diem_bao_tro_xa_hoi [approved]: địa điểm là cơ sở bảo trợ xã hội (nguồn: Điều 19 khoản 5)
* atom dia_diem_noi_lam_viec_co_quan [approved]: địa điểm là nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập (nguồn: Điều 19 khoản 6)
* atom dia_diem_duoc_phep_kinh_doanh [approved]: địa điểm được phép kinh doanh rượu, bia (ngoại lệ của Điều 19 khoản 6) (nguồn: Điều 19 khoản 6)
* atom danh_cho_nguoi_chua_du_18 [approved]: địa điểm «dành cho» người chưa đủ 18 tuổi (khái niệm mở, luật không định nghĩa) (nguồn: Điều 19 khoản 3)
* atom trong_thoi_gian_giang_day_hoc_tap_lam_viec_cua_co_so_giao_duc [approved]: thời điểm uống nằm trong thời gian giảng dạy, học tập, làm việc của cơ sở giáo dục (thời gian hoạt động của cơ sở, khác trong_gio_lam_viec_hoc_tap là giờ của riêng người uống) (nguồn: Điều 10 khoản 2)
* atom trong_thoi_gian_lam_viec_cua_co_quan_to_chuc [approved]: thời điểm uống nằm trong thời gian làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập có nơi làm việc đó (khác trong_gio_lam_viec_hoc_tap là giờ của riêng người uống) (nguồn: Điều 10 khoản 6)
* atom do_con_nguong_5_5 [approved]: độ cồn của rượu so với ngưỡng 5,5 độ (nguồn: Điều 15 khoản 1; Điều 15 khoản 5)
* atom noi_dung_khuyen_khich_uong_ruou_bia [approved]: quảng cáo có thông tin, hình ảnh nhằm khuyến khích uống rượu, bia (nguồn: Điều 12 khoản 2 điểm a)
* atom noi_dung_ruou_bia_tao_truong_thanh_thanh_dat_than_thien_hap_dan_gioi_tinh [approved]: quảng cáo có thông tin rằng rượu, bia có tác dụng tạo sự trưởng thành, thành đạt, thân thiện, hấp dẫn về giới tính (nguồn: Điều 12 khoản 2 điểm a)
* atom quang_cao_huong_den_tre_em_hssv_thanh_nien_phu_nu_mang_thai [approved]: quảng cáo «hướng đến» trẻ em, học sinh, sinh viên, thanh niên, phụ nữ mang thai (khái niệm mở, luật không định nghĩa) (nguồn: Điều 12 khoản 2 điểm a)
* atom su_dung_yeu_to_danh_cho_tre_em_hoc_sinh_sinh_vien [approved]: quảng cáo sử dụng vật dụng, hình ảnh, biểu tượng, âm nhạc, nhân vật trong phim, nhãn hiệu sản phẩm «dành cho» trẻ em, học sinh, sinh viên (khái niệm mở) (nguồn: Điều 12 khoản 2 điểm b)
* atom su_dung_nguoi_chua_du_18_hoac_hinh_anh_trong_quang_cao [approved]: quảng cáo sử dụng người chưa đủ 18 tuổi hoặc hình ảnh của người chưa đủ 18 tuổi (nguồn: Điều 12 khoản 2 điểm b)
* atom su_kien_phuong_tien_san_pham_danh_cho_nhom_dac_biet [approved]: sự kiện, phương tiện quảng cáo hoặc sản phẩm nơi quảng cáo được thực hiện là «dành cho» người chưa đủ 18 tuổi, học sinh, sinh viên, thanh niên, phụ nữ mang thai (khái niệm mở) (nguồn: Điều 12 khoản 3 điểm a)
* atom phuong_tien_quang_cao_la_phuong_tien_giao_thong [approved]: quảng cáo được thực hiện trên phương tiện giao thông (nguồn: Điều 12 khoản 3 điểm b)
* atom phuong_tien_quang_cao_la_bao_noi_bao_hinh [approved]: quảng cáo được thực hiện trên báo nói hoặc báo hình (nguồn: Điều 12 khoản 3 điểm c)
* atom ngay_truoc_trong_ngay_sau_chuong_trinh_danh_cho_tre_em [approved]: thời điểm phát quảng cáo là «ngay trước», trong hoặc «ngay sau» chương trình «dành cho» trẻ em (khái niệm mở, luật không định lượng) (nguồn: Điều 12 khoản 3 điểm c nhánh (i))
* atom trong_khung_gio_18_den_21_gio [approved]: thời điểm phát quảng cáo nằm trong khoảng từ 18 giờ đến 21 giờ trong ngày (nguồn: Điều 12 khoản 3 điểm c nhánh (ii))
* atom quang_cao_co_san_trong_chuong_trinh_the_thao_ban_quyen_tiep_song_truc_tiep_nuoc_ngoai [approved]: quảng cáo có sẵn trong chương trình thể thao mua bản quyền tiếp sóng trực tiếp từ nước ngoài (nguồn: Điều 12 khoản 3 điểm c nhánh (ii))
* atom thuoc_truong_hop_ngoai_le_khac_theo_quy_dinh_chinh_phu_khung_gio_18_21 [approved]: quảng cáo thuộc trường hợp ngoại lệ khác do Chính phủ quy định đối với khung giờ 18 giờ đến 21 giờ (nội dung do văn bản khác quy định) (nguồn: Điều 12 khoản 3 điểm c nhánh (ii))
* atom phuong_tien_quang_cao_ngoai_troi [approved]: quảng cáo được thực hiện trên phương tiện quảng cáo ngoài trời (nguồn: Điều 12 khoản 3 điểm d)
* atom vi_pham_kich_thuoc_khoang_cach_tu_khuon_vien_co_so_lan_can [approved]: phương tiện quảng cáo vi phạm quy định về kích thước, khoảng cách đặt tính từ khuôn viên của cơ sở lân cận đang xét (nội dung quy định do Chính phủ quy định) (nguồn: Điều 12 khoản 3 điểm d)
* atom co_so_lan_can_la_co_so_giao_duc [approved]: cơ sở lân cận dùng làm mốc tính khoảng cách là cơ sở giáo dục (khác dia_diem_co_so_giao_duc là nơi diễn ra hành vi) (nguồn: Điều 12 khoản 3 điểm d)
* atom co_so_lan_can_la_co_so_khu_vuc_cham_soc_vui_choi [approved]: cơ sở lân cận dùng làm mốc tính khoảng cách là cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí (khác dia_diem_cham_soc_vui_choi là nơi diễn ra hành vi) (nguồn: Điều 12 khoản 3 điểm d)
* atom co_so_lan_can_danh_cho_nguoi_chua_du_18 [approved]: cơ sở lân cận dùng làm mốc tính khoảng cách là «dành cho» người chưa đủ 18 tuổi (khái niệm mở; khác danh_cho_nguoi_chua_du_18 là địa điểm diễn ra hành vi) (nguồn: Điều 12 khoản 3 điểm d)
* atom quang_cao_co_canh_bao_tac_hai_ruou_bia [approved]: quảng cáo có cảnh báo để phòng, chống tác hại của rượu, bia (nguồn: Điều 12 khoản 4)
* atom quang_cao_tren_moi_truong_dien_tu [approved]: quảng cáo được thực hiện trên báo điện tử, trang thông tin điện tử, phương tiện điện tử, thiết bị đầu cuối hoặc thiết bị viễn thông khác (nguồn: Điều 12 khoản 5)
* atom co_he_thong_chan_loc_kiem_soat_tuoi_truy_cap [approved]: có hệ thống công nghệ chặn lọc, phần mềm kiểm soát tuổi của người truy cập để ngăn ngừa người chưa đủ 18 tuổi tiếp cận, truy cập, tìm kiếm thông tin về rượu, bia (nguồn: Điều 12 khoản 5)
* atom do_con_bia_nguong_5_5 [approved]: độ cồn của bia so với ngưỡng 5,5 độ (tương ứng với do_con_nguong_5_5 nhưng dành cho bia, vì mục đó chỉ nói về rượu) (nguồn: Điều 13)
*   nhãn «dưới 5,5 độ» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 13». Ghi chú: Điều 13 chỉ nêu bia «có độ cồn từ 5,5 độ trở lên»; nhãn này là phần bù để miền giá trị đầy đủ
* atom quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao [approved]: việc quảng cáo diễn ra trong các chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao (nguồn: Điều 13 khoản 1)
* atom quang_cao_tren_phuong_tien_quang_cao_ngoai_troi [approved]: việc quảng cáo được thực hiện trên phương tiện quảng cáo ngoài trời (nguồn: Điều 13 khoản 2)
* atom la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia [approved]: phương tiện quảng cáo là biển hiệu của cơ sở kinh doanh rượu, bia (nguồn: Điều 13 khoản 2)
* act tai_tro_bang_san_pham_ruou_bia [approved]: tài trợ bằng sản phẩm rượu, bia (dùng chính sản phẩm rượu, bia làm vật tài trợ); hẹp hơn cung_cap_ruou_bia và khác dung_ruou_bia_lam_qua_khuyen_mai vì đây là hoạt động tài trợ, không phải khuyến mại (nguồn: Điều 14)
* atom chu_the_la_to_chuc_ca_nhan_kinh_doanh_ruou_bia [approved]: chủ thể thực hiện tài trợ là tổ chức, cá nhân kinh doanh rượu, bia (nguồn: Điều 14)
* atom ban_theo_hinh_thuc_thuong_mai_dien_tu [approved]: việc bán rượu, bia được thực hiện theo hình thức thương mại điện tử (nguồn: Điều 16 tiêu đề)
* atom dap_ung_quy_dinh_dieu_15_khoan_4_5_va_dieu_18 [approved]: đáp ứng quy định tại khoản 4, khoản 5 Điều 15 và Điều 18 của Luật (nguồn: Điều 16 khoản 1)
* atom dap_ung_dieu_kien_phap_luat_thuong_mai_dien_tu [approved]: đáp ứng điều kiện theo quy định của pháp luật về thương mại điện tử (nội dung do văn bản khác quy định) (nguồn: Điều 16 khoản 2)
* atom thuc_hien_bien_phap_ngan_nguoi_chua_du_18_tiep_can_mua_ruou_bia [approved]: thực hiện biện pháp theo quy định của Chính phủ để ngăn người chưa đủ 18 tuổi tiếp cận, truy cập, tìm kiếm thông tin và mua rượu, bia (nội dung biện pháp do Chính phủ quy định) (nguồn: Điều 16 khoản 3)
* atom ap_dung_thanh_toan_khong_dung_tien_mat [approved]: áp dụng hình thức thanh toán không dùng tiền mặt (nguồn: Điều 16 khoản 4)
* act san_xuat_ruou_thu_cong [approved]: sản xuất rượu thủ công (bản thân hành vi sản xuất, không phải việc cấp phép) (nguồn: Điều 15 khoản 3)
* atom muc_dich_kinh_doanh [approved]: việc sản xuất rượu nhằm mục đích kinh doanh (nguồn: Điều 15 khoản 2)
* atom chu_the_la_ho_gia_dinh_ca_nhan [approved]: chủ thể sản xuất là hộ gia đình hoặc cá nhân (khác hộ kinh doanh) (nguồn: Điều 15 khoản 3)
* atom co_ban_ke_khai_gui_ubnd_cap_xa_ve_san_xuat_ruou_thu_cong [approved]: có bản kê khai gửi Ủy ban nhân dân cấp xã về lượng rượu được sản xuất, phạm vi sử dụng, cam kết bảo đảm an toàn thực phẩm và không bán rượu ra thị trường, theo mẫu do Bộ trưởng Bộ Công Thương quy định (nguồn: Điều 17 khoản 1)
* atom ruou_bia_khong_bao_dam_an_toan_thuc_pham [approved]: rượu, bia không bảo đảm an toàn thực phẩm (khác ruou_bia_khong_bao_dam_chat_luong) (nguồn: Điều 32 khoản 4)
* atom ruou_bia_khong_bao_dam_tieu_chuan_quy_chuan_ky_thuat [approved]: rượu, bia không bảo đảm tiêu chuẩn, quy chuẩn kỹ thuật (nội dung tiêu chuẩn do văn bản khác quy định) (nguồn: Điều 18)
* act phoi_hop_tham_gia_voi_co_quan_phong_chong_ruou_bia_gia_nhap_lau [approved]: phối hợp, tham gia với cơ quan có thẩm quyền trong phòng, chống rượu, bia giả, không bảo đảm chất lượng, an toàn thực phẩm và rượu, bia nhập lậu, không rõ nguồn gốc, xuất xứ (nguồn: Điều 20 khoản 2)
* act thuc_hien_bien_phap_phong_ngua_phat_hien_ngan_chan_nguoi_dieu_khien_phuong_tien_van_tai_uong_ruou_bia [approved]: chủ động thực hiện biện pháp phòng ngừa, phát hiện, ngăn chặn người điều khiển phương tiện vận tải uống rượu, bia ngay trước và trong khi tham gia giao thông (nguồn: Điều 21 khoản 2)
* atom uong_truoc_hoac_trong_khi_tham_gia_giao_thong_voi_tu_cach_nguoi_dieu_khien [approved]: người uống rượu, bia là người điều khiển phương tiện giao thông và việc uống diễn ra trước hoặc trong khi tham gia giao thông (nguồn: Điều 21 khoản 1)
* act to_chuc_thuc_hien_bien_phap_phong_chong_tac_hai_ruou_bia [approved]: tổ chức thực hiện các biện pháp phòng, chống tác hại của rượu, bia trong phạm vi nhiệm vụ, quyền hạn của người đứng đầu (nguồn: Điều 33 khoản 1)
* act to_chuc_thuc_hien_nghiem_quy_dinh_khong_uong_ruou_bia_trong_gio_lam_viec_tai_noi_lam_viec [approved]: tổ chức thực hiện nghiêm quy định không uống rượu, bia trong thời gian làm việc, tại nơi làm việc của cơ quan, tổ chức (nguồn: Điều 33 khoản 1)
* act tham_gia_hoat_dong_phong_chong_tac_hai_ruou_bia_tai_cong_dong_theo_dieu_24 [approved]: tham gia các hoạt động phòng, chống tác hại của rượu, bia tại cơ sở, cộng đồng quy định tại Điều 24 (nguồn: Điều 33 khoản 2)
* act nhac_nho_yeu_cau_cham_dut_vi_pham_dieu_10_va_19 [approved]: nhắc nhở, yêu cầu chấm dứt hành vi vi phạm quy định tại Điều 10 và Điều 19 tại địa điểm thuộc quyền quản lý (nguồn: Điều 33 khoản 3 điểm a)
* act tu_choi_cung_cap_dich_vu_cho_nguoi_tiep_tuc_vi_pham [approved]: từ chối cung cấp dịch vụ cho người tiếp tục vi phạm Điều 10, Điều 19 sau khi đã được nhắc nhở, yêu cầu (nguồn: Điều 33 khoản 3 điểm a)
* act to_chuc_huong_dan_kiem_tra_don_doc_khong_uong_khong_ban_ruou_bia_tai_dia_diem [approved]: tổ chức thực hiện, hướng dẫn, kiểm tra, đôn đốc mọi người thực hiện đúng quy định không được uống, không được bán rượu, bia tại địa điểm thuộc quyền quản lý, điều hành (nguồn: Điều 33 khoản 3 điểm b)
* atom co_hanh_vi_vi_pham_dieu_10_hoac_19_tai_dia_diem [approved]: tại địa điểm thuộc quyền quản lý đang có người vi phạm quy định tại Điều 10 hoặc Điều 19 (nguồn: Điều 33 khoản 3 điểm a)
* atom nguoi_vi_pham_tiep_tuc_vi_pham_sau_khi_duoc_nhac_nho_yeu_cau [approved]: người vi phạm Điều 10, Điều 19 tiếp tục vi phạm sau khi đã được nhắc nhở, yêu cầu chấm dứt (nguồn: Điều 33 khoản 3 điểm a)
* act giao_duc_giam_sat_nhac_nho_thanh_vien_chua_du_18_khong_uong_ruou_bia [approved]: giáo dục, giám sát, nhắc nhở thành viên gia đình chưa đủ 18 tuổi không uống rượu, bia (nguồn: Điều 34 khoản 1)
* act huong_dan_thanh_vien_gia_dinh_ky_nang_tu_choi_uong_ung_xu_nguoi_say_nghien [approved]: hướng dẫn các thành viên trong gia đình kỹ năng từ chối uống rượu, bia; kỹ năng nhận biết, ứng xử, xử trí khi gặp người say rượu, bia, người nghiện rượu, bia và thực hiện các biện pháp phòng, chống tác hại (nguồn: Điều 34 khoản 2)
* act gia_dinh_tham_gia_cung_co_quan_to_chuc_cong_dong_phong_chong_tac_hai_ruou_bia [approved]: gia đình tham gia với các cơ quan, tổ chức và cộng đồng thực hiện phòng, chống tác hại của rượu, bia (nguồn: Điều 34 khoản 3)
* act cung_cap_thong_tin_hoat_dong_kinh_doanh_cho_co_quan [approved]: cơ sở kinh doanh cung cấp thông tin đầy đủ, chính xác về hoạt động kinh doanh của mình cho cơ quan có thẩm quyền (khác cung_cap_thong_tin_ve_anh_huong_suc_khoe_cua_ruou_bia và cung_cap_ruou_bia) (nguồn: Điều 32 khoản 2)
* act su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia [approved]: sử dụng lao động trực tiếp tham gia vào việc kinh doanh, quảng cáo rượu, bia (rộng hơn su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia vì gồm cả quảng cáo) (nguồn: Điều 32 khoản 3)
* act thu_hoi_xu_ly_ruou_bia [approved]: thu hồi và xử lý rượu, bia (nguồn: Điều 32 khoản 4)
* act niem_yet_thong_bao_khong_ban_cho_nguoi_chua_du_18 [approved]: niêm yết thông báo không bán rượu, bia cho người chưa đủ 18 tuổi (nguồn: Điều 32 khoản 5 nhánh (i))
* act yeu_cau_nguoi_mua_xuat_trinh_giay_to_chung_minh_tuoi [approved]: người bán yêu cầu người mua rượu, bia xuất trình giấy tờ chứng minh độ tuổi (nguồn: Điều 32 khoản 5 nhánh (ii))
* act nhac_nho_thong_tin_khach_hang_khong_dieu_khien_phuong_tien [approved]: nhắc nhở và có hình thức thông tin phù hợp đối với khách hàng về việc không điều khiển phương tiện giao thông (nguồn: Điều 32 khoản 6 nhánh (i))
* act ho_tro_khach_hang_su_dung_phuong_tien_cong_cong [approved]: hỗ trợ khách hàng thuê, sử dụng phương tiện giao thông công cộng (nguồn: Điều 32 khoản 6 nhánh (ii))
* act mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho [approved]: mở mới điểm bán rượu, bia để tiêu dùng tại chỗ (nguồn: Điều 32 khoản 7)
* atom co_yeu_cau_cua_co_quan_co_tham_quyen [approved]: cơ quan có thẩm quyền đã yêu cầu cơ sở cung cấp thông tin về hoạt động kinh doanh (nguồn: Điều 32 khoản 2)
* atom ruou_bia_do_co_so_minh_san_xuat_mua_ban [approved]: rượu, bia do chính cơ sở sản xuất hoặc mua bán (nguồn: Điều 32 khoản 4)
* atom co_so_ban_ruou_bia [approved]: chủ thể là cơ sở bán rượu, bia (nguồn: Điều 32 khoản 5 nhánh (i))
* atom nghi_ngo_ve_do_tuoi_nguoi_mua [approved]: người bán nghi ngờ về độ tuổi của người mua rượu, bia (nguồn: Điều 32 khoản 5 nhánh (ii))
* atom co_so_ban_ruou_bia_tieu_dung_tai_cho [approved]: chủ thể là cơ sở bán rượu, bia để tiêu dùng tại chỗ (nguồn: Điều 32 khoản 6)
* atom khach_hang_da_uong_ruou_bia [approved]: khách hàng đã uống rượu, bia (thời điểm «sau khi uống rượu, bia») (nguồn: Điều 32 khoản 6 nhánh (ii))
* atom mo_moi_ke_tu_ngay_luat_co_hieu_luc [approved]: việc mở mới điểm bán diễn ra kể từ ngày Luật này có hiệu lực (nguồn: Điều 32 khoản 7)
* atom trong_ban_kinh_100m_tu_khuon_vien_co_so_y_te [approved]: điểm bán nằm trong bán kính 100 m tính từ khuôn viên của cơ sở y tế (khác dia_diem_co_so_y_te là địa điểm chính là cơ sở y tế) (nguồn: Điều 32 khoản 7)
* atom trong_ban_kinh_100m_tu_khuon_vien_co_so_mam_non_pho_thong [approved]: điểm bán nằm trong bán kính 100 m tính từ khuôn viên của nhà trẻ, trường mẫu giáo, trường mầm non hoặc cơ sở giáo dục phổ thông (hẹp hơn dia_diem_co_so_giao_duc và đo theo khoảng cách) (nguồn: Điều 32 khoản 7)
-/

namespace LexProof.Laws.Law44

open LexProof

def tS : AtomTable :=
  [ { name := "tuoi_nguoi_nhan", source := "Điều 5 khoản 3", domain := .enum [⟨"chưa đủ 18 tuổi", "Điều 5 khoản 3"⟩, ⟨"từ đủ 18 tuổi trở lên", "Điều 5 khoản 3"⟩] }
  , { name := "do_con", source := "Điều 2 khoản 4", domain := .enum [⟨"dưới 15 độ", "Điều 2 khoản 4"⟩, ⟨"từ 15 độ trở lên", "Điều 5 khoản 9"⟩] }
  , { name := "tuoi_nguoi_uong", source := "Điều 5 khoản 2", domain := .enum [⟨"chưa đủ 18 tuổi", "Điều 5 khoản 2"⟩, ⟨"từ đủ 18 tuổi trở lên", "Điều 5 khoản 2"⟩] }
  , { name := "tuoi_nguoi_lao_dong", source := "Điều 5 khoản 4", domain := .enum [⟨"chưa đủ 18 tuổi", "Điều 5 khoản 4"⟩, ⟨"từ đủ 18 tuổi trở lên", "Điều 5 khoản 4"⟩] }
  , { name := "nguoi_uong_thuoc_doi_tuong_dieu_5_khoan_5", source := "Điều 5 khoản 5", domain := .bool }
  , { name := "trong_gio_lam_viec_hoc_tap", source := "Điều 5 khoản 5", domain := .bool }
  , { name := "nghi_giua_gio_lam_viec_hoc_tap", source := "Điều 5 khoản 5", domain := .bool }
  , { name := "co_nong_do_con_trong_mau_hoac_hoi_tho", source := "Điều 5 khoản 6", domain := .bool }
  , { name := "loai_do_uong", source := "Điều 5 khoản 7", domain := .enum [⟨"rượu", "Điều 5 khoản 7"⟩, ⟨"bia", "Điều 5 khoản 12 nhánh (ii)"⟩] }
  , { name := "thong_tin_khong_chinh_xac_sai_su_that", source := "Điều 5 khoản 8", domain := .bool }
  , { name := "nguyen_lieu_khong_duoc_phep_dung_trong_thuc_pham", source := "Điều 5 khoản 10", domain := .bool }
  , { name := "nguyen_lieu_khong_bao_dam_chat_luong", source := "Điều 5 khoản 10", domain := .bool }
  , { name := "nguyen_lieu_khong_ro_nguon_goc_xuat_xu", source := "Điều 5 khoản 10", domain := .bool }
  , { name := "ruou_bia_gia", source := "Điều 5 khoản 12 nhánh (i)", domain := .bool }
  , { name := "ruou_bia_nhap_lau", source := "Điều 5 khoản 12 nhánh (i)", domain := .bool }
  , { name := "ruou_bia_khong_bao_dam_chat_luong", source := "Điều 5 khoản 12 nhánh (i)", domain := .bool }
  , { name := "ruou_bia_khong_ro_nguon_goc_xuat_xu", source := "Điều 5 khoản 12 nhánh (i)", domain := .bool }
  , { name := "co_dang_ky_kinh_doanh", source := "Điều 15 khoản 4 điểm a", domain := .bool }
  , { name := "co_giay_phep_kinh_doanh_ruou", source := "Điều 5 khoản 11 nhánh (i)", domain := .bool }
  , { name := "dia_diem_co_so_y_te", source := "Điều 19 khoản 1", domain := .bool }
  , { name := "dia_diem_co_so_giao_duc", source := "Điều 19 khoản 2", domain := .bool }
  , { name := "dia_diem_cham_soc_vui_choi", source := "Điều 19 khoản 3", domain := .bool }
  , { name := "dia_diem_cai_nghien_giam_giu", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "dia_diem_bao_tro_xa_hoi", source := "Điều 19 khoản 5", domain := .bool }
  , { name := "dia_diem_noi_lam_viec_co_quan", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "dia_diem_duoc_phep_kinh_doanh", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "trong_thoi_gian_giang_day_hoc_tap_lam_viec_cua_co_so_giao_duc", source := "Điều 10 khoản 2", domain := .bool }
  , { name := "trong_thoi_gian_lam_viec_cua_co_quan_to_chuc", source := "Điều 10 khoản 6", domain := .bool }
  , { name := "do_con_nguong_5_5", source := "Điều 15 khoản 1", domain := .enum [⟨"dưới 5,5 độ", "Điều 15 khoản 5"⟩, ⟨"từ 5,5 độ trở lên", "Điều 15 khoản 1"⟩] }
  , { name := "noi_dung_khuyen_khich_uong_ruou_bia", source := "Điều 12 khoản 2 điểm a", domain := .bool }
  , { name := "noi_dung_ruou_bia_tao_truong_thanh_thanh_dat_than_thien_hap_dan_gioi_tinh", source := "Điều 12 khoản 2 điểm a", domain := .bool }
  , { name := "su_dung_nguoi_chua_du_18_hoac_hinh_anh_trong_quang_cao", source := "Điều 12 khoản 2 điểm b", domain := .bool }
  , { name := "phuong_tien_quang_cao_la_phuong_tien_giao_thong", source := "Điều 12 khoản 3 điểm b", domain := .bool }
  , { name := "phuong_tien_quang_cao_la_bao_noi_bao_hinh", source := "Điều 12 khoản 3 điểm c", domain := .bool }
  , { name := "trong_khung_gio_18_den_21_gio", source := "Điều 12 khoản 3 điểm c nhánh (ii)", domain := .bool }
  , { name := "quang_cao_co_san_trong_chuong_trinh_the_thao_ban_quyen_tiep_song_truc_tiep_nuoc_ngoai", source := "Điều 12 khoản 3 điểm c nhánh (ii)", domain := .bool }
  , { name := "thuoc_truong_hop_ngoai_le_khac_theo_quy_dinh_chinh_phu_khung_gio_18_21", source := "Điều 12 khoản 3 điểm c nhánh (ii)", domain := .bool }
  , { name := "phuong_tien_quang_cao_ngoai_troi", source := "Điều 12 khoản 3 điểm d", domain := .bool }
  , { name := "vi_pham_kich_thuoc_khoang_cach_tu_khuon_vien_co_so_lan_can", source := "Điều 12 khoản 3 điểm d", domain := .bool }
  , { name := "co_so_lan_can_la_co_so_giao_duc", source := "Điều 12 khoản 3 điểm d", domain := .bool }
  , { name := "co_so_lan_can_la_co_so_khu_vuc_cham_soc_vui_choi", source := "Điều 12 khoản 3 điểm d", domain := .bool }
  , { name := "quang_cao_co_canh_bao_tac_hai_ruou_bia", source := "Điều 12 khoản 4", domain := .bool }
  , { name := "quang_cao_tren_moi_truong_dien_tu", source := "Điều 12 khoản 5", domain := .bool }
  , { name := "co_he_thong_chan_loc_kiem_soat_tuoi_truy_cap", source := "Điều 12 khoản 5", domain := .bool }
  , { name := "do_con_bia_nguong_5_5", source := "Điều 13", domain := .enum [⟨"dưới 5,5 độ", "Điều 13"⟩, ⟨"từ 5,5 độ trở lên", "Điều 13"⟩] }
  , { name := "quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao", source := "Điều 13 khoản 1", domain := .bool }
  , { name := "quang_cao_tren_phuong_tien_quang_cao_ngoai_troi", source := "Điều 13 khoản 2", domain := .bool }
  , { name := "la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia", source := "Điều 13 khoản 2", domain := .bool }
  , { name := "chu_the_la_to_chuc_ca_nhan_kinh_doanh_ruou_bia", source := "Điều 14", domain := .bool }
  , { name := "ban_theo_hinh_thuc_thuong_mai_dien_tu", source := "Điều 16 tiêu đề", domain := .bool }
  , { name := "dap_ung_quy_dinh_dieu_15_khoan_4_5_va_dieu_18", source := "Điều 16 khoản 1", domain := .bool }
  , { name := "dap_ung_dieu_kien_phap_luat_thuong_mai_dien_tu", source := "Điều 16 khoản 2", domain := .bool }
  , { name := "thuc_hien_bien_phap_ngan_nguoi_chua_du_18_tiep_can_mua_ruou_bia", source := "Điều 16 khoản 3", domain := .bool }
  , { name := "ap_dung_thanh_toan_khong_dung_tien_mat", source := "Điều 16 khoản 4", domain := .bool }
  , { name := "muc_dich_kinh_doanh", source := "Điều 15 khoản 2", domain := .bool }
  , { name := "chu_the_la_ho_gia_dinh_ca_nhan", source := "Điều 15 khoản 3", domain := .bool }
  , { name := "co_ban_ke_khai_gui_ubnd_cap_xa_ve_san_xuat_ruou_thu_cong", source := "Điều 17 khoản 1", domain := .bool }
  , { name := "ruou_bia_khong_bao_dam_an_toan_thuc_pham", source := "Điều 32 khoản 4", domain := .bool }
  , { name := "ruou_bia_khong_bao_dam_tieu_chuan_quy_chuan_ky_thuat", source := "Điều 18", domain := .bool }
  , { name := "uong_truoc_hoac_trong_khi_tham_gia_giao_thong_voi_tu_cach_nguoi_dieu_khien", source := "Điều 21 khoản 1", domain := .bool }
  , { name := "co_hanh_vi_vi_pham_dieu_10_hoac_19_tai_dia_diem", source := "Điều 33 khoản 3 điểm a", domain := .bool }
  , { name := "nguoi_vi_pham_tiep_tuc_vi_pham_sau_khi_duoc_nhac_nho_yeu_cau", source := "Điều 33 khoản 3 điểm a", domain := .bool }
  , { name := "co_yeu_cau_cua_co_quan_co_tham_quyen", source := "Điều 32 khoản 2", domain := .bool }
  , { name := "ruou_bia_do_co_so_minh_san_xuat_mua_ban", source := "Điều 32 khoản 4", domain := .bool }
  , { name := "co_so_ban_ruou_bia", source := "Điều 32 khoản 5 nhánh (i)", domain := .bool }
  , { name := "nghi_ngo_ve_do_tuoi_nguoi_mua", source := "Điều 32 khoản 5 nhánh (ii)", domain := .bool }
  , { name := "co_so_ban_ruou_bia_tieu_dung_tai_cho", source := "Điều 32 khoản 6", domain := .bool }
  , { name := "khach_hang_da_uong_ruou_bia", source := "Điều 32 khoản 6 nhánh (ii)", domain := .bool }
  , { name := "mo_moi_ke_tu_ngay_luat_co_hieu_luc", source := "Điều 32 khoản 7", domain := .bool }
  , { name := "trong_ban_kinh_100m_tu_khuon_vien_co_so_y_te", source := "Điều 32 khoản 7", domain := .bool }
  , { name := "trong_ban_kinh_100m_tu_khuon_vien_co_so_mam_non_pho_thong", source := "Điều 32 khoản 7", domain := .bool }
  , { name := "Điều 15 · S1 do_con_tu_5_5_do_tro_len", source := "Điều 15 khoản 1", domain := .bool }
  , { name := "Điều 15 · S2 san_xuat_ruou_cong_nghiep", source := "Điều 15 khoản 1", domain := .bool }
  , { name := "Điều 15 · S3 san_xuat_ruou_thu_cong_nham_muc_dich_kinh_doanh", source := "Điều 15 khoản 2", domain := .bool }
  , { name := "Điều 15 · S4 san_xuat_ruou_thu_cong_ban_cho_co_so_co_giay_phep_de_che_bien_lai", source := "Điều 15 khoản 3", domain := .bool }
  , { name := "Điều 15 · S5 mua_ban_ruou", source := "Điều 15 khoản 4", domain := .bool }
  , { name := "Điều 15 · S6 loai_chu_the", source := "Điều 15 khoản 2 điểm a", domain := .enum [⟨"doanh_nghiep", "Điều 15 khoản 1 điểm a"⟩, ⟨"hop_tac_xa", "Điều 15 khoản 2 điểm a"⟩, ⟨"lien_hiep_hop_tac_xa", "Điều 15 khoản 2 điểm a"⟩, ⟨"ho_kinh_doanh", "Điều 15 khoản 2 điểm a"⟩, ⟨"ho_gia_dinh", "Điều 15 khoản 3"⟩, ⟨"ca_nhan", "Điều 15 khoản 3"⟩] }
  , { name := "Điều 15 · S7 co_day_chuyen_may_moc_thiet_bi_quy_trinh_cong_nghe", source := "Điều 15 khoản 1 điểm b", domain := .bool }
  , { name := "Điều 15 · S8 co_nhan_vien_ky_thuat", source := "Điều 15 khoản 1 điểm d", domain := .bool }
  , { name := "Điều 15 · S9 co_hop_dong_mua_ban_voi_co_so_co_giay_phep_san_xuat_ruou", source := "Điều 15 khoản 3 điểm a", domain := .bool }
  , { name := "Điều 15 · S10 co_dang_ky_voi_ubnd_cap_xa_noi_co_co_so_san_xuat", source := "Điều 15 khoản 3 điểm a", domain := .bool }
  , { name := "Điều 15 · S11 co_dang_ky_kinh_doanh", source := "Điều 15 khoản 4 điểm a", domain := .bool } ]

def tP : AtomTable :=
  [ { name := "ngay_truoc_gio_lam_viec_hoc_tap", source := "Điều 5 khoản 5", domain := .bool }
  , { name := "danh_cho_nguoi_chua_du_18", source := "Điều 19 khoản 3", domain := .bool }
  , { name := "quang_cao_huong_den_tre_em_hssv_thanh_nien_phu_nu_mang_thai", source := "Điều 12 khoản 2 điểm a", domain := .bool }
  , { name := "su_dung_yeu_to_danh_cho_tre_em_hoc_sinh_sinh_vien", source := "Điều 12 khoản 2 điểm b", domain := .bool }
  , { name := "su_kien_phuong_tien_san_pham_danh_cho_nhom_dac_biet", source := "Điều 12 khoản 3 điểm a", domain := .bool }
  , { name := "ngay_truoc_trong_ngay_sau_chuong_trinh_danh_cho_tre_em", source := "Điều 12 khoản 3 điểm c nhánh (i)", domain := .bool }
  , { name := "co_so_lan_can_danh_cho_nguoi_chua_du_18", source := "Điều 12 khoản 3 điểm d", domain := .bool }
  , { name := "Điều 15 · P1 duoc_thanh_lap_theo_quy_dinh_phap_luat", source := "Điều 15 khoản 1 điểm a", domain := .bool }
  , { name := "Điều 15 · P2 day_chuyen_dap_ung_quy_mo_du_kien_san_xuat", source := "Điều 15 khoản 1 điểm b", domain := .bool }
  , { name := "Điều 15 · P3 bao_dam_dieu_kien_an_toan_thuc_pham", source := "Điều 15 khoản 1 điểm c", domain := .bool }
  , { name := "Điều 15 · P4 bao_dam_dieu_kien_bao_ve_moi_truong", source := "Điều 15 khoản 1 điểm c", domain := .bool }
  , { name := "Điều 15 · P5 trinh_do_chuyen_mon_phu_hop_nganh_nghe_san_xuat_ruou", source := "Điều 15 khoản 1 điểm d", domain := .bool }
  , { name := "Điều 15 · P6 dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou", source := "Điều 15 khoản 4 điểm b", domain := .bool } ]

def rS : List ReaderSpec :=
  [ ("tuoi_nguoi_nhan = chưa đủ 18 tuổi", 0, 0)
  , ("tuoi_nguoi_nhan = từ đủ 18 tuổi trở lên", 0, 1)
  , ("do_con = dưới 15 độ", 1, 0)
  , ("do_con = từ 15 độ trở lên", 1, 1)
  , ("tuoi_nguoi_uong = chưa đủ 18 tuổi", 2, 0)
  , ("tuoi_nguoi_uong = từ đủ 18 tuổi trở lên", 2, 1)
  , ("tuoi_nguoi_lao_dong = chưa đủ 18 tuổi", 3, 0)
  , ("tuoi_nguoi_lao_dong = từ đủ 18 tuổi trở lên", 3, 1)
  , ("nguoi_uong_thuoc_doi_tuong_dieu_5_khoan_5", 4, 1)
  , ("trong_gio_lam_viec_hoc_tap", 5, 1)
  , ("nghi_giua_gio_lam_viec_hoc_tap", 6, 1)
  , ("co_nong_do_con_trong_mau_hoac_hoi_tho", 7, 1)
  , ("loai_do_uong = rượu", 8, 0)
  , ("loai_do_uong = bia", 8, 1)
  , ("thong_tin_khong_chinh_xac_sai_su_that", 9, 1)
  , ("nguyen_lieu_khong_duoc_phep_dung_trong_thuc_pham", 10, 1)
  , ("nguyen_lieu_khong_bao_dam_chat_luong", 11, 1)
  , ("nguyen_lieu_khong_ro_nguon_goc_xuat_xu", 12, 1)
  , ("ruou_bia_gia", 13, 1)
  , ("ruou_bia_nhap_lau", 14, 1)
  , ("ruou_bia_khong_bao_dam_chat_luong", 15, 1)
  , ("ruou_bia_khong_ro_nguon_goc_xuat_xu", 16, 1)
  , ("co_dang_ky_kinh_doanh", 17, 1)
  , ("co_giay_phep_kinh_doanh_ruou", 18, 1)
  , ("dia_diem_co_so_y_te", 19, 1)
  , ("dia_diem_co_so_giao_duc", 20, 1)
  , ("dia_diem_cham_soc_vui_choi", 21, 1)
  , ("dia_diem_cai_nghien_giam_giu", 22, 1)
  , ("dia_diem_bao_tro_xa_hoi", 23, 1)
  , ("dia_diem_noi_lam_viec_co_quan", 24, 1)
  , ("dia_diem_duoc_phep_kinh_doanh", 25, 1)
  , ("trong_thoi_gian_giang_day_hoc_tap_lam_viec_cua_co_so_giao_duc", 26, 1)
  , ("trong_thoi_gian_lam_viec_cua_co_quan_to_chuc", 27, 1)
  , ("do_con_nguong_5_5 = dưới 5,5 độ", 28, 0)
  , ("do_con_nguong_5_5 = từ 5,5 độ trở lên", 28, 1)
  , ("noi_dung_khuyen_khich_uong_ruou_bia", 29, 1)
  , ("noi_dung_ruou_bia_tao_truong_thanh_thanh_dat_than_thien_hap_dan_gioi_tinh", 30, 1)
  , ("su_dung_nguoi_chua_du_18_hoac_hinh_anh_trong_quang_cao", 31, 1)
  , ("phuong_tien_quang_cao_la_phuong_tien_giao_thong", 32, 1)
  , ("phuong_tien_quang_cao_la_bao_noi_bao_hinh", 33, 1)
  , ("trong_khung_gio_18_den_21_gio", 34, 1)
  , ("quang_cao_co_san_trong_chuong_trinh_the_thao_ban_quyen_tiep_song_truc_tiep_nuoc_ngoai", 35, 1)
  , ("thuoc_truong_hop_ngoai_le_khac_theo_quy_dinh_chinh_phu_khung_gio_18_21", 36, 1)
  , ("phuong_tien_quang_cao_ngoai_troi", 37, 1)
  , ("vi_pham_kich_thuoc_khoang_cach_tu_khuon_vien_co_so_lan_can", 38, 1)
  , ("co_so_lan_can_la_co_so_giao_duc", 39, 1)
  , ("co_so_lan_can_la_co_so_khu_vuc_cham_soc_vui_choi", 40, 1)
  , ("quang_cao_co_canh_bao_tac_hai_ruou_bia", 41, 1)
  , ("quang_cao_tren_moi_truong_dien_tu", 42, 1)
  , ("co_he_thong_chan_loc_kiem_soat_tuoi_truy_cap", 43, 1)
  , ("do_con_bia_nguong_5_5 = dưới 5,5 độ", 44, 0)
  , ("do_con_bia_nguong_5_5 = từ 5,5 độ trở lên", 44, 1)
  , ("quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao", 45, 1)
  , ("quang_cao_tren_phuong_tien_quang_cao_ngoai_troi", 46, 1)
  , ("la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia", 47, 1)
  , ("chu_the_la_to_chuc_ca_nhan_kinh_doanh_ruou_bia", 48, 1)
  , ("ban_theo_hinh_thuc_thuong_mai_dien_tu", 49, 1)
  , ("dap_ung_quy_dinh_dieu_15_khoan_4_5_va_dieu_18", 50, 1)
  , ("dap_ung_dieu_kien_phap_luat_thuong_mai_dien_tu", 51, 1)
  , ("thuc_hien_bien_phap_ngan_nguoi_chua_du_18_tiep_can_mua_ruou_bia", 52, 1)
  , ("ap_dung_thanh_toan_khong_dung_tien_mat", 53, 1)
  , ("muc_dich_kinh_doanh", 54, 1)
  , ("chu_the_la_ho_gia_dinh_ca_nhan", 55, 1)
  , ("co_ban_ke_khai_gui_ubnd_cap_xa_ve_san_xuat_ruou_thu_cong", 56, 1)
  , ("ruou_bia_khong_bao_dam_an_toan_thuc_pham", 57, 1)
  , ("ruou_bia_khong_bao_dam_tieu_chuan_quy_chuan_ky_thuat", 58, 1)
  , ("uong_truoc_hoac_trong_khi_tham_gia_giao_thong_voi_tu_cach_nguoi_dieu_khien", 59, 1)
  , ("co_hanh_vi_vi_pham_dieu_10_hoac_19_tai_dia_diem", 60, 1)
  , ("nguoi_vi_pham_tiep_tuc_vi_pham_sau_khi_duoc_nhac_nho_yeu_cau", 61, 1)
  , ("co_yeu_cau_cua_co_quan_co_tham_quyen", 62, 1)
  , ("ruou_bia_do_co_so_minh_san_xuat_mua_ban", 63, 1)
  , ("co_so_ban_ruou_bia", 64, 1)
  , ("nghi_ngo_ve_do_tuoi_nguoi_mua", 65, 1)
  , ("co_so_ban_ruou_bia_tieu_dung_tai_cho", 66, 1)
  , ("khach_hang_da_uong_ruou_bia", 67, 1)
  , ("mo_moi_ke_tu_ngay_luat_co_hieu_luc", 68, 1)
  , ("trong_ban_kinh_100m_tu_khuon_vien_co_so_y_te", 69, 1)
  , ("trong_ban_kinh_100m_tu_khuon_vien_co_so_mam_non_pho_thong", 70, 1)
  , ("Điều 15 · S1 do_con_tu_5_5_do_tro_len", 71, 1)
  , ("Điều 15 · S2 san_xuat_ruou_cong_nghiep", 72, 1)
  , ("Điều 15 · S3 san_xuat_ruou_thu_cong_nham_muc_dich_kinh_doanh", 73, 1)
  , ("Điều 15 · S4 san_xuat_ruou_thu_cong_ban_cho_co_so_co_giay_phep_de_che_bien_lai", 74, 1)
  , ("Điều 15 · S5 mua_ban_ruou", 75, 1)
  , ("Điều 15 · S6 loai_chu_the = doanh_nghiep", 76, 0)
  , ("Điều 15 · S6 loai_chu_the = hop_tac_xa", 76, 1)
  , ("Điều 15 · S6 loai_chu_the = lien_hiep_hop_tac_xa", 76, 2)
  , ("Điều 15 · S6 loai_chu_the = ho_kinh_doanh", 76, 3)
  , ("Điều 15 · S6 loai_chu_the = ho_gia_dinh", 76, 4)
  , ("Điều 15 · S6 loai_chu_the = ca_nhan", 76, 5)
  , ("Điều 15 · S7 co_day_chuyen_may_moc_thiet_bi_quy_trinh_cong_nghe", 77, 1)
  , ("Điều 15 · S8 co_nhan_vien_ky_thuat", 78, 1)
  , ("Điều 15 · S9 co_hop_dong_mua_ban_voi_co_so_co_giay_phep_san_xuat_ruou", 79, 1)
  , ("Điều 15 · S10 co_dang_ky_voi_ubnd_cap_xa_noi_co_co_so_san_xuat", 80, 1)
  , ("Điều 15 · S11 co_dang_ky_kinh_doanh", 81, 1) ]

def rP : List ReaderSpec :=
  [ ("ngay_truoc_gio_lam_viec_hoc_tap", 0, 1)
  , ("danh_cho_nguoi_chua_du_18", 1, 1)
  , ("quang_cao_huong_den_tre_em_hssv_thanh_nien_phu_nu_mang_thai", 2, 1)
  , ("su_dung_yeu_to_danh_cho_tre_em_hoc_sinh_sinh_vien", 3, 1)
  , ("su_kien_phuong_tien_san_pham_danh_cho_nhom_dac_biet", 4, 1)
  , ("ngay_truoc_trong_ngay_sau_chuong_trinh_danh_cho_tre_em", 5, 1)
  , ("co_so_lan_can_danh_cho_nguoi_chua_du_18", 6, 1)
  , ("Điều 15 · P1 duoc_thanh_lap_theo_quy_dinh_phap_luat", 7, 1)
  , ("Điều 15 · P2 day_chuyen_dap_ung_quy_mo_du_kien_san_xuat", 8, 1)
  , ("Điều 15 · P3 bao_dam_dieu_kien_an_toan_thuc_pham", 9, 1)
  , ("Điều 15 · P4 bao_dam_dieu_kien_bao_ve_moi_truong", 10, 1)
  , ("Điều 15 · P5 trinh_do_chuyen_mon_phu_hop_nganh_nghe_san_xuat_ruou", 11, 1)
  , ("Điều 15 · P6 dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou", 12, 1) ]

/-- Every legal unit of the document (articles, clauses, points), for the dangling-reference check. -/
def catalog : List String :=
  [ "Điều 1"
  , "Điều 2"
  , "Điều 2 khoản 1"
  , "Điều 2 khoản 2"
  , "Điều 2 khoản 3"
  , "Điều 2 khoản 4"
  , "Điều 2 khoản 5"
  , "Điều 2 khoản 6"
  , "Điều 2 khoản 7"
  , "Điều 2 khoản 8"
  , "Điều 3"
  , "Điều 3 khoản 1"
  , "Điều 3 khoản 2"
  , "Điều 3 khoản 3"
  , "Điều 3 khoản 4"
  , "Điều 3 khoản 5"
  , "Điều 4"
  , "Điều 4 khoản 1"
  , "Điều 4 khoản 2"
  , "Điều 4 khoản 3"
  , "Điều 4 khoản 4"
  , "Điều 5"
  , "Điều 5 khoản 1"
  , "Điều 5 khoản 2"
  , "Điều 5 khoản 3"
  , "Điều 5 khoản 4"
  , "Điều 5 khoản 5"
  , "Điều 5 khoản 6"
  , "Điều 5 khoản 7"
  , "Điều 5 khoản 8"
  , "Điều 5 khoản 9"
  , "Điều 5 khoản 10"
  , "Điều 5 khoản 11"
  , "Điều 5 khoản 12"
  , "Điều 5 khoản 13"
  , "Điều 6"
  , "Điều 6 khoản 1"
  , "Điều 6 khoản 2"
  , "Điều 6 khoản 2 điểm a"
  , "Điều 6 khoản 2 điểm b"
  , "Điều 7"
  , "Điều 7 khoản 1"
  , "Điều 7 khoản 2"
  , "Điều 7 khoản 3"
  , "Điều 7 khoản 4"
  , "Điều 7 khoản 5"
  , "Điều 7 khoản 6"
  , "Điều 7 khoản 7"
  , "Điều 7 khoản 8"
  , "Điều 8"
  , "Điều 8 khoản 1"
  , "Điều 8 khoản 2"
  , "Điều 8 khoản 3"
  , "Điều 8 khoản 4"
  , "Điều 8 khoản 5"
  , "Điều 9"
  , "Điều 9 khoản 1"
  , "Điều 9 khoản 2"
  , "Điều 10"
  , "Điều 10 khoản 1"
  , "Điều 10 khoản 2"
  , "Điều 10 khoản 3"
  , "Điều 10 khoản 4"
  , "Điều 10 khoản 5"
  , "Điều 10 khoản 6"
  , "Điều 10 khoản 7"
  , "Điều 11"
  , "Điều 12"
  , "Điều 12 khoản 1"
  , "Điều 12 khoản 2"
  , "Điều 12 khoản 2 điểm a"
  , "Điều 12 khoản 2 điểm b"
  , "Điều 12 khoản 3"
  , "Điều 12 khoản 3 điểm a"
  , "Điều 12 khoản 3 điểm b"
  , "Điều 12 khoản 3 điểm c"
  , "Điều 12 khoản 3 điểm d"
  , "Điều 12 khoản 4"
  , "Điều 12 khoản 5"
  , "Điều 12 khoản 6"
  , "Điều 13"
  , "Điều 13 khoản 1"
  , "Điều 13 khoản 2"
  , "Điều 14"
  , "Điều 15"
  , "Điều 15 khoản 1"
  , "Điều 15 khoản 1 điểm a"
  , "Điều 15 khoản 1 điểm b"
  , "Điều 15 khoản 1 điểm c"
  , "Điều 15 khoản 1 điểm d"
  , "Điều 15 khoản 2"
  , "Điều 15 khoản 2 điểm a"
  , "Điều 15 khoản 2 điểm b"
  , "Điều 15 khoản 3"
  , "Điều 15 khoản 3 điểm a"
  , "Điều 15 khoản 3 điểm b"
  , "Điều 15 khoản 4"
  , "Điều 15 khoản 4 điểm a"
  , "Điều 15 khoản 4 điểm b"
  , "Điều 15 khoản 5"
  , "Điều 16"
  , "Điều 16 khoản 1"
  , "Điều 16 khoản 2"
  , "Điều 16 khoản 3"
  , "Điều 16 khoản 4"
  , "Điều 17"
  , "Điều 17 khoản 1"
  , "Điều 17 khoản 2"
  , "Điều 18"
  , "Điều 19"
  , "Điều 19 khoản 1"
  , "Điều 19 khoản 2"
  , "Điều 19 khoản 3"
  , "Điều 19 khoản 4"
  , "Điều 19 khoản 5"
  , "Điều 19 khoản 6"
  , "Điều 20"
  , "Điều 20 khoản 1"
  , "Điều 20 khoản 2"
  , "Điều 20 khoản 3"
  , "Điều 21"
  , "Điều 21 khoản 1"
  , "Điều 21 khoản 2"
  , "Điều 21 khoản 3"
  , "Điều 21 khoản 4"
  , "Điều 22"
  , "Điều 22 khoản 1"
  , "Điều 22 khoản 1 điểm a"
  , "Điều 22 khoản 1 điểm b"
  , "Điều 22 khoản 1 điểm c"
  , "Điều 22 khoản 1 điểm d"
  , "Điều 22 khoản 2"
  , "Điều 23"
  , "Điều 23 khoản 1"
  , "Điều 23 khoản 1 điểm a"
  , "Điều 23 khoản 1 điểm b"
  , "Điều 23 khoản 2"
  , "Điều 23 khoản 2 điểm a"
  , "Điều 23 khoản 2 điểm b"
  , "Điều 23 khoản 2 điểm c"
  , "Điều 23 khoản 2 điểm d"
  , "Điều 23 khoản 2 điểm đ"
  , "Điều 23 khoản 3"
  , "Điều 23 khoản 4"
  , "Điều 23 khoản 5"
  , "Điều 24"
  , "Điều 24 khoản 1"
  , "Điều 24 khoản 2"
  , "Điều 24 khoản 3"
  , "Điều 24 khoản 4"
  , "Điều 24 khoản 5"
  , "Điều 25"
  , "Điều 25 khoản 1"
  , "Điều 25 khoản 1 điểm a"
  , "Điều 25 khoản 1 điểm b"
  , "Điều 25 khoản 1 điểm c"
  , "Điều 25 khoản 2"
  , "Điều 25 khoản 3"
  , "Điều 26"
  , "Điều 26 khoản 1"
  , "Điều 26 khoản 1 điểm a"
  , "Điều 26 khoản 1 điểm b"
  , "Điều 26 khoản 2"
  , "Điều 26 khoản 3"
  , "Điều 27"
  , "Điều 27 khoản 1"
  , "Điều 27 khoản 2"
  , "Điều 28"
  , "Điều 28 khoản 1"
  , "Điều 28 khoản 2"
  , "Điều 28 khoản 3"
  , "Điều 29"
  , "Điều 29 khoản 1"
  , "Điều 29 khoản 2"
  , "Điều 29 khoản 3"
  , "Điều 29 khoản 4"
  , "Điều 29 khoản 5"
  , "Điều 29 khoản 6"
  , "Điều 30"
  , "Điều 30 khoản 1"
  , "Điều 30 khoản 2"
  , "Điều 30 khoản 3"
  , "Điều 30 khoản 4"
  , "Điều 31"
  , "Điều 31 khoản 1"
  , "Điều 31 khoản 2"
  , "Điều 31 khoản 2 điểm a"
  , "Điều 31 khoản 2 điểm b"
  , "Điều 31 khoản 2 điểm c"
  , "Điều 31 khoản 2 điểm d"
  , "Điều 31 khoản 3"
  , "Điều 31 khoản 3 điểm a"
  , "Điều 31 khoản 3 điểm b"
  , "Điều 31 khoản 3 điểm c"
  , "Điều 31 khoản 4"
  , "Điều 32"
  , "Điều 32 khoản 1"
  , "Điều 32 khoản 2"
  , "Điều 32 khoản 3"
  , "Điều 32 khoản 4"
  , "Điều 32 khoản 5"
  , "Điều 32 khoản 6"
  , "Điều 32 khoản 7"
  , "Điều 33"
  , "Điều 33 khoản 1"
  , "Điều 33 khoản 2"
  , "Điều 33 khoản 3"
  , "Điều 33 khoản 3 điểm a"
  , "Điều 33 khoản 3 điểm b"
  , "Điều 34"
  , "Điều 34 khoản 1"
  , "Điều 34 khoản 2"
  , "Điều 34 khoản 3"
  , "Điều 35"
  , "Điều 35 khoản 1"
  , "Điều 35 khoản 2"
  , "Điều 35 khoản 3"
  , "Điều 35 khoản 3 điểm a"
  , "Điều 35 khoản 3 điểm b"
  , "Điều 36"
  , "Điều 36 khoản 1"
  , "Điều 36 khoản 2" ]

private def nrm (id : String) (mo : Modality) (act : String) (c : Cond) (ex : List Cond) (art : String)
    (refs : List String) : Norm :=
  { id := id, modality := mo, act := act, condition := c, exceptions := ex, priority := none
  , source := { docId := "44/2019/QH14", docType := .law, effective := ⟨2020, 1, 1⟩, article := art }
  , references := refs }

def norms : List Norm :=
  [ nrm "Điều 5:5.1" .prohibition "xui_giuc_ep_buoc_uong_ruou_bia" .tt [] "Điều 5 khoản 1" []
  , nrm "Điều 5:5.2" .prohibition "uong_ruou_bia" (.sit 4) [] "Điều 5 khoản 2" []
  , nrm "Điều 5:5.3a" .prohibition "ban_ruou_bia" (.sit 0) [] "Điều 5 khoản 3" []
  , nrm "Điều 5:5.3b" .prohibition "cung_cap_ruou_bia" (.sit 0) [] "Điều 5 khoản 3" []
  , nrm "Điều 5:5.3c" .prohibition "khuyen_mai_ruou_bia" (.sit 0) [] "Điều 5 khoản 3" []
  , nrm "Điều 5:5.4" .prohibition "su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia" (.sit 6) [] "Điều 5 khoản 4" []
  , nrm "Điều 5:5.5" .prohibition "uong_ruou_bia" (.and (.sit 8) (.or (.param 0) (.or (.sit 9) (.sit 10)))) [] "Điều 5 khoản 5" []
  , nrm "Điều 5:5.6" .prohibition "dieu_khien_phuong_tien_giao_thong" (.sit 11) [] "Điều 5 khoản 6" []
  , nrm "Điều 5:5.7" .prohibition "quang_cao_ruou_bia" (.and (.sit 12) (.sit 3)) [] "Điều 5 khoản 7" []
  , nrm "Điều 5:5.8" .prohibition "cung_cap_thong_tin_ve_anh_huong_suc_khoe_cua_ruou_bia" (.sit 14) [] "Điều 5 khoản 8" []
  , nrm "Điều 5:5.9.i" .prohibition "khuyen_mai_ruou_bia" (.sit 3) [] "Điều 5 khoản 9 nhánh (i)" []
  , nrm "Điều 5:5.9.ii" .prohibition "dung_ruou_bia_lam_qua_khuyen_mai" (.sit 3) [] "Điều 5 khoản 9 nhánh (ii)" []
  , nrm "Điều 5:5.10" .prohibition "su_dung_nguyen_lieu_san_xuat_pha_che_ruou_bia" (.or (.sit 15) (.and (.sit 16) (.sit 17))) [] "Điều 5 khoản 10" []
  , nrm "Điều 5:5.11.i" .prohibition "kinh_doanh_ruou_bia" (.and (.sit 12) (.or (.not (.sit 23)) (.not (.sit 22)))) [] "Điều 5 khoản 11 nhánh (i)" []
  , nrm "Điều 5:5.11.ii" .prohibition "ban_ruou_bia_bang_may_tu_dong" .tt [] "Điều 5 khoản 11 nhánh (ii)" []
  , nrm "Điều 5:5.12.i.a" .prohibition "kinh_doanh_ruou_bia" (.or (.sit 18) (.or (.sit 19) (.or (.sit 20) (.sit 21)))) [] "Điều 5 khoản 12 nhánh (i)" []
  , nrm "Điều 5:5.12.i.b" .prohibition "tang_tru_ruou_bia" (.or (.sit 18) (.or (.sit 19) (.or (.sit 20) (.sit 21)))) [] "Điều 5 khoản 12 nhánh (i)" []
  , nrm "Điều 5:5.12.i.c" .prohibition "van_chuyen_ruou_bia" (.or (.sit 18) (.or (.sit 19) (.or (.sit 20) (.sit 21)))) [] "Điều 5 khoản 12 nhánh (i)" []
  , nrm "Điều 5:5.12.ii" .prohibition "nhap_lau_ruou_bia" .tt [] "Điều 5 khoản 12 nhánh (ii)" []
  , nrm "Điều 10:10.1" .prohibition "uong_ruou_bia" (.sit 24) [] "Điều 10 khoản 1" []
  , nrm "Điều 10:10.2" .prohibition "uong_ruou_bia" (.and (.sit 25) (.sit 31)) [] "Điều 10 khoản 2" []
  , nrm "Điều 10:10.3" .prohibition "uong_ruou_bia" (.and (.sit 26) (.param 1)) [] "Điều 10 khoản 3" []
  , nrm "Điều 10:10.4" .prohibition "uong_ruou_bia" (.sit 27) [] "Điều 10 khoản 4" []
  , nrm "Điều 10:10.5" .prohibition "uong_ruou_bia" (.sit 28) [] "Điều 10 khoản 5" []
  , nrm "Điều 10:10.6" .prohibition "uong_ruou_bia" (.and (.sit 29) (.sit 32)) [(.sit 30)] "Điều 10 khoản 6" []
  , nrm "Điều 12:12.2.a" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.or (.sit 35) (.or (.sit 36) (.param 2)))) [] "Điều 12 khoản 2 điểm a" []
  , nrm "Điều 12:12.2.b" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.or (.param 3) (.sit 37))) [] "Điều 12 khoản 2 điểm b" []
  , nrm "Điều 12:12.3.a" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.param 4)) [] "Điều 12 khoản 3 điểm a" []
  , nrm "Điều 12:12.3.b" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.sit 38)) [] "Điều 12 khoản 3 điểm b" []
  , nrm "Điều 12:12.3.c.i" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.and (.sit 39) (.param 5))) [] "Điều 12 khoản 3 điểm c nhánh (i)" []
  , nrm "Điều 12:12.3.c.ii" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.and (.sit 39) (.sit 40))) [(.sit 41), (.sit 42)] "Điều 12 khoản 3 điểm c nhánh (ii)" []
  , nrm "Điều 12:12.3.d" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.and (.sit 43) (.and (.sit 44) (.or (.sit 45) (.and (.sit 46) (.param 6)))))) [] "Điều 12 khoản 3 điểm d" []
  , nrm "Điều 12:12.4" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.not (.sit 47))) [] "Điều 12 khoản 4" []
  , nrm "Điều 12:12.5" .prohibition "quang_cao_ruou_bia" (.and (.sit 33) (.and (.sit 48) (.not (.sit 49)))) [] "Điều 12 khoản 5" []
  , nrm "Điều 13:13.1" .prohibition "quang_cao_ruou_bia" (.and (.or (.and (.sit 12) (.and (.sit 34) (.sit 2))) (.and (.sit 13) (.sit 51))) (.sit 52)) [] "Điều 13 khoản 1" []
  , nrm "Điều 13:13.2" .prohibition "quang_cao_ruou_bia" (.and (.or (.and (.sit 12) (.and (.sit 34) (.sit 2))) (.and (.sit 13) (.sit 51))) (.sit 53)) [(.sit 54)] "Điều 13 khoản 2" []
  , nrm "Điều 14:14.1" .prohibition "tai_tro_bang_san_pham_ruou_bia" (.sit 55) [] "Điều 14" []
  , nrm "Điều 16:16.1" .prohibition "ban_ruou_bia" (.and (.sit 56) (.not (.sit 57))) [] "Điều 16 khoản 1" ["Điều 15 khoản 4", "Điều 15 khoản 5", "Điều 18"]
  , nrm "Điều 16:16.2" .prohibition "ban_ruou_bia" (.and (.sit 56) (.not (.sit 58))) [] "Điều 16 khoản 2" []
  , nrm "Điều 16:16.3" .prohibition "ban_ruou_bia" (.and (.sit 56) (.not (.sit 59))) [] "Điều 16 khoản 3" []
  , nrm "Điều 16:16.4" .prohibition "ban_ruou_bia" (.and (.sit 56) (.not (.sit 60))) [] "Điều 16 khoản 4" []
  , nrm "Điều 17:17.1" .prohibition "san_xuat_ruou_thu_cong" (.and (.sit 62) (.and (.not (.sit 61)) (.not (.sit 63)))) [] "Điều 17 khoản 1" []
  , nrm "Điều 18:18.1" .prohibition "kinh_doanh_ruou_bia" (.or (.sit 65) (.or (.sit 20) (.sit 64))) [] "Điều 18" []
  , nrm "Điều 20:20.2" .obligation "phoi_hop_tham_gia_voi_co_quan_phong_chong_ruou_bia_gia_nhap_lau" .tt [] "Điều 20 khoản 2" []
  , nrm "Điều 21:21.1" .prohibition "uong_ruou_bia" (.sit 66) [] "Điều 21 khoản 1" []
  , nrm "Điều 21:21.2" .obligation "thuc_hien_bien_phap_phong_ngua_phat_hien_ngan_chan_nguoi_dieu_khien_phuong_tien_van_tai_uong_ruou_bia" .tt [] "Điều 21 khoản 2" []
  , nrm "Điều 33:33.1.i" .obligation "to_chuc_thuc_hien_bien_phap_phong_chong_tac_hai_ruou_bia" .tt [] "Điều 33 khoản 1 nhánh (i)" []
  , nrm "Điều 33:33.1.ii" .obligation "to_chuc_thuc_hien_nghiem_quy_dinh_khong_uong_ruou_bia_trong_gio_lam_viec_tai_noi_lam_viec" .tt [] "Điều 33 khoản 1 nhánh (ii)" []
  , nrm "Điều 33:33.2" .obligation "tham_gia_hoat_dong_phong_chong_tac_hai_ruou_bia_tai_cong_dong_theo_dieu_24" .tt [] "Điều 33 khoản 2" ["Điều 24"]
  , nrm "Điều 33:33.3.a.i" .obligation "nhac_nho_yeu_cau_cham_dut_vi_pham_dieu_10_va_19" (.sit 67) [] "Điều 33 khoản 3 điểm a nhánh (i)" ["Điều 10", "Điều 19"]
  , nrm "Điều 33:33.3.a.ii" .obligation "tu_choi_cung_cap_dich_vu_cho_nguoi_tiep_tuc_vi_pham" (.sit 68) [] "Điều 33 khoản 3 điểm a nhánh (ii)" ["Điều 10", "Điều 19"]
  , nrm "Điều 33:33.3.b" .obligation "to_chuc_huong_dan_kiem_tra_don_doc_khong_uong_khong_ban_ruou_bia_tai_dia_diem" .tt [] "Điều 33 khoản 3 điểm b" ["Điều 10", "Điều 19"]
  , nrm "Điều 34:34.1.i" .obligation "giao_duc_giam_sat_nhac_nho_thanh_vien_chua_du_18_khong_uong_ruou_bia" .tt [] "Điều 34 khoản 1 nhánh (i)" []
  , nrm "Điều 34:34.2" .obligation "huong_dan_thanh_vien_gia_dinh_ky_nang_tu_choi_uong_ung_xu_nguoi_say_nghien" .tt [] "Điều 34 khoản 2" []
  , nrm "Điều 34:34.3" .obligation "gia_dinh_tham_gia_cung_co_quan_to_chuc_cong_dong_phong_chong_tac_hai_ruou_bia" .tt [] "Điều 34 khoản 3" []
  , nrm "Điều 19:19.1" .prohibition "ban_ruou_bia" (.sit 24) [] "Điều 19 khoản 1" []
  , nrm "Điều 19:19.2" .prohibition "ban_ruou_bia" (.sit 25) [] "Điều 19 khoản 2" []
  , nrm "Điều 19:19.3" .prohibition "ban_ruou_bia" (.and (.sit 26) (.param 1)) [] "Điều 19 khoản 3" []
  , nrm "Điều 19:19.4" .prohibition "ban_ruou_bia" (.sit 27) [] "Điều 19 khoản 4" []
  , nrm "Điều 19:19.5" .prohibition "ban_ruou_bia" (.sit 28) [] "Điều 19 khoản 5" []
  , nrm "Điều 19:19.6" .prohibition "ban_ruou_bia" (.sit 29) [(.sit 30)] "Điều 19 khoản 6" []
  , nrm "Điều 32:32.2" .obligation "cung_cap_thong_tin_hoat_dong_kinh_doanh_cho_co_quan" (.sit 69) [] "Điều 32 khoản 2" []
  , nrm "Điều 32:32.3" .prohibition "su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia" (.sit 6) [] "Điều 32 khoản 3" []
  , nrm "Điều 32:32.4" .obligation "thu_hoi_xu_ly_ruou_bia" (.and (.sit 70) (.or (.sit 20) (.sit 64))) [] "Điều 32 khoản 4" []
  , nrm "Điều 32:32.5.i" .obligation "niem_yet_thong_bao_khong_ban_cho_nguoi_chua_du_18" (.sit 71) [] "Điều 32 khoản 5 nhánh (i)" []
  , nrm "Điều 32:32.5.ii" .permission "yeu_cau_nguoi_mua_xuat_trinh_giay_to_chung_minh_tuoi" (.sit 72) [] "Điều 32 khoản 5 nhánh (ii)" []
  , nrm "Điều 32:32.6.i" .obligation "nhac_nho_thong_tin_khach_hang_khong_dieu_khien_phuong_tien" (.and (.sit 73) (.sit 74)) [] "Điều 32 khoản 6 nhánh (i)" []
  , nrm "Điều 32:32.6.ii" .obligation "ho_tro_khach_hang_su_dung_phuong_tien_cong_cong" (.and (.sit 73) (.sit 74)) [] "Điều 32 khoản 6 nhánh (ii)" []
  , nrm "Điều 32:32.7" .prohibition "mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho" (.and (.sit 75) (.or (.sit 76) (.sit 77))) [] "Điều 32 khoản 7" []
  , nrm "Điều 15:15.1" .permission "duoc_cap_phep_san_xuat_ruou_cong_nghiep" (.and (.sit 79) (.and (.sit 78) (.and (.sit 83) (.and (.param 7) (.and (.sit 89) (.and (.param 8) (.and (.param 9) (.and (.param 10) (.and (.sit 90) (.param 11)))))))))) [] "Điều 15 khoản 1" []
  , nrm "Điều 15:15.2" .permission "duoc_cap_phep_san_xuat_ruou_thu_cong" (.and (.sit 80) (.and (.sit 78) (.and (.or (.sit 83) (.or (.sit 84) (.or (.sit 85) (.sit 86)))) (.and (.param 7) (.param 9))))) [(.and (.sit 81) (.or (.sit 87) (.sit 88)))] "Điều 15 khoản 2" ["Điều 15 khoản 3"]
  , nrm "Điều 15:15.3" .permission "san_xuat_ruou_thu_cong_ban_cho_co_so_che_bien_lai" (.and (.sit 81) (.and (.sit 78) (.and (.or (.sit 87) (.sit 88)) (.and (.sit 91) (.and (.sit 92) (.param 9)))))) [] "Điều 15 khoản 3" []
  , nrm "Điều 15:15.4" .permission "duoc_cap_phep_mua_ban_ruou" (.and (.sit 82) (.and (.sit 78) (.and (.sit 93) (.param 12)))) [] "Điều 15 khoản 4" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 5 khoản 13", "Khoản dẫn chiếu chung tới «các hành vi bị nghiêm cấm khác ... do luật định» ở các văn bản khác, không nêu hành vi hay điều kiện cụ thể nào để mã hóa.")
  , ("Điều 10 khoản 7", "Danh mục «địa điểm công cộng» do Chính phủ quy định trong văn bản khác; chữ của Điều 10 không cho biết địa điểm nào thuộc diện này nên không thể mã hóa điều kiện mà không đoán nội dung văn bản đó.")
  , ("Điều 12 khoản 1", "Nghĩa vụ chung phải tuân thủ Luật này và pháp luật về quảng cáo; không nêu hành vi hay điều kiện cụ thể nào, nội dung nằm ở văn bản khác hoặc đã được mã hóa ở các khoản khác.")
  , ("Điều 12 khoản 6", "Điều khoản giao Chính phủ quy định chi tiết điểm d khoản 3, khoản 4 và khoản 5; không tạo ra norm áp dụng trực tiếp.")
  , ("Điều 13", "Phần «phải tuân thủ quy định tại Điều 12 của Luật này» trong đoạn dẫn chỉ dẫn chiếu sang Điều 12, không tự đặt ra nội dung nghĩa vụ. Nghĩa vụ đó thuộc phần mã hóa Điều 12, nên ở đây không tạo norm riêng.")
  , ("Điều 14", "Chỉ mã hóa phần cấm tài trợ bằng sản phẩm rượu, bia. Phần «phải tuân thủ các quy định của pháp luật có liên quan đến việc tài trợ» dẫn chiếu sang văn bản khác và không nêu nội dung nghĩa vụ cụ thể, nên không mã hóa thành norm.")
  , ("Điều 17 khoản 1", "Câu sau «Việc kê khai không phải nộp phí, lệ phí» chỉ miễn phí, không đặt nghĩa vụ hay cấm đoán về hành vi nào trong bảng thuật ngữ, nên không mã hóa.")
  , ("Điều 17 khoản 2", "Nghĩa vụ của Ủy ban nhân dân các cấp (hướng dẫn, báo cáo) là việc của cơ quan nhà nước, không có hành vi tương ứng trong bảng thuật ngữ. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định.")
  , ("Điều 18", "Chữ «lưu hành» không có act tương ứng trong bảng thuật ngữ (bảng chỉ có kinh_doanh_ruou_bia); phần «lưu hành» của nghĩa vụ chưa được mã hóa. Để người duyệt quyết định có thêm act mới hay không.")
  , ("Điều 20 khoản 1", "«bị tịch thu, xử lý» là hậu quả đối với hàng hóa do cơ quan có thẩm quyền áp dụng, không phải hành vi của chủ thể trong bảng thuật ngữ; không có act tương ứng. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định.")
  , ("Điều 20 khoản 3", "Nhiệm vụ hướng dẫn của Bộ Công Thương, Bộ Y tế là việc của cơ quan nhà nước. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định.")
  , ("Điều 21 khoản 3", "Nghĩa vụ kiểm tra nồng độ cồn là của cơ quan, người có thẩm quyền. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định.")
  , ("Điều 21 khoản 4", "Trách nhiệm đào tạo của Bộ Giao thông vận tải là việc của cơ quan nhà nước. Quy tắc nhất quán của bản dịch này: nghĩa vụ của cơ quan nhà nước (hướng dẫn, kiểm tra, báo cáo, tịch thu) không được mã hóa, vì bảng thuật ngữ chỉ có hành vi của chủ thể tư nhân; những khoản đó vào «not_encoded» để người duyệt quyết định.")
  , ("Điều 33 khoản 3", "Câu dẫn của khoản xác định chủ thể là người đứng đầu, người quản lý, điều hành địa điểm quy định tại Điều 10 và Điều 19; chủ thể không được mã hóa thành atom, nên các norm của khoản này dùng điều kiện true hoặc điều kiện về hành vi vi phạm.")
  , ("Điều 34 khoản 1", "Hai phần sau của khoản («các thành viên khác trong gia đình hạn chế uống rượu, bia»; «động viên, giúp đỡ người nghiện rượu, bia trong gia đình cai nghiện») dùng chuẩn mở «hạn chế», «động viên, giúp đỡ» không có mức đo; không đoán, để người duyệt quyết định.")
  , ("Điều 32 khoản 1", "Câu đầu chỉ dẫn chiếu tới các văn bản pháp luật khác (điều kiện kinh doanh, quảng cáo, khuyến mại, tài trợ, an toàn thực phẩm, chất lượng, tiêu chuẩn, quy chuẩn, ghi nhãn) nên không có nội dung để mã hóa trong điều này. Câu sau («phải bảo đảm chính xác, khoa học») dùng chuẩn mở «khoa học», không trùng nghĩa với atom thong_tin_khong_chinh_xac_sai_su_that, và bảng không có act «cung cấp thông tin về sản phẩm» (cung_cap_thong_tin_ve_anh_huong_suc_khoe_cua_ruou_bia chỉ nói về ảnh hưởng sức khỏe). Để người duyệt quyết định cách đọc, không đoán.")
  , ("Điều 15 khoản 5", "Khoản này giao Chính phủ quy định chi tiết Điều 15 và quy định việc quản lý kinh doanh rượu có độ cồn dưới 5,5 độ; trong văn bản này không có quy phạm cấm, bắt buộc hay cho phép nào có điều kiện cụ thể.") ]

def acts : List Act := ["ban_ruou_bia", "ban_ruou_bia_bang_may_tu_dong", "cung_cap_ruou_bia", "cung_cap_thong_tin_hoat_dong_kinh_doanh_cho_co_quan", "cung_cap_thong_tin_ve_anh_huong_suc_khoe_cua_ruou_bia", "dieu_khien_phuong_tien_giao_thong", "dung_ruou_bia_lam_qua_khuyen_mai", "duoc_cap_phep_mua_ban_ruou", "duoc_cap_phep_san_xuat_ruou_cong_nghiep", "duoc_cap_phep_san_xuat_ruou_thu_cong", "gia_dinh_tham_gia_cung_co_quan_to_chuc_cong_dong_phong_chong_tac_hai_ruou_bia", "giao_duc_giam_sat_nhac_nho_thanh_vien_chua_du_18_khong_uong_ruou_bia", "ho_tro_khach_hang_su_dung_phuong_tien_cong_cong", "huong_dan_thanh_vien_gia_dinh_ky_nang_tu_choi_uong_ung_xu_nguoi_say_nghien", "khuyen_mai_ruou_bia", "kinh_doanh_ruou_bia", "mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho", "nhac_nho_thong_tin_khach_hang_khong_dieu_khien_phuong_tien", "nhac_nho_yeu_cau_cham_dut_vi_pham_dieu_10_va_19", "nhap_lau_ruou_bia", "niem_yet_thong_bao_khong_ban_cho_nguoi_chua_du_18", "phoi_hop_tham_gia_voi_co_quan_phong_chong_ruou_bia_gia_nhap_lau", "quang_cao_ruou_bia", "san_xuat_ruou_thu_cong", "san_xuat_ruou_thu_cong_ban_cho_co_so_che_bien_lai", "su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia", "su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia", "su_dung_nguyen_lieu_san_xuat_pha_che_ruou_bia", "tai_tro_bang_san_pham_ruou_bia", "tang_tru_ruou_bia", "tham_gia_hoat_dong_phong_chong_tac_hai_ruou_bia_tai_cong_dong_theo_dieu_24", "thu_hoi_xu_ly_ruou_bia", "thuc_hien_bien_phap_phong_ngua_phat_hien_ngan_chan_nguoi_dieu_khien_phuong_tien_van_tai_uong_ruou_bia", "to_chuc_huong_dan_kiem_tra_don_doc_khong_uong_khong_ban_ruou_bia_tai_dia_diem", "to_chuc_thuc_hien_bien_phap_phong_chong_tac_hai_ruou_bia", "to_chuc_thuc_hien_nghiem_quy_dinh_khong_uong_ruou_bia_trong_gio_lam_viec_tai_noi_lam_viec", "tu_choi_cung_cap_dich_vu_cho_nguoi_tiep_tuc_vi_pham", "uong_ruou_bia", "van_chuyen_ruou_bia", "xui_giuc_ep_buoc_uong_ruou_bia", "yeu_cau_nguoi_mua_xuat_trinh_giay_to_chung_minh_tuoi"]

def status : ReviewStatus := .reviewed "Vũ Đức Phong" ⟨2026, 11, 24⟩

/-- Every clause reference of the module, as written. -/
def usedRefs : List String :=
  norms.map (fun n => n.source.article) ++ norms.flatMap (·.references) ++ notEncoded.map (·.1) ++
  (tS ++ tP).map (·.source) ++
  (tS ++ tP).flatMap fun a => match a.domain with | .bool => [] | .enum vs => vs.map (·.source)

def unparsable : List String :=
  usedRefs.filter fun s => match parseEntry s with | .ok _ => false | .error _ => true

/-! ## Checked by the kernel -/

theorem refs_parse : unparsable = [] := by decide +kernel

theorem silent : pfindings tS tP rS rP catalog norms = [] := by decide +kernel

theorem consistent :
    analyzeP tS tP rS rP catalog norms = .consistentOn (projScope tS tP rS rP norms) := by
  decide +kernel

theorem no_conflict :
    ∀ n₁ ∈ norms, ∀ n₂ ∈ norms, ∀ (π : Valuation tP) (s : Valuation tS),
      ¬ Conflict (atomsOf tS tP rS rP) n₁ n₂ π s :=
  not_conflict_of_consistentOnP consistent

/-! The norms here are exactly the norms of the per-article modules, in this order: same id (ids already
carry their article), modality, act, source, references and number of exceptions. A norm dropped, duplicated or
reordered by the merge tool fails these theorems. Conditions are **not** compared: atom indices differ between
modules, so a condition changed by the merge would not be caught here (only by the tool's tests). -/

theorem covers_articles :
    norms.map (fun n => (n.id, n.modality, n.act)) =
    (LexProof.Laws.Article5.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article10.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article12.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article13.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article14.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article16.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article17.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article18.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article20.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article21.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article33.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article34.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article19.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article32.norms.map (fun n => (n.id, n.modality, n.act)) ++
     LexProof.Laws.Article15.norms.map (fun n => (n.id, n.modality, n.act))) := by
  decide +kernel

theorem covers_articles_source :
    norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) =
    (LexProof.Laws.Article5.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article10.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article12.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article13.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article14.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article16.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article17.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article18.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article20.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article21.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article33.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article34.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article19.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article32.norms.map (fun n => (n.source.article, n.references, n.exceptions.length)) ++
     LexProof.Laws.Article15.norms.map (fun n => (n.source.article, n.references, n.exceptions.length))) := by
  decide +kernel

/-- What `analyzeReport` prints for this module (always print this, not only the core result). -/
def report : List String := (analyzeReport status acts tS tP rS rP catalog norms).render

end LexProof.Laws.Law44
