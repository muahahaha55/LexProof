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

## 0. Bản đồ module và biên API

```
LexProof/Core/Finite.lean      ← lớp Finite, không Mathlib
        ↑
LexProof/Core/Norm.lean        ← Modality, Cond (+wf), Norm, applies, resolved, Atoms.valid
        ↑
LexProof/Verify/Validate.lean  ← Finding, validate, Reaches, 3 định lý
        ↑
LexProof/Verify/Conflict.lean  ← Conflict, analyze, Internal.check, các định lý (a)–(f), D23
        ↑
LexProof/Verify/Smoke.lean     ← ví dụ hai norm tối thiểu
        ↑
LexProof/Verify/Tests.lean     ← 11 nhóm ca kiểm thử, mọi kết quả ghim bằng `decide`
```

`LexProof/Laws/` và `LexProof/Cert/` **rỗng** (Planned).

**Biên API.** `LexProof.analyze` là **điểm vào duy nhất**: nó validate trước,
rồi mới tìm. Bộ kiểm và mọi thứ dưới nó nằm trong `LexProof.Internal`, nên
không gọi được bộ kiểm mà bỏ qua validator.

| Công khai | Trong `LexProof.Internal` |
|---|---|
| `Conflict`, `Conflict_comm`, `not_conflict_self` | `conflictsAt`, `isConflictAt`, `isUnknownAt` |
| `Counterexample`, `Resolution`, `Audit`, `Scope`, `UnknownReason`, `Result` | `Cand`, `cands`, `ceOf`, `paramNames`, `mkResult` |
| `analyze`, `scopeOf`, `auditOf`, `resolutionsOf`, `validPoints`, `validExcludedOf` | `checkNonempty`, `check` |
| `pairsOf` và các bổ đề về nó | các bổ đề trích xuất về search |
| toàn bộ `Validate.lean` | |

**Build**: `lake build` trần biên dịch mọi module (20 jobs). Lưu ý `touch`
**không** làm Lake rebuild — Lake băm nội dung file, không xem mtime; muốn buộc
build lại thì xóa artifact trong `.lake/`.

---

## 1. `Core/Finite.lean` — miền hữu hạn

Không có Mathlib nên không có `Fintype`, và Lean core **không** tổng hợp được
`Decidable (∀ a : α, p a)` cho một enum thường. Lớp `Finite` giải quyết bằng một
enumeration tường minh kèm chứng minh không bỏ sót.

| Khai báo | Chữ ký | Ngữ nghĩa |
|---|---|---|
| `Finite` | `class Finite (α : Type)` với `enum : List α`, `complete : ∀ a : α, a ∈ enum` | Kiểu có liệt kê đầy đủ *và chứng minh được* là đầy đủ |
| `Finite.card` | `(α : Type) → [Finite α] → Nat` | `enum.length` |
| `Finite.forall_of_all` | `(p : α → Bool) → (enum.all p = true) → ∀ a : α, p a = true` | Cầu nối từ quét `Bool` cạn sang `∀` thật; dùng trong `conflict_all_params` |
| `instFiniteUnit`, `instFiniteBool`, `instFiniteProd` | | `[()]`, `[false, true]`, tích Descartes |

**Trạng thái**: Implemented. Vẫn chỉ ba instance — chưa có `Fin n`, chưa có
deriving — nên mỗi văn bản mới phải **viết tay** instance `Finite` cho `S` và
`P`. Liên quan N9.

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
định nhận tất cả.

> **`valid` nằm trong trust base** ([ADR-0021](decisions/0021-integrity-constraint-valid.md)).
> Một `valid` quá mạnh **che xung đột thật**, và không định lý nào phát hiện
> được — mọi định lý đều có dạng "trên phần `valid`". `valid := fun _ _ => false`
> làm mọi văn bản trở nên "nhất quán". Phải duyệt `valid` như duyệt một norm.

| Khai báo | Chữ ký | Ngữ nghĩa |
|---|---|---|
| `Cond.eval` | `Atoms S P → P → S → Cond → Option Bool` | `none` = dị dạng (chỉ số ngoài phạm vi); `and`/`or` lan truyền `none` |
| `Cond.paramIdxs` | `Cond → List Nat` | Chỉ số tham số khái niệm mở |
| `Cond.evalAny` | `… → List Cond → Option Bool` | OR của danh sách; `[] ↦ some false` |
| `Cond.wf` | `Nat → Nat → Cond → Bool` | Kiểm **tĩnh** mọi chỉ số atom; không cần `π`, `s` |

```lean
theorem Cond.eval_isSome_of_wf (A : Atoms S P) (π : P) (s : S) (c : Cond) :
    c.wf A.sit.length A.param.length = true → (c.eval A π s).isSome = true
theorem Cond.evalAny_isSome_of_wf (A : Atoms S P) (π : P) (s : S) (cs : List Cond) :
    cs.all (wf A.sit.length A.param.length) = true → (evalAny A π s cs).isSome = true
```

Kiểm tĩnh là cái cho phép validator **nêu đúng norm sai** thay vì chờ tới eval.

### 2.3 `Norm` và các phép trên nó

Các trường của `Norm` không đổi (`id`, `modality`, `act`, `condition`,
`exceptions`, `priority`, `source`, `references`).

| Khai báo | Chữ ký | Ngữ nghĩa thực tế trong code |
|---|---|---|
| `Norm.applies` | `Norm → Atoms S P → P → S → Option Bool` | `some (c && !e)` với `e = evalAny exceptions` |
| `Norm.wf` | `Atoms S P → Norm → Bool` | Điều kiện **và** mọi ngoại lệ đều `Cond.wf` |
| `Norm.overrideIds` | `Norm → List NormId` | `priority.overrides`, hoặc `[]` |
| `Norm.overridesOther` | `Norm → Norm → Bool` | Một chiều |
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

`resolved` là **XOR**: override lẫn nhau **không** được coi là đã giải quyết —
đó là chu trình ưu tiên, và validator báo nó
([ADR-0013](decisions/0013-directional-priority-and-cycles.md)). Ca kiểm:
`Tests.mutual_override_not_resolved`.

Ba bổ đề `resolved_comm`, `Incompatible_comm`, `Incompatible_irrefl` là cái làm
cho việc so **mỗi cặp một lần** không mất gì, và làm cho cặp tự-ghép không cần
tồn tại.

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
  | mixedDocIds (docIds : List String)
  | duplicateId (norm : NormId)
  | atomIndexOutOfRange (norm : NormId)
  | danglingReference (norm : NormId) (ref : String)
  | unknownOverride (norm : NormId) (target : NormId)
  | priorityCycle (norm : NormId)
  deriving Repr, DecidableEq
```

Mọi constructor nêu tên norm sai, trừ `emptyNormList` và `mixedDocIds` là tính
chất của cả danh sách.

| Khai báo | Việc |
|---|---|
| `docIdsOf`, `singleDocId?` | Các `docId` khác nhau trong danh sách; `none` nếu rỗng hoặc lẫn nhiều văn bản |
| `duplicateIds` | Id xuất hiện nhiều hơn một lần |
| `unevaluableIds` | Norm có chỉ số atom ngoài phạm vi, theo id |
| `succsOf`, `reachStep`, `reachN` | Bước và bao đóng của đồ thị `overrides` |
| `inPriorityCycle` | Norm tới lại được chính nó, trong `ns.length` vòng |
| `validate` | `Atoms S P → List String → List Norm → List Finding` |

`validate` trả `[Finding.emptyNormList]` cho danh sách rỗng, ngược lại nối sáu
thành phần: lẫn `docId`, trùng id, dị dạng, tham chiếu treo (đối chiếu **catalog
truyền vào làm tham số**), override tới id không tồn tại, chu trình ưu tiên.

### 3.1 Quan hệ `Reaches` và ba định lý

```lean
inductive Reaches (ns : List Norm) : NormId → NormId → Prop
  | base (h : j ∈ succsOf ns i) : Reaches ns i j
  | step (t : Reaches ns i j) (h : k ∈ succsOf ns j) : Reaches ns i k
```

`Reaches ns i i` **chính là** "`i` nằm trên một chu trình".

```lean
theorem wf_of_validate_nil (h : validate A catalog ns = []) :
    ∀ n ∈ ns, n.wf A = true

theorem reachN_sound (ns) (i) : ∀ (k) (acc), (∀ x ∈ acc, Reaches ns i x) →
    ∀ x ∈ reachN ns k acc, Reaches ns i x

theorem cycle_of_validate_finding (h : Finding.priorityCycle i ∈ validate A catalog ns) :
    ∃ n ∈ ns, n.id = i ∧ Reaches ns i i

theorem singleDocId_isSome_of_validate_nil (hne : ns ≠ []) (h : validate A catalog ns = []) :
    (singleDocId? ns).isSome = true
```

`cycle_of_validate_finding` là **soundness** của phát hiện chu trình: báo cáo
nào cũng ứng với một chu trình thật. **Completeness — mọi chu trình đều bị báo —
chưa được chứng minh**; xem mục 6 và bảng trust base trong
[traceability.md](traceability.md).

---

## 4. `Verify/Conflict.lean` — quan hệ xung đột, báo cáo, bộ kiểm

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

`Conflict` **không** nhắc `valid`: nó là quan hệ logic thuần. Việc hạn chế về
phần `valid` nằm ở bộ kiểm và ở phát biểu các định lý.

### 4.2 Cặp không thứ tự

```lean
def pairsOf : List Norm → List (Norm × Norm)
  | [] => []
  | n :: rest => rest.map (fun m => (n, m)) ++ pairsOf rest

theorem pairsOf_subset (h : p ∈ pairsOf ns) : p.1 ∈ ns ∧ p.2 ∈ ns
theorem mem_pairsOf (h₁ : n₁ ∈ ns) (h₂ : n₂ ∈ ns) (hne : n₁ ≠ n₂) :
    (n₁, n₂) ∈ pairsOf ns ∨ (n₂, n₁) ∈ pairsOf ns
```

`mem_pairsOf` + `Conflict_comm` + `not_conflict_self` là ba mảnh cho phép định
lý (b) phát biểu trên **mọi** cặp `n₁ n₂ ∈ ns`, dù chỉ quét một nửa.

### 4.3 Kiểu kết quả

```lean
structure Counterexample (S P : Type) where
  situation : S ; params : P ; left : NormId ; right : NormId
  modalities : Modality × Modality ; sources : SourceId × SourceId

structure Resolution where winner : NormId ; loser : NormId

structure Audit where
  resolutions : List Resolution      -- clash đã được ưu tiên giải quyết, kèm norm thắng
  unevaluable : List NormId          -- norm không đánh giá được, KHÔNG bị bỏ im lặng

structure Scope where
  docId : Option String              -- none khi rỗng hoặc lẫn nhiều văn bản
  normIds : List NormId ; articles : List String
  situations : Nat ; params : Nat
  validExcluded : Nat                -- số điểm (π, s) bị `valid` loại
  validTotal : Nat                   -- tổng số điểm của miền liệt kê

def Scope.isRestricted (sc : Scope) : Bool := 0 < sc.validExcluded

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
được việc còn norm chưa đánh giá được. `Result.invalid` **không** mang `Scope`:
khi có khuyết điểm cấu trúc thì chưa kiểm gì cả.

| Khai báo | Việc |
|---|---|
| `Result.witness?` / `scope?` / `isConsistentOn` | Truy cập từng phần của báo cáo |
| `validPoints (S P)` | Mọi điểm `(π, s)` của miền liệt kê |
| `validExcludedOf A` | Đếm điểm bị `valid` loại |
| `scopeOf S P A ns` | `singleDocId?`, ids, articles, `card S`, `card P`, số bị loại, tổng |
| `coApplyPoint? A n₁ n₂` | Một điểm **valid** mà cả hai norm đều áp dụng, nếu có |
| `resolutionOf? A p` | Resolution của một cặp, **chỉ khi** clash thật sự xảy ra |
| `resolutionsOf A ns` | `(pairsOf ns).filterMap (resolutionOf? A)` |
| `auditOf A ns` | `resolutionsOf` + `unevaluableIds` |

```lean
theorem resolutionOf?_spec (h : resolutionOf? A p = some r) : ⟨nhân chứng⟩
theorem resolution_has_witness (h : r ∈ resolutionsOf A ns) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns, ∃ (π : P) (s : S),
      A.valid π s = true ∧
      n₁.applies A π s = some true ∧ n₂.applies A π s = some true ∧
      n₁.act = n₂.act ∧ Incompatible n₁.modality n₂.modality = true ∧
      Norm.winner? n₁ n₂ = some r.winner
```

Đây là **D23**: mọi resolution được báo là một clash **thật sự xảy ra** ở một
điểm valid. Cặp chưa bao giờ cùng áp dụng thì không có gì để giải quyết, nên
không được báo. Ca kiểm: `Tests.no_resolution_without_co_application`.

Mẹo cài đặt: `coApplyPoint?` trả về **chính điểm đó** thay vì một `Bool`. Đó là
lý do `resolution_has_witness` chứng minh được — nhân chứng có sẵn.

### 4.4 Bộ kiểm (trong `Internal`) và `analyze`

```lean
namespace Internal
  def conflictsAt / isConflictAt / isUnknownAt
  theorem isConflictAt_eq_true_iff : isConflictAt A n₁ n₂ π s = true ↔ Conflict A n₁ n₂ π s
  structure Cand ; def cands        -- lọc theo act trùng VÀ valid
  theorem mem_cands / mem_of_mem_cands
  def ceOf / paramNames / mkResult
  def checkNonempty / check
end Internal

def analyze (A) (catalog) (ns) : Result S P :=
  match validate A catalog ns with
  | [] => Internal.check A ns
  | fs => .invalid fs
```

Thứ tự quyết định của `Internal.check`: danh sách rỗng ⇒ `.invalid`; tìm xung
đột ⇒ `mkResult` (phân biệt `conflict` / `conditionalConflict`); không thấy ⇒
nếu có norm dị dạng thì `unknown` **nêu đúng norm đó**, ngược lại `consistentOn`.

Ba bổ đề bắc cầu từ `analyze` về `Internal.check`:

```lean
theorem analyze_eq_check (h : validate A catalog ns = []) :
    analyze A catalog ns = Internal.check A ns
theorem validate_nil_of_witness (h : (analyze A catalog ns).witness? = some c) :
    validate A catalog ns = []
theorem validate_nil_of_consistentOn (h : analyze A catalog ns = .consistentOn sc au) :
    validate A catalog ns = []
```

### 4.5 Sáu nhóm bảo đảm công khai

```lean
-- (a)+(c) phản ví dụ là thật, tại điểm valid, và MỌI trường khớp norm thật
theorem conflict_of_witness (h : (analyze A catalog ns).witness? = some c) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      c.left = n₁.id ∧ c.right = n₂.id ∧
      c.modalities = (n₁.modality, n₂.modality) ∧
      c.sources = (n₁.source, n₂.source) ∧
      A.valid c.params c.situation = true ∧
      Conflict A n₁ n₂ c.params c.situation

-- (b) consistentOn loại trừ xung đột trên phần valid
theorem not_conflict_of_consistentOn (h : analyze A catalog ns = .consistentOn sc au) :
    ∀ n₁ ∈ ns, ∀ n₂ ∈ ns, ∀ (π : P) (s : S),
      A.valid π s = true → ¬ Conflict A n₁ n₂ π s

-- (d) scope nói đúng những gì đã kiểm, kể cả phần bị `valid` loại
theorem scopeOf_spec (S P) (A) (ns) :
    docId = singleDocId? ns ∧ normIds = … ∧ articles = … ∧
    situations = card S ∧ params = card P ∧
    validExcluded = validExcludedOf A ∧ validTotal = (validPoints S P).length ∧
    validExcluded ≤ validTotal
theorem analyze_scope (hne : ns ≠ []) (h : validate A catalog ns = []) :
    (analyze A catalog ns).scope? = some (scopeOf S P A ns)

-- (e) hai nhãn đúng nghĩa
theorem conflict_all_params (h : analyze A catalog ns = .conflict c sc au) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns, ∀ π : P,
      A.valid π c.situation = true → Conflict A n₁ n₂ π c.situation
theorem conditionalConflict_split
    (h : analyze A catalog ns = .conditionalConflict c ps sc au) :
    ∃ n₁ ∈ ns, ∃ n₂ ∈ ns,
      (∃ π, A.valid π c.situation = true ∧ Conflict A n₁ n₂ π c.situation) ∧
      (∃ π, A.valid π c.situation = true ∧ ¬ Conflict A n₁ n₂ π c.situation)

-- (f) validate sạch ⇒ applies không bao giờ none
theorem applies_isSome_of_validate_nil (h : validate A catalog ns = []) :
    ∀ n ∈ ns, ∀ (π : P) (s : S), (n.applies A π s).isSome = true
```

Hai điểm đáng nói rõ:

- **(a) và (c) gộp thành một định lý.** Bản `Internal.conflict_of_witness` dùng
  một phương trình duy nhất `c = ceOf ⟨…⟩` nên khóa mọi trường cùng lúc; bản
  công khai trải nó ra thành từng trường để không phải nhắc `Internal.ceOf`.
- **(f) mạnh hơn mức cần**: đúng ở **mọi** `(π, s)`, kể cả cặp `valid` loại bỏ.

---

## 5. `Verify/Smoke.lean` và `Verify/Tests.lean`

**Không phải module `Laws`**: mọi norm ở đây là bịa ra để thử bộ kiểm, không mã
hóa điều khoản thật nào và không ai duyệt về faithfulness.

`Smoke.lean` giữ ví dụ hai norm tối thiểu và đi qua `analyze`. Bảy định lý,
trong đó `smoke_fields_correct` và `smoke_no_conflict_anywhere` **dùng thật**
(a)+(c) và (b).

`Tests.lean` có 11 nhóm, mọi kết quả mong đợi **ghim nguyên khối** và kiểm bằng
`decide`:

| # | Ca | Định lý |
|---|---|---|
| 1 | Chu trình ưu tiên độ dài **2, 3, 4**, và chu trình kèm **cạnh rời** | `cycle_2_found`, `cycle_3_found`, `cycle_4_found`, `cycle_plus_edge_found`, `cycle_3_is_real`, `mutual_override_not_resolved` |
| 2 | Trùng `NormId` | `duplicate_id_found` |
| 3 | Tham chiếu treo | `dangling_reference_found` |
| 4 | Lẫn `docId` giữa hai văn bản | `mixed_docids_found`, `mixed_docids_no_scope_docid`, `single_docid_when_clean` |
| 5 | Norm dị dạng cạnh một xung đột thật — **cả hai** được báo | `validator_names_the_bad_norm`, `conflict_reported_with_bad_norm`, `bad_norm_also_reported` |
| 6 | Danh sách rỗng | `empty_is_a_finding`, `empty_is_a_finding_via_analyze` |
| 7 | Điểm bị `valid` loại, **đếm được** | `valid_excludes_the_conflict`, `restriction_is_counted` (4/8), `no_restriction_counted` |
| 8 | Xung đột có điều kiện | `conditional_conflict_found`, `conditional_conflict_splits` |
| 9 | Ưu tiên một chiều: giải quyết được, ghi norm thắng | `one_sided_priority_resolves`, `winner_is_recorded`, `resolved_pair_is_consistent`, `recorded_resolution_has_witness` |
| 10 | Ưu tiên nhưng hai norm **không bao giờ cùng áp dụng** ⇒ không báo resolution | `no_resolution_without_co_application`, `no_co_apply_is_consistent` |
| 11 | Validate sạch ⇒ luôn đánh giá được (định lý (f)) | `smoke_pair_always_evaluates` |

**Chưa có ca kiểm**: `Finding.unknownOverride`; `Cond` lồng sâu; nhiều hơn một
ngoại lệ; chu trình dài hơn 4.

---

## 6. Những gì **vẫn chưa** được chứng minh

| Khoảng trống | Hệ quả |
|---|---|
| **Completeness của phát hiện chu trình** | Soundness đã có (`cycle_of_validate_finding`). Chiều "mọi chu trình đều bị báo" cần lập luận pigeonhole (một đường đi dài hơn số đỉnh phải lặp đỉnh), đắt khi không có Mathlib. **Giảm nhẹ**: với chu trình hai norm, `resolved` là XOR nên clash **vẫn** được báo là xung đột — bỏ sót finding không biến xung đột thành "nhất quán" |
| **Completeness của `Audit.resolutions`** | Soundness đã có (`resolution_has_witness`); không có định lý nói nó liệt kê **đủ** mọi clash đã giải quyết |
| `duplicateIds`, `danglingFindings`, `unknownOverrideFindings` | Chỉ có ca kiểm thử, không có định lý |
| Khi nào `unknown` xuất hiện | Không định lý nào nói `unknown` chỉ xảy ra khi thật có norm dị dạng |
| Ngân sách | `UnknownReason` **không có** `outOfBudget`; không có cơ chế đo hay chặn (N8) |
| `Atoms.valid` | Nằm trong trust base; `valid` quá mạnh che xung đột và không định lý nào thấy ([ADR-0021](decisions/0021-integrity-constraint-valid.md)) |

---

## 7. Audit axiom (số đo thực tế)

`#print axioms` trên toolchain `v4.35.0`: mọi định lý ⊆ whitelist
`{propext, Classical.choice, Quot.sound}`, không có `sorryAx`.

| Nhóm | Axiom |
|---|---|
| `conflict_of_witness`, `conflict_all_params`, `applies_isSome_of_validate_nil`, `resolution_has_witness`, `wf_of_validate_nil`, `cycle_of_validate_finding`, `reachN_sound`, `singleDocId_isSome_of_validate_nil` | `propext`, `Quot.sound` |
| `not_conflict_of_consistentOn`, `conditionalConflict_split`, `Internal.mem_cands` | `propext`, `Classical.choice`, `Quot.sound` |
| `scopeOf_spec`, `analyze_scope`, `analyze_eq_check`, `Internal.isConflictAt_eq_true_iff`, `resolutionOf?_spec`, và các định lý `decide` trong `Tests.lean` | `propext` |
| `Norm.resolved_comm`, `Tests.mutual_override_not_resolved` | *không axiom nào* |

Audit vẫn làm **thủ công**: `LexProof/Cert/` rỗng và `lake build` xanh **không**
kiểm axiom (FR11). Cách chạy lại: [conventions.md](conventions.md) §7. Đề xuất
cho phần quy mô: [ADR-0020](decisions/0020-untrusted-search-kernel-certificate.md).

---

## 8. Nợ chất lượng code đã biết

| Mục | Chi tiết |
|---|---|
| Docstring còn thiếu | `Core/Finite.lean`: ba `instance`. `Verify/Conflict.lean`: `Internal.Cand`, `UnknownReason`, `Result.isConsistentOn`, `scopeOf`, `auditOf`, `resolutionsOf`. `Verify/Validate.lean`: sáu hàm `*Findings`, `duplicateIds`. `Verify/Tests.lean`: phần lớn các `def` dữ liệu |
| Mẫu còn sót | `LexProof/Basic.lean` vẫn là `def hello := "world"`, `Main.lean` vẫn in `Hello, world!`, và `lexproof` là `defaultTargets` |
| `Date` không kiểm hợp lệ | `⟨2026, 99, 99⟩` hợp kiểu |
| `reachN` chạy `ns.length` vòng vô điều kiện | Không cắt sớm khi tập đã đóng; bậc hai theo số norm |
| `validExcludedOf` quét toàn miền | Riêng việc *báo cáo* scope cũng tốn một lần quét |
| `Internal` là quy ước, không phải `private` | Lean `private` sẽ chặn cả `Tests.lean`, nên bộ kiểm vẫn gọi được nếu ai đó cố ý viết `Internal.check` |
