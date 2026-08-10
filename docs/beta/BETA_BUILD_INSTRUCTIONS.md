# D1 — Beta Build

**Version:** Beta 0.9
**Build Date:** _______________

---

## Pre-Build Checklist

- [ ] All tests pass (D0.1 - D0.5 complete)
- [ ] No critical bugs open
- [ ] Code frozen for Beta
- [ ] Version bumped to 0.9

---

## Build Commands

```bash
# Ensure clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --build-name="PoolOS Beta 0.9" \
  --version-name="0.9.0" \
  --version-code=900

# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Tester Package Structure

```
PoolOS_Beta_0.9/
│
├── PoolOS_Beta_0.9.apk          # The APK to install
│
├── TESTER_GUIDE.pdf              # How to use the app
│
├── HOW_TO_EXPORT.pdf             # Black Box export instructions
│
├── CHANGELOG.md                 # What's new in Beta
│
└── KNOWN_LIMITATIONS.md         # Known issues, don't report these
```

---

## CHANGELOG.md Template

```markdown
# PoolOS Beta 0.9 — Changelog

## What's New

### Coach AI (NEW!)
- Personalized recommendations based on your progress
- Coach Chat for answering questions
- Coach Timeline to track your journey
- Black Box Export for debugging

### Practice Loop
- Guided drill sessions
- Progress tracking
- Reflection prompts
- Next Action recommendations

### General
- Bug fixes and performance improvements

## How to Report Issues

1. Use Black Box Export in Settings → PoolOS Black Box
2. Share the ZIP file with the developer
3. Include a brief description of the issue

## Known Issues

- See KNOWN_LIMITATIONS.md
```

---

## KNOWN_LIMITATIONS.md Template

```markdown
# PoolOS Beta 0.9 — Known Limitations

## Do NOT Report These

1. **Coach may suggest drills you've already completed**
   - Coach is learning your patterns, expect some overlap initially

2. **Chat response time may be slow**
   - AI processing happens on-device, may take 3-5 seconds

3. **Export may take up to 10 seconds**
   - First export is slower, subsequent exports are faster

4. **App requires ~100 MB storage**
   - Black Box data is stored locally

5. **Dark mode may not persist across restarts**
   - Will be fixed in Beta 0.9.1

## Report These

- App crashes
- Coach gives contradictory advice
- Drill progress not saved
- Export fails repeatedly
- UI elements missing or broken
```

---

## TESTER_GUIDE.md Template

```markdown
# PoolOS Beta Tester Guide

## Welcome, Tester!

Thank you for helping test PoolOS Beta. Here's what you need to know.

## Getting Started

1. Install PoolOS_Beta_0.9.apk on your Android device
2. Open PoolOS and complete onboarding
3. Start using the Coach feature

## Using Coach

### Coach Home
- Shows ONE thing to practice right now
- Tap "Bắt đầu" to start the recommended drill
- Tap "Vì sao?" to learn why Coach recommends this

### Coach Chat
- Ask Coach questions about your training
- Examples: "Tại sao tôi yếu?", "Tôi nên tập gì?"

### Coach Timeline
- View your training history
- See recommendations and completions

## Practice Sessions

1. Follow the drill instructions
2. Tap ✓ for success, ✗ for miss
3. Complete all reps to finish
4. Answer reflection questions

## Black Box Export

When you encounter an issue:

1. Go to Settings → PoolOS Black Box
2. Tap "Export Coach Package"
3. Optionally share your feedback
4. Share the ZIP file with the developer

**Your data stays private:**
- No account required
- No internet required
- No personal data included
- 100% anonymous

## Providing Feedback

The best feedback includes:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Export the Black Box ZIP

## Support

For questions, contact: [email]
```

---

## Post-Build Checklist

- [ ] APK built successfully
- [ ] APK size < 50 MB
- [ ] APK installs on test device
- [ ] Tester package created
- [ ] All documentation ready
- [ ] Tester list confirmed
- [ ] Distribution method ready

---

## Tester Distribution

### Recommended Testers (5-10)

| # | Profile | Focus Areas |
|---|---------|-------------|
| 1 | Beginner | Onboarding, Coach recommendations |
| 2 | Beginner | First drill experience |
| 3 | Intermediate | Practice loop |
| 4 | Intermediate | Coach Chat |
| 5 | Advanced | Edge cases, performance |
| 6 | Advanced | Coach accuracy |
| 7 | Casual | Overall experience |
| 8 | Casual | App stability |
| 9 | Heavy User | Long sessions, many drills |
| 10 | Heavy User | Black Box export flow |

---

## Sign-Off

| Task | Status | Date |
|------|--------|------|
| Build APK | ☐ | |
| Create Tester Package | ☐ | |
| Verify Installation | ☐ | |
| Distribute to Testers | ☐ | |
