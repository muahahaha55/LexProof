# Ghi nhận đo bước dịch (ADR-0024)

## Lần 1: Điều 19, 2026-11-18

- Câu lệnh: `prompt-article19.txt` (sha256 CRLF như LF `9bbbd6108c416df2ccf883423256a12f409316753ac97b65ac934de551a8ed50`), do `translate.py prompt --article 19` sinh.
- Câu trả lời: `article19.llm.json` (sha256 `043f2377c73c490ce9c31a4ae11877d6d02039c8acc85ddd10dcacbe1bbb42f3`). Người phụ trách dán câu lệnh vào một cửa sổ Claude mới và lưu JSON. **Việc cửa sổ đó không đọc được repo là lời kể, chưa kiểm chứng.** Dấu hiệu nghiêng về việc nó dịch độc lập: tên atom khác bản tay (S1.. thay vì S14..), tách danh sách địa điểm thành atom nhỏ hơn, và tự ghi rằng ngày hiệu lực không có trong văn bản được cung cấp.
- Bản đối chiếu: `article19.gold.json` (sha256 `4eb75dff35873580e0dea6310b5e4e0c2bcccda7a9b9ae9f66958529be5d272e`), do chính người viết bản mã hóa tay chép lại từ `LexProof/Laws/AlcoholSale.lean`.

| Phép kiểm | Kết quả |
|---|---|
| `translate.py check` | không có phát hiện cấu trúc |
| Lean: `pfindings` trên bản nháp | 0; `analyzeReport`: consistentOn, 15 cặp, **rỗng về xung đột modality** (mọi norm đều là cấm) |
| `compare` (chặt) | 4 norm giống, 2 khác (19.4, 19.6) |
| `compare --relaxed` | 6 norm giống, 0 khác |

Hai norm khác ở phép chặt chỉ vì bản LLM tách «cơ sở cai nghiện, cơ sở giáo dục bắt buộc, trường giáo dưỡng, cơ sở giam giữ phạm nhân, cơ sở giam giữ khác» (khoản 4) và danh sách nơi làm việc (khoản 6) thành nhiều atom nối bằng `or`, còn bản tay gộp thành một atom mỗi khoản. Phép `--relaxed` coi các toán hạng cùng nguồn trong một `or` là một atom của khoản đó; đó là một giả định đồng nhất (không áp dụng cho `and`), không phải chứng minh tương đương.

Khớp ở: modality (cấm), act `ban_ruou_bia` (act này đã có trong câu lệnh mẫu nên không phải bằng chứng), nguồn từng norm, «dành cho người chưa đủ 18 tuổi» là tham số bool, ngoại lệ «trừ địa điểm được phép kinh doanh rượu, bia» nằm ở `exceptions` và áp dụng cho cả khoản 6, tiêu đề Điều 19 được dùng làm lệnh cấm chung.

## Giới hạn (đọc trước khi trích số)

- Một lần chạy, một điều, 6 khoản có cấu trúc rất đơn giản (mỗi khoản một loại địa điểm). Không suy ra độ chính xác trên điều khoản có điều kiện, ngoại lệ lồng hoặc nhiều chủ thể.
- Bản đối chiếu cùng tác giả với bản mã hóa tay và cùng đọc theo G1/G4; câu lệnh cũng nêu sẵn quy tắc 7 (tiêu đề áp dụng cho các khoản) và quy tắc 8 («trừ» là ngoại lệ). Khớp ở hai điểm này phần lớn là do câu lệnh, không phải LLM tự hiểu luật.
- Khớp với bản tay không phải khớp với luật. Faithfulness vẫn chỉ được kiểm bằng người đọc.
- `consistentOn` ở đây rỗng về thông tin: không cặp norm nào có thể xung đột modality.

## Lần 2: Điều 5, 2026-11-18 (BỊ TỪ CHỐI bởi `check`)

- Câu lệnh đầu tiên cho Điều 5 chưa nói rõ chữ số của «nhánh». Câu trả lời `article5.llm.json` (sha256 `37065fd7699a46943bdd15c690aece8c1db99df45771efdef808b0021b8f0b02`) viết «Điều 5 khoản 9 nhánh (1)», «(2)» thay vì «(i)», «(ii)», nên `translate.py check` từ chối: 25 phát hiện, 21 là tham chiếu không phân tích được và 4 là hệ quả (khoản 9–12 không được tính tới vì tham chiếu của chúng bị loại). **Lỗi nằm ở câu lệnh của tôi** (ví dụ chỉ có «nhánh (i)», quy tắc không nói «số La Mã»), không chỉ ở LLM. Câu lệnh đã sửa (quy tắc 2 nêu «số La Mã thường, KHÔNG dùng chữ số») và có test giữ lại.
- Tệp bị từ chối được giữ nguyên làm bằng chứng; không sửa tay.
- Chẩn đoán trên bản sao tạm thời (không lưu), đổi máy móc «(1)» thành «(i)»: 0 phát hiện cấu trúc. Tức là phần còn lại (trích dẫn nguyên văn, atom, độ phủ khoản) không có lỗi máy bắt được. Đây không phải kết quả hợp lệ vì `check` đã từ chối tệp gốc.
- Điều đáng đọc trong nội dung (người đối chiếu cần quyết, chưa phải kết luận về luật):
  - Khoản 11 nhánh (i) «không có giấy phép hoặc không đăng ký»: LLM mã hóa là `rượu ∧ ¬(có giấy phép ∨ đã đăng ký)`, tức chỉ cấm khi thiếu **cả hai**, và tự ghi điều này vào `assumptions`. Cách đọc thông thường là thiếu **một** trong hai đã vi phạm (`¬giấy phép ∨ ¬đăng ký`). Hai cách đọc cho điều kiện khác nhau; đây là chỗ một người học luật phải quyết, không phải máy.
  - Khoản 10 nhánh (ii) «không bảo đảm chất lượng **và** không rõ nguồn gốc»: LLM đọc «và» theo nghĩa đen (cả hai) và ghi rõ cách đọc khác cũng có thể đúng.
  - Khoản 7 và khoản 11 nhánh (i) chỉ nói «rượu»: LLM mã hóa có thêm điều kiện «loại = rượu» và ghi lại; khớp với chữ của luật (và với phát hiện trước đó về C23).
  - Khoản 13 để vào `not_encoded` với lý do (dẫn chiếu luật khác); không bỏ lặng lẽ.
- Việc cần làm: nhắn lại cho LLM các phát hiện của `check` (vòng sửa lỗi bằng tay, tinh thần FR4) hoặc dán lại câu lệnh đã sửa, rồi lưu thành `article5.llm.json` mới; lần này tệp cũ nên đổi tên giữ lại (`article5.llm.rejected-1.json`).

## Lần 2b: Điều 5 sau một vòng sửa bằng tay, 2026-11-18

- Vòng sửa: người phụ trách gửi lại cho LLM phát hiện của `check` (chỉ «nhánh» phải dùng số La Mã) và lưu câu trả lời mới là `article5.llm.json` (sha256 `bc5feda9f6e12c89df2959c0427ea681e82ade640e1af5452acb8a206e67fedb`); tệp bị từ chối giữ ở `article5.llm.rejected-1.json`. So hai tệp (sau khi đổi máy móc «(1)» thành «(i)» ở tệp cũ): chỉ khác một câu trong `assumptions` (nhắc tới số nhánh). Tức vòng sửa chỉ đổi đúng chỗ được yêu cầu.
- `translate.py check`: không có phát hiện cấu trúc. Lean trên bản nháp: `pfindings` = 0; `analyzeReport`: consistentOn nhưng chỉ **5 cặp được kiểm, 185 cặp bỏ qua do khác act** và mọi norm đều là cấm, nên kết quả này gần như rỗng. LLM tạo 14 act, nhiều act chỉ có một norm.
- Đối chiếu một phần: `article5.gold.json` chỉ có 6 norm của Điều 5 mà bản tay đã mã hóa (khoản 3 ba act, khoản 9 hai nhánh, khoản 11 nhánh (ii)); 11 khoản/nhánh còn lại không có bản tay để so. `compare --relaxed`: 3 giống, 17 chỉ ở LLM, 3 chỉ ở bản tay. Đọc từng chênh lệch của 6 norm so được:

| Norm | Kết quả | Ghi chú |
|---|---|---|
| 5.3 (bán, cung cấp, khuyến mại, người chưa đủ 18 tuổi) | 3 giống | |
| 5.9 nhánh (i) | khác ở nguồn của atom | LLM dùng chung một atom «độ cồn từ 15 độ trở lên» cho khoản 7 và 9 và ghi nguồn là khoản 7; bản tay ghi khoản 9. Nội dung giống |
| 5.9 nhánh (ii) | khác tên act và atom | `dung_ruou_bia_de_khuyen_mai` so với `dung_ruou_bia_lam_qua_khuyen_mai`; LLM gộp «dùng để khuyến mại» và «≥15 độ» vào một atom. Chưa rõ có tương đương; người đối chiếu quyết |
| 5.11 nhánh (ii) | khác mức chia act | LLM: act `ban_ruou_bia` kèm atom «bán bằng máy»; bản tay: act riêng `ban_ruou_bia_bang_may_tu_dong`, điều kiện `true` (quyết định G7 của bản tay) |

- Chênh lệch có ý nghĩa nhất không nằm trong 6 norm so được mà ở khoản 11 nhánh (i): LLM mã hóa «không có giấy phép hoặc không đăng ký» là chỉ cấm khi thiếu cả hai (xem lần 2); bản tay không mã hóa nhánh này nên không có gì để so. Một người học luật cần quyết cách đọc.
- Giới hạn: một lần chạy cho mỗi điều; `compare` nhận atom theo nguồn nên bỏ sót trường hợp một atom dùng chung nhiều khoản; 17 norm chỉ ở LLM chưa được ai đối chiếu với luật.

## Chuẩn bị lần 3: Điều 15 (2026-11-18, chưa chạy)

Điều 15 có 5 khoản và 10 điểm (khoản 1: a–d; khoản 2, 3, 4: a–b), một dẫn chiếu trong điều («trừ trường hợp quy định tại khoản 3 Điều này», khoản 2) và một giao quyền cho Chính phủ (khoản 5). Trước khi dán, công cụ được sửa ba chỗ mà Điều 15 sẽ đụng phải:

1. **Lược đồ trong câu lệnh luôn ghi `"article": 19`** và ví dụ «Điều 19 khoản 1», dù dịch điều nào. Lần 1 (Điều 19) không lộ ra; lần 2 (Điều 5) LLM tự sửa đúng. Nay ví dụ dùng số của điều đang dịch.
2. **Không có chỗ ghi dẫn chiếu.** `Norm.references` có sẵn trong Lean (kiểm dẫn chiếu treo), nhưng lược đồ JSON không có trường này. Nay norm có trường `references` (tùy chọn); `check` đòi mỗi dẫn chiếu là một đơn vị có thật của luật (không «nhánh», không «tiêu đề»).
3. **Danh mục để kiểm dẫn chiếu treo chỉ có «Điều 1» … «Điều 36»**, nên một dẫn chiếu đúng tới «Điều 15 khoản 3» sẽ bị Lean báo treo. Nay danh mục trong bản nháp và module sinh ra gồm mọi điều, khoản, điểm (222 đơn vị) lấy từ văn bản đã tách; có test cho thấy Lean báo `danglingReference` với «Điều 15 khoản 9».

Thêm quy tắc 11: khi khoản liệt kê điều kiện («Điều kiện ... bao gồm:»), LLM phải ghi trong `assumptions` cách biểu diễn (được phép khi đủ mọi điểm, hay bắt buộc từng điểm). Đây là chỗ thật sự mở: Điều 15 nói điều kiện để **được cấp phép**, không nói thẳng «cấm» hay «bắt buộc».

- Câu lệnh: `prompt-article15.txt` (sha256 `3b41e23bc355f20cf87dfd1fc3c10869738e24620151a267d36a080629b6c1ee`).
- Câu lệnh của lần 1 và lần 2 giữ nguyên như lúc đã dùng; không sinh lại.
- **Level 2:** Nghị quyết 66.18/2026/NQ-CP «không thực hiện điều kiện quy định tại Điều 15» từ 01/7/2026 đến hết 28/02/2027. Bản dịch là của văn bản luật gốc; người duyệt cần biết điều này nhưng nó không đổi cách dịch.

## Lần 3: Điều 15, 2026-11-20 (qua `check`, chưa ai duyệt)

- Câu trả lời `article15.llm.json` (sha256 `98241e1293cf2b9b317ffa8915791493b801fe6dae50e8ad69b07ac02545e902`), dán một lần vào chat mới, **qua `check` ngay lần đầu** (không cần vòng sửa). Lean: `pfindings` = 0 khi gộp với Điều 5 và Điều 19; dẫn chiếu «Điều 15 khoản 3» của khoản 2 qua kiểm tra treo (nhờ danh mục đủ khoản và điểm, xem «Chuẩn bị lần 3»). Kết quả gộp: consistentOn, **vẫn 32 cặp được kiểm** như khi chỉ có Điều 5 và 19 (403 cặp bỏ qua do khác act), tức **Điều 15 không thêm cặp nào để kiểm**.
- Hai quy tắc mới của câu lệnh có tác dụng: LLM điền `references` (khoản 2 → «Điều 15 khoản 3») và ghi trong `assumptions` cách biểu diễn danh sách điều kiện (quy tắc 11).
- Norm: 4 norm, đều `permission` (khoản 1, 2, 4: «được cấp phép khi đủ mọi điểm»; khoản 3: được sản xuất để bán cho cơ sở chế biến lại khi đủ điểm a và b); khoản 5 vào `not_encoded` (giao Chính phủ). Khái niệm mở thành tham số: P1, P2, P3, P4, P5, P6.

Điểm người duyệt phải quyết (chưa phải kết luận về luật):

1. **«Điều kiện … bao gồm» là điều kiện cần, LLM mã hóa thành điều kiện đủ.** Norm nói «được phép khi đủ MỌI điểm». Chữ «bao gồm» nghĩa là các điểm là những điều kiện phải có; không nói đủ các điểm là được cấp phép (còn điều kiện ở nghị định, khoản 5). LLM tự ghi chiều ngược lại («thiếu một điểm thì không được cấp phép») không được mã hóa, nhưng cách gọi `permission` vẫn khẳng định nhiều hơn chữ của luật.
2. **Hành vi là «được cấp phép sản xuất…», không phải «sản xuất…».** Act `duoc_cap_phep_san_xuat_ruou_cong_nghiep` khác mọi act ở Điều 5 (`kinh_doanh_ruou_bia`, …), nên không cặp norm nào so được với lệnh cấm «kinh doanh rượu không có giấy phép» (Điều 5 khoản 11). Quan hệ có ý nghĩa (có giấy phép là tiền đề của việc được kinh doanh) **không được biểu diễn**. Muốn biểu diễn cần một atom «có giấy phép» dùng chung giữa hai điều (bảng thuật ngữ, FR2, chưa làm).
3. **«Điều kiện … theo quy định của pháp luật»** (thành lập, an toàn thực phẩm, đăng ký kinh doanh) thành tham số P1, P3, P4; LLM ghi đúng rằng dẫn chiếu văn bản khác không ghi vào `references`.
4. **Enum `loai_chu_the`** liệt kê 6 loại; LLM ghi nó không đầy đủ.
5. **Level 2:** Nghị quyết 66.18/2026/NQ-CP «không thực hiện điều kiện quy định tại Điều 15» từ 01/7/2026 đến hết 28/02/2027; bản dịch là của luật gốc.

Phiếu duyệt đã lập: `docs/review/duyet-ban-dich-dieu-15.md` (sha256 bản dịch trong phiếu).

## Ý kiến của người duyệt về bản dịch Điều 5 (2026-11-18)

Nguồn: `docs/review/ket-qua-doi-chieu-Phong-2026-11-18.md` (Vũ Đức Phong; ghi là **không xem bản nháp AI trước khi trả lời**; một người duyệt, chưa có ý kiến thứ hai).

| Điểm trong `article5.llm.json` | Cách đọc của LLM | Ý kiến người duyệt | Kết luận ghi nhận |
|---|---|---|---|
| Khoản 11 nhánh (i) «không có giấy phép hoặc không đăng ký» (Q1) | chỉ cấm khi thiếu **cả hai** (`¬(giấy phép ∨ đăng ký)`) | vi phạm khi thiếu **một trong hai**, «chắc» | **Bản dịch của LLM sai theo người duyệt.** LLM đã tự nêu cách đọc này trong `assumptions`, nên không bị giấu |
| Khoản 10 nhánh (ii) «không bảo đảm chất lượng và không rõ nguồn gốc» (Q2) | cần **cả hai** | cần cả hai, «chắc» | khớp |
| Khoản 3 «cung cấp» có gồm cho không (Q3) | bản dịch tách `cung_cap_ruou_bia` và dùng chung điều kiện «chưa đủ 18 tuổi» | gồm cả cho không, «chắc» | khớp với cách đọc của bản mã hóa tay và các ca C05, C07 |
| Khoản 7 và khoản 11 nhánh (i) chỉ nói «rượu» (Q7) | thêm điều kiện «loại = rượu» | bán bia không bị khoản 11 cấm, «chắc» | khớp |

Chưa đối chiếu được với bản dịch: khoản 9 nhánh (ii) (tên act và cách gộp atom), khoản 5 («ngay trước giờ làm việc» thành tham số), vì người duyệt không trả lời các điểm này.

Điều chưa giải quyết (không thuộc bước dịch): người duyệt cho rằng Nghị quyết 66.18/2026/NQ-CP «không thực hiện» quy định ở Điều 5 khoản 11 vế «không có giấy phép hoặc không đăng ký». Chưa kiểm chứng văn bản nghị quyết; quan hệ giữa hai văn bản thuộc Level 2 (CLAUDE.md), nên chưa ảnh hưởng đến việc ghi nhận bản dịch trên.
