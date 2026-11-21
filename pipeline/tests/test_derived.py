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
from test_glossary import gold19_with_glossary, only_19_1, has, frozen_glossary, GREL   # noqa: E402

# A frozen copy of data/derived/44-2019-QH14.json before review (both readings proposed), its «glossary» pointed at the
# frozen glossary of test_glossary: the live files change when a reviewer decides, the tests must not.
FROZEN_PATH = os.path.join(HERE, "derived_before_review.json")
FROZEN = D.load(FROZEN_PATH)
_patch = frozen_glossary()


def setUpModule():
    _patch.start()


def tearDownModule():
    _patch.stop()
HAS_LAKE = shutil.which("lake") is not None


def one(**kw):
    e = {"id": "D1", "modality": "permission", "act": "ban_ruou_bia", "condition": {"sit": "dia_diem_co_so_y_te"},
         "exceptions": [], "derived_from": ["Điều 19 khoản 1"], "reading": "thử", "proposed_by": "TEST", "status": "proposed"}
    e.update(kw)
    return {"doc_id": "44/2019/QH14", "glossary": GREL, "derived": [e]}


def rejected(**kw):
    """`one` decided as rejected, the way `apply` writes it."""
    dd = one(**kw)
    e = dd["derived"][0]
    e.update(status="rejected", reviewed_by="TEST", reviewed_on="2000-01-01")
    e["reviewed_content_sha256"] = D.content_sha(e)
    return dd


class Check(unittest.TestCase):
    def test_frozen_file_has_no_finding_and_nothing_is_approved(self):
        self.assertEqual(D.check(FROZEN), [])
        self.assertTrue(all(e["status"] == "proposed" for e in FROZEN["derived"]))

    def test_a_rejected_reading_is_a_record_only_its_terms_are_not_checked_and_it_is_not_run(self):
        dd = rejected(condition={"sit": "khong_co"})          # e.g. rejected because its term was rejected
        self.assertEqual(D.check(dd), [])
        self.assertEqual(D.as_translation(dd, "law", "2020-01-01")["norms"], [])
        self.assertTrue(has(D.check(rejected(derived_from=[])), "derived_from"))   # the record itself is still checked

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

    def test_a_file_of_rejected_readings_is_not_run(self):
        tr = self.write("a19.json", only_19_1(gold19_with_glossary()))
        dv = self.write("d.json", rejected())
        _, text, _ = RUN.run("44/2019/QH14", [tr], os.path.join(self.dir, "out"), lean=False, derived=dv, today="2000-01-01")
        self.assertIn("Không chạy: mọi norm suy ra trong tệp đều đã bị bác", text)
        self.assertFalse(os.path.exists(os.path.join(self.dir, "out", "44-2019-QH14-2000-01-01-suy-ra.lean")))


def tick(text, did, option, reason=""):
    opts = ["Chấp nhận", "Bác", "Để sau"]
    new = "<br>".join(("☒ " if i == option else "☐ ") + o for i, o in enumerate(opts))
    return "\n".join(l.replace(D.G.OPTIONS + " |  |", new + " | %s |" % reason) if l.startswith("| D:%s |" % did) else l
                     for l in text.splitlines())


class ReviewSheet(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.f = os.path.join(self.dir, "d.json")
        shutil.copy(FROZEN_PATH, self.f)
        self.blank = D.make_sheet(self.f, D.load(self.f))

    def tearDown(self):
        shutil.rmtree(self.dir)

    def filled(self, **dec):
        t = self.blank.replace("Người duyệt: ", "Người duyệt: TEST", 1)
        t = t.replace("Ngày duyệt (YYYY-MM-DD): ", "Ngày duyệt (YYYY-MM-DD): 2000-01-01", 1)
        for did, (opt, why) in dec.items():
            t = tick(t, did, opt, why)
        return t

    def apply(self, text):
        sh = os.path.join(self.dir, "s.md")
        with open(sh, "w", encoding="utf-8") as f:
            f.write(text)
        return D.apply_sheet(self.f, sh)

    def test_blank_sheet_pins_both_files_and_is_refused(self):
        self.assertEqual(self.blank.count("| D:"), 2)
        self.assertIn("sha256 tệp norm suy ra: " + D.G.sha_lf(self.f), self.blank)
        self.assertIn("sha256 bảng thuật ngữ: " + T.glossary_sha(T.glossary_rel("44/2019/QH14")), self.blank)
        self.assertIn("atom co_giay_phep_hoac_dang_ky_kinh_doanh_ruou [proposed]", self.blank)
        ps, _, _ = D.sheet_problems(D.load(self.f), self.f, self.blank)
        self.assertIn("chưa ghi người duyệt", ps)
        self.assertTrue(has(ps, "D1", "đúng một ô"))
        with self.assertRaises(SystemExit):
            self.apply(self.blank)

    def test_apply_then_an_edit_of_an_approved_reading_is_a_finding(self):
        msg = self.apply(self.filled(D1=(0, ""), D2=(1, "đủ điều kiện chưa phải là có giấy phép")))
        self.assertIn("chấp nhận 1, bác 1, để sau 0", msg)
        dd = D.load(self.f)
        self.assertEqual(D.check(dd), [])
        d1, d2 = dd["derived"]
        self.assertEqual((d1["status"], d1["reviewed_by"], d1["reviewed_content_sha256"]), ("approved", "TEST", D.content_sha(d1)))
        self.assertEqual((d2["status"], d2["review_note"]), ("rejected", "đủ điều kiện chưa phải là có giấy phép"))
        self.assertEqual(D.make_sheet(self.f, dd).count("| D:"), 0)
        d1["exceptions"] = [{"sit": "ruou_bia_gia"}]                       # someone adds an exception afterwards
        self.assertTrue(has(D.check(dd), "D1", "nội dung đã đổi sau khi duyệt"))

    def test_approval_by_hand_or_with_a_changed_glossary_is_refused(self):
        dd = D.load(self.f)
        dd["derived"][0].update(status="approved", reviewed_by="X", reviewed_on="2000-01-01")
        self.assertTrue(has(D.check(dd), "derived.py apply"))
        _, _, sheet = D.sheet_problems(D.load(self.f), self.f, self.filled(D1=(0, ""), D2=(2, "")))
        text = self.filled(D1=(0, ""), D2=(2, "")).replace(sheet["glossary_sha"], "0" * 64)
        ps, _, _ = D.sheet_problems(D.load(self.f), self.f, text)
        self.assertTrue(has(ps, "bảng thuật ngữ"))


if __name__ == "__main__":
    unittest.main()
