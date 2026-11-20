# -*- coding: utf-8 -*-
"""Per-document glossary of acts and atoms (FR2, ADR-0027 step 1). UNTRUSTED tool; it proves nothing.

    python pipeline/glossary.py check data/glossary/44-2019-QH14.json

A glossary is data reviewed by a person: every act and atom has an id, a gloss (what it means, in plain words), the
clauses it comes from, and a status (`proposed` until a reviewer approves it). This step only defines the file and
checks it. Using the ids in translations, merging by id and blocking unapproved terms are later steps (ADR-0027).
"""
import argparse
import datetime
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402

ID = re.compile(r"^[a-z0-9]+(?:_[a-z0-9]+)*$")
STATUSES = ("proposed", "approved", "rejected")
KINDS = ("situation", "parameter")


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def check_sources(seg, srcs, where, out):
    if not isinstance(srcs, list) or not srcs:
        out.append("%s: «sources» phải là danh sách không rỗng" % where)
        return
    for s in srcs:
        T.check_ref(seg, s, where, out)


def check_status(e, where, out):
    st = e.get("status")
    if st not in STATUSES:
        out.append("%s: «status» phải là một trong %s" % (where, list(STATUSES)))
    if st in ("approved", "rejected"):
        if not e.get("reviewed_by"):
            out.append("%s: trạng thái «%s» cần «reviewed_by»" % (where, st))
        try:
            datetime.date.fromisoformat(str(e.get("reviewed_on", "")))
        except ValueError:
            out.append("%s: trạng thái «%s» cần «reviewed_on» dạng YYYY-MM-DD" % (where, st))


def check(g):
    """Findings (strings); empty means no structural finding, NOT that the glossary is right."""
    out = []
    for k in ("doc_id", "acts", "atoms"):
        if k not in g:
            out.append("thiếu khóa «%s»" % k)
    if out:
        return out
    seg = T.load_segmented(g["doc_id"])
    for kind in ("acts", "atoms"):
        ids = [e.get("id") for e in g[kind]]
        dup = sorted({i for i in ids if ids.count(i) > 1})
        if dup:
            out.append("%s: id trùng: %s" % (kind, ", ".join(map(str, dup))))
    for e in g["acts"]:
        w = "act «%s»" % e.get("id")
        if not isinstance(e.get("id"), str) or not ID.match(e["id"]):
            out.append("%s: id phải là snake_case không dấu" % w)
        if not e.get("gloss"):
            out.append("%s: thiếu «gloss» (giải thích bằng lời)" % w)
        check_sources(seg, e.get("sources"), w, out)
        check_status(e, w, out)
    for e in g["atoms"]:
        w = "atom «%s»" % e.get("id")
        if not isinstance(e.get("id"), str) or not ID.match(e["id"]):
            out.append("%s: id phải là snake_case không dấu" % w)
        if e.get("kind") not in KINDS:
            out.append("%s: «kind» phải là situation hoặc parameter" % w)
        if not e.get("gloss"):
            out.append("%s: thiếu «gloss» (giải thích bằng lời)" % w)
        check_sources(seg, e.get("sources"), w, out)
        check_status(e, w, out)
        dom = e.get("domain")
        if dom == "bool":
            continue
        if e.get("kind") == "parameter":
            out.append("%s: tham số chỉ được là bool" % w)
        if not isinstance(dom, list) or len(dom) < 2:
            out.append("%s: domain phải là «bool» hoặc danh sách ≥ 2 nhãn" % w)
            continue
        labels = [b.get("label") for b in dom]
        if len(set(labels)) != len(labels):
            out.append("%s: nhãn trùng nhau" % w)
        for b in dom:
            wb = "%s, nhãn «%s»" % (w, b.get("label"))
            if b.get("source"):
                T.check_ref(seg, b["source"], wb, out)
            elif not b.get("note"):
                # a value no clause names (e.g. the complement of a band) must say so, never pass silently
                out.append("%s: không có «source» thì phải có «note» giải thích vì sao luật không nêu" % wb)
    return out


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("check")
    p.add_argument("file")
    a = ap.parse_args(argv)
    g = load(a.file)
    fs = check(g)
    if fs:
        print("TỪ CHỐI: %d phát hiện:" % len(fs))
        for f in fs:
            print("  - " + f)
        return 1
    n = {s: sum(1 for e in g["acts"] + g["atoms"] if e.get("status") == s) for s in STATUSES}
    print("không có phát hiện cấu trúc; %d act, %d atom; proposed %d, approved %d, rejected %d. "
          "Điều này KHÔNG nói bảng đúng luật." % (len(g["acts"]), len(g["atoms"]), n["proposed"], n["approved"], n["rejected"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
