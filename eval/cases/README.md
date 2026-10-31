# eval/cases — ca thử cụ thể cho nhóm «bán / cung cấp / khuyến mại» (BẢN NHÁP)

| Tệp | Việc |
|---|---|
| `cases_draft.py` | **danh sách ca được ghi trước khi chạy** (37 ca, kỳ vọng từ chữ của khoản) |
| `RECORD.md` | sha256 và thời điểm ghi |
| `check_quotes.py` | mỗi đoạn trích ngắn là nguyên văn của khoản trong `data/extracted/44-2019-QH14.txt` |
| `gen_cases_lean.py` | sinh `LexProof/Laws/AlcoholSaleCases.lean` (tham số: danh sách ca đạt, để thêm `pass_set`) |
| `Print.lean` | `lake env lean --run eval/cases/Print.lean > eval/cases/run_output.txt` |
| `build_cases_docs.py` | sinh `docs/review/sale-group-cases.md` (cho người) và `sale-group-cases-key.md` (đáp án, độ phủ) |
| `check_cases_sheet.py` | đối chiếu nguyên văn trong phiếu với file trích xuất; kiểm phiếu không lộ đáp án |

Phần post-hoc (101 mutant `missed-invisible` qua bộ chạy ca): `eval/mutation/gen_cases_run.py`, `posthoc_cases.py`.
