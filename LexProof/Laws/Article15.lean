import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article15 — Điều 15 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article15.glossary-2.llm.json` (sha256 `a2fcf0d372e37dc8ccce57daa2b47ca3b6e0d75fbe3e8db5b8d4d19b1ea53f5e`), sheet `docs/review/duyet-ban-dich-dieu-15-lan-3.md` (sha256 `06080ed80770a366f188336e9361857b1448b97183e03e097af627b07bfbbcca`), Vũ Đức Phong, 2026-11-25: accepted 8, rejected 0
  (sheet made on glossary sha256 `d2b183c06512a4dba6499f108d227dcd3731850f9fb493345df69f867acfa43e`; every term this translation uses has the same meaning in the
  current glossary, so the review carries over: see `changed_terms` in promote.py)

Assumptions accepted on the sheets:
* Điều 15: Ngày hiệu lực 2020-01-01 không có trong đoạn văn được cung cấp; giá trị này lấy từ kiến thức bên ngoài và người duyệt cần kiểm tra lại.
* Điều 15: Tiêu đề «Quản lý kinh doanh rượu» không cho biết tính chất cấm, bắt buộc hay được phép, nên không áp dụng tính chất nào từ tiêu đề cho các khoản (quy tắc 7).
* Điều 15: Quy tắc 11 theo người duyệt (lần 2 bác giả định cũ; trả lời 2026-11-25: «được phép»): mỗi danh sách «Điều kiện ... bao gồm» ở khoản 1, 2, 3, 4 được đọc theo hai chiều. Thiếu một điểm thì hành vi bị cấm (15.1, 15.2, 15.3, 15.4); đủ mọi điểm thì hành vi được phép (15.1.p, 15.2.p, 15.3.p, 15.4.p). «Được phép», không phải «bắt buộc»: luật không nói cơ quan phải cấp. Khoản 5 giao Chính phủ quy định chi tiết, nên văn bản hướng dẫn có thể thêm điều kiện; khi đó chiều «được phép» sẽ quá rộng.
* Điều 15: Ở khoản 1, 2 và 4, hành vi bị điều chỉnh là việc cấp giấy phép (do cơ quan có thẩm quyền thực hiện), không phải bản thân việc sản xuất hay mua bán; luật không nêu cơ quan cấp phép.
* Điều 15: Ở khoản 3, theo người duyệt (lần 2 bác giả định cũ; trả lời 2026-11-25: đồng ý), việc đăng ký với Ủy ban nhân dân cấp xã (điểm a) được coi tương đương cấp phép. Vì vậy hành vi bị điều chỉnh là việc Ủy ban nhân dân cấp xã nhận đăng ký (nhan_dang_ky_san_xuat_ruou_thu_cong_ban_che_bien_lai), không phải bản thân việc sản xuất; atom co_dang_ky_voi_ubnd_cap_xa không còn là điều kiện. Điều kiện còn lại: hợp đồng mua bán với cơ sở có giấy phép (điểm a) và an toàn thực phẩm (điểm b).
* Điều 15: Atom do_con của bảng có ngưỡng 15 độ, không dùng được cho ngưỡng 5,5 độ của Điều 15. Vì vậy đề xuất atom mới do_con_nguong_5_5 thay vì sửa do_con (quy tắc 14).
* Điều 15: Không dùng kinh_doanh_ruou_bia cho «mua bán rượu» ở khoản 4, vì kinh doanh rộng hơn (gồm cả sản xuất), nên đề xuất act mới cap_phep_mua_ban_ruou.
* Điều 15: Không dùng co_giay_phep_hoac_dang_ky_kinh_doanh_ruou cho khoản 4 điểm a, vì điểm a là đăng ký kinh doanh chung, không phải giấy phép hay đăng ký riêng cho kinh doanh rượu; đề xuất co_dang_ky_kinh_doanh.
* Điều 15: Điều 15 chỉ nói về rượu, không nói về bia. Tên các act mới đã giới hạn ở rượu, nên không thêm điều kiện loai_do_uong.
* Điều 15: Khoản 1 điểm c tách thành hai atom (an toàn thực phẩm; bảo vệ môi trường). Atom an toàn thực phẩm dùng chung cho khoản 1 điểm c, khoản 2 điểm b và khoản 3 điểm b vì chữ giống nhau.
* Điều 15: Khoản 1 điểm b («đáp ứng quy mô dự kiến sản xuất») và điểm d («phù hợp») được coi là khái niệm mở và mã hóa thành tham số; mỗi điểm là một tham số bao trọn điểm đó.
* Điều 15: Khoản 3 điểm a tách thành hai atom (hợp đồng mua bán; đăng ký với UBND cấp xã) vì chữ «và» đòi cả hai.
* Điều 15: Ngoại lệ của khoản 2 («trừ trường hợp quy định tại khoản 3 Điều này») được biểu diễn bằng phạm vi của khoản 3: chủ thể là hộ gia đình, cá nhân và bán cho cơ sở có giấy phép để chế biến lại. Hộ kinh doanh (khoản 2 điểm a) được coi là khác hộ gia đình (khoản 3).
* Điều 15: Các dẫn chiếu ra văn bản khác không ghi vào «references»: «theo quy định của pháp luật» (khoản 1 điểm a, c; khoản 2 điểm a, b; khoản 3 điểm b; khoản 4 điểm a), «theo từng loại hình mua bán rượu» ở khoản 4 điểm b (nội dung do văn bản khác quy định) và «Chính phủ quy định» ở khoản 5.
* Điều 15: 15.2.p không mang ngoại lệ «trừ trường hợp quy định tại khoản 3»: điều kiện của nó đã đòi chủ thể là doanh nghiệp, hợp tác xã, liên hiệp hợp tác xã hoặc hộ kinh doanh, mà theo người duyệt (2026-11-25) hộ gia đình đã đăng ký hộ kinh doanh được tính là hộ kinh doanh, không thuộc khoản 3. Ngoại lệ vẫn giữ ở 15.2 (lệnh cấm), vì ở đó nó loại hộ gia đình, cá nhân của khoản 3 khỏi lệnh cấm cấp phép.

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `f9f9510bf455995d59675c46a2f3cba8a0777bd5daf646e2eefa3537813750dd`); an id shared by two articles is ONE atom:
* act cap_phep_san_xuat_ruou_cong_nghiep [approved]: cấp giấy phép sản xuất rượu công nghiệp (nguồn: Điều 15 khoản 1)
* act cap_phep_san_xuat_ruou_thu_cong [approved]: cấp giấy phép sản xuất rượu thủ công nhằm mục đích kinh doanh (nguồn: Điều 15 khoản 2)
* act cap_phep_mua_ban_ruou [approved]: cấp giấy phép mua bán rượu (mua bán hẹp hơn kinh_doanh_ruou_bia, vốn gồm cả sản xuất) (nguồn: Điều 15 khoản 4)
* act nhan_dang_ky_san_xuat_ruou_thu_cong_ban_che_bien_lai [approved]: Ủy ban nhân dân cấp xã nhận đăng ký của hộ gia đình, cá nhân sản xuất rượu thủ công để bán cho cơ sở có giấy phép sản xuất rượu chế biến lại (việc đăng ký được coi tương đương cấp phép) (nguồn: Điều 15 khoản 3)
* atom do_con_nguong_5_5 [approved]: độ cồn của rượu so với ngưỡng 5,5 độ (nguồn: Điều 15 khoản 1; Điều 15 khoản 5)
* atom chu_the_la_doanh_nghiep_thanh_lap_hop_phap [approved]: chủ thể là doanh nghiệp được thành lập theo quy định của pháp luật (nguồn: Điều 15 khoản 1 điểm a)
* atom day_chuyen_thiet_bi_quy_trinh_dap_ung_quy_mo_du_kien [approved]: có dây chuyền máy móc, thiết bị công nghiệp, quy trình công nghệ sản xuất rượu «đáp ứng quy mô dự kiến sản xuất» (khái niệm mở, luật không định lượng) (nguồn: Điều 15 khoản 1 điểm b)
* atom bao_dam_dieu_kien_an_toan_thuc_pham [approved]: bảo đảm điều kiện về an toàn thực phẩm theo quy định của pháp luật (nguồn: Điều 15 khoản 1 điểm c; Điều 15 khoản 2 điểm b; Điều 15 khoản 3 điểm b)
* atom bao_dam_dieu_kien_bao_ve_moi_truong [approved]: bảo đảm điều kiện về bảo vệ môi trường theo quy định của pháp luật (nguồn: Điều 15 khoản 1 điểm c)
* atom nhan_vien_ky_thuat_trinh_do_phu_hop [approved]: có nhân viên kỹ thuật có trình độ, chuyên môn «phù hợp» với ngành, nghề sản xuất rượu (khái niệm mở) (nguồn: Điều 15 khoản 1 điểm d)
* atom muc_dich_kinh_doanh [approved]: việc sản xuất rượu nhằm mục đích kinh doanh (nguồn: Điều 15 khoản 2)
* atom chu_the_la_dn_htx_lhhtx_hkd_thanh_lap_hop_phap [approved]: chủ thể là doanh nghiệp, hợp tác xã, liên hiệp hợp tác xã hoặc hộ kinh doanh được thành lập theo quy định của pháp luật (nguồn: Điều 15 khoản 2 điểm a)
* atom chu_the_la_ho_gia_dinh_ca_nhan [approved]: chủ thể sản xuất là hộ gia đình hoặc cá nhân (khác hộ kinh doanh) (nguồn: Điều 15 khoản 3)
* atom ban_cho_co_so_co_giay_phep_de_che_bien_lai [approved]: rượu sản xuất ra được bán cho cơ sở có giấy phép sản xuất rượu để chế biến lại (nguồn: Điều 15 khoản 3)
* atom co_hop_dong_mua_ban_voi_co_so_co_giay_phep [approved]: có hợp đồng mua bán với cơ sở có giấy phép sản xuất rượu (nguồn: Điều 15 khoản 3 điểm a)
* atom co_dang_ky_kinh_doanh [approved]: đã đăng ký kinh doanh theo quy định của pháp luật (đăng ký kinh doanh chung, khác co_giay_phep_hoac_dang_ky_kinh_doanh_ruou) (nguồn: Điều 15 khoản 4 điểm a)
* atom dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou [approved]: đáp ứng điều kiện theo từng loại hình mua bán rượu (nội dung điều kiện do văn bản khác quy định) (nguồn: Điều 15 khoản 4 điểm b)
-/

namespace LexProof.Laws.Article15

open LexProof

def tS : AtomTable :=
  [ { name := "do_con_nguong_5_5", source := "Điều 15 khoản 1", domain := .enum [⟨"dưới 5,5 độ", "Điều 15 khoản 5"⟩, ⟨"từ 5,5 độ trở lên", "Điều 15 khoản 1"⟩] }
  , { name := "chu_the_la_doanh_nghiep_thanh_lap_hop_phap", source := "Điều 15 khoản 1 điểm a", domain := .bool }
  , { name := "bao_dam_dieu_kien_an_toan_thuc_pham", source := "Điều 15 khoản 1 điểm c", domain := .bool }
  , { name := "bao_dam_dieu_kien_bao_ve_moi_truong", source := "Điều 15 khoản 1 điểm c", domain := .bool }
  , { name := "muc_dich_kinh_doanh", source := "Điều 15 khoản 2", domain := .bool }
  , { name := "chu_the_la_dn_htx_lhhtx_hkd_thanh_lap_hop_phap", source := "Điều 15 khoản 2 điểm a", domain := .bool }
  , { name := "chu_the_la_ho_gia_dinh_ca_nhan", source := "Điều 15 khoản 3", domain := .bool }
  , { name := "ban_cho_co_so_co_giay_phep_de_che_bien_lai", source := "Điều 15 khoản 3", domain := .bool }
  , { name := "co_hop_dong_mua_ban_voi_co_so_co_giay_phep", source := "Điều 15 khoản 3 điểm a", domain := .bool }
  , { name := "co_dang_ky_kinh_doanh", source := "Điều 15 khoản 4 điểm a", domain := .bool }
  , { name := "dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou", source := "Điều 15 khoản 4 điểm b", domain := .bool } ]

def tP : AtomTable :=
  [ { name := "day_chuyen_thiet_bi_quy_trinh_dap_ung_quy_mo_du_kien", source := "Điều 15 khoản 1 điểm b", domain := .bool }
  , { name := "nhan_vien_ky_thuat_trinh_do_phu_hop", source := "Điều 15 khoản 1 điểm d", domain := .bool } ]

def rS : List ReaderSpec :=
  [ ("do_con_nguong_5_5 = dưới 5,5 độ", 0, 0)
  , ("do_con_nguong_5_5 = từ 5,5 độ trở lên", 0, 1)
  , ("chu_the_la_doanh_nghiep_thanh_lap_hop_phap", 1, 1)
  , ("bao_dam_dieu_kien_an_toan_thuc_pham", 2, 1)
  , ("bao_dam_dieu_kien_bao_ve_moi_truong", 3, 1)
  , ("muc_dich_kinh_doanh", 4, 1)
  , ("chu_the_la_dn_htx_lhhtx_hkd_thanh_lap_hop_phap", 5, 1)
  , ("chu_the_la_ho_gia_dinh_ca_nhan", 6, 1)
  , ("ban_cho_co_so_co_giay_phep_de_che_bien_lai", 7, 1)
  , ("co_hop_dong_mua_ban_voi_co_so_co_giay_phep", 8, 1)
  , ("co_dang_ky_kinh_doanh", 9, 1)
  , ("dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou", 10, 1) ]

def rP : List ReaderSpec :=
  [ ("day_chuyen_thiet_bi_quy_trinh_dap_ung_quy_mo_du_kien", 0, 1)
  , ("nhan_vien_ky_thuat_trinh_do_phu_hop", 1, 1) ]

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
  [ nrm "Điều 15:15.1" .prohibition "cap_phep_san_xuat_ruou_cong_nghiep" (.and (.sit 1) (.not (.and (.sit 2) (.and (.param 0) (.and (.sit 3) (.and (.sit 4) (.param 1))))))) [] "Điều 15 khoản 1" []
  , nrm "Điều 15:15.1.p" .permission "cap_phep_san_xuat_ruou_cong_nghiep" (.and (.sit 1) (.and (.sit 2) (.and (.param 0) (.and (.sit 3) (.and (.sit 4) (.param 1)))))) [] "Điều 15 khoản 1" []
  , nrm "Điều 15:15.2" .prohibition "cap_phep_san_xuat_ruou_thu_cong" (.and (.sit 1) (.and (.sit 5) (.not (.and (.sit 6) (.sit 3))))) [(.and (.sit 7) (.sit 8))] "Điều 15 khoản 2" ["Điều 15 khoản 3"]
  , nrm "Điều 15:15.2.p" .permission "cap_phep_san_xuat_ruou_thu_cong" (.and (.sit 1) (.and (.sit 5) (.and (.sit 6) (.sit 3)))) [] "Điều 15 khoản 2" []
  , nrm "Điều 15:15.3" .prohibition "nhan_dang_ky_san_xuat_ruou_thu_cong_ban_che_bien_lai" (.and (.sit 7) (.and (.sit 1) (.and (.sit 8) (.not (.and (.sit 9) (.sit 3)))))) [] "Điều 15 khoản 3" []
  , nrm "Điều 15:15.3.p" .permission "nhan_dang_ky_san_xuat_ruou_thu_cong_ban_che_bien_lai" (.and (.sit 7) (.and (.sit 1) (.and (.sit 8) (.and (.sit 9) (.sit 3))))) [] "Điều 15 khoản 3" []
  , nrm "Điều 15:15.4" .prohibition "cap_phep_mua_ban_ruou" (.and (.sit 1) (.not (.and (.sit 10) (.sit 11)))) [] "Điều 15 khoản 4" []
  , nrm "Điều 15:15.4.p" .permission "cap_phep_mua_ban_ruou" (.and (.sit 1) (.and (.sit 10) (.sit 11))) [] "Điều 15 khoản 4" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 15 khoản 5", "Khoản 5 giao Chính phủ quy định chi tiết Điều 15 và việc quản lý kinh doanh rượu dưới 5,5 độ. Nó không đặt ra lệnh cấm, nghĩa vụ hay quyền nào có thể mã hóa từ chữ của luật; chỉ dùng làm nguồn cho nhãn «dưới 5,5 độ».") ]

def acts : List Act := ["cap_phep_mua_ban_ruou", "cap_phep_san_xuat_ruou_cong_nghiep", "cap_phep_san_xuat_ruou_thu_cong", "nhan_dang_ky_san_xuat_ruou_thu_cong_ban_che_bien_lai"]

def status : ReviewStatus := .reviewed "Vũ Đức Phong" ⟨2026, 11, 25⟩

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
def report : List String := (analyzeReport status acts tS tP rS rP catalog norms).render ++
  counterexampleLines tS tP (analyzeP tS tP rS rP catalog norms)

end LexProof.Laws.Article15
