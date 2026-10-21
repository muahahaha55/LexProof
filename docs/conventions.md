# LexProof — Quy ước

Chuẩn áp dụng, bố cục repo, luật duyệt, và cách chạy build cùng audit axiom.
Các khuôn mẫu ở đây dùng ở mức **nhẹ**: lấy phần có ích, không làm lễ nghi.

---

## 1. Chuẩn áp dụng

| Việc | Chuẩn | Dùng ở đâu |
|---|---|---|
| Chất lượng yêu cầu | **ISO/IEC/IEEE 29148** — ID duy nhất, một phát biểu "phải", ưu tiên MoSCoW, tiêu chí chấp nhận, phương pháp kiểm chứng, trạng thái | [requirements.md](requirements.md) |
| Nhóm yêu cầu phi chức năng | **ISO/IEC 25010** — nhóm theo đặc tính chất lượng, và **nói rõ đặc tính nào chủ động để ngoài phạm vi** | [requirements.md](requirements.md) mục 2–3 |
| Tài liệu kiến trúc | **arc42** (chỉ mục có nội dung thực) | [architecture.md](architecture.md) |
| Sơ đồ | **C4** mức Context và Container, vẽ bằng **Mermaid** | [architecture.md](architecture.md) mục 3, 5 |
| Quyết định | **MADR** — một tệp một quyết định, số tăng dần, không sửa nội dung cũ | [decisions/](decisions/README.md) |
| Commit | **Conventional Commits** | mục 5 dưới đây |
| Đặt tên Lean | mục 4 dưới đây | toàn bộ `LexProof/` |

**Về sơ đồ C4**: Mermaid có cú pháp `C4Context` riêng nhưng còn thực nghiệm và
render không đồng đều. Trong repo này C4 được vẽ bằng `flowchart` với nhãn ghi
rõ loại phần tử (`[Person]`, `[Software System]`, `[Container]`) — đổi lại tính
tương thích, giữ nguyên ngữ nghĩa C4.

**Phương pháp kiểm chứng** dùng đúng bốn giá trị:

| Giá trị | Nghĩa |
|---|---|
| **Proof** | Kernel Lean kiểm; là bằng chứng mạnh nhất, nhưng chỉ cho G1 |
| **Test** | Chạy tự động, có kết quả đúng/sai |
| **Review** | Người đọc và xác nhận; là *cách duy nhất* cho G2 |
| **Demo** | Trình diễn cho người dùng thật |

**Trạng thái** dùng đúng ba giá trị: `Implemented` / `Planned` / `Open`. Thứ gì
chưa kiểm thì ghi thẳng **"chưa kiểm"**, không ghi là đã xong.

---

## 2. Bố cục repo

```
LexProof/            thư viện Lean (TIN CẬY)
  Core/              Finite.lean, Norm.lean
  Laws/              một module mỗi văn bản — RỖNG (Planned)
  Verify/            Conflict.lean, Smoke.lean
  Cert/              audit axiom — RỖNG (Planned)
  Basic.lean         còn sót từ `lake new`
LexProof.lean        gốc thư viện — hiện chỉ import LexProof.Basic
Main.lean            exe mẫu, còn sót từ `lake new`
pipeline/            Python, KHÔNG TIN CẬY — rỗng
data/ review/ eval/ reports/ docs/
lakefile.toml        không sửa mà không hỏi
lean-toolchain       leanprover/lean4:v4.35.0 — không sửa mà không hỏi
```

Biên tin cậy: mọi thứ ngoài `LexProof/` là **không tin cậy**. Đầu ra LLM phải
được người duyệt phê duyệt trước khi vào `Laws`
([ADR-0011](decisions/0011-trust-boundary-human-approval.md)). Nhưng trust base
còn rộng hơn kernel — xem mục 3 của [traceability.md](traceability.md).

---

## 3. Quy ước Lean

| Loại | Quy ước | Ví dụ trong code |
|---|---|---|
| Kiểu, structure, inductive, class | `UpperCamelCase` | `Norm`, `Cond`, `Modality`, `Finite`, `Counterexample` |
| Định nghĩa, hàm | `lowerCamelCase` | `conflictsAt`, `isConflictAt`, `mkResult`, `paramNames`, `scopeOf` |
| Định lý, bổ đề | `snake_case` | `conflict_of_witness`, `not_conflict_of_consistentOn`, `isConflictAt_eq_true_iff`, `mem_cands` |
| Vị từ dạng `Bool` | tiền tố `is` | `isConflictAt`, `isUnknownAt` |
| Hàm trả `Option` | hậu tố `?` | `Result.witness?` |

Thêm:

- **Docstring `/-- … -/` cho mọi khai báo công khai.** Docstring mô-đun `/-! … -/`
  ở đầu mỗi file, nói file đó làm gì và cái gì là mắt nối then chốt.
- Mã và tên định danh bằng **tiếng Anh**; lỗi Lean được giải thích cho người
  dùng bằng **tiếng Việt**.
- Không `sorry`, không axiom mới, không `native_decide`, không `bv_decide` trong
  bất cứ thứ gì chống lưng một kết luận
  ([ADR-0010](decisions/0010-axiom-whitelist-decide-only.md)).
- Mỗi norm hình thức hóa giữ ID điều khoản nguồn (`SourceId.article`).

**Nợ đã biết**: quy ước docstring hiện **chưa đạt**. Danh sách khai báo còn
thiếu docstring nằm ở [design-core.md](design-core.md) mục 6.

---

## 4. Luật duyệt

### 4.1 Duyệt code Lean

1. `lake build` **cho các module thật** (mục 6) phải xanh trước khi nói là xong.
2. Audit axiom (mục 7) phải sạch cho mọi định lý mới.
3. Thay đổi `Conflict`, `Norm.applies`, `Norm.resolved`, `Incompatible` hay
   `Cond.eval` là thay đổi **trust base** → phải nói rõ trong mô tả PR và phải
   kiểm lại các định lý phụ thuộc. Năm định nghĩa này không phải code thường.
4. Không mở rộng phạm vi ngoài phần được yêu cầu. Thêm phụ thuộc, đổi cấu trúc
   thư mục, sửa `lakefile.toml` hay `lean-toolchain` thì **phải hỏi trước**.

### 4.2 Duyệt bản mã hóa luật (faithfulness)

Đây là việc **của con người** và là bằng chứng duy nhất cho G2
([traceability.md](traceability.md)). Checklist:

- [ ] `source.article` trỏ đúng điều/khoản/điểm.
- [ ] `act` dùng đúng id trong glossary — và **không** có hành vi nào đáng ra
      cùng act lại bị gán id khác ([ADR-0004](decisions/0004-act-as-opaque-glossary-id.md)).
- [ ] `modality` đúng: "phải" / "không được" / "được".
- [ ] Mỗi câu "trừ trường hợp…" đã được phân loại **đúng** là ngoại lệ hay ưu
      tiên ([ADR-0005](decisions/0005-exceptions-vs-priority.md)) — đây là nguồn
      sai faithfulness thường gặp nhất.
- [ ] Mọi khái niệm mở đã thành **tham số**, không bị nhúng thành hằng.
- [ ] `docId`, `docType`, `effective` điền đúng, dù Level 1 chưa dùng
      ([ADR-0007](decisions/0007-keep-level2-fields-in-sourceid.md)).
- [ ] Bản dịch ngược tiếng Việt khớp với văn bản gốc khi đọc song song.
- [ ] Điều khoản không mã hóa được đã có bản ghi lý do, **không** bị bỏ im lặng.

### 4.3 Phán xử phản ví dụ (Loop B)

Người duyệt quyết định: **luật sai** hay **bản dịch sai**. Hệ thống **không bao
giờ tự sửa**. Kết luận phải ghi lại kèm phản ví dụ.

---

## 5. Commit

**Conventional Commits**: `<type>(<scope>): <mô tả>`

Type dùng trong repo: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `build`.
Scope nên là module hoặc thư mục: `core`, `verify`, `cert`, `laws`, `pipeline`,
`docs`.

```
feat(core): add Finite class and Cond syntax tree
feat(verify): link check to Conflict with two theorems
docs(adr): record axiom whitelist decision
fix(verify): report the malformed norm id, not the sound one
build: include Core and Verify in the default lake target
```

Thay đổi phá vỡ: thêm `!` (`feat(core)!: make resolved directional`) và giải
thích ở phần thân. Mọi thay đổi trust base nên có thân commit nói rõ định lý nào
phải chứng minh lại.

---

## 6. Chạy build

> **Cảnh báo (N12)**: `lake build` **trần không đủ**. `lakefile.toml` khai
> `[[lean_lib]] name = "LexProof"` không có `globs`, nên Lake chỉ build module
> gốc `LexProof`, mà `LexProof.lean` chỉ có `import LexProof.Basic`. Bốn module
> `Core.Finite`, `Core.Norm`, `Verify.Conflict`, `Verify.Smoke` **không** được
> build. Đã xác nhận: `touch` bốn file rồi `lake build` → vẫn 8 jobs, không
> rebuild. CI cũng vì vậy mà không kiểm. Xem N12 trong
> [requirements.md](requirements.md).

Đến khi N12 được sửa, dùng target tường minh:

```powershell
# build mọi module thật (Smoke kéo theo cả ba module kia)
lake build LexProof.Verify.Smoke

# hoặc liệt kê hết cho rõ
lake build LexProof.Core.Finite LexProof.Core.Norm LexProof.Verify.Conflict LexProof.Verify.Smoke

# build lại từ đầu khi nghi artifact cũ
Remove-Item -Recurse -Force .lake\build\lib\lean\LexProof\Core, .lake\build\lib\lean\LexProof\Verify
lake build LexProof.Verify.Smoke
```

---

## 7. Chạy audit axiom

Whitelist: **`{propext, Classical.choice, Quot.sound}`**. Bất cứ thứ gì khác, và
bất cứ `sorryAx` nào, là **thất bại**.

Audit theo **whitelist**, không phải blacklist theo tên: `native_decide` sinh ra
axiom **đặt tên theo từng định lý** (ví dụ `t._native.native_decide.ax_1_1`),
không phải `Lean.ofReduceBool`, nên tìm theo tên sẽ **không bắt được gì**
([ADR-0010](decisions/0010-axiom-whitelist-decide-only.md)).

### PowerShell

```powershell
$audit = "$env:TEMP\lexproof-audit.lean"
$body = @'
import LexProof.Verify.Smoke
#print axioms LexProof.conflict_of_witness
#print axioms LexProof.not_conflict_of_consistentOn
#print axioms LexProof.isConflictAt_eq_true_iff
#print axioms LexProof.Smoke.smoke_conflict
#print axioms LexProof.Smoke.smoke_consistent
'@
[System.IO.File]::WriteAllText($audit, $body, (New-Object System.Text.UTF8Encoding $false))
lake env lean $audit
```

> **Chú ý về encoding**: phải ghi file **không BOM**. `Out-File -Encoding utf8`
> trong Windows PowerShell 5.1 có thêm BOM, và Lean báo
> `<file>:1:0: error: expected token` rồi coi như không có dòng `import` — mọi
> `#print axioms` sau đó sẽ báo `Unknown constant`, rất dễ hiểu nhầm là lỗi
> code. Đã kiểm cả hai cách; dùng `[System.IO.File]::WriteAllText` như trên.

### Bash (Git Bash)

```bash
cat <<'EOF' | lake env lean --stdin
import LexProof.Verify.Smoke
#print axioms LexProof.conflict_of_witness
#print axioms LexProof.not_conflict_of_consistentOn
EOF
```

### Quét các cấu trúc bị cấm

```powershell
Select-String -Path LexProof\Core\*.lean, LexProof\Verify\*.lean `
  -Pattern 'sorry', 'native_decide', 'bv_decide', '^axiom', 'unsafe', 'partial'
```

Không có dòng nào khớp là đạt.

### Kết quả hiện tại

Mọi định lý trong repo chỉ dùng `propext` và `Quot.sound` — còn chưa cần tới
`Classical.choice`. Không có `sorryAx`. Bảng đầy đủ:
[design-core.md](design-core.md) mục 5.

Audit này đang là **thao tác tay**. Tự động hóa nó là FR11 (`LexProof/Cert/`,
hiện rỗng), và việc đó chỉ có nghĩa sau khi N12 được sửa — vì hiện CI còn không
build các module cần audit.
