import re, sys, io, unicodedata
SC = sys.argv[1]
def load(p):
    return io.open(p, encoding="utf-8").read()
srcs = {
  "layout(-layout, = data/extracted)": load("data/extracted/44-2019-QH14.txt"),
  "raw(-raw)": load(SC + "/raw_mode.txt"),
  "plain(default)": load(SC + "/plain_mode.txt"),
}
def clean(t):
    t = unicodedata.normalize("NFC", t)
    # drop running page lines of the Cong bao
    t = re.sub(r"^\s*\d*\s*CÔNG BÁO/Số 559 \+ 560/Ngày 17-7-2019\s*\d*\s*$", " ", t, flags=re.M)
    t = re.sub(r"\s+", " ", t)
    return t
def article(t, n):
    m = re.search(r"Điều %d\. " % n, t)
    if not m: return None
    nxt = re.search(r"Điều %d\. " % (n+1), t[m.end():])
    end = m.end() + nxt.start() if nxt else len(t)
    return t[m.start():end].strip()
res = {}
for name, t in srcs.items():
    c = clean(t)
    res[name] = {n: article(c, n) for n in (2, 5, 10, 12, 13, 19)}
base = "layout(-layout, = data/extracted)"
ok = True
for n in (2, 5, 10, 12, 13, 19):
    a = res[base][n]
    for name in res:
        if name == base: continue
        b = res[name][n]
        same = (a == b)
        print(f"Điều {n:>2}  {base.split('(')[0]} vs {name.split('(')[0]:<6} identical={same}  len {len(a)} / {len(b)}")
        if not same:
            ok = False
            # first divergence
            i = next((k for k in range(min(len(a), len(b))) if a[k] != b[k]), min(len(a), len(b)))
            print("   first diff at", i, "|", repr(a[max(0,i-40):i+40]), "|", repr(b[max(0,i-40):i+40]))
print("ALL IDENTICAL" if ok else "DIFFERENCES FOUND")

import difflib
a = res[base][2]; b = res["raw(-raw)"][2]
sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
print("\n--- Điều 2: layout vs raw, all non-equal opcodes ---")
for tag, i1, i2, j1, j2 in sm.get_opcodes():
    if tag != "equal":
        print(tag, "| layout:", repr(a[max(0,i1-25):i2+25]), "| raw:", repr(b[max(0,j1-25):j2+25]))
