# -*- coding: utf-8 -*-
"""Phân loại chuỗi giao diện không dấu thành các nhóm cần xử lý khác nhau."""
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

SLOTS = re.compile(
    r"(?:Text\(\s*|label:\s*|labelText:\s*|hintText:\s*|tooltip:\s*|"
    r"helperText:\s*|semanticLabel:\s*)'((?:[^'\\]|\\.){3,140})'"
)
SKIP = re.compile(r"^(/|\$|[A-Z]{2}\d|[\d\s.,:%/-]+$|[a-z_]+\.[a-z]+$|[a-z_]+$)")

# Tiếng Việt viết không dấu: có các cụm âm tiết đặc trưng.
VI_NO_TONE_WORDS = set("""
bao cao tuan thang chua co tran dau nay hay ghi them trong de thay chi tiet
du lieu xem ma khong ton tai bai tap voi cac ban da lam duoc va nhieu it
nguoi choi luyen ky nang muc do tot hon rat hon kem diem so lan phut giay
cu danh vao lo bi cai muc tieu tap trung nghi giai lao ket qua tong ket
mo dau giua cuoi truoc sau khi bat dau ket thuc tiep theo quay lai
""".split())

# Thuật ngữ bi-a / tên riêng — thường giữ nguyên tiếng Anh.
TERMS = re.compile(
    r'\b(8-?Ball|9-?Ball|10-?Ball|Straight Pool|Snooker|Carom|Break|Safety|'
    r'Stop|Follow|Draw|English|Masse|Jump|Bank|Kick|Combination|Run-?out|'
    r'Rack|Shot|Cue|PoolOS|AI Coach|Black Box|Ghost Ball|Throw|Diamond)\b',
    re.I,
)


def classify(s):
    words = re.findall(r'[A-Za-z]+', s.lower())
    if not words:
        return 'khac'
    vi_hits = sum(1 for w in words if w in VI_NO_TONE_WORDS)
    if vi_hits >= max(2, len(words) * 0.4):
        return 'viet_khong_dau'
    if TERMS.search(s) and len(words) <= 4:
        return 'thuat_ngu'
    return 'tieng_anh'


def main():
    root_dir = sys.argv[1] if len(sys.argv) > 1 else 'lib'
    buckets = collections.defaultdict(list)

    for root, dirs, files in os.walk(root_dir):
        for fn in files:
            if not fn.endswith('.dart'):
                continue
            p = os.path.join(root, fn).replace(os.sep, '/')
            src = io.open(p, encoding='utf-8').read()
            for m in SLOTS.finditer(src):
                s = m.group(1)
                if SKIP.match(s) or len(s.strip()) < 3 or VN.search(s):
                    continue
                buckets[classify(s)].append((p, s))

    for name in ('tieng_anh', 'viet_khong_dau', 'thuat_ngu', 'khac'):
        items = buckets[name]
        beta = sum(1 for p, _ in items if '/beta/' in p)
        print('== %s: %d chuoi (trong do %d o lib/beta) ==' % (name, len(items), beta))
        seen = set()
        for p, s in items:
            if s in seen:
                continue
            seen.add(s)
            if len(seen) > 18:
                print('   ... va %d chuoi khac' % (len(items) - 18))
                break
            print('   "%s"   <- %s' % (s, p.split('/')[-1]))
        print('')


if __name__ == '__main__':
    main()
