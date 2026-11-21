import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article19 — Điều 19 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atom names and norm ids carry their article («Điều 5 · ...»): two articles never share an atom, so a
conflict that depends on a concept shared by two articles can be missed (no translation here uses the glossary).

Review sheets:
* `eval/translate/article19.llm.json` (sha256 `043f2377c73c490ce9c31a4ae11877d6d02039c8acc85ddd10dcacbe1bbb42f3`), sheet `docs/review/duyet-ban-dich-dieu-19.md` (sha256 `efd53de9c2ce14d0059829732eed792fcced95100402a498e79cb62a9b6e9937`), Vũ Đức Phong, 2026-11-20: accepted 6, rejected 0

Assumptions accepted on the sheets:
* Điều 19: Tiêu đề Điều 19 («Địa điểm không bán rượu, bia») được áp dụng cho cả 6 khoản: mỗi khoản là một lệnh cấm (prohibition) đối với hành vi bán rượu, bia tại địa điểm nêu; act dùng chung là ban_ruou_bia.
* Điều 19: Ngày hiệu lực 2020-01-01 không có trong đoạn văn bản được cung cấp; đây là thông tin ngoài văn bản, cần người đối chiếu xác nhận.
* Điều 19: Mỗi khoản được mã hóa thành một norm, các loại địa điểm liệt kê trong cùng khoản được nối bằng «or» (không tách thành nhiều norm bằng «nhánh»).
* Điều 19: Khoản 3: «dành cho người chưa đủ 18 tuổi» là khái niệm mở nên đặt thành tham số P1, không tự quyết giá trị; đọc cụm này bổ nghĩa cho cả bốn loại (chăm sóc, nuôi dưỡng, vui chơi, giải trí), nên điều kiện là S3 và P1.
* Điều 19: Khoản 4: «cơ sở giam giữ phạm nhân» và «cơ sở giam giữ khác» được tách thành hai atom riêng (S7, S8); «cơ sở giáo dục bắt buộc» được hiểu là một loại cơ sở duy nhất.
* Điều 19: Khoản 6: «trừ địa điểm được phép kinh doanh rượu, bia» là ngoại lệ (exceptions), không phải quyền được phép; việc một địa điểm được phép kinh doanh do quy định khác xác định nên được mã hóa là atom tình huống S15 và không suy ra giá trị.
* Điều 19: Khoản 6: ngoại lệ S15 được áp dụng cho toàn bộ danh sách nơi làm việc trong khoản (cơ quan nhà nước, các tổ chức chính trị, đơn vị sự nghiệp công lập), không chỉ cho mục cuối.
* Điều 19: Chỉ mã hóa hành vi «bán» theo tiêu đề điều; không mở rộng sang các hành vi khác như uống hay mang vào.
-/

namespace LexProof.Laws.Article19

open LexProof

def tS : AtomTable :=
  [ { name := "Điều 19 · S1 Địa điểm là cơ sở y tế", source := "Điều 19 khoản 1", domain := .bool }
  , { name := "Điều 19 · S2 Địa điểm là cơ sở giáo dục", source := "Điều 19 khoản 2", domain := .bool }
  , { name := "Điều 19 · S3 Địa điểm là cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí", source := "Điều 19 khoản 3", domain := .bool }
  , { name := "Điều 19 · S4 Địa điểm là cơ sở cai nghiện", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "Điều 19 · S5 Địa điểm là cơ sở giáo dục bắt buộc", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "Điều 19 · S6 Địa điểm là trường giáo dưỡng", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "Điều 19 · S7 Địa điểm là cơ sở giam giữ phạm nhân", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "Điều 19 · S8 Địa điểm là cơ sở giam giữ khác", source := "Điều 19 khoản 4", domain := .bool }
  , { name := "Điều 19 · S9 Địa điểm là cơ sở bảo trợ xã hội", source := "Điều 19 khoản 5", domain := .bool }
  , { name := "Điều 19 · S10 Địa điểm là nơi làm việc của cơ quan nhà nước", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "Điều 19 · S11 Địa điểm là nơi làm việc của tổ chức chính trị", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "Điều 19 · S12 Địa điểm là nơi làm việc của tổ chức chính trị - xã hội", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "Điều 19 · S13 Địa điểm là nơi làm việc của tổ chức chính trị xã hội - nghề nghiệp", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "Điều 19 · S14 Địa điểm là nơi làm việc của đơn vị sự nghiệp công lập", source := "Điều 19 khoản 6", domain := .bool }
  , { name := "Điều 19 · S15 Địa điểm là địa điểm được phép kinh doanh rượu, bia", source := "Điều 19 khoản 6", domain := .bool } ]

def tP : AtomTable :=
  [ { name := "Điều 19 · P1 Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí là nơi dành cho người chưa đủ 18 tuổi", source := "Điều 19 khoản 3", domain := .bool } ]

def rS : List ReaderSpec :=
  [ ("Điều 19 · S1 Địa điểm là cơ sở y tế", 0, 1)
  , ("Điều 19 · S2 Địa điểm là cơ sở giáo dục", 1, 1)
  , ("Điều 19 · S3 Địa điểm là cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí", 2, 1)
  , ("Điều 19 · S4 Địa điểm là cơ sở cai nghiện", 3, 1)
  , ("Điều 19 · S5 Địa điểm là cơ sở giáo dục bắt buộc", 4, 1)
  , ("Điều 19 · S6 Địa điểm là trường giáo dưỡng", 5, 1)
  , ("Điều 19 · S7 Địa điểm là cơ sở giam giữ phạm nhân", 6, 1)
  , ("Điều 19 · S8 Địa điểm là cơ sở giam giữ khác", 7, 1)
  , ("Điều 19 · S9 Địa điểm là cơ sở bảo trợ xã hội", 8, 1)
  , ("Điều 19 · S10 Địa điểm là nơi làm việc của cơ quan nhà nước", 9, 1)
  , ("Điều 19 · S11 Địa điểm là nơi làm việc của tổ chức chính trị", 10, 1)
  , ("Điều 19 · S12 Địa điểm là nơi làm việc của tổ chức chính trị - xã hội", 11, 1)
  , ("Điều 19 · S13 Địa điểm là nơi làm việc của tổ chức chính trị xã hội - nghề nghiệp", 12, 1)
  , ("Điều 19 · S14 Địa điểm là nơi làm việc của đơn vị sự nghiệp công lập", 13, 1)
  , ("Điều 19 · S15 Địa điểm là địa điểm được phép kinh doanh rượu, bia", 14, 1) ]

def rP : List ReaderSpec :=
  [ ("Điều 19 · P1 Cơ sở, khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí là nơi dành cho người chưa đủ 18 tuổi", 0, 1) ]

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
  , nrm "Điều 19:19.4" .prohibition "ban_ruou_bia" (.or (.sit 3) (.or (.sit 4) (.or (.sit 5) (.or (.sit 6) (.sit 7))))) [] "Điều 19 khoản 4" []
  , nrm "Điều 19:19.5" .prohibition "ban_ruou_bia" (.sit 8) [] "Điều 19 khoản 5" []
  , nrm "Điều 19:19.6" .prohibition "ban_ruou_bia" (.or (.sit 9) (.or (.sit 10) (.or (.sit 11) (.or (.sit 12) (.sit 13))))) [(.sit 14)] "Điều 19 khoản 6" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  []

def acts : List Act := ["ban_ruou_bia"]

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

end LexProof.Laws.Article19
