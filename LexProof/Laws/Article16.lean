import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article16 — Điều 16 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article16.glossary.llm.json` (sha256 `77d47d0e74a5b7eea5ab3fc7c89696883a08f6d6d83ea004edcf2acd908da2a8`), sheet `docs/review/duyet-ban-dich-dieu-16.md` (sha256 `40e6d1149df4f119aa65e7c47d198839c92c33b0bc567ba53b20bfc2f664b13d`), Vũ Đức Phong, 2026-11-24: accepted 4, rejected 0

Assumptions accepted on the sheets:
* Điều 16: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 16: Tiêu đề «Điều kiện bán rượu, bia theo hình thức thương mại điện tử» cho biết các khoản là điều kiện của việc bán; áp dụng quy tắc 7 và 11: bốn khoản là bốn điều kiện cùng phải đủ.
* Điều 16: Mỗi điều kiện được biểu diễn là một lệnh cấm bán rượu, bia theo hình thức thương mại điện tử khi thiếu điều kiện đó (điều kiện: bán qua thương mại điện tử và không đáp ứng điều kiện); không biểu diễn là nghĩa vụ phải bán, vì nghĩa vụ đó sai nghĩa.
* Điều 16: Không dùng quyền được phép: luật nêu điều kiện, không trao quyền bán nào ngoài các điều khác.
* Điều 16: Khoản 1 dẫn chiếu Điều 15 khoản 4, khoản 5 và Điều 18; nội dung các đơn vị đó không được lặp lại ở đây, chỉ có một atom «đáp ứng» và «references» ghi nơi dẫn chiếu.
* Điều 16: Khoản 2 dẫn chiếu pháp luật về thương mại điện tử (văn bản khác), nên là một atom bool không có nội dung điều kiện; không ghi vào «references».
* Điều 16: Khoản 3 dẫn chiếu quy định của Chính phủ (văn bản khác); nội dung biện pháp không được mã hóa, chỉ có atom bool «thực hiện biện pháp».
* Điều 16: Chữ «hình thức thanh toán không dùng tiền mặt» ở khoản 4 giữ nguyên là atom bool, không định nghĩa thêm.

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe`); an id shared by two articles is ONE atom:
* act ban_ruou_bia [approved]: bán rượu, bia (trao đổi có trả tiền) (nguồn: Điều 5 khoản 3; Điều 19 tiêu đề)
* atom ban_theo_hinh_thuc_thuong_mai_dien_tu [approved]: việc bán rượu, bia được thực hiện theo hình thức thương mại điện tử (nguồn: Điều 16 tiêu đề)
* atom dap_ung_quy_dinh_dieu_15_khoan_4_5_va_dieu_18 [approved]: đáp ứng quy định tại khoản 4, khoản 5 Điều 15 và Điều 18 của Luật (nguồn: Điều 16 khoản 1)
* atom dap_ung_dieu_kien_phap_luat_thuong_mai_dien_tu [approved]: đáp ứng điều kiện theo quy định của pháp luật về thương mại điện tử (nội dung do văn bản khác quy định) (nguồn: Điều 16 khoản 2)
* atom thuc_hien_bien_phap_ngan_nguoi_chua_du_18_tiep_can_mua_ruou_bia [approved]: thực hiện biện pháp theo quy định của Chính phủ để ngăn người chưa đủ 18 tuổi tiếp cận, truy cập, tìm kiếm thông tin và mua rượu, bia (nội dung biện pháp do Chính phủ quy định) (nguồn: Điều 16 khoản 3)
* atom ap_dung_thanh_toan_khong_dung_tien_mat [approved]: áp dụng hình thức thanh toán không dùng tiền mặt (nguồn: Điều 16 khoản 4)
-/

namespace LexProof.Laws.Article16

open LexProof

def tS : AtomTable :=
  [ { name := "ban_theo_hinh_thuc_thuong_mai_dien_tu", source := "Điều 16 tiêu đề", domain := .bool }
  , { name := "dap_ung_quy_dinh_dieu_15_khoan_4_5_va_dieu_18", source := "Điều 16 khoản 1", domain := .bool }
  , { name := "dap_ung_dieu_kien_phap_luat_thuong_mai_dien_tu", source := "Điều 16 khoản 2", domain := .bool }
  , { name := "thuc_hien_bien_phap_ngan_nguoi_chua_du_18_tiep_can_mua_ruou_bia", source := "Điều 16 khoản 3", domain := .bool }
  , { name := "ap_dung_thanh_toan_khong_dung_tien_mat", source := "Điều 16 khoản 4", domain := .bool } ]

def tP : AtomTable :=
  []

def rS : List ReaderSpec :=
  [ ("ban_theo_hinh_thuc_thuong_mai_dien_tu", 0, 1)
  , ("dap_ung_quy_dinh_dieu_15_khoan_4_5_va_dieu_18", 1, 1)
  , ("dap_ung_dieu_kien_phap_luat_thuong_mai_dien_tu", 2, 1)
  , ("thuc_hien_bien_phap_ngan_nguoi_chua_du_18_tiep_can_mua_ruou_bia", 3, 1)
  , ("ap_dung_thanh_toan_khong_dung_tien_mat", 4, 1) ]

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
  [ nrm "Điều 16:16.1" .prohibition "ban_ruou_bia" (.and (.sit 0) (.not (.sit 1))) [] "Điều 16 khoản 1" ["Điều 15 khoản 4", "Điều 15 khoản 5", "Điều 18"]
  , nrm "Điều 16:16.2" .prohibition "ban_ruou_bia" (.and (.sit 0) (.not (.sit 2))) [] "Điều 16 khoản 2" []
  , nrm "Điều 16:16.3" .prohibition "ban_ruou_bia" (.and (.sit 0) (.not (.sit 3))) [] "Điều 16 khoản 3" []
  , nrm "Điều 16:16.4" .prohibition "ban_ruou_bia" (.and (.sit 0) (.not (.sit 4))) [] "Điều 16 khoản 4" [] ]

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

end LexProof.Laws.Article16
