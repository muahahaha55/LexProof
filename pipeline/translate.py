# -*- coding: utf-8 -*-
"""Translation step (FR3), manual-paste version. UNTRUSTED: nothing here proves anything.

    python pipeline/translate.py prompt  --article 19 [-o FILE]       print (or write, UTF-8) the prompt to paste into the LLM
    python pipeline/translate.py check   FILE.json                    structural and quotation checks (exit 1 on any finding)
    python pipeline/translate.py lean    FILE.json -o FILE.lean       check, then write a Lean DRAFT (outside the library)
    python pipeline/translate.py compare FILE.json GOLD.json          norm-by-norm difference with a hand translation

The LLM answer is a JSON file (schema in `prompt`). It is data, not Lean code. A finding means: do not use the file.
The output of `lean` goes under eval/translate/, never into `LexProof/Laws/`; moving it there is a human decision
after review (see CLAUDE.md, trust boundary). Lean's own `pfindings` is the check that matters; this script only
catches mistakes early (an invented quotation, an unknown atom, a clause nobody accounted for).
"""
import argparse
import json
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
SEGMENTED = {"44/2019/QH14": "data/segmented/44-2019-QH14.json"}
MODALITIES = {"prohibition": ".prohibition", "obligation": ".obligation", "permission": ".permission"}
DOC_TYPES = {"law": ".law", "decree": ".decree", "circular": ".circular", "decision": ".decision"}

REF_ARTICLE = re.compile(r"^Điều (\d+)( tiêu đề| \(tiêu đề\))?$")
REF_CLAUSE = re.compile(r"^Điều (\d+) khoản (\d+)(?: điểm ([a-zđ]))?(?: nhánh \(([ivx]+)\))?$")


# ------------------------------------------------------------------ source text

def load_segmented(doc_id):
    rel = SEGMENTED.get(doc_id)
    if rel is None:
        raise SystemExit("không có văn bản đã tách cho doc_id «%s»" % doc_id)
    with open(os.path.join(ROOT, *rel.split("/")), encoding="utf-8") as f:
        return json.load(f)


def norm_ws(s):
    return re.sub(r"\s+", " ", s).strip()


def parse_ref(s):
    """Same grammar as Core/ClauseRef.lean (the subset used here). Returns a dict or None."""
    m = REF_ARTICLE.match(s)
    if m:
        return {"article": int(m.group(1)), "clause": None, "point": None, "branch": None, "heading": bool(m.group(2))}
    m = REF_CLAUSE.match(s)
    if m:
        return {"article": int(m.group(1)), "clause": int(m.group(2)), "point": m.group(3), "branch": m.group(4),
                "heading": False}
    return None


def unit_text(seg, ref):
    """Text of the unit a reference names, or None if the unit does not exist."""
    art = next((a for a in seg["articles"] if a["number"] == ref["article"]), None)
    if art is None:
        return None
    if ref["clause"] is None:
        return art["title"] if ref["heading"] else norm_ws(" ".join(
            [art["title"]] + ([art["lead_in"]["text"]] if art["lead_in"] else []) + [c["text"] for c in art["clauses"]]))
    cl = next((c for c in art["clauses"] if c["number"] == ref["clause"]), None)
    if cl is None:
        return None
    if ref["point"] is None:
        return norm_ws(cl["text"])
    pt = next((p for p in cl["points"] if p["letter"] == ref["point"]), None)
    return norm_ws(pt["text"]) if pt else None


# ------------------------------------------------------------------ prompt

SCHEMA = """{
  "doc_id": "44/2019/QH14", "doc_type": "law", "effective": "YYYY-MM-DD", "article": 19,
  "atoms": {
    "situation": [ {"name": "S1 ...", "source": "Điều 19 khoản 1", "domain": "bool"},
                   {"name": "S2 ...", "source": "Điều 5 khoản 3",
                    "domain": [ {"label": "...", "source": "Điều 5 khoản 3"}, {"label": "...", "source": "..."} ]} ],
    "parameters": [ {"name": "P1 ...", "source": "Điều 19 khoản 3", "domain": "bool"} ]
  },
  "norms": [
    {"id": "19.1", "modality": "prohibition | obligation | permission", "act": "ban_ruou_bia",
     "condition": COND, "exceptions": [COND], "source": "Điều 19 khoản 1", "quote": "chữ nguyên văn trong đơn vị nguồn"}
  ],
  "not_encoded": [ {"clause": "Điều 19 khoản 7", "reason": "..."} ],
  "assumptions": [ "mỗi lựa chọn đọc luật mà bạn đã làm, một câu mỗi mục" ]
}
COND ::= "true" | "false"
       | {"sit": "<tên atom bool>"} | {"sit": "<tên atom enum>", "value": "<nhãn>"} | {"param": "<tên atom tham số>"}
       | {"not": COND} | {"and": [COND, COND, ...]} | {"or": [COND, COND, ...]}"""

RULES = """1. Chỉ trả về MỘT khối JSON đúng lược đồ trên. Không viết mã Lean. Không thêm lời giải thích ngoài JSON.
2. «source» của norm, atom và nhãn là tham chiếu điều khoản có dạng chính xác «Điều N», «Điều N tiêu đề», «Điều N khoản K»,
   «Điều N khoản K điểm x» (x là chữ cái thường), hoặc có thêm «nhánh (i)», «nhánh (ii)», «nhánh (iii)»... (số La Mã
   thường; KHÔNG dùng chữ số như «nhánh (1)») khi một khoản chứa nhiều lệnh cấm. Dùng đơn vị cụ
   thể nhất mà norm thật sự dựa vào, không dùng cả khoản khi chỉ một điểm hay một nhánh được mã hóa. Không dùng chuỗi tự do.
3. «quote» phải là đoạn nguyên văn (liền, cùng chính tả) nằm trong đúng đơn vị đã ghi ở «source».
4. Mọi khoản của điều phải xuất hiện trong «norms» (qua «source») hoặc trong «not_encoded» kèm lý do. Không được bỏ lặng lẽ.
5. Khái niệm mở («hợp lý», «nghiêm trọng», «dành cho người chưa đủ 18 tuổi»...) là atom trong «parameters»; không tự quyết giá trị.
6. Nếu không chắc cách đọc, đừng đoán: đưa khoản vào «not_encoded» và nêu lý do, hoặc ghi lựa chọn vào «assumptions».
7. Nếu tiêu đề điều cho biết tính chất (cấm, bắt buộc, được phép) áp dụng cho các khoản dưới nó, hãy áp dụng và ghi vào «assumptions».
8. «exceptions» là các điều kiện làm norm không áp dụng («trừ ...»); đó không phải một quyền được phép.
9. «act» là mã snake_case không dấu, ngắn, cho hành vi bị điều chỉnh; cùng hành vi dùng cùng mã."""


def make_prompt(seg, article):
    art = next((a for a in seg["articles"] if a["number"] == article), None)
    if art is None:
        raise SystemExit("văn bản không có Điều %d" % article)
    lines = ["Bạn là bộ dịch điều khoản luật Việt Nam thành DỮ LIỆU JSON cho một bộ kiểm tra nhất quán. Kết quả của bạn sẽ được",
             "kiểm tra tự động rồi được một người đọc đối chiếu với luật; bạn không được tin cậy.", "",
             "Văn bản: %s (doc_id %s). Chỉ dùng chữ dưới đây." % ("Luật Phòng, chống tác hại của rượu, bia", seg["input"].get("doc_id", "44/2019/QH14")), "",
             "### %s. %s" % (art["id"], art["title"])]
    if art["lead_in"]:
        lines.append("[đoạn dẫn, tham chiếu «%s»] %s" % (art["id"], norm_ws(art["lead_in"]["text"])))
    for c in art["clauses"]:
        lines.append("[%s] %s" % (c["id"], norm_ws(c["text"])))
        for p in c["points"]:
            lines.append("  [%s] %s" % (p["id"], norm_ws(p["text"])))
    lines += ["", "### Lược đồ JSON", SCHEMA, "", "### Quy tắc", RULES]
    return "\n".join(lines) + "\n"


# ------------------------------------------------------------------ check

def atom_index(atoms):
    return {a["name"]: a for a in atoms}


def walk_cond(c, sit, par, path, out):
    """Collects findings for one condition tree."""
    if c in ("true", "false"):
        return
    if not isinstance(c, dict) or len(c) not in (1, 2):
        out.append("%s: điều kiện sai dạng: %r" % (path, c))
        return
    if "sit" in c:
        a = sit.get(c["sit"])
        if a is None:
            out.append("%s: atom tình huống không tồn tại: «%s»" % (path, c["sit"]))
        elif a["domain"] == "bool":
            if "value" in c:
                out.append("%s: atom bool «%s» không có «value»" % (path, c["sit"]))
        elif c.get("value") not in [b["label"] for b in a["domain"]]:
            out.append("%s: «%s» không có nhãn «%s»" % (path, c["sit"], c.get("value")))
    elif "param" in c:
        a = par.get(c["param"])
        if a is None:
            out.append("%s: atom tham số không tồn tại: «%s»" % (path, c["param"]))
        elif a["domain"] != "bool":
            out.append("%s: tham số «%s» phải là bool" % (path, c["param"]))
    elif "not" in c:
        walk_cond(c["not"], sit, par, path + ".not", out)
    elif "and" in c or "or" in c:
        k = "and" if "and" in c else "or"
        if not isinstance(c[k], list) or not c[k]:
            out.append("%s: «%s» cần danh sách không rỗng" % (path, k))
        else:
            for i, x in enumerate(c[k]):
                walk_cond(x, sit, par, "%s.%s[%d]" % (path, k, i), out)
    else:
        out.append("%s: khóa không biết: %r" % (path, list(c)))


def check_ref(seg, ref_s, where, out, quote=None):
    ref = parse_ref(ref_s) if isinstance(ref_s, str) else None
    if ref is None:
        out.append("%s: tham chiếu không phân tích được: %r" % (where, ref_s))
        return None
    text = unit_text(seg, ref)
    if text is None:
        out.append("%s: đơn vị không tồn tại trong văn bản: «%s»" % (where, ref_s))
        return ref
    if quote is not None and norm_ws(quote) not in text:
        out.append("%s: «quote» không nằm nguyên văn trong «%s»: %r" % (where, ref_s, quote))
    return ref


def check(data):
    """Findings for a translation (a list of strings; empty means no finding, NOT that the translation is right)."""
    out = []
    for k in ("doc_id", "doc_type", "effective", "article", "atoms", "norms", "not_encoded", "assumptions"):
        if k not in data:
            out.append("thiếu khóa «%s»" % k)
    if out:
        return out
    seg = load_segmented(data["doc_id"])
    if data["doc_type"] not in DOC_TYPES:
        out.append("doc_type phải là một trong %s" % sorted(DOC_TYPES))
    if not re.match(r"^\d{4}-\d{2}-\d{2}$", str(data["effective"])):
        out.append("effective phải có dạng YYYY-MM-DD")
    sit_atoms, par_atoms = data["atoms"].get("situation", []), data["atoms"].get("parameters", [])
    for kind, atoms in (("situation", sit_atoms), ("parameters", par_atoms)):
        names = [a.get("name") for a in atoms]
        if len(set(names)) != len(names):
            out.append("atoms.%s: tên trùng nhau" % kind)
        for a in atoms:
            w = "atom «%s»" % a.get("name")
            check_ref(seg, a.get("source"), w, out)
            if a.get("domain") != "bool":
                if not isinstance(a.get("domain"), list) or len(a["domain"]) < 2:
                    out.append("%s: domain phải là «bool» hoặc danh sách ≥ 2 nhãn" % w)
                else:
                    labels = [b.get("label") for b in a["domain"]]
                    if len(set(labels)) != len(labels):
                        out.append("%s: nhãn trùng nhau" % w)
                    for b in a["domain"]:
                        check_ref(seg, b.get("source"), "%s, nhãn «%s»" % (w, b.get("label")), out)
    if any(a.get("domain") != "bool" for a in par_atoms):
        out.append("parameters: chỉ cho phép atom bool")
    sit, par = atom_index(sit_atoms), atom_index(par_atoms)
    seen, refs = set(), []
    for n in data["norms"]:
        nid = n.get("id")
        w = "norm «%s»" % nid
        if nid in seen:
            out.append("%s: id trùng" % w)
        seen.add(nid)
        if n.get("modality") not in MODALITIES:
            out.append("%s: modality phải là một trong %s" % (w, sorted(MODALITIES)))
        if not isinstance(n.get("act"), str) or not re.match(r"^[a-z0-9_]+$", n.get("act", "")):
            out.append("%s: act phải là snake_case không dấu" % w)
        r = check_ref(seg, n.get("source"), w, out, n.get("quote") if isinstance(n.get("quote"), str) and n["quote"] else None)
        if not n.get("quote"):
            out.append("%s: thiếu «quote»" % w)
        if r is not None and r["article"] != data["article"]:
            out.append("%s: nguồn thuộc Điều %d, không phải Điều %d của bản dịch này" % (w, r["article"], data["article"]))
        refs.append(r)
        walk_cond(n.get("condition"), sit, par, w + ".condition", out)
        if not isinstance(n.get("exceptions"), list):
            out.append("%s: exceptions phải là danh sách" % w)
        else:
            for i, e in enumerate(n["exceptions"]):
                walk_cond(e, sit, par, "%s.exceptions[%d]" % (w, i), out)
    for e in data["not_encoded"]:
        r = check_ref(seg, e.get("clause"), "not_encoded «%s»" % e.get("clause"), out)
        if not e.get("reason"):
            out.append("not_encoded «%s»: thiếu lý do" % e.get("clause"))
        refs.append(r)
    if not isinstance(data["assumptions"], list):
        out.append("assumptions phải là danh sách")
    # fail closed: every clause of the article is accounted for by a norm or a not_encoded entry
    art = next((a for a in seg["articles"] if a["number"] == data["article"]), None)
    if art is None:
        out.append("văn bản không có Điều %d" % data["article"])
    else:
        refs = [r for r in refs if r]
        for c in art["clauses"]:
            if not any(r["article"] == art["number"] and (r["clause"] == c["number"] or (r["clause"] is None and not r["heading"]))
                       for r in refs):
                out.append("khoản chưa được tính tới (không có norm, không có not_encoded): «%s»" % c["id"])
        if art["lead_in"] and not any(r["article"] == art["number"] and r["clause"] is None and not r["heading"] for r in refs):
            out.append("đoạn dẫn của «%s» chưa được tính tới (cần norm hoặc not_encoded với tham chiếu «%s»)" % (art["id"], art["id"]))
    return out


# ------------------------------------------------------------------ Lean draft

def lq(s):
    return '"' + str(s).replace("\\", "\\\\").replace('"', '\\"') + '"'


def readers(atoms):
    """Reader list [(name, atom index, value index)] and a lookup (atom name, value label or None) -> reader index."""
    rs, look = [], {}
    for i, a in enumerate(atoms):
        if a["domain"] == "bool":
            look[(a["name"], None)] = len(rs)
            rs.append((a["name"], i, 1))
        else:
            for j, b in enumerate(a["domain"]):
                look[(a["name"], b["label"])] = len(rs)
                rs.append(("%s = %s" % (a["name"], b["label"]), i, j))
    return rs, look


def cond_lean(c, sl, pl):
    if c == "true":
        return ".tt"
    if c == "false":
        return ".ff"
    if "sit" in c:
        return "(.sit %d)" % sl[(c["sit"], c.get("value"))]
    if "param" in c:
        return "(.param %d)" % pl[(c["param"], None)]
    if "not" in c:
        return "(.not %s)" % cond_lean(c["not"], sl, pl)
    k = "and" if "and" in c else "or"
    parts = [cond_lean(x, sl, pl) for x in c[k]]
    acc = parts[-1]
    for p in reversed(parts[:-1]):
        acc = "(.%s %s %s)" % (k, p, acc)
    return acc


def atom_lean(a):
    if a["domain"] == "bool":
        d = ".bool"
    else:
        d = ".enum [" + ", ".join("⟨%s, %s⟩" % (lq(b["label"]), lq(b["source"])) for b in a["domain"]) + "]"
    return "{ name := %s, source := %s, domain := %s }" % (lq(a["name"]), lq(a["source"]), d)


def to_lean(data, seg):
    sit, par = data["atoms"]["situation"], data["atoms"]["parameters"]
    rs, sl = readers(sit)
    rp, pl = readers(par)
    y, m, d = (int(x) for x in data["effective"].split("-"))
    nmax = max(a["number"] for a in seg["articles"])
    acts = sorted({n["act"] for n in data["norms"]})
    L = ["import LexProof.Verify.AnalyzeReport", "import LexProof.Core.Render", "",
         "/-! DRAFT, NOT HUMAN-REVIEWED. Machine-translated from the text of Điều %d by pipeline/translate.py (LLM answer, pasted by hand)." % data["article"],
         "Not part of the library: it is NOT in `LexProof/Laws/`, and moving it there needs a human review first.",
         "Assumptions the translator declared (each is a reading of the law that a reviewer must accept or reject):"]
    L += ["* " + str(a).replace("-/", "- /") for a in data["assumptions"]] or ["* (none declared)"]
    L += ["-/", "", "namespace Draft", "open LexProof", "", "def tS : AtomTable :=",
          "  [ " + "\n  , ".join(atom_lean(a) for a in sit) + " ]" if sit else "  []", "",
          "def tP : AtomTable :=", ("  [ " + "\n  , ".join(atom_lean(a) for a in par) + " ]") if par else "  []", "",
          "def rS : List ReaderSpec :=", ("  [ " + "\n  , ".join("(%s, %d, %d)" % (lq(n), i, j) for n, i, j in rs) + " ]") if rs else "  []", "",
          "def rP : List ReaderSpec :=", ("  [ " + "\n  , ".join("(%s, %d, %d)" % (lq(n), i, j) for n, i, j in rp) + " ]") if rp else "  []", "",
          "def catalog : List String := (List.range %d).map fun i => \"Điều \" ++ toString (i + 1)" % nmax, "",
          "private def nrm (id : String) (mo : Modality) (act : String) (c : Cond) (ex : List Cond) (art : String) : Norm :=",
          "  { id := id, modality := mo, act := act, condition := c, exceptions := ex, priority := none",
          "  , source := { docId := %s, docType := %s, effective := ⟨%d, %d, %d⟩, article := art }" % (
              lq(data["doc_id"]), DOC_TYPES[data["doc_type"]], y, m, d),
          "  , references := [] }", "", "def norms : List Norm :="]
    ns = []
    for n in data["norms"]:
        ex = "[" + ", ".join(cond_lean(e, sl, pl) for e in n["exceptions"]) + "]"
        ns.append("nrm %s %s %s %s %s %s" % (lq(n["id"]), MODALITIES[n["modality"]], lq(n["act"]),
                                             cond_lean(n["condition"], sl, pl), ex, lq(n["source"])))
    L += [("  [ " + "\n  , ".join(ns) + " ]") if ns else "  []", "",
          "def notEncoded : List (String × String) :=",
          ("  [ " + "\n  , ".join("(%s, %s)" % (lq(e["clause"]), lq(e["reason"])) for e in data["not_encoded"]) + " ]")
          if data["not_encoded"] else "  []", "",
          "def acts : List Act := [" + ", ".join(lq(a) for a in acts) + "]", "", "end Draft", "",
          "open LexProof Draft in", "def main : IO Unit := do",
          "  IO.println s!\"pfindings: {(pfindings tS tP rS rP catalog norms).length}\"",
          "  for f in pfindings tS tP rS rP catalog norms do IO.println s!\"  {(repr f).pretty}\"",
          "  let rep := analyzeReport .draft acts tS tP rS rP catalog norms",
          "  for l in rep.render do IO.println l", ""]
    return "\n".join(L)


# ------------------------------------------------------------------ compare

def canon(c, atoms, relaxed=False):
    """Canonical text of a condition; atoms are identified by their source and value, not by their name.
    `relaxed` also merges the operands of an `or` that have the same text (several atoms of one clause joined by
    `or` read as the one atom of that clause); it is never applied to `and`."""
    if c in ("true", "false"):
        return c
    if "sit" in c or "param" in c:
        pool = atoms["situation"] if "sit" in c else atoms["parameters"]
        a = next((x for x in pool if x["name"] == c.get("sit", c.get("param"))), None)
        if a is None:
            return "?" + str(c)
        v = c.get("value")
        src = next((b["source"] for b in a["domain"] if b["label"] == v), a["source"]) if v and a["domain"] != "bool" else a["source"]
        return "%s:%s[%s]" % ("sit" if "sit" in c else "param", src, v or "")
    if "not" in c:
        return "not(%s)" % canon(c["not"], atoms, relaxed)
    k = "and" if "and" in c else "or"
    parts = [canon(x, atoms, relaxed) for x in c[k]]
    if relaxed and k == "or":
        parts = sorted(set(parts))
        if len(parts) == 1:
            return parts[0]
    return "%s(%s)" % (k, ",".join(sorted(parts)))


def signatures(data, relaxed=False):
    return {(n["modality"], n["act"], n["source"], canon(n["condition"], data["atoms"], relaxed),
             tuple(sorted(canon(e, data["atoms"], relaxed) for e in n["exceptions"]))) for n in data["norms"]}


def compare(a, b, relaxed=False):
    sa, sb = signatures(a, relaxed), signatures(b, relaxed)
    return {"same": sorted(sa & sb), "only_first": sorted(sa - sb), "only_second": sorted(sb - sa)}


# ------------------------------------------------------------------ main

def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("prompt")
    p.add_argument("--article", type=int, required=True)
    p.add_argument("--doc", default="44/2019/QH14")
    p.add_argument("-o", "--out", help="ghi câu lệnh ra tệp UTF-8 (nên dùng thay cho `>` trong PowerShell, vì `>` làm hỏng dấu tiếng Việt)")
    for name in ("check", "lean"):
        p = sub.add_parser(name)
        p.add_argument("file")
        if name == "lean":
            p.add_argument("-o", "--out", required=True)
    p = sub.add_parser("compare")
    p.add_argument("file")
    p.add_argument("gold")
    p.add_argument("--relaxed", action="store_true", help="merge same-source operands of an `or` (see canon)")
    a = ap.parse_args(argv)
    if a.cmd == "prompt":
        seg = load_segmented(a.doc)
        seg["input"].setdefault("doc_id", a.doc)
        text = make_prompt(seg, a.article)
        if a.out:
            with open(a.out, "w", encoding="utf-8", newline="\n") as f:
                f.write(text)
            print(a.out)
        else:
            sys.stdout.write(text)
        return 0
    data = json.load(open(a.file, encoding="utf-8"))
    if a.cmd == "compare":
        r = compare(data, json.load(open(a.gold, encoding="utf-8")), a.relaxed)
        print("giống: %d; chỉ ở %s: %d; chỉ ở %s: %d" % (len(r["same"]), a.file, len(r["only_first"]), a.gold, len(r["only_second"])))
        for k, lab in (("only_first", a.file), ("only_second", a.gold)):
            for s in r[k]:
                print("  chỉ ở %s: %s" % (lab, s))
        return 0 if not r["only_first"] and not r["only_second"] else 1
    fs = check(data)
    if fs:
        print("TỪ CHỐI: %d phát hiện (không dùng tệp này):" % len(fs))
        for f in fs:
            print("  - " + f)
        return 1
    if a.cmd == "check":
        print("không có phát hiện cấu trúc. Điều này KHÔNG nói bản dịch đúng luật; cần người đối chiếu.")
        return 0
    seg = load_segmented(data["doc_id"])
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    with open(a.out, "w", encoding="utf-8", newline="\n") as f:
        f.write(to_lean(data, seg))
    print(a.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
