import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article13 — Điều 13 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article13.glossary.llm.json` (sha256 `cb543b4dec68babb7169e2c8f90189c9a7a14a502b2c97caeafc86995ff51ebf`), sheet `docs/review/duyet-ban-dich-dieu-13.md` (sha256 `9092a79cf9507b77477cf9361d466bb16d5de83a4f1c1b2154120618d47ba160`), Vũ Đức Phong, 2026-11-23: accepted 2, rejected 0

Assumptions accepted on the sheets:
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

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `c4d8dcbea47080c86e97ba4e42219d80e0f68f6102ac61fcec9eb85796a06758`); an id shared by two articles is ONE atom:
* act quang_cao_ruou_bia [approved]: quảng cáo rượu, bia (nguồn: Điều 5 khoản 7)
* atom do_con [approved]: độ cồn của rượu, bia (Điều 2 khoản 4 định nghĩa độ cồn) (nguồn: Điều 2 khoản 4; Điều 5 khoản 9)
*   nhãn «dưới 15 độ» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 2 khoản 4». Ghi chú: phần bù của «từ 15 độ trở lên» (Điều 5 khoản 9); Điều 11 có tiêu đề «có độ cồn dưới 15 độ». Chưa tách ngưỡng 5,5 độ của Điều 12, 13, 15
* atom loai_do_uong [approved]: đồ uống là rượu hay bia (nguồn: Điều 5 khoản 7; Điều 5 khoản 11 nhánh (i))
* atom do_con_nguong_5_5 [approved]: độ cồn của rượu so với ngưỡng 5,5 độ (nguồn: Điều 15 khoản 1; Điều 15 khoản 5)
* atom do_con_bia_nguong_5_5 [approved]: độ cồn của bia so với ngưỡng 5,5 độ (tương ứng với do_con_nguong_5_5 nhưng dành cho bia, vì mục đó chỉ nói về rượu) (nguồn: Điều 13)
*   nhãn «dưới 5,5 độ» không có khoản nào nêu; nguồn ghi trong Lean là «Điều 13». Ghi chú: Điều 13 chỉ nêu bia «có độ cồn từ 5,5 độ trở lên»; nhãn này là phần bù để miền giá trị đầy đủ
* atom quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao [approved]: việc quảng cáo diễn ra trong các chương trình, hoạt động văn hóa, sân khấu, điện ảnh, thể thao (nguồn: Điều 13 khoản 1)
* atom quang_cao_tren_phuong_tien_quang_cao_ngoai_troi [approved]: việc quảng cáo được thực hiện trên phương tiện quảng cáo ngoài trời (nguồn: Điều 13 khoản 2)
* atom la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia [approved]: phương tiện quảng cáo là biển hiệu của cơ sở kinh doanh rượu, bia (nguồn: Điều 13 khoản 2)
-/

namespace LexProof.Laws.Article13

open LexProof

def tS : AtomTable :=
  [ { name := "do_con", source := "Điều 2 khoản 4", domain := .enum [⟨"dưới 15 độ", "Điều 2 khoản 4"⟩, ⟨"từ 15 độ trở lên", "Điều 5 khoản 9"⟩] }
  , { name := "loai_do_uong", source := "Điều 5 khoản 7", domain := .enum [⟨"rượu", "Điều 5 khoản 7"⟩, ⟨"bia", "Điều 5 khoản 12 nhánh (ii)"⟩] }
  , { name := "do_con_nguong_5_5", source := "Điều 15 khoản 1", domain := .enum [⟨"dưới 5,5 độ", "Điều 15 khoản 5"⟩, ⟨"từ 5,5 độ trở lên", "Điều 15 khoản 1"⟩] }
  , { name := "do_con_bia_nguong_5_5", source := "Điều 13", domain := .enum [⟨"dưới 5,5 độ", "Điều 13"⟩, ⟨"từ 5,5 độ trở lên", "Điều 13"⟩] }
  , { name := "quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao", source := "Điều 13 khoản 1", domain := .bool }
  , { name := "quang_cao_tren_phuong_tien_quang_cao_ngoai_troi", source := "Điều 13 khoản 2", domain := .bool }
  , { name := "la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia", source := "Điều 13 khoản 2", domain := .bool } ]

def tP : AtomTable :=
  []

def rS : List ReaderSpec :=
  [ ("do_con = dưới 15 độ", 0, 0)
  , ("do_con = từ 15 độ trở lên", 0, 1)
  , ("loai_do_uong = rượu", 1, 0)
  , ("loai_do_uong = bia", 1, 1)
  , ("do_con_nguong_5_5 = dưới 5,5 độ", 2, 0)
  , ("do_con_nguong_5_5 = từ 5,5 độ trở lên", 2, 1)
  , ("do_con_bia_nguong_5_5 = dưới 5,5 độ", 3, 0)
  , ("do_con_bia_nguong_5_5 = từ 5,5 độ trở lên", 3, 1)
  , ("quang_cao_trong_chuong_trinh_hoat_dong_van_hoa_san_khau_dien_anh_the_thao", 4, 1)
  , ("quang_cao_tren_phuong_tien_quang_cao_ngoai_troi", 5, 1)
  , ("la_bien_hieu_cua_co_so_kinh_doanh_ruou_bia", 6, 1) ]

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
  [ nrm "Điều 13:13.1" .prohibition "quang_cao_ruou_bia" (.and (.or (.and (.sit 2) (.and (.sit 5) (.sit 0))) (.and (.sit 3) (.sit 7))) (.sit 8)) [] "Điều 13 khoản 1" []
  , nrm "Điều 13:13.2" .prohibition "quang_cao_ruou_bia" (.and (.or (.and (.sit 2) (.and (.sit 5) (.sit 0))) (.and (.sit 3) (.sit 7))) (.sit 9)) [(.sit 10)] "Điều 13 khoản 2" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 13", "Phần «phải tuân thủ quy định tại Điều 12 của Luật này» trong đoạn dẫn chỉ dẫn chiếu sang Điều 12, không tự đặt ra nội dung nghĩa vụ. Nghĩa vụ đó thuộc phần mã hóa Điều 12, nên ở đây không tạo norm riêng.") ]

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

end LexProof.Laws.Article13
