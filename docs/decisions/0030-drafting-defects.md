# ADR-0030: Dấu hiệu lỗi soạn thảo — norm chết, norm thừa, ngoại lệ không kích hoạt

- **Status**: **Accepted** 2026-11-25 (người phụ trách dự án chọn mở rộng phạm vi Level 1 ở mức Should)
- **Trạng thái cài đặt**: **Implemented**. Lõi `LexProof/Verify/Drafting.lean`, test `Verify/DraftingTests.lean`; công cụ
  `pipeline/drafting.py`, test `pipeline/tests/test_drafting.py`; module `LexProof/Laws/Law44Drafting.lean`; mục 6 của
  báo cáo `report.py --module law44`. Yêu cầu: FR14.
- **Ngày**: 2026-11-25
- **Liên quan**: [ADR-0029](0029-act-entailment-edges.md); thử nghiệm E6, E8 trong [`eval/entailment/`](../../eval/entailment/README.md)

## Bối cảnh

Kết quả nhất quán của `Law44` rỗng về thông tin: không act nào mang hai modality khắc nhau. Một phép kiểm chỉ có giá
trị khi nó **có thể thất bại**. Ba lỗi soạn thảo trong một văn bản có thể thất bại thật trên luật này, kể cả khi luật
chỉ có cấm và bắt buộc: một norm không bao giờ áp dụng, một norm bị norm khác bao trùm, một ngoại lệ không bao giờ kích
hoạt (Feng và cs., N-Check, định nghĩa «thừa» theo cùng cách). Phạm vi Level 1 cũ chỉ gồm xung đột và tham chiếu treo,
nên đây là mở rộng phạm vi.

## Quyết định

1. **Báo riêng, mức Should (FR14).** Không phải xung đột, không đổi kết luận nhất quán, có mục riêng trong báo cáo.
2. **Mục «sạch» là mệnh đề tồn tại, chứng minh bằng chứng nhân.** `Live`, `NotSubsumed`, `ExcFires` đều có dạng «có một
   tình huống mà…». Công cụ Python (không tin cậy) tìm một tình huống cho từng mục; `checkLive`, `checkNotSubsumed`,
   `checkExcFires` kiểm các chứng nhân bằng `decide`; `live_of_check`, `notSubsumed_of_check`, `excFires_of_check` nâng
   kết quả `true` thành định lý cho mọi norm (cặp, ngoại lệ). Kernel chỉ kiểm từng điểm, không duyệt cả miền.
3. **Chứng nhân ở dạng thô.** Hai danh sách chỉ số giá trị, đọc bằng `decodeVal`. `decodeVal` từ chối danh sách không hợp
   lệ, nên chứng nhân sai làm phép kiểm thất bại. Dạng `Valuation` kèm chứng minh trong từng chứng nhân làm bộ soạn hết
   ngân sách nhịp (thử 2026-11-25).
4. **Fail closed.** Mục không tìm được chứng nhân vào danh sách `skip` của module (`liveSkip`, `subSkip`, `excSkip`) và
   danh sách `unknown` có lý do. Định lý loại đúng các mục đó. Báo cáo ghi chúng là «không biết». Hệ thống **không bao giờ**
   khẳng định một norm chết hay thừa: điều đó cần một chứng minh «với mọi tình huống» (dựa trên phép chiếu theo atom của
   `Verify/ProjectedCheck.lean`), chưa làm.
5. **Bộ tìm có giới hạn.** Duyệt các atom mà điều kiện dùng, tối đa 65 536 điểm cho một mục; vượt thì mục đó là «không biết».

## Kết quả đầu tiên (`Law44`, 2026-11-25)

- 73/73 norm có chứng nhân sống; 322 cặp cùng hành vi, cùng tính chất có chứng nhân không bao trùm; 5/6 ngoại lệ có
  chứng nhân kích hoạt. Kernel kiểm module trong khoảng 80 giây.
- **1 mục «không biết»: ngoại lệ của norm 15.2** (Điều 15 khoản 2, bản dịch cũ không theo bảng thuật ngữ).
  - Điều kiện của 15.2 đòi chủ thể là doanh nghiệp, hợp tác xã, liên hiệp hợp tác xã hoặc hộ kinh doanh.
  - Ngoại lệ («trừ trường hợp quy định tại khoản 3») đòi chủ thể là hộ gia đình hoặc cá nhân.
  - Bản mã hóa dùng **một** atom `loai_chu_the` cho cả hai, nên hai tập rời nhau và ngoại lệ không bao giờ kích hoạt.
  - Hai cách giải thích, người duyệt phải chọn: (a) bản mã hóa sai khi coi «hộ kinh doanh» và «hộ gia đình, cá nhân» rời
    nhau (một hộ gia đình có thể đăng ký hộ kinh doanh); (b) chữ «trừ trường hợp quy định tại khoản 3» của luật thừa, vì
    danh sách chủ thể ở khoản 2 đã loại khoản 3.
  - Trước khi có người quyết, đây chỉ là dấu hiệu, không phải lỗi của luật.
  - **Người duyệt (Vũ Đức Phong) chọn (a)**, 2026-11-25, trả lời bằng tin nhắn: «xuất hiện trùng nhau giữa hộ gia đình,
    cá nhân và hộ kinh doanh». Sau đó người duyệt nói rõ thêm (cùng ngày): hộ gia đình đã đăng ký hộ kinh doanh được tính
    là hộ kinh doanh, tức hai nhóm **tách nhau**. Vậy câu hỏi (a)/(b) đặt sai chỗ: lỗi của bản mã hóa cũ là đưa danh sách
    chủ thể của khoản 2 (điểm a) vào phạm vi của norm, trong khi luật ghi nó là **một điều kiện cấp phép**. Bản dịch theo
    bảng thuật ngữ đặt nó vào điều kiện; khi đó ngoại lệ «trừ khoản 3» có tác dụng (loại hộ gia đình, cá nhân của khoản 3
    khỏi lệnh cấm cấp phép) dù hai nhóm tách nhau. Kết luận vẫn là: lỗi của bản mã hóa, không phải của luật.
  - Lần 2 (`docs/review/duyet-ban-dich-dieu-15-lan-2.md`) bị bác hai giả định (A:3, A:5). Lần 3
    (`eval/translate/article15.glossary-2.llm.json`, phiếu `docs/review/duyet-ban-dich-dieu-15-lan-3.md`, cùng phiếu bảng
    thuật ngữ `-5` cho một act mới) theo các câu trả lời của người duyệt; khi được duyệt, `Article15` và `Law44` được promote lại.
  - **Kết quả sau lần 3** (cả hai phiếu được chấp nhận đủ, 2026-11-25): `Law44` có 77 norm; `Law44Drafting`: 77/77 norm
    sống, 322 cặp không bao trùm, 6/6 ngoại lệ kích hoạt, **0 «không biết»**. `Law44.consistent` không còn rỗng: 4 act của
    Điều 15 có cả lệnh cấm lẫn quyền.
- So với thử nghiệm E8 (Python, chỉ 14 bản dịch theo bảng thuật ngữ, không có Điều 15): E8 báo 0. Mục này chỉ hiện khi gộp
  cả Điều 15.

## Rủi ro

- **«Thừa» không phải lỗi.** Luật có khi cố ý nhắc lại một quy tắc. Báo cáo ghi rõ điều này.
- **Chỉ nói về phần đã mã hóa và cách mã hóa.** Một mục «không biết» có thể do bản mã hóa (như trường hợp 15.2), không do luật.
- **Bỏ qua `Atoms.valid`.** Các module `Laws` hiện không dùng ràng buộc toàn vẹn; nếu sau này có, một chứng nhân có thể là
  tình huống mà `valid` loại. Lúc đó phải thêm điều kiện `valid` vào phép kiểm.
