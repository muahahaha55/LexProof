# ADR-0027: Bảng thuật ngữ dùng chung cho act và atom (FR2) — phác thảo

- **Status**: **Accepted** 2026-11-20 (người phụ trách dự án; ba câu hỏi đã trả lời ở mục cuối)
- **Trạng thái cài đặt**: bước 1 **Tested** (`pipeline/glossary.py`, `pipeline/tests/test_glossary.py`, bảng hạt giống `data/glossary/44-2019-QH14.json`, mọi mục `proposed`); bước 2 **Tested** (`translate.py prompt --glossary`, `check` chế độ bảng, `unapproved_terms`; xem «Bước 2 đã làm»); bước 3 **Tested** (`materialize`, `run.merge` theo id, chặn ở `promote.py`; xem «Bước 3 đã làm»); bước 4 **Tested** (`glossary.py sheet`/`apply`, phiếu trống `docs/review/duyet-bang-thuat-ngu-44-2019-QH14.md`; xem «Bước 4 đã làm»); bước 5 **đã đo, kết quả âm** (xem «Bước 5: kết quả» và `eval/translate/RECORD.md` «Lần 4»). Bảng đã được duyệt 2026-11-21 (xem «Kết quả duyệt»)
- **Ngày**: 2026-11-20
- **Liên quan**: FR2, [ADR-0004](0004-act-as-opaque-glossary-id.md) (act là id mờ), [ADR-0024](0024-translation-manual-paste.md), [ADR-0025](0025-run-command-draft-path.md), [ADR-0026](0026-promote-reviewed-translation.md)

## Bối cảnh: vì sao cần

Hiện mỗi bản dịch tự đặt tên act và atom, và khi gộp các điều (`run.py`, `promote.py`) mọi atom bị gắn tên điều («Điều 5 · …») để không gộp nhầm. Hệ quả đo được (`eval/translate/RECORD.md`):

- Điều 15 dùng act `duoc_cap_phep_san_xuat_ruou_cong_nghiep`, Điều 5 dùng `kinh_doanh_ruou_bia`: **không cặp norm nào so được**, nên việc thêm Điều 15 không thêm phép kiểm nào (vẫn 32 cặp). Quan hệ «có giấy phép» giữa lệnh cấm ở Điều 5 khoản 11 và điều kiện cấp phép ở Điều 15 không được biểu diễn.
- Cùng một khái niệm («độ cồn từ 15 độ trở lên», «địa điểm là cơ sở y tế») có tên khác nhau ở mỗi bản dịch và ở bản mã hóa tay, nên `compare` phải đoán theo nguồn.
- Điều 5 có 14 act cho 20 norm; `consistentOn` gần như rỗng vì phần lớn cặp khác act.

Một kiểm tra *trong một văn bản* chỉ có nghĩa khi các điều nói cùng một thứ bằng cùng một tên.

## Phương án đề xuất

**1. Một tệp thuật ngữ cho mỗi văn bản**, ví dụ `data/glossary/44-2019-QH14.json`, là dữ liệu (không phải code), được người duyệt:

```json
{ "doc_id": "44/2019/QH14",
  "acts":  [ { "id": "kinh_doanh_ruou", "gloss": "mua bán, sản xuất rượu để kiếm lời",
               "sources": ["Điều 5 khoản 11 nhánh (i)", "Điều 15"], "status": "approved" } ],
  "atoms": [ { "id": "co_giay_phep_kinh_doanh_ruou", "kind": "situation", "domain": "bool",
               "gloss": "chủ thể có giấy phép kinh doanh rượu còn hiệu lực",
               "sources": ["Điều 5 khoản 11 nhánh (i)", "Điều 15 khoản 4"], "status": "approved" },
             { "id": "do_con", "kind": "situation",
               "domain": [ {"label": "dưới 5,5 độ", "source": "Điều 15 khoản 5"},
                           {"label": "từ 5,5 đến dưới 15 độ", "source": "Điều 13"},
                           {"label": "từ 15 độ trở lên", "source": "Điều 5 khoản 9"} ],
               "status": "approved" } ] }
```

**2. Bản dịch dùng id của bảng.** Câu lệnh liệt kê các mục đã duyệt (id + giải thích). Trong JSON dịch, `{"sit": "co_giay_phep_kinh_doanh_ruou"}` chỉ tới mục bảng; thuật ngữ mới phải ghi vào một phần riêng `glossary_proposals` (id, gloss, nguồn), không được tự dùng.

**3. Chặn thuật ngữ chưa duyệt (AC của FR2).** `check` cho phép đề xuất nhưng `promote.py` từ chối mọi norm dùng act hoặc atom có `status` khác `approved`. `run.py` vẫn chạy bản nháp nhưng báo rõ các thuật ngữ chưa duyệt.

**4. Gộp theo id.** Atom của bảng không bị gắn tên điều: cùng id ở hai điều là **một** atom. Atom riêng của một điều (chưa vào bảng) vẫn gắn tên điều như hiện nay. Nhờ vậy Điều 5 và Điều 15 có thể dùng chung `co_giay_phep_kinh_doanh_ruou` và cùng act.

**5. Phiếu duyệt thuật ngữ** (cùng kiểu phiếu của ADR-0026, ghim sha256 bảng): mỗi mục một hàng «Chấp nhận / Bác», kèm lý do. Duyệt bảng đi trước duyệt norm dùng bảng.

**6. Lean không đổi.** `Core` giữ nguyên; bảng chỉ quyết định tên và cách gộp atom trước khi sinh bảng atom của module. Không thêm giả định vào kernel.

## Rủi ro

- **Gộp nhầm**: hai khái niệm khác nhau chung một id che mất khác biệt (ví dụ «kinh doanh» và «bán»). Chỉ người duyệt bảng chặn được; công cụ chỉ bắt được miền giá trị không khớp.
- **Ngưỡng số**: các điều dùng ngưỡng khác nhau (15 độ ở Điều 5, 5,5 độ ở Điều 12 và 15). Một atom độ cồn chung phải là enum gồm các dải tách nhau; đã có `Core/NumericBands.lean` (`tiles`) để kiểm các dải nối liền.
- **Quan hệ giữa act** («bán» là một dạng «kinh doanh») không biểu diễn được bằng id mờ (ADR-0004). Ngoài phạm vi phác thảo này; ghi thành giới hạn.
- **Các bản dịch đã có** (Điều 5, 15, 19) đặt tên riêng; cần một bước ánh xạ tên cũ sang id của bảng, cũng phải được duyệt.

## Các bước nếu chấp nhận (mỗi bước nhỏ, có test)

1. Lược đồ bảng thuật ngữ và `check` của nó; một bảng hạt giống lấy từ atom của `AlcoholSale.lean` (trạng thái `proposed`).
2. Câu lệnh dịch liệt kê bảng; lược đồ dịch có `glossary_proposals`.
3. `run.py`/`promote.py` gộp theo id; `promote.py` chặn thuật ngữ chưa duyệt.
4. Phiếu duyệt thuật ngữ.
5. Thử lại Điều 5 + Điều 15 với act và atom chung, đo số cặp được kiểm tăng bao nhiêu.

## Bước 4 đã làm (2026-11-20)

- `glossary.py sheet FILE -o SHEET.md`: mỗi mục `proposed` một hàng (`T:act:<id>`, `T:atom:<id>`), ba lựa chọn Chấp nhận / Bác / **Để sau**; lý do bắt buộc khi bác.
  - Phiếu ghim sha256 của bảng; các mục đã quyết được liệt kê riêng, chỉ để đọc.
  - Vì phiếu chỉ gồm mục `proposed`, duyệt được theo **từng đợt**: mục mới (ví dụ đề xuất từ bản dịch) vào đợt sau.
- `glossary.py apply FILE SHEET`: từ chối nếu phiếu thiếu hàng, thiếu người duyệt hoặc ngày, đánh dấu sai, bác không lý do, hoặc sha256 khác bảng hiện tại. Khi từ chối thì không ghi gì vào bảng.
  - Khi nhận: ghi `status`, `reviewed_by`, `reviewed_on`, và `review_note` nếu có lý do. Mục «Để sau» giữ `proposed`, chỉ thêm `review_note`.
  - Chạy lại `check` trước khi ghi.
- Đây là cách duy nhất công cụ đổi trạng thái của một mục. Công cụ không kiểm ai là người duyệt.
- Trong lúc làm bước này phát hiện một lỗi ở `promote.ticked`: một lựa chọn rỗng (ô kết thúc bằng `<br>`) bị tính là đã đánh dấu.
  - Ô «☐ Chấp nhận<br>» bị đọc thành «Bác». Đã sửa và có test.
  - Các phiếu đã nộp (nhánh `phong-review-law`) không có ô như vậy.

## Bước 5: kết quả (2026-11-20)

- Quy trình: dịch Điều 5 với bảng; `glossary.py adopt` chép đề xuất vào bảng (vẫn `proposed`); dịch Điều 15 với bảng đã mở rộng; chạy `run.py` trên hai tệp. Cả hai bản dịch qua `check` ngay lần đầu.
- **Số cặp được kiểm không tăng:** 5 cặp khi không dùng bảng, **3 cặp** khi dùng bảng. Hai điều không có act chung, và kết quả vẫn rỗng về thông tin.
- Lý do: Điều 5 khoản 11 (cấm kinh doanh khi không có giấy phép) và Điều 15 (điều kiện để cơ quan *cấp* giấy phép) điều chỉnh hai hành vi khác nhau. Chúng nối với nhau qua một quan hệ giữa các mệnh đề, không qua một act chung.
- Bảng thuật ngữ đúng là không giải quyết được việc này. Đây là giới hạn «quan hệ giữa act» đã ghi ở mục Rủi ro.
- Bảng có tác dụng khi nhiều điều điều chỉnh cùng một hành vi (Điều 5 khoản 3 và Điều 19, cùng `ban_ruou_bia`). Bảng cũng làm lộ ra một rủi ro có thật: hai atom độc lập cho cùng độ cồn (`do_con`, `do_con_nguong_5_5`).
- Hệ quả cho lộ trình: muốn kiểm Điều 5 với Điều 15 thì cần **quy tắc nối** giữa các mệnh đề, ví dụ «được cấp phép ⇒ có giấy phép». Đó là thay đổi ở `Core`, chưa đề xuất ở đây; nếu làm thì cần một ADR riêng.

## Câu hỏi đã quyết (2026-11-20)

- Bảng **theo từng văn bản**.
- Người duyệt bảng: **Phong** (cùng người duyệt norm).
- «bán», «cung cấp», «khuyến mại» là **ba act riêng** (giữ G7 của bản mã hóa tay).

Bước 1 thêm một quy tắc chưa có ở trên: một nhãn của enum mà không khoản nào nêu (ví dụ phần bù «từ đủ 18 tuổi trở lên») phải có `note` giải thích, không được thiếu nguồn mà im lặng.

## Bước 2 đã làm (2026-11-20)

- Bản dịch bật chế độ bảng bằng khóa `"glossary": "data/glossary/44-2019-QH14.json"` (đúng một bảng cho mỗi văn bản; đường dẫn khác bị từ chối).
- Ở chế độ này `atoms` phải rỗng: mọi `act`, `sit`, `param` là id của bảng (trừ mục `rejected`) hoặc id trong `glossary_proposals`. Đề xuất được kiểm như mục của bảng (gloss, nguồn có thật, `note` cho nhãn không nguồn), không được ghi `status`, không được trùng id của bảng.
- Không có khóa `glossary` thì mọi thứ như trước (Điều 5, 15, 19 đã dịch vẫn qua `check`; câu lệnh mặc định không đổi).
- `check` in danh sách thuật ngữ đang dùng mà chưa `approved`. Việc **chặn** ở `promote.py` là bước 3.
- (Cho tới bước 3, `lean`, `run.py` và `promote.py` từ chối bản dịch dùng bảng. Bước 3 bỏ chặn này.)
- Bản dịch không ghim sha256 của bảng: nếu bảng đổi sau khi dịch, `check` dùng bảng mới. Phiếu norm ghim nó (bước 3).

## Bước 3 đã làm (2026-11-20)

- `translate.materialize`: bản dịch dùng bảng thành dạng thường. Chỉ atom mà norm dùng mới vào bảng atom (giữ thứ tự của bảng), tên là id, đánh dấu `shared`.
  - Lean cần một nguồn đọc được cho mỗi atom và mỗi nhãn, nên lấy nguồn đầu tiên. Nhãn chỉ có `note` thì lấy nguồn đầu tiên của atom.
  - Phần bị lược (các nguồn khác, ghi chú, giải thích, trạng thái) được in ở đầu bản nháp và đầu module («Glossary terms used», kèm sha256 bảng).
- `run.merge`: atom `shared` giữ id và chỉ xuất hiện **một lần** dù nhiều điều dùng; atom riêng vẫn gắn tên điều.
  - `run.admit` và `promote.py` từ chối tệp khi cùng một id có loại hoặc nhãn khác nhau giữa hai điều (hai đề xuất cùng id), hoặc hai điều dùng hai phiên bản bảng.
- Một đề xuất đã được chép vào bảng (cùng id, cùng loại và nhãn) được thay bằng mục của bảng, nên bản dịch không phải sửa.
- **Chặn (AC của FR2)**: `promote.py` tính thuật ngữ trên các norm *được chấp nhận*. Còn một act hay atom chưa `approved` (kể cả đề xuất) thì từ chối và liệt kê chúng.
- Phiếu norm của bản dịch dùng bảng có mục «0. Thuật ngữ bản dịch dùng» (chỉ để đọc) và dòng `sha256 bảng thuật ngữ`. Bảng đổi sau khi lập phiếu thì phiếu bị từ chối.
  - Hệ quả: duyệt thêm một mục bảng làm mọi phiếu norm đã lập trước đó hết hiệu lực. Vì vậy duyệt bảng trước, rồi mới lập phiếu norm.
- Test cho thấy tác dụng: «được phép khi KHÔNG phải cơ sở y tế» (Điều 5, thử) và 19.1 «cấm ở cơ sở y tế».
  - Với atom chung, Lean cho `consistentOn`. Với atom riêng của từng điều, Lean báo xung đột giả (`test_sharing_removes_a_spurious_conflict`).
- Còn hở: bản dịch không dùng bảng vẫn qua `promote.py` với atom riêng. Chưa bắt buộc dùng bảng, vì sẽ chặn các bản dịch Điều 5, 19 đang chờ duyệt.

## Câu hỏi ban đầu

- Bảng theo **văn bản** (đề xuất) hay dùng chung **nhiều văn bản** (gần Level 2)?
- Ai duyệt bảng: cùng người duyệt norm hay người khác?
- Mức chi tiết act: «bán», «cung cấp», «khuyến mại» là ba act (như bản tay, G7) hay một act với atom «hình thức»?

## Kết quả duyệt (2026-11-21)

Phong duyệt cả 61 mục qua `glossary.py apply`: chấp nhận 60, bác 1.

- Bác `co_giay_phep_hoac_dang_ky_kinh_doanh_ruou` («có giấy phép **hoặc** đã đăng ký»), lý do: «thiếu một trong hai đã vi phạm». Quyết định này khớp với việc Phong bác N:5.11.1 và A:13 ở phiếu Điều 5. Ở lần điền đầu, Phong chấp nhận mục này; khi được hỏi lại về chỗ mâu thuẫn, Phong đổi thành bác.
- Hệ quả: bản dịch Điều 5 lần 4 (`eval/translate/article5.glossary.llm.json`) không còn qua `check`, vì norm 5.11.i dùng mục đã bị bác. Điều 5 phải dịch lại, có hay không có bảng.
- «Đã duyệt» nghĩa là một người đã tick đủ phiếu. Nó không chứng minh các giải thích đúng luật, và một người duyệt chưa đủ cho các mục gây tranh cãi như mục bị bác ở trên.
