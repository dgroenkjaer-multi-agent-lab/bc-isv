<#
.SYNOPSIS
    Bumps the patch version in VERSION and prepends an entry to CHANGELOG.md.

.DESCRIPTION
    Called automatically by the pre-commit hook when staged files include
    anything outside .git/, scripts/bump-version.ps1, or VERSION/CHANGELOG.md.

    Pass -CommitMessage to include a meaningful description in the changelog.
    If not passed, the script reads the first staged file list as a summary.

.PARAMETER CommitMessage
    Optional. Used as the changelog description. If omitted, a summary of
    staged files is generated automatically.

.PARAMETER Force
    Skip the "nothing to bump" guard and always bump.
#>
param(
    [string]$CommitMessage = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) { Write-Error "Not inside a git repo."; exit 1 }
$repoRoot = $repoRoot.Trim()

$versionFile   = Join-Path $repoRoot "VERSION"
$changelogFile = Join-Path $repoRoot "CHANGELOG.md"

# ── Read current version ─────────────────────────────────────────────────────
$current = (Get-Content $versionFile -Raw).Trim()
if ($current -notmatch '^\d+\.\d+\.\d+$') {
    Write-Error "VERSION file does not contain a valid semver: '$current'"
    exit 1
}
$parts = $current -split '\.'
$major = [int]$parts[0]
$minor = [int]$parts[1]
$patch = [int]$parts[2]

# ── Determine what changed ───────────────────────────────────────────────────
$staged = git diff --cached --name-only 2>$null | Where-Object {
    $_ -notmatch '^VERSION$' -and
    $_ -notmatch '^CHANGELOG\.md$' -and
    $_ -notmatch '^scripts/bump-version\.ps1$' -and
    $_ -notmatch '^\.git/'
}

if (-not $staged -and -not $Force) {
    Write-Host "  [bump] No relevant staged changes — skipping version bump." -ForegroundColor DarkGray
    exit 0
}

# ── Determine bump type from commit message ──────────────────────────────────
# Only bump minor when CommitMessage is explicitly passed with feat: prefix.
# The pre-commit hook never passes -CommitMessage, so hooks always do patch bumps.
# Use manual invocation with -CommitMessage "feat: ..." for minor bumps.
$newVersion = if ($CommitMessage -match '^(feat|feature):') {
    "$major.$($minor + 1).0"
} else {
    "$major.$minor.$($patch + 1)"
}

# ── Build changelog entry ────────────────────────────────────────────────────
$date = Get-Date -Format "yyyy-MM-dd"

if ($CommitMessage) {
    $description = $CommitMessage -replace '^(feat|feature|fix|refactor|docs|chore):\s*', ''
    $description = $description.Substring(0,1).ToUpper() + $description.Substring(1)
} else {
    $description = "Updated: " + ($staged -join ', ')
}

# Group staged files by type
$added    = git diff --cached --name-only --diff-filter=A 2>$null | Where-Object { $_ -notmatch '^(VERSION|CHANGELOG\.md)$' }
$modified = git diff --cached --name-only --diff-filter=M 2>$null | Where-Object { $_ -notmatch '^(VERSION|CHANGELOG\.md)$' }
$deleted  = git diff --cached --name-only --diff-filter=D 2>$null | Where-Object { $_ -notmatch '^(VERSION|CHANGELOG\.md)$' }

$entry = "## v$newVersion — $date`n`n"
if ($CommitMessage) { $entry += "$description`n`n" }
if ($added)    { $entry += "### Added`n" + ($added    | ForEach-Object { "- ``$_``" } | Join-String -Separator "`n") + "`n`n" }
if ($modified) { $entry += "### Changed`n" + ($modified | ForEach-Object { "- ``$_``" } | Join-String -Separator "`n") + "`n`n" }
if ($deleted)  { $entry += "### Removed`n" + ($deleted  | ForEach-Object { "- ``$_``" } | Join-String -Separator "`n") + "`n`n" }
if (-not $added -and -not $modified -and -not $deleted -and $CommitMessage) {
    $entry += "### Changed`n- $description`n`n"
}
$entry += "---`n`n"

# ── Write VERSION ─────────────────────────────────────────────────────────────
Set-Content $versionFile $newVersion -NoNewline

# ── Prepend to CHANGELOG.md ──────────────────────────────────────────────────
$existing = if (Test-Path $changelogFile) { Get-Content $changelogFile -Raw } else { "" }

# Remove the top-level heading if present so we can re-add it cleanly
$body = $existing -replace '^# bc-developer Changelog\s*\n+', ''
Set-Content $changelogFile "# bc-developer Changelog`n`n$entry$body" -NoNewline

# ── Stage the updated files ──────────────────────────────────────────────────
git add $versionFile $changelogFile

Write-Host "  [bump] $current → $newVersion" -ForegroundColor Cyan
Write-Host "  [bump] CHANGELOG.md updated" -ForegroundColor Cyan
