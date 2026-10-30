import LexProof.Verify.Conflict
open LexProof

/-! Encoding A (current design). Pair 12.3.c x 13.2. Scratch file, not part of the library. -/
namespace ExpA

/-- S01: loại đồ uống. Giá trị: rượu; bia. Nguồn: Điều 2 khoản 1-2 (định nghĩa rượu, bia); Điều 13 đoạn dẫn -/
inductive TS01 | v0 | v1 deriving DecidableEq, Repr
instance : Finite TS01 where
  enum := [.v0, .v1]
  complete := by intro a; cases a <;> simp
/-- S02: dải độ cồn. Giá trị: dưới 5,5 độ; từ 5,5 đến dưới 15 độ; từ 15 độ trở lên. Nguồn: Điều 13 đoạn dẫn (rượu 5,5 đến dưới 15; bia từ 5,5); Điều 12 (dưới 5,5); Điều 5 khoản 7 (từ 15) -/
inductive TS02 | v0 | v1 | v2 deriving DecidableEq, Repr
instance : Finite TS02 where
  enum := [.v0, .v1, .v2]
  complete := by intro a; cases a <;> simp
structure Sit where
  fS01 : TS01   -- S01: loại đồ uống (nguồn: Điều 2 khoản 1-2 (định nghĩa rượu, bia); Điều 13 đoạn dẫn)
  fS02 : TS02   -- S02: dải độ cồn (nguồn: Điều 13 đoạn dẫn (rượu 5,5 đến dưới 15; bia từ 5,5); Điều 12 (dưới 5,5); Điều 5 khoản 7 (từ 15))
  fS24 : Bool   -- S24: quảng cáo trên báo nói/báo hình (nguồn: Điều 12 khoản 3 điểm c)
  fS25 : Bool   -- S25: quảng cáo trên phương tiện ngoài trời (nguồn: Điều 13 khoản 2)
  fS28 : Bool   -- S28: phương tiện là biển hiệu của cơ sở kinh doanh rượu, bia (nguồn: Điều 13 khoản 2 (ngoại lệ))
  fS29 : Bool   -- S29: ngay trước/trong/sau chương trình dành cho trẻ em (nguồn: Điều 12 khoản 3 điểm c)
  fS30 : Bool   -- S30: trong khung 18 đến 21 giờ (nguồn: Điều 12 khoản 3 điểm c)
  fS31 : Bool   -- S31: quảng cáo có sẵn trong chương trình thể thao tiếp sóng từ nước ngoài (nguồn: Điều 12 khoản 3 điểm c (ngoại lệ))
  deriving DecidableEq, Repr
instance : Finite Sit where
  enum :=
    (Finite.enum (α := TS01)).flatMap fun fS01 =>
    (Finite.enum (α := TS02)).flatMap fun fS02 =>
    (Finite.enum (α := Bool)).flatMap fun fS24 =>
    (Finite.enum (α := Bool)).flatMap fun fS25 =>
    (Finite.enum (α := Bool)).flatMap fun fS28 =>
    (Finite.enum (α := Bool)).flatMap fun fS29 =>
    (Finite.enum (α := Bool)).flatMap fun fS30 =>
    (Finite.enum (α := Bool)).map fun fS31 =>
      ⟨fS01, fS02, fS24, fS25, fS28, fS29, fS30, fS31⟩
  complete := by
    intro s
    obtain ⟨fS01, fS02, fS24, fS25, fS28, fS29, fS30, fS31⟩ := s
    simp [List.mem_flatMap, List.mem_map, Finite.complete]

structure Params where
  fP11 : Bool   -- P11: chương trình 'dành cho' trẻ em (nguồn: Điều 12 khoản 3 điểm c (khái niệm mở))
  fP13 : Bool   -- P13: 'trường hợp khác theo quy định của Chính phủ' (nguồn: Điều 12 khoản 3 điểm c (khe ủy quyền))
  deriving DecidableEq, Repr
instance : Finite Params where
  enum :=
    (Finite.enum (α := Bool)).flatMap fun fP11 =>
    (Finite.enum (α := Bool)).map fun fP13 =>
      ⟨fP11, fP13⟩
  complete := by
    intro s
    obtain ⟨fP11, fP13⟩ := s
    simp [List.mem_flatMap, List.mem_map, Finite.complete]

def atoms : Atoms Sit Params where
  sit := [("S01=rượu", fun s => s.fS01 == TS01.v0),
    ("S01=bia", fun s => s.fS01 == TS01.v1),
    ("S02<5,5", fun s => s.fS02 == TS02.v0),
    ("S02 5,5..<15", fun s => s.fS02 == TS02.v1),
    ("S02>=15", fun s => s.fS02 == TS02.v2),
    ("S24", fun s => s.fS24),
    ("S25", fun s => s.fS25),
    ("S28", fun s => s.fS28),
    ("S29", fun s => s.fS29),
    ("S30", fun s => s.fS30),
    ("S31", fun s => s.fS31)]
  param := [("P11", fun s => s.fP11),
    ("P13", fun s => s.fP13)]

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

theorem strong : ∀ n₁ ∈ norms, ∀ n₂ ∈ norms, ∀ (π : Params) (s : Sit),
    atoms.valid π s = true → ¬ Conflict atoms n₁ n₂ π s := by
  cases hr : analyze atoms catalog norms with
  | consistentOn sc au => exact not_conflict_of_consistentOn hr
  | _ => have h := search; simp [Result.isConsistentOn, hr] at h

#print axioms search
#print axioms strong

end ExpA
