# LexProof — Thiết kế chi tiết `Core` và `Verify` (LLD)

Tài liệu này **viết từ code thực tế**, không từ bản đặc tả. Nếu có chỗ đặc tả và
code khác nhau, chỗ đó được ghi là lệch và nêu rõ code đang làm gì.

Nguồn: `LexProof/Core/Finite.lean`, `LexProof/Core/Norm.lean`,
`LexProof/Verify/Conflict.lean`, `LexProof/Verify/Smoke.lean`.
Toolchain `leanprover/lean4:v4.35.0`, không phụ thuộc ngoài.

Quy ước đặt tên: kiểu `UpperCamelCase`, def `lowerCamelCase`, định lý
`snake_case` — xem [conventions.md](conventions.md).

---

## 0. Bản đồ module

```
LexProof/Core/Finite.lean      ← lớp Finite, không Mathlib
        ↑
LexProof/Core/Norm.lean        ← Modality, Cond, Norm, applies, Incompatible
        ↑
LexProof/Verify/Conflict.lean  ← Conflict, check, Result, 2 định lý
        ↑
LexProof/Verify/Smoke.lean     ← smoke test (KHÔNG phải module Laws)
```

`LexProof/Laws/` và `LexProof/Cert/` **rỗng** (Planned).

> **Lệch quan trọng (N12)**: không file nào ở trên được `lake build` trần biên
> dịch. `lakefile.toml` khai `[[lean_lib]] name = "LexProof"` không có `globs`,
> nên Lake chỉ build module gốc `LexProof`, mà `LexProof.lean` chỉ có
> `import LexProof.Basic`. Đã xác nhận bằng thực nghiệm: `touch` bốn file rồi
> `lake build` → vẫn 8 jobs, không rebuild. Phải build bằng
> `lake build LexProof.Verify.Smoke` (kéo theo cả ba module kia).

---

## 1. `Core/Finite.lean` — miền hữu hạn

Không có Mathlib nên không có `Fintype`, và Lean core **không** tổng hợp được
`Decidable (∀ a : α, p a)` cho một enum thường. Lớp `Finite` giải quyết bằng một
enumeration tường minh kèm chứng minh không bỏ sót.

| Khai báo | Chữ ký | Ngữ nghĩa |
|---|---|---|
| `Finite` | `class Finite (α : Type)` với `enum : List α`, `complete : ∀ a : α, a ∈ enum` | Kiểu có liệt kê đầy đủ *và chứng minh được* là đầy đủ |
| `Finite.card` | `(α : Type) → [Finite α] → Nat` | `enum.length`; dùng cho `Scope` và ngân sách |
| `Finite.forall_of_all` | `(p : α → Bool) → (enum.all p = true) → ∀ a : α, p a = true` | Cầu nối từ quét `Bool` cạn sang `∀` thật |
| `instFiniteUnit` | `Finite Unit` | `[()]` |
| `instFiniteBool` | `Finite Bool` | `[false, true]` |
| `instFiniteProd` | `[Finite α] → [Finite β] → Finite (α × β)` | Tích Descartes qua `flatMap`/`map` |

**Trạng thái**: Implemented.

**Ghi chú từ code**:
- `forall_of_all` **hiện không được dùng ở đâu cả** (grep toàn `LexProof/` chỉ
  thấy đúng dòng định nghĩa). `Verify/Conflict.lean` đi đường khác:
  `List.find?_eq_none` + `mem_cands`. Nó sẽ cần thiết cho
  [ADR-0015](decisions/0015-characterize-conflict-labels.md), vì chính `mkResult`
  đang dùng `enum.all` mà chưa có định lý nào nối cái đó sang `∀ π`.
- Chỉ có ba instance. **Không có** instance cho `Fin n` hay deriving tự động,
  nên mỗi văn bản mới phải **viết tay** instance `Finite` cho `S` và `P` (xem
  `Smoke.lean` làm mẫu). Liên quan N9.

---

## 2. `Core/Norm.lean` — lược đồ chuẩn tắc

### 2.1 Kiểu nền

| Khai báo | Chữ ký / hình dạng | Ghi chú |
|---|---|---|
| `Modality` | `obligation \| prohibition \| permission` | `Repr, DecidableEq, Inhabited` |
| `DocType` | `law \| decree \| circular \| decision \| other (name : String)` | Chỉ cho Level 2 |
| `Date` | `{ year month day : Nat }` | Không có kiểm tra tính hợp lệ của ngày |
| `SourceId` | `{ docId : String, docType : DocType, effective : Date, article : String }` | `article` là ID điều khoản nguồn, ví dụ `"Điều 12 khoản 2 điểm a"` |
| `NormId` | `abbrev NormId := String` | |
| `Act` | `abbrev Act := String` | Id mờ từ glossary ([ADR-0004](decisions/0004-act-as-opaque-glossary-id.md)) |

`docId`, `docType`, `effective` **chưa dùng** ở Level 1, giữ sẵn theo
[ADR-0007](decisions/0007-keep-level2-fields-in-sourceid.md).

### 2.2 `Cond` — cây cú pháp điều kiện

```lean
inductive Cond
  | tt | ff | sit (i : Nat) | param (i : Nat)
  | not (c : Cond) | and (a b : Cond) | or (a b : Cond)
  deriving Repr, DecidableEq, Inhabited
```

`Cond` **không** phụ thuộc `S` hay `P`: atom trỏ vào bảng bằng **chỉ số**. Hệ
quả quan trọng: `Norm` là dữ liệu thuần, so sánh được, in được, và LLM không thể
chèn hàm lạ ([ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md)).

```lean
structure Atoms (S P : Type) where
  sit   : List (String × (S → Bool))
  param : List (String × (P → Bool))
```

| Khai báo | Chữ ký | Ngữ nghĩa |
|---|---|---|
| `Cond.eval` | `(A : Atoms S P) → (π : P) → (s : S) → Cond → Option Bool` | `none` = **dị dạng** (chỉ số atom ngoài phạm vi). `and`/`or` lan truyền `none`. Không bao giờ ngầm thành `false` |
| `Cond.paramIdxs` | `Cond → List Nat` | Các chỉ số tham số khái niệm mở xuất hiện trong điều kiện |
| `Cond.evalAny` | `(A) → (π) → (s) → List Cond → Option Bool` | OR của danh sách; `[] ↦ some false`; `none` nếu bất kỳ phần tử `none` |

**Trạng thái**: Implemented.

### 2.3 `Norm` và các phép trên nó

```lean
structure Norm where
  id         : NormId
  modality   : Modality
  act        : Act
  condition  : Cond
  exceptions : List Cond
  priority   : Option Priority
  source     : SourceId
  references : List String
  deriving Repr, DecidableEq, Inhabited

structure Priority where
  overrides : List NormId
  deriving Repr, DecidableEq, Inhabited
```

| Khai báo | Chữ ký | Ngữ nghĩa thực tế trong code |
|---|---|---|
| `Norm.applies` | `(n : Norm) → (A : Atoms S P) → (π : P) → (s : S) → Option Bool` | `some (c && !e)` với `c = condition.eval`, `e = evalAny exceptions`; `none` nếu bên nào `none`. Tức **ngoại lệ phủ định điều kiện** ([ADR-0005](decisions/0005-exceptions-vs-priority.md)) |
| `Norm.paramIdxs` | `Norm → List Nat` | `condition.paramIdxs ++ exceptions.flatMap Cond.paramIdxs` |
| `Norm.resolved` | `Norm → Norm → Bool` | `n₁.priority` chứa `n₂.id` **HOẶC** `n₂.priority` chứa `n₁.id`. **Đối xứng**, và *không* ghi lại ai thắng |
| `Incompatible` | `Modality → Modality → Bool` | Bảng dưới đây |

`Incompatible` (đúng như code, đối xứng và phản xạ-sai):

| | obligation | prohibition | permission |
|---|---|---|---|
| **obligation** | false | **true** | false |
| **prohibition** | **true** | false | **true** |
| **permission** | false | **true** | false |

**Trạng thái**: Implemented.

**Lệch so với đặc tải**: `Norm.references : List String` đã có nhưng **không có
checker nào đọc nó**. Tham chiếu treo (FR1, FR8) chưa được cài.

**Lệch so với [ADR-0013](decisions/0013-directional-priority-and-cycles.md)**
(Planned): `resolved` hiện đối xứng, nên "A override B" và "A và B override lẫn
nhau" cho cùng kết quả. Chu trình ưu tiên không bị phát hiện, và `Result` không
nói norm nào thắng.

---

## 3. `Verify/Conflict.lean` — quan hệ xung đột và bộ kiểm

### 3.1 `Conflict` — định nghĩa hình thức (Prop)

```lean
def Conflict (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) : Prop :=
  n₁.act = n₂.act ∧
  n₁.applies A π s = some true ∧
  n₂.applies A π s = some true ∧
  Incompatible n₁.modality n₂.modality = true ∧
  Norm.resolved n₁ n₂ = false
```

Năm điều kiện, đồng thời: cùng act, **cả hai** áp dụng (dứt khoát `some true`,
nên dị dạng không bao giờ thành xung đột), modality khắc nhau, và **không** có
ưu tiên tường minh giải quyết. Thiếu ưu tiên ⇒ vẫn là xung đột (fail closed,
không có lex specialis ngầm).

### 3.2 Các vị từ dạng Bool

| Khai báo | Chữ ký | Ngữ nghĩa |
|---|---|---|
| `conflictsAt` | `... → Option Bool` | `none` nếu `applies` của bên nào là `none`; ngược lại `some` của hội năm điều kiện |
| `isConflictAt` | `... → Bool` | `(conflictsAt ...).getD false` — unknown **không** phải xung đột |
| `isUnknownAt` | `... → Bool` | `(conflictsAt ...).isNone` |

**Định lý cầu** — đây là mắt nối giữa `Bool` và `Prop`:

```lean
theorem isConflictAt_eq_true_iff (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) :
    isConflictAt A n₁ n₂ π s = true ↔ Conflict A n₁ n₂ π s
```

Chứng minh: `simp only` mở ba định nghĩa, `cases` trên hai `applies`, rồi
`cases` trên hai `Bool` và `simp [and_assoc]`. **Iff hai chiều**, nên bộ kiểm
không mạnh hơn cũng không yếu hơn định nghĩa.

### 3.3 Không gian tìm kiếm

```lean
structure Cand (S P : Type) where
  left : Norm ; right : Norm ; params : P ; situation : S

def cands [Finite S] [Finite P] (ns : List Norm) : List (Cand S P)
```

Thứ tự liệt kê, đúng như code: `n₁` chạy ngoài trên `ns`, rồi `n₂` trên `ns`,
rồi `π` trên `Finite.enum P`, trong cùng là `s` trên `Finite.enum S`.

Đây là **cặp có thứ tự, kể cả `(n, n)`**. Hiện vô hại *chỉ vì* `Incompatible`
phản xạ-sai; nếu sau này hai obligation trái nhau cũng tính là xung đột thì
cặp tự-ghép sẽ báo nhầm. Xem [ADR-0014](decisions/0014-compare-pairs-by-index.md) (Planned).

Hai bổ đề về tính đầy đủ của phép liệt kê:

```lean
theorem mem_cands (h₁ : n₁ ∈ ns) (h₂ : n₂ ∈ ns) : (⟨n₁, n₂, π, s⟩ : Cand S P) ∈ cands ns
theorem mem_of_mem_cands (h : k ∈ cands ns) : k.left ∈ ns ∧ k.right ∈ ns
```

`mem_cands` là chỗ `Finite.complete` được dùng — nó chính là lý do kết quả
`consistentOn` phủ được *mọi* tình huống, không chỉ những cái tình cờ có trong
danh sách.

### 3.4 Kiểu kết quả

```lean
structure Counterexample (S P : Type) where
  situation : S ; params : P
  left : NormId ; right : NormId
  modalities : Modality × Modality
  sources : SourceId × SourceId
  deriving Repr, DecidableEq

structure Scope where
  docId : String ; normIds : List NormId ; articles : List String
  situations : Nat ; params : Nat
  deriving Repr, DecidableEq

inductive UnknownReason
  | malformedCondition (norm : NormId)
  deriving Repr, DecidableEq

inductive Result (S P : Type)
  | conflict (c : Counterexample S P)
  | conditionalConflict (c : Counterexample S P) (params : List String)
  | consistentOn (scope : Scope)
  | unknown (reason : UnknownReason)
  deriving Repr, DecidableEq
```

`Counterexample` `deriving Repr` nên **in được** (FR9, phần dữ liệu). Không có
constructor nào mang nghĩa "văn bản đúng" (N2).

**Lệch so với N8**: `UnknownReason` **chỉ có một** constructor. Không có
`outOfBudget`, và không có cơ chế nào phát hiện vượt ngân sách.

Hàm phụ trợ:

| Khai báo | Ngữ nghĩa |
|---|---|
| `Result.witness?` | `conflict c ↦ some c`, `conditionalConflict c _ ↦ some c`, còn lại `none` |
| `Result.isConsistentOn` | `true` chỉ với `consistentOn` |
| `ceOf` | `Cand → Counterexample`, lấy `id`, `modality`, `source` của hai norm |
| `paramNames` | Tên các tham số khái niệm mở hai norm nhắc tới (`eraseDups` rồi `filterMap` tra bảng) |
| `scopeOf` | `docId` lấy từ `ns.head?` (rỗng ⇒ `""`), `normIds`, `articles`, `Finite.card S`, `Finite.card P` |
| `mkResult` | Nếu `(Finite.enum P).all (fun π => isConflictAt ... π k.situation)` thì `conflict`, ngược lại `conditionalConflict` kèm `paramNames` |

### 3.5 `check` — bộ kiểm

```lean
def check [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : Result S P
```

Thứ tự quyết định, đúng như code:

1. `(cands ns).find?` theo `isConflictAt` → nếu thấy, `mkResult` (phân biệt
   `conflict` / `conditionalConflict`).
2. Nếu không, `(cands ns).find?` theo `isUnknownAt` → `unknown (.malformedCondition k.left.id)`.
3. Nếu không nữa → `consistentOn (scopeOf S P ns)`.

**Ba hành vi biên đã kiểm bằng `#eval`**, cần biết khi viết Tier 4:

| Đầu vào | Kết quả thực tế | Nhận xét |
|---|---|---|
| `check atoms []` | `consistentOn { docId := "", normIds := [], articles := [], situations := 4, params := 2 }` | **Nhất quán rỗng nghĩa**: đúng về mặt logic, nhưng báo cáo có thể nói "nhất quán" trên không có gì. FR10 phải chặn ở tầng báo cáo |
| `check atoms [normA, badNorm]` với `badNorm.condition = .sit 99` | `unknown (malformedCondition "A")` | **Ghi sai tên norm**: báo `"A"` là norm *lành*, không phải `"BAD"`. Code lấy `k.left.id` trong khi norm dị dạng là `k.right` |
| `check atoms [normA, normB, badNorm]` | `conflict` của A~B, **không nhắc** `badNorm` dị dạng | Do thứ tự ưu tiên ở mục 1. Một báo cáo có thể che việc còn norm chưa đánh giá được — ảnh hưởng N3 |

Hai hành vi sau là **khoảng trống thiết kế đã xác nhận**, không phải suy đoán.
Cách sửa thuộc [ADR-0017](decisions/0017-wellformedness-validator-first.md): đưa
phát hiện dị dạng ra một validator chạy *trước*, và dành `unknown` cho lý do khác.

### 3.6 Hai định lý liên kết

```lean
theorem conflict_of_witness [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {c : Counterexample S P}
    (h : (check A ns).witness? = some c) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      n₁.id = c.left ∧ n₂.id = c.right ∧
      Conflict A n₁ n₂ c.params c.situation

theorem not_conflict_of_consistentOn [Finite S] [Finite P]
    {A : Atoms S P} {ns : List Norm} {sc : Scope}
    (h : check A ns = .consistentOn sc) :
    ∀ n₁ ∈ ns, ∀ n₂ ∈ ns, ∀ (π : P) (s : S), ¬ Conflict A n₁ n₂ π s
```

(a) phát biểu qua `witness?` nên phủ **cả** `conflict` và `conditionalConflict`
bằng một câu. Chứng minh: `List.find?_some` cho vị từ đúng tại nhân chứng,
`List.mem_of_find?_eq_some` + `mem_of_mem_cands` cho tính thuộc `ns`, rồi
`isConflictAt_eq_true_iff`.

(b) chứng minh bằng `List.find?_eq_none` + `mem_cands` (chỗ dùng
`Finite.complete`) + chiều `mpr` của định lý cầu.

**Điểm tinh tế, nói rõ để không nhập nhằng**: nhánh `unknown` *không* cần thiết
cho tính đúng của (b). Điều kiện dị dạng cho `applies = none`, mà `Conflict` đòi
`some true`, nên `Conflict` không thể thành lập. Nhánh `unknown` tồn tại vì
**chính sách** fail-closed (N3) — không được tuyên bố nhất quán khi còn chỗ chưa
đánh giá được — chứ không vì định lý cần nó.

**Và (b) chỉ nói về `Conflict` như đã định nghĩa, trên `ns` đã mã hóa.** Nó
không nói gì về văn bản luật. Xem bảng G1/G2/G3 trong
[traceability.md](traceability.md).

### 3.7 Những gì **chưa** được chứng minh

| Khoảng trống | Hệ quả |
|---|---|
| Không có định lý đặc trưng nhãn `conflict` vs `conditionalConflict` | `mkResult` dùng `enum.all` nhưng không bổ đề nào nối sang `∀ π`. Nhãn hiện chỉ *được tính*, chưa *được chứng minh*. [ADR-0015](decisions/0015-characterize-conflict-labels.md) đặt đây là điều kiện bắt buộc trước module `Laws` đầu tiên |
| Không có định lý về `unknown` | Không có gì bảo đảm `unknown` chỉ xuất hiện khi thực sự có norm dị dạng, cũng không bảo đảm tên norm được báo là đúng (xem mục 3.5) |
| Không có định lý về tính đầy đủ của `check` so với `Conflict` ngoài hai chiều đã có | Ví dụ: không có phát biểu "nếu tồn tại xung đột thì `check` không trả `consistentOn`" — tuy nó suy ra được từ (b) bằng phản chứng |
| `Norm.references` không có checker | Tham chiếu treo (FR8) chưa làm |

---

## 4. `Verify/Smoke.lean` — smoke test

**Không phải module `Laws`**: hai norm ở đây là bịa ra để thử bộ kiểm, không mã
hóa điều khoản thật nào và không ai duyệt về faithfulness. Docstring đầu file
nói đúng điều đó.

| Khai báo | Nội dung |
|---|---|
| `Sit` | `{ overdue : Bool, disputed : Bool }` ⇒ `Finite.card Sit = 4` |
| `Params` | `{ serious : Bool }` ⇒ `Finite.card Params = 2` |
| `instFiniteSit`, `instFiniteParams` | Viết tay, `complete` chứng minh bằng `cases ... <;> decide` |
| `atoms` | `sit = [("overdue", …), ("disputed", …)]`, `param = [("serious", …)]` |
| `srcA`, `srcB` | `docId "SMOKE"`, `.decree`, `2026-01-01`, `"Điều 1"` / `"Điều 2"` |
| `normA` | `obligation`, act `"publish"`, `condition = .sit 0` |
| `normB` | `prohibition`, act `"publish"`, `condition = .sit 0` ⇒ xung đột cố ý |
| `normBFixed` | `normB` thêm `exceptions := [.sit 0]` ⇒ hai norm không bao giờ cùng áp dụng |
| `conflicting`, `fixed` | `[normA, normB]`, `[normA, normBFixed]` |

Bốn định lý, tất cả `by decide` hoặc term thuần:

| Định lý | Khẳng định |
|---|---|
| `smoke_conflict` | `check atoms conflicting = .conflict { situation := ⟨true, false⟩, params := ⟨false⟩, left := "A", right := "B", modalities := (.obligation, .prohibition), sources := (srcA, srcB) }` |
| `smoke_consistent` | `check atoms fixed = .consistentOn { docId := "SMOKE", normIds := ["A","B"], articles := ["Điều 1","Điều 2"], situations := 4, params := 2 }` |
| `smoke_conflict_is_real` | `Conflict atoms normA normB ⟨false⟩ ⟨true, false⟩`, qua `isConflictAt_eq_true_iff` |
| `smoke_no_conflict_anywhere` | `∀ n₁ ∈ fixed, ∀ n₂ ∈ fixed, ∀ π s, ¬ Conflict atoms n₁ n₂ π s`, qua `not_conflict_of_consistentOn` |

Hai định lý cuối tồn tại để chứng tỏ hai định lý chính **dùng được thật**, không
chỉ phát biểu suông.

**Chưa được smoke test chạm tới**: `Norm.priority` / `Norm.resolved`, nhánh
`conditionalConflict`, nhánh `unknown`, `Cond` lồng nhau (`and`/`or`/`not`),
`Cond.evalAny` với nhiều hơn một ngoại lệ. Đây là các lỗ hổng test đã biết.

---

## 5. Audit axiom (số đo thực tế)

`#print axioms`, toolchain `v4.35.0`:

| Khai báo | Axiom |
|---|---|
| `conflict_of_witness` | `propext`, `Quot.sound` |
| `not_conflict_of_consistentOn` | `propext`, `Quot.sound` |
| `isConflictAt_eq_true_iff` | `propext` |
| `mem_cands`, `mem_of_mem_cands` | `propext`, `Quot.sound` |
| `smoke_conflict`, `smoke_consistent`, `smoke_conflict_is_real` | `propext` |
| `smoke_no_conflict_anywhere` | `propext`, `Quot.sound` |
| `instFiniteSit`, `instFiniteParams` | `propext` |

Tất cả ⊆ whitelist `{propext, Classical.choice, Quot.sound}`. Không `sorryAx`.
Grep bốn file: không có `sorry`, `native_decide`, `bv_decide`, `axiom`, `unsafe`,
`partial`.

Audit này đang làm **thủ công**. `LexProof/Cert/` rỗng và CI không chạy nó
(FR11, N12). Cách chạy lại: [conventions.md](conventions.md).

---

## 6. Nợ chất lượng code đã biết

| Mục | Chi tiết |
|---|---|
| Docstring còn thiếu | `Core/Finite.lean`: ba `instance`. `Core/Norm.lean`: `Date`. `Verify/Conflict.lean`: `mem_cands`, `mem_of_mem_cands`, `UnknownReason`, `Result` (bản thân kiểu; hai constructor thì có), `Result.isConsistentOn`, `ceOf`, `scopeOf`. `Verify/Smoke.lean`: hai `instance`, `srcA`, `srcB`, `conflicting`, `fixed` |
| Code chết | `Finite.forall_of_all` chưa ai dùng |
| Mẫu còn sót | `LexProof/Basic.lean` vẫn là `def hello := "world"`, `Main.lean` vẫn in `Hello, world!`, và `lexproof` là `defaultTargets` |
| `#eval` trong file thư viện | `Smoke.lean` có hai `#eval` in ra mỗi lần build; tiện cho người đọc nhưng làm ồn log build |
| `Date` không kiểm hợp lệ | `⟨2026, 99, 99⟩` là giá trị hợp kiểu |
