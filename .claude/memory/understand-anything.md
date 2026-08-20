---
name: understand-anything
description: Understand-Anything plugin installed in project
metadata:
  type: reference
---

**Understand-Anything** plugin đã được cài đặt vào dự án.

**Vị trí plugin:** `Understand-Anything/understand-anything-plugin/`

**Các skills có sẵn:**

| Skill | Mô tả |
|-------|-------|
| `/understand` | Analyze codebase để tạo knowledge graph |
| `/understand-chat` | Hỏi về codebase sử dụng knowledge graph |
| `/understand-onboard` | Tạo onboarding guide cho project |
| `/understand-dashboard` | Mở interactive dashboard |
| `/understand-diff` | Phân tích changes trong diff |
| `/understand-domain` | Phân tích domain knowledge |
| `/understand-explain` | Giải thích code |
| `/understand-figma` | Phân tích Figma designs |
| `/understand-knowledge` | Quản lý domain knowledge |

**Requirements:**
- Node.js >= 22
- pnpm >= 10

**Data directory:** `.ua/` hoặc `.understand-anything/` (legacy)

**Why:** Plugin này giúp phân tích codebase nhanh chóng và tạo interactive knowledge graph để hiểu architecture.

**How to apply:** Sử dụng `/understand` để analyze project, sau đó dùng `/understand-chat` để hỏi về codebase.
