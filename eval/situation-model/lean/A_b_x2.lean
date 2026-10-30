import LexProof.Verify.Conflict
open LexProof

/-! Encoding A (current design). Pair 5.5 x 10.6. Scratch file, not part of the library. -/
namespace ExpA

/-- S07: thời điểm uống so với giờ làm việc/học tập. Giá trị: ngay trước; trong giờ; nghỉ giữa giờ; ngoài. Nguồn: Điều 5 khoản 5 -/
inductive TS07 | v0 | v1 | v2 | v3 deriving DecidableEq, Repr
instance : Finite TS07 where
  enum := [.v0, .v1, .v2, .v3]
  complete := by intro a; cases a <;> simp
structure Sit where
  fS06 : Bool   -- S06: người uống thuộc nhóm ở 5.5 (nguồn: Điều 5 khoản 5)
  fS07 : TS07   -- S07: thời điểm uống so với giờ làm việc/học tập (nguồn: Điều 5 khoản 5)
  fS19 : Bool   -- S19: địa điểm là nơi làm việc của cơ quan nhà nước/tổ chức chính trị/... (nguồn: Điều 10 khoản 6)
  fS20 : Bool   -- S20: địa điểm được phép kinh doanh rượu, bia (nguồn: Điều 10 khoản 6 (ngoại lệ))
  fS22 : Bool   -- S22: đang trong thời gian làm việc (nguồn: Điều 10 khoản 6)
  fX1 : Bool   -- X1: atom thêm (không norm nào đọc) (nguồn: không có: chỉ để nhân số điểm)
  fX2 : Bool   -- X2: atom thêm (không norm nào đọc) (nguồn: không có: chỉ để nhân số điểm)
  deriving DecidableEq, Repr
instance : Finite Sit where
  enum :=
    (Finite.enum (α := Bool)).flatMap fun fS06 =>
    (Finite.enum (α := TS07)).flatMap fun fS07 =>
    (Finite.enum (α := Bool)).flatMap fun fS19 =>
    (Finite.enum (α := Bool)).flatMap fun fS20 =>
    (Finite.enum (α := Bool)).flatMap fun fS22 =>
    (Finite.enum (α := Bool)).flatMap fun fX1 =>
    (Finite.enum (α := Bool)).map fun fX2 =>
      ⟨fS06, fS07, fS19, fS20, fS22, fX1, fX2⟩
  complete := by
    intro s
    obtain ⟨fS06, fS07, fS19, fS20, fS22, fX1, fX2⟩ := s
    simp [List.mem_flatMap, List.mem_map, Finite.complete]

structure Params where
  fP01 : Bool   -- P01: 'ngay trước' (uống) (nguồn: Điều 5 khoản 5 (khái niệm mở))
  deriving DecidableEq, Repr
instance : Finite Params where
  enum :=
    (Finite.enum (α := Bool)).map fun fP01 =>
      ⟨fP01⟩
  complete := by
    intro s
    obtain ⟨fP01⟩ := s
    simp [List.mem_flatMap, List.mem_map, Finite.complete]

def atoms : Atoms Sit Params where
  sit := [("S06", fun s => s.fS06),
    ("S07=ngay trước", fun s => s.fS07 == TS07.v0),
    ("S07=trong giờ", fun s => s.fS07 == TS07.v1),
    ("S07=nghỉ giữa giờ", fun s => s.fS07 == TS07.v2),
    ("S07=ngoài", fun s => s.fS07 == TS07.v3),
    ("S19", fun s => s.fS19),
    ("S20", fun s => s.fS20),
    ("S22", fun s => s.fS22)]
  param := [("P01", fun s => s.fP01)]

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

end ExpA
