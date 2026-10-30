# eval/mutation — thí nghiệm đột biến (xem docs/mutation-experiment.md, docs/mutation-results.md)

Tệp thử bỏ đi, **không** thuộc thư viện `lake`. Từ gốc repo:

    python eval/mutation/run_all.py --lean   # sinh Run.lean, chạy Lean (~5 phút), so sánh (a)/(b)/(c), ghi results.csv
    python eval/mutation/run_all.py          # chỉ phân tích lại lean_out.tsv
    python eval/mutation/make_results_doc.py # sinh docs/mutation-results.md

| Tệp | Việc |
|---|---|
| `spec.py` | mô hình Python của bản mã hóa B0/B1/B2; bảng được đọc thẳng từ `Laws/AlcoholSale.lean` |
| `gen_mutants.py` | các toán tử, seed 20261031, `mutants.csv`, `Run.lean` |
| `reference.py` | (b) cài lại ngữ nghĩa bằng Python, độc lập với Lean |
| `Run.lean` | (a) kiểm toàn miền bằng `Internal.isConflictAt` + `validate`/finding + `analyze` + `analyzeP`, in TSV |
| `run_all.py` | so sánh, phân loại, đếm |
| `results.csv`, `disagreements.txt`, `summary.json` | kết quả thô |
