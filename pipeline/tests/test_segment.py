# -*- coding: utf-8 -*-
"""Tests for pipeline/segment.py. Run: python -m unittest discover -s pipeline/tests -v   (from the repo root)

The broken copies are made in memory; data/extracted is never written.
"""
import os
import re
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import segment as S   # noqa: E402

SHA, LINES, DOC = S.run(S.DEFAULT_IN)


def seg(lines):
    return S.segment(lines)


def find(lines, pat):
    for i, l in enumerate(lines):
        if re.match(pat, l):
            return i
    raise AssertionError("pattern not found: " + pat)


class RealInput(unittest.TestCase):
    def test_S0_pin(self):
        self.assertTrue(S.check_input_pin(SHA, S.PINNED_SHA256)["ok"])

    def test_S1(self):
        r = S.check_S1(DOC)
        self.assertTrue(r["ok"], r)
        self.assertEqual((r["chapters"], r["articles"]), (7, 36))

    def test_S2(self):
        r = S.check_S2(DOC, LINES)
        self.assertTrue(r["ok"], r)
        self.assertEqual(r["sum_counts"], len(LINES))
        self.assertEqual(r["unclassified"], [])

    def test_S3(self):
        r = S.check_S3(DOC)
        self.assertTrue(r["ok"], r)

    def test_S5(self):
        r = S.check_S5(DOC, LINES)
        self.assertTrue(r["ok"], r)

    def test_deterministic(self):
        a = S.to_json(DOC, SHA, len(LINES), "x")
        b = S.to_json(S.segment(LINES), SHA, len(LINES), "x")
        self.assertEqual(a, b)
        shipped = os.path.join(S.ROOT, "data", "segmented", "44-2019-QH14.json")
        if os.path.exists(shipped):
            want = S.to_json(DOC, SHA, len(LINES), "data/extracted/44-2019-QH14.txt")
            with open(shipped, "rb") as f:
                self.assertEqual(f.read(), want.encode("utf-8"))


class BrokenInputs(unittest.TestCase):
    def test_deleted_clause_start_caught_by_S3(self):
        L = list(LINES)
        i = find(L, r"^\s+7\. ")          # first line of a khoản 7 (Điều 5)
        del L[i]
        self.assertFalse(S.check_S3(seg(L))["ok"])

    def test_deleted_article_heading_caught_by_S1(self):
        L = list(LINES)
        del L[find(L, r"^\s+Điều 20\. ")]
        self.assertFalse(S.check_S1(seg(L))["ok"])

    def test_renumbered_article_caught_by_S1(self):
        L = list(LINES)
        i = find(L, r"^\s+Điều 7\. ")
        L[i] = L[i].replace("Điều 7.", "Điều 8.", 1)
        self.assertFalse(S.check_S1(seg(L))["ok"])

    def test_stray_line_caught_by_S2(self):
        L = list(LINES)
        i = find(L, r"^\s*Chương II\s*$")
        L.insert(i + 2, "dòng lạ không thuộc đơn vị nào")
        r = S.check_S2(seg(L), L)
        self.assertFalse(r["ok"])
        self.assertTrue(r["unclassified"])

    def test_deleted_body_line_is_NOT_caught_by_structure_only_by_pin(self):
        """A deleted continuation line leaves a self-consistent segmentation: S1, S2, S3, S5 all pass. Only the
        pinned input hash notices. This documents a limit; it is not a defence."""
        L = list(LINES)
        i = find(L, r"^Luật này quy định biện pháp|^của cơ quan, tổ chức, cá nhân trong phòng")
        del L[i]
        d = seg(L)
        self.assertTrue(S.check_S1(d)["ok"] and S.check_S2(d, L)["ok"] and S.check_S3(d)["ok"]
                        and S.check_S5(d, L)["ok"])
        import hashlib
        sha = hashlib.sha256("\r\n".join(L).encode("utf-8")).hexdigest()
        self.assertFalse(S.check_input_pin(sha, S.PINNED_SHA256)["ok"])


if __name__ == "__main__":
    unittest.main()
