# -*- coding: utf-8 -*-
"""Translation step (FR3), manual-paste version. UNTRUSTED: nothing here proves anything.

    python pipeline/translate.py prompt  --article 19 [-o FILE]       print (or write, UTF-8) the prompt to paste into the LLM
                                         [--glossary]                 ... listing the document's glossary (ADR-0027)
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
  "doc_id": "44/2019/QH14", "doc_type": "law", "effective": "YYYY-MM-DD", "article": @N@,
  "atoms": {
    "situation": [ {"name": "S1 ...", "source": "Điều @N@ khoản 1", "domain": "bool"},
                   {"name": "S2 ...", "source": "Điều @N@ khoản 2",
                    "domain": [ {"label": "...", "source": "Điều @N@ khoản 2"}, {"label": "...", "source": "..."} ]} ],
    "parameters": [ {"name": "P1 ...", "source": "Điều @N@ khoản 3", "domain": "bool"} ]
  },
  "norms": [
    {"id": "@N@.1", "modality": "prohibition | obligation | permission", "act": "ten_hanh_vi",
     "condition": COND, "exceptions": [COND], "source": "Điều @N@ khoản 1", "quote": "chữ nguyên văn trong đơn vị nguồn",
     "references": [ "Điều @N@ khoản 3" ]}
  ],
  "not_encoded": [ {"clause": "Điều @N@ khoản 4", "reason": "..."} ],
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
9. «act» là mã snake_case không dấu, ngắn, cho hành vi bị điều chỉnh; cùng hành vi dùng cùng mã.
10. «references» (có thể rỗng) liệt kê mọi đơn vị mà chữ của norm dẫn chiếu tới («trừ trường hợp quy định tại khoản 3 Điều này»,
    «theo quy định tại Điều 18»), viết đầy đủ «Điều N», «Điều N khoản K» hoặc «Điều N khoản K điểm x»; «Điều này» là điều đang
    dịch. Không ghi dẫn chiếu tới văn bản khác («pháp luật về ...», «Chính phủ quy định»): nêu những chỗ đó trong «assumptions».
11. Khi một khoản liệt kê điều kiện («Điều kiện ... bao gồm:» rồi các điểm a, b, c), ghi rõ trong «assumptions» bạn biểu diễn
    nó thế nào (ví dụ: được phép làm việc đó khi đủ mọi điểm, hay bắt buộc phải có từng điểm), vì người duyệt cần thấy lựa chọn này."""

# Glossary mode (ADR-0027 step 2): acts and atoms come from the per-document glossary; new terms are proposals.
GLOSSARY = {"44/2019/QH14": "data/glossary/44-2019-QH14.json"}

SCHEMA_G = """{
  "doc_id": "44/2019/QH14", "doc_type": "law", "effective": "YYYY-MM-DD", "article": @N@,
  "glossary": "@G@",
  "atoms": {"situation": [], "parameters": []},
  "glossary_proposals": {
    "acts":  [ {"id": "ten_hanh_vi_moi", "gloss": "giải thích bằng lời", "sources": ["Điều @N@ khoản 1"]} ],
    "atoms": [ {"id": "ten_atom_moi", "kind": "situation | parameter", "domain": "bool",
                "gloss": "giải thích bằng lời", "sources": ["Điều @N@ khoản 2"]},
               {"id": "ten_atom_enum_moi", "kind": "situation", "gloss": "...", "sources": ["Điều @N@ khoản 2"],
                "domain": [ {"label": "...", "source": "Điều @N@ khoản 2"}, {"label": "...", "note": "vì sao không khoản nào nêu nhãn này"} ]} ]
  },
  "norms": [
    {"id": "@N@.1", "modality": "prohibition | obligation | permission", "act": "<id act của bảng hoặc của đề xuất>",
     "condition": COND, "exceptions": [COND], "source": "Điều @N@ khoản 1", "quote": "chữ nguyên văn trong đơn vị nguồn",
     "references": [ "Điều @N@ khoản 3" ]}
  ],
  "not_encoded": [ {"clause": "Điều @N@ khoản 4", "reason": "..."} ],
  "assumptions": [ "mỗi lựa chọn đọc luật mà bạn đã làm, một câu mỗi mục" ]
}
COND ::= "true" | "false"
       | {"sit": "<id atom bool>"} | {"sit": "<id atom enum>", "value": "<nhãn>"} | {"param": "<id atom tham số>"}
       | {"not": COND} | {"and": [COND, COND, ...]} | {"or": [COND, COND, ...]}"""

RULES_G = """12. Dùng bảng thuật ngữ: «act», «sit», «param» chỉ được là id của bảng ở trên hoặc id bạn đề xuất trong «glossary_proposals».
    Để «atoms» rỗng. Khi một khái niệm của điều trùng nghĩa với một mục của bảng, PHẢI dùng id đó, kể cả khi điều này viết khác chữ.
13. Chỉ đề xuất mục mới khi không mục nào của bảng cùng nghĩa. Id mới là snake_case không dấu, không trùng id của bảng; mỗi mục có
    «gloss» và «sources» là đơn vị có thật. Nhãn enum mà không khoản nào nêu phải có «note» thay cho «source». Không ghi «status».
14. Không sửa, không mở rộng một mục của bảng (ví dụ thêm nhãn). Nếu miền giá trị của mục có sẵn không đủ cho điều này (ví dụ cần
    ngưỡng khác), đề xuất một mục mới và ghi lý do vào «assumptions»."""


def glossary_rel(doc_id):
    rel = GLOSSARY.get(doc_id)
    if rel is None:
        raise SystemExit("không có bảng thuật ngữ cho doc_id «%s»" % doc_id)
    return rel


def glossary_lines(g, rel):
    lines = ["### Bảng thuật ngữ (%s); [trạng thái] là trạng thái duyệt của mục" % rel, "Act:"]
    live = lambda es: [e for e in es if e.get("status") != "rejected"]   # noqa: E731 - rejected entries are not offered
    for e in live(g["acts"]):
        lines.append("- %s [%s]: %s (nguồn: %s)" % (e["id"], e["status"], e["gloss"], "; ".join(e["sources"])))
    for kind, head in (("situation", "Atom tình huống:"), ("parameter", "Tham số (khái niệm mở, không tự quyết giá trị):")):
        lines.append(head)
        for e in live(g["atoms"]):
            if e["kind"] == kind:
                dom = "bool" if e["domain"] == "bool" else "nhãn " + " | ".join("«%s»" % b["label"] for b in e["domain"])
                lines.append("- %s [%s], %s: %s (nguồn: %s)" % (e["id"], e["status"], dom, e["gloss"], "; ".join(e["sources"])))
    return lines


def make_prompt(seg, article, glossary=None):
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
    if glossary is None:
        lines += ["", "### Lược đồ JSON", SCHEMA.replace("@N@", str(article)), "", "### Quy tắc", RULES]
    else:
        g, rel = glossary
        lines += [""] + glossary_lines(g, rel)
        rules = RULES
        for old, new in (("là atom trong «parameters»;", "là atom «kind»: «parameter» (của bảng hoặc đề xuất);"),
                         ("9. «act» là mã snake_case không dấu, ngắn, cho hành vi bị điều chỉnh; cùng hành vi dùng cùng mã.",
                          "9. «act» là id của bảng thuật ngữ hoặc của đề xuất (quy tắc 12).")):
            assert old in rules
            rules = rules.replace(old, new)
        lines += ["", "### Lược đồ JSON", SCHEMA_G.replace("@N@", str(article)).replace("@G@", rel), "",
                  "### Quy tắc", rules, RULES_G]
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


def cond_atoms(c, acc):
    if isinstance(c, dict):
        for k in ("sit", "param"):
            if isinstance(c.get(k), str):
                acc.add(c[k])
        for k in ("not", "and", "or"):
            for x in (c[k] if isinstance(c.get(k), list) else [c.get(k)]):
                cond_atoms(x, acc)
    return acc


def used_terms(data):
    """(acts, atom names) the norms use."""
    acts, atoms = set(), set()
    for n in data.get("norms", []):
        if isinstance(n, dict):
            if isinstance(n.get("act"), str):
                acts.add(n["act"])
            for c in [n.get("condition")] + (n["exceptions"] if isinstance(n.get("exceptions"), list) else []):
                cond_atoms(c, atoms)
    return acts, atoms


def load_glossary(doc_id):
    import glossary as G   # noqa: E402 - imported here because glossary.py imports this module
    rel = glossary_rel(doc_id)
    return G, G.load(os.path.join(ROOT, *rel.split("/"))), rel


def glossary_terms(data, out):
    """Glossary mode (ADR-0027 step 2): the acts, situation atoms and parameter atoms a norm may use (glossary entries
    not rejected, plus the translation's own proposals), and the rejected ids. Appends findings to `out`."""
    G, g, rel = load_glossary(data["doc_id"])
    if data["glossary"] != rel:
        out.append("«glossary» phải là «%s» (một bảng cho mỗi văn bản)" % rel)
    gfs = G.check(g)
    if gfs:
        out.append("bảng thuật ngữ %s có %d phát hiện; sửa bảng trước (python pipeline/glossary.py check %s)" % (rel, len(gfs), rel))
    if data["atoms"].get("situation") or data["atoms"].get("parameters"):
        out.append("dùng bảng thuật ngữ thì «atoms» phải rỗng; khái niệm mới phải đề xuất trong «glossary_proposals»")
    props = data.get("glossary_proposals", {})
    if not isinstance(props, dict) or not all(isinstance(props.get(k, []), list) for k in ("acts", "atoms")):
        out.append("«glossary_proposals» phải có dạng {\"acts\": [...], \"atoms\": [...]}")
        props = {}
    p_acts = [e for e in props.get("acts", []) if isinstance(e, dict)]
    p_atoms = [e for e in props.get("atoms", []) if isinstance(e, dict)]
    if len(p_acts) + len(p_atoms) != len(props.get("acts", [])) + len(props.get("atoms", [])):
        out.append("«glossary_proposals»: mỗi mục phải là một đối tượng JSON")
    for e in p_acts + p_atoms:
        if "status" in e:
            out.append("glossary_proposals «%s»: không ghi «status» (đề xuất luôn là proposed)" % e.get("id"))
    pg = {"doc_id": data["doc_id"], "acts": [dict(e, status="proposed") for e in p_acts],
          "atoms": [dict(e, status="proposed") for e in p_atoms]}
    out += ["glossary_proposals: " + f for f in G.check(pg)]
    known = {e.get("id") for e in g["acts"] + g["atoms"]}
    for e in p_acts + p_atoms:
        if e.get("id") in known:
            out.append("glossary_proposals «%s»: id đã có trong bảng; dùng mục đó, không đề xuất lại" % e["id"])
    rejected = {e["id"] for e in g["acts"] + g["atoms"] if e.get("status") == "rejected"}
    live_acts = [e for e in g["acts"] if e.get("status") != "rejected"]
    live_atoms = [e for e in g["atoms"] if e.get("status") != "rejected"] + p_atoms

    def as_atom(e):
        dom = e.get("domain")
        if dom != "bool" and not (isinstance(dom, list) and all(isinstance(b, dict) for b in dom)):
            dom = []          # malformed (already a finding): no label can match
        return {"name": e.get("id"), "domain": dom}

    acts = {e["id"] for e in live_acts} | {e.get("id") for e in p_acts}
    sit = {e.get("id"): as_atom(e) for e in live_atoms if e.get("kind") == "situation"}
    par = {e.get("id"): as_atom(e) for e in live_atoms if e.get("kind") == "parameter"}
    return acts, sit, par, rejected


def unapproved_terms(data):
    """Glossary mode: the acts and atoms the norms use whose status is not `approved` (proposals included), as
    sorted «id [status]» strings. `promote.py` must refuse a translation while this is not empty (ADR-0027 step 3)."""
    if "glossary" not in data:
        return []
    _, g, _ = load_glossary(data["doc_id"])
    status = {e["id"]: e.get("status") for e in g["acts"] + g["atoms"]}
    acts, atoms = used_terms(data)
    return sorted("%s [%s]" % (t, status.get(t, "đề xuất")) for t in acts | atoms if status.get(t) != "approved")


def not_merged_yet(data):
    """Findings for a step that cannot handle glossary mode yet (Lean draft, merge, review sheet): fail closed."""
    if "glossary" in data:
        return ["bản dịch dùng bảng thuật ngữ; gộp atom theo id (ADR-0027 bước 3) chưa làm, nên chưa sinh Lean, chưa gộp"
                " và chưa lập phiếu được cho tệp này"]
    return []


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
    acts, rejected = None, set()          # acts None: no glossary, any snake_case act
    if "glossary" in data:
        acts, sit, par, rejected = glossary_terms(data, out)
    elif "glossary_proposals" in data:
        out.append("«glossary_proposals» chỉ dùng cùng «glossary»")
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
        elif acts is not None and n["act"] not in acts:
            out.append("%s: act «%s» %s" % (w, n["act"], "là mục bị bác của bảng thuật ngữ" if n["act"] in rejected
                                            else "không có trong bảng thuật ngữ hay «glossary_proposals»"))
        r = check_ref(seg, n.get("source"), w, out, n.get("quote") if isinstance(n.get("quote"), str) and n["quote"] else None)
        if not n.get("quote"):
            out.append("%s: thiếu «quote»" % w)
        if r is not None and r["article"] != data["article"]:
            out.append("%s: nguồn thuộc Điều %d, không phải Điều %d của bản dịch này" % (w, r["article"], data["article"]))
        refs.append(r)
        walk_cond(n.get("condition"), sit, par, w + ".condition", out)
        refs_n = n.get("references", [])
        if not isinstance(refs_n, list):
            out.append("%s: references phải là danh sách" % w)
        else:
            for x in refs_n:
                rr = check_ref(seg, x, "%s, dẫn chiếu" % w, out)
                if rr is not None and (rr["branch"] or rr["heading"]):
                    out.append("%s: dẫn chiếu «%s» phải là một đơn vị của luật (không dùng «nhánh» hay «tiêu đề»)" % (w, x))
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
    for t in sorted(used_terms(data)[1] & rejected):
        out.append("atom «%s» là mục bị bác của bảng thuật ngữ; không được dùng" % t)
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


def unit_ids(seg):
    """Every legal unit of the document, in canonical spelling: «Điều N», «Điều N khoản K», «Điều N khoản K điểm x».
    This is the catalog the Lean dangling-reference check uses, so a reference to a clause or a point is checked too."""
    out = []
    for a in seg["articles"]:
        out.append(a["id"])
        for c in a["clauses"]:
            out.append(c["id"])
            out += [p["id"] for p in c["points"]]
    return out


def catalog_lean(seg):
    return "def catalog : List String :=\n  [ " + "\n  , ".join(lq(u) for u in unit_ids(seg)) + " ]"


def refs_lean(n):
    return "[" + ", ".join(lq(r) for r in n.get("references", [])) + "]"


def to_lean(data, seg):
    sit, par = data["atoms"]["situation"], data["atoms"]["parameters"]
    rs, sl = readers(sit)
    rp, pl = readers(par)
    y, m, d = (int(x) for x in data["effective"].split("-"))
    acts = sorted({n["act"] for n in data["norms"]})
    L = ["import LexProof.Verify.AnalyzeReport", "import LexProof.Core.Render", "",
         "/-! DRAFT, NOT HUMAN-REVIEWED. Machine-translated from the text of %s by pipeline/translate.py (LLM answer, pasted by hand)." % (
             data.get("label") or "Điều %d" % data["article"]),
         "Not part of the library: it is NOT in `LexProof/Laws/`, and moving it there needs a human review first.",
         "Assumptions the translator declared (each is a reading of the law that a reviewer must accept or reject):"]
    L += ["* " + str(a).replace("-/", "- /") for a in data["assumptions"]] or ["* (none declared)"]
    L += ["-/", "", "namespace Draft", "open LexProof", "", "def tS : AtomTable :=",
          "  [ " + "\n  , ".join(atom_lean(a) for a in sit) + " ]" if sit else "  []", "",
          "def tP : AtomTable :=", ("  [ " + "\n  , ".join(atom_lean(a) for a in par) + " ]") if par else "  []", "",
          "def rS : List ReaderSpec :=", ("  [ " + "\n  , ".join("(%s, %d, %d)" % (lq(n), i, j) for n, i, j in rs) + " ]") if rs else "  []", "",
          "def rP : List ReaderSpec :=", ("  [ " + "\n  , ".join("(%s, %d, %d)" % (lq(n), i, j) for n, i, j in rp) + " ]") if rp else "  []", "",
          catalog_lean(seg), "",
          "private def nrm (id : String) (mo : Modality) (act : String) (c : Cond) (ex : List Cond) (art : String)",
          "    (refs : List String) : Norm :=",
          "  { id := id, modality := mo, act := act, condition := c, exceptions := ex, priority := none",
          "  , source := { docId := %s, docType := %s, effective := ⟨%d, %d, %d⟩, article := art }" % (
              lq(data["doc_id"]), DOC_TYPES[data["doc_type"]], y, m, d),
          "  , references := refs }", "", "def norms : List Norm :="]
    ns = []
    for n in data["norms"]:
        ex = "[" + ", ".join(cond_lean(e, sl, pl) for e in n["exceptions"]) + "]"
        ns.append("nrm %s %s %s %s %s %s %s" % (lq(n["id"]), MODALITIES[n["modality"]], lq(n["act"]),
                                                cond_lean(n["condition"], sl, pl), ex, lq(n["source"]), refs_lean(n)))
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
    p.add_argument("--glossary", action="store_true", help="liệt kê bảng thuật ngữ của văn bản; bản dịch phải dùng id của bảng (ADR-0027)")
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
        gl = None
        if a.glossary:
            G, g, rel = load_glossary(a.doc)
            gfs = G.check(g)
            if gfs:
                print("TỪ CHỐI: bảng thuật ngữ %s có %d phát hiện; chạy `python pipeline/glossary.py check %s`." % (rel, len(gfs), rel))
                return 1
            gl = (g, rel)
        text = make_prompt(seg, a.article, gl)
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
        un = unapproved_terms(data)
        if un:
            print("dùng %d thuật ngữ chưa duyệt (promote sẽ từ chối cho tới khi bảng duyệt chúng): %s" % (len(un), ", ".join(un)))
        return 0
    nm = not_merged_yet(data)
    if nm:
        print("TỪ CHỐI: " + nm[0])
        return 1
    seg = load_segmented(data["doc_id"])
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    with open(a.out, "w", encoding="utf-8", newline="\n") as f:
        f.write(to_lean(data, seg))
    print(a.out)
    return 0


if __name__ == "__main__":
    sys.exit(main())
