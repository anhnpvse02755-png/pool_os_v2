# -*- coding: utf-8 -*-
"""Chuyển một file widget sang hệ token theo brightness.

Chỉ làm những phép thay 1-1 an toàn (tên token -> accessor), và CHÈN
`final brightness = ...` vào đầu mỗi `build`. Không đụng tới cấu trúc điều
kiện — lần trước sửa hàng loạt kiểu đó đã sinh ternary lồng nhau vô nghĩa.

Sau khi chạy PHẢI đọc diff và chạy analyze; script này không tự tin là đúng.

Dùng: python tools/migrate_theme_tokens.py <file...>
"""
import io
import re
import sys

# AppTheme.* là alias `static const Color` trỏ thẳng vào hằng AppColors —
# chúng không bao giờ nhận được Brightness.
MAP = {
    'AppTheme.primaryGreen': 'AppColors.primary(brightness)',
    'AppTheme.primary': 'AppColors.primary(brightness)',
    'AppTheme.primaryDark': 'AppColors.primaryDeep(brightness)',
    'AppTheme.accentGold': 'AppColors.gold',
    'AppTheme.textPrimary': 'AppColors.textPrimary(brightness)',
    'AppTheme.textSecondary': 'AppColors.textSecondary(brightness)',
    'AppTheme.surfaceLight': 'AppColors.background(brightness)',
    'AppTheme.surfaceDark': 'AppColors.background(brightness)',
    'AppTheme.error': 'AppColors.error',
    'AppTheme.success': 'AppColors.success',
    # Chữ/icon đặt TRÊN nền primary.
    'Colors.white': 'AppColors.onPrimary(brightness)',
    'Colors.red': 'AppColors.error',
    'Colors.green': 'AppColors.success',
    'Colors.orange': 'AppColors.warning',
    'Colors.grey': 'AppColors.textTertiary(brightness)',
}

BUILD = re.compile(
    r'(Widget build\(BuildContext context(?:, WidgetRef ref)?\) \{\n)'
)


def migrate(path):
    s = io.open(path, encoding='utf-8').read()
    orig = s

    for a, b in MAP.items():
        # `\b` tránh `Colors.grey` nuốt mất `Colors.grey700`.
        s = re.sub(re.escape(a) + r'(?![\w\[])', b, s)

    if 'brightness' in s and 'final brightness' not in s:
        s = BUILD.sub(
            r'\1    final brightness = Theme.of(context).brightness;\n\n', s)

    # `const` không sống nổi khi giá trị thành lời gọi phương thức.
    for _ in range(6):
        s2 = re.sub(
            r'const (\w+\((?:[^()]|\([^()]*\))*?AppColors\.\w+\(brightness\))',
            r'\1', s)
        if s2 == s:
            break
        s = s2

    if 'AppTheme.' not in s:
        s = re.sub(r"import '[^']*app_theme\.dart';\n", '', s)
    if 'AppColors.' in s and 'theme/colors.dart' not in s:
        m = re.search(r"^import 'package:flutter/material\.dart';\n", s, re.M)
        # lib/presentation/widgets/coach/x.dart -> 3 cap len toi lib/
        depth = path.count('/') - 1
        rel = '../' * depth + 'core/theme/colors.dart'
        if m:
            s = s[:m.end()] + "\nimport '%s';\n" % rel + s[m.end():]

    if s != orig:
        io.open(path, 'w', encoding='utf-8', newline='\n').write(s)
        return True
    return False


def main():
    for p in sys.argv[1:]:
        print(('da sua  ' if migrate(p) else 'khong doi') + '  ' + p)


if __name__ == '__main__':
    main()
