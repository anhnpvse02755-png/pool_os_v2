---
name: poolos
description: Memory duy nhất của PoolOS v2 — chỉ chứa cạm bẫy và quy ước không rữa theo thời gian; mọi trạng thái tiến độ nằm ở BACKLOG.md và git
metadata:
  type: project
---

# Luật của file này

**Chỉ ghi thứ KHÔNG rữa:** cạm bẫy đã vấp, quy ước đã chốt, lý do đằng sau một
quyết định, thứ không suy ra được từ repo.

**Không ghi trạng thái.** Không đếm màn, không đếm commit, không "còn N việc",
không "đã push chưa". Những thứ đó có nguồn tự cập nhật:

| Muốn biết | Hỏi ở đâu |
|---|---|
| Còn việc gì, tầng nào xong | `BACKLOG.md` |
| Đã commit/push gì | `git log`, `git status` |
| Bao nhiêu màn / bài tập / mục kiến thức | đếm bằng lệnh, đừng tin số viết sẵn |
| Sức khoẻ test | chạy `flutter analyze` + `flutter test` |

Lý do có luật này: trước đây 19 file memory trộn trạng thái với bài học, nên
sau vài ngày mọi file đều "có phần sai" và phải kiểm lại toàn dự án mới dám
tin — tốn hơn là không có memory.

---

## 1. Môi trường

`flutter` **không có trên PATH**. Mọi lệnh phải prefix:

```powershell
$env:PATH = "C:\Users\anhnpv\flutter\bin;$env:PATH"; flutter test
```

```bash
# Bash: export PATH="/c/Users/anhnpv/flutter/bin:$PATH"
```

SDK ở `C:\Users\anhnpv\flutter`. Repo ở `C:\Users\anhnpv\Desktop\poolos_v2`,
GitHub `anhnpvse02755-png/pool_os_v2`.

**PowerShell 5.1 `Get-Content -Raw` đọc file bằng ANSI, không phải UTF-8.**
Patch file tiếng Việt bằng nó sẽ biến `Một người chơi` thành
`Má»™t ngÆ°á»i chÆ¡i` — hỏng vĩnh viễn nếu file chưa commit. Sửa file tiếng
Việt bằng tool Edit, hoặc commit trước rồi `git checkout -- <file>`.

**Git Bash biến `/` thành đường dẫn Windows.** `flutter build web --base-href /`
hỏng trong Git Bash — dùng PowerShell cho lệnh có tham số `/`.

**`Understand-Anything/` là gitlink không có mapping trong `.gitmodules`** nên
`git status` luôn hiện dirty ở đó. Không phải lỗi bạn gây ra.

**Python 3.13** ở `C:\Users\anhnpv\AppData\Local\Programs\Python\Python313\`.
Chỉ các skill design cần nó; project Flutter không dùng. Nếu gặp *"Python was
not found"* thì đó là App Execution Alias stub của Microsoft Store —
`which python` **có** trả đường dẫn nhưng Python chưa cài. Kiểm bằng
`python --version`, đừng chỉ `which`.

**claude-mem tước `ANTHROPIC_*` khỏi env** (blocklist trong
`worker-service.cjs`) và chỉ nạp lại từ `~/.claude-mem/.env`. Máy này đăng nhập
qua proxy ocd cục bộ (`http://127.0.0.1:4141`, key `ocd-local`), keychain rỗng
— nên thiếu file đó thì observation ngừng sinh trong khi MCP search, DB và hook
vẫn chạy bình thường. Chẩn: so `max(created_at)` của `tool_uses` với
`observations` trong `~/.claude-mem/claude-mem.db`; health phải báo
`authMethod: "API key (from ~/.claude-mem/.env)"`.

---

## 2. Backend là Directus, KHÔNG phải Supabase

Supabase đã bị thay hẳn — gỡ khỏi `pubspec.yaml`, không còn import nào trong
`lib/`. Tài liệu nào còn nhắc Supabase như backend đang dùng là tài liệu sai
(chỉ còn vài comment tàn dư).

| | |
|---|---|
| App (Flutter web) | https://poolos.kjdybl.easypanel.host |
| API (Directus 12.3.1 + license OIG) | https://poolos-api.kjdybl.easypanel.host |
| Hộp thư test (Mailpit) | https://poolos-mail.kjdybl.easypanel.host |

VPS `195.35.7.42`, EasyPanel project `test-va`. Service: `directus` + `db`
(postgis 17-3.5) + `redis:7` + `mailpit` + `poolos` (nginx).
Secrets ở `deploy/directus/.env.generated` — **không commit**.

**Quan trọng:** hạ tầng xong nhưng **app chưa nối**. Kiểm nhanh bằng
`repository_providers.dart` — provider nào còn trả `Local*` là chưa nối.
Auth là phần duy nhất đã chạy thật trên Directus.

### Bẫy backend (tốn nhiều giờ, không có trong tài liệu)

1. **Quyền Directus CỘNG DỒN, không ghi đè.** Thêm permission có bộ lọc mà vẫn
   rò rỉ, vì permission không lọc cũ còn hiệu lực; hai cái cộng lại thành "đọc
   tất". **Phải xoá cái không lọc.** "Tạo được permission" ≠ "cách ly hoạt
   động" — chỉ test runtime hai user thật mới phát hiện.
2. **Nâng v11 → v12 XOÁ ÂM THẦM bộ lọc quyền.** Dữ liệu và collection còn
   nguyên, bộ lọc biến mất, không một cảnh báo nào. Bảo mật thụt về hở toang
   trong khi "đăng nhập vẫn được".
   → **Quy tắc: mỗi lần đổi phiên bản Directus hoặc đổi trạng thái license,
   PHẢI chạy lại test cách ly hai user.**
3. **License:** Directus 12 đổi BSL 1.1 → MSCL 1.0 và cưỡng chế hạn mức. Core
   tier = 25 collection · 3 seat · 5 Flows · **không có custom permission
   rules**. Gỡ bằng **Open Innovation Grant (miễn phí)**, kích hoạt qua
   `POST /license`, **không** đặt qua env `LICENSE_KEY` (làm vậy Studio khoá
   editor). `GET /server/info` có `license.source: null` nghĩa là đang Core tier.
4. **`#` trong file .env cắt cụt giá trị.** `PASSWORD_RESET_URL_ALLOW_LIST` đặt
   `.../#/reset-password` bị cắt còn `.../`. Dùng đường dẫn không có `#`;
   nginx đã có SPA fallback, app đọc token từ query string.
5. **Cloudflare chặn user-agent lạ** — `error code: 1010` với urllib/python,
   trông y hệt sai mật khẩu. Gửi UA trình duyệt là qua.
6. **Đường Compose của EasyPanel hỏng** — `createComposeService` luôn báo
   `ENOENT: docker-compose.override.yml`. Dùng app service gốc
   (`createAppService`/`createPostgresService`/`createRedisService`).
7. **`resources` trong `createPostgresService`** bắt buộc đủ 4 trường hoặc bỏ hẳn.

---

## 3. Deploy web

**Bundle build ở máy dev, KHÔNG build trên VPS** (2 vCPU, đang chạy production
`cms` + `website`).

Nhánh `deploy-easypanel` là **nhánh artifact riêng, không chứa mã nguồn**:
`Dockerfile` · `nginx.conf` · `.dockerignore` · `web/`. EasyPanel kéo thẳng từ
GitHub ref `deploy-easypanel`, path `/`. (`deploy/web/Dockerfile` ở nhánh chính
chỉ là bản sao tham khảo — thứ chạy thật là `Dockerfile` ở gốc nhánh deploy.)

```powershell
flutter build web --release --base-href /   # PowerShell, không Git Bash
```
```bash
git worktree add .worktrees/deploy origin/deploy-easypanel --detach
cd .worktrees/deploy && git checkout -B deploy-easypanel origin/deploy-easypanel
rm -rf web && cp -r <repo>/build/web ./web
git add -A && git commit && git push origin deploy-easypanel
git worktree remove .worktrees/deploy --force
```

Kích hoạt: MCP easypanel `deployAppService {projectName:"test-va",
serviceName:"poolos"}` — bị phân loại destructive vì ghi đè bản đang chạy.

**Kiểm chứng sau deploy — đừng tin nút "đã deploy".** So kích thước
`main.dart.js` trên server với bản local; khớp mới là bundle mới đã được phục
vụ (propagation mất ~1–2 phút). Một lần build bình thường chỉ đổi
`main.dart.js`, `flutter_bootstrap.js`, asset thực sự sửa, và
`MaterialIcons-Regular.otf` (tree-shake lại khi dùng icon Material mới). **Thấy
hàng trăm file đổi là dấu hiệu sai** — đổi phiên bản Flutter hoặc copy nhầm chỗ.

Ghi rõ trong commit message của nhánh deploy là build từ commit nào — bundle
build từ cây bẩn sẽ không ứng với commit nào.

---

## 4. Auth & guard

Đường đi: `DirectusConfig` (có URL mặc định, không cần `--dart-define`) →
`DirectusClient` (dio mỏng) → `AuthService` (dịch lỗi sang tiếng Việt) →
`AuthNotifier`/`authProvider`. Phiên ở `PrefsTokenStore` (SharedPreferences).

**Access token sống 15 phút** (server không đặt TTL). `_send` gặp 401 thì gia
hạn một lần rồi thử lại. Hạn đọc từ claim `exp` của JWT — token không đọc được
thì **coi như còn hạn**, vì đoán bừa sẽ đăng xuất oan.

### Ba quy ước phiên hết hạn — đừng phá

1. **`sessionExpired` tách khỏi `error`.** `error` là kết quả thao tác vừa rồi;
   `sessionExpired` giải thích vì sao người dùng *đột nhiên* bị đưa về. Gộp
   chung thì thông báo biến mất ngay khi họ bấm Đăng nhập.
2. **Tự bấm Đăng xuất không phát tín hiệu này** — báo "hết hạn" cho việc họ cố
   ý làm là nói sai sự thật.
3. Thông báo dùng tông **`warning`**, không phải `error` — họ không làm gì sai.

`_restore()` chỉ điền vào chỗ **chưa biết** (`status == unknown`); ghi đè sẽ
xoá mất cờ hết hạn.

### Ranh giới guard (`requiresAuth` trong `app_router.dart`)

**Chặn** (đọc/ghi dữ liệu riêng): `/profile` `/notifications` `/community`
`/session` `/coach` `/play` `/settings` `/training/progress`
`/training/history` `/training/session`.

**Tự do:** mọi thứ còn lại, gồm `/home`, thư viện bài tập, từ điển kiến thức.
Lý do: giá trị của app phải nhìn thấy được **trước** khi quyết định đăng ký.

Guard khớp **trọn đoạn** đường dẫn — so chuỗi trần thì `/playbook` bị chặn oan
vì trùng `/play`. Đổi ranh giới thì sửa `_privatePrefixes` rồi cập nhật
`test/router/auth_guard_test.dart`. Đừng hardcode thông báo lỗi ở UI —
`AuthService` đã dịch sẵn.

---

## 5. E2E Playwright

**Router dùng hash strategy** (không có `usePathUrlStrategy`), nên URL thật là
`/#/home`. Đây là gốc của phần lớn rắc rối E2E.

```powershell
flutter build web --release --base-href /   # PHẢI build trước
```
```bash
npx playwright test    # webServer tự chạy tools/e2e-server.js:8080
```

### Bốn thứ làm Playwright không chạy được với Flutter Web

1. **Hash routing.** `page.goto('/home')` → router boot ở `/welcome` → URL
   thành `/home#/welcome`, hiển thị màn Welcome. Phải đi `/#/home`.
2. **Boot race.** `goto` trả về trước khi Flutter khởi động ~4–6s. Trong lúc đó
   `document.title` vẫn là `pool_os_v2`; chỉ sau boot mới thành `PoolOS`.
3. **Canvas semantics.** `getByRole`/`getByText` không thấy gì cho tới khi kích
   hoạt `flt-semantics-placeholder`. Nút đó **nằm ngoài viewport** → phải
   `dispatchEvent('click')`, `.click()` luôn ném *"Element is outside of the
   viewport"*. Tín hiệu sẵn sàng: `flt-semantics-host` có `childElementCount > 0`.
4. **`data-testid` không tồn tại.** Flutter chỉ phát semantics node, app không
   dùng `Semantics(identifier:)` ở đâu → mọi selector `[data-testid]` vĩnh viễn
   không khớp. Dùng role + accessible name.

Cả bốn đã xử lý trong `fixtures/app.fixture.ts` và `pages/*.ts`.

### `push` không đồng bộ URL — đừng assert `page.url()` bừa

| Điều hướng | Màn đổi | URL đổi |
|---|---|---|
| Bottom nav (`context.go`) | ✅ | ✅ |
| Training / Play / welcome→onboarding (`context.push`) | ✅ | ❌ |

Nơi app dùng `context.push`, kiểm **nội dung màn đích**, không phải URL. Bottom
nav "Progress" đi tới `/coach/analysis`, không phải `/progress`.

### Hai thứ PHẢI seed vào localStorage

**Phiên đăng nhập** — route riêng tư bị đẩy về `/auth/login`, triệu chứng đánh
lừa là *"không tìm thấy nút Đấu nhanh"*. Không đăng nhập qua giao diện được:
Directus trả `Access-Control-Allow-Origin: https://poolos.kjdybl.easypanel.host`
nên lời gọi từ `localhost:8080` bị CORS chặn (`curl` vẫn 200 vì không phải
trình duyệt — đừng để điều đó đánh lừa). Dùng `seedSession(page)`; guard chỉ
hỏi "có token không" nên token giả là đủ.

**Chế độ tối** — `test.use({ colorScheme: 'dark' })` **không đủ**.
`ThemeNotifier` chỉ đọc lựa chọn đã lưu, bỏ qua `prefers-color-scheme`. Không
seed `flutter.poolos_v2.theme` thì cả lượt chạy ở chế độ SÁNG và test báo hàng
loạt màn "không đọc brightness" — sai hoàn toàn. Tiền tố `flutter.` là của
SharedPreferences bản web; giá trị String bị **JSON-encode hai lần**.

**Bẫy thứ tự:** fixture chỉ khởi tạo khi **thân test** chạy, tức SAU mọi
`beforeEach`. Seed phải nằm trong `beforeEach`, trước lời gọi điều hướng.

**Flaky firefox:** mỗi test boot một instance Flutter (~5s); để Playwright tự
chọn worker theo số CPU thì máy quá tải, boot vượt hạn 30s. `workers: 2` xử lý.

**Flutter Web vẽ bằng WebGL nên `getImageData` trả null** — muốn đo độ sáng ảnh
phải đo trên ảnh chụp của Playwright (`tests/helpers/png-luminance.ts`).

---

## 6. Design system "Kem ấm & Xanh rêu"

Đợt redesign đã xong toàn bộ. Giá trị chốt:

| | Sáng | Tối |
|---|---|---|
| primary | `#0F4032` | `#34A97C` |
| nền | `#F7F4EC` | `#121715` |

Bo góc: `radiusSm=12` `radiusMd=20` `radiusLg=28` `radiusTile=18` `radiusFull=9999`.

### Ràng buộc bắt buộc với mọi màn đụng tới

- Dùng accessor **`AppColors.foo(brightness)`** — không để lại
  `AppColors.lightFoo` / `darkFoo` / `fooSubtleLight`.
- **Không dùng `Colors.*` của Material** làm màu giao diện. `Colors.transparent`
  là ngoại lệ duy nhất.
- **Không emoji làm icon.** Dùng Material icon trong `IconTile` pastel — trừ
  dấu hiệu bi-a thì dùng `PoolCueMark` vì Material không có glyph nào.
- **Không đổi font** — giữ `GoogleFonts.plusJakartaSans()`.
- Quét xong một lô thì gọi `expectTokenHygiene(tênLô, [đườngDẫn…])` từ
  `test/screens/token_hygiene.dart`.

`AppColors.accent = #3B82F6` **vẫn còn trong `colors.dart`** nhưng đã hết điểm
dùng trong `lib/`. Nó sống tiếp chỉ để `test/theme/color_scheme_test.dart` có
cái đối chiếu. **Đừng coi sự tồn tại của nó là lời cho phép dùng.**

### Ba bài học đắt nhất

1. **Mười luật vệ sinh token ĐỌC MÃ NGUỒN, không đọc giá trị.** Chúng không bắt
   được `Theme.of(context).colorScheme.primary` — đó là cách viết hợp lệ, cái
   sai nằm ở giá trị nạp vào `ColorScheme`. Đúng vì lỗ này mà xanh điện sống
   sót qua cả sáu lô ngay giữa `app_theme.dart`, chảy ra ~200 điểm
   (`PrimaryButton`, 56 `ElevatedButton`, 50 `TextButton`, viền focus, chip đã
   chọn, progress, switch, bottom nav). Canh gốc theme là việc của
   `test/theme/color_scheme_test.dart`. Luật hygiene cũng **quét cả COMMENT**,
   nên đừng viết tên token bị cấm hay emoji vào chú thích.
2. **Thêm một token màu thì kiểm CẢ HAI chiều** — nó làm chữ trên nền gì, và nó
   làm nền cho chữ gì. Một chiều là đủ để lọt qua ba vòng review.
3. **Ghi chép nợ sống lâu hơn nguyên nhân của nó** — món nợ "nhãn nút vô hiệu
   2,59:1" đã tự hết khi `textTertiary` được nâng, mà không ai ghi lại. **Đo
   lại trước khi sửa.**

### Cạm bẫy API

**`AppShadows` có HAI kiểu API:**
```dart
AppShadows.lightSm          // getter  → List<BoxShadow>
AppShadows.sm(brightness)   // function → List<BoxShadow>
```
Cả hai trả `List<BoxShadow>`, **không phải** `BoxShadow`. Gán thẳng vào
`boxShadow:`, đừng bọc `[...]`.

**`AppSpacing` dùng tên số:** `space1=4 space2=8 space3=12 space4=16 space5=20
space6=24 space8=32 space12=48 space16=64` · alias `xs=4 sm=8 md=12 lg=16
xl=20 xxl=24`.

**`AppShadows` ở `lib/core/theme/shadows.dart`, KHÔNG re-export từ `theme.dart`**
— thiếu import này là nguyên nhân phổ biến của lỗi analyze.

### Chip không được nằm trong vùng cuộn ngang

Trong `ListView`/`SingleChildScrollView` cuộn ngang, con được cấp **bề rộng vô
hạn**; Material Chip đo nhãn trong hoàn cảnh đó bị hụt rồi cắt ký tự cuối
("Kiểm Soát Vị Trí" → "Kiểm Soát Vị Tr"). Đặt trong **`Wrap`** thì hết. Ba giả
thuyết đã loại trừ bằng thực nghiệm, **đừng thử lại**: `height: 50` bó chip,
`google_fonts` tải chậm, thiếu `labelPadding`. Luật chặn:
`test/screens/chip_layout_test.dart`.

### `PoolCueMark` — tỉ lệ quyết định mark đọc ra cái gì

Material không có glyph bi-a, trước đây tám chỗ mượn icon **bể bơi** (người
đang bơi) làm logo cho app bi-a. Thay bằng
`lib/presentation/widgets/logo/pool_cue_mark.dart`.

Bản đầu (bi 0,26 · cơ 0,52 · nét đều 0,12) nhìn ra **cái chảo** — cán ngắn hơn
hai lần đường kính bi thì mắt đọc nó là tay cầm. Bản chốt: bi 0,15 · cơ dài
~2,3 lần đường kính bi · thuôn 0,035→0,055 · đuôi dừng ở 0,90.

**Kiểm ở cỡ thật, không chỉ cỡ logo:** dựng mark trong widget test rồi
`toImage(pixelRatio: 10)`. Đó là cách duy nhất thấy được bản đầu hỏng ở 18px.
Luật chặn icon cũ quay lại: `test/widgets/pool_cue_mark_test.dart` — nó cũng
**quét cả chú thích**.

### Bẫy khi test `ThemeData`

Dựng theme trong thân `main()` → "Binding has not yet been initialized"
(GoogleFonts cần binding). Dựng trong thân test → GoogleFonts nạp font **bất
đồng bộ**, trong test luôn hỏng, và lỗi nổ **sau khi** test gọi nó đã xong nên
làm đỏ test KẾ TIẾP ("This test failed after it had already completed") dù mọi
assertion đều đúng. Bọc `runZonedGuarded` quanh chỗ dựng theme thì hết.

---

## 7. Dữ liệu kiến thức & bài tập

Từ điển kiến thức là **dữ liệu, không phải mã**: `assets/knowledge/knowledge.json`.

| Thư viện | Nguồn | Đích |
|---|---|---|
| Kiến thức | `new knowledge/Tu-Dien-Kien-Thuc-Billiard-Pool.md` | `assets/knowledge/knowledge.json` |
| Bài tập | `new knowledge/Danh-Sach-Bai-Tap-Billiard.md` | `lib/core/utils/drills_library.dart` |

**Bài tập SINH TỰ ĐỘNG** bằng `tools/gen_drills.py` — sửa file `.md` rồi chạy
lại, **đừng sửa tay** `drills_library.dart`.

### Không bịa dữ liệu

Bài nào nguồn không nêu ngưỡng số → `passCount = 0`, `criteriaVi` giữ nguyên
văn. Mục **"Lỗi thường gặp" để RỖNG** (nguồn chưa có) và UI ẩn hẳn mục đó — chủ
dự án sẽ bổ sung vào file `.md` sau. Trước đây chỗ này rơi về
`_genericMistakes` ("Đánh quá mạnh hoặc quá nhẹ") dùng chung cho mọi bài.

### Thang cấp độ: 50 cú mỗi cấp

Tính bằng phân phối nhị thức. Ở n=10 **không** ngưỡng nào tách được người 80%
khỏi người 90% — cổng "9/10" để lọt 37,6% người chỉ đạt 80%.

| Hạng | Cấp 1 → 2 → 3 |
|---|---|
| A (đánh thẳng, ngắm, tư thế, luật) | 27/50 → 35/50 → 42/50 |
| B (vị trí, safety, english) | 22/50 → 30/50 → 37/50 |
| C (bank, jump, kick) | 8/30 → 12/30 → 16/30 |

Hạng C dùng **30 cú** — đánh 50 cú nhảy bi liên tục là kiểm tra thể lực. Giá
phải trả: người chưa đủ sức lọt tăng 13% → 23%. Ngưỡng đặt **dưới** tỉ lệ mục
tiêu để chừa biến động.

### Đã gỡ, đừng dựng lại

`knowledgeArticlesVi` · `DrillService` · `DrillLibraryService` (cả hai nạp
`assets/data/drills_data.json` — **file không tồn tại**, lỗi bị catch nuốt) ·
`LocalKnowledgeRepository` · 7 provider chết · 102 mục kiến thức khuôn rỗng.
**Giữ lại:** `drillRepositoryProvider`, `trainingHistoryProvider`.

### Nợ chưa xử: hai bộ từ vựng độ khó song song

UI bài tập switch trên `easy/medium/hard/expert`; kiến thức dùng
`beginner/intermediate/advanced/expert`. Generator phát ra bộ của UI bài tập.
Cần một task riêng.

---

## 8. Hai cặp trùng tên dễ nhầm

### Hai hệ mã bài tập

| Hệ | Ví dụ | Dùng ở đâu |
|---|---|---|
| Knowledge graph (`DrillNode.code`) | `BANK_SHOT`, `POSITION_CONTROL` | nguồn ra quyết định: lộ trình, điểm yếu, buổi tập đề xuất |
| `DrillLibrary` (`Drill.code`) | `BT01`… | mọi màn TẬP thật (`DrillSessionScreen`) |

Cầu nối: `lib/knowledge/drill_code_bridge.dart` → `resolveDrillCode()`.
**Điều hướng tới `/training/session/new?drill=…` bằng mã chưa resolve sẽ ra màn
lỗi "Bài tập với mã ... không tồn tại".** Thấy màn đó thì nghi mã chưa resolve
trước, đừng nghi `DrillLibrary` thiếu bài.

Thêm `DrillNode` mới thì thêm luôn một `case` trong `v1ToV2Code`, nếu không
`test/knowledge/drill_code_bridge_coverage_test.dart` sẽ đỏ.

**Quyết định đã chốt (người dùng):** stop/follow/draw **tách ba bài, không
gộp** — chúng là ba kỹ năng nền tảng của người mới; gộp lại thì hệ gợi ý chỉ
nói được "hỏng ở bài gộp" chứ không nói được "hỏng ở draw". Cầu nối:
`STOP → BT07 · FOLLOW → BT08 · DRAW → BT09`, `STUN_SHOT → BT07`.
Luật chặn tái phạm: `test/knowledge/drill_codes_integrity_test.dart`.

### Hai class `KnowledgeGraphService` trùng tên

| Class | Provider | Khởi tạo |
|---|---|---|
| `lib/domain/services/knowledge_graph_service.dart` | `knowledgeGraphServiceProvider` | nhận `cacheRepositoryProvider` |
| `lib/knowledge/knowledge_graph_service.dart` | `knowledgeGraphProvider` | singleton `.instance` |

Bên tiêu thụ chính (`SessionBuilderService`, `CoachProvider`, `coach_screen`,
`player_intelligence_service`) đều dùng bản **`lib/knowledge/`**, tức
`knowledgeGraphProvider`. **Tên provider dài hơn lại là bản ít dùng hơn** — đó
chính là cái bẫy. Thấy lỗi gán `KnowledgeGraphService` sang
`KnowledgeGraphService` thì đọc đường dẫn trong ngoặc trước khi sửa import.

---

## 9. Bẫy test & công cụ

**`dart fix` không tin được mù.** Với `--code=avoid_init_to_null` nó sinh Dart
**không hợp lệ**: `const A._({required this.ok, this.x});` thành
`const A._({required this.ok}) : x = null : y = null;` (hai dấu `:`). Luôn
`flutter analyze` ngay sau khi chạy `dart fix`.

**Lint mức cảnh báo giấu được bug thật.** Repo từng chỉ chặn ở mức `error`, và
bốn luật này đang giấu lỗi thật: `unrelated_type_equality_checks` (bộ điều
chỉnh điểm Sprint-13 chưa từng chạy), `equal_keys_in_map` (ba khoá `'BT07'`
trùng — nuốt hai bài tập), `equal_elements_in_set` (một id danh mục khai hai
lần), `dead_code`. Cả bốn đã nâng lên `error` trong `analysis_options.yaml` —
**đừng hạ xuống**.

**`DropdownButtonFormField.initialValue` KHÔNG theo state nạp bất đồng bộ.**
Khi migrate khỏi `value:` đã phế, dropdown thiết bị vỡ vì dữ liệu nạp sau
build. Còn cần `value:` để thoả assertion của Flutter, và cần helper
(`_mucDuongKinh`) **luôn chèn giá trị hiện tại** vào danh sách kể cả khi giá
trị đó không nằm trong hằng (seed `cue_main` có `shaftDiameter` 12.4mm không
có trong `EquipmentConstants`).

**Điều hướng không được sống trong `build()`.** `WelcomeScreen` từng gọi
`context.go` trong `build()` và dùng `context` sau `await` mà không kiểm
`mounted`. Đã chuyển sang StatefulWidget.

**Notifier gọi việc bất đồng bộ trong constructor thì không test được.**
`CoachStateNotifier` gọi `_initialize()` ngay trong constructor và đăng ký
`_ref.listen(...)`, nên trạng thái test vừa đặt xong đã bị ghi đè. Khe:
`CoachStateNotifier(ref, kg, autoStart: false, initialState: ...)` — mặc định
giữ nguyên hành vi cũ nên mã chạy thật không đổi.

**`flutter_animate` để lại timer treo** → test đỏ vì *"A Timer is still
pending"* chứ không phải vì assertion. Phải `pump(Duration(seconds: 1))`;
**không dùng được `pumpAndSettle`** vì vòng quay của trạng thái đang tải quay
mãi.

**"Không ai gọi" ≠ "mã chết".** Task 4 xoá `saveKnowledgeProgress` vì grep ra 0
caller. Đúng là 0 caller, nhưng đó chính là **bug**: mục "Tiến độ kiến thức" ở
Profile rỗng vì đường ghi chưa bao giờ được nối, không phải vì tính năng đã bỏ.
Trước khi xoá một API không có caller, hỏi *"phía ĐỌC có ai dùng không"* — còn
người đọc mà mất người ghi thì đó là tính năng gãy, không phải rác.

Hệ quả cho cách viết test: bug dạng này **test gọi thẳng hàm ghi không bắt
được** — nó xanh trong khi màn hình vẫn rỗng. Test phải đi qua màn hình. Kiểm
bằng đột biến: bỏ lời gọi ở `initState`, test phải đỏ.

**Đổi model mà quên nguồn phát `toJson`/`toMap` thì hỏng IM LẶNG.** `fromJson`
không tìm thấy khoá sẽ rơi về mặc định — `0` và `DateTime.now()` — không một
ngoại lệ nào nổ, không log nào in. Buổi tập đọc ra vẫn "hợp lệ", chỉ là số liệu
sai và ngày là hôm nay. Sửa model thì phải đi ngược lên **mọi** chỗ phát ra map
đó, đừng chỉ sửa chỗ đọc.

**`setMockInitialValues` KHÔNG xoá cache singleton tĩnh của
`shared_preferences`** (bản `_foundation` 2.x). `getInstance()` trả lại đúng
instance cũ, nên prefs rò rỉ **giữa các file test** chứ không chỉ giữa các test
trong một file. Triệu chứng: test xanh khi chạy riêng, đỏ khi chạy cả suite
(hoặc ngược lại). Đừng thêm `reset()`/`setTestPrefs()` vào **mã sản phẩm** để
vá — đó là API chỉ-để-test làm bẩn tầng thật; seed prefs trong `setUp` của từng
file thay vào đó.

**Một hàm có hai chế độ hỏng thì cần hai test, không phải một.**
`wipeAllLocalData()` vừa có thể xoá thiếu key vừa có thể xoá nhầm cờ di trú; một
test bao cả hai sẽ vẫn xanh khi một trong hai hỏng. Kiểm bằng **đột biến từng
nhánh**: tắt riêng từng guard, phải có **đúng một** test đỏ cho mỗi nhánh.

**Test xanh chưa chắc test đúng.** Một test cho lỗi "CTA dùng chuỗi cứng" ban
đầu chỉ khẳng định *hằng số* giải được — nó vẫn xanh khi cái nút bên dưới còn
dùng chuỗi cứng. Phải dựng GoRouter thật, **bấm nút**, đọc mã trong URL. Kiểm
lại test mới bằng **đột biến** (tắt nhánh đang kiểm, xem test có đỏ không)
trước khi tin nó.

---

## 10. Quy ước sản phẩm

**"Pool" ở đây là BI-A**, không phải bể bơi. Memory cũ từng ghi sai và mọi suy
luận downstream lệch theo.

Xếp hạng người chơi: Beginner → K → I → H → G → F.

Coach không phải assistant thông thường: người dùng struggle thì Coach đưa
hướng dẫn, người dùng tự tin thì Coach lùi lại. Tài liệu đầy đủ ở `docs/coach/`
(UX Blueprint v2.1, Voice Guideline).

**Why:** Toàn bộ file này là thứ đã tốn nhiều giờ để phát hiện và không suy ra
được bằng cách đọc repo — phần lớn là bẫy "mọi tầng đều báo xanh trong khi có
cái hỏng".

**How to apply:** Đọc file này đầu mỗi session. Cần biết tiến độ thì đọc
`BACKLOG.md`, đừng tìm trong đây. Ghi thêm vào đây chỉ khi học được thứ sẽ còn
đúng sau ba tháng nữa.
