# -*- coding: utf-8 -*-
"""Tests for pipeline/promote.py. Sheets here are SYNTHETIC (filled by the test, reviewer «TEST»): they exercise the
gate, they are not reviews. Nothing is written into LexProof/ (the library files are replaced by temp copies)."""
import copy
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import promote as P   # noqa: E402
import translate as T   # noqa: E402

GOLD_PATH = os.path.join(T.ROOT, "eval", "translate", "article19.gold.json")
GOLD = json.load(open(GOLD_PATH, encoding="utf-8"))
HAS_LAKE = shutil.which("lake") is not None


def fill(text, reviewer="TEST", date="2000-01-01"):
    t = text.replace("Người duyệt: ", "Người duyệt: " + reviewer, 1)
    t = t.replace("Ngày duyệt (YYYY-MM-DD): ", "Ngày duyệt (YYYY-MM-DD): " + date, 1)
    t = t.replace("☐ Chấp nhận<br>☐ Bác", "☒ Chấp nhận<br>☐ Bác")
    return t.replace("☐ Đồng ý để ngoài<br>", "☒ Đồng ý để ngoài<br>")


def edit_row(text, prefix, old, new):
    lines = text.splitlines()
    for i, line in enumerate(lines):
        if line.startswith(prefix):
            lines[i] = line.replace(old, new)
    return "\n".join(lines)


class Base(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()

    def tearDown(self):
        shutil.rmtree(self.dir)

    def files(self, data=GOLD, edit=None):
        tr = os.path.join(self.dir, "t.json")
        with open(tr, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False)
        text = fill(P.make_sheet(tr, data))
        if edit:
            text = edit(text)
        sh = os.path.join(self.dir, "s.md")
        with open(sh, "w", encoding="utf-8") as f:
            f.write(text)
        return tr, sh

    def problems(self, data=GOLD, edit=None):
        tr, sh = self.files(data, edit)
        with open(sh, encoding="utf-8") as f:
            return P.sheet_problems(data, tr, P.parse_sheet(f.read()))


class Gate(Base):
    def test_blank_sheet_is_refused_row_by_row(self):
        tr = os.path.join(self.dir, "t.json")
        with open(tr, "w", encoding="utf-8") as f:
            json.dump(GOLD, f, ensure_ascii=False)
        ps, _ = P.sheet_problems(GOLD, tr, P.parse_sheet(P.make_sheet(tr, GOLD)))
        self.assertIn("chưa ghi người duyệt", ps)
        self.assertTrue(any("norm 19.6" in p for p in ps))
        self.assertTrue(any("A:1" in p for p in ps))

    def test_complete_sheet_passes(self):
        ps, dec = self.problems()
        self.assertEqual(ps, [])
        self.assertEqual(len(dec["accepted"]), 6)

    def test_rejection_needs_a_reason_and_becomes_not_encoded(self):
        ps, _ = self.problems(edit=lambda t: edit_row(t, "| N:19.4 |", "☒ Chấp nhận<br>☐ Bác |  |", "☐ Chấp nhận<br>☒ Bác |  |"))
        self.assertTrue(any("bác nhưng không ghi lý do" in p for p in ps))
        ps, dec = self.problems(edit=lambda t: edit_row(t, "| N:19.4 |", "☒ Chấp nhận<br>☐ Bác |  |",
                                                        "☐ Chấp nhận<br>☒ Bác | danh sách khoản 4 cần đọc lại |"))
        self.assertEqual(ps, [])
        d = P.apply_decisions(GOLD, dec, "TEST", "2000-01-01")
        self.assertNotIn("19.4", [n["id"] for n in d["norms"]])
        self.assertTrue(any("19.4 bị bác" in e["reason"] and e["clause"] == "Điều 19 khoản 4" for e in d["not_encoded"]))

    def test_rejected_assumption_stops_everything(self):
        ps, _ = self.problems(edit=lambda t: edit_row(t, "| A:1 |", "☒ Chấp nhận<br>☐ Bác", "☐ Chấp nhận<br>☒ Bác"))
        self.assertTrue(any("bị bác: bản dịch phải làm lại" in p for p in ps))

    def test_refused_not_encoded_stops_everything(self):
        d = copy.deepcopy(GOLD)
        d["norms"] = [n for n in d["norms"] if n["id"] != "19.5"]
        d["not_encoded"] = [{"clause": "Điều 19 khoản 5", "reason": "chưa đọc"}]
        ps, _ = self.problems(d, lambda t: edit_row(t, "| X:1 |", "☒ Đồng ý để ngoài<br>☐ Không đồng ý",
                                                    "☐ Đồng ý để ngoài<br>☒ Không đồng ý"))
        self.assertTrue(any("không đồng ý để ngoài" in p for p in ps))

    def test_two_ticks_changed_translation_and_bad_date(self):
        ps, _ = self.problems(edit=lambda t: edit_row(t, "| N:19.1 |", "☒ Chấp nhận<br>☐ Bác", "☒ Chấp nhận<br>☒ Bác"))
        self.assertTrue(any("norm 19.1: cần đánh dấu đúng một ô" in p for p in ps))
        tr, sh = self.files()
        d = copy.deepcopy(GOLD)
        d["assumptions"].append("thêm sau khi lập phiếu")
        with open(tr, "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False)
        with open(sh, encoding="utf-8") as f:
            ps, _ = P.sheet_problems(d, tr, P.parse_sheet(f.read()))
        self.assertTrue(any("sha256 trong phiếu khác" in p for p in ps))
        ps, _ = self.problems(edit=lambda t: t.replace("2000-01-01", "01/01/2000"))
        self.assertTrue(any("YYYY-MM-DD" in p for p in ps))


class Malformed(Base):
    """What a real reviewer's editor did to a sheet (2026-11-19): deleted the unchosen option and the closing «|»."""

    def mangle(self, text):
        out = []
        for line in text.splitlines():
            if line.startswith(("| N:", "| A:", "| X:")):
                line = line.replace("☒ Chấp nhận<br>☐ Bác |  |", "☐ Chấp nhận").replace("☒ Chấp nhận<br>☐ Bác |", "☐ Chấp nhận")
                line = line.replace("☒ Đồng ý để ngoài<br>☐ Không đồng ý |", "☐ Đồng ý để ngoài")
            out.append(line)
        return "\n".join(out)

    def test_row_without_decision_cell_is_refused_with_a_reason_not_a_crash(self):
        tr, sh = self.files()
        with open(sh, encoding="utf-8") as f:
            text = f.read()

        def cut(line):      # keep only the first 7 cells of the 19.3 row
            return "|".join(line.split("|")[:8]) + "|" if line.startswith("| N:19.3 |") else line

        cut_text = "\n".join(cut(l) for l in text.splitlines())
        ps, _ = P.sheet_problems(GOLD, tr, P.parse_sheet(cut_text))
        self.assertTrue(any("norm 19.3" in p and "hỏng định dạng" in p for p in ps), ps)

    def test_deleted_option_and_closing_pipe_get_an_actionable_message(self):
        ps, _ = self.problems(edit=self.mangle)
        self.assertTrue(ps)
        self.assertTrue(any("chỉ còn một lựa chọn" in p for p in ps))
        self.assertFalse(any("Traceback" in p for p in ps))

    def test_missing_closing_pipe_alone_is_read_correctly(self):
        ps, dec = self.problems(edit=lambda t: "\n".join(l.rstrip(" |") if l.startswith("| N:19.1 ") else l for l in t.splitlines()))
        self.assertEqual(ps, [])      # the ticked cell is the last one and still parses
        self.assertEqual(len(dec["accepted"]), 6)

    def test_missing_rows_are_findings(self):
        d = copy.deepcopy(GOLD)
        tr, sh = self.files(d)
        with open(sh, encoding="utf-8") as f:
            text = "\n".join(l for l in f.read().splitlines() if not l.startswith(("| A:1 ", "| X:")))
        ps, _ = P.sheet_problems(d, tr, P.parse_sheet(text))
        self.assertTrue(any("giả định A:1" in p for p in ps))


class Promote(Base):
    def test_name_and_no_overwrite(self):
        tr, sh = self.files()
        with self.assertRaises(SystemExit):
            P.promote("bad name", [(tr, sh)], build=False)
        with self.assertRaises(SystemExit) as cm:
            P.promote("AlcoholSale", [(tr, sh)], build=False)
        self.assertIn("không ghi đè", str(cm.exception))

    def compiles(self, name, text):
        out = os.path.join(self.dir, name + ".lean")
        with open(out, "w", encoding="utf-8") as f:
            f.write(text)
        r = subprocess.run(["lake", "env", "lean", out], cwd=T.ROOT, capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)

    @unittest.skipUnless(HAS_LAKE, "lake không có trong PATH")
    def test_module_text_compiles_with_kernel_theorems(self):
        tr, sh = self.files()
        _, text = P.promote("TestPromoGold", [(tr, sh)], build=False)
        for s in ("theorem refs_parse", "theorem silent", "theorem consistent", "theorem no_conflict", '.reviewed "TEST"'):
            self.assertIn(s, text)
        self.assertNotIn("sorry", text)
        self.compiles("TestPromoGold", text)

    @unittest.skipUnless(HAS_LAKE, "lake không có trong PATH")
    def test_conflicting_module_gets_has_conflict_theorem(self):
        d = copy.deepcopy(GOLD)
        d["norms"].append(dict(d["norms"][0], id="19.1-cho-phep", modality="permission"))
        tr, sh = self.files(d)
        _, text = P.promote("TestPromoConflict", [(tr, sh)], build=False)
        self.assertIn("theorem has_conflict", text)
        self.assertNotIn("theorem consistent", text)
        self.compiles("TestPromoConflict", text)

    @unittest.skipUnless(HAS_LAKE, "lake không có trong PATH")
    def test_failed_build_puts_everything_back(self):
        tr, sh = self.files()
        lib = os.path.join(self.dir, "lib")
        os.makedirs(os.path.join(lib, "Laws"))
        root, audit = os.path.join(lib, "LexProof.lean"), os.path.join(lib, "Audit.lean")
        with open(root, "w", encoding="utf-8") as f:
            f.write("import LexProof.Basic\nimport LexProof.Cert.Audit\n")
        with open(audit, "w", encoding="utf-8") as f:
            f.write("import LexProof.Basic\nimport LexProof.Verify.Smoke\n")
        saved = (P.LAWS, P.ROOT_FILE, P.AUDIT_FILE, P.subprocess.run)
        real_run = subprocess.run

        def fake_run(cmd, **kw):
            if cmd[:2] == ["lake", "build"]:
                return subprocess.CompletedProcess(cmd, 1, "build broke", "")
            return real_run(cmd, **kw)

        P.LAWS, P.ROOT_FILE, P.AUDIT_FILE, P.subprocess.run = os.path.join(lib, "Laws"), root, audit, fake_run
        try:
            with self.assertRaises(SystemExit) as cm:
                P.promote("TestPromoRollback", [(tr, sh)], build=True)
        finally:
            P.LAWS, P.ROOT_FILE, P.AUDIT_FILE, P.subprocess.run = saved
        self.assertIn("đã hoàn tác", str(cm.exception))
        self.assertFalse(os.path.exists(os.path.join(lib, "Laws", "TestPromoRollback.lean")))
        for p in (root, audit):
            with open(p, encoding="utf-8") as f:
                self.assertNotIn("TestPromoRollback", f.read())


if __name__ == "__main__":
    unittest.main()
