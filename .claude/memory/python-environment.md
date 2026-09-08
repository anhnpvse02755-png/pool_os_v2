---
name: python-environment
description: Python 3.13 install location, why the Store stub caused "Python was not found", and which skills need it
metadata:
  type: reference
---

**Cài ngày 28/8/2026** để chạy 35 script `.py` trong `.claude/skills/`.

## Cạm bẫy: "Python was not found"

Trước khi cài, `python` và `python3` trên PATH trỏ tới:
```
C:\Users\anhnpv\AppData\Local\Microsoft\WindowsApps\python
```
Đây là **App Execution Alias stub** của Microsoft Store — file rỗng, chạy là in:
> *Python was not found; run without arguments to install from the Microsoft Store...*

Nên `which python` **có** trả về đường dẫn, nhưng Python vẫn chưa cài. Đừng tin mỗi `which`, phải chạy `python --version`.

## Trạng thái hiện tại

| Mục | Giá trị |
|---|---|
| Version | Python 3.13.15 |
| Đường dẫn | `C:\Users\anhnpv\AppData\Local\Programs\Python\Python313\python.exe` |
| Cài bằng | `winget install -e --id Python.Python.3.13 --scope user` |
| PATH | `Python313\` và `Python313\Scripts\` đứng **trước** `WindowsApps` → stub bị che ✅ |

**Packages:** `pillow` (import `PIL`), `google-genai` (import `from google import genai`), `pytest` + `pytest-cov` + `pytest-mock`.

## Lưu ý về session

PATH mới chỉ có hiệu lực ở **process mới**. Session Claude Code đang chạy lúc cài vẫn giữ PATH cũ và vẫn thấy stub. Cách chạy trong session cũ:
```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
```
Hoặc gọi thẳng đường dẫn tuyệt đối. Session mở sau khi cài thì `python` trần chạy bình thường.

## Ai cần Python

Chỉ các skill design: ui-ux-pro-max (15 script), design (8), design-system (7), ui-styling (4), brand (1). **Project Flutter không dùng Python** — không có `.py` nào trong `lib/`, `scripts/`, `tools/`, `.github/`.

`ui-ux-pro-max/scripts/search.py` có `--stack flutter`, dùng được trực tiếp cho project này. Xem [[design-system-tokens]], [[user-project-context]].

**Why:** Stub Store làm triệu chứng gây hiểu nhầm — trông như lỗi PATH trong khi thực ra chưa cài gì cả.

**How to apply:** Nếu lại thấy "Python was not found", kiểm tra `python --version` chứ đừng chỉ `which python`.
