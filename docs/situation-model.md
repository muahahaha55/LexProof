# LexProof — Mô hình "tình huống là phép gán trị cho các atom có tên"

> **Cập nhật 2026-10-30 — số đo quy mô.** Các số kiểu "2^12 ≈ 1 s … 2^16 ≈ 50 s" trong tài liệu này đến từ phép đo **đại diện** (`(List.range N).all`), thấp hơn chi phí thật khoảng 5–8 lần. Chi phí đo bằng `analyze` thật là **2,3 đến 3,5 ms mỗi điểm** (N8 trong [requirements.md](requirements.md), [situation-model-experiment.md](situation-model-experiment.md)). Phần còn lại của tài liệu giữ nguyên.

> **Trạng thái**: phân tích trên giấy, **không có dòng Lean nào được chạy hay viết**
> cho tài liệu này. Mọi số dòng là ước lượng và mang nhãn **chưa kiểm**.
> Số đo về quy mô lấy từ [scaling-analysis.md](scaling-analysis.md) (mô hình
> Python, lưu ở `eval/scaling/`), số đo về chứng minh lấy từ thí nghiệm A1
> (`LexProof/Verify/Projection.lean`).
>
> Tài liệu **không trả lời** G1, G4, G7, G12 của [slice1-notes.md](slice1-notes.md).
> Chỗ nào kết quả phụ thuộc vào chúng, tôi nêu cả hai phía hoặc nói rõ là không phụ
> thuộc.

## 0. Câu hỏi và ba lựa chọn

**Câu hỏi.** Nếu một *tình huống* **là**, theo định nghĩa, một phép gán trị cho các
atom có tên (mỗi atom là Bool hoặc enum nhỏ); atom là **dữ liệu** (tên + miền giá
trị) chứ không phải hàm Lean từ `S` ra `Bool`; ràng buộc toàn vẹn (IC) là các cây
`Cond` trên cùng các atom đó; và miền hữu hạn là **tích** của các miền atom — thì
được gì, mất gì, so với giữ nguyên thiết kế hiện tại (`S` mờ, atom là hàm) rồi làm
tiếp A2–A9 của scaling-analysis?

Để so sánh công bằng tôi tách ba lựa chọn:

| Ký hiệu | Nội dung | Đụng vào mã hiện có |
|---|---|---|
| **C** | Giữ `S` mờ và atom là hàm. Làm tiếp (a) chiếu theo cặp + (b) IC là cây | Có: `Conflict.lean` (A5–A8), thêm IC |
| **V-lite** | **Thêm** một lớp "bảng atom → `Atoms`" ở file mới. API hiện tại (`Atoms S P`, `Finite`, mọi định lý) **giữ nguyên**; bảng chỉ là một cách *sinh ra* `Atoms` | Không (chỉ thêm file mới) |
| **V-full** | Thay hẳn: `Atoms` là bảng dữ liệu, `S`/`P` biến khỏi chữ ký, mọi định lý phát biểu trên phép gán | Có: gần như mọi file `.lean` |

Hai biến thể con của V về cách biểu diễn enum (ảnh hưởng đến hầu hết con số bên dưới):

- **V-enum**: thêm vào `Cond` một nút "atom `i` nhận giá trị `v`". Enum là atom hạng
  nhất; "đúng một trong k" là hệ quả của cấu trúc.
- **V-Bool**: chỉ giữ atom Bool, enum biểu diễn bằng k Bool + một IC "đúng một".
  Không đổi `Cond`, nhưng tốn bit (S02 tốn 3 bit thay vì 1,58; S07 tốn 4 thay vì 2; đo ở
  scaling-analysis 1.7 cho trường hợp ngưỡng độ cồn là Bool rời: thêm 3–4 cặp báo động
  giả nếu bỏ IC).

Từ đây "V" nói chung cho V-lite và V-full, và nói rõ khi chúng khác nhau.

## 1. V đơn giản hóa điều gì

### 1.1 Nâng phản ví dụ đã chiếu thành điểm thật (realisability)

*Phản ví dụ đã chiếu* là một phép gán **một phần** `v` trên tập atom `F` mà hai norm
của cặp đọc, làm cả hai cùng áp dụng. Nó mới là **ứng viên**
(xem phần "(S) không cho ta điều gì" trong `Projection.lean`). Để thành xung đột
thật cần một điểm đầy đủ `(π, s)` **thỏa `valid`** mà `Conflict` đúng tại đó.

| | C (S mờ) | V (bảng atom) |
|---|---|---|
| Dựng `s` từ giá trị atom | Không có cách tổng quát. Chỉ làm được nếu `S` là tích các trường độc lập — **một quy ước** mỗi module `Laws` tự giữ, kernel không kiểm | Là **định lý chứng minh một lần**: mọi phép gán hợp lệ trên các atom là một tình huống. Không còn quy ước |
| Phần còn lại sau khi có `v` | Tìm hoàn tất trên hộp đen `valid`: trường hợp xấu quét `S × P` (scaling-analysis 2.4, mục 3) | **Thỏa mãn được các IC** (SAT trên cây `Cond`) |
| Trên những atom nào | Không xác định được — không biết `valid` đọc atom nào | Chỉ trên **thành phần liên thông của IC** chạm vào `F`: các IC có atom chung với `F`, rồi các IC có atom chung với những IC đó, v.v. Trừ đi chính `F`. Atom ngoài thành phần này **tự do** (đặt giá trị mặc định) |
| Kernel kiểm gì | Một điểm: `valid` đúng và `Conflict` đúng | Giống hệt (không đổi) — phần tìm hoàn tất vẫn **không tin cậy**, hợp với ADR-0020 |

**Con số** (mô hình Python, ma trận tám biến thể, cột "khi giữ IC"): với bốn IC của
tôi (IC1–IC4), khi tính cả thành phần IC thì ở G1 a **mọi** cặp vẫn ≤ 12 bit; ở G1 b
có 3 (mịn) đến 6 (thô) cặp rơi vào khoảng 12–14 bit; không cặp nào vượt 14 bit.
Nghĩa là bước hoàn tất chỉ duyệt thêm vài bit cho mỗi cặp. ICX (giả định của tôi)
đọc S23–S26, bốn fact phương tiện quảng cáo.

**Hai điều V *không* làm được ở đây**, để khỏi hiểu lầm:

1. Chiều **loại ứng viên** bằng IC ("ứng viên này không có hoàn tất hợp lệ nên không
   phải xung đột") cần một định lý riêng: nếu không có hoàn tất nào trong thành phần
   thì không có điểm hợp lệ nào khớp `v` trên `F`. Định lý này **dùng lại**
   `Cond.evalE_congr` (đã chứng minh): IC là `Cond` nên tính cục bộ có sẵn. Với
   `valid` mờ không có định lý tương đương (scaling-analysis 2.4, mục 2). Nhưng nó
   vẫn là *việc phải chứng minh* (mảnh "A5/A6" trong C, "T4/T5" bên dưới).
2. V **không** làm SAT rẻ hơn về bản chất; nó chỉ làm cho SAT *có chỗ nói được* (có
   atom, có miền). Ở lát cắt này các thành phần nhỏ nên không thành vấn đề.

### 1.2 `card S`, `Scope` và D23

| Mục hiện tại | Vấn đề (scaling-analysis 1.6) | Với V |
|---|---|---|
| `Finite.card S` (= độ dài `enum`) | Cần dựng danh sách `enum`; S chung có 2^33,6 điểm — không dựng được | **Tích các kích thước miền**, tính bằng nhân; chứng minh `card = tích` một lần, không liệt kê. Làm được cho S chung hay cho từng module (G12 cả hai phía) |
| `Scope.situations`, `params` | Dùng `Finite.card` | Là cùng phép nhân. **Số không đổi** so với đếm tay trong slice1-notes B3 (2^33,6 × 2^13) |
| `Scope.validTotal` | Độ dài `validPoints` (toàn tích) | Tích hai số trên |
| `Scope.validExcluded`, `validExcludedOf` | Quét toàn miền để đếm | **Vẫn là vấn đề.** V cho phép đếm *không liệt kê* bằng cách tách IC thành thành phần liên thông và nhân số mô hình từng thành phần (mảnh B5 của scaling-analysis, 200–350 dòng thô, tùy chọn) — chỉ khả thi vì IC là cây có danh sách atom. Hoặc thay con số bằng **danh sách IC** (người đọc thấy ràng buộc thay vì một số) — đó là đổi nội dung `Scope`, một quyết định của bạn |
| `excludedPoints` (liệt kê điểm bị loại, có `cap`) | Quét toàn miền | Đổi ý nghĩa: "IC nào bị vi phạm bởi điểm nào" thay vì "những điểm nào" — lấy mẫu theo từng IC |
| `coApplyPoint?` (D23, dùng trong `resolutionOf?`) | Quét toàn miền để tìm điểm hợp lệ mà cả hai norm áp dụng | Viết lại thành: tìm phép gán trên `F` (chiếu), rồi hoàn tất theo 1.1. Giữ được hình dạng của `resolutionOf?_spec` / `resolution_has_witness` (vẫn là "tồn tại điểm hợp lệ mà cả hai áp dụng") |

**Giới hạn thật thà**: V *không* loại bỏ nhu cầu viết lại `scopeOf`, `coApplyPoint?`,
`Audit.resolutions` (đó là mảnh A7 của C, 120–200 dòng thô). V chỉ làm cho việc viết
lại đó có nền: con số `card` và việc dựng điểm là có thể chứng minh chứ không phải
quy ước.

### 1.3 Trust base

| Mục | Hiện tại (`traceability.md` §3) | Với V |
|---|---|---|
| Hàm đọc atom `S → Bool` (hàm Lean tùy ý) | Được tin: "atom 5 đọc đúng trường nào" — kernel không kiểm | **Rời khỏi trust base.** Bộ đọc là phép tra bảng sinh ra từ dữ liệu; ý nghĩa còn lại là **nhãn** (tên atom, tên giá trị) |
| `Atoms.valid` (hàm Bool tùy ý) | Được tin; "quá mạnh che xung đột thật" (ADR-0021) | **Vẫn trong trust base, nhưng thu hẹp**: một danh sách cây `Cond` in được, có kiểm chỉ số/miền. Quá mạnh vẫn che xung đột — chỉ khác là nhìn thấy, và báo cáo có thể nói IC nào loại ứng viên nào |
| "`S` là tích các trường độc lập" | Quy ước ngầm (cần cho A5) | **Định lý** (miền = tích theo định nghĩa) |
| `Finite S` viết tay cho từng `Laws` | `complete` được chứng minh nên **không** trong trust base, nhưng tốn công (N9) | Instance sinh một lần cho mọi bảng |
| Đáp ứng nghĩa của **nhãn** | Tên atom cũng chỉ là chuỗi | **Vào trust base theo nghĩa review**: nhãn và biên dải (5,5 / 15, 18 tuổi, 18–21 giờ) là *toàn bộ* ý nghĩa của atom. Hiện tại biên dải còn nằm trong mã bộ đọc, có thể đọc; với V chỉ còn là chuỗi + chỉ số |
| Ngữ nghĩa nút "atom = giá trị" (chỉ V-enum) | — | Vào cạnh `Cond.eval` trong bảng trust base |
| Cách `Atoms` được **nạp** | Là mã Lean được biên dịch | Nếu bảng là một `def` Lean do pipeline *sinh ra* thì giữ nguyên (kernel thấy được). Nếu là JSON đọc lúc chạy thì cần một bộ phân tích cú pháp — **bộ đó vào trust base**. Tôi khuyến nghị bảng là mã sinh ra, nhưng đó là quyết định chưa chốt |

Tóm lại: **bề mặt tin cậy đổi hình dạng hơn là nhỏ đi**. Mã tùy ý (bộ đọc, `valid`)
nhường chỗ cho dữ liệu in được (bảng, IC). Điều đó có lợi cho người duyệt, nhưng
cái cần duyệt (biên dải, tính đủ của IC) **không giảm**.

### 1.4 In ra và dịch ngược (FR5, ADR-0019)

Lợi ích có thật nhưng **nhỏ hơn tôi tưởng lúc đầu**, vì `Atoms.sit` hiện đã mang
tên (một cặp tên–hàm), nên một renderer cho `Cond` đã có thể in tên atom.

| | Hiện tại | V |
|---|---|---|
| Tên atom trong `Cond` | Có (qua `Atoms.sit`/`param`) | Có |
| Giá trị của enum | Không có nhãn: mỗi dải là một bộ đọc Bool riêng | **Có nhãn giá trị** ("dưới 5,5", "từ 15 trở lên"); renderer viết "dải độ cồn là từ 15 trở lên" thay vì "S02a" |
| Phản ví dụ | `Counterexample S P` in được nếu `S` có `Repr` (tên trường Lean, không phải nhãn tiếng Việt) | In theo bảng: danh sách (nhãn atom = nhãn giá trị), cả phản ví dụ **một phần** đã chiếu |
| Danh sách ràng buộc | Không in được (`valid` là hàm) | In được từng IC — cần (b) dù chọn C hay V |
| Renderer tất định viết trong Lean (phương án A của ADR-0019) | Khả thi nhưng lần lượt cho từng kiểu `S` | Một renderer cho mọi bảng |

V không giải quyết điều ADR-0019 coi là rủi ro chính (lỗi tương quan giữa dịch xuôi
và dịch ngược); chỉ làm renderer tất định dễ viết hơn.

### 1.5 Việc soạn một module `Laws`

Hiện tại mỗi văn bản cần: một `structure S`, một `structure P`, hai instance
`Finite` (viết tay, `complete` chứng minh bằng `cases … <;> decide`, ADR-0009,
`Smoke.lean`), một bảng atom đọc hàm. Với 32 fact và 13 tham số của lát cắt này
(slice1-notes B1, B2) đó là hai structure lớn và một instance tích lồng nhau. Với V
người/pipeline chỉ phải sinh **bảng** (S01–S32, P01–P13: đúng các bảng B1/B2 đã có
trong slice1-notes, gồm tên, kiểu, giá trị) và danh sách IC. Đây là lợi ích thực tế
nhất của V ngoài chứng minh — nhưng nó là lợi ích về **công sức soạn và về ranh giới
pipeline**, không phải về tính đúng.

## 2. V phá vỡ điều gì

Quy ước ở đây: **thô** = ước lượng tôi sẽ đưa trước thí nghiệm A1; **×2,5** = thô nhân
hệ số hiệu chỉnh từ A1. Mọi con số **chưa kiểm**.

**Về hệ số hiệu chỉnh — cần nói rõ giới hạn.** A1 ước lượng 100–120 dòng và
`Projection.lean` cần khoảng 270 dòng chứng minh (419 dòng cả file, khoảng 367 dòng
không tính dòng trống/chú thích), nên ×2,5. Nhưng file đó **không chỉ chứa A1**: nó
còn chứa A2 (phép gán, `evalE`), A3 (liệt kê đầy đủ) và phần lõi của A4 (bộ kiểm
theo cặp và định lý (S)). Cộng ước lượng thô A1–A4 được 330–460, và 270/395 ≈ **0,7**.
Hai cách quy kết cho hệ số khác nhau 3,5 lần. Tôi dùng ×2,5 làm cận **bi quan** theo
đúng yêu cầu và ghi cận lạc quan ×0,7 ở mục 2.4. Chỉ có **một** điểm dữ liệu,
và nó lẫn; đừng coi hệ số này là đã hiệu chỉnh.

### 2.1 Định nghĩa và định lý Lean phải đổi (V-full)

Số lần xuất hiện lấy bằng `grep` trên mã hiện tại (không đếm lỗi suy luận):
`Atoms` 47 lần ở `Conflict.lean`, 11 ở `Norm.lean`, 11 ở `Validate.lean`;
`Finite` 56 lần ở `Conflict.lean`; `valid` 50 lần ở `Conflict.lean`.

| File | Mục phải đổi | Thô | ×2,5 |
|---|---|---|---|
| `Core/Norm.lean` (300 dòng) | `Atoms` (bỏ `sit`/`param` hàm và `valid`; thêm bảng + danh sách IC); `Cond` (V-enum: thêm nút giá trị); `Cond.eval`, `evalAny`, `paramIdxs`, `wf`; `eval_isSome_of_wf`, `evalAny_isSome_of_wf`; `Norm.applies`, `Norm.wf`, `applies_isSome_of_wf`; thêm kiểm "giá trị nằm trong miền" | 80–140 | 200–350 |
| `Core/Finite.lean` (43) | Giữ nguyên các instance. Thêm instance cho phép gán ở **file mới** | 0 (+80–140 ở dòng sau) | — |
| File mới: bảng, phép gán, `Finite`, `card = tích`, bộ đọc, nâng phép gán một phần, IC → `valid` | T1–T5 bên dưới | 230–410 | 575–1 025 |
| `Verify/Validate.lean` (612) | Chữ ký `Atoms S P` → `Atoms` (11 chỗ); `unevaluableIds`, `malformedFindings`; hạng mục phát hiện mới (giá trị ngoài miền, IC sai chỉ số, tên atom trùng); `wf_of_validate_nil` và các định lý đi qua `Atoms` | 40–90 | 100–225 |
| `Verify/Conflict.lean` (780) | Phần **chung với C** (viết lại `cands`, `mem_cands`, `mem_of_mem_cands`, `validPoints`, `validExcludedOf`, `excludedPoints`, `scopeOf`, `coApplyPoint?`, `resolutionOf?`, `check`, `Counterexample`/`Scope`/`Audit`/`Result`, và 13 định lý: `witness_spec`, `conflict_label_spec`, `conditionalConflict_label_spec`, `conflict_of_witness`, `not_conflict_of_consistentOn`, `scopeOf_spec`, `analyze_scope`, `check_scope`, `conflict_all_params`, `conditionalConflict_split`, `resolutionOf?_spec`, `resolution_has_witness`, `applies_isSome_of_validate_nil`) đã nằm trong A5–A8 của C. **Phần thêm riêng của V-full**: bỏ tham số kiểu `S`, `P` khỏi mọi chữ ký và phát biểu | 100–200 (thêm) | 250–500 |
| `Verify/Smoke.lean` (139) | `Sit`, `Params`, hai instance `Finite`, `atoms` → bảng; các định lý `smoke_*` giữ phát biểu, đổi chứng minh | 40–80 | 100–200 |
| `Verify/Tests.lean` (406) | `atomsRestricted` (`valid := fun _ s => !s.overdue`) → một IC; các định lý đụng `Sit`/`Params`/`atoms` (`valid_excludes_the_conflict`, `restriction_is_counted`, `no_restriction_counted`, `conditional_conflict_*`, `smoke_pair_always_evaluates`, …). Các thử nghiệm đồ thị chu trình không phụ thuộc `Atoms` | 40–100 | 100–250 |
| `Verify/Projection.lean` (419) | `Atoms.sitVal`/`parVal` thành tra bảng; `evalE_congr` và họ hàng giữ nguyên (chúng đã trừu tượng hóa môi trường); (S) nhẹ đi vì không cần `Norm.wf`-trong-khoảng riêng | 60–120 | 150–300 |
| `Cert/Audit.lean` | Chỉ thêm `import` cho file mới (bắt buộc vì `ci/audit-coverage.sh`) | ~3 | — |

**Tổng V-full** (chưa kiểm): thô **≈ 590–1 140** dòng, ×2,5 **≈ 1 475–2 850**. Đây là
phần *cộng thêm* trên A5–A8 của C, không phải thay thế chúng (xem 2.4).

Lưu ý cho lựa chọn **V-Bool**: tiết kiệm được dòng thêm nút `Cond` (khoảng 60–100
dòng thô, vì thêm một ca vào mỗi chứng minh quy nạp trên `Cond`: `eval_isSome_of_wf`,
`evalE_congr`, `sitIdxs_lt_of_wf`, …) nhưng phải thêm IC "đúng một" cho mọi nhóm
enum và chịu thêm bit.

### 2.2 Định lý đang có và được/không được giữ

- **Giữ nguyên nếu chọn V-lite**: tất cả. `check`, `analyze`, `Result`, `Scope`,
  `Atoms S P`, 13 định lý trên, các định lý của validator (`cycle_of_validate_finding`,
  `cycle_finding_of_reaches`, `no_priority_cycle_of_*`, `nodup_ids_of_validate_nil`,
  `succsOf_eq_overrideIds_of_validate_nil`), (L) và (S) của `Projection.lean`.
- **Đổi phát biểu (V-full)**: mọi định lý trên đều có `{A : Atoms S P}` hoặc
  `[Finite S] [Finite P]` trong chữ ký; sau V-full chúng nói về phép gán hợp lệ chứ
  không về `s : S`. Nội dung không đổi, phát biểu và chứng minh phải sửa.
- **Mất (V-full)**: không định lý nào bị bỏ, nhưng các định lý (b) và (d) bị
  **viết lại** cùng với A4–A7 dù chọn C hay V; V không thêm, không bớt phần này.

### 2.3 Tài liệu phải đổi

| Trang | Mục | Đổi gì |
|---|---|---|
| `docs/design-core.md` | §2.2 (`Atoms`, `valid`), §3 (validator), §4 (Conflict/Scope/Result), §5 (Smoke/Tests), §7 (số khai báo audit), §9 (Projection) | Viết lại theo mã; **thô 150–300 dòng văn bản** (chưa kiểm) |
| `docs/traceability.md` | Bảng trust base (hàng `Atoms.valid`, thêm/bớt hàng bộ đọc và nhãn); bảng G1.x (tên định lý đổi); số khai báo audit | 40–80 dòng văn bản (chưa kiểm) |
| `docs/architecture.md` | Tầng `Laws`: một module `Laws` là bảng + IC + norm, không còn `structure S`; ranh giới tin cậy với pipeline (bảng do LLM sinh phải được duyệt, như norm) | 20–60 |
| `docs/requirements.md` | FR5 (dịch ngược), FR6 (khái niệm mở là atom loại tham số), N8 (ngân sách), N9 (không còn instance viết tay) | 10–30 |
| `docs/conventions.md` | Checklist duyệt `valid` → duyệt **bảng** và **IC**; cách viết module `Laws` | 20–40 |
| `docs/scaling-analysis.md` | Phần 2.1 (bảng A1–A9) và 2.4 (nếu `valid` mờ) lỗi thời một phần; 4.2 thí nghiệm 1 đã làm | 20–50 |
| `docs/slice1-notes.md` | Mục B1/B2 trùng khớp với bảng atom nên **không đổi**; mục B3 (cỡ miền) đổi cách tính `card` | 5–15 |
| ADR | **0006** (S do người gọi cung cấp dưới dạng structure → bị thay thế một phần); **0009** (nhược điểm "phải viết tay instance" biến mất; nội dung `Finite` giữ nguyên); **0003** (P là Bool: V ép "một khái niệm mở một atom" bằng dữ liệu); **0021** (`valid` hàm → IC cây; "đo bao nhiêu điểm bị loại" đổi); **0018**, **0020**; cần **ADR mới** cho mô hình V | mỗi cái 10–40 dòng |

### 2.4 So sánh tổng chi phí

Cột "C" lấy phần còn lại của A-series. Phần A1–A4 đã nằm trong `Projection.lean`.

| | Mảnh | Thô | ×2,5 |
|---|---|---|---|
| **C** | A5 nâng nhân chứng 70–100 · A6 20–50 · A7 120–200 · A8 120–180 · A9 50–80 · B1–B4 (IC cây) 90–170 | **470–780** | 1 175–1 950 |
| **V-lite** (chỉ thêm) | T1 bảng + miền 30–50 · T2 bộ đọc 40–70 · T3 `Finite` + `card = tích` 80–140 · T4 nâng phép gán một phần 50–90 · T5 IC → `valid` 30–60 · T6 Smoke theo bảng + so sánh `analyze` 40–80 | **270–490** | 675–1 225 |
| **V đầy đủ để dùng được** = V-lite + A6–A9 trên bảng + nút enum | 270–490 + (20–50 + 120–200 + 120–180 + 50–80) + 60–100 | **≈ 640–1 100** | 1 600–2 750 |
| **V-full** (thay hẳn, kể cả chỉnh sửa chữ ký) | A6–A9 (310–510) + toàn bộ bảng 2.1 (590–1 140; đã gồm T1–T5 và nút enum) | **≈ 900–1 650** | 2 250–4 125 |

Nếu thay ×2,5 bằng ×0,7 (cận lạc quan): C ≈ 330–550, V đầy đủ ≈ 450–770.

**Kết luận về chi phí**: V tốn **nhiều dòng hơn C** (khoảng +35–40% ở cùng hệ số), và
V-full tốn nhiều hơn nhiều. Chênh lệch này nằm trong biên sai số của chính ước lượng
(hệ số 0,7 so với 2,5). Cho nên dòng mã **không** là lý do chọn V; lý do chọn V nếu có
phải là các mục 1.1, 1.3, 1.5.

## 3. V không diễn đạt được gì mà thiết kế hiện tại làm được

Thiết kế hiện tại cho phép `S` là *bất kỳ* kiểu Lean hữu hạn nào, và bộ đọc/`valid`
là *bất kỳ* hàm Lean nào. Ví dụ từ các điều đã đọc:

| Hiện tượng | Ví dụ trong lát cắt | Hiện tại | V |
|---|---|---|---|
| **Ngưỡng số so với hằng** | độ cồn ≥ 15 (5.7, 5.9), từ 5,5 đến dưới 15 (13), dưới 5,5 (12.t); tuổi < 18 (5.2, 5.3, 5.4, 12.2.b, 10.3, 19.3) | Có thể là một trường số có biên (ví dụ độ cồn 0–40 bước 0,5) và các bộ đọc "≥ 5,5", "≥ 15": **không thể** chia dải sai vì mọi bộ đọc cùng đọc một số | Phải **chia dải tay** thành enum (S02: 3 dải) hoặc Bool. Lát cắt này mỗi đại lượng chỉ có hằng cố định, nên **không mất gì thật**; nhưng nếu thêm ngưỡng mới (ví dụ ở Điều 11 "dưới 15 độ" hay Điều 36 chuyển tiếp) phải chia lại dải và viết lại mọi điều kiện đọc S02 |
| **Biên dải đúng/sai** | "từ 15 độ trở lên" (≥) so với "dưới 5,5" (<) | Nằm trong mã bộ đọc, đọc được và kiểm được bằng toán | Chỉ là **nhãn** của giá trị enum; không có gì ngăn gắn nhãn sai biên |
| **Quan hệ giữa hai đại lượng số** | "tuổi người uống" và "tuổi người nhận" cùng một người? (5.2 so với 5.3) | Có thể khai hai trường cùng kiểu và `valid` ràng buộc `==` | Chỉ qua IC mệnh đề giữa hai atom Bool; **không có so sánh số**. Cần một nút `Cond` mới nếu muốn |
| **Giờ trong ngày** | "khung 18–21 giờ" (12.3.c, S30), "giờ làm việc/học tập" (5.5, S07), "ngay trước/sau chương trình" (S29) | Một trường giờ 0–23 với các bộ đọc cho từng khung; quan hệ giữa các khung (một giờ nằm trong cả hai khung) tự nhiên có | Mỗi khung là một atom riêng hoặc một enum dải; quan hệ giữa các khung **không tự có**, chỉ có nếu người mã hóa viết IC. Trong luật này "giờ làm việc" không có biên cố định, nên **không mất gì thật** |
| **Đếm / số lượng** | không có trong lát cắt (ví dụ "nhiều hơn k" ở luật khác) | `valid` đếm được | Ràng buộc đếm trên n atom trong cây `Cond` có kích thước **mũ** (hoặc cần nút mới) |
| **Atom suy diễn** | "chưa đủ 18 tuổi" suy từ tuổi; "rượu có độ cồn ≥ 15" suy từ loại đồ uống và độ cồn | Bộ đọc là hàm của nhiều trường | Phải **khai báo như atom** và thêm IC "tương đương" nối với atom gốc, hoặc gộp thành một enum |
| **Thời gian và chủ thể phân cấp** | thời hạn, ngày hiệu lực (Điều 36), "người điều khiển phương tiện" | Hoãn (ADR-0006), nhưng *có thể* mã hóa bằng trường số có biên | Giống nhau: enum hoặc Bool, không có suy luận |
| **Kiểu có sẵn** | tái dùng `Sit`/`Params` của Smoke, `deriving Repr, DecidableEq` | Có | Không có |

**Cái V thật sự mất**: (1) **tính toán tùy ý** trong bộ đọc và `valid`;
(2) **số có miền lớn** biểu diễn gọn (V muốn miền nhỏ; một trường 81 giá trị là một
atom 81 giá trị, và so sánh "≥" thành tuyển 40 nút nếu không có nút thứ tự);
(3) **tái dùng kiểu Lean**. Nếu chọn thêm nút thứ tự "atom ≥ k" cho atom có thứ tự,
(1)–(2) giảm nhiều với chi phí một nút `Cond` nữa (cùng loại sửa như nút enum:
khoảng +60–100 dòng thô cho mỗi nút, **chưa kiểm**).

**Cái V *không* mất trong lát cắt này**: mọi ngưỡng ở Điều 5, 10, 12, 13, 19 là so
sánh một đại lượng với một hằng, đã được chia dải trong từ vựng đề xuất (S02, S07 là
enum; các ngưỡng tuổi và giờ là Bool). Nói cách khác: *từ vựng slice1-notes B1 đã
chính là bảng atom*.

Hai điều **mà cả hai thiết kế đều không làm được**: miền vô hạn/không chặn (số tiền,
thời hạn tùy ý) và suy luận giữa hai văn bản (Level 2).

## 4. Bước đầu nhỏ nhất (giữ `lake build` xanh và các định lý đã chứng minh)

**Bước V0 — chỉ thêm, không sửa gì có sẵn.** Một file Lean mới, cùng một dòng
`import` trong `LexProof.lean` và một dòng `import` trong `Cert/Audit.lean` (bắt
buộc bởi `ci/audit-coverage.sh`). Nội dung (nói bằng lời, không phải mã):

1. Bảng atom: danh sách (tên, miền) với miền Bool hoặc enum có nhãn; một phép gán là
   danh sách giá trị, hợp lệ khi đúng độ dài và mỗi giá trị nằm trong miền.
2. Từ bảng sinh ra một giá trị `Atoms` có cùng chữ ký hiện tại, với kiểu tình huống
   là phép gán hợp lệ. Bộ đọc là tra bảng. `valid` là "mọi IC đúng", với IC là
   danh sách `Cond` (dùng lại `Cond` hiện có, **chưa** thêm nút enum: dùng V-Bool và
   một IC "đúng một" để bước này không sửa `Core/Norm.lean`).
3. Các chứng minh T3–T5: miền là *đầy đủ* (instance `Finite`), kích thước **bằng tích**
   mà không liệt kê, mọi phép gán một phần trên danh sách chỉ số mở rộng được thành
   một phép gán hợp lệ khớp (bổ đề nâng), và `valid` đúng khi mọi IC đúng.
4. T6: dựng lại ví dụ Smoke (`Sit`, `Params`) bằng bảng và chứng minh bằng `decide`
   rằng `analyze` cho **cùng kết quả** (cùng `Result`) với bản viết tay — một kiểm
   tra vi sai không chạm vào Smoke hiện có.

**Quy tắc dừng** (đặt trước khi làm):

- Hết thời hạn một phiên làm việc, **hoặc** vượt khoảng **400 dòng** (≈ ×2,5 thô
  của 160, cận bi quan cho T3–T5) mà bổ đề `card = tích` hoặc bổ đề nâng chưa
  chứng minh xong → **hoàn nguyên** file và hai dòng `import`, build vẫn xanh, báo
  cáo cái gì chặn.
- Nếu T6 đòi sửa *bất kỳ* định nghĩa hay định lý có sẵn → dừng và báo (V-lite mất
  tính "chỉ thêm", nghĩa là chọn V-full ngầm).
- Không `sorry`, `native_decide`, `bv_decide`, axiom mới; kiểm bằng `#print axioms`
  và audit tự động (số khai báo phải tăng).

## 5. Khuyến nghị

**Khuyến nghị**: dùng **V-lite làm nền cho phép chiếu theo cặp**, theo đúng thứ tự
V0 → thí nghiệm chi phí (bên dưới) → quyết định có thay hẳn không. **Không** làm
A5 trên `S` mờ như đã phác thảo.

**Lý do chính**: A5 (nâng nhân chứng) và A7 (`Scope`, D23) là hai mảnh tôi tin ít
nhất trong C, và cả hai đều bị chặn bởi cùng một thứ: không dựng được điểm từ giá
trị atom và không đếm được miền nếu không có cấu trúc tích. Trong C cấu trúc tích là
một **quy ước** mỗi module `Laws` tự giữ; trong V nó là **định lý chứng minh một
lần**. Phần còn lại (trust base đổi hình dạng, FR5 nhẹ hơn, soạn `Laws` rẻ hơn) là
lợi ích phụ.

**Vì sao không chọn V-full ngay**: tốn nhiều dòng nhất (mục 2.4), đụng gần như mọi
file, phụ thuộc vào một điều chưa đo (rủi ro 1 bên dưới), và không có lợi ích nào mà
V-lite chưa cho được trước khi phải chọn.

**Độ tin cậy** (cảm nhận chủ quan, không phải xác suất hiệu chỉnh):

- ~**70%** rằng V0 (T1–T6) làm được trong cận 400 dòng và không phải sửa file có sẵn.
- ~**60%** rằng V-lite là nền đúng (so với C) *nếu* thí nghiệm chi phí đạt.
- ~**35%** rằng ước lượng dòng ở mục 2.4 đúng trong vòng ×1,5 (chỉ có một điểm dữ liệu,
  và nó lẫn — xem mục 2).
- ~**30%** rằng V-full là đích cuối nên chọn; quyết định đó nên chờ kết quả V0.

**Thí nghiệm nhỏ nhất xác nhận hoặc bác bỏ** (làm sau V0, dùng chính file V0):

1. Mã hóa cặp lớn nhất — **12.3.c × 13.2** (10,58 bit, 1 536 điểm) — hai lần: một lần
   như hiện tại (structure + bộ đọc là hàm) và một lần bằng bảng của V0. Đo thời gian
   `decide` kiểm xung đột trên cả miền của cặp, trong kernel, với cùng vị từ.
   **Dự đoán** (chưa kiểm): bản bảng chậm hơn 3–10 lần vì mỗi lần đọc atom là tra
   danh sách thay vì chiếu trường. **Bác bỏ** V-lite nếu chậm hơn khoảng 10–20 lần:
   khi đó tổng ngân sách ở scaling-analysis (3,8 nghìn đến 54 nghìn điểm) nhân hệ số đó
   sẽ chạm trần đã đo (2^16 ≈ 50 giây cho vị từ rẻ).
2. Đã nằm trong V0: bổ đề `card = tích` và bổ đề nâng. **Bác bỏ** nếu vượt cận dòng.

Hai phép thử chỉ cần file thử bỏ đi ngoài thư viện (như đã làm với negative test).

## 6. Ba rủi ro lớn nhất

1. **Chi phí kernel của bảng tra (chưa đo).** Bộ đọc hiện tại là chiếu trường O(1);
   bảng tra là duyệt danh sách. Nếu hệ số lớn, V mất đúng thứ mà phép chiếu theo cặp
   mua được (ngân sách). Chỉ có thí nghiệm 1 trả lời được.
2. **Phạm vi và sai số ước lượng.** V đầy đủ ≈ 640–1 100 dòng thô (1 600–2 750 ở ×2,5),
   V-full thêm một lượt viết lại chữ ký ở mọi file; hệ số hiệu chỉnh từ A1 lẫn (0,7
   đến 2,5). Có nguy cơ trượt dài và để repo ở trạng thái nửa chừng. V-lite hạn chế
   bằng cách chỉ thêm file.
3. **Mất khả năng diễn đạt và dời niềm tin sang nhãn.** Ngưỡng số thành dải do người
   chia; biên (≥ hay >) và tính đủ của IC chỉ còn là chữ trên bảng, kernel không kiểm.
   Thêm ngưỡng mới ở điều khác nghĩa là chia lại dải. Kernel vẫn đúng trong khi bảng
   có thể sai.

## 7. Điều tôi không xác minh được

- **Không chạy hay viết Lean** cho V. Mọi con số dòng, mọi dự đoán về thời gian kernel
  và mọi khẳng định "chứng minh được gọn" là suy đoán từ cấu trúc mã hiện tại.
- Hệ số hiệu chỉnh ×2,5 / ×0,7: **một điểm dữ liệu**, lẫn nhiều mảnh (xem mục 2).
- Cách biểu diễn phép gán hợp lệ trong Lean **không Mathlib** (danh sách kèm vị từ
  "hợp lệ" hay một kiểu con) ảnh hưởng đến độ dễ của T3: tôi **chưa thử** cả hai.
- Tôi **chưa đọc từng dòng** của `Conflict.lean`; danh sách định lý phải đổi lấy từ
  cấu trúc file và `grep`, có thể thiếu hoặc thừa.
- Số bit của IC và thành phần IC lấy từ mô hình Python với bốn IC **do tôi đề xuất**
  (ICX là giả định, không phải điều văn bản nói); chúng chưa được duyệt.
- Mô hình norm là do tôi đọc và gom tay từ Điều 5, 10, 12, 13, 19; sai cách đọc sẽ
  đổi tập atom mỗi cặp đọc.
- Không kiểm chứng rằng `ci/` hay CI trên GitHub còn xanh sau V0 (chỉ chạy cục bộ).
- Chưa đọc các văn bản của Chính phủ mà luật dẫn chiếu; atom cho các khe ủy quyền
  (P07, P12, P13) chỉ là tham số mở như hiện tại.

## 8. Quyết định cần bạn

(Không gồm G1, G4, G7, G12; V không phụ thuộc chúng về định tính — chúng chỉ đổi số
atom, số norm và số cặp. G12 đổi việc bảng là **một** hay **nhiều**, và V biểu diễn
được cả hai.)

1. **Có cho phép V0** (một file mới, hai dòng `import`, không sửa gì có sẵn) hay muốn
   tiếp tục C (A5–A9 trên `S` mờ)?
2. **Bảng là mã Lean do pipeline sinh ra** (kernel thấy được, khuyến nghị) hay dữ liệu
   đọc lúc chạy (cần bộ phân tích cú pháp trong trust base)?
3. **Enum**: thêm nút "atom = giá trị" vào `Cond` (V-enum, sửa `Core/Norm.lean`), hay
   giữ Bool + IC "đúng một" (V-Bool, chỉ thêm, nhưng tốn bit)? V0 chọn V-Bool để
   không sửa file có sẵn.
4. **Phạm vi số**: lát cắt này chỉ cần so sánh với hằng, đã nằm trong dải. Có muốn
   nút thứ tự "atom ≥ k" ngay từ đầu (chi phí một nút `Cond`) không, hay chờ đến khi
   luật nào đó cần?
5. **`Scope`**: nếu V được chọn, `validExcluded` nên là con số đếm (cần B5, 200–350
   dòng thô) hay danh sách IC thay cho con số?
