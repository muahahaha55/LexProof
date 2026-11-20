# -*- coding: utf-8 -*-
"""Tests for pipeline/derived.py and `run.py --derived` (ADR-0028). Fixtures here are synthetic, not readings of the law."""
import copy
import json
import os
import shutil
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
sys.path.insert(0, HERE)
import derived as D     # noqa: E402
import run as RUN       # noqa: E402
import translate as T   # noqa: E402
from test_glossary import gold19_with_glossary, only_19_1, has   # noqa: E402

REAL = D.load(os.path.join(T.ROOT, "data", "derived", "44-2019-QH14.json"))
HAS_LAKE = shutil.which("lake") is not None


def one(**kw):
    e = {"id": "D1", "modality": "permission", "act": "ban_ruou_bia", "condition": {"sit": "dia_diem_co_so_y_te"},
         "exceptions": [], "derived_from": ["Điều 19 khoản 1"], "reading": "thử", "proposed_by": "TEST", "status": "proposed"}
    e.update(kw)
    return {"doc_id": "44/2019/QH14", "glossary": "data/glossary/44-2019-QH14.json", "derived": [e]}


class Check(unittest.TestCase):
    def test_real_file_has_no_finding_and_nothing_is_approved(self):
        self.assertEqual(D.check(REAL), [])
        self.assertTrue(all(e["status"] == "proposed" for e in REAL["derived"]))

    def test_terms_must_come_from_the_glossary(self):
        self.assertTrue(has(D.check(one(act="kinh_doanh_bat_ky")), "không có trong bảng thuật ngữ"))
        self.assertTrue(has(D.check(one(condition={"sit": "khong_co"})), "không tồn tại"))
        self.assertTrue(has(D.check(one(condition={"sit": "do_con", "value": "40 độ"})), "không có nhãn"))

    def test_a_reading_must_be_sourced_said_and_attributed(self):
        self.assertTrue(has(D.check(one(derived_from=[])), "derived_from"))
        self.assertTrue(has(D.check(one(derived_from=["Điều 19 khoản 9"])), "không tồn tại"))
        self.assertTrue(has(D.check(one(reading="")), "reading"))
        self.assertTrue(has(D.check(one(proposed_by="")), "proposed_by"))
        self.assertTrue(has(D.check(one(id="X1")), "D1, D2"))
        self.assertTrue(has(D.check(one(status="approved")), "reviewed_by"))

    def test_derived_norms_become_a_glossary_translation_with_marked_ids(self):
        m = T.materialize(D.as_translation(one(), "law", "2020-01-01"))
        self.assertEqual([n["id"] for n in m["norms"]], ["SUY RA D1"])
        self.assertEqual([a["name"] for a in m["atoms"]["situation"]], ["dia_diem_co_so_y_te"])
        self.assertTrue(m["atoms"]["situation"][0]["shared"])
        self.assertIn("SUY RA D1 [proposed, đề xuất bởi TEST]", m["assumptions"][0])


class Run(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()

    def tearDown(self):
        shutil.rmtree(self.dir)

    def write(self, name, d):
        p = os.path.join(self.dir, name)
        with open(p, "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False)
        return p

    @unittest.skipUnless(HAS_LAKE, "lake không có trong PATH")
    def test_conflict_with_a_derived_norm_is_reported_apart_and_leaves_the_headline(self):
        tr = self.write("a19.json", only_19_1(gold19_with_glossary()))      # 19.1: prohibited at a medical facility
        dv = self.write("d.json", one())                                    # D1: permitted at a medical facility
        _, text, head = RUN.run("44/2019/QH14", [tr], os.path.join(self.dir, "out"), derived=dv, today="2000-01-01")
        self.assertEqual(head, "nhất quán trên phần đã mã hóa")             # the text alone: one prohibition
        self.assertIn("## 5b. Kiểm thêm với norm suy ra (KHÔNG phải chữ luật)", text)
        self.assertIn("**TÌM THẤY XUNG ĐỘT** (khi thêm norm suy ra)", text)
        self.assertIn("Cặp xung đột chỉ có vì một norm suy ra: 1/1", text)
        self.assertIn("- Điều 19:19.1 × SUY RA D1", text)

    def test_a_bad_derived_file_is_unknown_and_not_run(self):
        tr = self.write("a19.json", only_19_1(gold19_with_glossary()))
        dv = self.write("d.json", one(act="khong_co"))
        _, text, _ = RUN.run("44/2019/QH14", [tr], os.path.join(self.dir, "out"), lean=False, derived=dv, today="2000-01-01")
        self.assertIn("**KHÔNG BIẾT** — tệp norm suy ra có 1 phát hiện, không chạy", text)
        self.assertFalse(os.path.exists(os.path.join(self.dir, "out", "44-2019-QH14-2000-01-01-suy-ra.lean")))


if __name__ == "__main__":
    unittest.main()
