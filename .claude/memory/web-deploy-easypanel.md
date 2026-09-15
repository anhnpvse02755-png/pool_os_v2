---
name: web-deploy-easypanel
description: Quy trình đưa bundle Flutter web lên https://poolos.kjdybl.easypanel.host — nhánh deploy-easypanel chỉ chứa bundle, không build trên VPS
metadata:
  type: project
---

App web chạy ở **https://poolos.kjdybl.easypanel.host**, service EasyPanel
`test-va` / `poolos` (nginx). Xem [[backend-directus]] cho phần API/Directus.

**Bundle build ở máy dev, KHÔNG build trên VPS** — VPS chỉ 2 vCPU và đang chạy
production (`cms`, `website`); build Flutter ở đó vừa chậm vừa tranh tài nguyên.

## Nhánh `deploy-easypanel` là nhánh riêng chỉ chứa artifact

Nội dung: `Dockerfile` · `nginx.conf` · `.dockerignore` · `web/` (bundle). Không
có mã nguồn. EasyPanel kéo thẳng từ GitHub
(`anhnpvse02755-png/pool_os_v2`, ref `deploy-easypanel`, path `/`).

## Các bước

```powershell
# 1. PowerShell — Git Bash biến `/` thành đường dẫn Windows
flutter build web --release --base-href /
```
```bash
# 2. Worktree riêng để không đụng cây làm việc đang dở
git worktree add .worktrees/deploy origin/deploy-easypanel --detach
cd .worktrees/deploy && git checkout -B deploy-easypanel origin/deploy-easypanel
rm -rf web && cp -r <repo>/build/web ./web
git add -A && git commit && git push origin deploy-easypanel
git worktree remove .worktrees/deploy --force   # sau khi xong
```
3. Kích hoạt: MCP easypanel `deployAppService {projectName:"test-va",
   serviceName:"poolos"}` (bị phân loại destructive vì ghi đè bản đang chạy).

## Kiểm chứng sau deploy

Deploy mất ~1–2 phút. Đừng tin nút "đã deploy" — so **kích thước
`main.dart.js`** trên server với bản local; chỉ khi khớp mới là bundle mới đã
được phục vụ. Kiểm thêm `assets/assets/knowledge/knowledge.json` (đếm số mục) và
SPA fallback bằng một URL sâu bất kỳ.

**Điều đáng chú ý:** một lần build đổi rất ít file — chỉ `main.dart.js`,
`flutter_bootstrap.js`, asset nào thực sự sửa, và `MaterialIcons-Regular.otf`
(tree-shake lại khi dùng icon Material mới). Thấy hàng trăm file đổi là dấu hiệu
sai (đổi phiên bản Flutter, hoặc copy nhầm chỗ).

**Why:** Quy trình này không có script, không có CI — không suy ra được từ repo;
`deploy/web/Dockerfile` ở nhánh chính chỉ là bản sao tham khảo, thứ chạy thật là
`Dockerfile` ở gốc nhánh `deploy-easypanel`.

**How to apply:** Bundle deploy từ cây làm việc bẩn sẽ không ứng với commit nào —
ghi rõ trong commit message của nhánh deploy là build từ đâu.
