# -*- coding: utf-8 -*-
"""Sinh lib/core/utils/drills_library.dart tu new knowledge/Danh-Sach-Bai-Tap-Billiard.md

Nguyen tac:
  * Ten, muc tieu, cac buoc, tieu chi dat  -> lay NGUYEN VAN tu nguon.
  * knowledgeIds -> giai tu cot "Lien ket kien thuc" (Muc N) qua bang dictionaryTopics.
  * levels -> THANG TIEN BO. Cap 1 dung nguong cua nguon; cap tren tang dan ca
    ti le lan co mau. Tran cua cap cao nhat phu thuoc BAN CHAT cu danh:
        A  ~91%  (50/55)  - cu ti le cao: danh thang, tu the, ngam, routine, luat
        B  ~80%  (44/55)  - trung binh: vi tri, safety, english, doc ban
        C  ~60%  (33/55)  - von ti le thap: bank, jump, kick, run-out 7+ bi
    Co mau lon dan vi o 10 lan thu thi 9/10 va 7/10 gan nhu khong phan biet duoc.
  * Bai dinh tinh (nguon khong neu nguong so) -> mot cap, passCount = 0,
    criteriaVi giu nguyen van. KHONG bia so.
"""
import io
import re

BS = chr(92)
NL = chr(10)

SRC_MD = 'new knowledge/Danh-Sach-Bai-Tap-Billiard.md'
OUT = 'lib/core/utils/drills_library.dart'

# ma -> (tenEN, danh muc, do kho, hang tran, thang cap [(attempts, pass, ghichu)])
# Cap 1 = nguong cua nguon. Cap 2/3 do hang tran quyet dinh.
# THANG CO DINH 50 CU, TI LE TANG DAN.
#
# Vi sao 50: o n=10 khong cong nao tach duoc nguoi 80% khoi nguoi 90% — cong
# "9/10" de lot 37,6% nguoi chi dat 80%. Phai ~50 cu ti le moi dang tin.
# Vi sao so cu khong doi: moi buoi tap dai nhu nhau nen so sanh duoc giua cac
# cap; cai tang len la CHAT chu khong phai khoi luong.
#
# Nguong dat DUOI ti le muc tieu de chua bien dong. Kiem bang phan phoi nhi thuc
# (nguoi du suc qua / nguoi kem mot bac lot):
#   A: 27/50 84%/13% | 35/50 84%/10% | 42/50 94%/9%
#   B: 22/50 ...     | 30/50 ...     | 37/50 ...
#   C: 19/50 ...     | 27/50 ...
A = [(50, 27, None), (50, 35, None), (50, 42, None)]   # tran ~90%: danh thang, ngam, tu the, luat
B = [(50, 22, None), (50, 30, None), (50, 37, None)]   # tran ~80%: vi tri, safety, english
# Cu kho (bank/kick/jump/masse): 30 cu thay vi 50 — danh 50 cu nhay bi lien tuc
# la kiem tra the luc chu khong phai ky nang. Gia phai tra: nguoi chua du suc lot
# tang tu 13% len 23%. Cong kem nhay hon nhung van dung huong.
C = [(30, 8, None), (30, 12, None), (30, 16, None)]     # tran ~60%: bank, jump, kick

D = {
    'BT01': ('Grip & Straight Stroke', 'fundamentals', 'beginner', A),
    'BT02': ('Stance & Bridge Consistency', 'fundamentals', 'beginner', A),
    'BT03': ('Ghost Ball by Increasing Angle', 'aiming', 'beginner',
             A),
    'BT04': ('Six Aiming Reference Methods', 'aiming', 'beginner', [(50, 0, None)]),
    'BT05': ('Rail & Mid-table Cut Aiming', 'aiming', 'beginner', A),
    'BT06': ('Controlled Break Shot', 'fundamentals', 'beginner',
             B),
    'BT07': ('Stop - Follow - Draw at Fixed Distance', 'shotmaking', 'intermediate',
             A),
    'BT08': ('Basic English through One Rail', 'shotmaking', 'intermediate',
             B),
    'BT09': ('Three-Ball Position Drill', 'positioning', 'intermediate',
             B),
    'BT10': ('Basic Safety - Screening One Ball', 'strategy', 'intermediate', B),
    'BT11': ('Table Reading & Run-out Planning', 'strategy', 'intermediate', B),
    'BT12': ('Recognising & Compensating Throw', 'shotmaking', 'advanced',
             B),
    'BT13': ('One-Rail Kick Shot', 'shotmaking', 'advanced', C),
    'BT14': ('Bank Shot to Side Pocket', 'shotmaking', 'advanced', C),
    'BT15': ('Basic Jump Shot', 'shotmaking', 'advanced', C),
    'BT16': ('Basic Combination', 'shotmaking', 'advanced',
             B),
    'BT17': ('Speed Control on a 1-10 Scale', 'positioning', 'advanced',
             B),
    'BT18': ('Advanced Run-out Planning (7+ balls)', 'strategy', 'expert',
             C),
    'BT19': ('Probabilistic Active Safety', 'strategy', 'expert',
             C),
    'BT20': ('Pre-shot Routine', 'psychology', 'intermediate', A),
    'BT21': ('8-Ball Practice Game with Calls', 'rules', 'intermediate',
             A),
    'BT22': ('9-Ball / 10-Ball Lowest-Ball Contact', 'rules', 'intermediate',
             A),
    'BT23': ('Short Straight Pool - Break Ball Awareness', 'rules', 'advanced',
             A),
    'BT24': ('Periodic Cue Inspection & Maintenance', 'equipment', 'beginner',
             [(1, 0, 'duy tri 4 tuan')]),
}

CATS = [
    ('fundamentals', 'Fundamentals', 'Nen tang', 'sports_martial_arts'),
    ('aiming', 'Aiming', 'Ngam danh', 'center_focus_strong'),
    ('shotmaking', 'Shot Making', 'Ky thuat cu danh', 'sports_baseball'),
    ('positioning', 'Positioning', 'Kiem soat vi tri', 'my_location'),
    ('strategy', 'Strategy', 'Chien thuat', 'psychology_alt'),
    ('psychology', 'Mental', 'Tam ly', 'self_improvement'),
    ('rules', 'Rules', 'Luat choi', 'gavel'),
    ('equipment', 'Equipment', 'Thiet bi', 'build'),
]

# nhan tieng Viet dung cho UI (khong dau bi mat khi sinh -> dat lai o day)
CAT_VI = {
    'fundamentals': 'Nền tảng',
    'aiming': 'Ngắm đánh',
    'shotmaking': 'Kỹ thuật cú đánh',
    'positioning': 'Kiểm soát vị trí',
    'strategy': 'Chiến thuật',
    'psychology': 'Tâm lý',
    'rules': 'Luật chơi',
    'equipment': 'Thiết bị',
}


# UI bai tap (drill_detail_screen, certification_detail_screen) switch tren
# 'easy'/'medium'/'hard'/'expert'. Kien thuc lai dung 'beginner'/'intermediate'/
# 'advanced'/'expert'. HAI BO TU VUNG song song la no co san cua du an — o day
# phat ra dung bo ma UI bai tap hieu, khong tu y hop nhat.
DIFF = {'beginner': 'easy', 'intermediate': 'medium',
        'advanced': 'hard', 'expert': 'expert'}


def parse_source():
    """Doc thang file .md nguon — khong qua file trung gian nao."""
    d = io.open(SRC_MD, encoding='utf-8').read()
    out = []
    for m in re.finditer(r'^### (BT\d+) — (.+?)$(.*?)(?=^### |^## |\Z)',
                         d, flags=re.M | re.S):
        code, name, body = m.group(1), m.group(2).strip(), m.group(3)

        def field(label):
            mm = re.search(r'\*\*' + label + r':\*\*\s*(.*?)(?=\n\*\*|\n---|\Z)',
                           body, flags=re.S)
            return mm.group(1).strip() if mm else ''

        def bullets(label):
            """Cac dong danh so HOAC gach dau dong duoi mot nhan."""
            items = []
            for line in field(label).split(NL):
                t = line.strip()
                if re.match(r'^(\d+\.|[-*])\s+', t):
                    items.append(re.sub(r'^(\d+\.|[-*])\s+', '', t))
            return items

        out.append(dict(
            code=code,
            name=name,
            links=field('Liên kết kiến thức'),
            goal=field('Mục tiêu'),
            steps=bullets('Cách thực hiện'),
            criteria=field('Tiêu chí đạt'),
            # Nguon CHUA co muc nay. Parser da san sang: chi can them vao .md
            #     **Lỗi thường gặp:**
            #     - ...
            #     - ...
            # roi chay lai script, khong phai sua gi o day.
            mistakes=bullets('Lỗi thường gặp'),
        ))
    if not out:
        raise SystemExit('khong doc duoc bai nao tu %s' % SRC_MD)
    return out


def resolve_knowledge_ids(entries):
    """Giai cot "Muc N" -> id kn_* qua bang dictionaryTopics cua test coverage."""
    t = io.open('test/knowledge_dictionary_coverage_test.dart',
                encoding='utf-8').read()
    m = re.search(r'const dictionaryTopics\s*=\s*<String, String>\{(.*?)\n\};',
                  t, flags=re.S)
    sec2kn = dict(re.findall(r"'§([\d.]+)[^']*':\s*'([^']+)'", m.group(1)))
    for b in entries:
        ids, missing = [], []
        for n in re.findall(r'Mục\s*([\d.]+)', b['links']):
            n = n.rstrip('.')
            if n in sec2kn:
                ids.append(sec2kn[n])
            else:
                missing.append(n)
        if missing:
            raise SystemExit('%s: khong giai duoc Muc %s' % (b['code'], missing))
        b['knowledgeIds'] = ids
    return entries


def esc(s):
    s = s.replace(BS, BS + BS)
    s = s.replace("'", BS + "'")
    s = s.replace('$', BS + '$')
    return re.sub(r'\s+', ' ', s).strip()


def main():
    bt = {b['code']: b for b in resolve_knowledge_ids(parse_source())}
    missing = [c for c in D if c not in bt]
    if missing:
        raise SystemExit('thieu trong nguon: %s' % missing)

    o = []
    o.append('// ===========================================================================')
    o.append('// SINH TU DONG tu `new knowledge/Danh-Sach-Bai-Tap-Billiard.md`')
    o.append('// bang `tools/gen_drills.py`. Sua nguon roi chay lai, dung sua tay file nay.')
    o.append('// ===========================================================================')
    o.append('')
    o.append('/// Thu vien bai tap thuc hanh.')
    o.append('///')
    o.append('/// `levels` la THANG TIEN BO: cap 1 dung dung nguong ghi trong nguon, cap tren')
    o.append('/// tang ca ti le lan co mau. Tran cua cap cao nhat phu thuoc ban chat cu danh —')
    o.append('/// ~91% (50/55) cho cu ti le cao, ~80% cho trung binh, ~60% cho cu von ti le')
    o.append('/// thap nhu bank/jump/kick. Co mau lon dan vi o 10 lan thu thi 9/10 va 7/10')
    o.append('/// gan nhu khong phan biet duoc.')
    o.append('///')
    o.append('/// Bai nao nguon KHONG neu nguong so thi `passCount` = 0 va `criteriaVi` giu')
    o.append('/// nguyen van tieu chi — UI phai uu tien hien `criteriaVi`.')
    o.append('class DrillLibrary {')
    o.append('  static const List<DrillCategory> categories = [')

    for cid, cen, _cvi, icon in CATS:
        members = sorted(c for c in D if D[c][1] == cid)
        if not members:
            continue
        o.append('    DrillCategory(')
        o.append("      id: '%s'," % cid)
        o.append("      name: '%s'," % cen)
        o.append("      nameVi: '%s'," % esc(CAT_VI[cid]))
        o.append("      icon: '%s'," % icon)
        o.append('      drills: [')
        for code in members:
            b = bt[code]
            en, _, diff, levels = D[code]
            o.append('        Drill(')
            o.append("          code: '%s'," % code)
            o.append("          name: '%s'," % esc(en))
            o.append("          nameVi: '%s'," % esc(b['name']))
            o.append("          category: '%s'," % cid)
            o.append("          difficulty: '%s'," % DIFF[diff])
            o.append("          description: '%s'," % esc(b['goal']))
            o.append("          setup: '%s'," % esc(b['steps'][0] if b['steps'] else ''))
            o.append('          steps: [')
            for s in b['steps']:
                o.append("            '%s'," % esc(s))
            o.append('          ],')
            o.append("          goal: '%s'," % esc(b['goal']))
            o.append("          criteriaVi: '%s'," % esc(b['criteria']))
            # Nguon hien CHUA co muc "Loi thuong gap". De rong — khong bia.
            mis = b.get('mistakes') or []
            if mis:
                o.append('          commonMistakes: [')
                for m_ in mis:
                    o.append("            '%s'," % esc(m_))
                o.append('          ],')
            else:
                o.append('          commonMistakes: [],')
            o.append('          levels: [')
            for i, (att, pas, note) in enumerate(levels, 1):
                extra = (", zone: '%s'" % esc(note)) if note else ''
                o.append('            DrillLevel(level: %d, attempts: %d, passCount: %d%s),'
                         % (i, att, pas, extra))
            o.append('          ],')
            o.append('          knowledgeIds: [%s],'
                     % ', '.join("'%s'" % k for k in b['knowledgeIds']))
            o.append('        ),')
        o.append('      ],')
        o.append('    ),')

    o.append('  ];')
    o.append('')
    o.append('  static List<Drill> getAllDrills() =>')
    o.append('      categories.expand((c) => c.drills).toList();')
    o.append('')
    o.append('  static List<Drill> getDrillsByCategory(String categoryId) => categories')
    o.append('      .where((c) => c.id == categoryId)')
    o.append('      .expand((c) => c.drills)')
    o.append('      .toList();')
    o.append('')
    o.append('  static Drill? getDrill(String code) {')
    o.append('    for (final d in getAllDrills()) {')
    o.append('      if (d.code == code) return d;')
    o.append('    }')
    o.append('    return null;')
    o.append('  }')
    o.append('')
    o.append('  /// Bi danh: giu ten cu de cho goi hien co khong gay.')
    o.append('  static Drill? getDrillByCode(String code) => getDrill(code);')
    o.append('')
    o.append('  static List<Drill> getDrillsByDifficulty(String difficulty) =>')
    o.append("      getAllDrills().where((d) => d.difficulty == difficulty).toList();")
    o.append('')
    o.append('  /// Nam bai dau theo thu tu Phan 1 -> Phan 6 cua nguon.')
    o.append('  static List<Drill> getRecommendedDrills() => getAllDrills().take(5).toList();')
    o.append('}')
    o.append('')

    # Ba lop mo hinh doc tu TEMPLATE rieng, khong doc nguoc file output.
    #
    # Ban truoc lay phan duoi cua chinh `OUT` roi va them truong vao — chay lan
    # hai se NHAN DOI `criteriaVi`/`commonMistakes`. Script sinh ma phai
    # idempotent: chay bao nhieu lan cung ra dung mot ket qua.
    tail = io.open('tools/drill_models.dart.tmpl', encoding='utf-8').read()

    io.open(OUT, 'w', encoding='utf-8', newline=NL).write(NL.join(o) + tail)
    print('sinh %d bai / %d danh muc -> %s' % (len(D), len({v[1] for v in D.values()}), OUT))


if __name__ == '__main__':
    main()
