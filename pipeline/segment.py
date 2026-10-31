# -*- coding: utf-8 -*-
"""Deterministic segmenter for data/extracted/44-2019-QH14.txt (no LLM, no network).

usage: python pipeline/segment.py [--in PATH] [--out PATH] [--no-write]

Writes data/segmented/44-2019-QH14.json: chapters, articles, clauses (khoản), points (điểm), each with
id, text and line numbers in the extracted file, plus the sha256 of the input and the tool version.
Two runs give byte-identical output (no timestamp, fixed key order, LF).

Untrusted tool: it reads a text file and classifies lines by indentation and leading tokens. The checks
S1..S5 (`check_*`) say whether the result is self-consistent; none of them says the segmentation is the law.
"""
import hashlib
import json
import os
import re
import sys

TOOL_VERSION = "segment.py 1.0"
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))
DEFAULT_IN = os.path.join(ROOT, "data", "extracted", "44-2019-QH14.txt")
DEFAULT_OUT = os.path.join(ROOT, "data", "segmented", "44-2019-QH14.json")

# Pinned sha256 of the extracted file the segmenter was written against (change detector, not a proof).
PINNED_SHA256 = "e0ca5a521ff91a604523bea006c082e38655855466f7bb2379414d36bf199752"

RUNNING_PAGE_PATTERN = r"^\x0c?(?:\d+\s+)?CÔNG BÁO/Số 559 \+ 560/Ngày 17-7-2019(?:\s+\d+)?\s*$"
RUNNING_PAGE = re.compile(RUNNING_PAGE_PATTERN)
STAMP = re.compile(r"^(?:Ký bởi|Email|Cơ quan|Thời gian ký):")
CHAPTER = re.compile(r"^\s*Chương ([IVXLC]+)\s*$")
ARTICLE = re.compile(r"^\s+Điều (\d+)\.\s+(\S.*)$")
CLAUSE = re.compile(r"^\s+(\d+)\.\s+\S")
POINT = re.compile(r"^\s+([a-zđ])\)\s+\S")
CLOSING = re.compile(r"^\s+Luật này được Quốc hội")

ROMAN = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100}


def roman(s):
    t = 0
    for i, ch in enumerate(s):
        v = ROMAN[ch]
        t += -v if i + 1 < len(s) and ROMAN[s[i + 1]] > v else v
    return t


def read_lines(path):
    raw = open(path, "rb").read()
    text = raw.decode("utf-8")
    return hashlib.sha256(raw).hexdigest(), text.split("\r\n") if "\r\n" in text else text.split("\n")


def segment(lines):
    """Returns the document dict. `lines[i-1]` is line i."""
    cls = {}                      # line number -> class
    chapters, articles = [], []
    cur_ch = cur_art = cur_cl = cur_pt = None
    title_mode = False            # inside the (uppercase) title of a chapter
    head_cont = False             # directly after an article heading line
    closing = False
    stray_paragraphs = 0          # indented, unnumbered paragraphs inside a clause/point

    def own(node, n):
        node["body_lines"].append(n)

    for n, line in enumerate(lines, 1):
        s = line.strip()
        if s == "":
            cls[n] = "blank"; head_cont = False
            continue
        if closing:
            cls[n] = "running_page" if RUNNING_PAGE.match(line) else "signature"
            continue
        if RUNNING_PAGE.match(line):
            cls[n] = "running_page"; head_cont = False
            continue
        if cur_ch is None and STAMP.match(line):
            cls[n] = "signature"
            continue
        m = CHAPTER.match(line)
        if m:
            cur_ch = {"id": m.group(1), "number": roman(m.group(1)), "title_lines": [], "heading_lines": [n],
                      "title": "", "articles": []}
            chapters.append(cur_ch)
            cur_art = cur_cl = cur_pt = None
            title_mode = True; head_cont = False
            cls[n] = "chapter_heading"
            continue
        if cur_ch is None:
            cls[n] = "preamble"
            continue
        if title_mode and s.isupper():
            cur_ch["heading_lines"].append(n); cur_ch["title_lines"].append(s)
            cls[n] = "chapter_heading"
            continue
        m = ARTICLE.match(line)
        if m:
            title_mode = False
            cur_art = {"number": int(m.group(1)), "id": "Điều " + m.group(1), "chapter": cur_ch["id"],
                       "title": m.group(2).strip(), "heading_lines": [n], "lead_in": None, "clauses": []}
            articles.append(cur_art); cur_ch["articles"].append(cur_art["number"])
            cur_cl = cur_pt = None
            head_cont = True
            cls[n] = "article_heading"
            continue
        title_mode = False
        if cur_art is None:
            cls[n] = "unclassified"
            continue
        if head_cont and not line.startswith(" "):
            cur_art["title"] += " " + s; cur_art["heading_lines"].append(n)
            cls[n] = "article_heading"
            continue
        head_cont = False
        if CLOSING.match(line):
            closing = True
            cls[n] = "signature"
            continue
        m = CLAUSE.match(line)
        if m:
            cur_cl = {"number": int(m.group(1)), "id": "%s khoản %s" % (cur_art["id"], m.group(1)),
                      "body_lines": [n], "points": []}
            cur_art["clauses"].append(cur_cl); cur_pt = None
            cls[n] = "body"
            continue
        m = POINT.match(line)
        if m:
            cur_pt = {"letter": m.group(1), "body_lines": [n],
                      "id": "%s%s điểm %s" % (cur_art["id"], (" khoản %d" % cur_cl["number"]) if cur_cl else "", m.group(1))}
            if cur_cl is None:  # a point with no clause: kept under a pseudo-clause 0 so nothing is dropped
                cur_cl = {"number": 0, "id": cur_art["id"] + " (không khoản)", "body_lines": [], "points": []}
                cur_art["clauses"].append(cur_cl)
            cur_cl["points"].append(cur_pt)
            cls[n] = "body"
            continue
        # continuation: of the open point, else of the open clause, else the article's unnumbered lead-in
        if cur_pt is not None:
            own(cur_pt, n)
        elif cur_cl is not None:
            own(cur_cl, n)
        else:
            if cur_art["lead_in"] is None:
                cur_art["lead_in"] = {"body_lines": []}
            cur_art["lead_in"]["body_lines"].append(n)
        if line.startswith(" ") and (cur_pt or cur_cl):
            stray_paragraphs += 1
        cls[n] = "body"

    def fill(node):
        bl = node["body_lines"]
        node["start"], node["end"] = (bl[0], bl[-1]) if bl else (None, None)
        node["text"] = "\n".join(lines[i - 1] for i in bl)

    for ch in chapters:
        ch["title"] = " ".join(ch.pop("title_lines"))
    for a in articles:
        if a["lead_in"]:
            fill(a["lead_in"])
        for c in a["clauses"]:
            fill(c)
            for p in c["points"]:
                fill(p)
    return {"chapters": chapters, "articles": articles, "line_class": cls, "stray_paragraphs": stray_paragraphs}


def runs(cls, n_lines):
    """Run-length encoding [class, first, last]."""
    out = []
    for i in range(1, n_lines + 1):
        c = cls[i]
        if out and out[-1][0] == c and out[-1][2] == i - 1:
            out[-1][2] = i
        else:
            out.append([c, i, i])
    return out


def to_json(doc, sha, n_lines, in_name):
    d = {"tool": TOOL_VERSION, "input": {"path": in_name, "sha256": sha, "lines": n_lines},
         "line_class_runs": runs(doc["line_class"], n_lines),
         "stray_paragraphs": doc["stray_paragraphs"],
         "chapters": doc["chapters"], "articles": doc["articles"]}
    return json.dumps(d, ensure_ascii=False, indent=1) + "\n"


# ----------------------------------------------------------------------------- checks (S1..S5)

def check_S1(doc):
    chs, arts = doc["chapters"], doc["articles"]
    nums = [a["number"] for a in arts]
    ch_ok = [c["number"] for c in chs] == list(range(1, len(chs) + 1))
    problems = []
    if len(chs) != 7: problems.append("số chương %d (kỳ vọng 7)" % len(chs))
    if not ch_ok: problems.append("chương không liên tục: %s" % [c["id"] for c in chs])
    if len(arts) != 36: problems.append("số điều %d (kỳ vọng 36)" % len(arts))
    if nums != list(range(1, len(nums) + 1)): problems.append("điều không liên tục từ 1: %s" % nums)
    # an article must follow the previous article in file order and its chapter in chapter order
    return {"ok": not problems, "chapters": len(chs), "articles": len(arts), "problems": problems,
            "per_chapter": {c["id"]: (c["articles"][0], c["articles"][-1], len(c["articles"])) if c["articles"] else None
                            for c in chs}}


def check_S2(doc, lines):
    cls = doc["line_class"]
    n = len(lines)
    counts = {}
    for i in range(1, n + 1):
        counts[cls[i]] = counts.get(cls[i], 0) + 1
    unclassified = [i for i in range(1, n + 1) if cls[i] == "unclassified"]
    running = [i for i in range(1, n + 1) if cls[i] == "running_page"]
    # "exactly once": every line number 1..n has exactly one class
    once = sorted(cls) == list(range(1, n + 1))
    return {"ok": once and not unclassified, "lines": n, "counts": dict(sorted(counts.items())),
            "unclassified": unclassified, "running_page_pattern": RUNNING_PAGE_PATTERN, "running_page_lines": running,
            "sum_counts": sum(counts.values())}


VN_LEGAL = list("abcdđeghiklmnopqrstuvxy")          # the order used in Vietnamese legal drafting (skips f j w z)
LATIN_D = list("abcdđefghijklmnopqrstuvwxyz")        # the Latin order with đ after d


def check_S3(doc):
    problems, seqs = [], {}
    for a in doc["articles"]:
        nums = [c["number"] for c in a["clauses"] if c["number"] != 0]
        if nums and nums != list(range(1, len(nums) + 1)):
            problems.append("%s: khoản %s (không liên tục từ 1)" % (a["id"], nums))
        for c in a["clauses"]:
            if c["number"] == 0 and c["points"]:
                problems.append("%s: điểm không có khoản" % a["id"])
            ls = [p["letter"] for p in c["points"]]
            if not ls:
                continue
            seqs[c["id"]] = "".join(ls)
            if len(set(ls)) != len(ls):
                problems.append("%s: điểm lặp %s" % (c["id"], ls))
            elif ls != VN_LEGAL[:len(ls)] and ls != LATIN_D[:len(ls)]:
                problems.append("%s: dãy điểm %s không phải đầu dãy nào trong hai bảng chữ" % (c["id"], ls))
    return {"ok": not problems, "problems": problems, "point_sequences": seqs}


def check_S4(doc, notes):
    """notes: {article: total rows in docs/slice1-notes.md}. Reports every difference, tunes nothing."""
    rows = []
    for k, tot in notes.items():
        a = doc["articles"][k - 1]
        K = sum(1 for c in a["clauses"] if c["number"] != 0)
        P = sum(len(c["points"]) for c in a["clauses"])
        L = 1 if a["lead_in"] else 0
        rows.append({"article": k, "notes_total": tot, "heading": 1, "lead_in": L, "clauses": K, "points": P,
                     "clauses+points": K + P, "heading+lead_in+clauses+points": 1 + L + K + P,
                     "diff_vs_clauses+points": tot - (K + P), "diff_vs_all_rows": tot - (1 + L + K + P)})
    return rows


def check_S5(doc, lines):
    bad = []
    cls = doc["line_class"]

    def chk(node):
        bl = node["body_lines"]
        if not bl:
            return
        if node["text"] != "\n".join(lines[i - 1] for i in bl):
            bad.append((node.get("id", "lead-in"), "text khác dòng nguồn"))
        if bl != sorted(set(bl)):
            bad.append((node.get("id", "lead-in"), "body_lines không tăng"))
        if node["start"] != bl[0] or node["end"] != bl[-1]:
            bad.append((node.get("id", "lead-in"), "start/end sai"))
        for i in range(node["start"], node["end"] + 1):
            if i not in bl and cls[i] not in ("blank", "running_page", "body"):
                # lines between two own lines may be the lines of a child (points) or blank/page lines
                bad.append((node.get("id", "lead-in"), "dòng %d (%s) nằm trong khoảng mà không thuộc node" % (i, cls[i])))

    for a in doc["articles"]:
        if a["lead_in"]:
            chk(a["lead_in"])
        for c in a["clauses"]:
            chk(c)
            for p in c["points"]:
                chk(p)
    # every body line belongs to exactly one node
    owners = {}
    for a in doc["articles"]:
        for node in ([a["lead_in"]] if a["lead_in"] else []) + [x for c in a["clauses"] for x in [c] + c["points"]]:
            for i in node["body_lines"]:
                owners[i] = owners.get(i, 0) + 1
    body = [i for i, c in cls.items() if c == "body"]
    for i in body:
        if owners.get(i, 0) != 1:
            bad.append(("dòng %d" % i, "thuộc %d node" % owners.get(i, 0)))
    return {"ok": not bad, "problems": bad[:20], "problem_count": len(bad), "body_lines": len(body)}


def check_input_pin(sha, pinned):
    return {"ok": pinned is None or sha == pinned, "sha256": sha, "pinned": pinned}


def run(path):
    sha, lines = read_lines(path)
    doc = segment(lines)
    return sha, lines, doc


def main(argv):
    sys.stdout.reconfigure(encoding="utf-8")
    inp, out, write = DEFAULT_IN, DEFAULT_OUT, True
    i = 0
    while i < len(argv):
        if argv[i] == "--in": inp = argv[i + 1]; i += 1
        elif argv[i] == "--out": out = argv[i + 1]; i += 1
        elif argv[i] == "--no-write": write = False
        i += 1
    sha, lines, doc = run(inp)
    text = to_json(doc, sha, len(lines), os.path.relpath(inp, ROOT).replace("\\", "/"))
    if write:
        os.makedirs(os.path.dirname(out), exist_ok=True)
        open(out, "w", encoding="utf-8", newline="\n").write(text)
    notes = {2: 9, 5: 14, 10: 8, 12: 13, 13: 4, 19: 7}
    res = {"S0_pin": check_input_pin(sha, PINNED_SHA256), "S1": check_S1(doc), "S2": check_S2(doc, lines),
           "S3": check_S3(doc), "S5": check_S5(doc, lines)}
    print(json.dumps({"sha256": sha, "lines": len(lines), **{k: res[k] for k in res}, "S4": check_S4(doc, notes),
                      "stray_paragraphs": doc["stray_paragraphs"]}, ensure_ascii=False, indent=1))
    return 0 if all(res[k]["ok"] for k in ("S0_pin", "S1", "S2", "S5")) else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
