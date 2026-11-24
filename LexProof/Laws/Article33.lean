import LexProof.Verify.AnalyzeReport
import LexProof.Core.Render
import LexProof.Core.ClauseRef

/-!
# Article33 — Điều 33 (44/2019/QH14), norms from an AI translation accepted on a review sheet

Written by `pipeline/promote.py 1.0`. **Reviewed** here means only: a person ticked every row of the sheet(s) below, and
the sheet names the sha256 of the translation it was about. The tool does not check who the person is, nor
whether the answers are right. Faithfulness to the law is not proved by anything in this file.

Atoms of the glossary keep their id and are shared by every article that uses them; every term used was
`approved` in the glossary file named below (ADR-0027). Other atom names, and all norm ids, carry their article.
A wrong merge (two different concepts under one id) is stopped only by the glossary reviewer.

Review sheets:
* `eval/translate/article33.glossary.llm.json` (sha256 `d86cc2f22edb7f74ca62072ce15db450406eda791f3344f9d0f156aee057f2ff`), sheet `docs/review/duyet-ban-dich-dieu-33.md` (sha256 `fa1e373b6a8fa3f3e197a0dfd3af6f11b793c0e6253c4208275a1f2770d09058`), Vũ Đức Phong, 2026-11-24: accepted 6, rejected 0

Assumptions accepted on the sheets:
* Điều 33: «effective» = 2020-01-01 lấy theo ngày hiệu lực đã biết của Luật 44/2019/QH14, không có trong đoạn văn được cung cấp; người duyệt cần đối chiếu.
* Điều 33: Tiêu đề «Trách nhiệm của người đứng đầu...» và chữ «có trách nhiệm» cho biết các khoản là nghĩa vụ (quy tắc 7).
* Điều 33: Chủ thể (người đứng đầu cơ quan, tổ chức; người quản lý địa điểm) không được mã hóa thành atom vì bảng thuật ngữ không có atom chủ thể loại này; điều kiện của phần lớn norm là true.
* Điều 33: Khoản 1 có hai nghĩa vụ ngăn bằng dấu chấm phẩy, tách thành nhánh (i) và (ii).
* Điều 33: Khoản 3 điểm a có hai nghĩa vụ ngăn bằng dấu chấm phẩy: nhắc nhở và từ chối dịch vụ, tách thành nhánh (i) và (ii); nghĩa vụ thứ hai có điều kiện «tiếp tục vi phạm sau khi đã được nhắc nhở».
* Điều 33: Nội dung Điều 10 và Điều 19 không lặp lại ở đây; «references» ghi nơi dẫn chiếu. Điều 24 chỉ có «vận động», «tuyên truyền» nên không mã hóa, norm 33.2 dẫn chiếu tới nó mà không dựng lại nội dung.
* Điều 33: Các nghĩa vụ ở đây là nghĩa vụ làm một việc (tổ chức, nhắc nhở, từ chối), không trùng hành vi nào của các điều cấm trong bảng, nên không tạo cặp phương thức khắc nhau.

Glossary terms used (`data/glossary/44-2019-QH14.json`, sha256 `2d192705747a96340ccb68db20fd11537d1aef5741b16654aa8028f8309a5bfe`); an id shared by two articles is ONE atom:
* act to_chuc_thuc_hien_bien_phap_phong_chong_tac_hai_ruou_bia [approved]: tổ chức thực hiện các biện pháp phòng, chống tác hại của rượu, bia trong phạm vi nhiệm vụ, quyền hạn của người đứng đầu (nguồn: Điều 33 khoản 1)
* act to_chuc_thuc_hien_nghiem_quy_dinh_khong_uong_ruou_bia_trong_gio_lam_viec_tai_noi_lam_viec [approved]: tổ chức thực hiện nghiêm quy định không uống rượu, bia trong thời gian làm việc, tại nơi làm việc của cơ quan, tổ chức (nguồn: Điều 33 khoản 1)
* act tham_gia_hoat_dong_phong_chong_tac_hai_ruou_bia_tai_cong_dong_theo_dieu_24 [approved]: tham gia các hoạt động phòng, chống tác hại của rượu, bia tại cơ sở, cộng đồng quy định tại Điều 24 (nguồn: Điều 33 khoản 2)
* act nhac_nho_yeu_cau_cham_dut_vi_pham_dieu_10_va_19 [approved]: nhắc nhở, yêu cầu chấm dứt hành vi vi phạm quy định tại Điều 10 và Điều 19 tại địa điểm thuộc quyền quản lý (nguồn: Điều 33 khoản 3 điểm a)
* act tu_choi_cung_cap_dich_vu_cho_nguoi_tiep_tuc_vi_pham [approved]: từ chối cung cấp dịch vụ cho người tiếp tục vi phạm Điều 10, Điều 19 sau khi đã được nhắc nhở, yêu cầu (nguồn: Điều 33 khoản 3 điểm a)
* act to_chuc_huong_dan_kiem_tra_don_doc_khong_uong_khong_ban_ruou_bia_tai_dia_diem [approved]: tổ chức thực hiện, hướng dẫn, kiểm tra, đôn đốc mọi người thực hiện đúng quy định không được uống, không được bán rượu, bia tại địa điểm thuộc quyền quản lý, điều hành (nguồn: Điều 33 khoản 3 điểm b)
* atom co_hanh_vi_vi_pham_dieu_10_hoac_19_tai_dia_diem [approved]: tại địa điểm thuộc quyền quản lý đang có người vi phạm quy định tại Điều 10 hoặc Điều 19 (nguồn: Điều 33 khoản 3 điểm a)
* atom nguoi_vi_pham_tiep_tuc_vi_pham_sau_khi_duoc_nhac_nho_yeu_cau [approved]: người vi phạm Điều 10, Điều 19 tiếp tục vi phạm sau khi đã được nhắc nhở, yêu cầu chấm dứt (nguồn: Điều 33 khoản 3 điểm a)
-/

namespace LexProof.Laws.Article33

open LexProof

def tS : AtomTable :=
  [ { name := "co_hanh_vi_vi_pham_dieu_10_hoac_19_tai_dia_diem", source := "Điều 33 khoản 3 điểm a", domain := .bool }
  , { name := "nguoi_vi_pham_tiep_tuc_vi_pham_sau_khi_duoc_nhac_nho_yeu_cau", source := "Điều 33 khoản 3 điểm a", domain := .bool } ]

def tP : AtomTable :=
  []

def rS : List ReaderSpec :=
  [ ("co_hanh_vi_vi_pham_dieu_10_hoac_19_tai_dia_diem", 0, 1)
  , ("nguoi_vi_pham_tiep_tuc_vi_pham_sau_khi_duoc_nhac_nho_yeu_cau", 1, 1) ]

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
  [ nrm "Điều 33:33.1.i" .obligation "to_chuc_thuc_hien_bien_phap_phong_chong_tac_hai_ruou_bia" .tt [] "Điều 33 khoản 1 nhánh (i)" []
  , nrm "Điều 33:33.1.ii" .obligation "to_chuc_thuc_hien_nghiem_quy_dinh_khong_uong_ruou_bia_trong_gio_lam_viec_tai_noi_lam_viec" .tt [] "Điều 33 khoản 1 nhánh (ii)" []
  , nrm "Điều 33:33.2" .obligation "tham_gia_hoat_dong_phong_chong_tac_hai_ruou_bia_tai_cong_dong_theo_dieu_24" .tt [] "Điều 33 khoản 2" ["Điều 24"]
  , nrm "Điều 33:33.3.a.i" .obligation "nhac_nho_yeu_cau_cham_dut_vi_pham_dieu_10_va_19" (.sit 0) [] "Điều 33 khoản 3 điểm a nhánh (i)" ["Điều 10", "Điều 19"]
  , nrm "Điều 33:33.3.a.ii" .obligation "tu_choi_cung_cap_dich_vu_cho_nguoi_tiep_tuc_vi_pham" (.sit 1) [] "Điều 33 khoản 3 điểm a nhánh (ii)" ["Điều 10", "Điều 19"]
  , nrm "Điều 33:33.3.b" .obligation "to_chuc_huong_dan_kiem_tra_don_doc_khong_uong_khong_ban_ruou_bia_tai_dia_diem" .tt [] "Điều 33 khoản 3 điểm b" ["Điều 10", "Điều 19"] ]

/-- Clauses not encoded, with the reason (from the translation or from the reviewer). Never a silent skip. -/
def notEncoded : List (String × String) :=
  [ ("Điều 33 khoản 3", "Câu dẫn của khoản xác định chủ thể là người đứng đầu, người quản lý, điều hành địa điểm quy định tại Điều 10 và Điều 19; chủ thể không được mã hóa thành atom, nên các norm của khoản này dùng điều kiện true hoặc điều kiện về hành vi vi phạm.") ]

def acts : List Act := ["nhac_nho_yeu_cau_cham_dut_vi_pham_dieu_10_va_19", "tham_gia_hoat_dong_phong_chong_tac_hai_ruou_bia_tai_cong_dong_theo_dieu_24", "to_chuc_huong_dan_kiem_tra_don_doc_khong_uong_khong_ban_ruou_bia_tai_dia_diem", "to_chuc_thuc_hien_bien_phap_phong_chong_tac_hai_ruou_bia", "to_chuc_thuc_hien_nghiem_quy_dinh_khong_uong_ruou_bia_trong_gio_lam_viec_tai_noi_lam_viec", "tu_choi_cung_cap_dich_vu_cho_nguoi_tiep_tuc_vi_pham"]

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

end LexProof.Laws.Article33
