# LexProof — Đặc tả yêu cầu

Khuôn theo **ISO/IEC/IEEE 29148**: mỗi yêu cầu có ID duy nhất, một phát biểu
"phải" (shall), độ ưu tiên MoSCoW, tiêu chí chấp nhận (AC), phương pháp kiểm
chứng (Proof | Test | Review | Demo) và trạng thái.

**Trạng thái** chỉ nhận một trong ba giá trị:

| Trạng thái | Nghĩa |
|---|---|
| Implemented | Đã có trong code và đã được build kiểm tra |
| Planned | Đã quyết định, chưa có code |
| Open | Chưa quyết định xong |

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
- **Phát biểu**: Hệ thống phải kiểm tra xung đột và trả về đúng một trong bốn
  kết quả: `conflict` / `conditionalConflict` / `consistentOn scope` / `unknown`.
- **Ưu tiên**: Must
- **AC**: Không bao giờ phát biểu "văn bản đúng" một cách vô điều kiện; mọi
  khẳng định nhất quán đều kèm scope.
- **Kiểm chứng**: Proof
- **Trạng thái**: **Implemented** — `check`, `Result`, kèm hai định lý
  `conflict_of_witness` và `not_conflict_of_consistentOn`.
  *Ghi chú*: nhánh `conditionalConflict` chưa có định lý đặc trưng và chưa có
  test — xem [ADR-0015](decisions/0015-characterize-conflict-labels.md).

### FR8 — Validator well-formedness
- **Phát biểu**: Hệ thống phải chạy validator trước khi kiểm tra xung đột, phát
  hiện: tham chiếu treo, ID trùng, chỉ số atom không hợp lệ, chu trình ưu tiên.
  Nên (Should) phát hiện thêm norm không bao giờ áp dụng được.
- **Ưu tiên**: Must (bốn mục đầu) / Should (mục cuối)
- **AC**: Có test trên văn bản đã cố tình tiêm lỗi, mỗi loại lỗi một ca.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned**. Hiện chỉ số atom sai lộ ra muộn, lúc eval, dưới
  dạng `unknown` — xem [ADR-0017](decisions/0017-wellformedness-validator-first.md).

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
  `situations`, `params`; chưa có trường "đã duyệt"/"đã bỏ qua".

### FR11 — Audit axiom
- **Phát biểu**: Hệ thống phải audit axiom theo whitelist
  `{propext, Classical.choice, Quot.sound}`, từ chối mọi thứ khác kể cả
  `sorryAx`, và chạy trong CI.
- **Ưu tiên**: Must
- **AC**: CI đỏ khi có bất kỳ axiom ngoài whitelist hoặc bất kỳ `sorryAx`.
- **Kiểm chứng**: Test (trong CI)
- **Trạng thái**: **Planned**. `LexProof/Cert/` rỗng; audit hiện làm **thủ công**
  bằng `#print axioms`. Nghiêm trọng hơn: CI hiện không build các module mới —
  xem N12.

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
- **Trạng thái**: **Implemented** cho phần đã có (đo được: chỉ `propext` và
  `Quot.sound`). Việc tự động hóa audit là FR11/Planned.

#### N2 — Honest scope (phạm vi trung thực)
- **Phát biểu**: Mọi khẳng định "nhất quán" phải nêu scope của nó, và không được
  phát biểu cho toàn văn bản khi còn norm chưa mã hóa hoặc chưa duyệt.
- **Ưu tiên**: Must · **Mục tiêu**: 100%
- **AC**: `Result.consistentOn` luôn mang `Scope`; không có API nào trả về
  "nhất quán" mà không có scope.
- **Kiểm chứng**: Proof + Review
- **Trạng thái**: **Implemented** ở mức kiểu dữ liệu — `consistentOn` bắt buộc
  mang `Scope`, và `not_conflict_of_consistentOn` chỉ kết luận trên `ns` truyền
  vào. `Scope` chưa ghi trạng thái duyệt ([ADR-0018](decisions/0018-scope-lists-parameter-names.md)).

#### N3 — Fail-closed
- **Phát biểu**: Khi LLM lỗi, đầu vào dị dạng, hoặc vượt ngân sách tính toán, hệ
  thống phải trả `unknown` hoặc một finding; không được bỏ qua im lặng.
- **Ưu tiên**: Must
- **AC**: Mỗi đường lỗi có một ca test cho ra `unknown`, không ra `consistentOn`.
- **Kiểm chứng**: Test
- **Trạng thái**: **Planned**. Đã có: `Cond.eval` trả `Option Bool`, `none` dẫn
  tới `Result.unknown` ([ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md)).
  Chưa có: phát hiện vượt ngân sách (`UnknownReason` chỉ có `malformedCondition`).

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
- **Trạng thái**: **Open — đang bị vi phạm (đã xác nhận bằng thực nghiệm)**.
  `lakefile.toml` khai `lean_lib` không có `globs`, nên Lake chỉ build module
  gốc `LexProof`, mà `LexProof.lean` chỉ `import LexProof.Basic`. Bốn module
  `Core.Finite`, `Core.Norm`, `Verify.Conflict`, `Verify.Smoke` **không** được
  `lake build` trần biên dịch, nên CI cũng không kiểm. Sửa được bằng cách thêm
  `import` vào `LexProof.lean` hoặc thêm `globs` vào `lakefile.toml` — cả hai
  file đều ngoài phạm vi tác vụ tài liệu này.
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
