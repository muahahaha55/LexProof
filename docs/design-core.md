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
LexProof/Verify/Tests.lean     ← 12 nhóm ca kiểm thử, mọi kết quả ghim bằng `decide`
        ↑
LexProof/Cert/Audit.lean       ← #audit_axioms và #audit_encapsulation, chạy trong lake build
```

`LexProof/Laws/` **rỗng** (Planned). `LexProof/Cert/` nay có audit tự động.

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
| `addAll`, `gnodes` | Hợp không trùng lặp (viết tay, có bổ đề `Nodup`); mọi id có thể xuất hiện trong đồ thị |
| `succsOf`, `closureStep`, `closure` | Bước và bao đóng của đồ thị `overrides`, **lặp tới điểm bất động** với `gnodes ns` làm ngân sách |
| `reachableFrom ns gn i` | Các id tới được từ `i`. `gn` là **tham số**, không gọi `gnodes ns` bên trong, để `cycleFindings` tính danh sách đỉnh **một lần** cho cả văn bản thay vì một lần mỗi norm |
| `inPriorityCycleWith ns gn n`, `inPriorityCycle ns n` | Norm có tới lại được chính nó; bản thứ hai là bản tiện dụng với `gn := gnodes ns` |
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

theorem cycle_finding_of_reaches (hn : n ∈ ns) (h : Reaches ns n.id n.id) :
    Finding.priorityCycle n.id ∈ validate A catalog ns

theorem no_priority_cycle_of_validate_nil (h : validate A catalog ns = []) :
    ∀ n ∈ ns, ¬ Reaches ns n.id n.id

-- (D42) validate sạch ⇒ id đôi một khác nhau, và đồ thị ưu tiên đúng là `overrides`
theorem nodup_ids_of_validate_nil (h : validate A catalog ns = []) :
    (ns.map fun n => n.id).Nodup
theorem succsOf_eq_overrideIds_of_nodup_ids
    (hnd : (ns.map fun n => n.id).Nodup) (hn : n ∈ ns) :
    succsOf ns n.id = n.overrideIds

theorem singleDocId_isSome_of_validate_nil (hne : ns ≠ []) (h : validate A catalog ns = []) :
    (singleDocId? ns).isSome = true
```

Hai định lý đầu là **soundness và completeness** của phát hiện chu trình:
validator báo chu trình cho một norm **đúng khi** norm đó thật nằm trên một chu
trình. Chúng dựa trên bốn bổ đề về `closure`:

| Bổ đề | Việc |
|---|---|
| `subset_closure` | Bộ tích lũy không bị mất đi |
| `closure_sound` | Mọi id thu được đều tới được từ điểm xuất phát |
| `closure_subset_gnodes` | Bộ tích lũy luôn nằm trong `gnodes` |
| `closure_closed` | **Ngân sách không thể cạn trước khi tập đóng** — mỗi vòng chưa đóng thêm ít nhất một id, và tập bị chặn trong `gnodes`. Dùng `List.Nodup.length_le_of_subset` |

Lặp tới **điểm bất động** là lý do completeness chứng minh được: tại điểm bất
động tập đã đóng dưới `succsOf`, nên quy nạp trên `Reaches` đi qua **không cần
chặn độ dài đường đi**. Bản trước lặp một số vòng cố định và chiều này sẽ cần
lập luận pigeonhole trên đường đi — đắt hơn hẳn.

`addAll` được viết tay thay cho `List.eraseDups` vì Lean core không có bổ đề
`Nodup` cho `eraseDups` và các bổ đề vòng lặp của nó là `private`.

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
| `excludedPoints A cap` | **Những** điểm bị loại, tối đa `cap` cái. Là **hàm**, không phải trường của `Scope`: danh sách là `O(\|S\|×\|P\|)` nên sẽ làm ngập báo cáo, nhưng người duyệt cần thấy điểm thật để kiểm `valid` có quá mạnh |
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

-- (D40) mọi kết quả đã quét ⇒ không norm nào nằm trên chu trình `overrides`
theorem no_priority_cycle_of_consistentOn
    (h : analyze A catalog ns = .consistentOn sc au) :
    ∀ n ∈ ns, ¬ Reaches ns n.id n.id
-- cùng dạng: no_priority_cycle_of_conflict, no_priority_cycle_of_conditionalConflict
```

**(D40) nói gì**: hiểm họa XOR-theo-cặp (chu trình ≥ 3 làm mọi cặp trông như đã
giải quyết) **không thể lọt qua `analyze`**. Có chu trình thì kết quả là
`.invalid`, không bao giờ là một khẳng định về nhất quán hay xung đột. Chứng
minh từ completeness, **không** sửa `resolved`.

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
| 12 | **Kiểm thử vi phân cạn** của phát hiện chu trình trên mọi đồ thị ≤ 4 đỉnh, so với `refInCycle` viết theo cách khác; cộng ba ca cho thấy chu trình 3 lừa được bộ kiểm trần còn chu trình 2 thì không; cộng D40 | `cycle_check_agrees_n1/2` (kernel), `#eval agreeAll 3`/`agreeAll 4` (biên dịch, hạng *Evaluated*), `two_cycle_still_reports_conflict`, `three_cycle_hides_conflict_from_search`, `three_cycle_is_caught_by_validation`, `fixed_has_no_priority_cycle` |

**Chưa có ca kiểm**: `Finding.unknownOverride`; `Cond` lồng sâu; nhiều hơn một
ngoại lệ; chu trình dài hơn 4.

---

## 6. Những gì **vẫn chưa** được chứng minh

| Khoảng trống | Hệ quả |
|---|---|
| ~~Completeness của phát hiện chu trình~~ | **Đã chứng minh** (`cycle_finding_of_reaches`) — không còn là khoảng trống. Hiểm họa bên dưới vẫn thật và vẫn nên biết: `resolved` là XOR **theo cặp**, nên trong chu trình từ 3 norm trở lên **mọi** cặp trông như đã giải quyết và bộ kiểm trần báo `consistentOn` (`Tests.three_cycle_hides_conflict_from_search`). Nay validator chắc chắn bắt được, nên lớp chặn không còn dựa vào niềm tin |
| Tính **sắp xếp** của `sortStrings` | Chỉ chứng minh *bảo toàn phần tử* (`mem_sortStrings`). Việc `docIdsOf` bất biến theo thứ tự đầu vào là **Tested một ví dụ**, không phải định lý. Chấp nhận: sắp xếp chỉ để báo cáo ổn định |
| **Completeness của `Audit.resolutions`** | Soundness đã có (`resolution_has_witness`); không có định lý nói nó liệt kê **đủ** mọi clash đã giải quyết |
| `danglingFindings`, `unknownOverrideFindings` | Chỉ có ca kiểm thử, không có định lý. (`duplicateIds` **đã có**: `nodup_ids_of_validate_nil`) |
| Khi nào `unknown` xuất hiện | Không định lý nào nói `unknown` chỉ xảy ra khi thật có norm dị dạng |
| Ngân sách | `UnknownReason` **không có** `outOfBudget`; không có cơ chế đo hay chặn (N8). Trần kế hoạch tính theo **chi phí đo được mỗi điểm: 2,3 đến 3,5 ms** (`analyze` thật, `decide +kernel`; 60 giây ≈ 17 000–26 000 điểm một module). Số cũ "2^14 ≈ 7 s" đến từ phép đo **đại diện** (`(List.range N).all`) và thấp hơn thật khoảng 5–8 lần — xem [situation-model-experiment.md](situation-model-experiment.md) |
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

Audit nay **tự động**: `LexProof/Cert/Audit.lean` chạy `#audit_axioms` trong mỗi
`lake build` (3118 khai báo, gồm cả `Verify/Projection.lean`, `Core/AtomTable.lean`, `Verify/ProjectedCheck.lean`, `Verify/AnalyzeProjected.lean`, `Core/Render.lean`, `Laws/AlcoholSale.lean`, `Verify/AnalyzeReport.lean`, `Verify/Cases.lean` và `Laws/AlcoholSaleCases.lean`) và làm **build đỏ** nếu có axiom ngoài whitelist,
`sorryAx`, axiom do `native_decide`/`bv_decide` sinh, hay `axiom` tự khai. Cùng
file chạy `#audit_encapsulation` để chặn việc dùng `LexProof.Internal.*` ngoài
ba module được phép. Chi tiết: [conventions.md](conventions.md) §7. Đề xuất cho
phần quy mô: [ADR-0020](decisions/0020-untrusted-search-kernel-certificate.md).

---

## 8. Nợ chất lượng code đã biết

| Mục | Chi tiết |
|---|---|
| Docstring còn thiếu | `Core/Finite.lean`: ba `instance`. `Verify/Conflict.lean`: `Internal.Cand`, `UnknownReason`, `Result.isConsistentOn`, `scopeOf`, `auditOf`, `resolutionsOf`. `Verify/Validate.lean`: sáu hàm `*Findings`, `duplicateIds`. `Verify/Tests.lean`: phần lớn các `def` dữ liệu |
| Mẫu còn sót | `LexProof/Basic.lean` vẫn là `def hello := "world"`, `Main.lean` vẫn in `Hello, world!`, và `lexproof` là `defaultTargets` |
| `Date` không kiểm hợp lệ | `⟨2026, 99, 99⟩` hợp kiểu |
| `reachN` chạy `ns.length` vòng vô điều kiện | Không cắt sớm khi tập đã đóng; bậc hai theo số norm |
| `validExcludedOf` quét toàn miền | Riêng việc *báo cáo* scope cũng tốn một lần quét |
| `Internal` là quy ước ở mức kiểu, nhưng **có audit chặn** | Lean `private` sẽ chặn cả `Tests.lean`. Thay vào đó `#audit_encapsulation` làm build đỏ nếu khai báo nào ngoài `Verify.{Conflict,Tests,Smoke}` nhắc tới `LexProof.Internal.*`. Nó quét **tên hằng dùng trong cả type và value**, nên không lách được bằng alias |
| Build lạnh **30.7s** | Từ 1m04.7s, nhờ hạ n=3 từ kernel `decide` xuống `#eval` (D38) và tính `gnodes` một lần (D39). Trong ngưỡng ~1 phút đã thống nhất |

---

## 9. `Verify/Projection.lean` — thí nghiệm chiếu theo cặp (không dùng bởi `check`/`analyze`)

Thí nghiệm A1 của [scaling-analysis.md](scaling-analysis.md) (design (a)). **Không
đổi định nghĩa hay định lý nào có sẵn**; `check`, `analyze`, `Result`, `Scope`
không gọi gì ở đây.

**Cầu nối** giữa các phép đánh giá có sẵn và bản nhận môi trường (`e g : Nat → Option Bool`)
dùng cho phép chiếu — ba định lý, đều chứng minh bằng quy nạp và `rfl`:

| Định lý | Nội dung |
|---|---|
| `Cond.eval_eq_evalE` | `c.eval A π s = c.evalE (A.sitVal s) (A.parVal π)` |
| `Cond.evalAny_eq_evalAnyE` | `evalAny A π s cs = evalAnyE (A.sitVal s) (A.parVal π) cs` |
| `Norm.applies_eq_appliesE` | `n.applies A π s = n.appliesE (A.sitVal s) (A.parVal π)` |

(L) tính cục bộ: `Cond.evalE_congr`, `Cond.evalAnyE_congr`, `Cond.eval_congr`,
`Norm.applies_congr`, `conflict_congr`. (S) tính đúng của tìm kiếm đã chiếu:
`not_conflict_of_projConsistent` (cần `Norm.wf` cho cả hai norm). `projConsistent`
không nhắc `Atoms` hay `valid`.

**Không có** trong (S): chiều ngược lại (một phép gán gây xung đột chỉ là *ứng
viên*, chưa phải xung đột thật), việc dựng điểm `(π, s)` hợp lệ từ phép gán, và
mọi thứ về `Scope`/`Finite.card`. Chưa đo chi phí chạy trên cặp thật.

---

## 10. `Core/AtomTable.lean` — bảng atom và phép gán (V0, chỉ thêm; chưa nối vào bộ kiểm)

Quyết định đề xuất: [ADR-0022](decisions/0022-atom-table-valuation-situation.md). Không sửa định nghĩa hay định lý
nào có sẵn. Dữ liệu: `Band` (nhãn + khoản nguồn), `Domain` (`bool` hoặc `enum` các `Band`), `Atom` (tên, miền,
nguồn), `AtomTable := List Atom`. Phép gán: `Valuation t` (danh sách chỉ số giá trị, kèm `legalVals … = true`).
Cắm vào API cũ: `instance Finite (Valuation t)`, `atomsOf` (dựng `Atoms (Valuation ts) (Valuation tp)`, `valid` mặc
định), `readersOk`, `icsEval` (ràng buộc là `List Cond`, chỉ có bộ đánh giá).

| Định lý | Nội dung |
|---|---|
| `mem_allVals`, `nodup_allVals`, `length_allVals` | liệt kê thô các danh sách giá trị: đầy đủ, không trùng, độ dài = tích |
| `Valuation.nodup_enum`, `Valuation.count_enum` (P1) | mỗi phép gán xuất hiện **đúng một lần** trong `Finite.enum` |
| `Valuation.card_eq`, `card_eq_prod` (P2) | `Finite.card (Valuation t) = tích kích thước miền` (`AtomTable.points`) |
| `PartialAssign.extend` (P3) | phép gán một phần trong miền, không gán hai giá trị cho một atom, mở rộng được thành phép gán đầy đủ nếu mọi miền khác rỗng — **chưa có ràng buộc** |

**Không có**: nâng phản ví dụ khi có ràng buộc (cần thỏa mãn được ràng buộc trên các atom chung), `Scope`
(`validExcluded`… vẫn quét `enum`), D23 (`coApplyPoint?`), kiểm bảng/bộ đọc trong `validate`.

---

## 11. `Verify/ProjectedCheck.lean` — bảng đúng dạng và kiểm theo cặp trên atom (chưa nối vào `analyze`)

Không sửa định nghĩa hay định lý có sẵn; không hàm nào ở đây được `check`/`analyze` gọi.

**A0 (đã đo, `eval/projected/A0_empty_domain.lean`).** Bảng có một atom enum **không có dải nào** làm không
gian tình huống **rỗng**. `analyze` khi đó trả `consistentOn` với `Scope.situations = 0`, `validTotal = 0`, **kể cả**
khi hai norm xung đột ở mọi điểm (cùng norm trên bảng có một dải thì trả `conflict`); validator im lặng. Kernel chứng
minh được cả hai (`decide +kernel`). Đây là kết luận "nhất quán" rỗng, không phải lỗi kernel.

| Định lý / định nghĩa | Nội dung |
|---|---|
| `tableFindings`, `readerFindings`, `TableFinding` | tên atom duy nhất; mọi enum khác rỗng; nhãn dải duy nhất trong một atom; mọi chuỗi nguồn (atom và dải) khác rỗng; mọi bộ đọc trỏ tới atom và giá trị có thật. Trả finding **nêu tên** atom/bộ đọc |
| `card_pos_of_tableFindings` (A2) | bảng không finding ⇒ `0 < Finite.card (Valuation t)` |
| `readersOk_of_readerFindings` (A2) | bộ đọc không finding ⇒ mọi bộ đọc đọc một atom và một giá trị trong miền |
| `projConflictT_iff` | kiểm xung đột trên phép gán một phần ⇔ `Conflict` khi phép gán ghi đúng giá trị các atom đã đọc |
| `not_conflict_of_projConsistentT` (B2) | không phép gán một phần nào gây xung đột ⇒ không có `Conflict` ở **bất kỳ** `(π, s)`. Cần: mọi bộ đọc trỏ tới atom có thật |
| `exists_conflict_of_not_projConsistentT` (B3) | có phép gán một phần gây xung đột ⇒ tồn tại `π`, `s` hợp lệ có `Conflict`. Cần: mọi miền khác rỗng; **không có ràng buộc** (`valid` mặc định) |
| `length_projVals` (B4) | số phép gán một phần được duyệt = `projPoints` = tích miền các atom **đã đọc** (hai phía S, P) |

**Không có**: ràng buộc toàn vẹn trong B3 (cần hoàn tất thỏa mãn các ràng buộc trên các atom chung với phép gán);
`Scope` (vẫn báo tích đầy đủ và quét `enum`; số điểm thật sự duyệt là `projPoints`, chưa có trường nào mang nó);
D23 (`coApplyPoint?`); bộ bọc cho cả danh sách norm; việc nối `tableFindings` vào `validate`.

**B5 (`eval/projected/`).** Cặp 12.3.c × 13.2 trên bảng thư viện. Kernel: kiểm theo cặp ≈ 4,4 giây, toàn miền ≈ 5,0 giây
(cặp này đọc **cả 10 atom**, nên hai bên duyệt cùng 1 536 điểm). Thêm 1/2/3 atom không ai đọc: kiểm theo cặp giữ nguyên
(wall 5,0–5,2 giây), toàn miền nhân đôi mỗi lần (5,7 → 10,7 → 21,6 → 44,2 giây). Kết quả hai bên trùng nhau ở mọi biến
thể, kể cả biến thể có xung đột thật.

---

## 12. `Verify/AnalyzeProjected.lean` — `analyzeP`, cửa vào cho cả danh sách norm trên bảng atom

Cộng thêm, không sửa gì có sẵn; `analyze` không đổi và không gọi `analyzeP`. `analyzeP` nhận bảng tình huống, bảng tham số, hai
danh sách bộ đọc, danh mục tham chiếu và danh sách norm, rồi theo thứ tự, **fail closed**:

1. nếu **bất kỳ** của `validate` (gồm danh sách norm rỗng), `tableFindings` (hai bảng), `readerFindings` (hai phía) khác rỗng
   thì trả `.invalid` với toàn bộ finding (mỗi finding nêu tên norm/atom/bộ đọc, có nhãn nguồn `norm`/`table`/`reader`);
2. nếu không, kiểm **mọi cặp không thứ tự `i < j` cùng act** bằng `projConsistentT`; cặp khác act bị bỏ **có chủ ý**;
3. trả `.conflicts` (một phép gán một phần đầu tiên gây xung đột **cho mỗi cặp** xung đột, nên liệt kê **mọi** cặp, không chỉ cặp đầu)
   hoặc `.consistentOn`; cả hai mang `ProjScope`: số điểm duyệt mỗi cặp (`projPoints`), số cặp đã kiểm và số cặp bỏ qua do khác act,
   kích thước miền đầy đủ (tích, không liệt kê), và `constraintsUsed = false`.

| Định lý | Nội dung |
|---|---|
| `silent_of_not_invalid` (W1) | không phải `.invalid` ⇒ mọi finding rỗng, danh sách khác rỗng, `NonEmpty` và `ReaderAtomsOk` cho cả hai bảng (giả thiết của B2, B3) |
| `not_conflict_of_consistentOnP` (W2) | `.consistentOn` ⇒ với mọi `n₁ n₂` thuộc danh sách và mọi `(π, s)` ở miền đầy đủ, không có `Conflict`; bao gồm cặp khác act và cặp `(n, n)` |
| `conflicts_sound` (W3, W4) | `.conflicts` ⇒ danh sách hit khác rỗng, và **mỗi** cặp được liệt kê có `π`, `s` với `Conflict`, mang đúng id/modality/nguồn của hai norm. **Không dùng ràng buộc** |
| `conflicts_complete` (W4) | mỗi cặp `(i < j)` cùng act mà thật sự xung đột ở một điểm của miền đầy đủ **đều được liệt kê**. Tương đối với `Conflict` không ràng buộc; dùng được để đếm recall của kiểm tra không ràng buộc, không hơn |
| `scope_of_consistentOn`, `scope_of_conflicts`, `projScope_points_spec`, `projScope_pairs` | các con số của `ProjScope`: mỗi mục `pointsPerPair` là một cặp cùng act với số phép gán một phần đúng bằng `length (projVals …)`; đã kiểm + bỏ qua = tổng số cặp |

**Lưu ý không thể bỏ**: một xung đột được báo **khi không dùng ràng buộc toàn vẹn** có thể nằm ở một tình huống **không thể xảy ra trong thực tế** (`valid` chỉ là mặc định "nhận mọi điểm"). Kết luận `consistentOn` thì không bị ảnh hưởng theo chiều đó: không có xung đột ở *mọi* điểm thì càng không có ở các điểm thật.

**Chưa có**: ràng buộc toàn vẹn trong bộ kiểm; ưu tiên nâng cao (`Audit.resolutions`, D23); `Scope` mới cho `analyze`; một bảng thật của một văn bản.
Phép đo B5 dùng các atom thừa **nhân tạo**: lợi ích thật của việc chiếu theo cặp chưa đo được cho đến khi có một bảng thật.

---

## 13. `Core/Render.lean` và `Laws/AlcoholSale.lean` — bản nháp đầu tiên của một mô-đun `Laws`

**`Core/Render.lean`** (86 dòng): in một `Norm` một cách **tất định** từ dữ liệu Lean — act, loại, điều kiện, ngoại lệ, ưu tiên, tên atom, nhãn dải, khoản nguồn của từng dải — để người duyệt đọc đúng cái bộ kiểm thấy. Không LLM, không diễn giải; bộ đọc thiếu hoặc atom thiếu được in là `‹…›` chứ không bị ẩn. Đây là phương án A (tất định) của [ADR-0019](decisions/0019-back-translation-renderer.md), chưa phải quyết định cuối.

**`Laws/AlcoholSale.lean`**: **BẢN NHÁP, CHƯA AI DUYỆT.** Nhóm act «bán / cung cấp / khuyến mại rượu, bia» (mục C của slice1-notes): Điều 5 khoản 3, 9, 11 (nhánh ii) và Điều 19 khoản 1 đến 6 — 12 norm, 9 atom tình huống, 1 tham số, 36 điều trong danh mục. Mỗi atom và mỗi dải mang khoản nguồn. Điều khoản của nhóm hoặc sát nhóm không mã hóa nằm trong `notEncoded` (kèm lý do). Phiếu duyệt cho con người: [review/sale-group-review.md](review/sale-group-review.md).

| Định lý | Nội dung |
|---|---|
| `silent` | `pfindings … = []`: `validate`, hai bảng, hai danh sách bộ đọc đều im lặng |
| `consistent` | `analyzeP … = .consistentOn (projScope …)`, kernel (`decide +kernel`) |
| `no_conflict_in_group` | hệ quả qua `not_conflict_of_consistentOnP` |

**Ý nghĩa bị giới hạn.** Mọi norm trong nhóm là *cấm*, nên `consistentOn` đúng với mọi nội dung điều kiện (xem phiếu duyệt, mục 8). Bộ kiểm không phát hiện khe hở hay chồng lấn giữa các dải; việc đó chạy ngoài Lean (`eval/sale-group/boundaries.py`). **Ranh giới tin cậy**: tệp nằm trong `LexProof/Laws/` mà chưa có người duyệt, trái với nguyên tắc «đầu ra của LLM phải được người duyệt trước khi vào `Laws`» (CLAUDE.md, [ADR-0011](decisions/0011-trust-boundary-human-approval.md)); cơ chế cưỡng chế chưa có, nên cờ duy nhất là docstring và tên phiếu.

---

## 14. `Verify/AnalyzeReport.lean` — `analyzeReport`: kết quả của `analyzeP` kèm ngữ cảnh để không đọc nhầm

Cộng thêm, không sửa gì có sẵn. `analyzeReport status actCatalog ts tp rs rp catalog ns` trả `AnalysisReport` với trường `core` **bằng đúng** `analyzeP` (`analyzeReport_core`, và đã kiểm lúc chạy ở 410 mutant).
Các trường còn lại:

| Mục | Trường | Định lý |
|---|---|---|
| **D47** độ rỗng theo act | `acts` (số norm, modality có mặt, có cặp khắc nhau), `noModalityClash` | `not_conflict_of_noClashAct` (theo act), `not_conflict_of_noModalityClash` (cả module): nếu cờ đặt thì **không** hai norm nào xung đột ở điểm nào, bất kể điều kiện; `analyzeP_not_conflicts_of_noClash`: khi đó `analyzeP` không thể trả `.conflicts` |
| **D48** ưu tiên | `resolutions` — cặp cùng act, modality khắc nhau, mà `Norm.resolved` giải quyết, kèm người thắng | `resolvedPairs_sound` và `resolvedPairs_complete` (đủ và đúng **ở mức cặp**); `not_conflict_of_resolved`. **Không** gồm việc hai norm có cùng áp dụng tại một điểm hay không (D23) |
| **D49** dùng act | `singleUseActs`, `unusedCatalogActs`, `actFindings` (act dùng mà ngoài danh mục) | `singleUseActs_sound`, `unusedCatalogActs_sound`, `actFindings_sound` (chỉ chiều đúng, không phát biểu đầy đủ) |
| **D50** trạng thái | `status : ReviewStatus` (`draft` hoặc `reviewed` kèm tên, ngày) | **không có định lý**; `render` in «DRAFT, NOT HUMAN REVIEWED» cho `draft` (có ví dụ `decide`). `reviewed` chỉ ghi lại tên và ngày, không có gì kiểm |

**Không thay đổi** ý nghĩa của `consistentOn`; không dùng ràng buộc toàn vẹn; không cho biết bản mã hóa có khớp luật. Cột «điểm mù D47–D50 chạm tới và không chạm tới» (một kỳ vọng, không phải phép đo):
[mutation-results.md](mutation-results.md) mục 8; số đo post-hoc: [mutation-posthoc-analyzereport.md](mutation-posthoc-analyzereport.md).

---

## 15. `Verify/Cases.lean` và `Laws/AlcoholSaleCases.lean` — ca thử cụ thể (đo faithfulness bằng tình huống viết từ luật)

**Cộng thêm, không sửa gì có sẵn. BẢN NHÁP, CHƯA AI DUYỆT.** Một *ca* = một tình huống cụ thể (giá trị atom theo mã atom và nhãn dải), một act, trạng thái mà người đọc khoản kỳ vọng
(`forbidden | required | explicitlyPermitted | clash | noNormApplies`), khoản nguồn và một đoạn trích nguyên văn. Bộ chạy tính trạng thái mà **mã hóa** cho và so sánh.

| Định nghĩa / định lý | Nội dung |
|---|---|
| `applyingNorms`, `mem_applyingNorms` | norm áp dụng được định nghĩa **qua `Norm.applies`**: `n ∈ applyingNorms ↔ n ∈ ns ∧ n.act = act ∧ n.applies A π s = some true` |
| `hasClash_iff_conflict` | trạng thái `clash` đúng bằng `Conflict` giữa hai norm của act đang thử |
| `runCase`, `CaseOutcome` | `pass` \| `fail got` \| `underspecified (atom thiếu)` \| `malformed`. **Fail closed**: ca không cố định mọi atom mà norm của act đọc là `underspecified`, kèm tên atom; không bao giờ mặc định giá trị |
| `runCase_pass_sound` | ca `pass` ⇒ không thiếu atom nào và trạng thái tính từ `Norm.applies` bằng kỳ vọng |
| `AlcoholSaleCases.pass_set` | kernel (`decide +kernel`) kiểm **đúng tập ca đạt**; ca không đạt do `notPassingNow` liệt kê lúc chạy |

**`noNormApplies` chỉ có nghĩa «không norm nào của mô-đun này áp dụng»**, không bao giờ là «hợp pháp»; văn bản in ra nói rõ như vậy.
Kết quả (37 ca): 36 đạt, 1 không đạt (C24: nhánh (i) của Điều 5 khoản 11 không được mã hóa). Phiếu cho người: [review/sale-group-cases.md](review/sale-group-cases.md); đáp án và độ phủ:
[review/sale-group-cases-key.md](review/sale-group-cases-key.md). **Ca, mã hóa và kỳ vọng cùng một nguồn**, nên 36/37 không phải bằng chứng khớp luật.

## 16. `Verify/CasesScoped.lean`, `Core/NumericBands.lean`, `Laws/AlcoholSaleBands.lean` — phạm vi của ca và ngưỡng số (D51, D52)

**Cộng thêm, không sửa gì có sẵn. BẢN NHÁP, CHƯA AI DUYỆT.**

**D51 — ca có phạm vi.** `runCase` trả `noNormApplies` cả khi điều khoản được mã hóa mà điều kiện sai, lẫn khi điều khoản *không được mã hóa* (ca C24). `runCaseScoped` nhận danh sách điều khoản `notEncoded` của mô-đun:

| Định nghĩa / định lý | Nội dung |
|---|---|
| `ScopedOutcome` | `ran (o : CaseOutcome)` \| `outOfScope clause` |
| `runCaseScoped_outOfScope` | điều khoản của ca có trong danh sách ⇒ kết quả là `outOfScope k`, bất kể `runCase` nói gì |
| `runCaseScoped_ran` | không có trong danh sách ⇒ kết quả đúng bằng `runCase` |
| `outOfScope_not_pass`, `scoped_pass_iff` | `outOfScope` không phải pass; chỉ ca trong phạm vi mới pass được |
| `unmentionedKeys` | điều khoản của ca không có trong norm đã mã hóa (`source.article`) lẫn danh sách `notEncoded` — là **finding** |
| `scopedReport` | in ca trong phạm vi trước, ca `OUT OF SCOPE` riêng, kèm «không nói gì về luật, không phải PASS», rồi các finding |

`Case.clause` thô hơn mục của `notEncoded` (cả khoản 11 so với nhánh (i)), nên bộ chạy nhận hàm `keyOf`; mô-đun cung cấp bảng ghi đè công khai (`keyOverride`, chỉ C24). So khớp là **bằng chuỗi**, không suy luận.
Kết quả trên 37 ca: C24 thành `outOfScope`; 36 ca còn lại như cũ (`scoped_pass_set` = `passing`). Finding: C37 viết «Điều 19 (tiêu đề)» còn danh sách viết «Điều 19 tiêu đề» (lệch chuỗi, `unmentioned_set`).

**D52 — dải số.** `NumBand` (cận dưới gồm, cận trên không gồm, nhãn, khoản nguồn của từng cận, cờ «luật có nêu cận này»), `tiles bs a b` (kiểm quyết định được: các dải nối liền phủ `[a,b)`, không hở, không chồng), `bandOf`.
`tiles_unique_band`: nếu `tiles` đúng thì mọi số trong khoảng có đúng một dải và `bandOf` trả nó; `tiles_bandOf_none`: ngoài khoảng `bandOf = none`. Trong `AlcoholSaleBands`: dải tuổi (năm nguyên) `[0,150)` và độ cồn (phần mười độ) `[0,1000)`; các cận 0, 150 tuổi, 1000 **không có trong luật** và được in là «assumed, not in the law» (`assumedBounds`); `age_labels`/`alcohol_labels` kiểm nhãn dải bằng nhãn trong `tS`; 20 ca số (10 ca ranh giới cũ có số, 6 ca đúng ranh giới, 4 ca ngay trên ranh giới) ánh xạ qua `bandOf` rồi chạy bằng `runCase`, kernel kiểm (`num_pass_all`); ngoài thang cho `outOfRange` (`num_out_of_range`).
**Bộ kiểm vẫn không biết các con số nghĩa là gì**: không biết 150 là «15 độ», không biết luật tính tuổi theo năm nguyên. Nó chỉ biết các dải nối liền nhau. Ranh giới sai mà vẫn nối liền thì vô hình.
Ca số cùng nguồn với mã hóa (cùng tác giả), nên «đạt» là đồng thuận với người soạn, không phải với luật.

## 17. `Core/ClauseRef.lean`, `Laws/AlcoholSaleRefs.lean`, `pipeline/segment.py` — tham chiếu có cấu trúc, phạm vi theo tham chiếu, sổ phủ

**Cộng thêm, không sửa gì có sẵn. BẢN NHÁP, CHƯA AI DUYỆT.**

| Định nghĩa | Nội dung |
|---|---|
| `ClauseRef` | `article`, `clause?`, `point?` (chữ cái, có `đ`), `part` (`body` \| `heading`), `branch?` — **ký hiệu của dự án, không phải đơn vị pháp lý** («nhánh (i)»); `isProjectNotation` |
| `parseRef`, `parseEntry` | bộ phân tích tất định trên `List Char`, **từ chối** mọi dạng ngoài văn phạm (ghi ở đầu tệp); `parseEntry` đọc thêm «Điều N khoản a, b, c» |
| `render`, `normalize` | cách viết chuẩn; `«Điều 19 (tiêu đề)»` và `«Điều 19 tiêu đề»` về cùng một tham chiếu |
| `isAncestorOf`, `isParentOf` | đường dẫn là tiền tố thực sự; tiêu đề treo dưới điều và không bao giờ là tổ tiên |
| `runCaseRefScoped` | phạm vi của ca chỉ từ tham chiếu (không bảng ghi đè): tiêu đề không bao giờ đưa ca ra ngoài phạm vi (G1: tiêu đề cho modality và act xuống các khoản); mục `notEncoded` là tổ tiên hoặc bằng ⇒ `outOfScope`; mục là hậu duệ ⇒ trong phạm vi chỉ khi có norm **cùng act** trích dẫn tham chiếu liên quan; còn lại ⇒ đúng bằng `runCase` |
| `render_parse_allRefs` | **kiểm bằng kernel** (`decide +kernel`) `parse ∘ render = id` trên mọi giá trị tham chiếu xuất hiện trong mô-đun; **không phải** định lý tổng quát |

Kết quả trên 37 ca: C24 ra ngoài phạm vi (khoản 11 có nhánh (i) không mã hóa và không norm nào cùng act); C37 trong phạm vi; **C23 cũng ra ngoài phạm vi** — hệ quả của quy tắc, vì tham chiếu và act không phân biệt được tình huống của C23 có thuộc nhánh (i) hay không (bảng ghi đè cũ để C23 trong phạm vi). Finding: hai chuỗi khác nhau cùng tham chiếu (C37 so với `notEncoded`); norm 5.11-ii trích dẫn cả khoản 11 chứ không riêng nhánh (ii), nên khoản 11 là «encoded một phần». Không có chuỗi nào không phân tích được; không tham chiếu nào ngoài `catalog` (catalog chỉ kiểm số điều, không kiểm sự tồn tại của khoản).

**Phân đoạn và sổ phủ.** `pipeline/segment.py` (Python, **không tin cậy**) ghi `data/segmented/44-2019-QH14.json` (kèm sha256 đầu vào và phiên bản công cụ). Các kiểm tra S1–S5 chỉ chứng minh kết quả nhất quán với chính tệp trích xuất; xóa một dòng nội dung thường không bị S1/S2/S3/S5 phát hiện, chỉ bị ghim sha256 phát hiện (có test). `eval/ledger/make_ledger.py` ghép với đầu ra của `Dump.lean` để lập `docs/review/alcohol-coverage-ledger.md`: mỗi khoản/điểm đúng một trạng thái; «encoded» = có norm nháp chưa duyệt, không nói gì về faithfulness.

## 18. `pipeline/report.py`, `eval/report/Dump.lean` — lệnh báo cáo (D55–D58), và D54 đã hoàn tác

**Không phải Lean trong thư viện. BẢN NHÁP, CHƯA AI DUYỆT. Công cụ không tin cậy: nó định dạng điều Lean in ra, không chứng minh gì.**

| Thành phần | Nội dung |
|---|---|
| `eval/report/Dump.lean` | chạy bằng `lake env lean --run`, **không** nằm trong thư viện, không ai import. In JSON: kết quả `analyzeReport .draft` (kèm cờ `noModalityClash`, act, ưu tiên, `render`), phát hiện của `pfindings`, phát hiện tham chiếu, 37 ca (kết quả `runCase`, phạm vi theo tham chiếu, phạm vi theo bảng ghi đè cũ), 20 ca số, cận giả định, danh sách `notEncoded`. Chỉ **chạy** định nghĩa có sẵn |
| `report.py` | chạy `lake build LexProof` (thất bại thì không ghi báo cáo; đọc số khai báo kiểm toán từ dòng `axiom audit:` ), chạy dump, ghép với `data/segmented` và sổ phủ, ghi `reports/alcohol-sale-<ngày>.md`. Bảy mục: trạng thái, phạm vi, kết quả ba giá trị, phát hiện, ca thử, «KHÔNG nói gì», nguồn gốc |
| định lý ↔ máy diễn giải | phát biểu của `consistent`, `silent`, `pass_set`, `refOutOfScope_set`, `num_pass_all`, `unparsable_none`, `notInCatalog_none`, `sameRef_c37` được **đọc từ mã nguồn** bằng biểu thức chính quy rồi so với đầu ra của dump. Định lý đúng vì `lake build` vừa xanh; báo cáo không tự chứng minh điều đó. Kết quả không có định lý ghi «chưa có định lý kernel cho kết quả này» |
| `--status reviewed --by NAME --date D` | **từ chối** nếu phiếu `docs/review/sale-group-cases.md` còn hàng chưa điền (mỗi hàng: đúng/sai ý và câu trả lời có đúng một ô được đánh dấu, người duyệt, ngày), hoặc thiếu dòng `sha256 mô-đun khi duyệt:`, hoặc mã đó khác sha256 hiện tại của `Laws/AlcoholSale.lean`, hoặc thiếu/sai dòng `sha256 tệp ca thử khi duyệt:` (so với `Laws/AlcoholSaleCases.lean`), hoặc `--by` không có trong cột Người duyệt, hoặc ngày của hàng không hợp lệ/muộn hơn `--date`. Khi chấp nhận, ghi sha256 của phiếu, của tệp mô-đun và của tệp ca thử. Kiểm này chỉ chứng tỏ phiếu đủ chữ và mô-đun chưa đổi; không kiểm danh tính hay nội dung câu trả lời |
| sha256 | mọi tệp được băm hai cách khi cần: nguyên byte và «CRLF đọc như LF». Git lưu LF nhưng bản làm việc trên Windows là CRLF, nên mã băm nguyên byte của `data/extracted/44-2019-QH14.txt` (mã bộ tách ghim) **khác** mã của blob trong git (`46c2f4e0…`). Báo cáo ghi cả hai |

**D54 (mức chi tiết của nguồn 5.11-ii, C22–C24) đã thử và hoàn tác.** Đổi nguồn sang «Điều 5 khoản 11 nhánh (ii)» và C22/C24 sang nhánh tương ứng làm `AlcoholSaleBands.unmentioned_set` sai (C23 còn trích khoản 11 nguyên, không norm nào dùng chuỗi đó); đổi cả C23 thì `AlcoholSaleRefs.refOutOfScope_set` sai (`["C23","C24"]` thành `["C24"]`). Quy tắc là không được đổi phát biểu định lý nào, nên không giữ thay đổi nào (`eval/cases/RECORD.md`). Hai cách xác định phạm vi hiện khác nhau ở đúng một ca: **C23** (cách mới: ngoài phạm vi; bảng ghi đè cũ: trong phạm vi).

**D58 — hai con số «đoạn không đánh số».** `stray_paragraphs = 2` của bộ tách đếm *dòng* thụt đầu dòng không đánh số nằm trong một khoản hoặc điểm (Điều 35 khoản 1 và 2). Sổ phủ đếm *đoạn dẫn*: 6 điều có văn bản đứng trước khoản đầu tiên hoặc không chia khoản (Điều 1, 2, 11, 13, 14, 18). Báo cáo dùng số của sổ phủ (6) cho mục phạm vi và ghi số của bộ tách riêng ở mục nguồn gốc. Tài liệu sai là câu mô tả ở sổ phủ (gọi chung là «đoạn không đánh số»); đã sửa. Bộ tách không bị chỉnh.
