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
- **Trạng thái**: **Implemented cho một văn bản** (2026-11-25). `pipeline/segment.py` tách Luật 44/2019/QH14 thành chương/điều/khoản/điểm, tất định, kèm kiểm tra S1–S5 và test; kết quả ở `data/segmented/`. Tham chiếu nội bộ: mọi module `Laws` dùng `ClauseRef` (`Core/ClauseRef.lean`) và có định lý `refs_parse`; tham chiếu treo bị bắt qua `catalog`. **Chưa có**: văn bản thứ hai, kiểm độc lập bộ tách.

### FR2 — Glossary
- **Phát biểu**: Hệ thống phải có glossary ánh xạ thuật ngữ sang kiểu Lean và
  sang act id.
- **Ưu tiên**: Must
- **AC**: Thuật ngữ chưa có trong glossary bị chặn (không tự suy diễn) cho đến
  khi người duyệt thêm vào.
- **Kiểm chứng**: Test
- **Trạng thái**: **Implemented** (2026-11-25, ADR-0027). Bảng `data/glossary/44-2019-QH14.json`: 40 act, 90 atom; 128 mục đã duyệt qua 4 phiếu, 2 bị bác, 0 chờ. `promote.py` từ chối thuật ngữ chưa `approved`; phiếu duyệt bản dịch lập trên bảng cũ chỉ được dùng tiếp khi mọi thuật ngữ nó dùng giữ nguyên nghĩa (ADR-0029). **Ngoại lệ**: Điều 15 vẫn là bản dịch kiểu cũ, không theo bảng. Kiểu đích: `Act` là id chuỗi mờ ([ADR-0004](decisions/0004-act-as-opaque-glossary-id.md)).

### FR3 — Dịch điều khoản thành dữ liệu Lean
- **Phát biểu**: Hệ thống phải dịch mỗi điều khoản thành **dữ liệu** Lean
  (`Norm` với cây cú pháp `Cond`), không phải mã Lean tự do, kèm ID nguồn.
- **Ưu tiên**: Must
- **AC**: Mọi `Norm` truy được về đúng một điều khoản qua `Norm.source.article`.
- **Kiểm chứng**: Review + Test
- **Trạng thái**: **Tested** (bước dịch dán tay, ADR-0024: `pipeline/translate.py`, chưa chạy với LLM thật; tự động gọi API vẫn Planned). Lược đồ đích `Norm`/`Cond` đã
  **Implemented** — xem [design-core.md](design-core.md#2-corenormlean).

### FR4 — Sửa lỗi có giới hạn
- **Phát biểu**: Hệ thống phải thử sửa lỗi dịch tối đa N vòng, sau đó đánh dấu
  điều khoản là "not encoded".
- **Ưu tiên**: ~~Must~~ **Won't (bản đồ án)**, [ADR-0031](decisions/0031-scope-down-for-thesis.md)
- **AC**: Không điều khoản nào bị loại bỏ mà không có bản ghi lý do.
- **Kiểm chứng**: Test
- **Trạng thái**: **Won't (bản đồ án)**. Không có dịch tự động nên không có vòng sửa tự động; dịch lại khi người duyệt bác do người làm (Điều 32 lần 2, Điều 5 lần 3). AC vẫn đúng: khoản không mã hóa luôn có lý do (`notEncoded`, lý do bác ghi vào module).

### FR5 — Dịch ngược để đối chiếu
- **Phát biểu**: Hệ thống phải diễn đạt lại mỗi `Norm` thành tiếng Việt để
  người duyệt đối chiếu song song với văn bản gốc.
- **Ưu tiên**: Must
- **AC**: Norm chưa được duyệt không bao giờ vào tập đã phê duyệt (`Laws`).
- **Kiểm chứng**: Review
- **Trạng thái**: **Implemented ở mức tối thiểu** (2026-11-25, [ADR-0031](decisions/0031-scope-down-for-thesis.md)). Bộ in tất định `promote.words` diễn đạt mỗi norm thành lời trên phiếu duyệt, cạnh câu trích của luật (hướng «tất định» của [ADR-0019](decisions/0019-back-translation-renderer.md)). Dịch vòng bằng LLM: chưa làm, để cho nghiên cứu sau.

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
  Hệ quả đã chứng minh: **mọi** kết quả đã quét của `analyze` kèm bảo đảm không
  norm nào nằm trên chu trình `overrides` (`no_priority_cycle_of_consistentOn`
  và hai bản cho `conflict`/`conditionalConflict`), nên cấu trúc ưu tiên vòng
  tròn không thể bị báo thành nhất quán.
  **Id trùng nay cũng có định lý**: `nodup_ids_of_validate_nil` — validate sạch
  ⇒ id các norm đôi một khác nhau. Kèm theo
  `succsOf_eq_overrideIds_of_validate_nil`: khi đó bước của đồ thị ưu tiên
  **chính là** trường `overrides` của norm, nên phát biểu "không có chu trình"
  nói về đúng đồ thị mà người đọc nghĩ tới, không phải một đồ thị bị nhập nhằng
  tra cứu id.
  *Ghi chú*: mục Should (norm không bao giờ áp dụng được) **chưa làm**.
  `danglingFindings` và `unknownOverrideFindings` vẫn ở hạng **Tested** (ca kiểm
  thử kernel), chưa có định lý. Phép so cạn trên đồ thị 3 và 4 đỉnh ở hạng
  **Evaluated** (`#eval`), không phải kernel.

### FR9 — Phản ví dụ phát lại được
- **Phát biểu**: Hệ thống phải xuất phản ví dụ phát lại được, kèm ID nguồn của
  cả hai norm, diễn đạt bằng tiếng Việt.
- **Ưu tiên**: Must
- **AC**: Từ phản ví dụ, người duyệt tái lập được tình huống mà không cần đọc Lean.
- **Kiểm chứng**: Demo + Review
- **Trạng thái**: **Implemented** (2026-11-25). `counterexampleLines` (`Verify/AnalyzeReport.lean`) in mỗi cặp xung
  đột kèm id, tính chất và nguồn của hai norm, và tình huống bằng lời: tên atom, nhãn giá trị, khoản nguồn; khái niệm mở
  in riêng; «mọi atom khác: giá trị bất kỳ». Có test `decide` trong Lean. Dùng ở `edges.py draft`, `readings.py`,
  `run.py`, module do `promote.py` và `edges.py module` viết, và mục 5 của báo cáo `law44` (ví dụ thật: Điều 32 khoản 4 ×
  Điều 5 khoản 12). Tình huống là cái `analyzeP` tìm thấy đầu tiên, không phải tình huống nhỏ nhất.
### FR10 — Báo cáo tiếng Việt
- **Phát biểu**: Hệ thống phải sinh báo cáo tiếng Việt nêu rõ scope (đã mã hóa /
  đã duyệt / đã bỏ qua) và trích dẫn điều khoản.
- **Ưu tiên**: Must
- **AC**: Báo cáo luôn có mục scope; không có mục scope thì không phát hành.
- **Kiểm chứng**: Review
- **Trạng thái**: **Implemented** (2026-11-25). `pipeline/report.py --module alcohol-sale --status draft|reviewed` và `--module law44 --status draft` (module gộp 15 điều; 9 mục: kết luận, phạm vi luôn có, định lý kernel, duyệt, kiểm qua cạnh, dấu hiệu lỗi soạn thảo, điều không được chứng minh, đầu ra Lean, nguồn gốc). `reviewed` cho `law44` bị từ chối khi chưa có bộ ca (FR12). Test: `test_report.py`, `test_report_promoted.py`.
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
  viết tay nào để mục ruỗng; lần chạy hiện tại phủ **3118 khai báo**. Nó so
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

### FR14 — Dấu hiệu lỗi soạn thảo trong một văn bản
- **Phát biểu**: Trên phần đã mã hóa của một văn bản, hệ thống chỉ ra norm không bao giờ áp dụng, norm bị một norm khác
  cùng hành vi và cùng tính chất bao trùm, và ngoại lệ không bao giờ kích hoạt. Kết quả báo riêng, không phải xung đột,
  không đổi kết luận nhất quán.
- **Ưu tiên**: Should
- **AC**: Mỗi mục «sạch» có định lý kernel từ một chứng nhân; mỗi mục không có chứng nhân được báo «không biết», không bao
  giờ «sạch» và không bao giờ «là lỗi»; một chứng nhân sai làm build thất bại.
- **Kiểm chứng**: Test (`Verify/DraftingTests.lean`, `pipeline/tests/test_drafting.py`) và định lý trên `Laws/Law44Drafting.lean`
- **Trạng thái**: **Implemented** (2026-11-25, [ADR-0030](decisions/0030-drafting-defects.md)). Trên `Law44`: 73 norm sống,
  322 cặp không bao trùm, 5 ngoại lệ có kích hoạt; 1 mục «không biết» (ngoại lệ của norm 15.2).

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
- **Trạng thái**: **Partial**. Bằng chứng hiện có: phiếu duyệt từng norm của **một** người duyệt (Phong), có ghim sha256. Không đo được mục tiêu ≥95% khi chưa có người thứ hai hay bộ ca độc lập (FR12). Ghi thành giới hạn trong mọi báo cáo. Xem bảng G2 trong [traceability.md](traceability.md).

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
- **Ưu tiên**: ~~Must~~ **Should** («đo và ghi giới hạn»), [ADR-0031](decisions/0031-scope-down-for-thesis.md)
- **Số đo theo chi phí mỗi điểm** (đo bằng `analyze` thật, `decide +kernel`, Windows, một máy; chi tiết và điều kiện:
  [situation-model-experiment.md](situation-model-experiment.md)): **2,3 đến 3,5 ms mỗi điểm** của miền
  `(tham số × tình huống)` của một module (2,3 ms ở cặp 5.5 × 10.6, 7 bit; 3,5 ms ở cặp 12.3.c × 13.2, 10,6 bit),
  cộng khoảng 0,12–0,15 giây mỗi module. Thời gian tuyến tính theo số điểm trong từng cặp (số mũ ≈ 1,06 từ 1 536
  đến 6 144 điểm). Quy ra:

  | Số điểm một module | Thời gian ước tính |
  |---|---|
  | 2^12 (4 096) | 9 đến 14 giây |
  | 2^14 (16 384) | 38 đến 57 giây |
  | 2^16 (65 536) | 150 đến 230 giây |

  *Trần kế hoạch* (theo thời gian, không theo số mũ): **60 giây ≈ 17 000 đến 26 000 điểm cho một module**.
  Với 75 cặp cùng act của biến thể mặc định (Σ 3 832 điểm), mỗi cặp là một module riêng: ≈ 20–25 giây
  (≈ 38 giây nếu kèm hệ quả `strong`).
  *Giới hạn của số đo*: chỉ hai cặp, cả hai cấm × cấm; chi phí mỗi điểm đổi ×1,5 giữa hai cặp, nên là khoảng,
  không phải hằng số; không đo bộ kiểm chiếu theo cặp; `decide` thường (không `+kernel`) thất bại ở 1 536 điểm
  với "maximum recursion depth".
  *Số cũ* ("2^12 ≈ 1 s, 2^14 ≈ 7 s, 2^16 ≈ 50 s, 2^18 thất bại") đo bằng `(List.range N).all` làm **đại diện**
  (proxy), không phải bằng `check`: nó thấp hơn chi phí thật khoảng 5 đến 8 lần (2^14 ≈ 0,43 ms mỗi điểm so với
  2,3–3,5 ms). **Không dùng số cũ để lập kế hoạch.**
- **AC**: Vượt ngân sách → `unknown(outOfBudget)`, không bao giờ im lặng hoặc treo.
- **Kiểm chứng**: Test
- **Trạng thái**: **Implemented theo nghĩa đã hạ** (2026-11-25). Không có `outOfBudget`. Fail closed nhờ giới hạn nhịp của Lean: quá giới hạn thì build thất bại và không có kết quả. Số đo: module gộp `Law44` (73 norm, 78 atom) build khoảng 330 giây; `Law44Drafting` khoảng 80 giây; một module có cạnh khoảng 43 giây (ADR-0029, ADR-0030).

### 2.3 Reliability

#### N7 — Reproducibility
- **Phát biểu**: Toolchain và phụ thuộc phải được ghim; model, phiên bản prompt
  và log gọi LLM phải được lưu.
- **Ưu tiên**: Must
- **AC**: Build lại cho kết quả như cũ từ một commit; mỗi `Norm` do LLM sinh ra
  truy được về một lần gọi LLM cụ thể.
- **Kiểm chứng**: Review
- **Trạng thái**: **Partial**. Đã có: `lean-toolchain` ghim `v4.35.0`, không phụ thuộc ngoài; mọi bản dịch và prompt dán tay được lưu trong `eval/translate/` (thay cho log LLM, vì không gọi API); báo cáo ghi commit, sha256 module và đầu vào. Chưa có: một lệnh chạy lại toàn bộ và hướng dẫn cài đặt (bước đóng gói).

### 2.4 Usability (Interaction capability)

#### N10 — Usability
- **Phát biểu**: Thông báo phải đọc được mà không cần biết Lean.
- **Ưu tiên**: Must
- **AC**: 1–2 người duyệt không biết Lean hiểu đúng một phản ví dụ mẫu.
- **Kiểm chứng**: Demo + Review
- **Trạng thái**: **Partial**. Báo cáo, phiếu duyệt và kết quả đều bằng tiếng Việt, norm được diễn đạt thành lời (FR5). Người duyệt (Phong) đọc phiếu không cần biết Lean. Chưa có: thử với người thứ hai (bước đóng gói).

### 2.5 Maintainability

#### N5 — Evaluability
- **Phát biểu**: Hệ thống phải đo được recall (tiêm xung đột vào bản sao văn bản)
  và precision (người duyệt đánh giá).
- **Ưu tiên**: ~~Must~~ **Should**, [ADR-0031](decisions/0031-scope-down-for-thesis.md) · **Mục tiêu**: TBD
- **AC**: *chưa định nghĩa được* — phụ thuộc mục tiêu số, xem báo cáo.
- **Kiểm chứng**: Test
- **Trạng thái**: **Partial**. Recall đo bằng gieo lỗi trên luật thật (`eval/entailment/`, E2: 23/23 ca cùng act; E5: 3/3 ca qua cạnh; 0 báo nhầm). Precision do người đánh giá phụ thuộc FR12.

#### N9 — Maintainability
- **Phát biểu**: Mỗi văn bản một module; thêm một văn bản không được sửa `Core`.
- **Ưu tiên**: ~~Must~~ **Should**, [ADR-0031](decisions/0031-scope-down-for-thesis.md)
- **AC**: Thêm một module `Laws/` mới không thay đổi file nào trong `Core/`.
- **Kiểm chứng**: Review
- **Trạng thái**: **Implemented** (kiểm thực tế 2026-11-25): từ 2026-11-19, 8 commit thêm 17 module `Laws` mà không đổi file nào trong `Core/`.

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
- **Trạng thái**: **Partial**. Mọi báo cáo có dòng «Không phải tư vấn pháp lý»; `data/` chỉ chứa văn bản công khai (Luật 44/2019/QH14 từ Công báo). Chưa có: ghi nguồn và điều kiện sử dụng trong README (bước đóng gói).

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
