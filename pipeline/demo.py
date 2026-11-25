# -*- coding: utf-8 -*-
"""One-command demo of LexProof (N7, N10). UNTRUSTED driver: it runs the real tools and prints what they say.

    python pipeline/demo.py [--no-build] [--out-dir eval/demo]

Steps, each printed with its result:
  1. `lake build` (kernel checks every theorem, axiom audit, encapsulation audit);
  2. the report of the merged module (`report.py --module law44 --status draft`), written to the out dir;
  3. a SEEDED conflict: one reviewed norm copied with the opposite modality; the checker must find the pair and print
     the situation in words (this is the evidence that the checker finds a conflict when there is one);
  4. the edge draft (conflicts through «doing A entails doing B», unreviewed edges included);
  5. the readings table (the same candidate under alternative readings);
  6. the drafting-defect scan.
Nothing is written into `reports/`, `LexProof/` or `data/`.
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import time

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import translate as T   # noqa: E402
import run as RUN       # noqa: E402
import readings as RD   # noqa: E402
import edges as E       # noqa: E402
import drafting as D    # noqa: E402

ROOT = T.ROOT


def say(s=""):
    print(s, flush=True)


def step(n, title):
    say("")
    say("=" * 78)
    say("BƯỚC %d. %s" % (n, title))
    say("=" * 78)


def main(argv=None):
    for s in (sys.stdout, sys.stderr):
        if hasattr(s, "reconfigure"):
            s.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--no-build", action="store_true", help="bỏ bước lake build (dùng bản đã build)")
    ap.add_argument("--out-dir", default=os.path.join(ROOT, "eval", "demo"))
    a = ap.parse_args(argv)
    os.makedirs(a.out_dir, exist_ok=True)
    lake = shutil.which("lake")
    if lake is None:
        say("KHÔNG CHẠY ĐƯỢC: không tìm thấy `lake` trong PATH (cài elan, xem README).")
        return 1

    say("LexProof: kiểm tính nhất quán của Luật 44/2019/QH14 (Level 1). Không phải tư vấn pháp lý.")

    step(1, "Build: kernel Lean kiểm mọi định lý; audit axiom và audit đóng gói")
    if a.no_build:
        say("bỏ qua (--no-build): các định lý KHÔNG được kiểm lại trong lần chạy này")
    else:
        t = time.time()
        r = subprocess.run([lake, "build"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
        out = r.stdout + r.stderr
        for line in out.splitlines():
            if "axiom audit" in line or "encapsulation audit" in line or "Build completed" in line:
                say(line.strip()[:200])
        say("%s sau %.0f giây" % ("THÀNH CÔNG" if r.returncode == 0 else "THẤT BẠI", time.time() - t))
        if r.returncode != 0:
            say(out[-2000:])
            return 1

    step(2, "Báo cáo của module gộp Law44 (15 điều đã duyệt, 73 norm)")
    r = subprocess.run([sys.executable, os.path.join(HERE, "report.py"), "--module", "law44", "--status", "draft",
                        "--no-build", "--out-dir", a.out_dir], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    if r.returncode != 0:
        say("LỖI: " + (r.stdout + r.stderr)[-1500:])
        return 1
    rp = r.stdout.strip().splitlines()[-1]
    text = open(rp, encoding="utf-8").read()
    for line in text.splitlines():
        if line.startswith(("**Nhất quán", "**Tìm thấy", "**Không biết", "**Cảnh báo rỗng", "| **Cộng**")):
            say(line[:220])
    say("báo cáo đầy đủ: %s" % RUN.rel(rp))

    step(3, "Gieo một xung đột: bộ kiểm phải tìm ra nó và in tình huống bằng lời")
    merged, seg = RD.base({"doc_id": "44/2019/QH14", "module": "Law44"})
    n = next(x for x in merged["norms"] if x["id"] == "Điều 19:19.1")
    seeded = dict(n, id="GIEO: cho phép (ngược với 19.1)", modality="permission")
    say("norm gốc: %s (%s, %s); bản gieo: cùng hành vi, cùng điều kiện, tính chất «được phép»" % (n["id"], n["modality"], n["act"]))
    lp = os.path.join(a.out_dir, "seeded.lean")
    with open(lp, "w", encoding="utf-8", newline="\n") as f:
        f.write(T.to_lean(dict(merged, norms=merged["norms"] + [seeded]), seg))
    res = RUN.run_lean(lp)
    say("kết quả: %s" % next((l for l in res["stdout"].splitlines() if l.startswith("KẾT QUẢ")), "LỖI " + str(res.get("why"))))
    blocks, cur = [], None
    for line in res["stdout"].split("PHẢN VÍ DỤ", 1)[-1].splitlines():
        if line.startswith("  ▸ "):
            cur = [line]
            blocks.append(cur)
        elif cur is not None:
            cur.append(line)
    own = [b for b in blocks if b[0].startswith("  ▸ Điều 19:19.1 (")]
    say("phản ví dụ của cặp gieo với norm gốc (các cặp khác: bản gieo cũng trái với mọi lệnh cấm bán khác áp dụng ở cùng tình huống):")
    for b in own:
        for line in b:
            say(line)
    say("(%d cặp; danh sách đầy đủ trong %s khi chạy `lake env lean --run`)" % (len(blocks), RUN.rel(lp)))

    step(4, "Xung đột qua quan hệ giữa hành vi (cạnh kéo theo; có cạnh AI đề xuất, CHƯA DUYỆT)")
    rp4, res4, need, pairs = E.draft(os.path.join(ROOT, "data", "edges", "44-2019-QH14.json"), "Law44", a.out_dir)
    say(res4)
    origins = sorted({tuple(sorted((E.chain(l)[1], E.chain(r_)[1]))) for l, r_ in pairs})
    for o in origins:
        say("  cặp norm gốc: %s × %s" % o)
    say("cạnh cần người duyệt trước: %s (trên tổng %d cạnh)" % (", ".join(need) or "không có",
                                                              len(E.load(os.path.join(ROOT, "data", "edges", "44-2019-QH14.json"))["edges"])))
    say("chi tiết và phản ví dụ: %s" % RUN.rel(rp4))

    step(5, "Cùng ứng viên, theo từng cách đọc (cách đọc do AI đề xuất, CHƯA DUYỆT)")
    rp5, rows = RD.run(os.path.join(ROOT, "data", "readings", "44-2019-QH14.json"), a.out_dir)
    for x in rows:
        say("  %s: %s; %d cặp norm gốc — %s" % (x["id"], x["result"], len(x["origins"]), x["reading"][:90]))

    step(6, "Dấu hiệu lỗi soạn thảo (norm chết, norm thừa, ngoại lệ không kích hoạt)")
    _, live, notsub, exc, unknown = D.scan(merged)
    say("chứng nhân: %d norm sống, %d cặp không bao trùm, %d ngoại lệ có kích hoạt; không biết: %d"
        % (len(live), len(notsub), len(exc), len(unknown)))
    for u in unknown:
        say("  - " + u[3])

    say("")
    say("Giới hạn: kernel chứng minh suy luận, KHÔNG chứng minh bản mã hóa khớp luật (một người duyệt; chưa có bộ ca của "
        "người học luật). Cạnh và cách đọc ở bước 4–5 là đề xuất chưa duyệt. Xem mục 7 của báo cáo.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
