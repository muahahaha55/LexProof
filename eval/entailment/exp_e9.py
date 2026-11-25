# E9: «dịch vòng» dạng tất định (proxy): tìm cụm điều kiện trong chữ luật mà norm không phủ.
# Không phải roundtrip thật (cần một bộ dịch lại không thấy bản dịch gốc). KHÔNG tin cậy.
import sys, os, json, re
sys.path.insert(0, r'D:\LexProof\pipeline'); os.chdir(r'D:\LexProof')
seg = json.load(open('data/segmented/44-2019-QH14.json', encoding='utf-8'))
G = json.load(open('data/glossary/44-2019-QH14.json', encoding='utf-8'))
gl = {e['id']: e['gloss'] for e in G['acts'] + G['atoms']}
unit = {}
for a in seg['articles']:
    t = [a['lead_in']['text']] if a.get('lead_in') else []
    unit[a['id']] = ' '.join(t + [c['text'] for c in a['clauses']] + [p['text'] for c in a['clauses'] for p in c['points']])
    for c in a['clauses']:
        unit[c['id']] = ' '.join([c['text']] + [p['text'] for p in c['points']])
        for p in c['points']: unit[p['id']] = p['text']
norm_ = lambda s: re.sub(r'\s+', ' ', s.lower())
STOP = set('và của các cho với trong khi để được không có là một những đối việc người thì theo về này đó tại hoặc từ'.split())
MARK = r'(sau khi|trước khi|trong khi|ngay trước|trong thời gian|trừ|nếu|khi|đối với|dưới|chưa đủ|từ \S+ (?:độ|tuổi)[^,;.]* trở lên|dành cho)'
def words(s): return [w for w in re.findall(r'\w+', norm_(s)) if w not in STOP and not w.isdigit()]
def cond_atoms(c, out):
    if isinstance(c, dict):
        for k in ('sit', 'param'):
            if k in c: out.add(c[k])
        if 'value' in c: out.add('VAL:' + c['value'])
        for k in ('and', 'or'):
            for x in c.get(k, []): cond_atoms(x, out)
        if 'not' in c: cond_atoms(c['not'], out)
    return out
def check(path):
    d = json.load(open(path, encoding='utf-8'))
    flags = []
    for n in d['norms']:
        src = re.sub(r' nhánh.*$', '', n['source'])
        text = norm_(unit.get(src, ''))
        ids = cond_atoms(n['condition'], set())
        for e in n['exceptions']: cond_atoms(e, ids)
        bag = set(words(' '.join((i[4:] if i.startswith('VAL:') else gl.get(i, i.replace('_', ' '))) for i in ids | {n['act']})))
        # chỉ xét đoạn chữ thuộc về nhánh: nếu có nhánh, lấy câu chứa quote nối với phần đuôi chung của khoản
        qw = set(words(n['quote']))
        segs = [x for x in re.split(r'[;:]|\.\s', text) if x.strip()]
        for si, sg in enumerate(segs):
            sw = words(sg)
            own = bool(sw) and sum(w in qw for w in sw) / len(sw) >= 0.5
            last = si == len(segs) - 1
            for m in re.finditer(MARK + r'([^,;.:]{0,60})', sg):
                phrase = m.group(0); ws = words(phrase)
                if len(ws) < 2: continue
                trailing = sg.rstrip(' .').endswith(phrase.rstrip(' .'))
                if not own and not (last and trailing): continue
                cov = sum(w in bag for w in ws) / len(ws)
                if cov < 0.5:
                    flags.append((n['id'], 'THIẾU' if own else 'PHẠM VI MƠ HỒ', phrase.strip(), round(cov, 2)))
    return d, flags
for f in sys.argv[1:]:
    d, fl = check(f)
    print('==', f, '| norm', len(d['norms']), '| cờ', len(fl), '| norm bị cờ', len({x[0] for x in fl}))
    for x in fl: print('   ', x)
