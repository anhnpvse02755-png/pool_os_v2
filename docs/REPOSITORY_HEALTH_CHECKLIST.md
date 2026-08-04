# Repository Health Checklist

> **Mandatory pre-RC / pre-Beta gate.**
> **Origin:** Sprint 1 recovery (2026-08-04).
> **Purpose:** prevent the Sprint 1 source-of-truth regression from
> recurring.

## Why this exists

During Sprint 1, `main` was not buildable from a clean clone because
production source lived only in the user's local working tree. The
recovery returned `main` to a buildable state, but the lesson is
general: **a Source of Truth that does not build is not a Source of
Truth.**

This checklist operationalizes that lesson. It must pass on `main`
(after every merge into `main`) before any RC or Beta tag is cut.

## When to run

- Before every RC tag.
- Before every Beta tag.
- Before every release to production.
- Whenever merging to `main` if the merge touches
  `lib/**`, `pubspec.yaml`, `assets/`, or `tools/`.

## How to run

The gate must run on a **fresh clone** of `origin/main`. No working
tree, no untracked files, no local caches.

```bash
# 1. Fresh clone (or worktree)
git clone <repo-url> poolos-check
cd poolos-check

# 2. Gate checks (each must PASS)
flutter pub get
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
```

Record the result in `docs/REPOSITORY_HEALTH_REPORT.md` (or attach to
the release tag).

## Gate definitions

| Gate | Command | Pass condition |
|---|---|---|
| **1. Clean clone** | `git clone` | No errors, no warnings. |
| **2. Dependencies** | `flutter pub get` | Exit code 0. |
| **3. Static analysis** | `flutter analyze` | 0 errors. Warnings/info allowed. |
| **4. Tests** | `flutter test` | 100% pass rate, except pre-existing failures documented in `SPRINT_*_BACKLOG.md`. |
| **5. Web build** | `flutter build web --release` | Exit code 0. |
| **6. Android build** | `flutter build apk --debug` | Exit code 0. |

## Sprint 1 baseline (recorded 2026-08-04)

| Gate | Result |
|---|---|
| Clean clone | PASS |
| `flutter pub get` | PASS |
| `flutter analyze` | 0 errors / 57 warnings / 47 info |
| `flutter test` (Sprint 1) | 88/88 PASS |
| `flutter build web --release` | PASS (113.6s) |
| `flutter build apk --debug` | PASS (93.6s) |

## Recording a Health Check

```markdown
# Repository Health Report — <date>

  Branch: main
  Commit: <sha>
  Tester: <name>

  Gate 1 - Clean clone:        PASS / FAIL
  Gate 2 - Dependencies:       PASS / FAIL
  Gate 3 - Static analysis:    PASS / FAIL
  Gate 4 - Tests:              PASS / FAIL
  Gate 5 - Web build:          PASS / FAIL
  Gate 6 - Android build:      PASS / FAIL

  Total: X / 6 PASS

  Notes:
  - <any deviation from baseline>
```

## Failure escalation

If any gate fails:

1. **Stop the release.** Do not tag.
2. Investigate whether the failure is a regression in the merge
   just landed, or a pre-existing issue.
3. For regressions: revert the offending commit, fix forward.
4. For pre-existing issues: log in `SPRINT_*_BACKLOG.md` and decide
   scope.
5. Re-run the gate from a fresh clone of the corrected `main`.

## Why a fresh clone

A fresh clone is the only test that catches the Sprint 1 failure
mode. The local working tree can hide missing source files because
they exist uncommitted. The Repository Completeness Gate exists
because every developer should be able to clone and build.

## CI integration (future)

This checklist should be encoded as a CI workflow that runs on every
push to `main`. Required jobs:

- `fresh-clone-build-web`
- `fresh-clone-build-apk`
- `fresh-clone-analyze`
- `fresh-clone-test`

Until CI integration lands, this document is the manual gate.

## Related documents

- `docs/RECOVERY_INVENTORY.md` — Sprint 1 inventory.
- `docs/RECOVERY_PHASE_B.md` — Sprint 1 classification.
- `docs/RECOVERY_VERIFICATION_LOG.md` — Sprint 1 verification gates.
- `docs/SPRINT_1_FINAL_VERIFICATION.md` — Sprint 1 final gate.
- `tools/knowledge_migration/README.md` — migration tool.
