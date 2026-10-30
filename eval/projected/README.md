# eval/projected — A0 và B5 của LexProof/Verify/ProjectedCheck.lean

File thử bỏ đi, **không** thuộc thư viện `lake`, không được `LexProof.lean` import. Chạy bằng
`lake env lean eval/projected/<file>.lean` từ gốc repo (cần `lake build` xong).

- `A0_empty_domain.lean` — `analyze` trả gì khi bảng có enum không có dải nào (không gian tình huống rỗng).
- `gen_proj.py` — sinh `lean/PairA_{full,proj}_x{0..3}.lean`, `PairA_{full,proj}_opp.lean`: cặp 12.3.c × 13.2 chép từ
  `eval/situation-model/gen.py` (cùng atom, cùng thứ tự bộ đọc, cùng `Cond`), dựng trên `LexProof.Core.AtomTable`.
  `full` = `analyze` trên toàn miền; `proj` = `projConsistentT`; `x<k>` = thêm k atom Bool không norm nào đọc;
  `opp` = 13.2 đổi thành nghĩa vụ để có xung đột thật.
- `time_runs.py` — đo wall-clock (ba lượt mỗi file), ghi `timings.csv`. `lean/baseline.lean` = thời gian nạp thư viện (trừ đi).
