import LexProof.Verify.Conflict
open LexProof

/-! Encoding B (V-lite). Pair 12.3.c x 13.2. Scratch file, not part of the library. -/
namespace ExpB

/-- Bảng atom: (tên, các dải/giá trị, khoản luật nguồn). -/
def tableS : List (String × List String × String) :=
  [
  ("S01 loại đồ uống", ["rượu", "bia"],
    "Điều 2 khoản 1-2 (định nghĩa rượu, bia); Điều 13 đoạn dẫn"),
  ("S02 dải độ cồn", ["dưới 5,5 độ", "từ 5,5 đến dưới 15 độ", "từ 15 độ trở lên"],
    "Điều 13 đoạn dẫn (rượu 5,5 đến dưới 15; bia từ 5,5); Điều 12 (dưới 5,5); Điều 5 khoản 7 (từ 15)"),
  ("S24 quảng cáo trên báo nói/báo hình", ["sai", "đúng"],
    "Điều 12 khoản 3 điểm c"),
  ("S25 quảng cáo trên phương tiện ngoài trời", ["sai", "đúng"],
    "Điều 13 khoản 2"),
  ("S28 phương tiện là biển hiệu của cơ sở kinh doanh rượu, bia", ["sai", "đúng"],
    "Điều 13 khoản 2 (ngoại lệ)"),
  ("S29 ngay trước/trong/sau chương trình dành cho trẻ em", ["sai", "đúng"],
    "Điều 12 khoản 3 điểm c"),
  ("S30 trong khung 18 đến 21 giờ", ["sai", "đúng"],
    "Điều 12 khoản 3 điểm c"),
  ("S31 quảng cáo có sẵn trong chương trình thể thao tiếp sóng từ nước ngoài", ["sai", "đúng"],
    "Điều 12 khoản 3 điểm c (ngoại lệ)"),
  ("X1 atom thêm (không norm nào đọc)", ["sai", "đúng"],
    "không có: chỉ để nhân số điểm")
  ]
def sdoms : List Nat := tableS.map fun a => a.2.1.length

/-- Bảng atom: (tên, các dải/giá trị, khoản luật nguồn). -/
def tableP : List (String × List String × String) :=
  [
  ("P11 chương trình 'dành cho' trẻ em", ["sai", "đúng"],
    "Điều 12 khoản 3 điểm c (khái niệm mở)"),
  ("P13 'trường hợp khác theo quy định của Chính phủ'", ["sai", "đúng"],
    "Điều 12 khoản 3 điểm c (khe ủy quyền)")
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
  sit := [("S01=rượu", rd 0 0),
    ("S01=bia", rd 0 1),
    ("S02<5,5", rd 1 0),
    ("S02 5,5..<15", rd 1 1),
    ("S02>=15", rd 1 2),
    ("S24", rd 2 1),
    ("S25", rd 3 1),
    ("S28", rd 4 1),
    ("S29", rd 5 1),
    ("S30", rd 6 1),
    ("S31", rd 7 1)]
  param := [("P11", rd 0 1),
    ("P13", rd 1 1)]

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
  nrm "12.3.c" .prohibition "qc_o_noi" (Cond.and (Cond.sit 5) (Cond.or (Cond.and (Cond.sit 8) (Cond.param 0)) (Cond.sit 9))) [(Cond.sit 10), (Cond.param 1)] "Điều 12 khoản 3 điểm c",
  nrm "13.2" .prohibition "qc_o_noi" (Cond.and (Cond.or (Cond.and (Cond.sit 0) (Cond.sit 3)) (Cond.and (Cond.sit 1) (Cond.or (Cond.sit 3) (Cond.sit 4)))) (Cond.sit 6)) [(Cond.sit 7)] "Điều 13 khoản 2"
  ]

theorem search : (analyze atoms catalog norms).isConsistentOn = true := by
  decide +kernel

#print axioms search

end ExpB
