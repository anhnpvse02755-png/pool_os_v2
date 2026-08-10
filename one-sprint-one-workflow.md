---
name: phase-3-rule-5
description: Phase 3 Constitution Rule 5 — one sprint = one complete workflow; AI hooks into completed workflows, not reverse-engineered.
metadata:
  type: feedback
---

Phase 3 Constitution Rule 5:

**One Sprint, One Complete Workflow.**

- Mỗi sprint giải quyết đúng 1 workflow hoàn chỉnh.
- Workflow phải chạy end-to-end trước khi sprint đóng.
- AI / Coach / Recommendation được gắn vào workflow đã hoàn thiện.
- Không thiết kế ngược từ AI để quyết định workflow.

**Why:** Reverse-engineering workflows from AI capabilities (e.g., "what could Coach see?") leads to speculative features and scope creep. Building the workflow first means AI slots in as a consumer of real signals (Reflection data, Match history, Completion state).

**How to apply:**
- For each new sprint: identify the single workflow gap, not the AI feature.
- Out-of-scope checklist must include: AI Coach, Recommendation AI, Knowledge integration, future-phase intelligence.
- Sprint closes only when workflow runs end-to-end (Code path + DoD + Product Validation).

Related: [[phase-3-constitution]], [[phase-3-validation-rule]], [[sprint-3a-product-facts]], [[sprint-3b-product-facts]].