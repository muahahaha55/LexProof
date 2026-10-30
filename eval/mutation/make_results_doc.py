# -*- coding: utf-8 -*-
"""Writes docs/mutation-results.md from summary.json / results.csv (tables), around fixed prose."""
import csv
import json
import os
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", ".."))
S = json.load(open(os.path.join(HERE, "summary.json"), encoding="utf-8"))
rows = list(csv.DictReader(open(os.path.join(HERE, "results.csv"), encoding="utf-8")))
mut = {r["id"]: r for r in csv.DictReader(open(os.path.join(HERE, "mutants.csv"), encoding="utf-8"))}
T = S["table"]

NAME = {"M5": "M5 id trùng", "M6a": "M6a tham chiếu treo", "M8b": "M8b bộ đọc: atom trong khoảng, giá trị ngoài miền",
        "M8c": "M8c bộ đọc: atom ngoài khoảng", "M8e": "M8e `Cond.sit` ngoài khoảng", "M9b": "M9b chu trình ưu tiên",
        "M9c": "M9c ưu tiên tới id không có", "M11a": "M11a trùng tên atom", "M11b": "M11b enum không có dải",
        "M11c": "M11c nguồn rỗng", "M11d": "M11d trùng nhãn dải",
        "M1": "M1 đổi modality", "M2": "M2 thêm norm modality đối", "M3": "M3 bỏ ngoại lệ", "M4": "M4 đổi tập dải",
        "M7a": "M7a đổi act sang act có sẵn", "M7b": "M7b đổi act sang act mới", "M8a": "M8a bộ đọc đọc atom khác (hợp lệ)",
        "M8d": "M8d `Cond.sit` sang bộ đọc khác (trong khoảng)", "M9a": "M9a thêm cạnh ưu tiên",
        "M10a": "M10a norm chỉ xung đột ở vùng bất khả thi", "M10b": "M10b đối chứng: xung đột ở vùng khả thi",
        "C1": "C1 đổi id duy nhất", "C2": "C2 tham chiếu có thật", "C3": "C3 đảo thứ tự"}


def keys_of(g):
    return sorted([k for k in T if k.startswith(g + "/") and not k.endswith("/ALL")], key=lambda x: (len(x), x))


def table(g):
    out = ["| Toán tử | n | detected | missed-invisible | missed-hiding | false alarm | unconstrained-only (cặp) | kỳ vọng sai | bất đồng |",
           "|---|---|---|---|---|---|---|---|---|"]
    for k in keys_of(g):
        v = T[k]; op = k.split("/")[1]
        out.append("| %s | %d | %d | %d | %d | %d | %d | %d | %d |" % (
            NAME[op], v["n"], v.get("detected", 0), v.get("missed-invisible", 0), v.get("missed-hiding", 0),
            v.get("false_alarm", 0), v.get("unc_only_pairs", 0), v.get("expectation_wrong", 0), v.get("disagree", 0)))
    return "\n".join(out)


def tableA():
    out = ["| Toán tử | n | detected (đúng loại, nêu đúng đối tượng) | missed | kỳ vọng sai (finding thừa hoặc thiếu) | bất đồng |",
           "|---|---|---|---|---|---|"]
    for k in keys_of("A"):
        v = T[k]; op = k.split("/")[1]
        out.append("| %s | %d | %d | %d | %d | %d |" % (NAME[op], v["n"], v.get("detected", 0), v.get("missed", 0),
                                                     v.get("expectation_wrong", 0), v.get("disagree", 0)))
    return "\n".join(out)


def tableD():
    out = ["| Toán tử | n | im lặng (đúng) | false alarm |", "|---|---|---|---|"]
    for k in keys_of("D"):
        v = T[k]; op = k.split("/")[1]
        out.append("| %s | %d | %d | %d |" % (NAME[op], v["n"], v.get("silent", 0), v.get("false-alarm", 0)))
    return "\n".join(out)


def tableBbase():
    c = Counter((r["base"], r["outcome"]) for r in rows if r["group"] == "B")
    out = ["| Gốc | n | detected | missed-invisible | missed-hiding |", "|---|---|---|---|---|"]
    for b in ("B0", "B1", "B2"):
        n = sum(v for (bb, _), v in c.items() if bb == b)
        out.append("| %s | %d | %d | %d | %d |" % (b, n, c[(b, "detected")], c[(b, "missed-invisible")], c[(b, "missed-hiding")]))
    return "\n".join(out)


def example(op, outcome, base=None):
    for r in rows:
        if r["op"] == op and r["outcome"] == outcome and (base is None or r["base"] == base):
            return "`%s` — %s" % (r["id"], mut[r["id"]]["description"].replace("|", "\\|"))
    return "(không có mutant nào trong mẫu)"


lean = {}
for l in open(os.path.join(HERE, "lean_out.tsv"), encoding="utf-8").read().split("\n"):
    f = l.split("\t")
    if len(f) > 5:
        lean[f[0]] = f
tab_only = Counter()
for r in rows:
    f = lean[r["id"]]
    keys = [k for k in f[1].split(";") if k]
    if keys and not any(k.startswith("N:") for k in keys):
        tab_only[f[4]] += 1
n_tab_only = sum(tab_only.values())
tm = S["timing"]; rg = S["regression"]

TEMPLATE = open(os.path.join(HERE, "results_template.md"), encoding="utf-8").read()
vals = {
    "N_ALL": S["mutants"] + 3, "N_MUT": S["mutants"], "N_TAB": n_tab_only,
    "TAB_CONS": tab_only["consistent"], "TAB_CONF": tab_only["conflict"] + tab_only.get("conditional", 0),
    "REG_N": rg["valid_mutants"], "REG_EQ": rg["pairs_equal_full_domain"],
    "REG_BAD": rg["pairs_reported_not_confirmed"], "REG_MISS": rg["pairs_missed"],
    "TABLE_A": tableA(), "TABLE_B": table("B"), "TABLE_BBASE": tableBbase(), "TABLE_C": table("C"), "TABLE_D": tableD(),
    "EX_M1": example("M1", "missed-invisible"), "EX_M3": example("M3", "missed-invisible"),
    "EX_M4": example("M4", "missed-invisible", "B0"), "EX_M8A": example("M8a", "missed-invisible"),
    "EX_M8D": example("M8d", "missed-invisible"), "EX_M7B": example("M7b", "missed-invisible"),
    "EX_M7B_HIDE": example("M7b", "missed-hiding", "B2"), "EX_M7A_NEW": example("M7a", "detected", "B1"),
    "EX_M4_HIDE": example("M4", "missed-hiding", "B2"), "EX_M7A_HIDE": example("M7a", "missed-hiding", "B2"),
    "EX_M9A": example("M9a", "missed-invisible"), "EX_M2": example("M2", "missed-invisible"),
    "UNC_PAIRS": T["C/M10a"]["unc_only_pairs"], "UNC_N": T["C/M10a"]["n"], "UNC_CTRL": T["C/M10b"]["unc_only_pairs"],
    "MED": tm["median_us"], "P90": tm["p90_us"], "MAX": tm["max_us"], "TN": tm["n"], "FIRST": tm["first_call_us"],
}
doc = TEMPLATE
for k, v in vals.items():
    doc = doc.replace("{{%s}}" % k, str(v))
assert "{{" not in doc
open(os.path.join(ROOT, "docs", "mutation-results.md"), "w", encoding="utf-8", newline="\n").write(doc)
print("ok")
