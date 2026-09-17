# Memory Index

Dự án này có **đúng một file memory**:

- [poolos](.claude/memory/poolos.md) — cạm bẫy và quy ước của PoolOS v2: môi
  trường, backend Directus, deploy, auth, E2E, design system, dữ liệu, bẫy test

## Luật

File memory **chỉ chứa thứ không rữa theo thời gian** — cạm bẫy đã vấp, quy ước
đã chốt, lý do đằng sau một quyết định. Nó **không chứa trạng thái**: không đếm
màn, không đếm commit, không "còn N việc", không "đã push chưa".

| Muốn biết | Hỏi ở đâu |
|---|---|
| Còn việc gì, tầng nào xong | `BACKLOG.md` |
| Đã commit/push gì | `git log`, `git status` |
| Bao nhiêu màn / bài tập / mục kiến thức | đếm bằng lệnh, đừng tin số viết sẵn |
| Sức khoẻ test | chạy `flutter analyze` + `flutter test` |

Trước đây chỗ này có 20 file trộn lẫn hai loại, nên sau vài ngày file nào cũng
"có phần sai" và phải kiểm lại toàn dự án mới dám tin. Gộp về một file ngày
17/9/2026. Bản cũ vẫn lấy lại được:
`git show 8900b02 -- .claude/memory/` hoặc `git checkout 8900b02 -- .claude/memory/`.

**Thêm memory mới:** viết thẳng vào `.claude/memory/poolos.md`, đúng mục phù
hợp. Chỉ thêm khi học được thứ sẽ còn đúng sau ba tháng nữa. Đừng tạo file thứ
hai — mục đích của lần gộp này là để không bao giờ phải đi đối chiếu nhiều
nguồn nữa.
