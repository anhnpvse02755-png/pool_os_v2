---
name: claude-mem-auth-trap
description: claude-mem tước ANTHROPIC_* khỏi env và chỉ đọc từ ~/.claude-mem/.env — máy này đăng nhập qua proxy ocd nên phải tạo file đó
metadata:
  type: reference
---

Máy này **không dùng OAuth/keychain**. Claude Code đi qua **proxy ocd cục bộ**:

```
ANTHROPIC_BASE_URL=http://127.0.0.1:4141
ANTHROPIC_API_KEY=ocd-local
```

(`ocd.exe` nằm ở gốc repo; Windows Credential Manager **rỗng, 0 mục**.)

## Cái bẫy

Worker của claude-mem **cố ý tước** `ANTHROPIC_API_KEY`, `ANTHROPIC_AUTH_TOKEN`,
`ANTHROPIC_BASE_URL` khỏi `process.env` mà nó kế thừa (blocklist `URe` trong
`scripts/worker-service.cjs`), rồi **chỉ nạp lại từ `~/.claude-mem/.env`**
(danh sách `FG`). Thiết kế này để một proxy vô tình trong shell không chiếm
quyền — nhưng trên máy này proxy lại chính là đường đăng nhập thật.

Không có file đó thì worker rơi xuống OAuth-keychain, keychain rỗng, và mọi
batch bị vứt với:

```
[SDK  ] ← "Not logged in · Please run /login"
[PARSER] SDK returned non-XML prose response — ignoring queued batch
```

**Triệu chứng đánh lừa:** MCP search vẫn chạy, DB vẫn đọc được, hook vẫn nổ,
`tool_uses` vẫn ghi — chỉ `observations` đứng im. Nhìn như "memory chết" nhưng
thực ra chỉ đứt đúng bước SDK tóm tắt.

## Cách sửa (đã làm 11/9/2026)

Tạo `~/.claude-mem/.env` với đúng hai dòng `ANTHROPIC_BASE_URL` và
`ANTHROPIC_API_KEY` ở trên, rồi restart worker:

```bash
P=$(cygpath -w ~/.claude/plugins/cache/thedotmack/claude-mem/<ver>)
node "$P/scripts/bun-runner.js" "$P/scripts/worker-service.cjs" stop
node "$P/scripts/bun-runner.js" "$P/scripts/worker-service.cjs" start
```

Kiểm chứng: `curl -s 127.0.0.1:37777/api/health` phải báo
`authMethod: "API key (from ~/.claude-mem/.env)"`, **không** phải
`"...system keychain..."`.

## Chẩn đoán nhanh lần sau

| Kiểm | Lệnh |
|---|---|
| worker sống? | `curl -s 127.0.0.1:37777/api/health` |
| hook có nổ? | `grep "HOOK" ~/.claude-mem/logs/claude-mem-<ngày>.log` |
| batch bị vứt? | `grep "non-XML\|Not logged in" <log>` |
| thô vs tóm tắt | so `max(created_at)` của `tool_uses` với `observations` trong `~/.claude-mem/claude-mem.db` |

**Why:** Mọi tầng đều báo "khoẻ" nên rất dễ đi sửa nhầm worker, plugin version,
hay đi chạy `/login` — trong khi gốc rễ là một file env không tồn tại.

**How to apply:** Khi observation ngừng sinh mà search vẫn chạy, so hai mốc
`tool_uses` / `observations` trước tiên. Cùng họ bẫy môi trường với
[[shell-encoding-traps]].
