# POST-HOC: các mutant `missed-invisible` đi qua bộ chạy ca thử

**Nhãn: post-hoc.** Các ca (`LexProof/Laws/AlcoholSaleCases.lean`) được chốt trước khi chạy với mã hóa gốc B0, nhưng **sau khi** thí nghiệm đột biến đã có kết quả, và **cùng một người soạn**
viết ca, mã hóa và đột biến. Đây **không phải tỉ lệ phát hiện độc lập**; nó chỉ cho thấy ca thử của tôi nhạy với loại đột biến nào. Tài liệu thí nghiệm gốc không được sửa.

**Cách đếm.** Mỗi mutant `missed-invisible` (`analyzeP` giống hệt gốc) chạy qua 37 ca. «Làm ca không đạt» = có ca **đạt ở gốc của nó** mà **không đạt** ở mutant (so với gốc B0/B1/B2 tương ứng,
vì gốc B1/B2 có norm tổng hợp `SYN-P` nên tự nó làm một số ca không đạt).

Ca không đạt ở các gốc: B0 = C24; B1 = C10, C12, C15, C16, C24; B2 = C10, C12, C13, C14, C15, C16, C24.

| Toán tử | missed-invisible (n) | làm ≥ 1 ca đang đạt ở gốc thành không đạt | không làm ca nào đổi | trong đó có ca chuyển thành underspecified/malformed | ví dụ (mutant → ca) |
|---|---|---|---|---|---|
| M1 | 3 | 3 | 0 | 0 | B0.M1.00 → C05, C07 |
| M2 | 1 | 1 | 0 | 1 | B0.M2.04 → C18, C19, C20, C21 |
| M3 | 3 | 3 | 0 | 0 | B0.M3.00 → C34 |
| M4 | 15 | 14 | 1 | 0 | B0.M4.00 → C01, C03 |
| M7a | 14 | 14 | 0 | 10 | B0.M7a.00 → C01, C03, C18, C19, C20, C21 |
| M7b | 17 | 17 | 0 | 0 | B0.M7b.00 → C01, C03 |
| M8a | 16 | 12 | 4 | 1 | B0.M8a.02 → C02, C04, C23, C26, C28, C30, C34, C35 |
| M8d | 14 | 13 | 1 | 4 | B0.M8d.00 → C01, C03, C34 |
| M9a | 18 | 0 | 18 | 0 | — |

**Cách đọc.** Các đột biến đổi ngưỡng/dải (M4), bộ đọc (M8a), `Cond.sit` (M8d) và ưu tiên (M9a) là chỗ `analyzeP` và `analyzeReport` không thấy; cột thứ ba cho biết ca thử có thấy hay không.
Ca thử chỉ thấy đột biến khi một ca **chạm** đúng norm bị đổi, nên độ nhạy phụ thuộc hoàn toàn vào việc người soạn có viết ca cho chỗ đó. Đột biến M7b (đổi sang act mới) làm ca của act đó trả `noNormApplies` nên bị bắt.
