# -*- coding: utf-8 -*-
"""Tests for the promoted-module report (`report.py --module law44`)."""
import os
import shutil
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import report as R   # noqa: E402
import report_promoted as RP   # noqa: E402

CFG = R.MODULES["law44"]
BUILT = os.path.exists(os.path.join(R.ROOT, ".lake", "build", "lib", "lean", "LexProof", "Laws", "Law44.olean"))


class Units(unittest.TestCase):
    def test_branch_belongs_to_its_unit_and_nesting(self):
        self.assertEqual(RP.unit_of("Điều 32 khoản 5 nhánh (ii)"), "Điều 32 khoản 5")
        self.assertTrue(RP.under("Điều 5 khoản 3", "Điều 5"))
        self.assertFalse(RP.under("Điều 50 khoản 1", "Điều 5"))
        self.assertFalse(RP.under("Điều 5 khoản 13", "Điều 5 khoản 1"))

    def test_classification_reads_ticks_and_flags_missing_ones(self):
        d = tempfile.mkdtemp()
        try:
            p = os.path.join(d, "s.md")
            with open(p, "w", encoding="utf-8") as f:
                f.write("| NE:1 | a | b | c | d | [x] Đồng ý để ngoài<br>[ ] Không đồng ý | |\n"
                        "| NE:2 | a | b | c | d | [ ] Đồng ý để ngoài<br>[x] Không đồng ý | lý do |\n"
                        "| NE:3 | a | b | c | d | [ ] Đồng ý để ngoài<br>[ ] Không đồng ý | |\n")
            saved = R.ROOT
            R.ROOT = d
            try:
                got = RP.classification("s.md")
            finally:
                R.ROOT = saved
        finally:
            shutil.rmtree(d)
        self.assertEqual(got[1], "đồng ý để ngoài")
        self.assertTrue(got[2].startswith("không đồng ý"))
        self.assertEqual(got[3], "chưa duyệt")

    def test_a_unit_without_norm_or_reason_is_a_gap(self):
        dump = {"norms": [{"id": "x", "source": "Điều 19 khoản 1", "act": "a"}], "not_encoded": [], "render": []}
        arts, gaps = RP.scope(CFG, dump)
        self.assertIn("Điều 19 khoản 2", gaps)
        self.assertNotIn("Điều 19 khoản 1", gaps)
        self.assertEqual(next(a for a in arts if a["n"] == 19)["status"], "đã mã hóa")


class Make(unittest.TestCase):
    def test_reviewed_is_refused(self):
        with self.assertRaises(SystemExit) as cm:
            RP.make(CFG, "reviewed", do_build=False)
        self.assertIn("FR12", str(cm.exception))

    @unittest.skipUnless(shutil.which("lake") and BUILT, "cần lake và Law44 đã build")
    def test_draft_report_says_scope_vacuity_and_keeps_edges_apart(self):
        text = RP.make(CFG, "draft", do_build=False, today="2000-01-01")
        for s in ("BẢN NHÁP", "Không phải tư vấn pháp lý", "Nhất quán trên phần đã mã hóa", "| **Cộng** | **36** |",
                  "không có đơn vị nào bị bỏ qua im lặng", "covers_articles", "## 5. Kiểm qua quan hệ giữa các hành vi",
                  "không** đổi kết luận ở mục 1", "## 6. Dấu hiệu lỗi soạn thảo", "## 7. Điều KHÔNG được chứng minh", "KẾT QUẢ: consistentOn"):
            # no counterexample check here: whether section 5 has one depends on the reviewed edges in data/
            self.assertIn(s, text)
        self.assertIn("KHÔNG CHẠY (--no-build)", text)


if __name__ == "__main__":
    unittest.main()
