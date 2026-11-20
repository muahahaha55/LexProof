# ADR-0027: Bảng thuật ngữ dùng chung cho act và atom (FR2) — phác thảo

- **Status**: **Proposed** (chưa quyết, chưa có code)
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

## Câu hỏi để quyết

- Bảng theo **văn bản** (đề xuất) hay dùng chung **nhiều văn bản** (gần Level 2)?
- Ai duyệt bảng: cùng người duyệt norm hay người khác?
- Mức chi tiết act: «bán», «cung cấp», «khuyến mại» là ba act (như bản tay, G7) hay một act với atom «hình thức»?
