# LexProof — Ma trận truy vết và bảng khẳng định

Tài liệu này trả lời hai câu hỏi: **mỗi yêu cầu được hiện thực ở đâu**, và
**mỗi khẳng định của hệ thống dựa trên bằng chứng gì** — kèm phần quan trọng
hơn: **bằng chứng đó *không* bao phủ cái gì**.

Nguồn: [requirements.md](requirements.md), [design-core.md](design-core.md),
[decisions/](decisions/README.md).

---

## 1. Ma trận truy vết

Cột **Lean** ghi khai báo thật trong code; `—` nghĩa là chưa có.

### 1.1 Yêu cầu chức năng

| YC | Phần tử thiết kế | Khai báo / định lý Lean | Test / eval | Trạng thái |
|---|---|---|---|---|
| FR1 | Tier 1 Segmenter | — | — | Planned |
| FR2 | Tier 1 Glossary; [ADR-0004](decisions/0004-act-as-opaque-glossary-id.md) | `Act` (kiểu đích) | — | Planned |
| FR3 | Tier 2 Translator; lược đồ `Norm` | `Norm`, `Cond`, `SourceId` | `Smoke.normA`, `normB` | Planned *(lược đồ: Implemented)* |
| FR4 | Tier 2 Loop A | — | — | Planned |
| FR5 | Tier 2 Back-translator; [ADR-0019](decisions/0019-back-translation-renderer.md) | — | — | **Open** |
| FR6 | `Core` lược đồ chuẩn tắc | `Modality`, `Cond`, `Norm.exceptions`, `Norm.priority`, tham số `P`, `Norm.applies` | `smoke_conflict`, `smoke_consistent` | Implemented |
| FR7 | `Verify` bộ kiểm; `Result` 5 nhánh | `Result`, `check`, `analyze`, (a) `conflict_of_witness`, (b) `not_conflict_of_consistentOn`, (e) `conflict_all_params`, `conditionalConflict_split` | `Smoke.*` (4), `Tests.conditional_conflict_found`, `Tests.conditional_conflict_splits` | Implemented |
| FR8 | Tier 2 Validator; [ADR-0017](decisions/0017-wellformedness-validator-first.md) | `Finding`, `validate`, `inPriorityCycle`, `duplicateIds`, (f) `wf_of_validate_nil` | `Tests` ca 1–5 (chu trình, trùng id, tham chiếu treo, dị dạng, rỗng) | Implemented *(chỉ `wf_of_validate_nil` có chứng minh; các check khác chỉ có test)* |
| FR9 | Tier 4 Phản ví dụ | `Counterexample` (+ `Repr`), `ceOf`, `Result.witness?`, (c) `counterexample_fields_correct` | `smoke_conflict`, `Tests.conflict_reported_with_bad_norm` | Planned *(dữ liệu: Implemented, và (c) chứng minh mọi trường khớp; render tiếng Việt: chưa có)* |
| FR10 | Tier 4 Báo cáo | `Scope`, `scopeOf` | `smoke_consistent` so khớp nguyên khối `Scope` | Planned |
| FR11 | `Cert` audit axiom | — *(thư mục rỗng)* | `#print axioms` **thủ công** | Planned |
| FR12 | Ca chuyên gia | — | — | Planned |
| FR13 | Tier 4 Phiên bản | `SourceId.docId`, `.docType`, `.effective` | — | Planned |

### 1.2 Yêu cầu phi chức năng

| YC | Phần tử thiết kế | Khai báo / định lý Lean | Test / eval | Trạng thái |
|---|---|---|---|---|
| N1 Soundness | [ADR-0010](decisions/0010-axiom-whitelist-decide-only.md) | `isConflictAt_eq_true_iff`, `conflict_of_witness`, `not_conflict_of_consistentOn` | `#print axioms` (đo: chỉ `propext`, `Quot.sound`) | Implemented *(audit thủ công)* |
| N2 Honest scope | `Result`, `Scope`; [ADR-0018](decisions/0018-scope-lists-parameter-names.md) | `Result.consistentOn` **bắt buộc** mang `Scope`; `not_conflict_of_consistentOn` chỉ kết luận trên `ns` | `smoke_consistent` | Implemented *(một phần: `Scope` chưa có trạng thái duyệt)* |
| N3 Fail-closed | [ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md), [ADR-0017](decisions/0017-wellformedness-validator-first.md) | `Cond.eval : … → Option Bool`, `Norm.applies`, `validate`, `Audit.unevaluable`, `Result.invalid` | `Tests` ca 4, 5, 9 | Implemented *(trừ ngân sách: `outOfBudget` vẫn chưa có — N8)* |
| N4 Faithfulness | [ADR-0011](decisions/0011-trust-boundary-human-approval.md) | — *(không chứng minh được)* | — | Planned |
| N5 Evaluability | Tiêm xung đột | — | — | Planned *(không có AC — xem báo cáo)* |
| N6 Traceability | `SourceId` | `SourceId.article`, `Counterexample.sources`, `Scope.articles` | `smoke_conflict` chứa `srcA`, `srcB` | Implemented *(mức lược đồ)* |
| N7 Reproducibility | Ghim toolchain | — | `lean-toolchain` = `v4.35.0`; `lake-manifest.json` rỗng | Planned *(log LLM chưa có)* |
| N8 Scale | Ngân sách liệt kê | `Finite.card`, `Scope.situations`, `Scope.params` | Số đo 2^12…2^18 (**đại diện**, không bằng `check`) | Planned *(`outOfBudget` chưa có)* |
| N9 Maintainability | `Core` độc lập văn bản | `Norm` không mang tham số kiểu; `check` nhận `S`, `P` trừu tượng | — *(`Laws/` rỗng nên chưa kiểm được)* | Planned |
| N10 Usability | Tier 4 | `deriving Repr` | — | Planned |
| N11 Legal/ethical | Chính sách | — | — | Planned |
| N12 Build integrity | `LexProof.lean` import đủ 5 module | — | `lake build` trần: 20 jobs, biên dịch mọi module | Implemented *(build xanh **không** kiểm axiom — đó là FR11)* |

### 1.3 Yêu cầu không có phần tử Lean nào

FR1, FR2, FR4, FR5, FR11, FR12, N4, N5, N10, N11 hiện **không có** khai báo
Lean nào tương ứng. Với **FR11** (audit axiom tự động, `Cert/` rỗng) đây là rủi
ro trực tiếp cho G1: `lake build` nay biên dịch mọi module (N12 đã sửa), nhưng
build xanh không kiểm axiom, nên không có gì chặn một commit sau đưa
`native_decide` hay `sorryAx` vào mà CI vẫn xanh.

---

## 2. Bảng khẳng định: G1, G2, G3

Ba mục tiêu chất lượng của [architecture.md](architecture.md). Với mỗi cái:
bằng chứng hiện có, và **giới hạn** của bằng chứng đó.

### G1 — Soundness: kernel Lean chấp nhận chứng minh

**Bằng chứng**

| # | Bằng chứng | Trạng thái |
|---|---|---|
| G1.1 | `isConflictAt_eq_true_iff` — bộ kiểm dạng `Bool` **tương đương hai chiều** với `Conflict` dạng `Prop` | Implemented |
| G1.2 | `conflict_of_witness` (a) — báo xung đột ⇒ nhân chứng là `Conflict` thật giữa hai norm thuộc `ns`, tại điểm `valid` | Implemented |
| G1.2b | `counterexample_fields_correct` (c) — **mọi trường** được báo (id, modality, source) khớp norm thật | Implemented |
| G1.3 | `not_conflict_of_consistentOn` (b) — báo `consistentOn` ⇒ không `Conflict` nào tại **mọi** `π`, `s` **valid** | Implemented |
| G1.3b | `conflict_all_params`, `conditionalConflict_split` (e) — hai nhãn đúng nghĩa | Implemented |
| G1.3c | `scopeOf_spec`, `check_scope` (d) — scope nói đúng ids/articles/kích thước miền, và mọi kết quả đã quét đều báo scope đó | Implemented |
| G1.4 | `Finite.complete` + `mem_cands` + `mem_pairsOf` + `Conflict_comm` + `not_conflict_self` — phép liệt kê **chứng minh được** là không bỏ sót, dù chỉ quét mỗi cặp một lần | Implemented |
| G1.7 | `applies_isSome_of_validate_nil` (f) — validate sạch ⇒ `applies` không bao giờ `none`, ở **mọi** `(π, s)` | Implemented |
| G1.5 | `#print axioms` trên 48 khai báo: tất cả ⊆ `{propext, Classical.choice, Quot.sound}`; không `sorryAx` | Implemented *(thủ công)* |
| G1.6 | Grep: không `sorry`, `native_decide`, `bv_decide`, `axiom`, `unsafe`, `partial` | Implemented *(thủ công)* |

**G1 KHÔNG bao phủ**

- **Không** bao phủ việc `Conflict` có đúng là khái niệm xung đột pháp lý hay
  không. Đó là G2. Kernel kiểm *suy luận*, không kiểm *định nghĩa*.
- **Không** bao phủ tính đúng đắn của **validator**: `inPriorityCycle` (kể cả
  việc `ns.length` bước là đủ), `duplicateIds`, và hai thành phần finding còn
  lại chỉ được kiểm bằng ca kiểm thử, không có định lý. Định lý duy nhất của
  validator là `wf_of_validate_nil`.
- **Không** bao phủ `Audit.resolutions`: không định lý nào nói nó liệt kê **đủ**
  và **đúng** các clash đã được ưu tiên giải quyết.
- **Không** bao phủ khi nào `Result.unknown` xuất hiện; chỉ bảo đảm rằng sau một
  lần `validate` sạch thì `applies` không bao giờ `none` (G1.7).
- **Không** bao phủ ngân sách: `UnknownReason` vẫn **không có** `outOfBudget`,
  và không có cơ chế đo hay chặn (N8).
- **Không** bao phủ `Atoms.valid`. Mọi định lý nói "trên phần `valid`"; một
  `valid` quá mạnh làm chúng đúng mà vô nghĩa. Xem mục 3.
- **Không** bao phủ việc audit axiom được *chạy*. G1.5 và G1.6 là thao tác tay;
  `lake build` nay biên dịch mọi module (N12 đã sửa) nhưng build xanh **không**
  kiểm axiom, và `Cert/` vẫn rỗng (FR11).
- **Không** bao phủ `Scope.docId` khi danh sách lẫn norm của hai văn bản: lấy từ
  `ns.head?` nên sẽ báo sai mà không ai phát hiện.
- **Không** bao phủ chính kernel Lean, `List`/`Option` của Lean core, và trình
  biên dịch.

### G2 — Faithfulness: bản mã hóa khớp với luật

**Bằng chứng**

| # | Bằng chứng | Trạng thái |
|---|---|---|
| G2.1 | Người duyệt phê duyệt là cổng **duy nhất** vào `Laws` ([ADR-0011](decisions/0011-trust-boundary-human-approval.md)) | Planned *(hiện là quy ước, không cưỡng chế)* |
| G2.2 | Dịch ngược tiếng Việt để đối chiếu song song (FR5) | **Open** ([ADR-0019](decisions/0019-back-translation-renderer.md)) |
| G2.3 | Ca kiểm thử chuyên gia, tỉ lệ đạt trước/sau duyệt (FR12, N4) | Planned |
| G2.4 | `Norm` là **dữ liệu**, in được và so sánh được, nên duyệt được bằng mắt ([ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md)) | Implemented |
| G2.5 | Mọi norm giữ `source.article` (N6) | Implemented *(mức lược đồ)* |

**G2 KHÔNG bao phủ**

- **Không có bằng chứng máy nào, và sẽ không bao giờ có.** Kernel không thể
  kiểm một bản mã hóa có khớp với một văn bản tiếng Việt hay không. Mọi bằng
  chứng cho G2 là *của con người* và *theo mẫu*.
- Hiện tại **gần như trống**: G2.1 chưa cưỡng chế, G2.2 chưa quyết, G2.3 chưa
  có. Thực tế đang dựa vào G2.4 và G2.5, tức chỉ là *khả năng* duyệt được, chứ
  chưa phải *đã duyệt*.
- Bị chặn trên bởi chất lượng việc duyệt: người duyệt bỏ qua thì không còn lớp
  nào phía sau.
- Những sai sót mà G2 đặc biệt khó bắt: hai act đáng ra giống nhau bị gán hai id
  khác nhau ([ADR-0004](decisions/0004-act-as-opaque-glossary-id.md)); nhầm
  giữa ngoại lệ và ưu tiên ([ADR-0005](decisions/0005-exceptions-vs-priority.md));
  một khái niệm mở bị nhúng thành hằng thay vì thành tham số.
- Nếu dịch ngược dùng LLM cùng họ với dịch xuôi, G2.2 có **lỗi tương quan** và
  mất phần lớn giá trị ([ADR-0019](decisions/0019-back-translation-renderer.md)).
- `LexProof/Verify/Smoke.lean` **không** là bằng chứng G2: docstring của nó ghi
  rõ đó là norm bịa, không ai duyệt về faithfulness.

### G3 — Honest scope: không bao giờ khẳng định quá phần đã mã hóa và đã duyệt

**Bằng chứng**

| # | Bằng chứng | Trạng thái |
|---|---|---|
| G3.1 | `Result` **không có** constructor nào nghĩa là "văn bản đúng" | Implemented |
| G3.2 | `Result.consistentOn` **bắt buộc** mang `Scope`; không thể trả nhất quán mà không có scope | Implemented |
| G3.3 | `not_conflict_of_consistentOn` chỉ lượng hóa trên `ns` truyền vào, không trên văn bản | Implemented |
| G3.4 | `Scope` ghi `docId`, `normIds`, `articles`, `\|S\|`, `\|P\|` | Implemented |
| G3.5 | `unknown` tồn tại như một kết quả hạng nhất; dị dạng không thành "không áp dụng" | Implemented |
| G3.6 | Khái niệm mở là tham số, hệ thống không tự quyết ([ADR-0003](decisions/0003-open-concepts-as-finite-parameters.md)) | Implemented |
| G3.7 | `Scope` ghi tên tham số và trạng thái duyệt | **Planned** ([ADR-0018](decisions/0018-scope-lists-parameter-names.md)) |

**G3 KHÔNG bao phủ**

- `Scope` hiện **không** nói norm nào đã duyệt. Vì vậy N2 chỉ đạt *một phần*:
  có scope về cấu trúc, chưa có scope về mức độ tin cậy.
- `Scope.params : Nat` chỉ là **số lượng**, không phải tên; người đọc không biết
  kết luận đã lượng hóa trên những cách hiểu nào
  ([ADR-0018](decisions/0018-scope-lists-parameter-names.md) còn Planned).
- `Scope.validRestricted` chỉ là một `Bool`: nó nói miền đã bị thu hẹp, **không**
  nói thu hẹp cái gì. Người đọc không biết phần nào của miền đã bị loại.
- `scopeOf` lấy `docId` từ `ns.head?`. Nếu danh sách lẫn norm của hai văn bản,
  `Scope` **báo sai** và không có gì phát hiện.
- G3 là tính chất của **đầu ra Lean**. Khi Tier 4 viết báo cáo tiếng Việt, không
  có gì bảo đảm bản tiếng Việt giữ được sự dè dặt đó — đó là ràng buộc quy
  trình, không phải ràng buộc kiểu.

**Đã sửa** so với bản trước (nay có ca kiểm thử ghim lại):

- `check A []` nay là `.invalid [.emptyNormList]`, không còn là `consistentOn`
  trên không có gì — `Tests.empty_is_a_finding`.
- Một `conflict` không còn che norm chưa đánh giá được: `Audit.unevaluable` đi
  kèm **mọi** kết quả đã quét — `Tests.bad_norm_also_reported`.
- `validate` nêu **đúng** norm dị dạng, không nêu norm lành —
  `Tests.validator_names_the_bad_norm`.

---

## 3. Trust base — các định nghĩa được tin mà không được chứng minh

Kernel Lean **không phải** toàn bộ cơ sở tin cậy. Năm định nghĩa sau nằm **cùng
kernel** trong trust base. Chúng là *tiên đề nội dung* của hệ thống: kernel kiểm
mọi suy luận *từ* chúng, nhưng **không có gì chứng minh chúng khớp với luật**.
Sai một trong năm cái này thì mọi định lý vẫn đúng — và mọi kết luận vẫn vô giá
trị.

| Định nghĩa | Ở đâu | Điều được tin mà không chứng minh | Hỏng thì sao |
|---|---|---|---|
| `Conflict` | `Verify/Conflict.lean` | Rằng "cùng act + cả hai áp dụng + modality khắc nhau + không có ưu tiên" **chính là** xung đột pháp lý | Toàn bộ kết luận sai nghĩa. Mọi định lý vẫn qua kernel |
| `Norm.applies` | `Core/Norm.lean` | Rằng `condition && !(OR exceptions)` là cách đúng để ghép điều kiện với ngoại lệ | Norm áp dụng sai chỗ ⇒ cả xung đột lẫn nhất quán đều sai |
| `Norm.resolved` | `Core/Norm.lean` | Rằng ưu tiên tường minh là **cách duy nhất** giải quyết một clash | Nay là XOR, nên override lẫn nhau không còn bị coi là đã giải quyết ([ADR-0013](decisions/0013-directional-priority-and-cycles.md)); nhưng giả định "chỉ ưu tiên tường minh mới giải quyết được" vẫn là điều được tin, không được chứng minh |
| `Atoms.valid` | `Core/Norm.lean` | Rằng những cặp `(π, s)` nó loại bỏ **thật sự không thể xảy ra** | **Một `valid` quá mạnh che xung đột thật.** Mọi định lý đều có dạng "trên phần `valid`", nên không định lý nào phát hiện được việc này. Đây là bề mặt tin cậy *mới* thêm vào, và là cái dễ bị lạm dụng nhất |
| `Incompatible` | `Core/Norm.lean` | Rằng đúng hai cặp modality đó xung đột, không hơn không kém | Báo nhiễu, hoặc bỏ sót im lặng ([ADR-0001](decisions/0001-incompatible-modalities.md)) |
| `Cond.eval` | `Core/Norm.lean` | Rằng `and`/`or`/`not` trên `Option Bool` khớp với cách luật ghép điều kiện | Điều kiện bị hiểu sai ⇒ phạm vi áp dụng sai |

Ngoài năm cái trên, trust base còn gồm: **kernel Lean 4.35.0**, **Lean core**
(`List`, `Option`, `Decidable`, và các bổ đề đã dùng), ba axiom trong whitelist,
và — với mọi dữ liệu trong `Laws` — **phán đoán của người duyệt**.

**Hệ quả thực tiễn**: cách duy nhất làm tăng niềm tin vào năm định nghĩa này là
**ca kiểm thử của chuyên gia** (FR12) và **duyệt chéo** — chính là G2. Thêm
định lý không giúp gì, vì định lý nào cũng nằm *phía sau* chúng.
