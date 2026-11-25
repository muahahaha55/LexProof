# ADR-0029: Cạnh kéo theo giữa các hành vi, duyệt theo nhu cầu; module gộp được kernel chứng minh

- **Status**: **Accepted** 2026-11-25 (người phụ trách dự án chọn hướng này sau các thử nghiệm E1–E9, xem «Bằng chứng»)
- **Trạng thái cài đặt**:
  - Lõi Lean **Implemented**: `LexProof/Verify/Entail.lean` (`Edge`, `derive`, `derive_sound`, `conflict_derived_meaning`), test `Verify/EntailTests.lean`.
  - Module gộp **Implemented**: `LexProof/Laws/Law44.lean` (15 điều, 73 norm), có `covers_articles` và `covers_articles_source`.
  - Công cụ **Tested**: `pipeline/edges.py` (check, draft, sheet, apply, module), `pipeline/tests/test_edges.py`.
  - Báo cáo **Tested**: `report.py --module law44` (chỉ `draft`), `pipeline/report_promoted.py`.
  - Dữ liệu: `data/edges/44-2019-QH14.json`, 13 cạnh `proposed` do AI đề xuất, **chưa ai duyệt**; phiếu cho E9, E10: `docs/review/duyet-canh-keo-theo-44-2019-QH14.md`.
  - Nhiều cách đọc **Tested**: `pipeline/readings.py`, `data/readings/44-2019-QH14.json` (R1, R2 do AI đề xuất), `pipeline/tests/test_readings.py`.
- **Ngày**: 2026-11-25
- **Liên quan**: [ADR-0026](0026-promote-reviewed-translation.md), [ADR-0027](0027-glossary-shared-atoms.md), [ADR-0028](0028-derived-norms.md)

## Bối cảnh

`Conflict` chỉ so hai norm có **cùng id act**. Trên 15 điều đã duyệt, không act nào mang hai modality khắc nhau, nên
mọi kết quả «nhất quán» đều rỗng. Thử nghiệm gieo lỗi (E2, E5) cho thấy một xung đột nằm giữa hai hành vi khác tên mà
kéo theo nhau thì không bao giờ hiện ra. Định nghĩa chuẩn trong tài liệu (Kelsen, Vranes; Robaldo & Pozzato 2024;
T-NORM của Fornara và cs. 2021) là: hai norm xung đột khi **tuân thủ norm này kéo theo vi phạm norm kia**. Định nghĩa
này bao cả trường hợp hành vi bị bắt buộc cụ thể hơn hành vi bị cấm.

## Quyết định

1. **Cạnh là dữ liệu riêng**, mỗi văn bản một tệp `data/edges/<doc>.json`. Mỗi cạnh có `id` (E1, …), `src`, `dst` (id act
   của bảng thuật ngữ), `source` (đơn vị luật làm căn cứ), `reading` (bằng lời), `proposed_by` và trạng thái duyệt. Luật
   duyệt giống norm suy ra (ADR-0028): chỉ `apply` ghi trạng thái, kèm sha256 nội dung lúc duyệt.
2. **Phép suy ra nằm trong Lean**, không trong Python. Lệnh cấm trên `dst` sinh lệnh cấm trên `src`; nghĩa vụ trên `src`
   sinh nghĩa vụ trên `dst`; quyền không được truyền. Norm suy ra mang cạnh trong id («SUY RA [A ⇒ B] …»).
   - `derive_sound`: mọi norm suy ra đến từ một norm đầu vào, cùng modality, điều kiện, ngoại lệ, ưu tiên; ai tôn trọng
     các cạnh mà tuân thủ norm gốc thì cũng tuân thủ norm suy ra.
   - `conflict_derived_meaning`: một `Conflict` với norm suy ra nghĩa là norm gốc áp dụng ở đó, và không ai tôn trọng các
     cạnh lại vừa làm theo norm thứ nhất vừa tuân thủ norm gốc.
3. **Kết quả có dùng cạnh không bao giờ đổi kết luận về chữ luật.** Nó được báo riêng (mục 5 của báo cáo `law44`), ghi
   rõ là về cách đọc.
4. **Duyệt theo nhu cầu.** `edges.py draft` chạy Lean với mọi cạnh chưa bị bác và liệt kê các cạnh nằm trên đường dẫn
   tới một cặp xung đột. Người duyệt quyết các cạnh đó trước (`edges.py sheet --ids …`). Một cạnh không nằm trên đường
   xung đột nào, đúng hay sai, không đổi kết quả. Một cạnh sai mà sinh xung đột thì tự lộ ra trong danh sách phải duyệt.
5. **Chỉ cạnh `approved` vào thư viện**: `edges.py module` viết một module `Laws` riêng với định lý kernel
   (`consistent` hoặc `has_conflict`) trên `norms ++ derive edges norms`.
6. **Module gộp.** `promote.py promote` nhận nhiều cặp (bản dịch, phiếu) cùng một người duyệt (các ngày có thể khác
   nhau; `status` mang ngày mới nhất). `--covers` thêm định lý rằng danh sách norm gộp đúng bằng norm của các module
   từng điều. Định lý so id, modality, act, nguồn, tham chiếu và số ngoại lệ, **không** so điều kiện.
7. **Phiếu duyệt bản dịch không mất hiệu lực khi bảng thuật ngữ chỉ thêm mục.** Phiếu ghim sha256 của cả bảng. Khi
   sha256 khác, `promote.py` tìm phiên bản bảng mang sha256 đó trong lịch sử git. Nếu mọi thuật ngữ bản dịch dùng có cùng
   nghĩa (id, kind, domain, gloss, sources) ở hai bảng, phiếu được dùng tiếp và module ghi rõ điều này. Nếu một thuật
   ngữ đã đổi, hoặc không tìm thấy phiên bản, phiếu bị từ chối như trước.

## Bằng chứng (thử nghiệm 2026-11-25, chi tiết và script ở [`eval/entailment/`](../../eval/entailment/README.md))

- E1: kernel chứng minh `consistent` trên 69 norm của 14 điều trong 195 giây. Module `Law44` với 73 norm và hai định lý
  `covers_*` build trong khoảng 330 giây.
- E2, E5: gieo lỗi trên luật thật. Đổi modality cùng act: bắt 23/23. Điều kiện phủ định: 0/23 báo nhầm. Ca khác act mà
  là xung đột theo định nghĩa kéo theo: 0/3 khi không có cạnh, 3/3 khi có cạnh. Nhãn «nên bắt» ở E5 tính từ chính các cạnh,
  nên E5 chỉ chứng tỏ Lean thực hiện đúng ngữ nghĩa của cạnh.
- E4: 14 cạnh (13 của AI và 1 cạnh cố ý sai làm đối chứng). Chỉ 2 cạnh thật nằm trên đường xung đột; cạnh sai tự lộ ra
  với 16 cặp xung đột vô lý.
- E7: ứng viên Điều 32 khoản 4 × Điều 5 khoản 12 chỉ đứng khi đọc lệnh cấm tàng trữ, vận chuyển theo đúng chữ; nó mất khi
  đọc lệnh cấm là chỉ nhắm việc kinh doanh, hoặc khi thừa nhận ngoại lệ ngầm cho việc thu hồi.
- Kernel chứng minh `has_conflict` trên `Law44` cộng hai cạnh thu hồi trong 43 giây.

## Rủi ro

- **Cạnh sai được đọc như luật.** Có ba lớp chặn: id «SUY RA [A ⇒ B]», mục riêng của báo cáo, và kết luận chính không đổi.
- **Cạnh thiếu che xung đột thật.** Duyệt theo nhu cầu không nhìn thấy cạnh chưa ai đề xuất; chỉ một người đọc luật đề
  xuất thêm cạnh mới bù được.
- **Xung đột qua cạnh vẫn có thể được luật giải quyết ngầm** (luật riêng thắng luật chung, mục đích của điều luật).
  Báo cáo phải gọi nó là «khoảng trống ưu tiên cần người quyết», không phải «luật mâu thuẫn».
- **Một người duyệt** cho cả bản dịch lẫn cạnh.

## Chưa làm

- Phiếu cho E9 và E10 (hai cạnh trên đường xung đột) và câu hỏi về ứng viên Điều 32 khoản 4 × Điều 5 khoản 12 cho người học luật.
- Kiểm norm thừa, norm chết, ngoại lệ không kích hoạt (E6, E8) trong Lean: nằm ngoài phạm vi Level 1 hiện ghi, cần quyết riêng.
