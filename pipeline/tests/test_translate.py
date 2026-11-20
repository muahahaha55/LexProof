# -*- coding: utf-8 -*-
"""Tests for pipeline/translate.py. Run: python -m unittest discover -s pipeline/tests -v   (from the repo root).
The Lean run needs `lake` on PATH and takes a few seconds."""
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
import translate as T   # noqa: E402

GOLD_PATH = os.path.join(T.ROOT, "eval", "translate", "article19.gold.json")
GOLD = json.load(open(GOLD_PATH, encoding="utf-8"))


def has(findings, *words):
    return any(all(w in f for w in words) for f in findings)


class Check(unittest.TestCase):
    def test_gold_has_no_finding(self):
        self.assertEqual(T.check(GOLD), [])

    def test_invented_quotation_is_refused(self):
        d = copy.deepcopy(GOLD)
        d["norms"][0]["quote"] = "Cơ sở thú y."
        self.assertTrue(has(T.check(d), "quote", "19.1") or has(T.check(d), "nguyên văn"))

    def test_clause_nobody_accounted_for_is_refused(self):
        d = copy.deepcopy(GOLD)
        d["norms"] = [n for n in d["norms"] if n["id"] != "19.4"]
        self.assertTrue(has(T.check(d), "khoản chưa được tính tới", "Điều 19 khoản 4"))
        d["not_encoded"].append({"clause": "Điều 19 khoản 4", "reason": "chưa đọc"})
        self.assertEqual(T.check(d), [])   # a stated reason is enough; the reviewer then judges it

    def test_not_encoded_needs_a_reason(self):
        d = copy.deepcopy(GOLD)
        d["not_encoded"].append({"clause": "Điều 19 khoản 4", "reason": ""})
        self.assertTrue(has(T.check(d), "thiếu lý do"))

    def test_free_string_reference_and_missing_unit_are_findings(self):
        d = copy.deepcopy(GOLD)
        d["norms"][0]["source"] = "điều 19, khoản 1"
        self.assertTrue(has(T.check(d), "không phân tích được"))
        d = copy.deepcopy(GOLD)
        d["norms"][0]["source"] = "Điều 19 khoản 9"
        self.assertTrue(has(T.check(d), "không tồn tại"))

    def test_unknown_atom_and_wrong_article(self):
        d = copy.deepcopy(GOLD)
        d["norms"][0]["condition"] = {"sit": "không có atom này"}
        self.assertTrue(has(T.check(d), "atom tình huống không tồn tại"))
        d = copy.deepcopy(GOLD)
        d["norms"][0]["source"] = "Điều 5 khoản 3"
        d["norms"][0]["quote"] = "Bán, cung cấp, khuyến mại rượu, bia cho người chưa đủ 18 tuổi."
        self.assertTrue(has(T.check(d), "không phải Điều 19"))

    def test_bad_modality_and_missing_keys(self):
        d = copy.deepcopy(GOLD)
        d["norms"][0]["modality"] = "được phép"
        self.assertTrue(has(T.check(d), "modality"))
        d = copy.deepcopy(GOLD)
        del d["assumptions"]
        self.assertTrue(has(T.check(d), "thiếu khóa"))

    def test_references_must_name_existing_legal_units(self):
        d = copy.deepcopy(GOLD)
        d["norms"][5]["references"] = ["Điều 15 khoản 4", "Điều 15 khoản 1 điểm a"]
        self.assertEqual(T.check(d), [])
        d["norms"][5]["references"] = ["Điều 15 khoản 9"]
        self.assertTrue(has(T.check(d), "dẫn chiếu", "không tồn tại"))
        d["norms"][5]["references"] = ["pháp luật về khuyến mại"]
        self.assertTrue(has(T.check(d), "dẫn chiếu", "không phân tích được"))
        d["norms"][5]["references"] = ["Điều 5 khoản 11 nhánh (i)"]
        self.assertTrue(has(T.check(d), "phải là một đơn vị của luật"))
        d["norms"][5]["references"] = "Điều 15"
        self.assertTrue(has(T.check(d), "references phải là danh sách"))

    def test_parse_ref_grammar(self):
        self.assertEqual(T.parse_ref("Điều 19 khoản 6")["clause"], 6)
        self.assertEqual(T.parse_ref("Điều 5 khoản 11 nhánh (ii)")["branch"], "ii")
        self.assertTrue(T.parse_ref("Điều 19 (tiêu đề)")["heading"])
        self.assertIsNone(T.parse_ref("Điều 19 khoản"))
        self.assertIsNone(T.parse_ref("Điều 5 mục 3"))


class Outputs(unittest.TestCase):
    def test_prompt_has_the_text_the_schema_and_the_rules(self):
        seg = T.load_segmented("44/2019/QH14")
        seg["input"].setdefault("doc_id", "44/2019/QH14")
        p = T.make_prompt(seg, 19)
        self.assertIn("[Điều 19 khoản 6]", p)
        self.assertIn("trừ địa điểm được phép kinh doanh rượu, bia", p)
        self.assertIn("«quote»", p)
        self.assertIn("số La Mã", p)      # a real run wrote «nhánh (1)» and was refused (RECORD.md)
        self.assertIn("not_encoded", p)
        p15 = T.make_prompt(seg, 15)
        self.assertIn('"article": 15', p15)    # the schema example used to say 19 whatever the article
        self.assertNotIn("Điều 19", p15.split("### Lược đồ JSON")[1])
        self.assertIn("[Điều 15 khoản 1 điểm d]", p15)
        self.assertIn("«references»", p15)

    def test_catalog_has_every_unit(self):
        ids = T.unit_ids(T.load_segmented("44/2019/QH14"))
        self.assertEqual(len(ids), 36 + 141 + 45)
        self.assertIn("Điều 15 khoản 1 điểm a", ids)
        self.assertEqual(len(ids), len(set(ids)))

    def test_lean_draft_is_marked_and_outside_laws(self):
        seg = T.load_segmented(GOLD["doc_id"])
        text = T.to_lean(GOLD, seg)
        self.assertIn("DRAFT, NOT HUMAN-REVIEWED", text)
        self.assertNotIn("sorry", text)
        self.assertNotIn("axiom", text)

    def test_compare_identical_and_different(self):
        self.assertEqual(T.compare(GOLD, GOLD)["only_first"], [])
        d = copy.deepcopy(GOLD)
        d["norms"][5]["exceptions"] = []
        r = T.compare(d, GOLD)
        self.assertEqual((len(r["only_first"]), len(r["only_second"])), (1, 1))
        d = copy.deepcopy(GOLD)
        d["norms"][0]["act"] = "ban_bia"          # naming differences are reported, not hidden
        self.assertEqual(len(T.compare(d, GOLD)["only_first"]), 1)

    def test_relaxed_compare_merges_or_of_same_source_atoms_only(self):
        d = copy.deepcopy(GOLD)
        a = d["atoms"]["situation"][3]            # the khoản 4 atom of the gold file
        extra = dict(a, name=a["name"] + " (b)")
        d["atoms"]["situation"].append(extra)
        d["norms"][3]["condition"] = {"or": [{"sit": a["name"]}, {"sit": extra["name"]}]}
        self.assertEqual(len(T.compare(d, GOLD)["only_first"]), 1)                  # strict: different
        self.assertEqual(T.compare(d, GOLD, relaxed=True)["only_first"], [])        # relaxed: same
        d["norms"][3]["condition"] = {"and": [{"sit": a["name"]}, {"sit": extra["name"]}]}
        self.assertEqual(len(T.compare(d, GOLD, relaxed=True)["only_first"]), 1)    # never for `and`

    def test_cli_refuses_a_bad_file_and_writes_nothing(self):
        d = copy.deepcopy(GOLD)
        d["norms"][0]["quote"] = "bịa"
        tmp = tempfile.mkdtemp()
        try:
            src, out = os.path.join(tmp, "x.json"), os.path.join(tmp, "x.lean")
            json.dump(d, open(src, "w", encoding="utf-8"), ensure_ascii=False)
            rc = T.main(["lean", src, "-o", out])
            self.assertEqual(rc, 1)
            self.assertFalse(os.path.exists(out))
        finally:
            shutil.rmtree(tmp)


@unittest.skipIf(shutil.which("lake") is None, "lake không có trong PATH")
class LeanRun(unittest.TestCase):
    def test_gold_draft_has_no_pfindings_and_is_consistent_on_the_encoded_part(self):
        tmp = tempfile.mkdtemp()
        try:
            out = os.path.join(tmp, "Article19Draft.lean")
            self.assertEqual(T.main(["lean", GOLD_PATH, "-o", out]), 0)
            r = subprocess.run(["lake", "env", "lean", "--run", out], cwd=T.ROOT, capture_output=True, text=True, encoding="utf-8")
            self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
            self.assertIn("pfindings: 0", r.stdout)
            self.assertIn("consistentOn", r.stdout)
            self.assertIn("DRAFT, NOT HUMAN REVIEWED", r.stdout)
        finally:
            shutil.rmtree(tmp)

    def run_draft(self, data):
        tmp = tempfile.mkdtemp()
        try:
            out = os.path.join(tmp, "Draft.lean")
            with open(out, "w", encoding="utf-8") as f:
                f.write(T.to_lean(data, T.load_segmented(data["doc_id"])))
            r = subprocess.run(["lake", "env", "lean", "--run", out], cwd=T.ROOT, capture_output=True, text=True, encoding="utf-8")
            self.assertEqual(r.returncode, 0, r.stderr + r.stdout)
            return r.stdout
        finally:
            shutil.rmtree(tmp)

    def test_lean_checks_references_at_clause_and_point_level(self):
        d = copy.deepcopy(GOLD)
        d["norms"][5]["references"] = ["Điều 15 khoản 4", "Điều 15 khoản 1 điểm a"]
        self.assertIn("pfindings: 0", self.run_draft(d))
        d["norms"][5]["references"] = ["Điều 15 khoản 9"]     # `check` refuses this; Lean must catch it too
        out = self.run_draft(d)
        self.assertIn("pfindings: 1", out)
        self.assertIn("danglingReference", out)


if __name__ == "__main__":
    unittest.main()
