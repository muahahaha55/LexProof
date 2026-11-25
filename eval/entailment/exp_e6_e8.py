# E6: lỗi Level 1 không cần cặp khắc nhau — norm chết (không bao giờ áp dụng) và norm thừa (bị norm khác cùng act, cùng modality bao trùm).
# Python, KHÔNG tin cậy, bỏ qua Atoms.valid. Chỉ để xem hướng có ra gì không.
import sys, os, json, itertools
sys.path.insert(0, r'D:\LexProof\pipeline'); os.chdir(r'D:\LexProof')
import run as R, translate as T
FILES = ['eval/translate/article5.glossary-3.llm.json'] + ['eval/translate/article%d.glossary.llm.json' % n for n in (10,12,13,14,16,17,18,19,20,21,33,34)] + ['eval/translate/article32.glossary-2.llm.json']
seg = T.load_segmented('44/2019/QH14'); seg['doc_id'] = '44/2019/QH14'
acc, ref, _ = R.admit(FILES, seg); m = R.merge(acc)
dom = {}
for kind in ('situation', 'parameters'):
    for a in m['atoms'][kind]:
        d = a['domain']
        dom[a['name']] = [False, True] if d == 'bool' else [x['label'] if isinstance(x, dict) else x for x in (d.get('enum') if isinstance(d, dict) else d)]
def atoms(c, s):
    if isinstance(c, dict):
        for k in ('sit', 'param'):
            if k in c: s.add(c[k])
        for k in ('and', 'or'):
            for x in c.get(k, []): atoms(x, s)
        if 'not' in c: atoms(c['not'], s)
    return s
def ev(c, v):
    if c == 'true' or c is True: return True
    if c == 'false' or c is False: return False
    if 'and' in c: return all(ev(x, v) for x in c['and'])
    if 'or' in c: return any(ev(x, v) for x in c['or'])
    if 'not' in c: return not ev(c['not'], v)
    k = 'sit' if 'sit' in c else 'param'
    return v[c[k]] == c['value'] if 'value' in c else v[c[k]] is True
def applies(n, v): return ev(n['condition'], v) and not any(ev(e, v) for e in n['exceptions'])
def vals(ns):
    A = sorted(set().union(*[atoms(n['condition'], set()) | set().union(set(), *[atoms(e, set()) for e in n['exceptions']]) for n in ns]))
    for combo in itertools.product(*[dom[a] for a in A]):
        yield dict(zip(A, combo))
ns = m['norms']
dead = [n['id'] for n in ns if not any(applies(n, v) for v in vals([n]))]
print('norm chết (không tình huống nào áp dụng):', dead or 'không có')
red = []
for a, b in itertools.permutations(ns, 2):
    if a['act'] == b['act'] and a['modality'] == b['modality']:
        if all(applies(b, v) for v in vals([a, b]) if applies(a, v)):
            red.append((a['id'], b['id']))
eq = {frozenset(p) for p in red if (p[1], p[0]) in red}
print('cặp bao trùm (mọi tình huống norm trái áp dụng thì norm phải cũng áp dụng):', len(red), '| trong đó tương đương hai chiều:', len(eq))
for x, y in red: print('  ', x, '⊆', y, '(tương đương)' if frozenset((x, y)) in eq else '')
# kiểm tra chính bộ đo: một bản sao có điều kiện mạnh hơn phải bị báo là bị bao trùm
n0 = next(n for n in ns if n['act'] == 'ban_ruou_bia' and n['condition'] != 'true')
other = next(n for n in ns if n['act'] == 'ban_ruou_bia' and n is not n0)
cp = dict(n0, id='COPY', condition={'and': [n0['condition'], other['condition']]})
print('tự kiểm:', n0['id'], '| COPY ⊆', n0['id'], ':', all(applies(n0, v) for v in vals([cp, n0]) if applies(cp, v)),
      '| COPY chết?', not any(applies(cp, v) for v in vals([cp])))
from collections import Counter
print('số norm theo (act, modality) có ≥2 norm:', {k: c for k, c in Counter((n['act'], n['modality']) for n in ns).items() if c > 1})
# E8: ngoại lệ không bao giờ kích hoạt (điều kiện chính đã loại trừ nó) và ngoại lệ nuốt hết norm
withexc = [n for n in ns if n['exceptions']]
print('norm có ngoại lệ:', len(withexc))
for n in withexc:
    for i, e in enumerate(n['exceptions']):
        vs = list(vals([n]))
        fires = any(ev(n['condition'], v) and ev(e, v) for v in vs)
        swallows = all(ev(e, v) for v in vs if ev(n['condition'], v))
        print('  ', n['id'], 'ngoại lệ', i, '| có lúc kích hoạt:', fires, '| nuốt hết norm:', swallows)
