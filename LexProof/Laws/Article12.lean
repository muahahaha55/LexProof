import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article12 — Điều 12 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article12.glossary.llm.json` (sha256 `c77afeeb4a0e7a40187daf64ce5fd91ef5e9592a7971c43a513d6d3704cf417e`), sheet `docs/review/duyet-ban-dich-dieu-12.md` (sha256 `cb8c857f354c7b7aeff4e714630e58d27b46a26f4923a552f5f6bef8d24bf0b3`), Vũ Đức Phong, 2026-11-23: accepted 9, rejected 0

Assumptions accepted on the sheets:
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

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`); an id shared by two articles is ONE atom:
* act quang_cao_ruou_bia [approved]: quảng cáo rượu, bia (nguồn: Điều 5 khoản 7)
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
-/

namespace LexProof.Laws.Article12

open LexProof

def tS : AtomTable :=
  [ { name := "do_con_nguong_5_5", source := "Điều 15 khoản 1", domain := .enum [⟨"dưới 5,5 độ", "Điều 15 khoản 5"⟩, ⟨"từ 5,5 độ trở lên", "Điều 15 khoản 1"⟩] }
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
  , { name := "co_he_thong_chan_loc_kiem_soat_tuoi_truy_cap", source := "Điều 12 khoản 5", domain := .bool } ]

def tP : AtomTable :=
  [ { name := "quang_cao_huong_den_tre_em_hssv_thanh_nien_phu_nu_mang_thai", source := "Điều 12 khoản 2 điểm a", domain := .bool }
  , { name := "su_dung_yeu_to_danh_cho_tre_em_hoc_sinh_sinh_vien", source := "Điều 12 khoản 2 điểm b", domain := .bool }
  , { name := "su_kien_phuong_tien_san_pham_danh_cho_nhom_dac_biet", source := "Điều 12 khoản 3 điểm a", domain := .bool }
  , { name := "ngay_truoc_trong_ngay_sau_chuong_trinh_danh_cho_tre_em", source := "Điều 12 khoản 3 điểm c nhánh (i)", domain := .bool }
  , { name := "co_so_lan_can_danh_cho_nguoi_chua_du_18", source := "Điều 12 khoản 3 điểm d", domain := .bool } ]

def rS : List ReaderSpec :=
  [ ("do_con_nguong_5_5 = dưới 5,5 độ", 0, 0)
  , ("do_con_nguong_5_5 = từ 5,5 độ trở lên", 0, 1)
  , ("noi_dung_khuyen_khich_uong_ruou_bia", 1, 1)
  , ("noi_dung_ruou_bia_tao_truong_thanh_thanh_dat_than_thien_hap_dan_gioi_tinh", 2, 1)
  , ("su_dung_nguoi_chua_du_18_hoac_hinh_anh_trong_quang_cao", 3, 1)
  , ("phuong_tien_quang_cao_la_phuong_tien_giao_thong", 4, 1)
  , ("phuong_tien_quang_cao_la_bao_noi_bao_hinh", 5, 1)
  , ("trong_khung_gio_18_den_21_gio", 6, 1)
  , ("quang_cao_co_san_trong_chuong_trinh_the_thao_ban_quyen_tiep_song_truc_tiep_nuoc_ngoai", 7, 1)
  , ("thuoc_truong_hop_ngoai_le_khac_theo_quy_dinh_chinh_phu_khung_gio_18_21", 8, 1)
  , ("phuong_tien_quang_cao_ngoai_troi", 9, 1)
  , ("vi_pham_kich_thuoc_khoang_cach_tu_khuon_vien_co_so_lan_can", 10, 1)
  , ("co_so_lan_can_la_co_so_giao_duc", 11, 1)
  , ("co_so_lan_can_la_co_so_khu_vuc_cham_soc_vui_choi", 12, 1)
  , ("quang_cao_co_canh_bao_tac_hai_ruou_bia", 13, 1)
  , ("quang_cao_tren_moi_truong_dien_tu", 14, 1)
  , ("co_he_thong_chan_loc_kiem_soat_tuoi_truy_cap", 15, 1) ]

def rP : List ReaderSpec :=
  [ ("quang_cao_huong_den_tre_em_hssv_thanh_nien_phu_nu_mang_thai", 0, 1)
  , ("su_dung_yeu_to_danh_cho_tre_em_hoc_sinh_sinh_vien", 1, 1)
  , ("su_kien_phuong_tien_san_pham_danh_cho_nhom_dac_biet", 2, 1)
  , ("ngay_truoc_trong_ngay_sau_chuong_trinh_danh_cho_tre_em", 3, 1)
  , ("co_so_lan_can_danh_cho_nguoi_chua_du_18", 4, 1) ]

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
  [ nrm "Điều 12:12.2.a" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.or (.sit 2) (.or (.sit 3) (.param 0)))) [] "Điều 12 khoản 2 điểm a" []
  , nrm "Điều 12:12.2.b" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.or (.param 1) (.sit 4))) [] "Điều 12 khoản 2 điểm b" []
  , nrm "Điều 12:12.3.a" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.param 2)) [] "Điều 12 khoản 3 điểm a" []
  , nrm "Điều 12:12.3.b" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.sit 5)) [] "Điều 12 khoản 3 điểm b" []
  , nrm "Điều 12:12.3.c.i" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.and (.sit 6) (.param 3))) [] "Điều 12 khoản 3 điểm c nhánh (i)" []
  , nrm "Điều 12:12.3.c.ii" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.and (.sit 6) (.sit 7))) [(.sit 8), (.sit 9)] "Điều 12 khoản 3 điểm c nhánh (ii)" []
  , nrm "Điều 12:12.3.d" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.and (.sit 10) (.and (.sit 11) (.or (.sit 12) (.and (.sit 13) (.param 4)))))) [] "Điều 12 khoản 3 điểm d" []
  , nrm "Điều 12:12.4" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.not (.sit 14))) [] "Điều 12 khoản 4" []
  , nrm "Điều 12:12.5" .prohibition "quang_cao_ruou_bia" (.and (.sit 0) (.and (.sit 15) (.not (.sit 16)))) [] "Điều 12 khoản 5" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 12 khoản 1", "Nghĩa vụ chung phải tuân thủ Luật này và pháp luật về quảng cáo; không nêu hành vi hay điều kiện cụ thể nào, nội dung nằm ở văn bản khác hoặc đã được mã hóa ở các khoản khác.")
  , ("Điều 12 khoản 6", "Điều khoản giao Chính phủ quy định chi tiết điểm d khoản 3, khoản 4 và khoản 5; không tạo ra norm áp dụng trực tiếp.") ]

def acts : List Act := ["quang_cao_ruou_bia"]

def status : ReviewStatus := .reviewed "Vũ Đức Phong" ⟨2026, 11, 23⟩

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

/-- What `analyzeReport` prints for this module (always print this, not only the core result). -/
def report : List String := (analyzeReport status acts tS tP rS rP catalog norms).render

end LexProof.Laws.Article12
