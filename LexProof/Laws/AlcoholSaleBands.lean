import LexProof.Core.NumericBands
import LexProof.Verify.CasesScoped
import LexProof.Laws.AlcoholSaleCases

/-!
# DRAFT, NOT HUMAN-REVIEWED — numeric bands and scoped cases for `Laws/AlcoholSale.lean`

**What the kernel checks here:** the bands below tile their stated range (no gap, no overlap); their labels
are the labels of the bands in `AlcoholSale.tS`; the numeric cases map each number to a label with `bandOf`
and the evaluator then gives the status listed in `numPass`.

**What it does not check:** that 150 tenths of a degree is «15 độ» in the law, that the law counts an age in
whole years, or that any number was read correctly. The checker only knows the bands tile. Bounds the law
does not state are marked `assumed, not in the law` in `assumedBounds`.
-/

namespace LexProof.Laws.AlcoholSaleBands

open LexProof LexProof.Laws.AlcoholSale LexProof.Laws.AlcoholSaleCases

private def nb (lo hi : Int) (l ls hs : String) (lst hst : Bool) : NumBand :=
  { lo := lo, hi := hi, label := l, loSource := ls, hiSource := hs, loStated := lst, hiStated := hst }

/-- Age in whole years, scale `[0, 150)`. 18 is stated (Điều 5 khoản 3); 0 and 150 are not in the law. -/
def ageBands : List NumBand :=
  [ nb 0 18 "chưa đủ 18 tuổi" "thang tuổi bắt đầu từ 0" "Điều 5 khoản 3: «chưa đủ 18 tuổi»" false true
  , nb 18 150 "từ đủ 18 tuổi trở lên" "Điều 5 khoản 3: «chưa đủ 18 tuổi»" "giới hạn trên của thang tuổi" true false ]

/-- Alcohol in tenths of a degree, scale `[0, 1000)`. 150 (15 độ) is stated (Điều 5 khoản 9); 0 and 1000
(100 độ) are not in the law. -/
def alcoholBands : List NumBand :=
  [ nb 0 150 "dưới 15 độ" "thang độ cồn bắt đầu từ 0" "Điều 5 khoản 9: «độ cồn từ 15 độ trở lên»" false true
  , nb 150 1000 "từ 15 độ trở lên" "Điều 5 khoản 9: «độ cồn từ 15 độ trở lên»" "giới hạn trên của thang độ cồn" true false ]

theorem age_tiles : tiles ageBands 0 150 = true := by decide +kernel
theorem alcohol_tiles : tiles alcoholBands 0 1000 = true := by decide +kernel

/-- Every bound the law does not state, to be shown to the reviewer. -/
def assumedBounds : List String := (ageBands ++ alcoholBands).flatMap NumBand.assumedBounds

def labelsOf (a : Atom) : List String :=
  match a.domain with
  | .bool => []
  | .enum bs => bs.map (·.label)

/-- The band labels are exactly the labels of the bands in the existing tables. -/
theorem age_labels : tS[0]?.map labelsOf = some (ageBands.map (·.label)) := by decide +kernel
theorem alcohol_labels : tS[1]?.map labelsOf = some (alcoholBands.map (·.label)) := by decide +kernel

/-! ## Scoped run of the 37 cases -/

def notEncodedKeys : List String := notEncoded.map (·.clause)

/-- `Case.clause` of C24 is the whole khoản 11; the not-encoded entry is its branch (i). -/
def keyOverride : List (String × String) := [("C24", "Điều 5 khoản 11 nhánh (i)")]

def clauseKey (c : Case) : String := ((keyOverride.find? (·.1 == c.id)).map (·.2)).getD c.clause

def scopedReportNow : String := scopedReport notEncodedKeys clauseKey tS tP rS rP norms cases

theorem out_of_scope_set : outOfScopeIds notEncodedKeys clauseKey tS tP rS rP norms cases = ["C24"] := by
  decide +kernel

/-- The in-scope passes are exactly the passes of `runCase`: scoping removes C24 from the failures and adds
nothing to the passes. -/
theorem scoped_pass_set : scopedPassIds notEncodedKeys clauseKey tS tP rS rP norms cases = passing := by
  decide +kernel

/-- Finding: C37 cites «Điều 19 (tiêu đề)», the not-encoded list says «Điều 19 tiêu đề». -/
theorem unmentioned_set : unmentionedKeys notEncodedKeys clauseKey norms cases = ["Điều 19 (tiêu đề)"] := by
  decide +kernel

/-! ## Numeric cases -/

structure NumCase where
  id : String
  description : String
  /-- Whole years. -/
  age : Option Int := none
  /-- Tenths of a degree. -/
  degree : Option Int := none
  others : List (String × String) := []
  params : List (String × String) := []
  act : Act
  expected : CaseStatus
  clause : String

inductive NumOutcome
  | outOfRange
  | ran (o : CaseOutcome)
  deriving Repr, DecidableEq

def numLabel (bs : List NumBand) (code : String) (x : Option Int) : Option (Option (String × String)) :=
  match x with
  | none => some none
  | some v => (bandOf bs v).map fun l => some (code, l)

/-- The case with each number replaced by the label `bandOf` gives; `none` if a number is outside its scale. -/
def NumCase.toCase (n : NumCase) : Option Case := do
  let a ← numLabel ageBands "S04" n.age
  let d ← numLabel alcoholBands "S02" n.degree
  some { id := n.id, description := n.description, situation := a.toList ++ d.toList ++ n.others
       , params := n.params, act := n.act, expected := n.expected, clause := n.clause, quote := ""
       , kind := .boundary, confidence := .high }

def runNum (n : NumCase) : NumOutcome :=
  match n.toCase with
  | none => .outOfRange
  | some c => .ran (runCase tS tP rS rP norms c).outcome

private def noPlace : List (String × String) :=
  ["S14", "S15", "S16", "S17", "S18", "S19", "S20"].map (·, "sai")

private def ban (id d : String) (age : Int) (e : CaseStatus) : NumCase :=
  { id := id, description := d, age := some age, others := noPlace, params := [("P14", "sai")]
  , act := "ban_ruou_bia", expected := e, clause := "Điều 5 khoản 3" }
private def cc (id d : String) (age : Int) (e : CaseStatus) : NumCase :=
  { id := id, description := d, age := some age, act := "cung_cap_ruou_bia", expected := e
  , clause := "Điều 5 khoản 3" }
private def km (id d : String) (age deg : Int) (e : CaseStatus) : NumCase :=
  { id := id, description := d, age := some age, degree := some deg, act := "khuyen_mai_ruou_bia"
  , expected := e, clause := "Điều 5 khoản 9" }
private def qua (id d : String) (deg : Int) (e : CaseStatus) : NumCase :=
  { id := id, description := d, degree := some deg, act := "dung_ruou_bia_lam_qua_khuyen_mai"
  , expected := e, clause := "Điều 5 khoản 9" }

def numCases : List NumCase :=
  -- the ten existing boundary cases, with numbers
  [ ban "N-C03" "bán, 17 tuổi" 17 .forbidden, ban "N-C04" "bán, 18 tuổi" 18 .noNormApplies
  , cc "N-C07" "cung cấp, 17 tuổi" 17 .forbidden, cc "N-C08" "cung cấp, 18 tuổi" 18 .noNormApplies
  , km "N-C11" "khuyến mại, 17 tuổi, 10,0 độ" 17 100 .forbidden
  , km "N-C12" "khuyến mại, 18 tuổi, 10,0 độ" 18 100 .noNormApplies
  , km "N-C14" "khuyến mại, 30 tuổi, 15,0 độ" 30 150 .forbidden
  , km "N-C15" "khuyến mại, 30 tuổi, 14,9 độ" 30 149 .noNormApplies
  , qua "N-C19" "quà, 15,0 độ" 150 .forbidden, qua "N-C20" "quà, 14,9 độ" 149 .noNormApplies
  -- six at the exact boundaries (stated 18 and 15,0; assumed floors 0 and the top 99,9)
  , km "N-B1" "đúng 18 tuổi, đúng 15,0 độ" 18 150 .forbidden
  , km "N-B2" "17 tuổi, đúng 15,0 độ (cả hai nhánh)" 17 150 .forbidden
  , km "N-B3" "18 tuổi, 0,0 độ (sàn của thang, giả định)" 18 0 .noNormApplies
  , ban "N-B4" "0 tuổi (sàn của thang, giả định)" 0 .forbidden
  , qua "N-B5" "quà, 0,0 độ (sàn của thang, giả định)" 0 .noNormApplies
  , qua "N-B6" "quà, 99,9 độ (sát trần của thang, giả định)" 999 .forbidden
  -- one just above each stated boundary (the cases just below are N-C03, N-C07, N-C15, N-C20)
  , ban "N-S1" "bán, 19 tuổi" 19 .noNormApplies, cc "N-S2" "cung cấp, 19 tuổi" 19 .noNormApplies
  , km "N-S3" "khuyến mại, 30 tuổi, 15,1 độ" 30 151 .forbidden, qua "N-S4" "quà, 15,1 độ" 151 .forbidden ]

def numPass : List String :=
  (numCases.filter fun n => runNum n == .ran .pass).map (·.id)

theorem num_pass_all : numPass = numCases.map (·.id) := by decide +kernel

/-- Outside the stated scale there is no band: the case is out of range, not defaulted. -/
theorem num_out_of_range :
    runNum (ban "x" "" (-1) .forbidden) = .outOfRange ∧ runNum (ban "x" "" 150 .noNormApplies) = .outOfRange ∧
    runNum (qua "x" "" 1000 .forbidden) = .outOfRange ∧ runNum (qua "x" "" (-1) .noNormApplies) = .outOfRange := by
  decide +kernel

end LexProof.Laws.AlcoholSaleBands
