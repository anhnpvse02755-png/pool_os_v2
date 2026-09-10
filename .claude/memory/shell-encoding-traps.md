---
name: shell-encoding-traps
description: flutter không có trên PATH, và PowerShell 5.1 làm hỏng UTF-8 tiếng Việt khi patch file
metadata:
  type: project
---

**`flutter` KHÔNG có trên PATH.** Mọi lệnh phải prefix:

```powershell
$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test
```

SDK nằm ở `C:\Users\anhnpv\flutter` — xem [[user-project-context]].

**PowerShell 5.1 `Get-Content -Raw` đọc file bằng ANSI, không phải UTF-8.**
Dùng nó để patch file có tiếng Việt (ví dụ script mutation testing sửa rồi
khôi phục source) sẽ biến `Một người chơi` thành `Má»™t ngÆ°á»i chÆ¡i` — hỏng
vĩnh viễn nếu file chưa được commit.

**Why:** Session 10/9/2026 mất một vòng sửa vì script mutation testing làm
hỏng encoding của `score_bar.dart` và `bottom_action_bar.dart` khi hai file
còn untracked, phải gõ tay lại toàn bộ nội dung.

**How to apply:** Mutation testing trên file có tiếng Việt thì sửa bằng tool
Edit (sửa → chạy test → sửa ngược lại), hoặc commit file trước rồi
`git checkout -- <file>` để khôi phục. Không dùng vòng lặp
`Get-Content` / `Set-Content`. Cùng họ với [[design-system-tokens]] — đều là
bẫy lặp lại giữa các session.
