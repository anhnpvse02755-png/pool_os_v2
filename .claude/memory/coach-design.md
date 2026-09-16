---
name: coach-design
description: Coach AI UX and Voice guidelines
metadata:
  type: project
---

**Coach UX Blueprint v2.1** — ✅ APPROVED với 10 rules

**Coach Voice Guideline** — FINAL với 10 rules + writing examples

**Key Principles:**
- Coach không phải assistant thông thường
- Tone: supportive, educational, confidence-building
- Khi user struggle → Coach offers guidance
- Khi user confident → Coach steps back
- Luôn respect user's expertise trong domain

**Why:** Coach là core differentiator của Pool OS v2. Design phải consistent.

**How to apply:** Trước khi viết Coach response hoặc design Coach UI, reference Coach Voice Guideline.


## Kiem man Coach: phai co khe (16/9/2026)

`CoachStateNotifier` goi `_initialize()` bat dong bo NGAY TRONG constructor va
dang ky `_ref.listen(trainingNotifierProvider)`. Hau qua: trang thai test vua
dat xong da bi ghi de, nen ba trang thai cua man Coach khong kiem duoc.

Khe: `CoachStateNotifier(ref, kg, autoStart: false, initialState: ...)`. Mac
dinh giu nguyen hanh vi cu nen ma chay that khong doi. Test o
`test/widget/coach_screen_states_test.dart`.

Hai loi lo ra ngay khi co test:

- **`coachState.error` khong widget nao doc.** Tai hong thi man van ve bai du
  phong — hong im lang. Da them nhanh loi dat TRUOC nhanh `isLoading`.
- **CTA trang thai rong dung chuoi cung `'straight_shot'`.** Cau noi chi biet
  `'STRAIGHT'` nen ma do giai ra null roi roi vao `?? drillCode` → man "Bai tap
  khong ton tai". Nay la hang `CoachScreen.fallbackDrillCode`.

**Bai hoc ve chinh test:** ban dau test cho loi thu hai chi khang dinh HANG
`fallbackDrillCode` giai duoc — no van xanh khi cai nut ben duoi con dung chuoi
cung. Phai dung GoRouter that, BAM NUT, doc ma trong URL. Kiem lai bang dot
bien (tat nhanh dang kiem, xem test co do khong) truoc khi tin mot test moi.

**Bay moi truong:** `flutter_animate` de lai timer treo → test do vi "A Timer is
still pending" chu khong phai vi assertion. Phai `pump(Duration(seconds: 1))`;
khong dung duoc `pumpAndSettle` vi vong quay cua trang thai dang tai quay mai.
