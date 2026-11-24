import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article34 — Điều 34 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article34.glossary.llm.json` (sha256 `4d56cccf85d041dae698eebfa5575d347432f045418976483d3de94c1671f3b1`), sheet `docs/review/duyet-ban-dich-dieu-34.md` (sha256 `81a74effebd614b8814cb6e22618094ea6294c1aa1f2898a72bebc7630694b08`), Vũ Đức Phong, 2026-11-24: accepted 3, rejected 0

Assumptions accepted on the sheets:
* Điều 34: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 34: Tiêu đề «Trách nhiệm của gia đình...» cho biết các khoản là nghĩa vụ của gia đình (quy tắc 7).
* Điều 34: Chủ thể «gia đình» không được mã hóa thành atom; điều kiện là true.
* Điều 34: Khoản 1 chỉ mã hóa phần giáo dục, giám sát, nhắc nhở thành viên chưa đủ 18 tuổi (nhánh (i)); hai phần còn lại ở not_encoded.
* Điều 34: Các nghĩa vụ là làm một việc, không trùng hành vi của các điều cấm trong bảng, nên không tạo cặp phương thức khắc nhau.

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe`); an id shared by two articles is ONE atom:
* act giao_duc_giam_sat_nhac_nho_thanh_vien_chua_du_18_khong_uong_ruou_bia [approved]: giáo dục, giám sát, nhắc nhở thành viên gia đình chưa đủ 18 tuổi không uống rượu, bia (nguồn: Điều 34 khoản 1)
* act huong_dan_thanh_vien_gia_dinh_ky_nang_tu_choi_uong_ung_xu_nguoi_say_nghien [approved]: hướng dẫn các thành viên trong gia đình kỹ năng từ chối uống rượu, bia; kỹ năng nhận biết, ứng xử, xử trí khi gặp người say rượu, bia, người nghiện rượu, bia và thực hiện các biện pháp phòng, chống tác hại (nguồn: Điều 34 khoản 2)
* act gia_dinh_tham_gia_cung_co_quan_to_chuc_cong_dong_phong_chong_tac_hai_ruou_bia [approved]: gia đình tham gia với các cơ quan, tổ chức và cộng đồng thực hiện phòng, chống tác hại của rượu, bia (nguồn: Điều 34 khoản 3)
-/

namespace LexProof.Laws.Article34

open LexProof

def tS : AtomTable :=
  []

def tP : AtomTable :=
  []

def rS : List ReaderSpec :=
  []

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
  [ nrm "Điều 34:34.1.i" .obligation "giao_duc_giam_sat_nhac_nho_thanh_vien_chua_du_18_khong_uong_ruou_bia" .tt [] "Điều 34 khoản 1 nhánh (i)" []
  , nrm "Điều 34:34.2" .obligation "huong_dan_thanh_vien_gia_dinh_ky_nang_tu_choi_uong_ung_xu_nguoi_say_nghien" .tt [] "Điều 34 khoản 2" []
  , nrm "Điều 34:34.3" .obligation "gia_dinh_tham_gia_cung_co_quan_to_chuc_cong_dong_phong_chong_tac_hai_ruou_bia" .tt [] "Điều 34 khoản 3" [] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 34 khoản 1", "Hai phần sau của khoản («các thành viên khác trong gia đình hạn chế uống rượu, bia»; «động viên, giúp đỡ người nghiện rượu, bia trong gia đình cai nghiện») dùng chuẩn mở «hạn chế», «động viên, giúp đỡ» không có mức đo; không đoán, để người duyệt quyết định.") ]

def acts : List Act := ["gia_dinh_tham_gia_cung_co_quan_to_chuc_cong_dong_phong_chong_tac_hai_ruou_bia", "giao_duc_giam_sat_nhac_nho_thanh_vien_chua_du_18_khong_uong_ruou_bia", "huong_dan_thanh_vien_gia_dinh_ky_nang_tu_choi_uong_ung_xu_nguoi_say_nghien"]

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

end LexProof.Laws.Article34
