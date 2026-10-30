# eval/situation-model — thí nghiệm chi phí kernel của V-lite

Thí nghiệm **bỏ đi**, không thuộc thư viện `lake` và không được `LexProof.lean`
import. Mô tả, tiêu chí và dự đoán cố định trước khi làm:
[../../docs/situation-model-experiment.md](../../docs/situation-model-experiment.md).
Kết quả và kết luận: cuối file đó.

## Cách chạy

    python gen.py                                   # sinh lean/*.lean từ các spec trong gen.py
    lake env lean eval/situation-model/lean/A_a_x0.lean
    python time_runs.py 3 eval/situation-model/lean/A_a_x0.lean ...   # ghi timings.csv

Chạy từ gốc repo. Cần `lake build` đã xong để `LexProof.Verify.Conflict` có `.olean`.

## Tên file

`<mã hóa>_<cặp>_x<k>[_hậu tố].lean`

- mã hóa **A** = thiết kế hiện tại (structure + bộ đọc là chiếu trường);
  **B** = V-lite (bảng atom, tình huống là phép gán, bộ đọc tra danh sách);
- cặp **a** = 12.3.c × 13.2 (10,58 bit, 1 536 điểm), **b** = 5.5 × 10.6 (7 bit, 128 điểm);
- `x<k>` = thêm k atom Bool mà không norm nào đọc (nhân số điểm lên 2^k) — dùng để kiểm
  thời gian có tuyến tính theo số điểm không;
- `_prof` = bật `set_option profiler true`; `_plain` = `decide` thường thay vì
  `decide +kernel`; `_full` = khẳng định đầy đủ `analyze … = .consistentOn (scopeOf …) (auditOf …)`.

`baseline.lean` chỉ import thư viện: thời gian khởi động để trừ đi.

## Giả định

- Hai mã hóa của cùng một cặp có **cùng danh sách bộ đọc (cùng thứ tự, cùng chỉ số)**,
  cùng `Cond`, cùng norm; chỉ khác kiểu tình huống và cách đọc atom.
- Không có IC (`valid` mặc định = đúng): miền = tích các miền atom mà **hai norm đọc**
  (thêm các atom giả ở biến thể `x<k>`), như cột "Fact trong F" của scaling-analysis.
- Cả hai cặp đều là cặp cấm × cấm (cùng modality) nên "không xung đột" đúng ngay theo
  `Incompatible`. Chi phí vẫn đo được vì `Internal.conflictsAt` xét `act`, rồi `applies`
  của norm thứ nhất (và của norm thứ hai khi norm thứ nhất áp dụng), rồi mới đến
  modality; xem tài liệu thí nghiệm.
- Chỉ dùng `decide +kernel` (không `native_decide`, không `bv_decide`, không axiom mới).
