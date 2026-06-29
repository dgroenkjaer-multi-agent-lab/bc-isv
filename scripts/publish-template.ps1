<#
.SYNOPSIS
    Publishes the bc-isv template to the public distribution repo.

.DESCRIPTION
    Copies the distributable files (skills, agents, AGENTS.md,
    GETTING-STARTED.md, VERSION, CHANGELOG.md) to a clean clone of
    the public bc-isv-template repo and pushes a new commit.

    Internal maintenance files (hooks/, scripts/bump-version.ps1,
    scripts/install-hooks.ps1) are intentionally excluded.

.PARAMETER Message
    Optional commit message for the public repo. Defaults to
    "release: sync from bc-developer v<VERSION>".

.EXAMPLE
    pwsh scripts/publish-template.ps1

.EXAMPLE
    pwsh scripts/publish-template.ps1 -Message "release: add bc-al-performance skill"
#>
param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"

$repoRoot   = (git rev-parse --show-toplevel 2>$null).Trim()
$version    = (Get-Content "$repoRoot\VERSION" -Raw).Trim()
$publicRepo = "https://github.com/dgroenkjaer-multi-agent-lab/bc-isv-template"
$tempPath   = "$env:TEMP\bc-isv-template-publish"
$commitMsg  = if ($Message) { $Message } else { "release: sync from bc-isv v$version" }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Publish bc-isv-template" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Version : $version" -ForegroundColor White
Write-Host " Target  : $publicRepo" -ForegroundColor White
Write-Host " Message : $commitMsg" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

# ── Clone public repo ─────────────────────────────────────────────────────────
Write-Host ">> Cloning public repo..." -ForegroundColor Cyan
if (Test-Path $tempPath) { Remove-Item -Recurse -Force $tempPath }
git clone $publicRepo $tempPath --depth 1 2>&1 | Out-Null
Write-Host "   done" -ForegroundColor Green

# ── Clear existing content (except .git) ─────────────────────────────────────
Write-Host ">> Clearing existing content..." -ForegroundColor Cyan
Get-ChildItem $tempPath | Where-Object { $_.Name -ne '.git' } |
    Remove-Item -Recurse -Force
Write-Host "   done" -ForegroundColor Green

# ── Files to include ──────────────────────────────────────────────────────────
$include = @(
    "AGENTS.md",
    "CHANGELOG.md",
    "GETTING-STARTED.md",
    "README.md",
    "VERSION"
)

$includeDirs = @(
    "agents",
    "skills"
)

# bc-isv has no project-facing scripts
$includeScripts = @()

# ── Copy files ────────────────────────────────────────────────────────────────
Write-Host ">> Copying files..." -ForegroundColor Cyan

foreach ($file in $include) {
    $src = Join-Path $repoRoot $file
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $tempPath $file)
        Write-Host "  [copy] $file" -ForegroundColor DarkGray
    }
}

foreach ($dir in $includeDirs) {
    $src = Join-Path $repoRoot $dir
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $tempPath $dir) -Recurse
        $count = (Get-ChildItem $src -Recurse -File).Count
        Write-Host "  [copy] $dir/ ($count files)" -ForegroundColor DarkGray
    }
}

New-Item -ItemType Directory -Force "$tempPath\scripts" | Out-Null
foreach ($script in $includeScripts) {
    $src = Join-Path $repoRoot $script
    $dst = Join-Path $tempPath $script
    if (Test-Path $src) {
        Copy-Item $src $dst
        Write-Host "  [copy] $script" -ForegroundColor DarkGray
    }
}

Write-Host "   done" -ForegroundColor Green

# ── Commit and push ───────────────────────────────────────────────────────────
Write-Host ">> Committing and pushing..." -ForegroundColor Cyan
git -C $tempPath add . 2>&1 | Out-Null

$status = git -C $tempPath status --porcelain
if (-not $status) {
    Write-Host "   Nothing changed — public repo is already up to date." -ForegroundColor Yellow
} else {
    git -C $tempPath commit -m $commitMsg 2>&1 | Out-Null
    git -C $tempPath push 2>&1 | Out-Null
    Write-Host "   Pushed to $publicRepo" -ForegroundColor Green
}

# ── Clean up ──────────────────────────────────────────────────────────────────
Remove-Item -Recurse -Force $tempPath

Write-Host ""
Write-Host "Done. Public template is now at v$version." -ForegroundColor Green
Write-Host "Share this URL with colleagues:" -ForegroundColor White
Write-Host "  $publicRepo/blob/main/GETTING-STARTED.md" -ForegroundColor Cyan
Write-Host ""
