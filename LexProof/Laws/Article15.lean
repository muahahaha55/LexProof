import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article15 — Điều 15 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atom names and norm ids carry their article («Điều 5 · ...»): two articles never share an atom, so a
conflict that depends on a concept shared by two articles can be missed (no translation here uses the glossary).

Review sheets:
* `eval/translate/article15.llm.json` (sha256 `98241e1293cf2b9b317ffa8915791493b801fe6dae50e8ad69b07ac02545e902`), sheet `docs/review/duyet-ban-dich-dieu-15.md` (sha256 `131389487aa77d1f1a63304b79c5e78e861d4e5684948c36bb59d6ff8d06982d`), Vũ Đức Phong, 2026-11-20: accepted 4, rejected 0

Assumptions accepted on the sheets:
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
-/

namespace LexProof.Laws.Article15

open LexProof

def tS : AtomTable :=
  [ { name := "Điều 15 · S1 do_con_tu_5_5_do_tro_len", source := "Điều 15 khoản 1", domain := .bool }
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
  [ { name := "Điều 15 · P1 duoc_thanh_lap_theo_quy_dinh_phap_luat", source := "Điều 15 khoản 1 điểm a", domain := .bool }
  , { name := "Điều 15 · P2 day_chuyen_dap_ung_quy_mo_du_kien_san_xuat", source := "Điều 15 khoản 1 điểm b", domain := .bool }
  , { name := "Điều 15 · P3 bao_dam_dieu_kien_an_toan_thuc_pham", source := "Điều 15 khoản 1 điểm c", domain := .bool }
  , { name := "Điều 15 · P4 bao_dam_dieu_kien_bao_ve_moi_truong", source := "Điều 15 khoản 1 điểm c", domain := .bool }
  , { name := "Điều 15 · P5 trinh_do_chuyen_mon_phu_hop_nganh_nghe_san_xuat_ruou", source := "Điều 15 khoản 1 điểm d", domain := .bool }
  , { name := "Điều 15 · P6 dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou", source := "Điều 15 khoản 4 điểm b", domain := .bool } ]

def rS : List ReaderSpec :=
  [ ("Điều 15 · S1 do_con_tu_5_5_do_tro_len", 0, 1)
  , ("Điều 15 · S2 san_xuat_ruou_cong_nghiep", 1, 1)
  , ("Điều 15 · S3 san_xuat_ruou_thu_cong_nham_muc_dich_kinh_doanh", 2, 1)
  , ("Điều 15 · S4 san_xuat_ruou_thu_cong_ban_cho_co_so_co_giay_phep_de_che_bien_lai", 3, 1)
  , ("Điều 15 · S5 mua_ban_ruou", 4, 1)
  , ("Điều 15 · S6 loai_chu_the = doanh_nghiep", 5, 0)
  , ("Điều 15 · S6 loai_chu_the = hop_tac_xa", 5, 1)
  , ("Điều 15 · S6 loai_chu_the = lien_hiep_hop_tac_xa", 5, 2)
  , ("Điều 15 · S6 loai_chu_the = ho_kinh_doanh", 5, 3)
  , ("Điều 15 · S6 loai_chu_the = ho_gia_dinh", 5, 4)
  , ("Điều 15 · S6 loai_chu_the = ca_nhan", 5, 5)
  , ("Điều 15 · S7 co_day_chuyen_may_moc_thiet_bi_quy_trinh_cong_nghe", 6, 1)
  , ("Điều 15 · S8 co_nhan_vien_ky_thuat", 7, 1)
  , ("Điều 15 · S9 co_hop_dong_mua_ban_voi_co_so_co_giay_phep_san_xuat_ruou", 8, 1)
  , ("Điều 15 · S10 co_dang_ky_voi_ubnd_cap_xa_noi_co_co_so_san_xuat", 9, 1)
  , ("Điều 15 · S11 co_dang_ky_kinh_doanh", 10, 1) ]

def rP : List ReaderSpec :=
  [ ("Điều 15 · P1 duoc_thanh_lap_theo_quy_dinh_phap_luat", 0, 1)
  , ("Điều 15 · P2 day_chuyen_dap_ung_quy_mo_du_kien_san_xuat", 1, 1)
  , ("Điều 15 · P3 bao_dam_dieu_kien_an_toan_thuc_pham", 2, 1)
  , ("Điều 15 · P4 bao_dam_dieu_kien_bao_ve_moi_truong", 3, 1)
  , ("Điều 15 · P5 trinh_do_chuyen_mon_phu_hop_nganh_nghe_san_xuat_ruou", 4, 1)
  , ("Điều 15 · P6 dap_ung_dieu_kien_theo_loai_hinh_mua_ban_ruou", 5, 1) ]

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
  [ nrm "Điều 15:15.1" .permission "duoc_cap_phep_san_xuat_ruou_cong_nghiep" (.and (.sit 1) (.and (.sit 0) (.and (.sit 5) (.and (.param 0) (.and (.sit 11) (.and (.param 1) (.and (.param 2) (.and (.param 3) (.and (.sit 12) (.param 4)))))))))) [] "Điều 15 khoản 1" []
  , nrm "Điều 15:15.2" .permission "duoc_cap_phep_san_xuat_ruou_thu_cong" (.and (.sit 2) (.and (.sit 0) (.and (.or (.sit 5) (.or (.sit 6) (.or (.sit 7) (.sit 8)))) (.and (.param 0) (.param 2))))) [(.and (.sit 3) (.or (.sit 9) (.sit 10)))] "Điều 15 khoản 2" ["Điều 15 khoản 3"]
  , nrm "Điều 15:15.3" .permission "san_xuat_ruou_thu_cong_ban_cho_co_so_che_bien_lai" (.and (.sit 3) (.and (.sit 0) (.and (.or (.sit 9) (.sit 10)) (.and (.sit 13) (.and (.sit 14) (.param 2)))))) [] "Điều 15 khoản 3" []
  , nrm "Điều 15:15.4" .permission "duoc_cap_phep_mua_ban_ruou" (.and (.sit 4) (.and (.sit 0) (.and (.sit 15) (.param 5)))) [] "Điều 15 khoản 4" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 15 khoản 5", "Khoản này giao Chính phủ quy định chi tiết Điều 15 và quy định việc quản lý kinh doanh rượu có độ cồn dưới 5,5 độ; trong văn bản này không có quy phạm cấm, bắt buộc hay cho phép nào có điều kiện cụ thể.") ]

def acts : List Act := ["duoc_cap_phep_mua_ban_ruou", "duoc_cap_phep_san_xuat_ruou_cong_nghiep", "duoc_cap_phep_san_xuat_ruou_thu_cong", "san_xuat_ruou_thu_cong_ban_cho_co_so_che_bien_lai"]

def status : ReviewStatus := .reviewed "Vũ Đức Phong" ⟨2026, 11, 20⟩

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

end LexProof.Laws.Article15
