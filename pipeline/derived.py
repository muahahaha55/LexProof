# -*- coding: utf-8 -*-
"""Derived norms (ADR-0028). UNTRUSTED tool; it proves nothing.

    python pipeline/derived.py check data/derived/44-2019-QH14.json

A derived norm is a norm the text does **not** state in words but that a reader infers from it, for example
«có giấy phép thì được kinh doanh rượu» from the prohibition in Điều 5 khoản 11 and the licensing regime of Điều 15.
Two articles that regulate different acts (a business; an authority granting a licence) can only be checked against
each other through such a reading, so the reading is written down, sourced, and reviewed like any other term.

A derived norm uses glossary ids only (ADR-0027), names the units it is inferred from (`derived_from`) and says the
inference in words (`reading`). `run.py --derived FILE` checks the law twice: as written, and with the derived norms
added; a result of the second run depends on the readings and is reported as such, never as a fact about the law.
"""
import argparse
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402
import glossary as G    # noqa: E402

DERIVED = {"44/2019/QH14": "data/derived/44-2019-QH14.json"}
ID = re.compile(r"^D\d+$")
PREFIX = "SUY RA "      # norm ids in Lean: «SUY RA D1», so a reader of any report sees which norms are not the text


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def check(dd):
    """Findings (strings); empty means no structural finding, NOT that a reading is right."""
    out = []
    for k in ("doc_id", "glossary", "derived"):
        if k not in dd:
            out.append("thiếu khóa «%s»" % k)
    if out:
        return out
    seg = T.load_segmented(dd["doc_id"])
    probe = {"doc_id": dd["doc_id"], "glossary": dd["glossary"], "atoms": {"situation": [], "parameters": []}}
    acts, sit, par, rejected = T.glossary_terms(probe, out)
    ids = [e.get("id") for e in dd["derived"]]
    dup = sorted({i for i in ids if ids.count(i) > 1})
    if dup:
        out.append("id trùng: %s" % ", ".join(map(str, dup)))
    for e in dd["derived"]:
        w = "norm suy ra «%s»" % e.get("id")
        if not isinstance(e.get("id"), str) or not ID.match(e["id"]):
            out.append("%s: id phải có dạng D1, D2, ..." % w)
        if e.get("modality") not in T.MODALITIES:
            out.append("%s: modality phải là một trong %s" % (w, sorted(T.MODALITIES)))
        if e.get("act") not in acts:
            out.append("%s: act «%s» %s" % (w, e.get("act"), "là mục bị bác" if e.get("act") in rejected
                                            else "không có trong bảng thuật ngữ"))
        T.walk_cond(e.get("condition"), sit, par, w + ".condition", out)
        if not isinstance(e.get("exceptions"), list):
            out.append("%s: exceptions phải là danh sách" % w)
        else:
            for i, c in enumerate(e["exceptions"]):
                T.walk_cond(c, sit, par, "%s.exceptions[%d]" % (w, i), out)
        src = e.get("derived_from")
        if not isinstance(src, list) or not src:
            out.append("%s: «derived_from» phải là danh sách không rỗng các đơn vị suy ra từ đó" % w)
        else:
            for s in src:
                T.check_ref(seg, s, w + ", derived_from", out)
        if not e.get("reading"):
            out.append("%s: thiếu «reading» (cách suy ra, bằng lời)" % w)
        if not e.get("proposed_by"):
            out.append("%s: thiếu «proposed_by» (ai đề xuất cách đọc này)" % w)
        G.check_status(e, w, out)
    for t in sorted(cond_terms(dd) & rejected):
        out.append("atom «%s» là mục bị bác của bảng thuật ngữ; không được dùng" % t)
    return out


def cond_terms(dd):
    atoms = set()
    for e in dd.get("derived", []):
        for c in [e.get("condition")] + (e["exceptions"] if isinstance(e.get("exceptions"), list) else []):
            T.cond_atoms(c, atoms)
    return atoms


def as_translation(dd, doc_type, effective):
    """The derived norms as a glossary-mode translation, so that `translate.materialize` and `run.merge` treat them
    like any article: one atom per glossary id. Lean needs one parsable source per norm: the first `derived_from`;
    the id («SUY RA D1») and the header say it is not the text. Call only on a file `check` accepted."""
    norms = [{"id": PREFIX + e["id"], "modality": e["modality"], "act": e["act"], "condition": e["condition"],
              "exceptions": e["exceptions"], "source": e["derived_from"][0], "quote": "", "references": []}
             for e in dd["derived"]]
    return {"doc_id": dd["doc_id"], "doc_type": doc_type, "effective": effective, "article": 0,
            "glossary": dd["glossary"], "atoms": {"situation": [], "parameters": []}, "glossary_proposals": {},
            "norms": norms, "not_encoded": [],
            "assumptions": ["%s%s [%s, đề xuất bởi %s] suy ra từ %s: %s" % (PREFIX, e["id"], e["status"], e["proposed_by"],
                                                                        "; ".join(e["derived_from"]), e["reading"])
                            for e in dd["derived"]]}


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("check")
    p.add_argument("file")
    a = ap.parse_args(argv)
    dd = load(a.file)
    fs = check(dd)
    if fs:
        print("TỪ CHỐI: %d phát hiện:" % len(fs))
        for f in fs:
            print("  - " + f)
        return 1
    n = {s: sum(1 for e in dd["derived"] if e.get("status") == s) for s in G.STATUSES}
    print("không có phát hiện cấu trúc; %d norm suy ra; proposed %d, approved %d, rejected %d. "
          "Điều này KHÔNG nói cách suy ra đúng." % (len(dd["derived"]), n["proposed"], n["approved"], n["rejected"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
