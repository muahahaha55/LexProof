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
| FR7 | `Verify` bộ kiểm 4 kết quả | `Result`, `check`, **`conflict_of_witness`**, **`not_conflict_of_consistentOn`** | `smoke_conflict`, `smoke_consistent`, `smoke_conflict_is_real`, `smoke_no_conflict_anywhere` | Implemented *(nhãn `conditionalConflict` chưa có định lý — [ADR-0015](decisions/0015-characterize-conflict-labels.md))* |
| FR8 | Tier 2 Validator; [ADR-0017](decisions/0017-wellformedness-validator-first.md) | — | — | Planned |
| FR9 | Tier 4 Phản ví dụ | `Counterexample` (+ `Repr`), `ceOf`, `Result.witness?` | `smoke_conflict` so khớp nguyên khối witness | Planned *(dữ liệu: Implemented; render tiếng Việt: chưa có)* |
| FR10 | Tier 4 Báo cáo | `Scope`, `scopeOf` | `smoke_consistent` so khớp nguyên khối `Scope` | Planned |
| FR11 | `Cert` audit axiom | — *(thư mục rỗng)* | `#print axioms` **thủ công** | Planned |
| FR12 | Ca chuyên gia | — | — | Planned |
| FR13 | Tier 4 Phiên bản | `SourceId.docId`, `.docType`, `.effective` | — | Planned |

### 1.2 Yêu cầu phi chức năng

| YC | Phần tử thiết kế | Khai báo / định lý Lean | Test / eval | Trạng thái |
|---|---|---|---|---|
| N1 Soundness | [ADR-0010](decisions/0010-axiom-whitelist-decide-only.md) | `isConflictAt_eq_true_iff`, `conflict_of_witness`, `not_conflict_of_consistentOn` | `#print axioms` (đo: chỉ `propext`, `Quot.sound`) | Implemented *(audit thủ công)* |
| N2 Honest scope | `Result`, `Scope`; [ADR-0018](decisions/0018-scope-lists-parameter-names.md) | `Result.consistentOn` **bắt buộc** mang `Scope`; `not_conflict_of_consistentOn` chỉ kết luận trên `ns` | `smoke_consistent` | Implemented *(một phần: `Scope` chưa có trạng thái duyệt)* |
| N3 Fail-closed | [ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md), [ADR-0017](decisions/0017-wellformedness-validator-first.md) | `Cond.eval : … → Option Bool`, `Norm.applies`, `UnknownReason` | `#eval` trên `badNorm` (đã kiểm, **phát hiện khuyết điểm**) | Planned |
| N4 Faithfulness | [ADR-0011](decisions/0011-trust-boundary-human-approval.md) | — *(không chứng minh được)* | — | Planned |
| N5 Evaluability | Tiêm xung đột | — | — | Planned *(không có AC — xem báo cáo)* |
| N6 Traceability | `SourceId` | `SourceId.article`, `Counterexample.sources`, `Scope.articles` | `smoke_conflict` chứa `srcA`, `srcB` | Implemented *(mức lược đồ)* |
| N7 Reproducibility | Ghim toolchain | — | `lean-toolchain` = `v4.35.0`; `lake-manifest.json` rỗng | Planned *(log LLM chưa có)* |
| N8 Scale | Ngân sách liệt kê | `Finite.card`, `Scope.situations`, `Scope.params` | Số đo 2^12…2^18 (**đại diện**, không bằng `check`) | Planned *(`outOfBudget` chưa có)* |
| N9 Maintainability | `Core` độc lập văn bản | `Norm` không mang tham số kiểu; `check` nhận `S`, `P` trừu tượng | — *(`Laws/` rỗng nên chưa kiểm được)* | Planned |
| N10 Usability | Tier 4 | `deriving Repr` | — | Planned |
| N11 Legal/ethical | Chính sách | — | — | Planned |
| N12 Build integrity | `lakefile.toml`, CI | — | **Đã kiểm: đang bị vi phạm** | **Open** |

### 1.3 Yêu cầu không có phần tử Lean nào

FR1, FR2, FR4, FR5, FR8, FR11, FR12, N4, N5, N10, N11, N12 hiện **không có**
khai báo Lean nào tương ứng. Với FR11 và N12 thì đây là rủi ro trực tiếp cho
G1, vì chúng là hai thứ đáng ra phải bảo vệ các định lý khỏi bị hỏng âm thầm.

---

## 2. Bảng khẳng định: G1, G2, G3

Ba mục tiêu chất lượng của [architecture.md](architecture.md). Với mỗi cái:
bằng chứng hiện có, và **giới hạn** của bằng chứng đó.

### G1 — Soundness: kernel Lean chấp nhận chứng minh

**Bằng chứng**

| # | Bằng chứng | Trạng thái |
|---|---|---|
| G1.1 | `isConflictAt_eq_true_iff` — bộ kiểm dạng `Bool` **tương đương hai chiều** với `Conflict` dạng `Prop` | Implemented |
| G1.2 | `conflict_of_witness` — báo xung đột ⇒ nhân chứng là `Conflict` thật giữa hai norm thuộc `ns` | Implemented |
| G1.3 | `not_conflict_of_consistentOn` — báo `consistentOn` ⇒ không `Conflict` nào với **mọi** `π`, `s` | Implemented |
| G1.4 | `Finite.complete` + `mem_cands` — phép liệt kê **chứng minh được** là không bỏ sót | Implemented |
| G1.5 | `#print axioms`: tất cả ⊆ `{propext, Classical.choice, Quot.sound}`; không `sorryAx` | Implemented *(thủ công)* |
| G1.6 | Grep: không `sorry`, `native_decide`, `bv_decide`, `axiom`, `unsafe`, `partial` | Implemented *(thủ công)* |

**G1 KHÔNG bao phủ**

- **Không** bao phủ việc `Conflict` có đúng là khái niệm xung đột pháp lý hay
  không. Đó là G2. Kernel kiểm *suy luận*, không kiểm *định nghĩa*.
- **Không** bao phủ nhãn `conflict` vs `conditionalConflict`: không định lý nào
  phân biệt hai nhãn ([ADR-0015](decisions/0015-characterize-conflict-labels.md)).
- **Không** bao phủ `Result.unknown`: không có gì bảo đảm `unknown` chỉ xuất
  hiện khi thật có norm dị dạng, và đã kiểm thấy nó **báo sai tên norm**.
- **Không** bao phủ việc audit axiom được *chạy*. G1.5 và G1.6 là thao tác tay;
  không có gì ngăn một commit sau làm chúng sai. **Nặng hơn**: `lake build`
  trần không build các module này (N12), nên CI hiện **không** kiểm cả G1.
- **Không** bao phủ `check` trên danh sách rỗng: `check A [] = consistentOn`
  với scope rỗng — đúng về logic, dễ gây hiểu sai khi báo cáo.
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
  kết luận đã lượng hóa trên những cách hiểu nào.
- `scopeOf` lấy `docId` từ `ns.head?`. Nếu danh sách lẫn norm của hai văn bản,
  `Scope` **báo sai** và không có gì phát hiện.
- `check A [] = consistentOn` với scope rỗng: "nhất quán" trên không có gì.
  Tầng báo cáo (FR10) phải chặn, Lean không chặn.
- Một `conflict` được báo có thể **che** việc còn norm chưa đánh giá được (đã
  kiểm: `check atoms [normA, normB, badNorm]` không nhắc `badNorm`). Báo cáo khi
  đó không đầy đủ dù không sai.
- G3 là tính chất của **đầu ra Lean**. Khi Tier 4 viết báo cáo tiếng Việt, không
  có gì bảo đảm bản tiếng Việt giữ được sự dè dặt đó — đó là ràng buộc quy
  trình, không phải ràng buộc kiểu.

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
| `Norm.resolved` | `Core/Norm.lean` | Rằng ưu tiên tường minh là **cách duy nhất** giải quyết, và (bản hiện tại) rằng **đối xứng** là đúng | Hiện bỏ sót trường hợp override lẫn nhau — xem [ADR-0013](decisions/0013-directional-priority-and-cycles.md) |
| `Incompatible` | `Core/Norm.lean` | Rằng đúng hai cặp modality đó xung đột, không hơn không kém | Báo nhiễu, hoặc bỏ sót im lặng ([ADR-0001](decisions/0001-incompatible-modalities.md)) |
| `Cond.eval` | `Core/Norm.lean` | Rằng `and`/`or`/`not` trên `Option Bool` khớp với cách luật ghép điều kiện | Điều kiện bị hiểu sai ⇒ phạm vi áp dụng sai |

Ngoài năm cái trên, trust base còn gồm: **kernel Lean 4.35.0**, **Lean core**
(`List`, `Option`, `Decidable`, và các bổ đề đã dùng), ba axiom trong whitelist,
và — với mọi dữ liệu trong `Laws` — **phán đoán của người duyệt**.

**Hệ quả thực tiễn**: cách duy nhất làm tăng niềm tin vào năm định nghĩa này là
**ca kiểm thử của chuyên gia** (FR12) và **duyệt chéo** — chính là G2. Thêm
định lý không giúp gì, vì định lý nào cũng nằm *phía sau* chúng.
