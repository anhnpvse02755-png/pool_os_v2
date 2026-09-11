---
name: pool-os-project
description: PoolOS_v2 is an AI-powered billiard (bi-a) training platform built with Flutter
metadata:
  type: project
---

**PoolOS_v2 là nền tảng huấn luyện bi-a (billiard/pool) thông minh** — dùng AI phân tích lối chơi và đưa khuyến nghị cá nhân hoá cho người chơi.

⚠️ **KHÔNG phải** phần mềm quản lý dịch vụ bể bơi. Memory cũ ghi sai điều này (đã sửa 28/8/2026). Từ "Pool" ở đây là **bi-a**, không phải hồ bơi.

**Tính năng chính:**
- Theo dõi buổi chơi: ghi chi tiết trận đấu, rack, cú đánh
- Coach AI: phân tích lối chơi từ dữ liệu thực tế
- Thống kê cá nhân + lộ trình luyện tập
- Xếp hạng: Beginner → K → I → H → G → F

**Tech stack:**
| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter 3.47.0 · Dart 3.12.2 |
| State | Riverpod 2.x |
| Navigation | GoRouter |
| Backend | Supabase (Auth, DB, Edge Functions) |
| UI | Material 3 + design token riêng — xem [[warm-green-redesign]] |

**Version:** 0.9.0+900 · **Repo:** https://github.com/anhnpvse02755-png/pool_os_v2

**Quy mô:** 67 file screen trong `lib/presentation/screens/`, chia 13 nhóm: auth, coach, community, home, knowledge, match, onboarding, play, profile, reports, session, shell, training.

**Why:** Ghi sai domain khiến mọi suy luận downstream lệch hướng — dễ đề xuất tính năng hồ bơi cho một app bi-a.

**How to apply:** Khi đọc code, hiểu "pool" = bi-a. Xem [[sprint-status]] để biết sprint hiện tại, [[design-system-tokens]] trước khi sửa UI.
