# -*- coding: utf-8 -*-
"""POST-HOC: for each missed-invisible mutant, does any `analyzeReport` field (other than `core`) differ
from the report of its base? Writes docs/mutation-posthoc-analyzereport.md.  Not a detection rate."""
import csv
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))

rep = {}
for line in open(os.path.join(HERE, "report_out.tsv"), encoding="utf-8").read().split("\n"):
    f = line.split("\t")
    if len(f) < 8: continue
    rep[f[0]] = dict(nc=f[1], acts=frozenset(x for x in f[2].split(";") if x), res=frozenset(x for x in f[3].split(",") if x),
                     single=frozenset(x for x in f[4].split(",") if x), unused=frozenset(x for x in f[5].split(",") if x),
                     finds=frozenset(x for x in f[6].split(",") if x), core_eq=f[7])
assert all(v["core_eq"] == "true" for v in rep.values())
rows = list(csv.DictReader(open(os.path.join(HERE, "results.csv"), encoding="utf-8")))
mut = {r["id"]: r for r in csv.DictReader(open(os.path.join(HERE, "mutants.csv"), encoding="utf-8"))}

ALERT = ("nc", "res", "unused", "finds")          # fields that point at something to look at
DESC = ("acts", "single")                          # descriptive tables
FIELDS = ALERT + DESC
NAME = {"nc": "cờ «không có cặp khắc modality»", "res": "ưu tiên (mức cặp)", "unused": "act danh mục không dùng",
        "finds": "act ngoài danh mục", "acts": "bảng act (số norm/modality)", "single": "act chỉ dùng một lần"}

per = defaultdict(lambda: defaultdict(int))
for r in rows:
    if r["op"] == "base" or r["outcome"] != "missed-invisible": continue
    b, m = rep[r["base"]], rep[r["id"]]
    ch = [k for k in FIELDS if b[k] != m[k]]
    t = per[r["op"]]
    t["n"] += 1
    if ch: t["any"] += 1
    if any(k in ALERT for k in ch): t["alert"] += 1
    if ch and not any(k in ALERT for k in ch): t["desc_only"] += 1
    for k in ch: t["f_" + k] += 1

ops = sorted(per, key=lambda o: (len(o), o))
tab = ["| Toán tử | missed-invisible (n) | đổi ≥ 1 trường báo cáo | đổi trường «cảnh báo» | chỉ đổi bảng mô tả | không đổi gì | " +
       " | ".join(NAME[k] for k in FIELDS) + " |",
       "|---|---|---|---|---|---|" + "---|" * len(FIELDS)]
for o in ops:
    t = per[o]
    tab.append("| %s | %d | %d | %d | %d | %d | %s |" % (o, t["n"], t["any"], t["alert"], t["desc_only"], t["n"] - t["any"],
                                                       " | ".join(str(t["f_" + k]) for k in FIELDS)))

doc = """# POST-HOC: các mutant `missed-invisible` đi qua `analyzeReport`

**Nhãn: post-hoc.** D47 đến D50 (`LexProof/Verify/AnalyzeReport.lean`) được thiết kế **sau khi đã thấy** kết quả ở
[mutation-results.md](mutation-results.md); các trường báo cáo được chọn vì chúng liên quan tới điểm mù đã biết. Vì vậy đây **không phải tỉ lệ phát hiện** và không đo
khả năng bắt lỗi thật. Hai tài liệu thí nghiệm gốc không được sửa; tệp này chỉ thêm.

**Cách đếm.** Với mỗi mutant `missed-invisible` (kết quả `analyzeP` giống hệt gốc), so các trường của `analyzeReport` *ngoài* `core` với báo cáo của gốc cùng loại
(B0/B1/B2), dùng danh mục act do người gọi cung cấp = 5 act của nhóm (slice1-notes mục C). `core` bằng `analyzeP` ở cả 410 mutant (kiểm lúc chạy bằng `decide`).
«Trường cảnh báo» = cờ không-cặp-khắc-modality, ưu tiên mức cặp, act danh mục không dùng, act ngoài danh mục. «Bảng mô tả» = bảng act (số norm, modality) và danh sách act dùng một lần:
chúng đổi mỗi khi norm đổi modality hay act, nhưng chỉ là **số liệu để người duyệt đọc**, không phải cảnh báo.

%s

**Cách đọc.** «đổi ≥ 1 trường» lớn một phần vì bảng act mô tả lại đúng cái đã đột biến (đổi modality hay act thì bảng đổi); con số đáng chú ý hơn là cột «đổi trường cảnh báo».
Các điểm mù mà **không trường nào đổi** (cột cuối) là điểm mù D47–D50 không chạm tới: bỏ ngoại lệ, đổi tập dải/ngưỡng, bộ đọc đọc sai atom, `Cond.sit` trỏ nhầm.
Mutant `missed-hiding` (4 mutant) không nằm trong bảng này.
""" % "\n".join(tab)
open(os.path.join(ROOT, "docs", "mutation-posthoc-analyzereport.md"), "w", encoding="utf-8", newline="\n").write(doc)
for o in ops: print(o, dict(per[o]))
