# -*- coding: utf-8 -*-
"""Đo tỉ lệ tương phản WCAG cho các cặp token thật sự được dùng cạnh nhau.

Đọc `lib/core/theme/colors.dart`, dựng bảng hằng, rồi giải từng accessor
`foo(brightness)` thành cặp (bản sáng, bản tối). Sau đó chấm các cặp
chữ-trên-nền theo cả hai chế độ.

Ngưỡng WCAG 2.1 AA: 4.5 cho chữ thường, 3.0 cho chữ lớn (>=18.66px đậm hoặc
>=24px) và cho icon/đường viền mang nghĩa.
"""
import io
import re
import sys

SRC = 'lib/core/theme/colors.dart'


def load_tokens():
    s = io.open(SRC, encoding='utf-8').read()
    consts = {}
    for m in re.finditer(
        r'static const Color (\w+) = Color\(0x([0-9A-Fa-f]{8})\)', s
    ):
        consts[m.group(1)] = int(m.group(2), 16)

    # accessor: static Color foo(Brightness b) => cond ? A : B;
    acc = {}
    for m in re.finditer(
        r'static Color (\w+)\(Brightness \w+\) =>\s*(.*?);', s, re.S
    ):
        name, body = m.group(1), m.group(2)
        names = re.findall(r'\b([a-zA-Z]\w*)\b', body)
        picks = [n for n in names if n in consts]
        if len(picks) >= 2:
            acc[name] = (picks[0], picks[1])  # (light, dark)
    return consts, acc


def srgb_to_lin(c):
    c = c / 255.0
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def luminance(argb):
    r = (argb >> 16) & 0xFF
    g = (argb >> 8) & 0xFF
    b = argb & 0xFF
    return (
        0.2126 * srgb_to_lin(r)
        + 0.7152 * srgb_to_lin(g)
        + 0.0722 * srgb_to_lin(b)
    )


def contrast(a, b):
    la, lb = luminance(a), luminance(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)


# (chữ, nền, ngưỡng, mô tả)
PAIRS = [
    ('textPrimary', 'background', 4.5, 'chữ chính trên nền'),
    ('textPrimary', 'surface', 4.5, 'chữ chính trên thẻ'),
    ('textPrimary', 'surfaceElevated', 4.5, 'chữ chính trên thẻ nổi'),
    ('textPrimary', 'surfaceRecessed', 4.5, 'chữ chính trên nền lõm'),
    ('textSecondary', 'background', 4.5, 'chữ phụ trên nền'),
    ('textSecondary', 'surface', 4.5, 'chữ phụ trên thẻ'),
    ('textTertiary', 'background', 4.5, 'chữ mờ trên nền'),
    ('textTertiary', 'surface', 4.5, 'chữ mờ trên thẻ'),
    ('onPrimary', 'primary', 4.5, 'chữ trên nút chính'),
    ('onPrimary', 'primaryDeep', 4.5, 'chữ trên nút chính đậm'),
    ('successOnTint', 'successSubtle', 4.5, 'chữ trên nền dịu success'),
    ('warningOnTint', 'warningSubtle', 4.5, 'chữ trên nền dịu warning'),
    ('errorOnTint', 'errorSubtle', 4.5, 'chữ trên nền dịu error'),
    ('accentLabel', 'background', 4.5, 'nhãn nhấn trên nền'),
    ('accentLabel', 'surface', 4.5, 'nhãn nhấn trên thẻ'),
    ('primary', 'background', 3.0, 'icon/viền primary trên nền'),
    ('primary', 'surface', 3.0, 'icon/viền primary trên thẻ'),
    ('border', 'background', 3.0, 'viền trên nền'),
    ('border', 'surface', 3.0, 'viền trên thẻ'),
]


def main():
    consts, acc = load_tokens()
    problems = []

    print('%-46s %7s %7s' % ('cặp', 'sáng', 'tối'))
    print('-' * 62)
    for fg, bg, need, desc in PAIRS:
        if fg not in acc or bg not in acc:
            print('%-46s  (thiếu accessor: %s / %s)' % (desc, fg, bg))
            continue
        row = []
        for i, mode in enumerate(('sáng', 'tối')):
            f = consts[acc[fg][i]]
            b = consts[acc[bg][i]]
            r = contrast(f, b)
            row.append(r)
            if r < need:
                problems.append(
                    '%s (%s): %.2f < %.1f  [%s trên %s]'
                    % (desc, mode, r, need, acc[fg][i], acc[bg][i])
                )
        flag = '' if all(r >= need for r in row) else '  <-- DUOI NGUONG'
        print('%-46s %7.2f %7.2f%s' % (desc, row[0], row[1], flag))

    print()
    if problems:
        print('KHONG DAT (%d):' % len(problems))
        for p in problems:
            print('  ' + p)
        sys.exit(1)
    print('Tat ca cap deu dat nguong.')


if __name__ == '__main__':
    main()
