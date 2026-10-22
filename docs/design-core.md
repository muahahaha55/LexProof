# LexProof — Thiết kế chi tiết `Core` và `Verify` (LLD)

Tài liệu này **viết từ code thực tế**, không từ bản đặc tả. Nếu có chỗ đặc tả và
code khác nhau, chỗ đó được ghi là lệch và nêu rõ code đang làm gì.

Nguồn: `LexProof/Core/Finite.lean`, `LexProof/Core/Norm.lean`,
`LexProof/Verify/Validate.lean`, `LexProof/Verify/Conflict.lean`,
`LexProof/Verify/Smoke.lean`, `LexProof/Verify/Tests.lean`.
Toolchain `leanprover/lean4:v4.35.0`, không phụ thuộc ngoài.

Quy ước đặt tên: kiểu `UpperCamelCase`, def `lowerCamelCase`, định lý
`snake_case` — xem [conventions.md](conventions.md).

---

## 0. Bản đồ module

```
LexProof/Core/Finite.lean      ← lớp Finite, không Mathlib
        ↑
LexProof/Core/Norm.lean        ← Modality, Cond (+wf), Norm, applies, resolved, Incompatible
        ↑
LexProof/Verify/Validate.lean  ← Finding, validate, wf_of_validate_nil
        ↑
LexProof/Verify/Conflict.lean  ← Conflict, cands, check, analyze, các định lý (a)–(f)
        ↑
LexProof/Verify/Smoke.lean     ← ví dụ hai norm tối thiểu
        ↑
LexProof/Verify/Tests.lean     ← 9 nhóm ca kiểm thử, mọi kết quả ghim bằng `decide`
```

`LexProof/Laws/` và `LexProof/Cert/` **rỗng** (Planned).

**Build**: `lake build` trần nay biên dịch mọi module (20 jobs). `LexProof.lean`
import cả năm module trên. Lưu ý `touch` **không** làm Lake rebuild, vì Lake băm
nội dung file chứ không xem mtime; muốn buộc build lại thì xóa artifact trong
`.lake/`.

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
| `instFiniteUnit`, `instFiniteBool`, `instFiniteProd` | | `[()]`, `[false, true]`, tích Descartes |

**Trạng thái**: Implemented.

`Finite.forall_of_all` trước đây là code chết; nay nó là bước đầu của
`conflict_all_params` (định lý (e) phần 1).

Vẫn chỉ có ba instance — chưa có `Fin n`, chưa có deriving — nên mỗi văn bản mới
phải **viết tay** instance `Finite` cho `S` và `P` (xem `Smoke.lean`). Liên quan N9.

---

## 2. `Core/Norm.lean` — lược đồ chuẩn tắc

### 2.1 Kiểu nền

| Khai báo | Hình dạng | Ghi chú |
|---|---|---|
| `Modality` | `obligation \| prohibition \| permission` | |
| `DocType` | `law \| decree \| circular \| decision \| other (name)` | Chỉ cho Level 2 |
| `Date` | `{ year month day : Nat }` | Không kiểm hợp lệ |
| `SourceId` | `{ docId, docType, effective, article }` | `article` là ID điều khoản nguồn |
| `NormId`, `Act` | `abbrev … := String` | `Act` là id mờ từ glossary |

### 2.2 `Cond`, `Atoms`, và ràng buộc toàn vẹn `valid`

```lean
inductive Cond
  | tt | ff | sit (i : Nat) | param (i : Nat)
  | not (c : Cond) | and (a b : Cond) | or (a b : Cond)
  deriving Repr, DecidableEq, Inhabited

structure Atoms (S P : Type) where
  sit   : List (String × (S → Bool))
  param : List (String × (P → Bool))
  valid : P → S → Bool := fun _ _ => true
```

`valid π s` nói cặp đó **có thể xảy ra**; bộ kiểm bỏ qua mọi cặp nó loại. Mặc
định nhận tất cả, nên văn bản không cần ràng buộc thì không bị ảnh hưởng.

> **`valid` nằm trong trust base.** Một `valid` quá mạnh sẽ **che xung đột
> thật**, và không định lý nào phát hiện được — mọi định lý đều có dạng "trên
> phần `valid`". Xem bảng trust base trong [traceability.md](traceability.md).

| Khai báo | Chữ ký | Ngữ nghĩa |
|---|---|---|
| `Cond.eval` | `Atoms S P → P → S → Cond → Option Bool` | `none` = dị dạng (chỉ số ngoài phạm vi); `and`/`or` lan truyền `none` |
| `Cond.paramIdxs` | `Cond → List Nat` | Chỉ số tham số khái niệm mở |
| `Cond.evalAny` | `… → List Cond → Option Bool` | OR của danh sách; `[] ↦ some false` |
| `Cond.wf` | `Nat → Nat → Cond → Bool` | Kiểm **tĩnh** mọi chỉ số atom có trong phạm vi; không cần `π`, `s` |

```lean
theorem Cond.eval_isSome_of_wf (A : Atoms S P) (π : P) (s : S) (c : Cond) :
    c.wf A.sit.length A.param.length = true → (c.eval A π s).isSome = true
theorem Cond.evalAny_isSome_of_wf (A : Atoms S P) (π : P) (s : S) (cs : List Cond) :
    cs.all (wf A.sit.length A.param.length) = true → (evalAny A π s cs).isSome = true
```

Kiểm tĩnh là thay đổi then chốt so với bản trước: nhờ nó validator **nêu đúng
norm sai** thay vì phải chờ tới lúc eval.

### 2.3 `Norm` và các phép trên nó

Các trường của `Norm` không đổi (`id`, `modality`, `act`, `condition`,
`exceptions`, `priority`, `source`, `references`).

| Khai báo | Chữ ký | Ngữ nghĩa thực tế trong code |
|---|---|---|
| `Norm.applies` | `Norm → Atoms S P → P → S → Option Bool` | `some (c && !e)` với `e = evalAny exceptions`; `none` nếu bên nào `none` |
| `Norm.wf` | `Atoms S P → Norm → Bool` | Điều kiện **và** mọi ngoại lệ đều `Cond.wf` |
| `Norm.overrideIds` | `Norm → List NormId` | `priority.overrides`, hoặc `[]` |
| `Norm.overridesOther` | `Norm → Norm → Bool` | Một chiều: `n₁` có nêu `n₂.id` không |
| `Norm.resolved` | `Norm → Norm → Bool` | **XOR**: `n₁.overridesOther n₂ ^^ n₂.overridesOther n₁` |
| `Norm.winner?` | `Norm → Norm → Option NormId` | Id norm thắng, khi **đúng một** bên nêu bên kia |
| `Incompatible` | `Modality → Modality → Bool` | Bảng dưới |

```lean
theorem Norm.applies_isSome_of_wf (A) (n) (h : n.wf A = true) (π) (s) :
    (n.applies A π s).isSome = true
theorem Norm.resolved_comm (n₁ n₂ : Norm) : n₁.resolved n₂ = n₂.resolved n₁
theorem Incompatible_comm (a b : Modality) : Incompatible a b = Incompatible b a
theorem Incompatible_irrefl (m : Modality) : Incompatible m m = false
```

`resolved` là **XOR**, không còn là OR: override lẫn nhau **không** còn được coi
là đã giải quyết. Đó là một chu trình ưu tiên, và validator báo nó
([ADR-0013](decisions/0013-directional-priority-and-cycles.md)). Ca kiểm:
`Tests.mutual_override_not_resolved`.

Ba bổ đề `resolved_comm`, `Incompatible_comm`, `Incompatible_irrefl` không phải
đồ trang trí: chúng là cái làm cho việc so **mỗi cặp một lần** là không mất gì,
và làm cho cặp tự-ghép không cần tồn tại.

`Incompatible` (đối xứng, phản xạ-sai):

| | obligation | prohibition | permission |
|---|---|---|---|
| **obligation** | false | **true** | false |
| **prohibition** | **true** | false | **true** |
| **permission** | false | **true** | false |

---

## 3. `Verify/Validate.lean` — validator

```lean
inductive Finding
  | emptyNormList
  | duplicateId (norm : NormId)
  | atomIndexOutOfRange (norm : NormId)
  | danglingReference (norm : NormId) (ref : String)
  | unknownOverride (norm : NormId) (target : NormId)
  | priorityCycle (norm : NormId)
  deriving Repr, DecidableEq
```

Mọi constructor **nêu tên norm sai**.

| Khai báo | Việc |
|---|---|
| `duplicateIds` | Id xuất hiện nhiều hơn một lần |
| `unevaluableIds` | Norm có chỉ số atom ngoài phạm vi, theo id (bộ kiểm cũng dùng) |
| `succsOf`, `reachStep`, `reachN` | Bước và bao đóng của đồ thị `overrides` |
| `inPriorityCycle` | Norm có tới lại được chính nó, trong `ns.length` bước |
| `validate` | `Atoms S P → List String → List Norm → List Finding` |

`validate` trả `[Finding.emptyNormList]` cho danh sách rỗng, ngược lại nối năm
thành phần: trùng id, dị dạng, tham chiếu treo (đối chiếu **catalog truyền vào
làm tham số**), override tới id không tồn tại, chu trình ưu tiên.

Định lý duy nhất của file:

```lean
theorem wf_of_validate_nil (h : validate A catalog ns = []) : ∀ n ∈ ns, n.wf A = true
```

**Chưa chứng minh** trong file này: tính đúng đắn của `duplicateIds`,
`inPriorityCycle` (kể cả việc `ns.length` bước là đủ), và của ba thành phần
finding còn lại. Chúng chỉ được kiểm bằng ca kiểm thử.

---

## 4. `Verify/Conflict.lean` — quan hệ xung đột và bộ kiểm

### 4.1 `Conflict` (Prop) và hai bổ đề về nó

```lean
def Conflict (A : Atoms S P) (n₁ n₂ : Norm) (π : P) (s : S) : Prop :=
  n₁.act = n₂.act ∧
  n₁.applies A π s = some true ∧
  n₂.applies A π s = some true ∧
  Incompatible n₁.modality n₂.modality = true ∧
  Norm.resolved n₁ n₂ = false

theorem Conflict_comm (h : Conflict A n₁ n₂ π s) : Conflict A n₂ n₁ π s
theorem not_conflict_self (A) (n) (π) (s) : ¬ Conflict A n n π s
```

`Conflict` **không** nhắc `valid`: nó là một quan hệ logic thuần. Việc hạn chế
về phần `valid` nằm ở bộ kiểm và ở phát biểu các định lý.

### 4.2 Vị từ Bool và định lý cầu

| Khai báo | Ngữ nghĩa |
|---|---|
| `conflictsAt` | `Option Bool`; `none` nếu `applies` bên nào là `none` |
| `isConflictAt` | `(conflictsAt …).getD false` — unknown **không** phải xung đột |
| `isUnknownAt` | `(conflictsAt …).isNone`; sau một lần validate sạch thì không tới được (định lý (f)), giữ lại làm chốt fail-closed |

```lean
theorem isConflictAt_eq_true_iff (A) (n₁ n₂) (π) (s) :
    isConflictAt A n₁ n₂ π s = true ↔ Conflict A n₁ n₂ π s
```

### 4.3 Không gian tìm kiếm

```lean
def pairsOf : List Norm → List (Norm × Norm)
  | [] => []
  | n :: rest => rest.map (fun m => (n, m)) ++ pairsOf rest
```

Cặp **không thứ tự**, mỗi cặp vị trí đúng một lần, **không có cặp tự-ghép**.

```lean
theorem pairsOf_subset (h : p ∈ pairsOf ns) : p.1 ∈ ns ∧ p.2 ∈ ns
theorem mem_pairsOf (h₁ : n₁ ∈ ns) (h₂ : n₂ ∈ ns) (hne : n₁ ≠ n₂) :
    (n₁, n₂) ∈ pairsOf ns ∨ (n₂, n₁) ∈ pairsOf ns
```

`mem_pairsOf` cộng `Conflict_comm` cộng `not_conflict_self` là ba mảnh cho phép
định lý (b) vẫn phát biểu được trên **mọi** cặp `n₁ n₂ ∈ ns`, dù chỉ quét một
nửa.

```lean
def cands [Finite S] [Finite P] (A : Atoms S P) (ns : List Norm) : List (Cand S P)
```
Tích `pairsOf ns × enum P × enum S`, rồi **lọc** theo
`(left.act == right.act) && A.valid params situation`.

```lean
theorem mem_cands (hp : (n₁, n₂) ∈ pairsOf ns) (hact : n₁.act = n₂.act)
    (hv : A.valid π s = true) : (⟨n₁, n₂, π, s⟩ : Cand S P) ∈ cands A ns
theorem mem_of_mem_cands (h : k ∈ cands A ns) :
    k.left ∈ ns ∧ k.right ∈ ns ∧ k.left.act = k.right.act ∧
      A.valid k.params k.situation = true
```

### 4.4 Kiểu kết quả

```lean
structure Counterexample (S P : Type) where
  situation : S ; params : P ; left : NormId ; right : NormId
  modalities : Modality × Modality ; sources : SourceId × SourceId

structure Resolution where winner : NormId ; loser : NormId

structure Audit where
  resolutions : List Resolution      -- clash đã được ưu tiên giải quyết, kèm norm thắng
  unevaluable : List NormId          -- norm không đánh giá được, KHÔNG bị bỏ im lặng

structure Scope where
  docId : String ; normIds : List NormId ; articles : List String
  situations : Nat ; params : Nat
  validRestricted : Bool             -- `valid` đã thu hẹp miền

inductive UnknownReason
  | malformedCondition (norm : NormId)

inductive Result (S P : Type)
  | conflict (c : Counterexample S P) (scope : Scope) (audit : Audit)
  | conditionalConflict (c : Counterexample S P) (params : List String)
      (scope : Scope) (audit : Audit)
  | consistentOn (scope : Scope) (audit : Audit)
  | unknown (reason : UnknownReason) (scope : Scope) (audit : Audit)
  | invalid (findings : List Finding)
```

`Audit` đi kèm **mọi** kết quả đã quét, nên một `conflict` không bao giờ che
được việc còn norm chưa đánh giá được.

| Khai báo | Việc |
|---|---|
| `Result.witness?` | Nhân chứng của cả hai loại báo xung đột |
| `Result.scope?` | Scope của mọi kết quả đã quét; `none` với `invalid` |
| `Result.isConsistentOn` | |
| `ceOf` | `Cand → Counterexample`, lấy id/modality/source của hai norm |
| `paramNames` | Tên tham số khái niệm mở hai norm nhắc tới |
| `validIsTrivial` | `valid` có nhận cả miền liệt kê không |
| `scopeOf` | `docId` từ `ns.head?`, ids, articles, `card S`, `card P`, `validRestricted` |
| `resolutionsOf` | Cặp cùng act, khắc modality, có norm thắng |
| `auditOf` | `resolutionsOf` + `unevaluableIds` |
| `mkResult` | `conflict` nếu **mọi `π` valid** đều xung đột tại `k.situation`, ngược lại `conditionalConflict` |

### 4.5 Bộ kiểm

```lean
def checkNonempty (A) (ns) : Result S P    -- tìm xung đột → unevaluable → consistentOn
def check (A) (ns) : Result S P            -- ns = [] ⇒ .invalid [.emptyNormList]
def analyze (A) (catalog) (ns) : Result S P -- validate trước, rồi check
```

`analyze` là **điểm vào**. `unknown` chỉ còn là chốt fail-closed, không còn là
nơi báo khuyết điểm cấu trúc.

Ba hành vi từng là khoảng trống, nay đã sửa và **có ca kiểm thử ghim lại**:

| Trước | Nay | Ca kiểm |
|---|---|---|
| `unknown` nêu tên norm *lành* | `validate` nêu đúng `"BAD"` | `Tests.validator_names_the_bad_norm` |
| Một `conflict` che norm dị dạng | `Audit.unevaluable = ["BAD"]` đi kèm `conflict` | `Tests.conflict_reported_with_bad_norm`, `Tests.bad_norm_also_reported` |
| `check A [] = consistentOn` | `.invalid [.emptyNormList]` | `Tests.empty_is_a_finding` |

### 4.6 Sáu nhóm định lý

```lean
-- (a) phản ví dụ được báo là xung đột thật, tại điểm valid
theorem conflict_of_witness (h : (check A ns).witness? = some c) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      c = ceOf (⟨n₁, n₂, c.params, c.situation⟩ : Cand S P) ∧
      A.valid c.params c.situation = true ∧
      Conflict A n₁ n₂ c.params c.situation

-- (c) mọi trường được báo khớp norm thật, không chỉ id
theorem counterexample_fields_correct (h : (check A ns).witness? = some c) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      c.left = n₁.id ∧ c.right = n₂.id ∧
      c.modalities = (n₁.modality, n₂.modality) ∧
      c.sources = (n₁.source, n₂.source) ∧
      Conflict A n₁ n₂ c.params c.situation

-- (b) consistentOn loại trừ xung đột trên phần valid
theorem not_conflict_of_consistentOn (h : check A ns = .consistentOn sc au) :
    ∀ n₁ ∈ ns, ∀ n₂ ∈ ns, ∀ (π : P) (s : S),
      A.valid π s = true → ¬ Conflict A n₁ n₂ π s

-- (d) scope nói đúng những gì đã kiểm
theorem scopeOf_spec (S P) (A) (ns) : normIds/articles/situations/params/validRestricted đúng
theorem check_scope (hne : ns ≠ []) : (check A ns).scope? = some (scopeOf S P A ns)

-- (e) hai nhãn đúng nghĩa
theorem conflict_all_params (h : check A ns = .conflict c sc au) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns, ∀ π : P, A.valid π c.situation = true → Conflict A n₁ n₂ π c.situation
theorem conditionalConflict_split (h : check A ns = .conditionalConflict c ps sc au) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      (∃ π, A.valid π c.situation = true ∧ Conflict A n₁ n₂ π c.situation) ∧
      (∃ π, A.valid π c.situation = true ∧ ¬ Conflict A n₁ n₂ π c.situation)

-- (f) validate sạch ⇒ applies không bao giờ none
theorem applies_isSome_of_validate_nil (h : validate A catalog ns = []) :
    ∀ n ∈ ns, ∀ (π : P) (s : S), (n.applies A π s).isSome = true
```

Hai điểm đáng nói rõ:

- **(a) dùng `c = ceOf ⟨…⟩`**, một phương trình duy nhất, nên nó khóa **mọi**
  trường của phản ví dụ cùng lúc; (c) chỉ là cách đọc lại cho dễ dùng.
- **(f) mạnh hơn mức cần**: nó đúng ở **mọi** `(π, s)`, kể cả cặp `valid` loại
  bỏ, chứ không chỉ trên phần valid.

### 4.7 Những gì **vẫn chưa** được chứng minh

| Khoảng trống | Hệ quả |
|---|---|
| Tính đúng đắn của `inPriorityCycle` | Không có gì bảo đảm phát hiện đủ hoặc không báo nhiễu chu trình; `ns.length` bước là đủ cũng chưa chứng minh |
| Tính đúng đắn của `duplicateIds`, `danglingFindings`, `unknownOverrideFindings` | Chỉ được kiểm bằng ca kiểm thử |
| Tính đúng đắn của `resolutionsOf` | Không có định lý nói `Audit.resolutions` liệt kê **đủ** và **đúng** các clash đã giải quyết |
| Khi nào `unknown` xuất hiện | Không định lý nào nói `unknown` chỉ xảy ra khi thật có norm dị dạng |
| Ngân sách | `UnknownReason` **không có** `outOfBudget`; không có cơ chế đo hay chặn (N8) |
| `Scope.docId` | Lấy từ `ns.head?`; danh sách lẫn hai văn bản sẽ báo sai, không ai phát hiện |
| `valid` | Nằm trong trust base; `valid` quá mạnh che xung đột và không định lý nào thấy |

---

## 5. `Verify/Smoke.lean` và `Verify/Tests.lean`

**Không phải module `Laws`**: mọi norm ở đây là bịa ra để thử bộ kiểm, không mã
hóa điều khoản thật nào và không ai duyệt về faithfulness.

`Smoke.lean` giữ đúng ví dụ hai norm tối thiểu: `Sit` (4 tình huống), `Params`
(1 bit), `normA` obligation / `normB` prohibition cùng act `"publish"`, và bản
`normBFixed` thêm ngoại lệ. Bốn định lý, trong đó hai định lý cuối **dùng thật**
định lý (b) và định lý cầu.

`Tests.lean` có 9 nhóm, mọi kết quả mong đợi được **ghim nguyên khối** và kiểm
bằng `decide`:

| # | Ca | Định lý |
|---|---|---|
| 1 | Chu trình ưu tiên (override lẫn nhau) | `priority_cycle_found`, `mutual_override_not_resolved` |
| 2 | Trùng `NormId` | `duplicate_id_found` |
| 3 | Tham chiếu treo | `dangling_reference_found` |
| 4 | Norm dị dạng cạnh một xung đột thật — **cả hai** được báo | `conflict_reported_with_bad_norm`, `bad_norm_also_reported`, `validator_names_the_bad_norm` |
| 5 | Danh sách rỗng | `empty_is_a_finding`, `empty_is_a_finding_via_analyze` |
| 6 | Tình huống bị `valid` loại bỏ | `valid_excludes_the_conflict`, `restriction_is_recorded`, `no_restriction_recorded` |
| 7 | Xung đột có điều kiện | `conditional_conflict_found`, `conditional_conflict_splits` |
| 8 | Ưu tiên một chiều: giải quyết được và ghi norm thắng | `one_sided_priority_resolves`, `winner_is_recorded`, `resolved_pair_is_consistent` |
| 9 | Validate sạch ⇒ luôn đánh giá được (định lý (f)) | `smoke_pair_validates`, `smoke_pair_always_evaluates` |

**Chưa có ca kiểm**: `Finding.unknownOverride`; chu trình ưu tiên dài hơn hai
norm; `Cond` lồng sâu; nhiều hơn một ngoại lệ.

---

## 6. Audit axiom (số đo thực tế)

`#print axioms` trên toolchain `v4.35.0`, 48 khai báo (thư viện + smoke + tests):
tất cả ⊆ whitelist `{propext, Classical.choice, Quot.sound}`, không có `sorryAx`.

| Nhóm | Axiom |
|---|---|
| `conflict_of_witness`, `counterexample_fields_correct`, `conflict_all_params`, `applies_isSome_of_validate_nil` | `propext`, `Quot.sound` |
| `not_conflict_of_consistentOn`, `conditionalConflict_split`, `mem_cands` | `propext`, `Classical.choice`, `Quot.sound` |
| `scopeOf_spec`, `check_scope`, `isConflictAt_eq_true_iff`, mọi định lý trong `Tests.lean` dạng `decide` | `propext` |
| `Norm.resolved_comm`, `Tests.mutual_override_not_resolved`, `Tests.one_sided_priority_resolves` | *không axiom nào* |

Audit vẫn làm **thủ công**: `LexProof/Cert/` rỗng và CI chỉ chạy `lake build`,
mà build xanh **không** kiểm axiom (FR11). Cách chạy lại:
[conventions.md](conventions.md) §7. Đề xuất cho phần quy mô:
[ADR-0020](decisions/0020-untrusted-search-kernel-certificate.md).

---

## 7. Nợ chất lượng code đã biết

| Mục | Chi tiết |
|---|---|
| Docstring còn thiếu | `Core/Finite.lean`: ba `instance`. `Verify/Conflict.lean`: `Cand`, `UnknownReason`, `Result.isConsistentOn`, `scopeOf`, `auditOf`. `Verify/Validate.lean`: năm hàm `*Findings`, `duplicateIds`. `Verify/Tests.lean`: phần lớn các `def` dữ liệu |
| Mẫu còn sót | `LexProof/Basic.lean` vẫn là `def hello := "world"`, `Main.lean` vẫn in `Hello, world!`, và `lexproof` là `defaultTargets` |
| `Date` không kiểm hợp lệ | `⟨2026, 99, 99⟩` hợp kiểm kiểu |
| `reachN` chạy `ns.length` vòng vô điều kiện | Không cắt sớm khi tập đã đóng; không đo nhưng là bậc hai theo số norm |
