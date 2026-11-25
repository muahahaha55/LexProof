# -*- coding: utf-8 -*-
"""Tests for pipeline/drafting.py (synthetic norms; they exercise the search, they are not readings of the law)."""
import os
import shutil
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import drafting as D   # noqa: E402
import report as R   # noqa: E402
import report_promoted as RP   # noqa: E402

ATOMS = {"situation": [{"name": "x", "source": "Điều 1", "domain": "bool"},
                       {"name": "k", "source": "Điều 1", "domain": [{"label": "a", "source": "Điều 1"},
                                                                    {"label": "b", "source": "Điều 1"}]}],
         "parameters": []}


def n(i, c, ex=(), act="act", mo="prohibition"):
    return {"id": i, "act": act, "modality": mo, "condition": c, "exceptions": list(ex)}


class Scan(unittest.TestCase):
    def test_clean_set_has_witnesses_for_everything(self):
        m = {"atoms": ATOMS, "norms": [n("1", {"sit": "x"}), n("2", {"not": {"sit": "x"}}, [{"sit": "k", "value": "b"}])]}
        M, live, notsub, exc, unknown = D.scan(m)
        self.assertEqual(unknown, [])
        self.assertEqual(len(live), 2)
        self.assertEqual(len(notsub), 2)
        self.assertEqual([(i, k) for i, k, _ in exc], [("2", 0)])
        for i, v in live:
            self.assertTrue(M.applies(next(x for x in m["norms"] if x["id"] == i), v))

    def test_dead_covered_and_never_firing_exception_become_unknown(self):
        m = {"atoms": ATOMS, "norms": [
            n("dead", {"and": [{"sit": "x"}, {"not": {"sit": "x"}}]}),
            n("narrow", {"and": [{"sit": "x"}, {"sit": "k", "value": "a"}]}),
            n("wide", {"sit": "x"}),
            n("exc", {"sit": "k", "value": "a"}, [{"sit": "k", "value": "b"}], act="other")]}
        _, _, _, _, unknown = D.scan(m)
        kinds = {(u[0], u[1], u[2]) for u in unknown}
        self.assertIn(("live", "dead", None), kinds)
        self.assertIn(("sub", "narrow", "wide"), kinds)
        self.assertNotIn(("sub", "wide", "narrow"), kinds)
        self.assertIn(("exc", "exc", 0), kinds)

    def test_different_act_or_modality_is_never_compared(self):
        m = {"atoms": ATOMS, "norms": [n("a", {"sit": "x"}), n("b", "true", act="other"), n("c", "true", mo="obligation")]}
        _, _, notsub, _, unknown = D.scan(m)
        self.assertEqual(notsub, [])
        self.assertEqual(unknown, [])

    def test_points_use_value_indices_in_table_order(self):
        M = D.Model({"atoms": ATOMS, "norms": []})
        self.assertEqual(M.lean_point({"k": 1, "x": 1}), "([], [1, 1])")
        self.assertEqual(M.lean_point({}), "([], [0, 0])")

    def test_module_text_has_theorems_skip_lists_and_unknowns(self):
        m = {"atoms": ATOMS, "norms": [n("dead", {"and": [{"sit": "x"}, {"not": {"sit": "x"}}]})]}
        M, live, notsub, exc, unknown = D.scan(m)
        t = D.module_text("TestDrafting", "Law44", M, live, notsub, exc, unknown)
        for s in ("theorem no_dead", "theorem no_redundant", "theorem exceptions_fire", 'def liveSkip : List String := ["dead"]',
                  "decodeVal", "def unknown"):
            self.assertIn(s, t)
        self.assertNotIn("sorry", t)


class Report(unittest.TestCase):
    @unittest.skipUnless(os.path.exists(os.path.join(R.ROOT, "LexProof", "Laws", "Law44Drafting.lean")), "cần Law44Drafting")
    def test_section_lists_theorems_and_unknowns(self):
        text = "\n".join(RP.drafting_section(R.MODULES["law44"]))
        self.assertIn("`no_dead`", text)
        self.assertIn("phải kiểm xung đột", text)
        # the unknown list depends on the reviewed data: either it is listed or the section says there is none
        self.assertTrue("Không biết" in text or "không có dấu hiệu nào" in text)

    def test_section_without_module(self):
        self.assertIn("Chưa có module", RP.drafting_section(dict(R.MODULES["law44"], drafting="KhongCo"))[0])


if __name__ == "__main__":
    unittest.main()
