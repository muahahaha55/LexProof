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


class Review(unittest.TestCase):
    def setUp(self):
        import json, tempfile
        self.json = json
        self.dir = tempfile.mkdtemp()
        self.path = os.path.join(self.dir, "r.json")
        dd = dict(DD, readings=[reading(id="R1"), reading(id="R2")])
        with open(self.path, "w", encoding="utf-8") as f:
            json.dump(dd, f, ensure_ascii=False)
        self.saved = RD.check
        Review.saved_check = staticmethod(self.saved)
        RD.check = lambda dd, merged=None: RD_check(dd)

    def tearDown(self):
        import shutil
        RD.check = self.saved
        shutil.rmtree(self.dir)

    def sheet(self, ticks):
        text = RD.make_sheet(self.path, RD.load(self.path))
        text = text.replace("Người duyệt: ", "Người duyệt: TEST", 1).replace("Ngày duyệt (YYYY-MM-DD): ", "Ngày duyệt (YYYY-MM-DD): 2000-01-01", 1)
        out = []
        for l in text.splitlines():
            for i, (k, why) in ticks.items():
                if l.startswith("| R:%s " % i):
                    opts = ["☐ Chấp nhận", "☐ Bác", "☐ Để sau"]
                    opts[k] = opts[k].replace("☐", "☒")
                    l = l.replace("☐ Chấp nhận<br>☐ Bác<br>☐ Để sau", "<br>".join(opts))
                    l = l[:-2].rstrip() + " " + why + " |"
            out.append(l)
        sp = os.path.join(self.dir, "s.md")
        with open(sp, "w", encoding="utf-8") as f:
            f.write("\n".join(out))
        return sp

    def test_sheet_has_r0_and_every_reading(self):
        text = RD.make_sheet(self.path, RD.load(self.path))
        for i in ("R0", "R1", "R2"):
            self.assertIn("| R:%s " % i, text)

    def test_choose_one_and_reject_others(self):
        sp = self.sheet({"R0": (1, "có ngoại lệ ngầm"), "R1": (1, "không"), "R2": (0, "")})
        self.assertIn("chấp nhận 1, bác 2", RD.apply_sheet(self.path, sp))
        d = RD.load(self.path)
        st = {r["id"]: r["status"] for r in d["readings"]}
        self.assertEqual(st, {"R0": "rejected", "R1": "rejected", "R2": "approved"})

    def test_two_chosen_or_unexplained_rejection_is_refused(self):
        with self.assertRaises(SystemExit) as cm:
            RD.apply_sheet(self.path, self.sheet({"R1": (0, ""), "R2": (0, "")}))
        self.assertIn("nhiều hơn một", str(cm.exception))
        with self.assertRaises(SystemExit) as cm:
            RD.apply_sheet(self.path, self.sheet({"R1": (1, "")}))
        self.assertIn("không ghi lý do", str(cm.exception))


def RD_check(dd):
    """`check` without the module (MERGED stands in for Law44)."""
    return Review.saved_check(dd, MERGED) if hasattr(Review, "saved_check") else []


if __name__ == "__main__":
    unittest.main()
