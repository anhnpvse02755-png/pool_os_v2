# -*- coding: utf-8 -*-
"""Quét chuỗi hiển thị trong lib/ và phân loại tiếng Việt / không dấu.

Dùng để ước lượng khối lượng việt hoá giao diện. Không sửa gì, chỉ báo cáo.
"""
import re
import io
import os
import sys
import collections

VN = re.compile(
    u'[à-ãè-êìíò-õùúý'
    u'ăđĩũơưẠ-ỹ'
    u'À-ÃÈ-ÊÌÍÒ-ÕÙÚÝ'
    u'ĂĐĨŨƠƯ]'
)

# Những vị trí mà chuỗi thực sự hiện ra màn hình.
SLOTS = re.compile(
    r"(?:Text\(\s*|label:\s*|labelText:\s*|hintText:\s*|tooltip:\s*|"
    r"helperText:\s*|semanticLabel:\s*)'((?:[^'\\]|\\.){3,140})'"
)

# Loại trừ: route, mã bài, khoá kỹ thuật, số, tên file.
SKIP = re.compile(r"^(/|\$|[A-Z]{2}\d|[\d\s.,:%/-]+$|[a-z_]+\.[a-z]+$|[a-z_]+$)")


def main():
    root_dir = sys.argv[1] if len(sys.argv) > 1 else 'lib'
    per_file = collections.Counter()
    samples = collections.defaultdict(list)
    all_hits = []
    total_vn = 0

    for root, dirs, files in os.walk(root_dir):
        for fn in files:
            if not fn.endswith('.dart'):
                continue
            p = os.path.join(root, fn).replace(os.sep, '/')
            src = io.open(p, encoding='utf-8').read()
            for m in SLOTS.finditer(src):
                s = m.group(1)
                if SKIP.match(s) or len(s.strip()) < 3:
                    continue
                if VN.search(s):
                    total_vn += 1
                else:
                    per_file[p] += 1
                    all_hits.append((p, s))
                    if len(samples[p]) < 3:
                        samples[p].append(s)

    print('Co dau tieng Viet: %d | Khong dau (nghi tieng Anh): %d'
          % (total_vn, len(all_hits)))
    print('So file dinh: %d\n' % len(per_file))
    print('TOP 30 FILE:')
    for p, c in per_file.most_common(30):
        print('%4d  %s' % (c, p))
        for s in samples[p]:
            print('        "%s"' % s)


if __name__ == '__main__':
    main()
