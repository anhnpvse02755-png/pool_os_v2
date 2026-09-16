# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**Ngôn ngữ trao đổi: tiếng Việt.**

## Memory

Toàn bộ memory của dự án nằm ở **`.claude/memory/`**, index ở `MEMORY.md` tại
gốc repo. Đọc `MEMORY.md` đầu mỗi session. Khi ghi memory mới, ghi vào
`.claude/memory/` và thêm một dòng vào `MEMORY.md` — **không** dùng thư mục
memory mặc định của harness (`~/.claude/projects/…/memory/`), nó đã được gộp bỏ.

## Lệnh

**`flutter` KHÔNG có trên PATH.** Mọi lệnh phải prefix:

```powershell
$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test
```

```bash
# Bash: export PATH="/c/Users/anhnpv/flutter/bin:$PATH"
flutter analyze                                  # phải 0 error; info/warning ở test/ và tools/ là nợ cũ
flutter test                                     # toàn bộ suite
flutter test test/theme/design_tokens_test.dart  # một file
flutter test --plain-name "tên test"             # một test
flutter run -d chrome
```

E2E Playwright (Node, không cần prefix Flutter):

```bash
flutter build web --release --base-href /   # PHẢI build trước; dùng PowerShell — Git Bash biến `/` thành đường dẫn Windows
npx playwright test                         # webServer tự chạy tools/e2e-server.js:8080
npx playwright test --headed
```

## Kiến trúc

Flutter 3.47.0 · Dart 3.13.0 · Riverpod 2.x · GoRouter · Material 3.

```
lib/core/         theme (design token) · router · providers · services · models
lib/domain/       entities + services thuần, không phụ thuộc Flutter
lib/data/         repositories (interface) · impl · datasources · remote · content
lib/presentation/ screens (68 màn, 13 nhóm) · widgets dùng chung · providers
lib/knowledge/    knowledge graph bi-a — node nhân/quả/quyết định, coach & conversation engine
lib/beta/         nhánh tính năng beta, tự chứa (models/providers/services/presentation)
```

Từ điển kiến thức là dữ liệu, không phải mã: `assets/knowledge/knowledge.json` (138 mục).

**Repository pattern có một điểm cần biết trước khi đọc code:** cả 10 provider
trong `lib/core/providers/repository_providers.dart` đều trả về bản `Local*`
(SharedPreferences). Supabase đã cấu hình nhưng **chưa nhánh nào dùng
`SupabaseConfig.client`** — app hiện chạy hoàn toàn offline. Đừng giả định dữ
liệu đi qua mạng.

**Router dùng hash strategy.** Không có `usePathUrlStrategy`, nên URL thật là
`/#/home`. Điều này chi phối toàn bộ cách viết E2E — xem
`.claude/memory/e2e-playwright-accessibility.md` trước khi debug test Playwright.

## Redesign "Kem ấm & Xanh rêu" — đã xong

Đợt quét 68 màn từ xanh điện sang kem ấm + xanh rêu. **68/68 màn xong**
(11/9/2026), **vệ sinh token 0 vi phạm** (lô A–F, 15/9), **gốc `ThemeData` hết
xanh điện** (16/9). Plan ở `docs/superpowers/plans/2026-09-*-warm-green-*.md`.
Ràng buộc vẫn bắt buộc với mọi màn đụng tới:

- Màn đã quét **phải** dùng accessor `AppColors.foo(brightness)` — không để lại
  `AppColors.lightFoo` / `darkFoo` / `fooSubtleLight`.
- **Không dùng `Colors.*` của Material** làm màu giao diện. `Colors.transparent`
  là ngoại lệ duy nhất.
- **Không emoji làm icon** — dùng Material icon đặt trong `IconTile` pastel.
- **Không đổi font** — giữ `GoogleFonts.plusJakartaSans()`.
- Quét xong một lô thì gọi `expectTokenHygiene(tênLô, [đườngDẫn…])` từ
  `test/screens/token_hygiene.dart` — 10 luật chặn token khoá-sáng quay lại.

**`AppColors.accent = #3B82F6` vẫn còn trong `colors.dart`** nhưng đã hết điểm
dùng trong `lib/`. Nó sống tiếp chỉ để `test/theme/color_scheme_test.dart` có
cái đối chiếu. Đừng coi sự tồn tại của nó là lời cho phép dùng. Giá trị đúng và
các bẫy API của `AppShadows`/`AppSpacing`: `.claude/memory/design-system-tokens.md`.

**Mười luật vệ sinh token ĐỌC MÃ NGUỒN, không đọc giá trị.** Chúng không bắt
được `Theme.of(context).colorScheme.primary` — đó là cách viết hợp lệ, cái sai
nằm ở giá trị nạp vào `ColorScheme`. Đúng vì lỗ này mà xanh điện sống sót qua
cả sáu lô ngay giữa `app_theme.dart`. Canh gốc theme là việc của
`test/theme/color_scheme_test.dart`.

**Khi thêm một token màu, kiểm CẢ HAI chiều** — nó làm chữ trên nền gì, và nó
làm nền cho chữ gì. Một chiều là đủ để lọt qua ba vòng review (lô 3a mất một
vòng vì đúng lỗi này).

## Bẫy môi trường

**PowerShell 5.1 `Get-Content -Raw` đọc file bằng ANSI, không phải UTF-8.** Dùng
nó để patch file có tiếng Việt sẽ biến `Một người chơi` thành
`Má»™t ngÆ°á»i chÆ¡i` — hỏng vĩnh viễn nếu file chưa commit. Sửa file tiếng Việt
bằng tool Edit, hoặc commit trước rồi `git checkout -- <file>` để khôi phục.

`Understand-Anything/` là gitlink nhưng không có mapping trong `.gitmodules`,
nên `git status` luôn hiện dirty ở đó. Không phải lỗi bạn gây ra.
