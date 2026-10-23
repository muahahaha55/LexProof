# LexProof — Kiến trúc (HLD)

Khuôn theo **arc42** (chỉ các mục có nội dung thực), sơ đồ theo **C4** vẽ bằng
Mermaid. Thiết kế chi tiết của tầng Lean: [design-core.md](design-core.md).

---

## 1. Mục tiêu và yêu cầu

LexProof kiểm tra **tính nhất quán logic trong một văn bản pháp luật** tiếng
Việt: cùng một tình huống mà có nghĩa vụ / cấm / cho phép xung đột nhau và
không có thứ tự ưu tiên rõ ràng, cộng với tham chiếu treo.

Ba mục tiêu chất lượng, theo đúng thứ tự ưu tiên:

| # | Mục tiêu | Vì sao đứng ở vị trí này |
|---|---|---|
| G1 | **Soundness** — kernel Lean chấp nhận chứng minh | Nếu mất, mọi kết luận vô giá trị |
| G2 | **Faithfulness** — bản mã hóa khớp với luật | Không chứng minh được bằng máy; chỉ người và ca kiểm thử chuyên gia nói lên được |
| G3 | **Honest scope** — không bao giờ khẳng định quá phần đã mã hóa và đã duyệt | Đây là thứ phân biệt công cụ hữu ích với công cụ gây hại |

G1 và G2 là **hai loại đúng đắn khác nhau** và không được trộn vào nhau. Bằng
chứng cho từng mục tiêu, và những gì mỗi bằng chứng *không* bao phủ, nằm trong
[traceability.md](traceability.md).

Yêu cầu đầy đủ: [requirements.md](requirements.md).

## 2. Ràng buộc

| Ràng buộc | Nguồn |
|---|---|
| Lean 4 `v4.35.0`, ghim trong `lean-toolchain` | N7 |
| **Không Mathlib**, không phụ thuộc ngoài | [ADR-0009](decisions/0009-own-finite-class-no-mathlib.md) |
| Chỉ `decide`; cấm `native_decide`, `bv_decide`, `sorry`, axiom mới | [ADR-0010](decisions/0010-axiom-whitelist-decide-only.md) |
| Miền tình huống hữu hạn | [ADR-0009](decisions/0009-own-finite-class-no-mathlib.md) |
| Chỉ Level 1 | [ADR-0012](decisions/0012-scope-level1-now.md) |
| Môi trường phát triển: Windows / PowerShell; CI: ubuntu | CLAUDE.md |

## 3. Bối cảnh và phạm vi (C4 — Context)

```mermaid
flowchart TB
    subgraph people["Người"]
        expert["<b>Chuyên gia pháp lý / Người duyệt</b><br/><i>[Person]</i><br/>Phê duyệt bản mã hóa,<br/>phán xử phản ví dụ"]
        author["<b>Tác giả đồ án</b><br/><i>[Person]</i><br/>Mã hóa, vận hành, hiệu chỉnh"]
    end

    lexproof["<b>LexProof</b><br/><i>[Software System]</i><br/>Kiểm tra nhất quán logic<br/>trong một văn bản pháp luật"]

    subgraph ext["Hệ thống ngoài"]
        corpus[("<b>Văn bản pháp luật công khai</b><br/><i>[External System]</i>")]
        llm["<b>LLM</b><br/><i>[External System]</i><br/>Dịch sang dữ liệu Lean<br/><b>KHÔNG tin cậy</b>"]
    end

    corpus -->|"văn bản thô"| lexproof
    lexproof -->|"yêu cầu dịch"| llm
    llm -->|"bản nháp Norm<br/>(phải duyệt)"| lexproof
    lexproof -->|"phản ví dụ,<br/>báo cáo kèm scope"| expert
    expert -->|"phê duyệt / từ chối,<br/>phán xử"| lexproof
    author -->|"vận hành"| lexproof

    style lexproof fill:#1168bd,stroke:#0b4884,color:#fff
    style llm fill:#999,stroke:#666,color:#fff
    style expert fill:#08427b,stroke:#052e56,color:#fff
    style author fill:#08427b,stroke:#052e56,color:#fff
```

**Trong phạm vi**: một văn bản, Level 1.
**Ngoài phạm vi**: so sánh giữa nhiều văn bản, thứ bậc hiệu lực pháp lý, tư vấn
pháp lý, quyết định về khái niệm mở.

## 4. Chiến lược giải pháp

1. **Đẩy mọi thứ không chắc chắn ra ngoài kernel.** LLM, phân đoạn, glossary đều
   không tin cậy. Chỉ dữ liệu *đã có người duyệt* được vào `Laws`.
2. **Dữ liệu, không phải mã.** LLM sinh ra `Norm` với cây cú pháp `Cond`, không
   sinh mã Lean tự do. Nhờ vậy bản dịch in được, so sánh được, và không thể
   chèn logic lạ ([ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md)).
3. **Miền hữu hạn để kiểm được bằng máy.** Tình huống và khái niệm mở đều hữu
   hạn, nên tìm xung đột là quét cạn, chứng minh bằng `decide`.
4. **Ba/bốn giá trị, fail closed.** Không chắc thì `unknown`, không bao giờ
   im lặng bỏ qua.
5. **Hai vòng phản hồi có người ở giữa** (mục 6). Hệ thống không bao giờ tự sửa
   bản mã hóa dựa trên kết quả kiểm tra của chính nó.

## 5. Khung nhìn khối (C4 — Container), 4 tầng

```mermaid
flowchart TB
    subgraph T1["Tier 1 — Chuẩn bị đầu vào  ·  KHÔNG TIN CẬY"]
        seg["<b>Segmenter</b><br/><i>[Container: Python]</i><br/>Tách phần/chương/điều/khoản/điểm,<br/>giữ ID, phân giải tham chiếu"]
        glo["<b>Glossary</b><br/><i>[Container: Python + data]</i><br/>Thuật ngữ cố định → kiểu Lean, act id"]
        cases["<b>Ca kiểm thử chuyên gia</b><br/><i>[Container: data]</i><br/>Đầu vào/kết quả mong đợi"]
    end

    subgraph T2["Tier 2 — Dịch và sửa  ·  KHÔNG TIN CẬY"]
        tr["<b>LLM Translator</b><br/><i>[Container: Python + LLM]</i><br/>Điều khoản → Norm (dữ liệu)"]
        val["<b>Validator</b><br/><i>[Container: Lean/Python]</i><br/>Well-formedness: ID trùng,<br/>tham chiếu treo, chỉ số atom,<br/>chu trình ưu tiên"]
        back["<b>Back-translator</b><br/><i>[Container: ?]</i><br/>Norm → tiếng Việt<br/>(LLM hay tất định: ADR-0019)"]
        rev["<b>Người duyệt</b><br/><i>[Person]</i><br/>Đối chiếu song song, phê duyệt"]
    end

    subgraph T3["Tier 3 — Kernel Lean, thư viện LexProof/  ·  TIN CẬY"]
        core["<b>Core</b><br/><i>[Lean module]</i><br/>Finite, Modality, Cond+eval,<br/>Norm, SourceId, applies"]
        laws["<b>Laws</b><br/><i>[Lean modules]</i><br/>Một module mỗi văn bản<br/><b>chỉ nhận norm đã duyệt</b>"]
        verify["<b>Verify</b><br/><i>[Lean module]</i><br/>Conflict, check,<br/>counterexample, 2 định lý"]
        cert["<b>Cert</b><br/><i>[Lean module]</i><br/>Audit axiom theo whitelist"]
    end

    subgraph T4["Tier 4 — Đầu ra"]
        rep["<b>Báo cáo</b><br/><i>[Container]</i><br/>Tiếng Việt, kèm scope<br/>và trích dẫn điều khoản"]
        query["<b>Truy vấn kèm chứng minh</b><br/><i>[Container]</i>"]
        ver["<b>Quản lý phiên bản</b><br/><i>[Container]</i>"]
        cex["<b>Phản ví dụ</b><br/><i>[Container]</i><br/>Phát lại được"]
    end

    seg --> tr
    glo --> tr
    tr --> val
    val -->|"lỗi"| tr
    val --> back
    back --> rev
    rev -->|"PHÊ DUYỆT"| laws
    core --> laws
    core --> verify
    laws --> verify
    verify --> cert
    verify --> cex
    verify --> rep
    verify --> query
    laws --> ver
    cases --> verify
    cex --> rev

    style T1 fill:#fff4f4,stroke:#d33
    style T2 fill:#fff4f4,stroke:#d33
    style T3 fill:#f0fff0,stroke:#2a2
    style T4 fill:#f4f8ff,stroke:#48a
    style laws fill:#1168bd,stroke:#0b4884,color:#fff
    style verify fill:#1168bd,stroke:#0b4884,color:#fff
    style rev fill:#08427b,stroke:#052e56,color:#fff
```

Trạng thái cài đặt của từng khối:

| Khối | Trạng thái |
|---|---|
| `Core` (`Finite`, `Norm`, `Cond` + `wf`, `Atoms.valid`) | **Implemented** |
| `Verify` (`Conflict`, `cands`, `check`, `analyze`, định lý (a)–(f), smoke, 9 nhóm test) | **Implemented** |
| Validator (`Verify/Validate.lean`: `Finding`, `validate`) | **Implemented** — [ADR-0017](decisions/0017-wellformedness-validator-first.md) |
| `Laws` | **Planned** — thư mục rỗng |
| `Cert` (`Cert/Audit.lean`: `#audit_axioms`, `#audit_encapsulation`) | **Implemented** — chạy trong mỗi `lake build`, làm build đỏ khi vi phạm. Đề xuất cho phần quy mô: [ADR-0020](decisions/0020-untrusted-search-kernel-certificate.md) |
| Segmenter, Glossary, Translator, Back-translator | **Planned** — `pipeline/` rỗng |
| Ca chuyên gia, báo cáo, truy vấn, phiên bản | **Planned** — `eval/`, `reports/` rỗng |

## 6. Khung nhìn thời gian chạy — hai vòng phản hồi

### Loop A — sửa lỗi dịch (trước khi vào Laws)

```mermaid
sequenceDiagram
    participant S as Segmenter
    participant L as LLM Translator
    participant V as Validator / Lean
    participant B as Back-translator
    participant R as Người duyệt
    participant W as Laws

    S->>L: điều khoản + ID
    loop tối đa N vòng (N chưa chốt)
        L->>V: Norm (dữ liệu)
        alt không well-formed
            V-->>L: lỗi cụ thể → sửa
        else well-formed
            V->>B: Norm
        end
    end
    alt hết N vòng vẫn lỗi
        V->>R: đánh dấu "not encoded" + bản ghi lý do
    end
    B->>R: diễn đạt tiếng Việt, đối chiếu song song
    alt duyệt
        R->>W: norm đã phê duyệt
    else từ chối
        R-->>L: yêu cầu mã hóa lại / đánh dấu "not encoded"
    end
```

Điểm then chốt: **không có mũi nào đi từ LLM trực tiếp vào `Laws`**. Mọi đường
vào `Laws` đều qua người duyệt (FR5, [ADR-0011](decisions/0011-trust-boundary-human-approval.md)).

### Loop B — phán xử phản ví dụ (sau khi kiểm tra)

```mermaid
sequenceDiagram
    participant V as Verify (check)
    participant C as Phản ví dụ
    participant R as Người duyệt
    participant W as Laws
    participant D as Văn bản luật

    V->>C: conflict / conditionalConflict + witness
    C->>R: tình huống, tham số, 2 NormId, 2 SourceId
    R->>R: Luật sai, hay bản dịch sai?
    alt bản dịch sai
        R->>W: sửa lại bản mã hóa (có người duyệt)
    else luật thật sự xung đột
        R->>D: ghi nhận một phát hiện về văn bản
    end
    Note over V,R: Hệ thống KHÔNG BAO GIỜ tự sửa.<br/>Phân xử luật-sai hay dịch-sai là việc của con người.
```

## 7. Khái niệm xuyên suốt

### 7.1 Trust boundary

```
KHÔNG TIN CẬY                      │  TIN CẬY
Tier 1, Tier 2                     │  Tier 3 (kernel Lean + LexProof/)
Python, LLM, segmenter, glossary    │  Core, Laws, Verify, Cert
───────────────────────────────────┼──────────────────────────────────
Cổng duy nhất: NGƯỜI DUYỆT PHÊ DUYỆT
```

Mọi thứ ngoài Lean là không tin cậy. Nhưng **kernel không phải là toàn bộ cơ sở
tin cậy**: các định nghĩa `Conflict`, `Norm.applies`, `Norm.resolved`,
`Incompatible`, `Cond.eval` nằm *cùng* kernel trong trust base, và **không có gì
chứng minh chúng khớp với luật**. Danh sách đầy đủ và hệ quả: bảng trust base
trong [traceability.md](traceability.md).

### 7.2 Kết quả nhiều giá trị và fail-closed

`check` trả về đúng một trong bốn: `conflict`, `conditionalConflict`,
`consistentOn scope`, `unknown reason`. Không có giá trị nào nghĩa là "văn bản
đúng". `consistentOn` chỉ nói về `ns` được truyền vào, trong miền `|S| × |P|`
được liệt kê.

Khi không đánh giá được (chỉ số atom sai), `Cond.eval` trả `none` và kết quả
thành `unknown` — không bao giờ lặng lẽ thành `false`
([ADR-0002](decisions/0002-cond-syntax-tree-option-eval.md)).

### 7.3 Chính sách axiom

Whitelist `{propext, Classical.choice, Quot.sound}`. `native_decide` và
`bv_decide` bị cấm vì cả hai đều thêm axiom sinh theo từng định lý khi thực sự
phải gọi trình giải; `sorryAx` bị cấm vì `decide` thất bại sẽ *im lặng* để lại
nó. Chi tiết và số liệu đo: [ADR-0010](decisions/0010-axiom-whitelist-decide-only.md).

### 7.4 Ngân sách liệt kê

Chi phí `|S| × |P| × số cặp norm`. Trần kế hoạch 2^14; nhóm norm theo `act` để
giảm số cặp. Số đo và giới hạn: N8 trong [requirements.md](requirements.md).

## 8. Quyết định kiến trúc

19 ADR theo khuôn MADR: [decisions/README.md](decisions/README.md).

## 9. Rủi ro và nợ kỹ thuật

| # | Rủi ro / nợ | Mức | Xử lý |
|---|---|---|---|
| R2 | Faithfulness không chứng minh được; trust base gồm **6** định nghĩa người viết (nay thêm `Atoms.valid`) | Cao | G2: ca chuyên gia + duyệt chéo (FR12, N4) |
| R11 | **`Atoms.valid` quá mạnh sẽ che xung đột thật** và không định lý nào phát hiện được — mọi định lý đều có dạng "trên phần `valid`" | Cao | Duyệt `valid` như duyệt một norm; `Scope.validRestricted` để người đọc thấy |
| R14 | **Chu trình ưu tiên từ 3 norm trở lên lừa được bộ kiểm trần**: `resolved` là XOR theo cặp nên mọi cặp trông như đã giải quyết | Thấp | Nay có **định lý**: mọi kết quả đã quét của `analyze` kèm bảo đảm không có chu trình (`no_priority_cycle_of_*`), nên hiểm họa không lọt qua điểm vào. Định nghĩa `resolved` vẫn giữ nguyên (theo D40) |
| R5 | Nổ tổ hợp khi `\|S\|` lớn; chưa có chốt ngân sách | Trung bình | N8; `unknown(outOfBudget)` chưa cài; [ADR-0020](decisions/0020-untrusted-search-kernel-certificate.md) |
| R12 | Validator chỉ có **một** định lý (`wf_of_validate_nil`); phát hiện chu trình ưu tiên, trùng id và tham chiếu treo chỉ được kiểm bằng test | Trung bình | Chứng minh thêm, hoặc chấp nhận và nói rõ |
| R13 | `Audit.resolutions` không có định lý nói nó liệt kê đủ và đúng | Thấp | Chứng minh khi báo cáo dựa vào nó |
| R9 | `LexProof/Basic.lean` và `Main.lean` vẫn là mẫu `lake new` (`def hello`), và `lexproof` là target build mặc định | Thấp | Dọn riêng |
| R10 | Mỗi văn bản mới phải viết tay instance `Finite`; chỉ có sẵn `Unit`, `Bool`, `×` | Thấp | Cân nhắc deriving handler sau |

**Đã đóng**: R1 (`lake build` trần nay biên dịch mọi module, N12),
R3 (nhãn đã có định lý đặc trưng, [ADR-0015](decisions/0015-characterize-conflict-labels.md)),
R4 (validator đã có, [ADR-0017](decisions/0017-wellformedness-validator-first.md)),
R6 (`resolved` nay là XOR, chu trình bị báo, norm thắng được ghi, [ADR-0013](decisions/0013-directional-priority-and-cycles.md)),
R7 (so cặp không thứ tự, [ADR-0014](decisions/0014-compare-pairs-by-index.md)),
R8 (audit axiom nay tự động trong `lake build`, FR11),
R12 (validator nay có thêm `cycle_of_validate_finding` và `singleDocId_isSome_of_validate_nil`; completeness chu trình thì chuyển thành R14),
R13 (`resolution_has_witness` đã chứng minh),
R15 (negative test của audit nay chạy cố định trong CI: `ci/audit-negative.sh`),
R16 (build lạnh về **30.7s** sau khi hạ n=3 xuống `#eval` và tính `gnodes` một lần).

## 10. Thuật ngữ

| Thuật ngữ | Nghĩa trong LexProof |
|---|---|
| Norm | Một điều khoản đã hình thức hóa, kiểu `Norm` |
| Situation (`S`) | Kiểu hữu hạn mô tả tình huống, do mỗi văn bản tự khai |
| Open-textured concept | Khái niệm mở ("hợp lý", "nghiêm trọng"), là tham số `P`, hệ thống không tự quyết |
| Act | Id hành vi, chuỗi mờ lấy từ glossary |
| Modality | obligation / prohibition / permission |
| Priority | Ưu tiên tường minh; thiếu nó nghĩa là *chưa* giải quyết |
| Scope | Phần đã mã hóa và đã quét mà một khẳng định nhất quán nói về |
| Trust base | Kernel Lean **cộng** các định nghĩa mà con người viết và không chứng minh được |
| Soundness (G1) | Kernel chấp nhận chứng minh |
| Faithfulness (G2) | Bản mã hóa khớp với luật |
