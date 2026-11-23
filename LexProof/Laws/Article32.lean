import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article32 — Điều 32 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article32.glossary-2.llm.json` (sha256 `02c516f06d9c99377489ba238b5a51fce32b85b873f850e84af8e3ff267c8f51`), sheet `docs/review/duyet-ban-dich-dieu-32-lan-2.md` (sha256 `d5e6f853cb83b9ad0ddc3bcfff99bbfea6d458de1d11fb6571998c35828582e5`), Vũ Đức Phong, 2026-11-23: accepted 8, rejected 0

Assumptions accepted on the sheets:
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

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`); an id shared by two articles is ONE atom:
* act cung_cap_thong_tin_hoat_dong_kinh_doanh_cho_co_quan [approved]: cơ sở kinh doanh cung cấp thông tin đầy đủ, chính xác về hoạt động kinh doanh của mình cho cơ quan có thẩm quyền (khác cung_cap_thong_tin_ve_anh_huong_suc_khoe_cua_ruou_bia và cung_cap_ruou_bia) (nguồn: Điều 32 khoản 2)
* act su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia [approved]: sử dụng lao động trực tiếp tham gia vào việc kinh doanh, quảng cáo rượu, bia (rộng hơn su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia vì gồm cả quảng cáo) (nguồn: Điều 32 khoản 3)
* act thu_hoi_xu_ly_ruou_bia [approved]: thu hồi và xử lý rượu, bia (nguồn: Điều 32 khoản 4)
* act niem_yet_thong_bao_khong_ban_cho_nguoi_chua_du_18 [approved]: niêm yết thông báo không bán rượu, bia cho người chưa đủ 18 tuổi (nguồn: Điều 32 khoản 5 nhánh (i))
* act yeu_cau_nguoi_mua_xuat_trinh_giay_to_chung_minh_tuoi [approved]: người bán yêu cầu người mua rượu, bia xuất trình giấy tờ chứng minh độ tuổi (nguồn: Điều 32 khoản 5 nhánh (ii))
* act nhac_nho_thong_tin_khach_hang_khong_dieu_khien_phuong_tien [approved]: nhắc nhở và có hình thức thông tin phù hợp đối với khách hàng về việc không điều khiển phương tiện giao thông (nguồn: Điều 32 khoản 6 nhánh (i))
* act ho_tro_khach_hang_su_dung_phuong_tien_cong_cong [approved]: hỗ trợ khách hàng thuê, sử dụng phương tiện giao thông công cộng (nguồn: Điều 32 khoản 6 nhánh (ii))
* act mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho [approved]: mở mới điểm bán rượu, bia để tiêu dùng tại chỗ (nguồn: Điều 32 khoản 7)
* atom tuoi_nguoi_lao_dong [approved]: tuổi của người lao động được sử dụng (nguồn: Điều 5 khoản 4)
*   nhãn «từ đủ 18 tuổi trở lên» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 5 khoản 4». Ghi chú: nhãn bù để miền đầy đủ; không khoản nào nêu trực tiếp
* atom ruou_bia_khong_bao_dam_chat_luong [approved]: rượu, bia không bảo đảm chất lượng (nguồn: Điều 5 khoản 12 nhánh (i))
* atom co_yeu_cau_cua_co_quan_co_tham_quyen [approved]: cơ quan có thẩm quyền đã yêu cầu cơ sở cung cấp thông tin về hoạt động kinh doanh (nguồn: Điều 32 khoản 2)
* atom ruou_bia_khong_bao_dam_an_toan_thuc_pham [approved]: rượu, bia không bảo đảm an toàn thực phẩm (khác ruou_bia_khong_bao_dam_chat_luong) (nguồn: Điều 32 khoản 4)
* atom ruou_bia_do_co_so_minh_san_xuat_mua_ban [approved]: rượu, bia do chính cơ sở sản xuất hoặc mua bán (nguồn: Điều 32 khoản 4)
* atom co_so_ban_ruou_bia [approved]: chủ thể là cơ sở bán rượu, bia (nguồn: Điều 32 khoản 5 nhánh (i))
* atom nghi_ngo_ve_do_tuoi_nguoi_mua [approved]: người bán nghi ngờ về độ tuổi của người mua rượu, bia (nguồn: Điều 32 khoản 5 nhánh (ii))
* atom co_so_ban_ruou_bia_tieu_dung_tai_cho [approved]: chủ thể là cơ sở bán rượu, bia để tiêu dùng tại chỗ (nguồn: Điều 32 khoản 6)
* atom khach_hang_da_uong_ruou_bia [approved]: khách hàng đã uống rượu, bia (thời điểm «sau khi uống rượu, bia») (nguồn: Điều 32 khoản 6 nhánh (ii))
* atom mo_moi_ke_tu_ngay_luat_co_hieu_luc [approved]: việc mở mới điểm bán diễn ra kể từ ngày Luật này có hiệu lực (nguồn: Điều 32 khoản 7)
* atom trong_ban_kinh_100m_tu_khuon_vien_co_so_y_te [approved]: điểm bán nằm trong bán kính 100 m tính từ khuôn viên của cơ sở y tế (khác dia_diem_co_so_y_te là địa điểm chính là cơ sở y tế) (nguồn: Điều 32 khoản 7)
* atom trong_ban_kinh_100m_tu_khuon_vien_co_so_mam_non_pho_thong [approved]: điểm bán nằm trong bán kính 100 m tính từ khuôn viên của nhà trẻ, trường mẫu giáo, trường mầm non hoặc cơ sở giáo dục phổ thông (hẹp hơn dia_diem_co_so_giao_duc và đo theo khoảng cách) (nguồn: Điều 32 khoản 7)
-/

namespace LexProof.Laws.Article32

open LexProof

def tS : AtomTable :=
  [ { name := "tuoi_nguoi_lao_dong", source := "Điều 5 khoản 4", domain := .enum [⟨"chưa đủ 18 tuổi", "Điều 5 khoản 4"⟩, ⟨"từ đủ 18 tuổi trở lên", "Điều 5 khoản 4"⟩] }
  , { name := "ruou_bia_khong_bao_dam_chat_luong", source := "Điều 5 khoản 12 nhánh (i)", domain := .bool }
  , { name := "co_yeu_cau_cua_co_quan_co_tham_quyen", source := "Điều 32 khoản 2", domain := .bool }
  , { name := "ruou_bia_khong_bao_dam_an_toan_thuc_pham", source := "Điều 32 khoản 4", domain := .bool }
  , { name := "ruou_bia_do_co_so_minh_san_xuat_mua_ban", source := "Điều 32 khoản 4", domain := .bool }
  , { name := "co_so_ban_ruou_bia", source := "Điều 32 khoản 5 nhánh (i)", domain := .bool }
  , { name := "nghi_ngo_ve_do_tuoi_nguoi_mua", source := "Điều 32 khoản 5 nhánh (ii)", domain := .bool }
  , { name := "co_so_ban_ruou_bia_tieu_dung_tai_cho", source := "Điều 32 khoản 6", domain := .bool }
  , { name := "khach_hang_da_uong_ruou_bia", source := "Điều 32 khoản 6 nhánh (ii)", domain := .bool }
  , { name := "mo_moi_ke_tu_ngay_luat_co_hieu_luc", source := "Điều 32 khoản 7", domain := .bool }
  , { name := "trong_ban_kinh_100m_tu_khuon_vien_co_so_y_te", source := "Điều 32 khoản 7", domain := .bool }
  , { name := "trong_ban_kinh_100m_tu_khuon_vien_co_so_mam_non_pho_thong", source := "Điều 32 khoản 7", domain := .bool } ]

def tP : AtomTable :=
  []

def rS : List ReaderSpec :=
  [ ("tuoi_nguoi_lao_dong = chưa đủ 18 tuổi", 0, 0)
  , ("tuoi_nguoi_lao_dong = từ đủ 18 tuổi trở lên", 0, 1)
  , ("ruou_bia_khong_bao_dam_chat_luong", 1, 1)
  , ("co_yeu_cau_cua_co_quan_co_tham_quyen", 2, 1)
  , ("ruou_bia_khong_bao_dam_an_toan_thuc_pham", 3, 1)
  , ("ruou_bia_do_co_so_minh_san_xuat_mua_ban", 4, 1)
  , ("co_so_ban_ruou_bia", 5, 1)
  , ("nghi_ngo_ve_do_tuoi_nguoi_mua", 6, 1)
  , ("co_so_ban_ruou_bia_tieu_dung_tai_cho", 7, 1)
  , ("khach_hang_da_uong_ruou_bia", 8, 1)
  , ("mo_moi_ke_tu_ngay_luat_co_hieu_luc", 9, 1)
  , ("trong_ban_kinh_100m_tu_khuon_vien_co_so_y_te", 10, 1)
  , ("trong_ban_kinh_100m_tu_khuon_vien_co_so_mam_non_pho_thong", 11, 1) ]

def rP : List ReaderSpec :=
  []

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
  [ nrm "Điều 32:32.2" .obligation "cung_cap_thong_tin_hoat_dong_kinh_doanh_cho_co_quan" (.sit 3) [] "Điều 32 khoản 2" []
  , nrm "Điều 32:32.3" .prohibition "su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia" (.sit 0) [] "Điều 32 khoản 3" []
  , nrm "Điều 32:32.4" .obligation "thu_hoi_xu_ly_ruou_bia" (.and (.sit 5) (.or (.sit 2) (.sit 4))) [] "Điều 32 khoản 4" []
  , nrm "Điều 32:32.5.i" .obligation "niem_yet_thong_bao_khong_ban_cho_nguoi_chua_du_18" (.sit 6) [] "Điều 32 khoản 5 nhánh (i)" []
  , nrm "Điều 32:32.5.ii" .permission "yeu_cau_nguoi_mua_xuat_trinh_giay_to_chung_minh_tuoi" (.sit 7) [] "Điều 32 khoản 5 nhánh (ii)" []
  , nrm "Điều 32:32.6.i" .obligation "nhac_nho_thong_tin_khach_hang_khong_dieu_khien_phuong_tien" (.and (.sit 8) (.sit 9)) [] "Điều 32 khoản 6 nhánh (i)" []
  , nrm "Điều 32:32.6.ii" .obligation "ho_tro_khach_hang_su_dung_phuong_tien_cong_cong" (.and (.sit 8) (.sit 9)) [] "Điều 32 khoản 6 nhánh (ii)" []
  , nrm "Điều 32:32.7" .prohibition "mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho" (.and (.sit 10) (.or (.sit 11) (.sit 12))) [] "Điều 32 khoản 7" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 32 khoản 1", "Câu đầu chỉ dẫn chiếu tới các văn bản pháp luật khác (điều kiện kinh doanh, quảng cáo, khuyến mại, tài trợ, an toàn thực phẩm, chất lượng, tiêu chuẩn, quy chuẩn, ghi nhãn) nên không có nội dung để mã hóa trong điều này. Câu sau («phải bảo đảm chính xác, khoa học») dùng chuẩn mở «khoa học», không trùng nghĩa với atom thong_tin_khong_chinh_xac_sai_su_that, và bảng không có act «cung cấp thông tin về sản phẩm» (cung_cap_thong_tin_ve_anh_huong_suc_khoe_cua_ruou_bia chỉ nói về ảnh hưởng sức khỏe). Để người duyệt quyết định cách đọc, không đoán.") ]

def acts : List Act := ["cung_cap_thong_tin_hoat_dong_kinh_doanh_cho_co_quan", "ho_tro_khach_hang_su_dung_phuong_tien_cong_cong", "mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho", "nhac_nho_thong_tin_khach_hang_khong_dieu_khien_phuong_tien", "niem_yet_thong_bao_khong_ban_cho_nguoi_chua_du_18", "su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia", "thu_hoi_xu_ly_ruou_bia", "yeu_cau_nguoi_mua_xuat_trinh_giay_to_chung_minh_tuoi"]

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

end LexProof.Laws.Article32
