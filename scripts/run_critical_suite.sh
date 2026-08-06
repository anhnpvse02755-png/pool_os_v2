#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# scripts/run_critical_suite.sh
#
# Runs the Critical Suite — the Tier 1 tests that gate every release.
# Source of truth: test/CRITICAL_SUITE.md
# Constitution: docs/engineering-constitution.md Article 5
#
# Usage:
#   ./scripts/run_critical_suite.sh              # run all
#   ./scripts/run_critical_suite.sh --reporter expanded
#
# Exit codes:
#   0  all critical tests passed
#   1  one or more critical tests failed
#   2  script error (flutter missing, etc.)
# -----------------------------------------------------------------------------

set -uo pipefail

# --- Resolve repo root from script location ---------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# --- Pre-flight: flutter must be on PATH ------------------------------------
if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter is not on PATH." >&2
  echo "       Install Flutter or activate your environment first." >&2
  exit 2
fi

# --- Pre-flight: pub get must already be done -------------------------------
if [ ! -d ".dart_tool" ]; then
  echo "WARN: .dart_tool missing. Running 'flutter pub get' first..." >&2
  flutter pub get
fi

# --- The Critical Suite — keep in sync with test/CRITICAL_SUITE.md ----------
CRITICAL_TESTS=(
  "test/knowledge_migration/pipeline_test.dart"
  "test/knowledge_migration/validators_test.dart"
  "test/knowledge_migration/mappers_test.dart"
  "test/knowledge_migration/cli_options_test.dart"
  "test/knowledge_runtime_loading_test.dart"
  "test/knowledge_article_count_test.dart"
  "test/personal_best_repository_test.dart"
  "test/streak_calculator_test.dart"
  "test/weekly_report_generator_test.dart"
  "test/coach_profile_aggregator_test.dart"
  "test/drill_session_recovery_test.dart"
  "test/equipment_repository_test.dart"
  "test/match_repository_test.dart"
  "test/drill_attempt_repository_test.dart"
)

# --- Parse args -------------------------------------------------------------
REPORTER="compact"
for arg in "$@"; do
  case "$arg" in
    --reporter)       shift; REPORTER="${1:-compact}";;
    --reporter=*)     REPORTER="${arg#*=}";;
    -h|--help)
      echo "Usage: $0 [--reporter <compact|expanded|github>]"
      exit 0
      ;;
  esac
done

# --- Header -----------------------------------------------------------------
echo "============================================================"
echo "Critical Suite — Tier 1 business-rule tests"
echo "Manifest:  test/CRITICAL_SUITE.md"
echo "Runner:    scripts/run_critical_suite.sh"
echo "Reporter:  $REPORTER"
echo "============================================================"
echo ""

# --- Existence check --------------------------------------------------------
missing=()
for t in "${CRITICAL_TESTS[@]}"; do
  if [ ! -f "$t" ]; then
    missing+=("$t")
  fi
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "ERROR: the following Critical Suite files are missing:" >&2
  for m in "${missing[@]}"; do
    echo "  - $m" >&2
  done
  echo "" >&2
  echo "Either restore the files or update test/CRITICAL_SUITE.md." >&2
  exit 2
fi

# --- Run --------------------------------------------------------------------
echo "Running ${#CRITICAL_TESTS[@]} critical test files..."
echo ""

set +e
flutter test \
  --reporter="$REPORTER" \
  "${CRITICAL_TESTS[@]}"
status=$?
set -e

echo ""
echo "============================================================"
if [ $status -eq 0 ]; then
  echo "Critical Suite: PASS"
else
  echo "Critical Suite: FAIL ($status)"
fi
echo "============================================================"

exit $status
