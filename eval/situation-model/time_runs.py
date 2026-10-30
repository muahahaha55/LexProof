# -*- coding: utf-8 -*-
"""Cold wall-clock timing: `lake env lean <file>` run N times per file.

usage: python time_runs.py N file1.lean file2.lean ...   (paths relative to repo root)
Appends one CSV line per run to eval/situation-model/timings.csv and prints a summary.
A run that exits non-zero or prints `error` is recorded with status FAIL.
"""
import csv
import os
import statistics
import subprocess
import sys
import time

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CSV = os.path.join(os.path.dirname(__file__), "timings.csv")


def run_once(path):
    t0 = time.perf_counter()
    p = subprocess.run(["lake", "env", "lean", path], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    dt = time.perf_counter() - t0
    ok = p.returncode == 0 and "error" not in p.stdout.lower()
    return dt, ok, p.stdout


def main():
    n = int(sys.argv[1])
    files = sys.argv[2:]
    new = not os.path.exists(CSV)
    with open(CSV, "a", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        if new:
            w.writerow(["file", "run", "seconds", "status", "timestamp"])
        for fn in files:
            ts = []
            for r in range(1, n + 1):
                dt, ok, out = run_once(fn)
                w.writerow([os.path.basename(fn), r, "%.3f" % dt, "OK" if ok else "FAIL",
                            time.strftime("%Y-%m-%d %H:%M:%S")])
                f.flush()
                ts.append(dt)
                if not ok:
                    print("FAIL", fn, out[:300])
                    break
            print("%-26s runs=%s  median=%.2fs" % (os.path.basename(fn), ", ".join("%.2f" % t for t in ts),
                                                    statistics.median(ts)))


if __name__ == "__main__":
    main()
