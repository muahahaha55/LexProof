# -*- coding: utf-8 -*-
"""POST-HOC: for each missed-invisible mutant, does any case that passes on its base stop passing?
Writes docs/mutation-posthoc-cases.md. Not an independent detection rate."""
import csv
import os
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
out = {}
for line in open(os.path.join(HERE, "cases_out.tsv"), encoding="utf-8").read().split("\n"):
    f = line.split("\t")
    if len(f) == 2:
        out[f[0]] = dict(x.split(":") for x in f[1].split(","))
rows = list(csv.DictReader(open(os.path.join(HERE, "results.csv"), encoding="utf-8")))
per = defaultdict(lambda: defaultdict(int))
ex = {}
for r in rows:
    if r["op"] == "base" or r["outcome"] != "missed-invisible":
        continue
    b, m = out[r["base"]], out[r["id"]]
    newly = sorted(c for c in m if b[c] == "pass" and m[c] != "pass")
    t = per[r["op"]]
    t["n"] += 1
    if newly:
        t["changed"] += 1
        ex.setdefault(r["op"], (r["id"], newly))
    if any(m[c] in ("under", "malformed") for c in newly):
        t["unsound_kind"] += 1
ops = sorted(per, key=lambda o: (len(o), o))
tab = ["| Toán tử | missed-invisible (n) | làm ≥ 1 ca đang đạt ở gốc thành không đạt | không làm ca nào đổi | trong đó có ca chuyển thành underspecified/malformed | ví dụ (mutant → ca) |", "|---|---|---|---|---|---|"]
for o in ops:
    t = per[o]
    e = ex.get(o)
    tab.append("| %s | %d | %d | %d | %d | %s |" % (o, t["n"], t["changed"], t["n"] - t["changed"], t["unsound_kind"], ("%s → %s" % (e[0], ", ".join(e[1]))) if e else "—"))
base_fail = {b: sorted(c for c, v in out[b].items() if v != "pass") for b in ("B0", "B1", "B2")}
doc = """# POST-HOC: các mutant `missed-invisible` đi qua bộ chạy ca thử

**Nhãn: post-hoc.** Các ca (`LexProof/Laws/AlcoholSaleCases.lean`) được chốt trước khi chạy với mã hóa gốc B0, nhưng **sau khi** thí nghiệm đột biến đã có kết quả, và **cùng một người soạn**
viết ca, mã hóa và đột biến. Đây **không phải tỉ lệ phát hiện độc lập**; nó chỉ cho thấy ca thử của tôi nhạy với loại đột biến nào. Tài liệu thí nghiệm gốc không được sửa.

**Cách đếm.** Mỗi mutant `missed-invisible` (`analyzeP` giống hệt gốc) chạy qua 37 ca. «Làm ca không đạt» = có ca **đạt ở gốc của nó** mà **không đạt** ở mutant (so với gốc B0/B1/B2 tương ứng,
vì gốc B1/B2 có norm tổng hợp `SYN-P` nên tự nó làm một số ca không đạt).

Ca không đạt ở các gốc: B0 = %s; B1 = %s; B2 = %s.

%s

**Cách đọc.** Các đột biến đổi ngưỡng/dải (M4), bộ đọc (M8a), `Cond.sit` (M8d) và ưu tiên (M9a) là chỗ `analyzeP` và `analyzeReport` không thấy; cột thứ ba cho biết ca thử có thấy hay không.
Ca thử chỉ thấy đột biến khi một ca **chạm** đúng norm bị đổi, nên độ nhạy phụ thuộc hoàn toàn vào việc người soạn có viết ca cho chỗ đó. Đột biến M7b (đổi sang act mới) làm ca của act đó trả `noNormApplies` nên bị bắt.
""" % (", ".join(base_fail["B0"]) or "—", ", ".join(base_fail["B1"]) or "—", ", ".join(base_fail["B2"]) or "—", "\n".join(tab))
open(os.path.join(ROOT, "docs", "mutation-posthoc-cases.md"), "w", encoding="utf-8", newline="\n").write(doc)
for o in ops: print(o, dict(per[o]), ex.get(o))
print(base_fail)
