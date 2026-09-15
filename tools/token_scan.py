# -*- coding: utf-8 -*-
"""Chạy 10 luật vệ sinh token của `test/screens/token_hygiene.dart` lên MỌI file.

Mục đích: tìm màn nào chưa được quét sang hệ token mới, thay vì đoán theo
danh sách lô. Chỉ báo cáo, không sửa.
"""
import io
import os
import re
import sys
import collections

RULES = [
    ('AppColors.light*', re.compile(r'AppColors\.light[A-Z]\w*')),
    ('AppColors.dark*', re.compile(r'AppColors\.dark[A-Z]\w*')),
    ('nền dịu Light/Dark', re.compile(r'AppColors\.\w*Subtle(Light|Dark)\b')),
    ('emoji làm icon',
     re.compile(r'[\U0001F300-\U0001F9FF☀-➿]')),
    ('Colors.* của Material',
     re.compile(r'(?<!App)\bColors\.(?!transparent)\w+')),
    ('token accent xanh điện',
     re.compile(r'AppColors\.accent(Color|Subtle|Light|Dark)?\b')),
    ('hằng màu thô', re.compile(r'Color\(0x[0-9A-Fa-f]{8}\)')),
    ('token hậu tố Light/Dark',
     re.compile(r'AppColors\.(?!light|dark)[a-z]\w*(Light|Dark)\b')),
    ('màu alias của AppTheme', re.compile(r'AppTheme\.[a-z]\w*')),
]


def main():
    roots = sys.argv[1:] or ['lib/presentation', 'lib/beta']
    per_file = collections.defaultdict(lambda: collections.Counter())
    rule_totals = collections.Counter()

    for root in roots:
        for d, _, files in os.walk(root):
            for fn in files:
                if not fn.endswith('.dart'):
                    continue
                p = os.path.join(d, fn).replace(os.sep, '/')
                src = io.open(p, encoding='utf-8').read()
                for name, pat in RULES:
                    hits = pat.findall(src)
                    if hits:
                        per_file[p][name] = len(hits)
                        rule_totals[name] += len(hits)

    print('FILE VI PHAM: %d' % len(per_file))
    print()
    print('Theo luat:')
    for name, n in rule_totals.most_common():
        print('  %-28s %4d' % (name, n))
    print()
    print('Theo file (nhieu nhat truoc):')
    ranked = sorted(per_file.items(), key=lambda kv: -sum(kv[1].values()))
    for p, c in ranked:
        print('  %4d  %-62s %s'
              % (sum(c.values()), p.replace('lib/presentation/screens/', ''),
                 ', '.join('%s=%d' % (k, v) for k, v in c.most_common())))


if __name__ == '__main__':
    main()
