# -*- coding: utf-8 -*-
"""Tests for pipeline/glossary.py (ADR-0027 step 1). Run: python -m unittest discover -s pipeline/tests -v"""
import copy
import os
import sys
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import glossary as G   # noqa: E402

SEED = G.load(os.path.join(G.T.ROOT, "data", "glossary", "44-2019-QH14.json"))


def has(fs, *words):
    return any(all(w in f for w in words) for f in fs)


class Check(unittest.TestCase):
    def test_seed_has_no_finding_and_nothing_is_approved_yet(self):
        self.assertEqual(G.check(SEED), [])
        self.assertTrue(all(e["status"] == "proposed" for e in SEED["acts"] + SEED["atoms"]))

    def test_three_acts_sell_supply_promote_are_separate(self):   # decision of 2026-11-20
        ids = {a["id"] for a in SEED["acts"]}
        self.assertTrue({"ban_ruou_bia", "cung_cap_ruou_bia", "khuyen_mai_ruou_bia"} <= ids)

    def test_duplicate_and_badly_spelt_ids(self):
        g = copy.deepcopy(SEED)
        g["atoms"].append(copy.deepcopy(g["atoms"][0]))
        self.assertTrue(has(G.check(g), "id trùng", "tuoi_nguoi_nhan"))
        g = copy.deepcopy(SEED)
        g["acts"][0]["id"] = "Bán rượu"
        self.assertTrue(has(G.check(g), "snake_case"))

    def test_sources_must_be_real_units(self):
        g = copy.deepcopy(SEED)
        g["atoms"][2]["sources"] = ["Điều 19 khoản 9"]
        self.assertTrue(has(G.check(g), "không tồn tại"))
        g["atoms"][2]["sources"] = []
        self.assertTrue(has(G.check(g), "không rỗng"))

    def test_approved_needs_reviewer_and_date(self):
        g = copy.deepcopy(SEED)
        g["acts"][0]["status"] = "approved"
        self.assertTrue(has(G.check(g), "reviewed_by"))
        self.assertTrue(has(G.check(g), "reviewed_on"))
        g["acts"][0].update(reviewed_by="X", reviewed_on="2026-11-21")
        self.assertEqual(G.check(g), [])
        g["acts"][0]["status"] = "ok"
        self.assertTrue(has(G.check(g), "status"))

    def test_a_value_no_clause_names_must_say_so(self):
        g = copy.deepcopy(SEED)
        del g["atoms"][0]["domain"][1]["note"]
        self.assertTrue(has(G.check(g), "từ đủ 18 tuổi trở lên", "note"))

    def test_parameters_are_bool_and_gloss_is_required(self):
        g = copy.deepcopy(SEED)
        p = next(a for a in g["atoms"] if a["kind"] == "parameter")
        p["domain"] = [{"label": "có", "source": "Điều 19 khoản 3"}, {"label": "không", "source": "Điều 19 khoản 3"}]
        self.assertTrue(has(G.check(g), "tham số chỉ được là bool"))
        g = copy.deepcopy(SEED)
        g["atoms"][3]["gloss"] = ""
        self.assertTrue(has(G.check(g), "gloss"))


if __name__ == "__main__":
    unittest.main()
