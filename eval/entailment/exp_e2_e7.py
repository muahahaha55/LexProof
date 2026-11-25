# Experiments E2 (seeded conflicts) and E3 (act subsumption). Scratch only; writes nothing in the repo.
import sys, os, json, re, time
ROOT = r'D:\LexProof'
sys.path.insert(0, os.path.join(ROOT, 'pipeline'))
os.chdir(ROOT)
import run as R, translate as T

OUT = os.path.join(ROOT, 'eval', 'entailment', 'out')   # gitignored
os.makedirs(OUT, exist_ok=True)
DOC = '44/2019/QH14'
FILES = ['eval/translate/article5.glossary-3.llm.json'] + \
        ['eval/translate/article%d.glossary.llm.json' % n for n in (10, 12, 13, 14, 16, 17, 18, 19, 20, 21, 33, 34)] + \
        ['eval/translate/article32.glossary-2.llm.json']

seg = T.load_segmented(DOC); seg['doc_id'] = DOC
acc, ref, info = R.admit(FILES, seg)
assert not ref, ref
merged = R.merge(acc)
base = merged['norms']
print('norms', len(base))

def lean_run(name, norms):
    m = dict(merged, norms=norms)
    p = os.path.join(OUT, name + '.lean')
    open(p, 'w', encoding='utf-8', newline='\n').write(T.to_lean(m, seg))
    t = time.time(); r = R.run_lean(p); dt = time.time() - t
    pairs = R.conflict_pairs(r)
    return r, pairs, dt

NEG = lambda c: {'not': c}
OPP = {'prohibition': 'permission', 'permission': 'prohibition', 'obligation': 'prohibition'}

def mutant(n, tag, **kw):
    return dict(n, id='MUT %s %s' % (tag, n['id']), **kw)

which = sys.argv[1]
res = {}
if which == 'E2':
    by_act = {}
    for n in base: by_act.setdefault(n['act'], []).append(n)
    sample = base[::3]                      # every third norm: 23 norms
    sib = {'ban_ruou_bia': 'cung_cap_ruou_bia', 'cung_cap_ruou_bia': 'ban_ruou_bia',
           'quang_cao_ruou_bia': 'khuyen_mai_ruou_bia', 'uong_ruou_bia': 'xui_giuc_ep_buoc_uong_ruou_bia',
           'kinh_doanh_ruou_bia': 'ban_ruou_bia', 'khuyen_mai_ruou_bia': 'quang_cao_ruou_bia'}
    muts, expect = [], []
    for n in sample:
        o = OPP[n['modality']]
        a = mutant(n, 'M1', modality=o); muts.append(a); expect.append(('M1 đổi modality, cùng act, cùng điều kiện', a['id'], n['id'], True))
        b = mutant(n, 'M4', modality=o, condition=NEG(n['condition'])); muts.append(b)
        expect.append(('M4 đổi modality, điều kiện phủ định', b['id'], n['id'], False))
        if n['act'] in sib:
            c = mutant(n, 'M2', modality=o, act=sib[n['act']]); muts.append(c)
            expect.append(('M2 đổi modality, act gần nghĩa', c['id'], n['id'], None))
    r, pairs, dt = lean_run('E2', base + muts)
    ps = {frozenset(p) for p in pairs}
    rows = {}
    for kind, mid, oid, exp in expect:
        got = frozenset((mid, oid)) in ps
        k = rows.setdefault(kind, [0, 0, 0])
        k[0] += 1; k[1] += got; k[2] += (exp is not None and got != exp)
    print('E2 lean ok', r['ok'], r.get('result'), 'pfindings', r.get('pfindings'), 'pairs', len(pairs), 'secs %.0f' % dt)
    for kind, (tot, got, wrong) in rows.items():
        print('  %-45s ca %3d  bị bắt (cặp với norm gốc) %3d  sai kỳ vọng %d' % (kind, tot, got, wrong))
    if not r['ok']: print(r['stderr'][-2000:], r['stdout'][-1500:])
elif which == 'E3':
    # A ⊑ B: doing A is doing B (AI reading, unreviewed). Prohibition on B is inherited by A.
    EDGES = [('ban_ruou_bia_bang_may_tu_dong', 'ban_ruou_bia', 'gloss: bán bằng máy là một cách bán'),
             ('ban_ruou_bia', 'cung_cap_ruou_bia', 'cung cấp gồm cả bán và cho không (Q3)'),
             ('dung_ruou_bia_lam_qua_khuyen_mai', 'cung_cap_ruou_bia', 'tặng làm quà là cung cấp không lấy tiền'),
             ('tai_tro_bang_san_pham_ruou_bia', 'cung_cap_ruou_bia', 'gloss: hẹp hơn cung_cap_ruou_bia'),
             ('dung_ruou_bia_lam_qua_khuyen_mai', 'khuyen_mai_ruou_bia', 'dùng rượu làm quà là một hình thức khuyến mại'),
             ('ban_ruou_bia', 'kinh_doanh_ruou_bia', 'KÉM CHẮC: bán (mua bán) là một phần của kinh doanh'),
             ('mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho', 'kinh_doanh_ruou_bia', 'KÉM CHẮC: mở điểm bán là kinh doanh'),
             ('su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia', 'su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia', 'gloss: rộng hơn')]
    # transitive closure of edges
    up = {}
    for a, b, _ in EDGES: up.setdefault(a, set()).add(b)
    changed = True
    while changed:
        changed = False
        for a in list(up):
            for b in list(up[a]):
                for c in up.get(b, ()):
                    if c not in up[a]: up[a].add(c); changed = True
    down = {}
    for a, bs in up.items():
        for b in bs: down.setdefault(b, set()).add(a)
    derived = []
    for n in base:
        if n['modality'] == 'prohibition':
            for a in sorted(down.get(n['act'], ())):
                derived.append(dict(n, id='SUY RA (%s ⊑ %s) %s' % (a, n['act'], n['id']), act=a))
    acts_all = {}
    for n in base + derived: acts_all.setdefault(n['act'], set()).add(n['modality'])
    print('E3 cạnh', len(EDGES), 'norm suy ra', len(derived))
    print('  act có >1 modality sau suy ra:', {a: sorted(m) for a, m in acts_all.items() if len(m) > 1})
    perm = [n for n in base if n['modality'] != 'prohibition']
    print('  norm không phải cấm trong bản gộp:', len(perm), sorted({(n['act'], n['modality']) for n in perm if n['modality'] == 'permission'}))
    r, pairs, dt = lean_run('E3', base + derived)
    print('  lean ok', r['ok'], r.get('result'), 'pfindings', r.get('pfindings'), 'pairs', len(pairs), 'secs %.0f' % dt, 'vacuous', r.get('vacuous'))
    for p in pairs: print('   ', p)
    if not r['ok']: print(r['stderr'][-2000:], r['stdout'][-1500:])
if which == 'E3b':
    # «A kéo theo B»: thực hiện A thì phải thực hiện B. Nghĩa vụ A truyền sang B (AI đọc, chưa duyệt).
    ENTAIL = [('thu_hoi_xu_ly_ruou_bia', 'van_chuyen_ruou_bia', 'thu hồi hàng đã bán thì phải chở hàng về'),
              ('thu_hoi_xu_ly_ruou_bia', 'tang_tru_ruou_bia', 'thu hồi rồi mới xử lý thì phải giữ hàng trong lúc chờ')]
    derived = []
    for n in base:
        if n['modality'] == 'obligation':
            for a, b, why in ENTAIL:
                if n['act'] == a:
                    derived.append(dict(n, id='SUY RA (%s kéo theo %s) %s' % (a, b, n['id']), act=b))
    print('E3b norm suy ra', [d['id'] for d in derived])
    r, pairs, dt = lean_run('E3b', base + derived)
    print('  lean ok', r['ok'], r.get('result'), 'pfindings', r.get('pfindings'), 'pairs', len(pairs), 'secs %.0f' % dt)
    for p in pairs: print('   ', p)
    i = r['stdout'].find('KẾT QUẢ'); print(r['stdout'][i:i+1800])

# ---- E4: đồ thị «A kéo theo B» cho cả bảng act (AI đề xuất, chưa duyệt) + duyệt theo nhu cầu ----
EDGES = [  # (A, B, độ chắc của AI, lý do)
 ('ban_ruou_bia_bang_may_tu_dong', 'ban_ruou_bia', 'cao', 'bán bằng máy là một cách bán'),
 ('ban_ruou_bia', 'cung_cap_ruou_bia', 'cao', 'cung cấp gồm cả bán lẫn cho không (gloss, Q3)'),
 ('dung_ruou_bia_lam_qua_khuyen_mai', 'cung_cap_ruou_bia', 'cao', 'tặng làm quà là cung cấp không lấy tiền'),
 ('dung_ruou_bia_lam_qua_khuyen_mai', 'khuyen_mai_ruou_bia', 'TB', 'dùng rượu làm quà là một hình thức khuyến mại'),
 ('tai_tro_bang_san_pham_ruou_bia', 'cung_cap_ruou_bia', 'cao', 'gloss: hẹp hơn cung_cap_ruou_bia'),
 ('ban_ruou_bia', 'kinh_doanh_ruou_bia', 'thấp', 'bán có thể không phải kinh doanh (bán một lần)'),
 ('mo_moi_diem_ban_ruou_bia_tieu_dung_tai_cho', 'kinh_doanh_ruou_bia', 'TB', 'mở điểm bán là hoạt động kinh doanh'),
 ('su_dung_lao_dong_truc_tiep_san_xuat_mua_ban_ruou_bia', 'su_dung_lao_dong_truc_tiep_kinh_doanh_quang_cao_ruou_bia', 'cao', 'gloss: rộng hơn'),
 ('thu_hoi_xu_ly_ruou_bia', 'van_chuyen_ruou_bia', 'TB', 'thu hồi hàng đã bán thì phải chở hàng về'),
 ('thu_hoi_xu_ly_ruou_bia', 'tang_tru_ruou_bia', 'TB', 'giữ hàng trong lúc chờ xử lý'),
 ('nhap_lau_ruou_bia', 'van_chuyen_ruou_bia', 'TB', 'nhập lậu là đưa hàng qua biên giới'),
 ('san_xuat_ruou_thu_cong', 'su_dung_nguyen_lieu_san_xuat_pha_che_ruou_bia', 'cao', 'sản xuất thì dùng nguyên liệu'),
 ('kinh_doanh_ruou_bia', 'tang_tru_ruou_bia', 'thấp', 'kinh doanh thường kèm giữ hàng'),
 ('yeu_cau_nguoi_mua_xuat_trinh_giay_to_chung_minh_tuoi', 'ban_ruou_bia', 'thấp (cố ý sai)', 'ĐỐI CHỨNG: cạnh sai có chủ ý, để xem duyệt theo nhu cầu có bắt được không'),
]

def closure(edges):
    paths = {}  # (A, B) -> shortest list of edges
    for e in edges: paths[(e[0], e[1])] = [e]
    changed = True
    while changed:
        changed = False
        for (a, b), p in list(paths.items()):
            for (c, d), q in list(paths.items()):
                if b == c and a != d and (a, d) not in paths:
                    paths[(a, d)] = p + q; changed = True
    return paths

def derive(norms, edges):
    paths, out = closure(edges), []
    for n in norms:
        for (a, b), p in paths.items():
            lab = ' → '.join([p[0][0]] + [e[1] for e in p])
            if n['modality'] == 'prohibition' and n['act'] == b:      # cấm B ⇒ cấm A
                out.append((dict(n, id='SUY RA [%s] %s' % (lab, n['id']), act=a), p))
            if n['modality'] == 'obligation' and n['act'] == a:       # bắt buộc A ⇒ bắt buộc B
                out.append((dict(n, id='SUY RA [%s] %s' % (lab, n['id']), act=b), p))
    return out

if which == 'E4':
    der = derive(base, EDGES)
    path_of = {d['id']: p for d, p in der}
    r, pairs, dt = lean_run('E4', base + [d for d, _ in der])
    print('E4 cạnh', len(EDGES), 'norm suy ra', len(der), '| lean', r['ok'], r.get('result'), 'pairs', len(pairs), 'secs %.0f' % dt)
    need = {}
    for l, rr in pairs:
        print('   ', l, '×', rr)
        for x in (l, rr):
            for e in path_of.get(x, []): need[(e[0], e[1])] = e
    print('  cạnh phải duyệt (nằm trên đường xung đột):', len(need), 'trên', len(EDGES))
    for e in need.values(): print('    ', e[0], '⇒', e[1], '|', e[2], '|', e[3])
    if not r['ok']: print(r['stderr'][-1500:], r['stdout'][-1500:])

if which == 'E5':
    # E2 lặp lại với đồ thị: các bản sửa M2 có bị bắt không, M4 có báo nhầm không
    sib = {'ban_ruou_bia': 'cung_cap_ruou_bia', 'cung_cap_ruou_bia': 'ban_ruou_bia',
           'quang_cao_ruou_bia': 'khuyen_mai_ruou_bia', 'uong_ruou_bia': 'xui_giuc_ep_buoc_uong_ruou_bia',
           'kinh_doanh_ruou_bia': 'ban_ruou_bia', 'khuyen_mai_ruou_bia': 'quang_cao_ruou_bia'}
    good = [e for e in EDGES if not e[2].startswith('thấp (cố ý')]
    paths = closure(good)
    muts, expect = [], []
    for n in base[::3]:
        o = OPP[n['modality']]
        b = mutant(n, 'M4', modality=o, condition=NEG(n['condition'])); muts.append(b); expect.append(('M4', b, n))
        if n['act'] in sib:
            c = mutant(n, 'M2', modality=o, act=sib[n['act']]); muts.append(c); expect.append(('M2', c, n))
    for mode, edges in (('không cạnh', []), ('có cạnh', good)):
        der = [d for d, _ in derive(base + muts, edges)]
        r, pairs, dt = lean_run('E5', base + muts + der)
        hit = lambda mid: any(mid in p[0] or mid in p[1] for p in pairs)
        rows = {}
        for k, m, n in expect:
            # «nên bắt» theo định nghĩa kéo theo: bản sửa (cho phép/bắt buộc trên X) gặp lệnh cấm trên Y với X ⇒* Y, hoặc ngược lại
            if k == 'M2':
                x, y = m['act'], n['act']
                should = (m['modality'] != 'prohibition' and n['modality'] == 'prohibition' and (x, y) in paths) or \
                         (m['modality'] == 'prohibition' and n['modality'] != 'prohibition' and (y, x) in paths)
                key = 'M2 nên bắt' if should else 'M2 không phải xung đột theo định nghĩa'
            else:
                key = 'M4'
            s = rows.setdefault(key, [0, 0]); s[0] += 1
            def fam(x, i):   # x là norm i hoặc một norm suy ra trực tiếp từ i
                return x == i or (x.startswith('SUY RA [') and x.endswith('] ' + i))
            s[1] += any((fam(p[0], m['id']) and fam(p[1], n['id'])) or (fam(p[1], m['id']) and fam(p[0], n['id'])) for p in pairs)
        print('E5', mode, '| pairs', len(pairs), '|', {k: '%d/%d bị bắt' % (v[1], v[0]) for k, v in rows.items()})

if which == 'E7':
    # Độ bền của ứng viên Điều 32 khoản 4 × Điều 5 khoản 12 theo cách đọc. Chỉ dùng 2 cạnh thu hồi (không cạnh đối chứng).
    TH = [e for e in EDGES if e[0] == 'thu_hoi_xu_ly_ruou_bia']
    K = {'name': 'nham_muc_dich_kinh_doanh', 'source': 'Điều 5 khoản 12', 'domain': 'bool'}
    T_ = {'name': 'dang_thuc_hien_thu_hoi_theo_dieu_32_khoan_4', 'source': 'Điều 32 khoản 4', 'domain': 'bool'}
    def variant(r):
        ns = json.loads(json.dumps(base)); extra = []
        for n in ns:
            if n['id'] in ('Điều 5:5.12.i.b', 'Điều 5:5.12.i.c'):
                if r == 'R1': n['condition'] = {'and': [n['condition'], {'sit': K['name']}]}
                if r == 'R2': n['exceptions'] = n['exceptions'] + [{'sit': T_['name']}]
        der = [d for d, _ in derive(ns, TH) if d['modality'] == 'obligation']   # chỉ chiều nghĩa vụ, khỏi đếm đôi
        for d in der:
            if r == 'R1': d['condition'] = {'and': [d['condition'], {'not': {'sit': K['name']}}]}
            if r == 'R2': d['condition'] = {'and': [d['condition'], {'sit': T_['name']}]}
        return ns + der, ([K] if r == 'R1' else [T_] if r == 'R2' else [])
    READ = {'R0': 'chữ luật như đã dịch: cấm tàng trữ, vận chuyển trong mọi trường hợp',
            'R1': 'cấm ở Điều 5 khoản 12 chỉ nhắm việc nhằm mục đích kinh doanh; thu hồi không nhằm kinh doanh',
            'R2': 'Điều 5 khoản 12 có ngoại lệ ngầm cho việc thu hồi theo Điều 32 khoản 4 (luật riêng thắng)'}
    for r, why in READ.items():
        ns, atoms = variant(r)
        saved = merged['atoms']['situation']
        merged['atoms']['situation'] = saved + atoms
        res, pairs, dt = lean_run('E7' + r, ns)
        merged['atoms']['situation'] = saved
        print(r, '|', why, '| lean', res['ok'], res.get('result'), '| cặp', len(pairs))
        for p in pairs: print('     ', p)
        if not res['ok']: print(res['stderr'][-800:], res['stdout'][-800:])
