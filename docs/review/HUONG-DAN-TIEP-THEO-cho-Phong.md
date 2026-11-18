# Hướng dẫn tiếp theo cho Phong (cập nhật 2026-11-18)

Gửi Phong: cảm ơn tệp đối chiếu hôm 18/11 (`ket-qua-doi-chieu-Phong-2026-11-18.md`). Tệp này nói bạn cần làm gì tiếp, theo thứ tự. **Bạn không cần chạy code.** Chỉ cần đọc, đánh dấu ô, ghi lý do, rồi gửi lại.

## 0. Bạn đang ở đâu trong dự án (đọc 1 phút)

LexProof là công cụ kiểm tra xem các điều khoản trong **một văn bản luật** có mâu thuẫn nhau không. Đường đi:

```
chữ của luật → AI dịch thành "norm" (dữ liệu) → NGƯỜI DUYỆT (bạn) → máy kiểm tra → báo cáo
```

- **Norm** = một quy tắc đã viết thành dữ liệu: *cấm / bắt buộc / được phép* + *hành vi* + *khi nào áp dụng* + *ngoại lệ* + *điều khoản nguồn*.
- **Atom** = một dữ kiện đúng/sai dùng trong điều kiện, ví dụ «địa điểm là cơ sở y tế».
- **Tham số** = khái niệm mở mà máy **không** tự quyết (ví dụ «dành cho người chưa đủ 18 tuổi»).
- **Nhánh (i), (ii)** = cách gọi của dự án để tách một khoản dài thành các lệnh cấm ngăn bằng dấu «;». Luật gốc không có chữ «nhánh».
- Việc của bạn: xác nhận AI đã **đọc luật đúng chưa**. Máy chỉ kiểm logic trên dữ liệu; chỉ người đọc luật mới biết dữ liệu có đúng ý luật không. **Máy không bao giờ kết luận «văn bản đúng».**

Hiện **chưa có bản dịch AI nào được đưa vào thư viện chính**. Hai bản dịch (Điều 19 và Điều 5) đang chờ bạn duyệt.

## 1. Việc 1 (quan trọng nhất): điền hai phiếu duyệt bản dịch

Hai tệp (cùng thư mục `docs/review/`):

| Tệp | Số norm | Ghi chú |
|---|---|---|
| `duyet-ban-dich-dieu-19.md` | 6 | Làm trước, đơn giản |
| `duyet-ban-dich-dieu-5.md` | 20 | Có chỗ bạn đã nói AI sai (xem mục 1.3) |

### 1.1 Cách điền (cho cả hai phiếu)

1. Mở **văn bản luật** trước: `docs/review/ban-nhap-ai-phieu-ca-thu.pdf` (mục 2 có toàn văn 36 điều), hoặc bản chính thức của bạn. Đọc điều luật **trước khi** đọc phiếu.
2. Ở đầu phiếu điền 2 dòng, **chỉ sửa phần sau dấu hai chấm**:
   ```
   Người duyệt: Vũ Đức Phong
   Ngày duyệt (YYYY-MM-DD): 2026-11-19
   ```
3. Mỗi hàng của bảng **«1. Norm»**: so cột «Trích dẫn» và «Áp dụng khi» / «Ngoại lệ» với luật. Rồi ở cột **Quyết định** đổi **đúng một** ô `☐` thành `☒`:
   - Đồng ý → `☒ Chấp nhận<br>☐ Bác`
   - Không đồng ý → `☐ Chấp nhận<br>☒ Bác`, **và bắt buộc** ghi lý do ở cột cuối («Lý do»).
4. Bảng **«2. Giả định»**: mỗi giả định là một cách đọc luật mà AI tự chọn. `☒ Chấp nhận` nếu bạn đồng ý, `☒ Bác` nếu không.
5. Bảng **«3. Khoản để ngoài»**: những khoản AI không mã hóa. `☒ Đồng ý để ngoài` nếu hợp lý, `☒ Không đồng ý` nếu khoản đó đáng lẽ phải được mã hóa.
6. Giữ nguyên dấu `|` và số cột của bảng. Chỉ đổi ký tự `☐`/`☒` và điền chữ vào ô «Lý do». Đừng thêm hay xóa hàng. Nếu gõ sai định dạng, công cụ sẽ báo lỗi chứ không hỏng gì.
7. **Đừng chọn «Chấp nhận» chỉ để cho qua.** Chọn «Bác» khi không chắc cũng là câu trả lời đúng; công cụ được làm ra để chặn bản dịch sai.

> Dòng `sha256 bản dịch: ...` trong phiếu **đừng sửa**. Nó gắn phiếu với đúng bản dịch bạn đã đọc.

### 1.2 Những chỗ tôi (Claude) nghi, bạn nên soi kỹ

**Phiếu Điều 19**
- Khoản 3: AI đọc «dành cho người chưa đủ 18 tuổi» bổ nghĩa cho cả bốn loại (chăm sóc, nuôi dưỡng, vui chơi, giải trí) và coi đó là **tham số mở**. Bạn đọc thế nào?
- Khoản 4: AI tách thành 5 loại địa điểm nối bằng «HOẶC». Có chấp nhận không?
- Khoản 6: ngoại lệ «trừ địa điểm được phép kinh doanh rượu, bia» áp dụng cho **cả danh sách** nơi làm việc. AI coi đó là **ngoại lệ thu hẹp lệnh cấm**, không phải quyền. (Trong tệp trước bạn từng đọc ngược lại: ngoại lệ **tạo ra quyền**. Nếu bạn vẫn nghĩ vậy, hãy bác giả định **A:6** (ở phiếu Điều 19) và ghi lý do. Đây là chỗ cần ý kiến thứ hai.)
- Giả định về **ngày hiệu lực 2020-01-01** (phiếu Điều 19 là A:2, phiếu Điều 5 là A:1): ngày này **có trong luật** ở **Điều 36 khoản 1**, chỉ là không nằm trong đoạn văn bản đưa cho AI. Đối chiếu Điều 36 rồi chấp nhận.

**Phiếu Điều 5**
- **Norm 5.11.1 (khoản 11, vế «không có giấy phép hoặc không đăng ký»)**: AI mã hóa là chỉ cấm khi thiếu **cả hai**. Bạn đã trả lời ở Q1 là thiếu **một trong hai** đã vi phạm. Vậy hãy **Bác** norm này, ghi lý do «thiếu một trong hai đã vi phạm», và **Bác** giả định **A:13** trong bảng 2 (giả định «chỉ cấm khi thiếu cả hai»). Hệ quả đã biết: bản dịch Điều 5 sẽ **không** vào thư viện ngay mà phải dịch lại. Đó là kết quả mong muốn, đừng cố sửa phiếu cho qua.
- **Norm 5.10.2 (khoản 10 nhánh (ii))**: AI đọc «không bảo đảm chất lượng **và** không rõ nguồn gốc» là cả hai. Bạn đã trả lời cùng cách: nên **Chấp nhận** norm này và giả định **A:12**.
- **Norm 5.7 và 5.11.1**: AI chỉ áp dụng cho **rượu**, không cho bia (vì luật chỉ nói «rượu»). Bạn đã đồng ý ở Q7 (giả định A:9 và A:14).
- **Norm 5.3a/b/c** (bán, cung cấp, khuyến mại cho người chưa đủ 18 tuổi): AI tách thành 3 norm riêng cho 3 hành vi. Kiểm tra «cung cấp» có gồm cho không (bạn đã trả lời có ở Q3). Giả định A:4 nói về việc tách này.
- **Norm 5.5 (khoản 5)**: điều kiện dài, có tham số «ngay trước giờ làm việc». Đọc kỹ cột «Áp dụng khi».
- **Norm 5.6** (lái xe có nồng độ cồn): AI coi mọi nồng độ lớn hơn 0 là vi phạm (giả định A:8). Đồng ý không?

Nếu một norm bạn bác mà chỉ vì **cách mã hóa** (không phải vì sai nghĩa luật), vẫn ghi rõ lý do để người sau biết.

## 2. Việc 2: các câu hỏi còn treo từ tệp của bạn

Trả lời ngắn vào một tệp mới (xem mục 4) cho các câu sau:

1. **Q4 và C37 mâu thuẫn:** ở Q4 bạn viết tặng rượu miễn phí tại phòng khám **không bị** Điều 19 cấm (không chắc), nhưng C37 (cùng tình huống) bạn trả lời **cấm**. Câu nào là ý của bạn?
2. **Ô «Đúng ý / Sai ý» ở C26, C28, C30, C35:** bạn ghi «khoản này không điều chỉnh» vào ô này (đáng lẽ chỉ ghi Đúng ý hoặc Sai ý). Ý bạn là **Đúng ý** cho cả 4 ca, đúng không?
3. **15 ca bạn trả lời «được phép»** (C02, C04, C06, C08, C10, C12, C15, C16, C20, C21, C23, C26, C28, C30, C34): bạn có ý là **luật cho phép rõ ràng**, hay chỉ là **không bị cấm / không có quy định cấm trong các khoản đã trích**? (Phiếu ca thử có quy định: «đừng ghi được phép chỉ vì không thấy lệnh cấm».)
4. **C34** bạn ghi «được phép» nhưng chọn «**Sai ý**». Bạn thấy câu hỏi của ca C34 sai ở chỗ nào?
5. **Q8–Q10 (Nghị quyết 66.18/2026/NQ-CP)**, xem `docs/review/huong-dan-doi-chieu.md`:
   - Q8: ba mục về luật rượu, bia nằm ở **phụ lục nào, mục nào** của PDF chính thức?
   - Q9: ngày bắt đầu của ba mục là **01/7/2026** hay **20/5/2026**?
   - Q10: trong thời gian nghị quyết có hiệu lực (đến hết **28/02/2027**), ca C24 (bán rượu không giấy phép) có còn bị cấm theo khoản 11 Điều 5 vế đầu không?
   (Tôi đã đọc PDF chính thức: ba mục có thật và nghị quyết chỉ có hiệu lực đến hết 28/02/2027, nhưng chữ PDF bị lỗi nhận dạng nên tôi chưa thấy tiêu đề phụ lục. Bạn mở PDF gốc tại vanban.chinhphu.vn, số 66.18/2026/NQ-CP, tìm cụm «kinh doanh rượu không có giấy phép».)

## 3. Việc 3 (nếu còn thời gian): nhờ người thứ hai

- **Q5** (ngoại lệ «trừ…» của Điều 19 khoản 6 chỉ thu hẹp lệnh cấm hay còn tạo quyền) cần **ý kiến thứ hai**, vì chỉ một người đọc thì chưa đủ để đổi bản mã hóa. Bạn nhờ thêm một người học luật đọc riêng và ghi tên họ vào tệp kết quả.

## 4. Cách gửi lại

Tạo tệp **`docs/review/ket-qua-doi-chieu-Phong-2026-11-19.md`** (đổi ngày nếu cần) gồm:

1. Tên, ngày; **bạn có xem bản nháp AI trước khi trả lời không** (có / không / một phần).
2. Trả lời các câu ở **mục 2**.
3. Nếu có người thứ hai: tên và ý kiến về Q5.
4. Chỗ nào trong hai phiếu bạn thấy khó hiểu hoặc phiếu có lỗi.

Cùng với **hai phiếu đã điền** (sửa trực tiếp trong `docs/review/duyet-ban-dich-dieu-19.md` và `docs/review/duyet-ban-dich-dieu-5.md`).

**Đẩy lên GitHub** (như lần trước, qua nhánh riêng). Trong thư mục `LexProof`:

```
git switch -c phong-review-2
git add docs/review/duyet-ban-dich-dieu-19.md docs/review/duyet-ban-dich-dieu-5.md docs/review/ket-qua-doi-chieu-Phong-2026-11-19.md
git commit -m "Phong: duyet ban dich Dieu 19 va Dieu 5, tra loi cau hoi treo"
git push -u origin phong-review-2
```

Nếu dùng GitHub Desktop thì chọn đúng ba tệp trên, đặt nhánh mới là `phong-review-2`, commit rồi publish. Nếu không dùng git, gửi ba tệp cho người phụ trách dự án.

**Sau khi bạn gửi:** người phụ trách (hoặc Claude) chạy `pipeline/promote.py`. Công cụ sẽ từ chối nếu phiếu thiếu hàng, thiếu lý do, hoặc bạn bác một giả định (khi đó AI phải dịch lại). Nếu hợp lệ, bản dịch Điều 19 sẽ vào thư viện kèm định lý Lean được kernel kiểm. Bạn **không** cần chạy gì.

## 5. Những điều KHÔNG làm

- Không sửa tệp `.lean`, `.py` hoặc các tệp `.json` (bản dịch). Nếu bản dịch sai, ghi vào phiếu (Bác + lý do).
- Không sửa dòng `sha256 bản dịch`.
- Không viết «đúng luật» hay «hợp pháp». Ghi: chấp nhận / bác / không chắc, kèm lý do.
- Không đoán ý người soạn luật. Chữ của luật không đủ để quyết thì ghi **«không chắc»** và nêu vì sao.

## 6. Bản đồ tệp (nếu bạn muốn xem thêm)

| Bạn muốn | Mở |
|---|---|
| Đọc toàn văn luật | `docs/review/ban-nhap-ai-phieu-ca-thu.pdf` (mục 2) |
| Phiếu cần điền | `docs/review/duyet-ban-dich-dieu-19.md`, `duyet-ban-dich-dieu-5.md` |
| Bản dịch gốc của AI (JSON; không cần đọc, phiếu đã diễn giải) | `eval/translate/article19.llm.json`, `article5.llm.json` |
| Cách AI dịch lần này và nó sai chỗ nào | `eval/translate/RECORD.md` |
| Tệp đối chiếu cũ của bạn | `docs/review/ket-qua-doi-chieu-Phong-2026-11-18.md` |
| Hướng dẫn đối chiếu đầu tiên (Q1–Q10) | `docs/review/huong-dan-doi-chieu.md` |
| Mục tiêu, tiến độ, lộ trình | `docs/roadmap.md` |

Hiện dự án làm được gì và chưa làm được gì: `docs/roadmap.md`. Mới có 9 trong 141 khoản của luật được mã hóa tay, và độ đúng so với luật chỉ được kiểm bằng người đọc, tức bạn. Vì vậy ý kiến của bạn quan trọng hơn bất kỳ con số nào của máy.
