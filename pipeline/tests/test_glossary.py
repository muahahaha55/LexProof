# -*- coding: utf-8 -*-
"""Tests for pipeline/glossary.py (ADR-0027 step 1). Run: python -m unittest discover -s pipeline/tests -v"""
import copy
import json
import os
import sys
import tempfile
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


# ---------------------------------------------------------------- step 2: translations that use the glossary
T = G.T
GOLD19 = json.load(open(os.path.join(T.ROOT, "eval", "translate", "article19.gold.json"), encoding="utf-8"))
GLOSSARY_IDS = ["dia_diem_co_so_y_te", "dia_diem_co_so_giao_duc", "dia_diem_cham_soc_vui_choi", "dia_diem_cai_nghien_giam_giu",
                "dia_diem_bao_tro_xa_hoi", "dia_diem_noi_lam_viec_co_quan", "dia_diem_duoc_phep_kinh_doanh"]


def rename(c, m):
    if isinstance(c, dict):
        return {k: (m.get(v, v) if k in ("sit", "param") else
                    [rename(x, m) for x in v] if isinstance(v, list) else rename(v, m)) for k, v in c.items()}
    return c


def gold19_with_glossary():
    """The Article 19 gold file rewritten to use glossary ids (a fixture, not a translation anyone reviewed)."""
    d = copy.deepcopy(GOLD19)
    m = {a["name"]: i for a, i in zip(d["atoms"]["situation"], GLOSSARY_IDS)}
    m[d["atoms"]["parameters"][0]["name"]] = "danh_cho_nguoi_chua_du_18"
    for n in d["norms"]:
        n["condition"] = rename(n["condition"], m)
        n["exceptions"] = [rename(e, m) for e in n["exceptions"]]
    d["atoms"] = {"situation": [], "parameters": []}
    d["glossary"] = "data/glossary/44-2019-QH14.json"
    d["glossary_proposals"] = {"acts": [], "atoms": []}
    return d


class WithGlossary(unittest.TestCase):
    def test_ids_of_the_glossary_resolve_and_unapproved_terms_are_listed(self):
        d = gold19_with_glossary()
        self.assertEqual(T.check(d), [])
        un = T.unapproved_terms(d)
        self.assertEqual(len(un), 9)          # 1 act + 7 situation atoms + 1 parameter, all still proposed
        self.assertIn("ban_ruou_bia [proposed]", un)
        self.assertEqual(T.unapproved_terms(GOLD19), [])   # no glossary, nothing to report

    def test_act_must_come_from_the_glossary_or_a_proposal(self):
        d = gold19_with_glossary()
        d["norms"][0]["act"] = "kinh_doanh_ruou"
        self.assertTrue(has(T.check(d), "kinh_doanh_ruou", "không có trong bảng thuật ngữ"))
        d["glossary_proposals"]["acts"].append({"id": "kinh_doanh_ruou", "gloss": "kinh doanh rượu", "sources": ["Điều 19 khoản 1"]})
        self.assertEqual(T.check(d), [])
        self.assertIn("kinh_doanh_ruou [đề xuất]", T.unapproved_terms(d))

    def test_proposals_are_checked_like_glossary_entries(self):
        d = gold19_with_glossary()
        d["glossary_proposals"]["atoms"] = [
            {"id": "do_con", "kind": "situation", "domain": "bool", "gloss": "x", "sources": ["Điều 19 khoản 1"]},
            {"id": "moi", "kind": "situation", "domain": "bool", "gloss": "x", "sources": ["Điều 19 khoản 9"], "status": "approved"}]
        fs = T.check(d)
        self.assertTrue(has(fs, "do_con", "đã có trong bảng"))
        self.assertTrue(has(fs, "glossary_proposals", "không tồn tại"))
        self.assertTrue(has(fs, "không ghi «status»"))

    def test_no_private_atoms_and_the_right_glossary(self):
        d = gold19_with_glossary()
        d["atoms"]["situation"] = copy.deepcopy(GOLD19["atoms"]["situation"])
        self.assertTrue(has(T.check(d), "«atoms» phải rỗng"))
        d = gold19_with_glossary()
        d["glossary"] = "data/glossary/khac.json"
        self.assertTrue(has(T.check(d), "một bảng cho mỗi văn bản"))
        d = copy.deepcopy(GOLD19)
        d["glossary_proposals"] = {"acts": [], "atoms": []}
        self.assertTrue(has(T.check(d), "chỉ dùng cùng «glossary»"))

    def test_rejected_entries_cannot_be_used_or_offered(self):
        g = copy.deepcopy(SEED)
        for e in g["acts"] + g["atoms"]:
            if e["id"] in ("ban_ruou_bia", "dia_diem_co_so_y_te"):
                e.update(status="rejected", reviewed_by="TEST", reviewed_on="2000-01-01")
        saved = G.load
        G.load = lambda path: copy.deepcopy(g)
        try:
            fs = T.check(gold19_with_glossary())
            prompt = T.make_prompt(T.load_segmented("44/2019/QH14"), 19, (g, "data/glossary/44-2019-QH14.json"))
        finally:
            G.load = saved
        self.assertTrue(has(fs, "ban_ruou_bia", "bị bác"))
        self.assertTrue(has(fs, "dia_diem_co_so_y_te", "bị bác"))
        self.assertNotIn("- ban_ruou_bia ", prompt)

    def test_prompt_lists_the_glossary_and_its_rules(self):
        p = T.make_prompt(T.load_segmented("44/2019/QH14"), 15, (SEED, "data/glossary/44-2019-QH14.json"))
        for s in ("### Bảng thuật ngữ", "- do_con [proposed], nhãn «dưới 15 độ» | «từ 15 độ trở lên»",
                  "- danh_cho_nguoi_chua_du_18 [proposed], bool", '"glossary": "data/glossary/44-2019-QH14.json"',
                  "glossary_proposals", "12. Dùng bảng thuật ngữ", "14. Không sửa"):
            self.assertIn(s, p)
        self.assertNotIn("cùng hành vi dùng cùng mã", p)
        self.assertNotIn("là atom trong «parameters»", p)     # would contradict «atoms» being empty
        self.assertNotIn("bảng thuật ngữ", T.make_prompt(T.load_segmented("44/2019/QH14"), 15))   # default unchanged

    def test_later_steps_refuse_glossary_translations_until_step_3(self):
        import run as RUN   # noqa: E402
        d = gold19_with_glossary()
        self.assertTrue(T.not_merged_yet(d))
        self.assertEqual(T.not_merged_yet(GOLD19), [])
        with tempfile.TemporaryDirectory() as tmp:
            p = os.path.join(tmp, "a19.json")
            with open(p, "w", encoding="utf-8") as f:
                json.dump(d, f, ensure_ascii=False)
            accepted, refused, _ = RUN.admit([p], T.load_segmented("44/2019/QH14"))
            self.assertEqual(accepted, [])
            self.assertTrue(has(refused[0][1], "bước 3"))
            self.assertEqual(T.main(["lean", p, "-o", os.path.join(tmp, "x.lean")]), 1)


if __name__ == "__main__":
    unittest.main()
