# LexProof — Đặc tả yêu cầu

Khuôn theo **ISO/IEC/IEEE 29148**: mỗi yêu cầu có ID duy nhất, một phát biểu
"phải" (shall), độ ưu tiên MoSCoW, tiêu chí chấp nhận (AC), phương pháp kiểm
chứng (Proof | Test | Review | Demo) và trạng thái.

**Trạng thái** chỉ nhận một trong ba giá trị:

| Trạng thái | Nghĩa |
|---|---|
| **Implemented** | Có **định lý** hoặc **ca kiểm thử kernel kiểm** chống lưng |
| **Tested** | Có ca kiểm thử chạy được, nhưng không phải kernel kiểm (script, CI), hoặc kernel kiểm nhưng chỉ **một ví dụ** chứ không phải mệnh đề tổng quát |
| **Evaluated** | Chỉ chạy bằng trình biên dịch (`#eval`); kernel **không** kiểm. Là chẩn đoán, không phải chứng minh |
| Planned | Đã quyết định, chưa có code |
| Open | Chưa quyết định xong |

Phân biệt này là có chủ ý: "Implemented" **không** được dùng cho thứ chỉ chạy
thử. Ví dụ: `docIdsOf` không phụ thuộc thứ tự đầu vào là **Tested một ví dụ**,
và phép so cạn trên đồ thị 4 đỉnh là **Evaluated**.

Phạm vi: **Level 1** — nhất quán *trong một* văn bản. Level 2 (giữa các văn
bản, thứ bậc hiệu lực) ngoài phạm vi, xem [ADR-0012](decisions/0012-scope-level1-now.md).

Chi tiết thiết kế: [design-core.md](design-core.md). Ma trận truy vết:
[traceability.md](traceability.md).

---

## 1. Yêu cầu chức năng

### FR1 — Phân đoạn văn bản
- **Phát biểu**: Hệ thống phải phân đoạn văn bản thành phần/chương/điều/khoản/điểm,
  gán ID ổn định, và phân giải các tham chiếu nội bộ.
- **Ưu tiên**: Must
- **AC**: ID là duy nhất trong văn bản; mọi tham chiếu không phân giải được đều
  được báo cáo, không bị bỏ qua.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned** — `pipeline/` hiện rỗng.

### FR2 — Glossary
- **Phát biểu**: Hệ thống phải có glossary ánh xạ thuật ngữ sang kiểu Lean và
  sang act id.
- **Ưu tiên**: Must
- **AC**: Thuật ngữ chưa có trong glossary bị chặn (không tự suy diễn) cho đến
  khi người duyệt thêm vào.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned**. Kiểu đích đã có: `Act` là id chuỗi mờ
  ([ADR-0004](decisions/0004-act-as-opaque-glossary-id.md)).

### FR3 — Dịch điều khoản thành dữ liệu Lean
- **Phát biểu**: Hệ thống phải dịch mỗi điều khoản thành **dữ liệu** Lean
  (`Norm` với cây cú pháp `Cond`), không phải mã Lean tự do, kèm ID nguồn.
- **Ưu tiên**: Must
- **AC**: Mọi `Norm` truy được về đúng một điều khoản qua `Norm.source.article`.
- **Kiểm chứng**: Review + Test
- **Trạng thái**: **Planned** (bước dịch). Lược đồ đích `Norm`/`Cond` đã
  **Implemented** — xem [design-core.md](design-core.md#2-corenormlean).

### FR4 — Sửa lỗi có giới hạn
- **Phát biểu**: Hệ thống phải thử sửa lỗi dịch tối đa N vòng, sau đó đánh dấu
  điều khoản là "not encoded".
- **Ưu tiên**: Must
- **AC**: Không điều khoản nào bị loại bỏ mà không có bản ghi lý do.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned**. Giá trị N chưa chốt (xem báo cáo).

### FR5 — Dịch ngược để đối chiếu
- **Phát biểu**: Hệ thống phải diễn đạt lại mỗi `Norm` thành tiếng Việt để
  người duyệt đối chiếu song song với văn bản gốc.
- **Ưu tiên**: Must
- **AC**: Norm chưa được duyệt không bao giờ vào tập đã phê duyệt (`Laws`).
- **Kiểm chứng**: Review
- **Trạng thái**: **Open** — LLM hay renderer tất định; ưu tiên tất định. Xem
  [ADR-0019](decisions/0019-back-translation-renderer.md).

### FR6 — Mô hình chuẩn tắc
- **Phát biểu**: Hệ thống phải biểu diễn obligation/permission/prohibition,
  điều kiện, ngoại lệ, ưu tiên tường minh, và khái niệm mở dưới dạng tham số.
- **Ưu tiên**: Must
- **AC**: Hệ thống không bao giờ tự quyết định giá trị của một khái niệm mở.
- **Kiểm chứng**: Review + Proof
- **Trạng thái**: **Implemented** — `Modality`, `Cond`, `Norm.exceptions`,
  `Norm.priority`, tham số `P`.

### FR7 — Kiểm tra xung đột ba/bốn kết quả
- **Phát biểu**: Hệ thống phải kiểm tra xung đột và trả về đúng một trong **năm**
  kết quả: `conflict` / `conditionalConflict` / `consistentOn scope` / `unknown`
  / `invalid` (khuyết điểm cấu trúc — không kiểm gì cả).
- **Ưu tiên**: Must
- **AC**: Không bao giờ phát biểu "văn bản đúng" một cách vô điều kiện; mọi
  khẳng định nhất quán đều kèm scope.
- **Kiểm chứng**: Proof
- **Trạng thái**: **Implemented** — `analyze` là **điểm vào duy nhất** (validate
  trước, rồi mới tìm; bộ kiểm nằm trong `LexProof.Internal` nên không bỏ qua
  được validator). `Result` có năm nhánh như trên, kèm các định lý
  (a)+(c) `conflict_of_witness`, (b) `not_conflict_of_consistentOn`,
  (d) `scopeOf_spec`/`analyze_scope`, (e) `conflict_all_params`/
  `conditionalConflict_split`. Mọi nhánh đều có ca kiểm thử.

### FR8 — Validator well-formedness
- **Phát biểu**: Hệ thống phải chạy validator trước khi kiểm tra xung đột, phát
  hiện: tham chiếu treo, ID trùng, chỉ số atom không hợp lệ, chu trình ưu tiên.
  Nên (Should) phát hiện thêm norm không bao giờ áp dụng được.
- **Ưu tiên**: Must (bốn mục đầu) / Should (mục cuối)
- **AC**: Có test trên văn bản đã cố tình tiêm lỗi, mỗi loại lỗi một ca.
- **Kiểm chứng**: Test
- **Trạng thái**: **Implemented** — `validate` trong `LexProof/Verify/Validate.lean`
  bắt sáu loại (chỉ số atom qua kiểm **tĩnh** `Cond.wf`, trùng id, tham chiếu
  treo đối chiếu catalog truyền vào, override tới id không tồn tại, chu trình ưu
  tiên, lẫn `docId`), mỗi finding nêu tên norm sai.
  **Phát hiện chu trình ưu tiên có chứng minh cả hai chiều**:
  `cycle_of_validate_finding` (báo ⇒ có chu trình) và `cycle_finding_of_reaches`
  (có chu trình ⇒ được báo). Thuật toán lặp tới **điểm bất động**, không phải
  một số vòng cố định — xem [traceability.md](traceability.md) mục 4.
  *Ghi chú*: mục Should (norm không bao giờ áp dụng được) **chưa làm**.
  `duplicateIds`, `danglingFindings`, `unknownOverrideFindings` chỉ ở hạng
  **Tested** (ca kiểm thử kernel), chưa có định lý.

### FR9 — Phản ví dụ phát lại được
- **Phát biểu**: Hệ thống phải xuất phản ví dụ phát lại được, kèm ID nguồn của
  cả hai norm, diễn đạt bằng tiếng Việt.
- **Ưu tiên**: Must
- **AC**: Từ phản ví dụ, người duyệt tái lập được tình huống mà không cần đọc Lean.
- **Kiểm chứng**: Demo + Review
- **Trạng thái**: **Planned**. Phần dữ liệu đã **Implemented**:
  `Counterexample` có `situation`, `params`, hai `NormId`, hai `Modality`, hai
  `SourceId`, và `deriving Repr` nên in được. Phần diễn đạt tiếng Việt chưa có.

### FR10 — Báo cáo tiếng Việt
- **Phát biểu**: Hệ thống phải sinh báo cáo tiếng Việt nêu rõ scope (đã mã hóa /
  đã duyệt / đã bỏ qua) và trích dẫn điều khoản.
- **Ưu tiên**: Must
- **AC**: Báo cáo luôn có mục scope; không có mục scope thì không phát hành.
- **Kiểm chứng**: Review
- **Trạng thái**: **Planned**. `Scope` đã có `docId`, `normIds`, `articles`,
  `situations`, `params`, `validExcluded`/`validTotal`; chưa có trường "đã
  duyệt"/"đã bỏ qua".
- **Ràng buộc cho tầng báo cáo (D33)**: `Result.invalid` **không** mang `Scope`,
  và sẽ không mang. Khi có khuyết điểm cấu trúc thì **chưa kiểm gì cả**, nên
  không có phạm vi nào để báo. Báo cáo phải hiển thị nhánh này thành
  **"không kiểm được do có khuyết điểm cấu trúc"** kèm danh sách `Finding`,
  **không** được hiển thị như một phạm vi rỗng hay một kết quả nhất quán.
- **Ràng buộc thứ hai**: khi `valid` loại bỏ điểm, báo cáo nên kèm
  `excludedPoints` (một **hàm**, không phải trường của `Scope`) để người duyệt
  xem được *điểm nào* bị loại, chứ không chỉ số lượng.

### FR11 — Audit axiom
- **Phát biểu**: Hệ thống phải audit axiom theo whitelist
  `{propext, Classical.choice, Quot.sound}`, từ chối mọi thứ khác kể cả
  `sorryAx`, và chạy trong CI.
- **Ưu tiên**: Must
- **AC**: CI đỏ khi có bất kỳ axiom ngoài whitelist hoặc bất kỳ `sorryAx`.
- **Kiểm chứng**: Test (trong CI)
- **Trạng thái**: **Implemented** — `LexProof/Cert/Audit.lean` cung cấp lệnh
  `#audit_axioms`, chạy khi `LexProof.lean` import module đó, nên **`lake build`
  trần và CI đều chạy nó**. Audit lấy danh sách khai báo **từ môi trường**
  (mọi module `LexProof.*` cộng file đang elaborate), nên không có danh sách tên
  viết tay nào để mục ruỗng; lần chạy hiện tại phủ **1166 khai báo**. Nó so
  **tập** axiom với whitelist, không khớp theo tên — điều này thiết yếu vì axiom
  do `native_decide` sinh được đặt tên theo định lý, không theo tiền tố cố định.
  Một `axiom` khai trong module của ta cũng bị từ chối.
  **Negative test cố định trong CI** (`ci/audit-negative.sh`, chạy
  `ci/audit-negative/BadAxioms.lean` — ngoài thư viện nên `lake build` không
  thấy): file dùng `sorry`, `native_decide` và một `axiom`; CI đỏ nếu audit
  **không** từ chối cả ba. Hạng của negative test là **Tested** (script +
  Lean), không phải kernel.
  *Còn thiếu*: negative test nằm ở CI chứ không ở `lake build`, vì một ca như
  thế phải làm lệnh build đỏ. Sửa cả audit **và** script thì vẫn lọt.

### FR12 — Bộ ca kiểm thử của chuyên gia
- **Phát biểu**: Hệ thống nên chạy bộ ca do chuyên gia soạn trên phần đã mã hóa
  và báo tỉ lệ đạt.
- **Ưu tiên**: Should
- **AC**: Có tỉ lệ đạt tính được, tách riêng trước và sau khi duyệt.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned** — `eval/` rỗng.

### FR13 — Phiên bản văn bản
- **Phát biểu**: Hệ thống có thể quản lý nhiều phiên bản văn bản theo ngày hiệu lực.
- **Ưu tiên**: Could
- **AC**: Chọn đúng phiên bản có hiệu lực tại một ngày cho trước.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned**. Trường đã để sẵn: `SourceId.docId`,
  `SourceId.docType`, `SourceId.effective` ([ADR-0007](decisions/0007-keep-level2-fields-in-sourceid.md)).

---

## 2. Yêu cầu phi chức năng

Nhóm theo đặc tính chất lượng **ISO/IEC 25010**.

### 2.1 Functional suitability (đúng đắn chức năng)

#### N1 — Soundness
- **Phát biểu**: Mọi khẳng định về xung đột phải được chống lưng bởi một định lý
  mà kernel Lean chấp nhận, với axiom nằm trong whitelist.
- **Ưu tiên**: Must · **Mục tiêu**: 100%
- **AC**: `#print axioms` của mọi định lý kết luận ⊆ `{propext, Classical.choice, Quot.sound}`; không `sorryAx`.
- **Kiểm chứng**: Proof
- **Trạng thái**: **Implemented**. Đo được: mọi định lý chỉ dùng `propext`,
  `Classical.choice`, `Quot.sound`. Audit nay **tự động trong `lake build`**
  (FR11), nên khẳng định này được kiểm lại ở mỗi lần build thay vì mỗi lần ai đó
  nhớ chạy tay.

#### N2 — Honest scope (phạm vi trung thực)
- **Phát biểu**: Mọi khẳng định "nhất quán" phải nêu scope của nó, và không được
  phát biểu cho toàn văn bản khi còn norm chưa mã hóa hoặc chưa duyệt.
- **Ưu tiên**: Must · **Mục tiêu**: 100%
- **AC**: `Result.consistentOn` luôn mang `Scope`; không có API nào trả về
  "nhất quán" mà không có scope.
- **Kiểm chứng**: Proof + Review
- **Trạng thái**: **Implemented** ở mức kiểu dữ liệu — `consistentOn` bắt buộc
  mang `Scope`; `scopeOf_spec` và `analyze_scope` chứng minh scope nói đúng
  những gì đã kiểm; `not_conflict_of_consistentOn` chỉ kết luận trên `ns` truyền
  vào **và chỉ trên phần `valid`**; `Scope.validExcluded`/`validTotal` nói **bao
  nhiêu** điểm bị ràng buộc toàn vẹn loại bỏ trên tổng số
  ([ADR-0021](decisions/0021-integrity-constraint-valid.md)); `Scope.docId` là
  `Option String` qua `singleDocId?`, **không** phỏng đoán từ đầu danh sách, và
  danh sách lẫn nhiều văn bản là một finding. `Scope` vẫn chưa ghi **tên** tham
  số khái niệm mở, chưa nói *điểm nào* bị `valid` loại, và chưa ghi trạng thái
  duyệt ([ADR-0018](decisions/0018-scope-lists-parameter-names.md)).

#### N3 — Fail-closed
- **Phát biểu**: Khi LLM lỗi, đầu vào dị dạng, hoặc vượt ngân sách tính toán, hệ
  thống phải trả `unknown` hoặc một finding; không được bỏ qua im lặng.
- **Ưu tiên**: Must
- **AC**: Mỗi đường lỗi có một ca test cho ra `unknown`, không ra `consistentOn`.
- **Kiểm chứng**: Test
- **Trạng thái**: **Implemented** trừ ngân sách. Đã có: `Cond.eval` trả
  `Option Bool` ([ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md));
  `validate` chặn trước khi kiểm; danh sách rỗng là finding, **không bao giờ**
  `consistentOn`; `Audit.unevaluable` đi kèm **mọi** kết quả đã quét nên một
  `conflict` không che được norm chưa đánh giá được. Ca kiểm: `Tests` ca 4, 5, 9.
  **Chưa có**: phát hiện vượt ngân sách — `UnknownReason` vẫn chỉ có
  `malformedCondition`, không có `outOfBudget` (N8).

#### N4 — Faithfulness
- **Phát biểu**: Độ khớp giữa bản mã hóa và luật phải được đo trên bộ ca chuyên
  gia, trước và sau khi duyệt.
- **Ưu tiên**: Must · **Mục tiêu**: ≥95% sau khi duyệt *(giả định, cần hiệu chỉnh)*
- **AC**: Có số đo trên bộ ca; mọi ca trượt có bản ghi nguyên nhân.
- **Kiểm chứng**: Test + Review
- **Trạng thái**: **Planned**. Faithfulness **không** chứng minh được bằng
  kernel — xem bảng G2 trong [traceability.md](traceability.md).

#### N6 — Traceability
- **Phát biểu**: Mọi kết luận phải truy được về điều khoản nguồn.
- **Ưu tiên**: Must · **Mục tiêu**: 100%
- **AC**: Mọi `Norm` có `source.article` khác rỗng; mọi phản ví dụ mang hai `SourceId`.
- **Kiểm chứng**: Review + Test
- **Trạng thái**: **Implemented** ở mức lược đồ (`SourceId.article` là trường bắt
  buộc, `Counterexample.sources` mang cả hai). Kiểm tra "khác rỗng" chưa có.

### 2.2 Performance efficiency

#### N8 — Scale
- **Phát biểu**: Chi phí liệt kê là `|S| × |P| × số cặp norm`; hệ thống phải giữ
  trong ngân sách và trả `unknown` khi vượt.
- **Ưu tiên**: Must
- **Số đo** (máy dev, `decide` trong kernel, quét toàn bộ):

  | Kích thước | Thời gian |
  |---|---|
  | 2^12 | ~1s |
  | 2^14 | ~7s |
  | 2^16 | ~50s |
  | 2^18 | **thất bại** — `(deterministic) timeout at whnf`, 200000 heartbeats; định lý khi đó mang `sorryAx` |

  *Cách đo*: bằng `(List.range N).all` làm đại diện, **không** phải bằng `check`
  thật. Số cho `check` trên văn bản thật: **chưa kiểm**.
- **Trần kế hoạch**: 2^14 toàn cục; nhóm norm theo `act`, ~2^8 mỗi nhóm.
- **AC**: Vượt ngân sách → `unknown(outOfBudget)`, không bao giờ im lặng hoặc treo.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned**. `UnknownReason` hiện **không có** `outOfBudget`;
  không có cơ chế đo hay chặn ngân sách. Khả năng nâng trần bằng
  `decide +kernel`: **chưa kiểm**.

### 2.3 Reliability

#### N7 — Reproducibility
- **Phát biểu**: Toolchain và phụ thuộc phải được ghim; model, phiên bản prompt
  và log gọi LLM phải được lưu.
- **Ưu tiên**: Must
- **AC**: Build lại cho kết quả như cũ từ một commit; mỗi `Norm` do LLM sinh ra
  truy được về một lần gọi LLM cụ thể.
- **Kiểm chứng**: Review
- **Trạng thái**: **Planned**. Đã có: `lean-toolchain` ghim `v4.35.0`, không
  phụ thuộc ngoài (`lake-manifest.json` rỗng). Chưa có: log LLM.

### 2.4 Usability (Interaction capability)

#### N10 — Usability
- **Phát biểu**: Thông báo phải đọc được mà không cần biết Lean.
- **Ưu tiên**: Must
- **AC**: 1–2 người duyệt không biết Lean hiểu đúng một phản ví dụ mẫu.
- **Kiểm chứng**: Demo + Review
- **Trạng thái**: **Planned**. Hiện `Repr` in ra cấu trúc Lean thô.

### 2.5 Maintainability

#### N5 — Evaluability
- **Phát biểu**: Hệ thống phải đo được recall (tiêm xung đột vào bản sao văn bản)
  và precision (người duyệt đánh giá).
- **Ưu tiên**: Must · **Mục tiêu**: TBD
- **AC**: *chưa định nghĩa được* — phụ thuộc mục tiêu số, xem báo cáo.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned**.

#### N9 — Maintainability
- **Phát biểu**: Mỗi văn bản một module; thêm một văn bản không được sửa `Core`.
- **Ưu tiên**: Must
- **AC**: Thêm một module `Laws/` mới không thay đổi file nào trong `Core/`.
- **Kiểm chứng**: Review
- **Trạng thái**: **Planned**. Thiết kế đã hỗ trợ (`Norm` không phụ thuộc `S`,
  `P`), nhưng `LexProof/Laws/` rỗng nên chưa được kiểm thực tế. Lưu ý: mỗi văn
  bản mới vẫn phải **viết tay** một instance `Finite` cho `S` và `P`.

#### N12 — Build integrity
- **Phát biểu**: Một lệnh `lake build` trần và CI phải build mọi module.
- **Ưu tiên**: Must
- **AC**: `lake build` thất bại nếu bất kỳ file `.lean` nào trong `LexProof/`
  không biên dịch được.
- **Kiểm chứng**: Test
- **Trạng thái**: **Implemented**. `LexProof.lean` import cả năm module
  (`Core.Finite`, `Core.Norm`, `Verify.Validate`, `Verify.Conflict`,
  `Verify.Smoke`, `Verify.Tests`), và `lake build` trần nay chạy 20 jobs, biên
  dịch mọi module.
  *Lưu ý về cách kiểm*: `touch` **không** phải phép thử hợp lệ — Lake băm nội
  dung file, không xem mtime, nên `touch` rồi build sẽ báo `Replayed`. Muốn buộc
  build lại thì xóa artifact trong `.lake/`.
  *Lưu ý phạm vi*: build xanh nghĩa là "biên dịch được", **không** nghĩa là
  "axiom sạch" — việc đó là FR11 và vẫn chưa tự động.
  *Lý do có yêu cầu này*: 4 module từng bị loại khỏi build mà không ai biết.

### 2.6 Security / Legal

#### N11 — Legal & ethical
- **Phát biểu**: Hệ thống chỉ dùng văn bản công khai; đầu ra phải được gắn nhãn
  là hỗ trợ ra quyết định, không phải tư vấn pháp lý.
- **Ưu tiên**: Must
- **AC**: Mọi báo cáo có dòng nhãn; không có dữ liệu không công khai trong `data/`.
- **Kiểm chứng**: Review
- **Trạng thái**: **Planned**.

---

## 3. Đặc tính ISO/IEC 25010 chủ động để ngoài phạm vi

| Đặc tính | Lý do |
|---|---|
| **Security** (xác thực, phân quyền, mã hóa) | Công cụ chạy cục bộ, một người dùng, dữ liệu công khai. Chỉ giữ phần *trust boundary* (ADR-0011) vì nó thuộc về tính đúng đắn, không phải bảo mật. |
| **Compatibility** (liên thông với hệ legal-tech khác) | Không có bên thứ ba tiêu thụ đầu ra trong phạm vi đồ án. |
| **Portability** (triển khai web/mobile, đa nền) | Chỉ cần chạy trên máy dev (Windows) và CI (ubuntu). Toolchain ghim là đủ. |
| **Safety** (bổ sung ở 25010:2023) | Hệ thống không điều khiển thiết bị và không tự động ra quyết định pháp lý; rủi ro được xử lý bằng N11 và bắt buộc có người duyệt. |

Các đặc tính **trong** phạm vi: Functional suitability (N1, N2, N3, N4, N6),
Performance efficiency (N8), Reliability (N7), Usability (N10),
Maintainability (N5, N9, N12).
