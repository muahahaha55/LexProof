import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article10 — Điều 10 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article10.glossary.llm.json` (sha256 `def1c42962edf074ffe3e503f8488d95b553555658babb211b00e518aaecf3a6`), sheet `docs/review/duyet-ban-dich-dieu-10.md` (sha256 `6ddbcd61c3850e350af7d8862a2f84d08256ce030f494b0afa0b4d6902e10499`), Vũ Đức Phong, 2026-11-23: accepted 6, rejected 0

Assumptions accepted on the sheets:
* Điều 10: Tiêu đề «Địa điểm không uống rượu, bia» được đọc là lệnh cấm uống rượu, bia tại các địa điểm ở khoản 1–7 (quy tắc 7), nên mọi norm có modality prohibition và act uong_ruou_bia.
* Điều 10: Lệnh cấm áp dụng cho bất kỳ người uống nào; Điều 10 không giới hạn chủ thể nên không có điều kiện về người uống.
* Điều 10: Các atom địa điểm của bảng (dia_diem_co_so_y_te, dia_diem_co_so_giao_duc, dia_diem_cham_soc_vui_choi, dia_diem_cai_nghien_giam_giu, dia_diem_bao_tro_xa_hoi, dia_diem_noi_lam_viec_co_quan, dia_diem_duoc_phep_kinh_doanh) có nguồn là Điều 19 nhưng cùng nghĩa với các địa điểm ở Điều 10, nên được dùng lại theo quy tắc 12.
* Điều 10: «Trong thời gian giảng dạy, học tập, làm việc» (khoản 2) và «trong thời gian làm việc» (khoản 6) được đọc là thời gian hoạt động của cơ sở hay cơ quan, không phải giờ của riêng người uống, nên không dùng trong_gio_lam_viec_hoc_tap mà đề xuất hai atom mới.
* Điều 10: Ở khoản 3, cụm «dành cho người chưa đủ 18 tuổi» được đọc là bổ nghĩa cho toàn bộ «cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí»; đây là khái niệm mở nên dùng tham số danh_cho_nguoi_chua_du_18.
* Điều 10: Ở khoản 6, «trừ địa điểm được phép kinh doanh rượu, bia» được mã hóa là ngoại lệ (quy tắc 8), không phải quyền được uống.
* Điều 10: Khoản 7 dẫn chiếu tới quy định của Chính phủ (văn bản khác), nên không ghi vào «references».
* Điều 10: Ngày hiệu lực 2020-01-01 không có trong đoạn chữ được cung cấp; giá trị này lấy từ hiểu biết bên ngoài về Luật 44/2019/QH14 và cần người duyệt kiểm tra.

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`); an id shared by two articles is ONE atom:
* act uong_ruou_bia [approved]: uống rượu, bia (nguồn: Điều 5 khoản 2; Điều 5 khoản 5)
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
-/

namespace LexProof.Laws.Article10

open LexProof

def tS : AtomTable :=
  [ { name := "dia_diem_co_so_y_te", source := "Điều 19 khoản 1", domain := .bool }
  , { name := "dia_diem_co_so_giao_duc", source := "Điều 19 khoản 2", domain := .bool }
  , { name := "dia_diem_cham_soc_vui_choi", source := "Điều 19 khoản 3", domain := .bool }
  , { name := "dia_diem_cai_nghien_giam_giu", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "dia_diem_bao_tro_xa_hoi", source := "Điều 19 khoản 5", domain := .bool }
  , { name := "dia_diem_noi_lam_viec_co_quan", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "dia_diem_duoc_phep_kinh_doanh", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "trong_thoi_gian_giang_day_hoc_tap_lam_viec_cua_co_so_giao_duc", source := "Điều 10 khoản 2", domain := .bool }
  , { name := "trong_thoi_gian_lam_viec_cua_co_quan_to_chuc", source := "Điều 10 khoản 6", domain := .bool } ]

def tP : AtomTable :=
  [ { name := "danh_cho_nguoi_chua_du_18", source := "Điều 19 khoản 3", domain := .bool } ]

def rS : List ReaderSpec :=
  [ ("dia_diem_co_so_y_te", 0, 1)
  , ("dia_diem_co_so_giao_duc", 1, 1)
  , ("dia_diem_cham_soc_vui_choi", 2, 1)
  , ("dia_diem_cai_nghien_giam_giu", 3, 1)
  , ("dia_diem_bao_tro_xa_hoi", 4, 1)
  , ("dia_diem_noi_lam_viec_co_quan", 5, 1)
  , ("dia_diem_duoc_phep_kinh_doanh", 6, 1)
  , ("trong_thoi_gian_giang_day_hoc_tap_lam_viec_cua_co_so_giao_duc", 7, 1)
  , ("trong_thoi_gian_lam_viec_cua_co_quan_to_chuc", 8, 1) ]

def rP : List ReaderSpec :=
  [ ("danh_cho_nguoi_chua_du_18", 0, 1) ]

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
  [ nrm "Điều 10:10.1" .prohibition "uong_ruou_bia" (.sit 0) [] "Điều 10 khoản 1" []
  , nrm "Điều 10:10.2" .prohibition "uong_ruou_bia" (.and (.sit 1) (.sit 7)) [] "Điều 10 khoản 2" []
  , nrm "Điều 10:10.3" .prohibition "uong_ruou_bia" (.and (.sit 2) (.param 0)) [] "Điều 10 khoản 3" []
  , nrm "Điều 10:10.4" .prohibition "uong_ruou_bia" (.sit 3) [] "Điều 10 khoản 4" []
  , nrm "Điều 10:10.5" .prohibition "uong_ruou_bia" (.sit 4) [] "Điều 10 khoản 5" []
  , nrm "Điều 10:10.6" .prohibition "uong_ruou_bia" (.and (.sit 5) (.sit 8)) [(.sit 6)] "Điều 10 khoản 6" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 10 khoản 7", "Danh mục «địa điểm công cộng» do Chính phủ quy định trong văn bản khác; chữ của Điều 10 không cho biết địa điểm nào thuộc diện này nên không thể mã hóa điều kiện mà không đoán nội dung văn bản đó.") ]

def acts : List Act := ["uong_ruou_bia"]

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

end LexProof.Laws.Article10
