import LexProof.Verify.Conflict
open LexProof

/-! Encoding B (V-lite). Pair 5.5 x 10.6. Scratch file, not part of the library. -/
namespace ExpB

/-- Bảng atom: (tên, các dải/giá trị, khoản luật nguồn). -/
def tableS : List (String × List String × String) :=
  [
  ("S06 người uống thuộc nhóm ở 5.5", ["sai", "đúng"],
    "Điều 5 khoản 5"),
  ("S07 thời điểm uống so với giờ làm việc/học tập", ["ngay trước", "trong giờ", "nghỉ giữa giờ", "ngoài"],
    "Điều 5 khoản 5"),
  ("S19 địa điểm là nơi làm việc của cơ quan nhà nước/tổ chức chính trị/...", ["sai", "đúng"],
    "Điều 10 khoản 6"),
  ("S20 địa điểm được phép kinh doanh rượu, bia", ["sai", "đúng"],
    "Điều 10 khoản 6 (ngoại lệ)"),
  ("S22 đang trong thời gian làm việc", ["sai", "đúng"],
    "Điều 10 khoản 6"),
  ("X1 atom thêm (không norm nào đọc)", ["sai", "đúng"],
    "không có: chỉ để nhân số điểm")
  ]
def sdoms : List Nat := tableS.map fun a => a.2.1.length

/-- Bảng atom: (tên, các dải/giá trị, khoản luật nguồn). -/
def tableP : List (String × List String × String) :=
  [
  ("P01 'ngay trước' (uống)", ["sai", "đúng"],
    "Điều 5 khoản 5 (khái niệm mở)")
  ]
def pdoms : List Nat := tableP.map fun a => a.2.1.length

def legal : List Nat → List Nat → Bool
  | [], [] => true
  | d :: ds, v :: vs => decide (v < d) && legal ds vs
  | _, _ => false

def allVals : List Nat → List (List Nat)
  | [] => [[]]
  | d :: ds => (List.range d).flatMap fun v => (allVals ds).map (v :: ·)

theorem mem_allVals : ∀ (doms vs : List Nat), vs ∈ allVals doms ↔ legal doms vs = true
  | [], vs => by cases vs <;> simp [allVals, legal]
  | d :: ds, vs => by
    cases vs with
    | nil => simp [allVals, legal]
    | cons v vs =>
      simp [allVals, legal, List.mem_flatMap, List.mem_map, List.mem_range, mem_allVals ds vs]

/-- A situation (or a parameter assignment) is a valuation: one value index per atom. -/
structure Val (doms : List Nat) where
  vs : List Nat
  h : legal doms vs = true
  deriving DecidableEq

instance (doms : List Nat) : Finite (Val doms) where
  enum := (allVals doms).attach.map fun x => ⟨x.1, (mem_allVals doms x.1).1 x.2⟩
  complete := by
    intro a
    exact List.mem_map.2 ⟨⟨a.vs, (mem_allVals doms a.vs).2 a.h⟩, List.mem_attach _ _, rfl⟩

abbrev Sit := Val sdoms
abbrev Params := Val pdoms

/-- Reader: atom `i` has value index `v`. -/
def rd {d : List Nat} (i v : Nat) (s : Val d) : Bool := s.vs.getD i 0 == v

def atoms : Atoms Sit Params where
  sit := [("S06", rd 0 1),
    ("S07=ngay trước", rd 1 0),
    ("S07=trong giờ", rd 1 1),
    ("S07=nghỉ giữa giờ", rd 1 2),
    ("S07=ngoài", rd 1 3),
    ("S19", rd 2 1),
    ("S20", rd 3 1),
    ("S22", rd 4 1)]
  param := [("P01", rd 0 1)]

def nrm (id : String) (m : Modality) (act : String) (c : Cond) (ex : List Cond)
    (art : String) : Norm :=
  { id := id, modality := m, act := act, condition := c, exceptions := ex
  , priority := none
  , source := { docId := "44/2019/QH14", docType := .law
              , effective := ⟨2020, 1, 1⟩, article := art }
  , references := [] }

def catalog : List String := []

def norms : List Norm :=
  [
  nrm "5.5" .prohibition "uong" (Cond.and (Cond.sit 0) (Cond.or (Cond.or (Cond.sit 2) (Cond.sit 3)) (Cond.and (Cond.sit 1) (Cond.param 0)))) [] "Điều 5 khoản 5",
  nrm "10.6" .prohibition "uong" (Cond.and (Cond.sit 5) (Cond.sit 7)) [(Cond.sit 6)] "Điều 10 khoản 6"
  ]

theorem search : (analyze atoms catalog norms).isConsistentOn = true := by
  decide +kernel

theorem strong : ∀ n₁ ∈ norms, ∀ n₂ ∈ norms, ∀ (π : Params) (s : Sit),
    atoms.valid π s = true → ¬ Conflict atoms n₁ n₂ π s := by
  cases hr : analyze atoms catalog norms with
  | consistentOn sc au => exact not_conflict_of_consistentOn hr
  | _ => have h := search; simp [Result.isConsistentOn, hr] at h

#print axioms search
#print axioms strong

end ExpB
