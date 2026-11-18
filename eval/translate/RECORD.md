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
