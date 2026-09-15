# -*- coding: utf-8 -*-
"""Áp bảng dịch cho từng file, an toàn UTF-8.

Mỗi phép thay PHẢI khớp đúng số lần mong đợi, nếu không thì dừng và không ghi
gì — tránh sửa nhầm hoặc sửa sót âm thầm. Dùng Python chứ không dùng
PowerShell: `Get-Content -Raw` đọc bằng ANSI và sẽ phá tiếng Việt.

Cách dùng: python tools/apply_vi.py <file_bang_dich.py>
Bảng dịch là một file Python khai báo biến TABLE = {path: [(cu, moi, so_lan)]}
"""
import io
import sys
import importlib.util


def load_table(path):
    spec = importlib.util.spec_from_file_location('table', path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.TABLE


def main():
    table = load_table(sys.argv[1])
    total = 0
    problems = []

    # Vòng 1: kiểm tra tất cả trước khi ghi bất cứ gì.
    staged = {}
    for path, pairs in table.items():
        src = io.open(path, encoding='utf-8').read()
        out = src
        for item in pairs:
            old, new = item[0], item[1]
            want = item[2] if len(item) > 2 else 1
            got = out.count(old)
            if got != want:
                problems.append('%s: "%s" khop %d lan, mong doi %d'
                                % (path, old[:50], got, want))
                continue
            out = out.replace(old, new)
            total += want
        staged[path] = out

    if problems:
        print('DUNG LAI - khong ghi file nao:')
        for p in problems:
            print('  ' + p)
        sys.exit(1)

    for path, out in staged.items():
        io.open(path, 'w', encoding='utf-8', newline='\n').write(out)

    print('Da sua %d chuoi trong %d file' % (total, len(staged)))


if __name__ == '__main__':
    main()
