# -*- coding: utf-8 -*-
"""Tests for pipeline/edges.py. Edge files and sheets here are SYNTHETIC (reviewer «TEST»): they exercise the
tool, they are not reviews."""
import copy
import json
import os
import shutil
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, ".."))
import edges as E   # noqa: E402
import translate as T   # noqa: E402

HAS_LAKE = shutil.which("lake") is not None


def edge(i, a, b, src="Điều 32 khoản 4", st="proposed"):
    return {"id": "E%d" % i, "src": a, "dst": b, "source": src, "reading": "test", "proposed_by": "TEST", "status": st}


BASE = {"doc_id": "44/2019/QH14", "glossary": "data/glossary/44-2019-QH14.json",
        "edges": [edge(1, "thu_hoi_xu_ly_ruou_bia", "van_chuyen_ruou_bia"),
                  edge(2, "ban_ruou_bia_bang_may_tu_dong", "ban_ruou_bia", "Điều 5 khoản 11")]}


class Check(unittest.TestCase):
    def test_clean_file_has_no_finding(self):
        self.assertEqual(E.check(copy.deepcopy(BASE)), [])

    def test_unknown_act_bad_ref_duplicate_and_self_loop(self):
        d = copy.deepcopy(BASE)
        d["edges"] += [edge(3, "khong_co_act_nay", "ban_ruou_bia"), edge(4, "ban_ruou_bia", "ban_ruou_bia"),
                       edge(1, "uong_ruou_bia", "ban_ruou_bia", "Điều 99 khoản 1"),
                       edge(5, "thu_hoi_xu_ly_ruou_bia", "van_chuyen_ruou_bia")]
        fs = E.check(d)
        for s in ("khong_co_act_nay", "hai đầu cạnh trùng nhau", "id trùng: E1", "cạnh trùng", "Điều 99"):
            self.assertTrue(any(s in f for f in fs), (s, fs))

    def test_hand_written_status_is_a_finding(self):
        d = copy.deepcopy(BASE)
        d["edges"][0]["status"] = "approved"
        d["edges"][0].update(reviewed_by="X", reviewed_on="2000-01-01")
        self.assertTrue(any("edges.py apply" in f for f in E.check(d)))


class Chain(unittest.TestCase):
    def test_chain_reads_nested_ids(self):
        self.assertEqual(E.chain("SUY RA [a ⇒ b] SUY RA [b ⇒ c] Điều 5:5.1"), ([("a", "b"), ("b", "c")], "Điều 5:5.1"))
        self.assertEqual(E.chain("Điều 5:5.1"), ([], "Điều 5:5.1"))


class Review(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp()
        self.path = os.path.join(self.dir, "edges.json")
        with open(self.path, "w", encoding="utf-8") as f:
            json.dump(BASE, f, ensure_ascii=False)

    def tearDown(self):
        shutil.rmtree(self.dir)

    def sheet(self, ticks, ids=None):
        text = E.make_sheet(self.path, E.load(self.path), ids)
        text = text.replace("Người duyệt: ", "Người duyệt: TEST", 1).replace("Ngày duyệt (YYYY-MM-DD): ", "Ngày duyệt (YYYY-MM-DD): 2000-01-01", 1)
        lines = []
        for l in text.splitlines():
            for i, (k, why) in ticks.items():
                if l.startswith("| E:%s " % i):
                    opts = ["☐ Chấp nhận", "☐ Bác", "☐ Để sau"]
                    opts[k] = opts[k].replace("☐", "☒")
                    l = l.replace("☐ Chấp nhận<br>☐ Bác<br>☐ Để sau", "<br>".join(opts)).rstrip()
                    l = l[:-1].rstrip() + " " + why + " |" if l.endswith("|") else l
            lines.append(l)
        sp = os.path.join(self.dir, "sheet.md")
        with open(sp, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        return sp

    def test_demand_driven_sheet_has_only_the_named_edges(self):
        text = E.make_sheet(self.path, E.load(self.path), ["E1"])
        self.assertIn("| E:E1 ", text)
        self.assertNotIn("| E:E2 ", text)

    def test_apply_writes_decisions_and_content_hash(self):
        sp = self.sheet({"E1": (0, ""), "E2": (1, "bán bằng máy vẫn là bán, nhưng thử bác")})
        print_ = E.apply_sheet(self.path, sp)
        self.assertIn("chấp nhận 1, bác 1", print_)
        d = E.load(self.path)
        self.assertEqual([e["status"] for e in d["edges"]], ["approved", "rejected"])
        self.assertEqual(E.check(d), [])
        self.assertEqual([e["id"] for e in E.approved(d)], ["E1"])
        self.assertEqual([e["id"] for e in E.live(d)], ["E1"])

    def test_rejection_without_reason_and_changed_file_are_refused(self):
        sp = self.sheet({"E1": (1, "")}, ["E1"])
        with self.assertRaises(SystemExit) as cm:
            E.apply_sheet(self.path, sp)
        self.assertIn("không ghi lý do", str(cm.exception))
        sp = self.sheet({"E1": (0, "")}, ["E1"])
        d = E.load(self.path)
        d["edges"][0]["reading"] = "đổi"
        with open(self.path, "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False)
        with self.assertRaises(SystemExit) as cm:
            E.apply_sheet(self.path, sp)
        self.assertIn("sha256 tệp cạnh", str(cm.exception))

    def test_module_refuses_without_approved_edges(self):
        with self.assertRaises(SystemExit) as cm:
            E.module(self.path, "TestEdges", build=False)
        self.assertIn("chưa có cạnh nào được duyệt", str(cm.exception))


class Lean(unittest.TestCase):
    def test_draft_and_module_text_shape(self):
        es = BASE["edges"]
        t = E.draft_text(es, "Law44")
        for s in ("import LexProof.Laws.Law44", "import LexProof.Verify.Entail", "def edges : List Edge :=",
                  "derive edges norms", "DRAFT, NOT HUMAN-REVIEWED"):
            self.assertIn(s, t)
        m = E.module_text(es, "TestEdges", "Law44", False)
        self.assertIn("theorem has_conflict", m)
        self.assertNotIn("sorry", m)
        self.assertIn("theorem consistent", E.module_text(es, "TestEdges", "Law44", True))

    @unittest.skipUnless(HAS_LAKE and os.path.exists(os.path.join(T.ROOT, ".lake", "build", "lib", "lean", "LexProof", "Laws",
                                                                      "Law44.olean")), "cần lake và Law44 đã build")
    def test_draft_on_law44_finds_the_recall_candidate_through_e1_only(self):
        d = tempfile.mkdtemp()
        try:
            p = os.path.join(d, "edges.json")
            with open(p, "w", encoding="utf-8") as f:
                json.dump(BASE, f, ensure_ascii=False)
            rp, res, need, pairs = E.draft(p, "Law44", d, today="2000-01-01")
            self.assertTrue(res.startswith("KẾT QUẢ: XUNG ĐỘT"), res)
            self.assertEqual(need, ["E1"])
            self.assertTrue(any("Điều 5:5.12.i.c" in l or "Điều 5:5.12.i.c" in r for l, r in pairs))
        finally:
            shutil.rmtree(d)


if __name__ == "__main__":
    unittest.main()
