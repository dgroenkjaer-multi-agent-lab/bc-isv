<#
.SYNOPSIS
    Installs the bc-developer git hooks into the local .git/hooks directory.

.DESCRIPTION
    Run this once after cloning or pulling the bc-developer template repo.
    The hook automatically bumps VERSION and updates CHANGELOG.md on every commit.

.EXAMPLE
    pwsh scripts/install-hooks.ps1
#>

$ErrorActionPreference = "Stop"

$repoRoot  = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) { Write-Error "Not inside a git repo."; exit 1 }
$repoRoot  = $repoRoot.Trim()

$hooksDir  = Join-Path $repoRoot ".git\hooks"
$srcDir    = Join-Path $repoRoot "hooks"

if (-not (Test-Path $srcDir)) {
    Write-Error "hooks/ directory not found at $srcDir"
    exit 1
}

foreach ($hook in Get-ChildItem $srcDir -File) {
    $dst = Join-Path $hooksDir $hook.Name
    Copy-Item $hook.FullName $dst -Force

    # Make executable on Unix/macOS (no-op on Windows but harmless)
    if ($IsLinux -or $IsMacOS) {
        chmod +x $dst
    }

    Write-Host "  [ok] Installed hook: $($hook.Name)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Git hooks installed. Every commit to bc-developer will now automatically" -ForegroundColor Cyan
Write-Host "bump VERSION (patch) and prepend an entry to CHANGELOG.md." -ForegroundColor Cyan
Write-Host "Use 'feat:' prefix in your commit message to trigger a minor bump." -ForegroundColor Cyan
