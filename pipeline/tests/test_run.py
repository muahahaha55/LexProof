# -*- coding: utf-8 -*-
"""Tests for pipeline/run.py. Run: python -m unittest discover -s pipeline/tests -v   (from the repo root).
The two Lean runs need `lake` on PATH."""
import copy
import json
import os
import shutil
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import run as RUN   # noqa: E402
import translate as T   # noqa: E402

TR = os.path.join(T.ROOT, "eval", "translate")
GOLD19 = json.load(open(os.path.join(TR, "article19.gold.json"), encoding="utf-8"))
LLM5 = os.path.join(TR, "article5.llm.json")
REJ5 = os.path.join(TR, "article5.llm.rejected-1.json")


def seg():
    s = T.load_segmented("44/2019/QH14")
    s["doc_id"] = "44/2019/QH14"
    return s


class Tmp(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()

    def tearDown(self):
        shutil.rmtree(self.dir)

    def write(self, name, d):
        p = os.path.join(self.dir, name)
        with open(p, "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False)
        return p


class Merge(unittest.TestCase):
    def test_atoms_and_ids_are_prefixed_so_articles_never_share_by_accident(self):
        a = copy.deepcopy(GOLD19)
        b = json.load(open(LLM5, encoding="utf-8"))
        m = RUN.merge([a, b])
        names = [x["name"] for x in m["atoms"]["situation"]]
        self.assertEqual(len(names), len(set(names)))
        self.assertTrue(all(n.startswith(("Điều 19 · ", "Điều 5 · ")) for n in names))
        self.assertTrue(all(n["id"].startswith(("Điều 19:", "Điều 5:")) for n in m["norms"]))
        self.assertEqual(m["norms"][0]["condition"], {"sit": "Điều 19 · " + GOLD19["norms"][0]["condition"]["sit"]})
        self.assertEqual(len(m["norms"]), len(a["norms"]) + len(b["norms"]))

    def test_compact(self):
        self.assertEqual(RUN.compact([1, 2, 3, 5, 7, 8]), "1–3, 5, 7–8")
        self.assertEqual(RUN.compact([]), "—")


class Admit(Tmp):
    def test_refused_file_is_listed_and_not_merged(self):
        acc, ref, _ = RUN.admit([REJ5, LLM5], seg())
        self.assertEqual([d["article"] for d in acc], [5])
        self.assertEqual(len(ref), 1)
        self.assertIn("không phân tích được", " ".join(ref[0][1]))

    def test_second_translation_of_one_article_is_refused(self):
        p = self.write("g19.json", GOLD19)
        q = self.write("g19b.json", GOLD19)
        acc, ref, _ = RUN.admit([p, q], seg())
        self.assertEqual(len(acc), 1)
        self.assertIn("mỗi điều chỉ một bản dịch", ref[0][1][0])

    def test_unreadable_or_wrong_shape_is_refused_not_crashing(self):
        bad = os.path.join(self.dir, "bad.json")
        open(bad, "w", encoding="utf-8").write("{ không phải json")
        shape = self.write("shape.json", dict(GOLD19, atoms=[]))
        acc, ref, _ = RUN.admit([bad, shape], seg())
        self.assertEqual(acc, [])
        self.assertEqual(len(ref), 2)

    def test_changed_extracted_text_stops_everything(self):
        p = self.write("g19.json", GOLD19)
        old = RUN.sha_raw
        RUN.sha_raw = lambda path: "0" * 64
        try:
            _, text, head = RUN.run("44/2019/QH14", [p], self.dir, lean=False, today="2000-01-01")
        finally:
            RUN.sha_raw = old
        self.assertEqual(head, "không biết")
        self.assertIn("không khớp tệp trích hiện tại", text)
        self.assertFalse(os.path.exists(os.path.join(self.dir, "44-2019-QH14-2000-01-01.lean")))


class Verdict(unittest.TestCase):
    def test_three_values_and_fail_closed(self):
        ok = {"ok": True, "pfindings": 0, "result": "consistentOn", "vacuous": True}
        self.assertEqual(RUN.verdict(None, False)[0], "không biết")
        self.assertEqual(RUN.verdict(None, True)[0], "không biết")
        self.assertEqual(RUN.verdict({"ok": False, "why": "x"}, True)[0], "không biết")
        self.assertEqual(RUN.verdict(dict(ok, pfindings=None), True)[0], "không biết")
        self.assertEqual(RUN.verdict(dict(ok, pfindings=2), True)[0], "không biết")
        self.assertEqual(RUN.verdict(dict(ok, result="INVALID"), True)[0], "không biết")
        self.assertEqual(RUN.verdict(dict(ok, result="XUNG ĐỘT"), True)[0], "tìm thấy xung đột")
        h, why = RUN.verdict(ok, True)
        self.assertEqual(h, "nhất quán trên phần đã mã hóa")
        self.assertIn("rỗng về thông tin", why)


@unittest.skipIf(shutil.which("lake") is None, "lake không có trong PATH")
class LeanRuns(Tmp):
    def test_two_articles_consistent_but_vacuous_and_scope_listed(self):
        p = self.write("g19.json", GOLD19)
        rep, text, head = RUN.run("44/2019/QH14", [p, LLM5, REJ5], self.dir, today="2000-01-01")
        self.assertEqual(head, "nhất quán trên phần đã mã hóa")
        self.assertIn("BẢN NHÁP, CHƯA CÓ NGƯỜI DUYỆT", text)
        self.assertIn("rỗng về thông tin", text)
        self.assertIn("| chưa dịch | 34 |", text)
        self.assertIn("article5.llm.rejected-1.json", text)
        self.assertIn("Evaluated", text)
        self.assertIn("Level 2", text)

    def test_a_permission_against_a_prohibition_is_found(self):
        d = copy.deepcopy(GOLD19)
        d["norms"].append(dict(d["norms"][0], id="19.1-cho-phep", modality="permission"))
        p = self.write("conflict.json", d)
        _, text, head = RUN.run("44/2019/QH14", [p], self.dir, today="2000-01-01")
        self.assertEqual(head, "tìm thấy xung đột", text[:2000])


if __name__ == "__main__":
    unittest.main()
