# -*- coding: utf-8 -*-
"""Tests for pipeline/glossary.py (ADR-0027 step 1). Run: python -m unittest discover -s pipeline/tests -v"""
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

    def test_a_proposal_moved_into_the_glossary_is_superseded(self):
        d = gold19_with_glossary()
        d["glossary_proposals"]["atoms"].append(copy.deepcopy(next(a for a in SEED["atoms"] if a["id"] == "do_con")))
        del d["glossary_proposals"]["atoms"][0]["status"]
        self.assertEqual(T.check(d), [])


# ---------------------------------------------------------------- step 3: merge by id, block unapproved terms
import run as RUN          # noqa: E402
import promote as P        # noqa: E402

HAS_LAKE = shutil.which("lake") is not None
SEG = dict(T.load_segmented("44/2019/QH14"), doc_id="44/2019/QH14")   # as run.run() sets it


def article5(modality="permission", condition=None, proposals=None):
    """A synthetic one-norm Article 5 translation in glossary mode (a fixture, not a reading of the law)."""
    return {"doc_id": "44/2019/QH14", "doc_type": "law", "effective": GOLD19["effective"], "article": 5,
            "glossary": "data/glossary/44-2019-QH14.json", "atoms": {"situation": [], "parameters": []},
            "glossary_proposals": proposals or {"acts": [], "atoms": []},
            "norms": [{"id": "5.t", "modality": modality, "act": "ban_ruou_bia",
                       "condition": condition or {"not": {"sit": "dia_diem_co_so_y_te"}}, "exceptions": [],
                       "source": "Điều 5 khoản 3", "quote": "Bán, cung cấp, khuyến mại rượu, bia", "references": []}],
            "not_encoded": [{"clause": "Điều 5", "reason": "fixture: chỉ một norm thử"}], "assumptions": []}


def only_19_1(d):
    """Keep norm 19.1 alone (prohibited at a medical facility); the rest of the article is set aside."""
    d = copy.deepcopy(d)
    d["norms"] = d["norms"][:1]
    d["not_encoded"] = [{"clause": "Điều 19", "reason": "fixture: chỉ norm 19.1"}]
    return d


def approved(g):
    g = copy.deepcopy(g)
    for e in g["acts"] + g["atoms"]:
        e.update(status="approved", reviewed_by="TEST", reviewed_on="2000-01-01")
    return g


class MergeById(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()

    def tearDown(self):
        shutil.rmtree(self.dir)

    def write(self, name, d):
        p = os.path.join(self.dir, name)
        with open(p, "w", encoding="utf-8") as f:
            if isinstance(d, str):
                f.write(d)
            else:
                json.dump(d, f, ensure_ascii=False)
        return p

    def test_materialize_names_atoms_by_id_and_keeps_what_lean_drops(self):
        d = gold19_with_glossary()
        d["norms"][0]["condition"] = {"and": [d["norms"][0]["condition"], {"sit": "tuoi_nguoi_nhan", "value": "từ đủ 18 tuổi trở lên"}]}
        self.assertEqual(T.check(d), [])
        m = T.materialize(d)
        names = [a["name"] for a in m["atoms"]["situation"]]
        self.assertEqual(len(names), 8)                     # only the atoms the norms use, glossary order
        self.assertNotIn("do_con", names)
        self.assertTrue(all(a["shared"] for a in m["atoms"]["situation"] + m["atoms"]["parameters"]))
        age = next(a for a in m["atoms"]["situation"] if a["name"] == "tuoi_nguoi_nhan")
        self.assertEqual(age["domain"][1], {"label": "từ đủ 18 tuổi trở lên", "source": "Điều 5 khoản 3"})
        self.assertTrue(any("không có khoản nào nêu" in t and "phần bù" in t for t in m["glossary_terms"]))
        self.assertEqual(len(m["unapproved"]), 10)
        self.assertIs(T.materialize(GOLD19), GOLD19)

    def test_one_id_in_two_articles_is_one_atom(self):
        accepted, refused, _ = RUN.admit([self.write("a19.json", gold19_with_glossary()), self.write("a5.json", article5())], SEG)
        self.assertEqual(refused, [])
        m = RUN.merge(accepted)
        names = [a["name"] for a in m["atoms"]["situation"]]
        self.assertEqual(names.count("dia_diem_co_so_y_te"), 1)
        self.assertFalse(any(n.startswith("Điều") for n in names))
        self.assertIn({"not": {"sit": "dia_diem_co_so_y_te"}}, [n["condition"] for n in m["norms"]])
        text = T.to_lean(m, SEG)
        self.assertIn("an id shared by two articles is ONE atom", text)

    @unittest.skipUnless(HAS_LAKE, "lake không có trong PATH")
    def test_sharing_removes_a_spurious_conflict(self):
        # «permitted where NOT a medical facility» vs 19.1 «prohibited at a medical facility»: no situation has both,
        # but only if both speak of the same atom. With per-article atoms (no glossary) Lean finds a conflict.
        files = [self.write("a19.json", only_19_1(gold19_with_glossary())), self.write("a5.json", article5())]
        accepted, _, _ = RUN.admit(files, SEG)
        out = os.path.join(self.dir, "shared.lean")
        with open(out, "w", encoding="utf-8") as f:
            f.write(T.to_lean(RUN.merge(accepted), SEG))
        self.assertEqual(RUN.run_lean(out).get("result"), "consistentOn")
        local = article5(condition={"not": {"sit": "S14 địa điểm là cơ sở y tế"}})
        for k in ("glossary", "glossary_proposals"):
            del local[k]
        local["atoms"]["situation"] = [copy.deepcopy(GOLD19["atoms"]["situation"][0])]
        local["atoms"]["situation"][0]["source"] = "Điều 5 khoản 3"
        accepted, refused, _ = RUN.admit([self.write("b19.json", only_19_1(GOLD19)), self.write("b5.json", local)], SEG)
        self.assertEqual(refused, [])
        with open(out, "w", encoding="utf-8") as f:
            f.write(T.to_lean(RUN.merge(accepted), SEG))
        self.assertEqual(RUN.run_lean(out).get("result"), "XUNG ĐỘT")

    def test_two_proposals_with_one_id_must_agree(self):
        prop = lambda labels: {"acts": [], "atoms": [{"id": "hinh_thuc_ban", "kind": "situation", "gloss": "x", "sources": ["Điều 5 khoản 3"],
                                                      "domain": [{"label": l, "source": "Điều 5 khoản 3"} for l in labels]}]}   # noqa: E731
        a = article5(condition={"sit": "hinh_thuc_ban", "value": "trực tiếp"}, proposals=prop(["trực tiếp", "trực tuyến"]))
        b = copy.deepcopy(a)
        b["article"], b["norms"][0]["source"], b["not_encoded"][0]["clause"] = 19, "Điều 19 khoản 1", "Điều 19"
        b["norms"][0]["quote"] = "Cơ sở y tế"
        b["glossary_proposals"] = prop(["trực tiếp", "qua mạng"])
        self.assertEqual(T.check(b), [])
        accepted, refused, _ = RUN.admit([self.write("a.json", a), self.write("b.json", b)], SEG)
        self.assertEqual(len(accepted), 1)
        self.assertTrue(has(refused[0][1], "hinh_thuc_ban", "định nghĩa khác nhau"))

    def sheet(self, d, g=None):
        tr = self.write("t%d.json" % d["article"], d)
        text = P.make_sheet(tr, d)
        text = text.replace("Người duyệt: ", "Người duyệt: TEST", 1).replace("Ngày duyệt (YYYY-MM-DD): ", "Ngày duyệt (YYYY-MM-DD): 2000-01-01", 1)
        text = text.replace("☐ Chấp nhận<br>☐ Bác", "☒ Chấp nhận<br>☐ Bác").replace("☐ Đồng ý để ngoài<br>", "☒ Đồng ý để ngoài<br>")
        sh = self.write("s%d.md" % d["article"], text)
        return tr, sh

    def with_glossary(self, g):
        saved = G.load
        G.load = lambda path: copy.deepcopy(g)
        self.addCleanup(setattr, G, "load", saved)

    def test_sheet_shows_the_terms_and_pins_the_glossary(self):
        tr, sh = self.sheet(gold19_with_glossary())
        text = open(sh, encoding="utf-8").read()
        self.assertIn("## 0. Thuật ngữ bản dịch dùng", text)
        self.assertIn("atom dia_diem_co_so_y_te [proposed]", text)
        sheet = P.parse_sheet(text)
        self.assertEqual(P.sheet_problems(gold19_with_glossary(), tr, sheet)[0], [])
        sheet["glossary_sha"] = "0" * 64
        self.assertTrue(has(P.sheet_problems(gold19_with_glossary(), tr, sheet)[0], "sha256 bảng thuật ngữ"))

    def test_promote_refuses_unapproved_terms(self):
        with self.assertRaises(SystemExit) as cm:
            P.promote("TestGlossaryUnapproved", [self.sheet(gold19_with_glossary())], build=False)
        self.assertIn("thuật ngữ chưa duyệt", str(cm.exception))
        self.assertIn("ban_ruou_bia [proposed]", str(cm.exception))

    def test_promote_refuses_a_proposal_even_with_an_approved_glossary(self):
        self.with_glossary(approved(SEED))
        d = article5(proposals={"acts": [], "atoms": [{"id": "moi", "kind": "situation", "domain": "bool", "gloss": "x",
                                                       "sources": ["Điều 5 khoản 3"]}]}, condition={"sit": "moi"})
        with self.assertRaises(SystemExit) as cm:
            P.promote("TestGlossaryProposal", [self.sheet(d)], build=False)
        self.assertIn("moi [đề xuất]", str(cm.exception))

    @unittest.skipUnless(HAS_LAKE, "lake không có trong PATH")
    def test_promote_with_approved_terms_compiles(self):
        self.with_glossary(approved(SEED))
        _, text = P.promote("TestGlossaryPromo", [self.sheet(only_19_1(gold19_with_glossary())), self.sheet(article5())], build=False)
        self.assertIn("Glossary terms used", text)
        self.assertIn("every term used was", text)
        self.assertIn("theorem consistent", text)
        self.assertEqual(text.count('{ name := "dia_diem_co_so_y_te"'), 1)
        out = os.path.join(self.dir, "TestGlossaryPromo.lean")
        with open(out, "w", encoding="utf-8") as f:
            f.write(text)
        r = subprocess.run(["lake", "env", "lean", out], cwd=T.ROOT, capture_output=True, text=True, encoding="utf-8")
        self.assertEqual(r.returncode, 0, r.stdout + r.stderr)


if __name__ == "__main__":
    unittest.main()
