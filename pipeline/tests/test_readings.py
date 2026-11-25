# -*- coding: utf-8 -*-
"""Tests for pipeline/readings.py (synthetic readings; they exercise the tool, they are not readings of the law)."""
import copy
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import readings as RD   # noqa: E402

DD = {"doc_id": "44/2019/QH14", "module": "Law44", "edges": "data/edges/44-2019-QH14.json", "readings": []}
MERGED = {"atoms": {"situation": [{"name": "a", "source": "Điều 5 khoản 1", "domain": "bool"}], "parameters": []},
          "norms": [{"id": "Điều 5:5.1", "condition": {"sit": "a"}, "exceptions": []}]}


def reading(**kw):
    r = {"id": "R1", "reading": "x", "proposed_by": "TEST",
         "atoms": [{"name": "k", "source": "Điều 5 khoản 12", "domain": "bool"}],
         "patches": [{"norm": "Điều 5:5.1", "add_condition": {"sit": "k"}}]}
    r.update(kw)
    return r


class Check(unittest.TestCase):
    def test_clean(self):
        self.assertEqual(RD.check(dict(DD, readings=[reading()]), MERGED), [])

    def test_unknown_norm_unknown_atom_reused_atom_bad_id(self):
        d = dict(DD, readings=[reading(id="X", atoms=[{"name": "a", "source": "Điều 5 khoản 1", "domain": "bool"}],
                                       patches=[{"norm": "Điều 9:9.9", "add_condition": {"sit": "zz"}}])])
        fs = RD.check(d, MERGED)
        for s in ("R0, R1", "đã có trong module", "Điều 9:9.9", "«zz»"):
            self.assertTrue(any(s in f for f in fs), (s, fs))


class Apply(unittest.TestCase):
    def test_apply_adds_atom_conjunct_and_exception_without_touching_input(self):
        before = copy.deepcopy(MERGED)
        r = reading(patches=[{"norm": "Điều 5:5.1", "add_condition": {"sit": "k"}, "add_exception": {"sit": "k"}}])
        m = RD.apply(MERGED, r)
        self.assertEqual(MERGED, before)
        n = m["norms"][0]
        self.assertEqual(n["condition"], {"and": [{"sit": "a"}, {"sit": "k"}]})
        self.assertEqual(n["exceptions"], [{"sit": "k"}])
        self.assertEqual([a["name"] for a in m["atoms"]["situation"]], ["a", "k"])


class Real(unittest.TestCase):
    def test_module_translations_are_read_from_the_module_header(self):
        fs = RD.module_translations("Law44")
        self.assertEqual(len(fs), 15)
        self.assertTrue(all(f.startswith("eval/translate/") for f, _ in fs))


if __name__ == "__main__":
    unittest.main()
