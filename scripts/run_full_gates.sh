#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# scripts/run_full_gates.sh
#
# Engineering Gate — runs all four required gates in order:
#   1. flutter analyze
#   2. critical suite (Tier 1 tests)
#   3. flutter build web --release
#   4. flutter build apk --debug
#
# A failure in any gate stops the run. Used for sprint close and
# release verification. NOT for every-PR (use the lighter critical
# suite script for that).
#
# Usage:
#   ./scripts/run_full_gates.sh
#   ./scripts/run_full_gates.sh --skip-web
#   ./scripts/run_full_gates.sh --skip-apk
#   ./scripts/run_full_gates.sh --skip-build
#
# Exit codes:
#   0  all gates passed
#   non-zero  first failing gate (echoed to stdout)
# -----------------------------------------------------------------------------

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# --- Parse args -------------------------------------------------------------
SKIP_WEB=0
SKIP_APK=0
SKIP_BUILD=0
for arg in "$@"; do
  case "$arg" in
    --skip-web)            SKIP_WEB=1;;
    --skip-apk)            SKIP_APK=1;;
    --skip-build)          SKIP_BUILD=1; SKIP_WEB=1; SKIP_APK=1;;
    -h|--help)
      echo "Usage: $0 [--skip-web] [--skip-apk] [--skip-build]"
      echo "  --skip-web   skip flutter build web"
      echo "  --skip-apk   skip flutter build apk"
      echo "  --skip-build skip both builds (run analyze + tests only)"
      exit 0
      ;;
  esac
done

# --- Pre-flight ------------------------------------------------------------
if ! command -v flutter >/dev/null 2>&1; then
  echo "[fatal] flutter is not on PATH." >&2
  exit 2
fi

banner() {
  echo ""
  echo "============================================================"
  echo "  $1"
  echo "============================================================"
}

run_gate() {
  local name="$1"; shift
  banner "$name"
  "$@"
  local status=$?
  if [ $status -eq 0 ]; then
    echo ""
    echo "[PASS] $name"
  else
    echo ""
    echo "[FAIL] $name (exit $status)"
  fi
  return $status
}

# --- Gate 1: static analysis ------------------------------------------------
banner "Gate 1 / 4 — flutter analyze"
flutter analyze
g1=$?
if [ $g1 -ne 0 ]; then
  echo "[FAIL] Gate 1 (flutter analyze) — exit $g1"
  exit $g1
fi
echo "[PASS] Gate 1 (flutter analyze)"

# --- Gate 2: critical suite -------------------------------------------------
banner "Gate 2 / 4 — Critical Suite"
"$SCRIPT_DIR/run_critical_suite.sh" --reporter compact
g2=$?
if [ $g2 -ne 0 ]; then
  echo "[FAIL] Gate 2 (Critical Suite) — exit $g2"
  exit $g2
fi
echo "[PASS] Gate 2 (Critical Suite)"

# --- Gate 3: web build ------------------------------------------------------
if [ $SKIP_WEB -eq 0 ]; then
  banner "Gate 3 / 4 — flutter build web --release"
  flutter build web --release
  g3=$?
  if [ $g3 -ne 0 ]; then
    echo "[FAIL] Gate 3 (flutter build web) — exit $g3"
    exit $g3
  fi
  echo "[PASS] Gate 3 (flutter build web)"
else
  echo "[SKIP] Gate 3 (flutter build web) — per --skip-web"
fi

# --- Gate 4: apk build ------------------------------------------------------
if [ $SKIP_APK -eq 0 ]; then
  banner "Gate 4 / 4 — flutter build apk --debug"
  flutter build apk --debug
  g4=$?
  if [ $g4 -ne 0 ]; then
    echo "[FAIL] Gate 4 (flutter build apk) — exit $g4"
    exit $g4
  fi
  echo "[PASS] Gate 4 (flutter build apk)"
else
  echo "[SKIP] Gate 4 (flutter build apk) — per --skip-apk"
fi

# --- Summary ----------------------------------------------------------------
banner "Engineering Gate — Summary"
echo "Gate 1 (flutter analyze):    PASS"
echo "Gate 2 (Critical Suite):     PASS"
[ $SKIP_WEB -eq 0 ] && echo "Gate 3 (build web):          PASS" || echo "Gate 3 (build web):          SKIPPED"
[ $SKIP_APK -eq 0 ] && echo "Gate 4 (build apk):          PASS" || echo "Gate 4 (build apk):          SKIPPED"
echo ""
echo "All required gates passed."
exit 0