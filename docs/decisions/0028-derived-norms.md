# ADR-0028: Norm suy ra — kiểm các điều điều chỉnh hai hành vi khác nhau

- **Status**: **Accepted** 2026-11-20 (người phụ trách dự án chọn hướng này thay cho «ràng buộc tình huống» và «ghi thành giới hạn»)
- **Trạng thái cài đặt**: bước 1 **Tested** (`pipeline/derived.py`, `run.py --derived`, `pipeline/tests/test_derived.py`, tệp `data/derived/44-2019-QH14.json` với 2 mục `proposed` do AI đề xuất). Bước 2 **Tested**: phiếu duyệt `derived.py sheet`/`apply`; phiếu trống `docs/review/duyet-norm-suy-ra-44-2019-QH14.md`. Đưa vào `promote.py`: chưa làm.
- **Ngày**: 2026-11-20
- **Liên quan**: [ADR-0004](0004-act-as-opaque-glossary-id.md), [ADR-0027](0027-glossary-shared-atoms.md) (bước 5, kết quả âm), [ADR-0025](0025-run-command-draft-path.md)

## Bối cảnh

ADR-0027 bước 5 cho thấy Điều 5 và Điều 15 không có act chung. Điều 5 khoản 11 cấm *người kinh doanh* kinh doanh rượu khi không có giấy phép; Điều 15 cấm *cơ quan* cấp phép khi thiếu điều kiện. Hai lệnh cấm, hai chủ thể: theo đúng chữ, chúng **không thể** khắc nhau ở Level 1, có bảng thuật ngữ hay không. Một ràng buộc giữa atom («được cấp phép ⇒ có giấy phép») chỉ loại bớt tình huống, không tạo được cặp khắc nhau.

Hai điều chỉ so được với nhau qua một **cách đọc** mà luật không viết thẳng, ví dụ «có giấy phép thì được kinh doanh rượu».

## Quyết định

1. **Norm suy ra là dữ liệu riêng**, mỗi văn bản một tệp `data/derived/<doc>.json`, không nằm trong bản dịch của một điều. Mỗi mục có các trường:
   - `id` (D1, D2, ...), `modality`, `act`, `condition`, `exceptions`; act và atom chỉ được dùng id của bảng thuật ngữ (ADR-0027);
   - `derived_from`: các đơn vị là căn cứ suy ra;
   - `reading`: cách suy ra, bằng lời;
   - `proposed_by`: ai đề xuất;
   - `status`, với `reviewed_by` và `reviewed_on` khi đã duyệt (cùng luật như bảng thuật ngữ).
2. **`pipeline/derived.py check`** kiểm cấu trúc của tệp: id, act và atom có trong bảng và không bị bác, nhãn đúng, nguồn có thật, có `reading` và `proposed_by`.
3. **`run.py --derived FILE` chạy Lean hai lần.**
   - Lần 1 chỉ trên các norm dịch từ chữ luật. Kết luận ở mục 1 của báo cáo chỉ đến từ lần này, và tệp norm suy ra không bao giờ đổi được nó.
   - Lần 2 thêm các norm suy ra, với id «SUY RA D1» để mọi báo cáo đều thấy norm nào không phải chữ luật. Kết quả lần 2 ghi riêng ở mục 5b: nêu từng cặp xung đột và cho biết cặp đó có dính norm suy ra không.
4. **Diễn giải.** Một cặp xung đột có dính norm suy ra nghĩa là: *nếu* đọc luật theo cách đó thì có tình huống hai norm khắc nhau. Đó là lý do để sửa cách đọc, thêm ngoại lệ, hoặc bác nó. Nó **không** phải bằng chứng luật mâu thuẫn.
5. **Lean không đổi.** Norm suy ra đi qua cùng `pfindings` và `analyzeReport`; không thêm giả định vào kernel, không đụng tới `Atoms.valid`.

## Kết quả đầu tiên (2026-11-20, các cách đọc chưa ai duyệt)

`run.py eval/translate/article5.glossary.llm.json eval/translate/article15.glossary.llm.json --derived data/derived/44-2019-QH14.json`:

- Lần 1, chỉ chữ luật: consistentOn, rỗng về thông tin (không đổi so với ADR-0027 bước 5).
- Lần 2, có norm suy ra: 8 cặp cùng act được kiểm, **3 cặp xung đột, cả 3 đều dính norm suy ra**.
  - D1 («có giấy phép thì được kinh doanh rượu») **không** xung đột với 5.11.i («cấm kinh doanh rượu khi không có giấy phép»). Đây là phép kiểm có nghĩa đầu tiên giữa Điều 5 và Điều 15, và cách đọc qua được nó.
  - D1 × 5.12.i.1: có giấy phép vẫn bị cấm kinh doanh rượu giả, nhập lậu, không bảo đảm chất lượng, không rõ nguồn gốc. Vậy D1 cần ngoại lệ cho các trường hợp của khoản 12, nếu không thì D1 nói nhiều hơn luật.
  - D2 × 5.11.i: đọc «Điều kiện cấp phép … bao gồm» (Điều 15 khoản 4) là điều kiện đủ thì có tình huống đủ điều kiện nhưng chưa có giấy phép: được phép theo D2, bị cấm theo Điều 5 khoản 11. Như vậy công cụ **bác được** cách đọc của bản dịch lần 3: đủ điều kiện cấp phép không phải là có giấy phép.
  - D2 × 5.12.i.1: cùng lý do với D1.

Đây là kết quả trên bản dịch chưa ai duyệt và trên cách đọc do AI đề xuất. Nó cho thấy cách làm có tác dụng; nó chưa phải kết luận về luật.

## Rủi ro

- **Cách đọc sai được đưa vào như thể là luật.** Có ba lớp chặn: id «SUY RA», mục 5b riêng của báo cáo, và kết luận chính không đổi. Nhưng một người chỉ đọc lướt vẫn có thể nhầm.
- **Cách đọc quá yếu làm mất xung đột.** Chỉ người duyệt nhìn ra được, giống `valid` (trust base).
- Cách đọc là chỗ ý kiến của người duyệt có trọng lượng lớn nhất; một người duyệt chưa đủ cho các mục gây tranh cãi (như Q5).

## Bước 2: phiếu duyệt (2026-11-20)

- `derived.py sheet FILE -o SHEET.md`: mỗi mục `proposed` một hàng (`D:D1`). Hàng ghi tính chất, hành vi, điều kiện và ngoại lệ bằng lời, «Suy ra từ», cách suy ra và người đề xuất. Ba lựa chọn Chấp nhận / Bác / Để sau; bác thì phải ghi lý do.
  - Mục 0 liệt kê các thuật ngữ mà norm suy ra dùng, kèm trạng thái duyệt của chúng.
  - Phiếu ghim sha256 của **cả** tệp norm suy ra **và** bảng thuật ngữ, vì nghĩa của norm phụ thuộc vào nghĩa của các id.
- `derived.py apply FILE SHEET`: từ chối phiếu thiếu hàng, thiếu tên hoặc ngày, đánh dấu sai, bác không lý do, hoặc khi một trong hai sha256 đã đổi; khi từ chối thì không ghi gì.
  - Khi nhận, mỗi mục được quyết có thêm `reviewed_content_sha256`: sha256 của nội dung mục lúc duyệt (mọi trường, trừ các trường duyệt).
- **Khác bảng thuật ngữ:**
  - `check` báo finding khi một mục `approved` hoặc `rejected` không có `reviewed_content_sha256` (tức trạng thái được ghi tay, không qua phiếu).
  - `check` cũng báo khi nội dung đã đổi sau khi duyệt, ví dụ thêm ngoại lệ cho D1. Một cách đọc đã sửa không còn là cách đọc đã được duyệt.
  - Bảng thuật ngữ chưa có chốt này; nên thêm nếu dùng thật.

## Chưa làm

- Đưa norm suy ra đã duyệt vào `promote.py`: một module có `derived` riêng và định lý riêng cho `norms ++ derived`.
- Ngoại lệ cho D1 theo khoản 12, nếu người duyệt chấp nhận hướng đó.
