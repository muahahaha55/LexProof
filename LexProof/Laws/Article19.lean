import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article19 — Điều 19 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article19.glossary.llm.json` (sha256 `35347eacb9bfcd366544cb140e34a6d850e93795e347b535d15f368e74011b96`), sheet `docs/review/duyet-ban-dich-dieu-19-lan-2.md` (sha256 `5a0ed1c381bac7ed6df8975fa653f9a710713256351d615b7075894e43226d2b`), Vũ Đức Phong, 2026-11-24: accepted 6, rejected 0

Assumptions accepted on the sheets:
* Điều 19: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 19: Tiêu đề «Địa điểm không bán rượu, bia» được áp dụng cho cả 6 khoản: mỗi khoản là một lệnh cấm bán rượu, bia tại địa điểm nêu (quy tắc 7); act dùng chung là ban_ruou_bia.
* Điều 19: Mỗi khoản là một norm; các loại địa điểm liệt kê trong cùng khoản đã được gộp trong một atom của bảng thuật ngữ (dia_diem_cai_nghien_giam_giu, dia_diem_noi_lam_viec_co_quan), không tách «nhánh».
* Điều 19: Khoản 3: «dành cho người chưa đủ 18 tuổi» là khái niệm mở nên dùng tham số danh_cho_nguoi_chua_du_18; đọc cụm này bổ nghĩa cho cả bốn loại (chăm sóc, nuôi dưỡng, vui chơi, giải trí), nên điều kiện là địa điểm và tham số.
* Điều 19: Khoản 6: «trừ địa điểm được phép kinh doanh rượu, bia» là ngoại lệ (exceptions), không phải quyền được phép; việc một địa điểm được phép kinh doanh do quy định khác xác định nên là atom dia_diem_duoc_phep_kinh_doanh, không suy ra giá trị; ngoại lệ áp dụng cho toàn bộ danh sách nơi làm việc trong khoản.
* Điều 19: Khác Điều 10 khoản 2, Điều 19 khoản 2 chỉ ghi «Cơ sở giáo dục», không có điều kiện về thời gian; norm 19.2 vì vậy không có điều kiện thời gian.
* Điều 19: Chỉ mã hóa hành vi «bán» theo tiêu đề điều; không mở rộng sang uống hay mang vào.

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe`); an id shared by two articles is ONE atom:
* act ban_ruou_bia [approved]: bán rượu, bia (trao đổi có trả tiền) (nguồn: Điều 5 khoản 3; Điều 19 tiêu đề)
* atom dia_diem_co_so_y_te [approved]: địa điểm là cơ sở y tế (nguồn: Điều 19 khoản 1)
* atom dia_diem_co_so_giao_duc [approved]: địa điểm là cơ sở giáo dục (nguồn: Điều 19 khoản 2)
* atom dia_diem_cham_soc_vui_choi [approved]: địa điểm là cơ sở hoặc khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí (nguồn: Điều 19 khoản 3)
* atom dia_diem_cai_nghien_giam_giu [approved]: địa điểm là cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân hoặc cơ sở giam giữ khác (nguồn: Điều 19 khoản 4)
* atom dia_diem_bao_tro_xa_hoi [approved]: địa điểm là cơ sở bảo trợ xã hội (nguồn: Điều 19 khoản 5)
* atom dia_diem_noi_lam_viec_co_quan [approved]: địa điểm là nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập (nguồn: Điều 19 khoản 6)
* atom dia_diem_duoc_phep_kinh_doanh [approved]: địa điểm được phép kinh doanh rượu, bia (ngoại lệ của Điều 19 khoản 6) (nguồn: Điều 19 khoản 6)
* atom danh_cho_nguoi_chua_du_18 [approved]: địa điểm «dành cho» người chưa đủ 18 tuổi (khái niệm mở, luật không định nghĩa) (nguồn: Điều 19 khoản 3)
-/

namespace LexProof.Laws.Article19

open LexProof

def tS : AtomTable :=
  [ { name := "dia_diem_co_so_y_te", source := "Điều 19 khoản 1", domain := .bool }
  , { name := "dia_diem_co_so_giao_duc", source := "Điều 19 khoản 2", domain := .bool }
  , { name := "dia_diem_cham_soc_vui_choi", source := "Điều 19 khoản 3", domain := .bool }
  , { name := "dia_diem_cai_nghien_giam_giu", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "dia_diem_bao_tro_xa_hoi", source := "Điều 19 khoản 5", domain := .bool }
  , { name := "dia_diem_noi_lam_viec_co_quan", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "dia_diem_duoc_phep_kinh_doanh", source := "Điều 19 khoản 6", domain := .bool } ]

def tP : AtomTable :=
  [ { name := "danh_cho_nguoi_chua_du_18", source := "Điều 19 khoản 3", domain := .bool } ]

def rS : List ReaderSpec :=
  [ ("dia_diem_co_so_y_te", 0, 1)
  , ("dia_diem_co_so_giao_duc", 1, 1)
  , ("dia_diem_cham_soc_vui_choi", 2, 1)
  , ("dia_diem_cai_nghien_giam_giu", 3, 1)
  , ("dia_diem_bao_tro_xa_hoi", 4, 1)
  , ("dia_diem_noi_lam_viec_co_quan", 5, 1)
  , ("dia_diem_duoc_phep_kinh_doanh", 6, 1) ]

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
  [ nrm "Điều 19:19.1" .prohibition "ban_ruou_bia" (.sit 0) [] "Điều 19 khoản 1" []
  , nrm "Điều 19:19.2" .prohibition "ban_ruou_bia" (.sit 1) [] "Điều 19 khoản 2" []
  , nrm "Điều 19:19.3" .prohibition "ban_ruou_bia" (.and (.sit 2) (.param 0)) [] "Điều 19 khoản 3" []
  , nrm "Điều 19:19.4" .prohibition "ban_ruou_bia" (.sit 3) [] "Điều 19 khoản 4" []
  , nrm "Điều 19:19.5" .prohibition "ban_ruou_bia" (.sit 4) [] "Điều 19 khoản 5" []
  , nrm "Điều 19:19.6" .prohibition "ban_ruou_bia" (.sit 5) [(.sit 6)] "Điều 19 khoản 6" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  []

def acts : List Act := ["ban_ruou_bia"]

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

/-- What `analyzeReport` prints for this module (always print this, not only the core result). -/
def report : List String := (analyzeReport status acts tS tP rS rP catalog norms).render

end LexProof.Laws.Article19
