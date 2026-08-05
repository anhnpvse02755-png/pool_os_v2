# -----------------------------------------------------------------------------
# scripts/run_critical_suite.ps1
#
# Windows PowerShell wrapper for the Critical Suite.
# Source of truth: test/CRITICAL_SUITE.md
# Constitution: docs/engineering-constitution.md Article 5
#
# Usage:
#   .\scripts\run_critical_suite.ps1              # default reporter
#   .\scripts\run_critical_suite.ps1 -Reporter expanded
#
# Exit codes:
#   0  all critical tests passed
#   1  one or more critical tests failed
#   2  script error (flutter missing, etc.)
# -----------------------------------------------------------------------------

[CmdletBinding()]
param(
    [ValidateSet('compact', 'expanded', 'github')]
    [string]$Reporter = 'compact'
)

$ErrorActionPreference = 'Stop'

# --- Resolve repo root from script location --------------------------------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = (Resolve-Path (Join-Path $ScriptDir '..')).Path
Set-Location $RepoRoot

# --- Pre-flight: flutter must be on PATH -----------------------------------
$flutter = (Get-Command flutter -ErrorAction SilentlyContinue)
if (-not $flutter) {
    Write-Host 'ERROR: flutter is not on PATH.' -ForegroundColor Red
    Write-Host '       Install Flutter or activate your environment first.' -ForegroundColor Red
    exit 2
}

# --- Pre-flight: pub get must already be done ------------------------------
if (-not (Test-Path '.dart_tool')) {
    Write-Host 'WARN: .dart_tool missing. Running "flutter pub get" first...' -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) { exit 2 }
}

# --- The Critical Suite — keep in sync with test/CRITICAL_SUITE.md --------
$CriticalTests = @(
    'test/knowledge_migration/pipeline_test.dart',
    'test/knowledge_migration/validators_test.dart',
    'test/knowledge_migration/mappers_test.dart',
    'test/knowledge_migration/cli_options_test.dart',
    'test/knowledge_runtime_loading_test.dart',
    'test/knowledge_article_count_test.dart',
    'test/personal_best_repository_test.dart',
    'test/streak_calculator_test.dart',
    'test/weekly_report_generator_test.dart',
    'test/coach_profile_aggregator_test.dart',
    'test/drill_session_recovery_test.dart',
    'test/equipment_repository_test.dart'
)

# --- Existence check -------------------------------------------------------
$missing = @()
foreach ($t in $CriticalTests) {
    if (-not (Test-Path $t)) { $missing += $t }
}
if ($missing.Count -gt 0) {
    Write-Host 'ERROR: the following Critical Suite files are missing:' -ForegroundColor Red
    foreach ($m in $missing) {
        Write-Host "  - $m" -ForegroundColor Red
    }
    Write-Host ''
    Write-Host 'Either restore the files or update test/CRITICAL_SUITE.md.' -ForegroundColor Red
    exit 2
}

# --- Header ----------------------------------------------------------------
Write-Host '============================================================'
Write-Host 'Critical Suite - Tier 1 business-rule tests'
Write-Host 'Manifest:  test/CRITICAL_SUITE.md'
Write-Host 'Runner:    scripts\run_critical_suite.ps1'
Write-Host "Reporter:  $Reporter"
Write-Host '============================================================'
Write-Host ''

# --- Run -------------------------------------------------------------------
Write-Host "Running $($CriticalTests.Count) critical test files..."
Write-Host ''

& flutter test --reporter=$Reporter @CriticalTests
$status = $LASTEXITCODE

Write-Host ''
Write-Host '============================================================'
if ($status -eq 0) {
    Write-Host 'Critical Suite: PASS' -ForegroundColor Green
} else {
    Write-Host "Critical Suite: FAIL ($status)" -ForegroundColor Red
}
Write-Host '============================================================'

exit $status