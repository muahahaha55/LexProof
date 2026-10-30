import LexProof.Verify.AnalyzeProjected
import LexProof.Core.Render

/-!
# DRAFT, NOT HUMAN-REVIEWED — Luật 44/2019/QH14: bán / cung cấp / khuyến mại rượu, bia

**Nothing in this file has been reviewed by a person.** It is an AI draft of the
encoding of one act group, to be read clause by clause against the law with
`docs/review/sale-group-review.md`. `analyzeP` can say the *encoded part* is
consistent; it cannot say the encoding is faithful. Faithfulness is checked only
by a human reviewer.

## The group

Section C of `docs/slice1-notes.md`, acts
`ban_ruou_bia`, `cung_cap_ruou_bia`, `khuyen_mai_ruou_bia`,
`dung_ruou_bia_lam_qua_khuyen_mai`, `ban_ruou_bia_bang_may_tu_dong`.
Clauses: Điều 5 khoản 3 (three acts), khoản 9 (two acts), khoản 11 nhánh (ii),
and Điều 19 khoản 1 to 6 (heading: «Địa điểm không bán rượu, bia»).
Source text: `data/extracted/44-2019-QH14.txt`.

## Tentative working defaults relied on (all unreviewed)

* **G1 conservative**: a heading's modality and act apply to every clause under
  it — Điều 5 («Các hành vi bị nghiêm cấm») and Điều 19 («Địa điểm không bán
  rượu, bia») make each clause a *prohibition*. Same spirit: «cho người chưa đủ
  18 tuổi» in khoản 3 is read as binding all three verbs.
* **G4**: «trừ địa điểm được phép kinh doanh rượu, bia» (19.6) is an **exception**
  (it narrows the prohibition), not a permission.
* **G7 fine-grained acts**: bán, cung cấp, khuyến mại, dùng làm quà khuyến mại and
  bán bằng máy are separate act ids. Consequence: 5.11 nhánh (ii) is never compared
  with Điều 19.
* **G12**: this file is one module for this act group; it has its own tables.

## What Core cannot say here

Bands are labels: the checker does not know that «dưới 15 độ» and «từ 15 độ trở lên»
meet, nor detect a gap or an overlap (checked outside Lean, `eval/sale-group/`). All
norms in this group are prohibitions, so no two of them can clash by modality:
`consistentOn` below says nothing about the *content* of the conditions.
-/

set_option profiler true
set_option profiler.threshold 100
namespace LexProof.Laws.AlcoholSale

open LexProof

/-! ## Atom tables (every atom and every band carries its clause) -/

/-- Situation atoms. DRAFT. `S04`, `S02`, `S16` differ from the vocabulary B1 of
`slice1-notes.md` (see the review sheet). -/
def tS : AtomTable :=
  [ { name := "S04 tuổi của người nhận", source := "Điều 5 khoản 3"
      domain := .enum
        [ ⟨"chưa đủ 18 tuổi", "Điều 5 khoản 3: «cho người chưa đủ 18 tuổi»"⟩
        , ⟨"từ đủ 18 tuổi trở lên",
            "KHÔNG có khoản nào nêu; là phần bù của «chưa đủ 18 tuổi» (Điều 5 khoản 3), giả định của người mã hóa"⟩ ] }
  , { name := "S02 độ cồn của rượu, bia", source := "Điều 2 khoản 4 (định nghĩa độ cồn); Điều 5 khoản 9"
      domain := .enum
        [ ⟨"dưới 15 độ", "Điều 11 tiêu đề: «có độ cồn dưới 15 độ»; phần bù của «từ 15 độ trở lên» (Điều 5 khoản 9)"⟩
        , ⟨"từ 15 độ trở lên", "Điều 5 khoản 9: «có độ cồn từ 15 độ trở lên»"⟩ ] }
  , { name := "S14 địa điểm là cơ sở y tế", source := "Điều 19 khoản 1", domain := .bool }
  , { name := "S15 địa điểm là cơ sở giáo dục", source := "Điều 19 khoản 2", domain := .bool }
  , { name := "S16 địa điểm là cơ sở hoặc khu vực chăm sóc, nuôi dưỡng, vui chơi, giải trí"
      source := "Điều 19 khoản 3", domain := .bool }
  , { name := "S17 địa điểm là cơ sở cai nghiện, giáo dục bắt buộc, trường giáo dưỡng, giam giữ phạm nhân hoặc giam giữ khác"
      source := "Điều 19 khoản 4", domain := .bool }
  , { name := "S18 địa điểm là cơ sở bảo trợ xã hội", source := "Điều 19 khoản 5", domain := .bool }
  , { name := "S19 địa điểm là nơi làm việc của cơ quan nhà nước, tổ chức chính trị, tổ chức chính trị - xã hội, tổ chức chính trị xã hội - nghề nghiệp, đơn vị sự nghiệp công lập"
      source := "Điều 19 khoản 6", domain := .bool }
  , { name := "S20 địa điểm được phép kinh doanh rượu, bia"
      source := "Điều 19 khoản 6 (ngoại lệ «trừ địa điểm được phép kinh doanh rượu, bia»)", domain := .bool } ]

/-- Open-textured parameters. DRAFT. -/
def tP : AtomTable :=
  [ { name := "P14 địa điểm «dành cho» người chưa đủ 18 tuổi"
      source := "Điều 19 khoản 3 («dành cho người chưa đủ 18 tuổi»: khái niệm mở, luật không định nghĩa)"
      domain := .bool } ]

/-- Readers `(name, atom index, value index)`. Index = number used by `Cond.sit`. -/
def rS : List ReaderSpec :=
  [ ("S04 chưa đủ 18", 0, 0), ("S04 từ đủ 18", 0, 1)
  , ("S02 dưới 15", 1, 0), ("S02 từ 15", 1, 1)
  , ("S14", 2, 1), ("S15", 3, 1), ("S16", 4, 1), ("S17", 5, 1), ("S18", 6, 1)
  , ("S19", 7, 1), ("S20", 8, 1) ]

def rP : List ReaderSpec := [ ("P14", 0, 1) ]

/-- Article ids of the document, from `data/extracted/44-2019-QH14.txt`
(`eval/sale-group/check_sources.py` checks this list against the file). -/
def catalog : List String :=
  (List.range 36).map fun i => "Điều " ++ toString (i + 1)

/-! ## Norms -/

private def nrm (id : String) (act : String) (c : Cond) (ex : List Cond) (art : String) : Norm :=
  { id := id, modality := .prohibition, act := act, condition := c, exceptions := ex
  , priority := none
  , source := { docId := "44/2019/QH14", docType := .law
              , effective := ⟨2020, 1, 1⟩, article := art }
  , references := [] }

/-- DRAFT encoding. Reader numbers: see `rS`, `rP`. -/
def norms : List Norm :=
  [ -- Điều 5 khoản 3: bán / cung cấp / khuyến mại cho người chưa đủ 18 tuổi (3 acts)
    nrm "5.3-ban" "ban_ruou_bia" (.sit 0) [] "Điều 5 khoản 3"
  , nrm "5.3-cung-cap" "cung_cap_ruou_bia" (.sit 0) [] "Điều 5 khoản 3"
  , nrm "5.3-khuyen-mai" "khuyen_mai_ruou_bia" (.sit 0) [] "Điều 5 khoản 3"
    -- Điều 5 khoản 9: khuyến mại trong kinh doanh / dùng làm quà, độ cồn từ 15 trở lên
  , nrm "5.9-i" "khuyen_mai_ruou_bia" (.sit 3) [] "Điều 5 khoản 9"
  , nrm "5.9-ii" "dung_ruou_bia_lam_qua_khuyen_mai" (.sit 3) [] "Điều 5 khoản 9"
    -- Điều 5 khoản 11 nhánh (ii): bán bằng máy bán hàng tự động (the act carries the condition)
  , nrm "5.11-ii" "ban_ruou_bia_bang_may_tu_dong" .tt [] "Điều 5 khoản 11"
    -- Điều 19: địa điểm không bán rượu, bia
  , nrm "19.1" "ban_ruou_bia" (.sit 4) [] "Điều 19 khoản 1"
  , nrm "19.2" "ban_ruou_bia" (.sit 5) [] "Điều 19 khoản 2"
  , nrm "19.3" "ban_ruou_bia" (.and (.sit 6) (.param 0)) [] "Điều 19 khoản 3"
  , nrm "19.4" "ban_ruou_bia" (.sit 7) [] "Điều 19 khoản 4"
  , nrm "19.5" "ban_ruou_bia" (.sit 8) [] "Điều 19 khoản 5"
  , nrm "19.6" "ban_ruou_bia" (.sit 9) [.sit 10] "Điều 19 khoản 6" ]

/-! ## Clauses of the group or next to it that are NOT encoded -/

/-- A clause that is not encoded, with the reason. Never a silent skip. -/
structure NotEncoded where
  clause : String
  reason : String

def notEncoded : List NotEncoded :=
  [ ⟨"Điều 5 tiêu đề", "không phải norm riêng: modality «cấm» được áp dụng cho từng khoản qua G1 conservative"⟩
  , ⟨"Điều 19 tiêu đề", "không phải norm riêng: modality «cấm» và act «bán» được áp dụng cho từng khoản 1 đến 6 qua G1 conservative"⟩
  , ⟨"Điều 5 khoản 11 nhánh (i)", "khác nhóm act (kinh_doanh_ruou_khong_phep_hoac_dang_ky): thuộc mô-đun cấp phép (G12); thực chất là nghĩa vụ có giấy phép/đăng ký, phụ thuộc Điều 15"⟩
  , ⟨"Điều 2 khoản 1, 2, 4", "định nghĩa rượu, bia, độ cồn: dùng làm từ vựng (atom S02), không phải norm"⟩
  , ⟨"Điều 11", "ngoài lát cắt 1; chỉ yêu cầu «tuân thủ» luật này và pháp luật về khuyến mại (dẫn chiếu văn bản khác); chưa đọc phân tích"⟩
  , ⟨"Điều 15 khoản 4", "ngoài lát cắt 1; điều kiện cấp phép mua bán rượu từ 5,5 độ; định nghĩa «được phép kinh doanh» dùng ở 19.6 (S20) nằm ở đây; chưa đọc phân tích"⟩
  , ⟨"Điều 16", "ngoài lát cắt 1; điều kiện bán qua thương mại điện tử (nghĩa vụ hình thức, giao Chính phủ quy định biện pháp, dẫn pháp luật thương mại điện tử); chưa đọc phân tích"⟩
  , ⟨"Điều 32 khoản 3, 5, 7", "ngoài lát cắt 1; trách nhiệm của cơ sở kinh doanh: 32.3 lao động dưới 18 (liên quan 5.4), 32.5 nghĩa vụ niêm yết (hình thức), 32.7 cấm mở điểm bán mới trong bán kính 100 m — khoảng cách không biểu diễn được bằng Core hiện tại"⟩ ]

/-! ## Checks -/

/-- No finding of any kind: `validate`, both tables, both reader lists. -/
theorem silent : pfindings tS tP rS rP catalog norms = [] := by decide +kernel

/-- `analyzeP` on the whole group, proved by the kernel. -/
theorem consistent :
    analyzeP tS tP rS rP catalog norms = .consistentOn (projScope tS tP rS rP norms) := by
  decide +kernel

/-- Consequence: for every two norms of the group and every point of the full
domains there is no `Conflict`. Meaning is limited: every norm here is a
prohibition (no modality clash is possible), and no integrity constraint was used. -/
theorem no_conflict_in_group :
    ∀ n₁ ∈ norms, ∀ n₂ ∈ norms, ∀ (π : Valuation tP) (s : Valuation tS),
      ¬ Conflict (atomsOf tS tP rS rP) n₁ n₂ π s :=
  not_conflict_of_consistentOnP consistent

end LexProof.Laws.AlcoholSale
