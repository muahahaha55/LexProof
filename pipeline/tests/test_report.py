# -*- coding: utf-8 -*-
"""Tests for pipeline/report.py. Run: python -m unittest discover -s pipeline/tests -v   (from the repo root)

They run the real Lean dump once (`lake env lean --run eval/report/Dump.lean`, a few seconds) and need `lake` on PATH.
`lake build` is not run here (the CI step runs after it). Nothing is written under reports/.
"""
import copy
import os
import re
import shutil
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import report as R   # noqa: E402

CFG = R.MODULES["alcohol-sale"]
DATE = "2000-01-01"
FORBIDDEN = ["hợp pháp", "đúng luật", "được kiểm chứng"]
DATA = EXTRA = None


def setUpModule():
    global DATA, EXTRA
    if shutil.which("lake") is None:
        raise unittest.SkipTest("lake không có trong PATH")
    DATA = R.collect(CFG, build=False)
    EXTRA = R.build_extra(CFG)


def draft(data=None, today=DATE):
    return R.render(CFG, data or DATA, "draft", None, today, EXTRA)


def section(text, n):
    m = re.search(r"^## %d\. .*?(?=^## \d\. |\Z)" % n, text, re.S | re.M)
    return m.group(0) if m else ""


def sheet_text(ids, module_sha, skip=None, cases_sha="auto"):
    """A synthetic, fully answered review sheet (the real sheet is blank)."""
    head = "| Mã | Tình huống | Câu hỏi | Khoản chính | Thêm | Đúng ý / Sai ý | Câu trả lời | Ghi chú | Người duyệt | Ngày |\n"
    rows = []
    for cid in ids:
        if cid == skip:
            rows.append("| %s | t | q | k | m | ☐ Đúng ý<br>☐ Sai ý | ☒ cấm<br>☐ không biết |  | N. V. A | 2026-10-31 |" % cid)
        else:
            rows.append("| %s | t | q | k | m | ☒ Đúng ý<br>☐ Sai ý | ☒ cấm<br>☐ không biết |  | N. V. A | 2026-10-31 |" % cid)
    cs = EXTRA["cases_lf"] if cases_sha == "auto" else cases_sha
    h = "\nsha256 mô-đun khi duyệt: %s\n" % module_sha if module_sha else "\n"
    if cs:
        h += "sha256 tệp ca thử khi duyệt: %s\n" % cs
    return head + "|---|---|---|---|---|---|---|---|---|---|\n" + "\n".join(rows) + "\n" + h


def write_tmp(text):
    fd, path = tempfile.mkstemp(suffix=".md", text=True)
    with os.fdopen(fd, "w", encoding="utf-8") as f:
        f.write(text)
    return path


def reviewed(text):
    path = write_tmp(text)
    try:
        return R.make_report(CFG, DATA, "reviewed", "N. V. A", "2026-11-01", path, DATE, EXTRA)
    finally:
        os.remove(path)


def ids():
    return [c["id"] for c in DATA["cases"]]


class Always(unittest.TestCase):
    def test_banner_and_section6_in_draft(self):
        t = draft()
        self.assertIn("# BẢN NHÁP, CHƯA CÓ NGƯỜI DUYỆT", section(t, 1))
        self.assertIn("không phải tư vấn pháp lý".lower(), section(t, 6).lower())
        self.assertIn("Ràng buộc toàn vẹn không được dùng", section(t, 6))
        self.assertIn("chưa được so với văn bản in", section(t, 6))

    def test_banner_and_section6_in_reviewed(self):
        t = reviewed(sheet_text(ids(), EXTRA["module_lf"]))
        self.assertIn("PHIẾU CA THỬ ĐÃ ĐƯỢC ĐIỀN", section(t, 1))
        self.assertIn("không có nghĩa bản mã hóa khớp luật", section(t, 1))
        self.assertIn("KHÔNG nói gì", section(t, 6))

    def test_forbidden_phrases_only_in_negating_sentences_of_section6(self):
        for t in (draft(), reviewed(sheet_text(ids(), EXTRA["module_lf"]))):
            s6 = section(t, 6)
            outside = t.replace(s6, "")
            for p in FORBIDDEN:
                self.assertNotIn(p, outside, "«%s» ngoài mục 6" % p)
                for line in s6.splitlines():
                    if p in line:
                        self.assertTrue(re.search(r"[Kk]hông|chưa", line), "câu không phủ định: " + line)

    def test_scope_section_always_present_with_ledger_totals(self):
        s2 = section(draft(), 2)
        self.assertIn("141", s2)
        self.assertIn("không phải thước đo độ trung thực", s2)
        self.assertIn("UNACCOUNTED", s2)

    def test_section3_leads_with_vacuity_and_three_values(self):
        s3 = section(draft(), 3)
        body = s3.split("\n", 2)[2].lstrip()
        self.assertTrue(body.startswith("> **Nói trước"), body[:80])
        self.assertIn("RỖNG về thông tin", s3)
        self.assertIn("tìm thấy xung đột / nhất quán trên phần đã mã hóa / không biết", s3)

    def test_every_headline_names_a_theorem_or_says_none(self):
        s3 = section(draft(), 3)
        self.assertIn("LexProof.Laws.AlcoholSaleCases.pass_set", s3)
        self.assertIn("chưa có định lý kernel cho kết quả này", s3)
        self.assertNotIn("KHÔNG KHỚP", s3)

    def test_out_of_scope_listed_apart_and_not_among_passes(self):
        s5 = section(draft(), 5)
        outs = s5.split("### outOfScope")[1].split("### PASS")[0]
        passes = s5.split("### PASS")[1].split("### Ca số")[0]
        for cid in ("C23", "C24"):
            self.assertIn("| %s |" % cid, outs)
            self.assertNotIn("| %s |" % cid, passes)
        self.assertIn("noNormApplies và outOfScope không nói gì về luật", s5)

    def test_every_noNormApplies_row_carries_scope_status(self):
        s5 = section(draft(), 5)
        for line in s5.splitlines():
            if line.startswith("| C") and "noNormApplies" in line:
                self.assertRegex(line, r"trong phạm vi|NGOÀI PHẠM VI")


class InjectedFailure(unittest.TestCase):
    def test_failing_case_is_listed(self):
        d = copy.deepcopy(DATA)
        c = d["cases"][0]
        c["outcome"], c["got"] = "fail", "noNormApplies"
        t = draft(d)
        fail = section(t, 5).split("### FAIL")[1].split("### UNDERSPECIFIED")[0]
        self.assertIn("| %s |" % c["id"], fail)
        self.assertIn("FAIL 1", section(t, 5))
        # the interpreter no longer agrees with `pass_set`: the report says so
        self.assertIn("KHÔNG KHỚP", section(t, 3))
        self.assertIn("CẢNH BÁO", section(t, 3))

    def test_unsound_is_not_hidden_by_changing_status(self):
        d = copy.deepcopy(DATA)
        d["analyze"]["result"] = "conflicts"
        d["analyze"]["hits"] = ["a × b"]
        t = draft(d)
        self.assertIn("TÌM THẤY XUNG ĐỘT", section(t, 3))
        self.assertNotIn("Nói trước", section(t, 3))


class ReviewedRefusals(unittest.TestCase):
    def test_blank_sheet_is_refused(self):
        blank = sheet_text(ids(), EXTRA["module_lf"]).replace("☒", "☐").replace("N. V. A", "").replace("2026-10-31", "")
        with self.assertRaises(SystemExit) as cm:
            reviewed(blank)
        self.assertIn("TỪ CHỐI", str(cm.exception))
        self.assertIn("chưa điền", str(cm.exception))

    def test_incomplete_sheet_refused(self):
        with self.assertRaises(SystemExit) as cm:
            reviewed(sheet_text(ids(), EXTRA["module_lf"], skip="C10"))
        self.assertIn("ca C10 chưa điền", str(cm.exception))
        self.assertNotIn("ca C09", str(cm.exception))

    def test_missing_row_refused(self):
        with self.assertRaises(SystemExit) as cm:
            reviewed(sheet_text(ids()[:-1], EXTRA["module_lf"]))
        self.assertIn("không có hàng cho ca %s" % ids()[-1], str(cm.exception))

    def test_changed_module_hash_refused(self):
        with self.assertRaises(SystemExit) as cm:
            reviewed(sheet_text(ids(), "0" * 64))
        self.assertIn("mô-đun đã đổi", str(cm.exception))

    def test_changed_or_missing_cases_hash_refused(self):
        with self.assertRaises(SystemExit) as cm:
            reviewed(sheet_text(ids(), EXTRA["module_lf"], cases_sha="0" * 64))
        self.assertIn("các ca đã đổi sau khi duyệt", str(cm.exception))
        with self.assertRaises(SystemExit) as cm:
            reviewed(sheet_text(ids(), EXTRA["module_lf"], cases_sha=None))
        self.assertIn("sha256 tệp ca thử khi duyệt", str(cm.exception))

    def test_missing_module_hash_refused(self):
        with self.assertRaises(SystemExit) as cm:
            reviewed(sheet_text(ids(), None))
        self.assertIn("sha256 mô-đun khi duyệt", str(cm.exception))

    def test_no_reviewer_name_or_bad_date_refused(self):
        with self.assertRaises(SystemExit):
            R.make_report(CFG, DATA, "reviewed", None, "2026-11-01", None, DATE, EXTRA)
        with self.assertRaises(SystemExit):
            R.make_report(CFG, DATA, "reviewed", "X", "01/11/2026", None, DATE, EXTRA)

    def test_accepted_records_both_hashes(self):
        text = sheet_text(ids(), EXTRA["module_lf"])
        t = reviewed(text)
        import hashlib
        self.assertIn(hashlib.sha256(text.encode("utf-8")).hexdigest(), t)
        self.assertIn("sha256 mô-đun ghi trong phiếu khi duyệt (bằng tệp mô-đun hiện tại): `%s`" % EXTRA["module_lf"], t)
        self.assertIn("N. V. A", t)

    def test_by_must_be_in_sheet_and_dates_must_be_valid(self):
        text = sheet_text(ids(), EXTRA["module_lf"])
        path = write_tmp(text)
        try:
            with self.assertRaises(SystemExit) as cm:
                R.make_report(CFG, DATA, "reviewed", "Người Khác", "2026-11-01", path, DATE, EXTRA)
            self.assertIn("không có trong cột Người duyệt", str(cm.exception))
        finally:
            os.remove(path)
        with self.assertRaises(SystemExit) as cm:   # review date earlier than the row dates (2026-10-31)
            R.make_report(CFG, DATA, "reviewed", "N. V. A", "2026-10-01", write_tmp(text), DATE, EXTRA)
        self.assertIn("muộn hơn --date", str(cm.exception))
        with self.assertRaises(SystemExit) as cm:
            reviewed(text.replace("2026-10-31", "31/10/2026"))
        self.assertIn("không phải YYYY-MM-DD", str(cm.exception))

    def test_ai_draft_rows_are_disclosed_in_banner(self):
        text = sheet_text(ids(), EXTRA["module_lf"])
        self.assertNotIn("không phải trả lời độc lập", section(reviewed(text), 1))
        marked = text.replace("☒ cấm<br>☐ không biết |  |", "☒ cấm<br>☐ không biết | Đồng thuận với bản nháp AI |")
        self.assertEqual(R.ai_draft_rows(R.parse_sheet(marked)), sorted(ids()))
        s1 = section(reviewed(marked), 1)
        self.assertIn("%d/%d hàng" % (len(ids()), len(ids())), s1)
        self.assertIn("không phải trả lời độc lập", s1)

    def test_answered(self):
        self.assertFalse(R.answered("☐ cấm<br>☐ không biết"))
        self.assertTrue(R.answered("☒ cấm<br>☐ không biết"))
        self.assertFalse(R.answered("☒ cấm<br>☒ không biết"))
        self.assertFalse(R.answered(""))
        self.assertTrue(R.answered("N. V. A"))


class Determinism(unittest.TestCase):
    def test_two_runs_identical_apart_from_date_line(self):
        d2 = R.collect(CFG, build=False)
        a = R.render(CFG, DATA, "draft", None, "2026-01-01", EXTRA)
        b = R.render(CFG, d2, "draft", None, "2027-02-02", R.build_extra(CFG))
        strip = lambda t: "\n".join(x for x in t.splitlines() if not x.startswith("- Ngày tạo báo cáo"))
        self.assertNotEqual(a, b)
        self.assertEqual(strip(a), strip(b))
        self.assertEqual(sum(x.startswith("- Ngày tạo báo cáo") for x in a.splitlines()), 1)


class Parsers(unittest.TestCase):
    def test_ledger_totals_match_segmented_text(self):
        led = EXTRA["ledger"]
        self.assertEqual(led["rows"]["Cộng"], (141, 45, 6))
        seg = EXTRA["segmented"]
        k = sum(1 for a in seg["articles"] for c in a["clauses"] if c["number"] != 0)
        p = sum(len(c["points"]) for a in seg["articles"] for c in a["clauses"])
        u = sum(1 for a in seg["articles"] if a["lead_in"])
        self.assertEqual((k, p, u), (141, 45, 6))
        self.assertEqual(led["unaccounted_total"], 21)
        self.assertEqual(len(led["unaccounted_units"]), 21)


if __name__ == "__main__":
    unittest.main()
