# Getting Started — bc-isv

This file tells an opencode agent exactly how to activate ISV product knowledge for a project. Just point the agent here and say "set this up for me".

---

## Philosophy — what belongs where

| This repo (`bc-isv`) | Project `AGENTS.md` |
|---|---|
| Universal knowledge about ISV products | Which ISV products are licensed on this project |
| ForNAV architecture, data items, expression language | ForNAV version, license type, template locations |
| Continia Document Capture flow and configuration | Which Continia modules are active, configured approval flows |
| How ISV products integrate with BC standard | Customer-specific ISV configuration decisions |

---

## Repo structure

```
bc-isv/
  GETTING-STARTED.md                      ← you are here
  AGENTS.md                               ← always-active: consider ISVs in solution design
  CHANGELOG.md                            ← automatically updated on every commit
  VERSION                                 ← current template version
  hooks/pre-commit                        ← git hook for auto-versioning
  scripts/
    bump-version.ps1                      ← bumps VERSION and CHANGELOG
    install-hooks.ps1                     ← installs pre-commit hook locally
  skills/
    fornav/
      SKILL.md                            ← ForNAV report designer
    continia-document-capture/
      SKILL.md                            ← Continia Document Capture
  agents/
    bc-fornav.md                          ← ForNAV specialist agent
    bc-continia.md                        ← Continia specialist agent
```

---

## Setup instructions for opencode agent

When a user points you to this file and asks to set up ISV knowledge, do the following:

### Step 1 — Clone the template repo to a temp location

```powershell
$tempPath = "C:\Users\$env:USERNAME\AppData\Local\Temp\bc-isv-template"
if (Test-Path $tempPath) { Remove-Item -Recurse -Force $tempPath }
git clone https://github.com/dgroenkjaer-multi-agent-lab/bc-isv $tempPath --depth 1
```

### Step 2 — Ask which ISV products are in scope

Ask the user before copying anything:

> "Which ISV products are in use on this project? Available: **ForNAV**, **Continia Document Capture**. You can select multiple."

Only copy skills and agents for the selected products.

### Step 3 — Copy selected files into the project

```powershell
$projectRoot = (Get-Location).Path

function Copy-IfMissing([string]$src, [string]$dst) {
    if (Test-Path $dst) {
        Write-Host "  [skip] $($dst.Replace($projectRoot, ''))" -ForegroundColor DarkGray
    } else {
        New-Item -ItemType Directory -Force (Split-Path $dst -Parent) | Out-Null
        Copy-Item $src $dst
        Write-Host "  [add]  $($dst.Replace($projectRoot, ''))" -ForegroundColor Green
    }
}

# Always copy AGENTS.md base
Copy-IfMissing "$tempPath\AGENTS.md" "$projectRoot\.opencode\bc-isv-base.md"

# ForNAV — only if selected
Copy-IfMissing "$tempPath\skills\fornav\SKILL.md"   "$projectRoot\.opencode\skills\fornav\SKILL.md"
Copy-IfMissing "$tempPath\agents\bc-fornav.md"       "$projectRoot\.opencode\agents\bc-fornav.md"

# Continia Document Capture — only if selected
Copy-IfMissing "$tempPath\skills\continia-document-capture\SKILL.md" "$projectRoot\.opencode\skills\continia-document-capture\SKILL.md"
Copy-IfMissing "$tempPath\agents\bc-continia.md"     "$projectRoot\.opencode\agents\bc-continia.md"

# VERSION — always overwrite
Copy-Item "$tempPath\VERSION" "$projectRoot\.opencode\bc-isv-version.txt" -Force
Write-Host "  [set]  .opencode/bc-isv-version.txt → $(Get-Content $tempPath\VERSION)" -ForegroundColor Cyan
```

### Step 4 — Register in opencode.json

Add or merge into `.opencode/opencode.json`:

```json
{
  "skills": {
    "paths": [".opencode/skills"]
  },
  "instructions": [
    ".opencode/bc-isv-base.md"
  ]
}
```

**Append — do not overwrite existing entries.**

### Step 5 — Clean up and confirm

```powershell
Remove-Item -Recurse -Force $tempPath
```

Tell the user:
- Which skills and agents were added
- That `bc-isv-base.md` should be updated with project-specific ISV details (versions, licensed modules)
- That opencode must be **restarted** for changes to take effect

### Step 6 — Update bc-isv-base.md with project specifics

After setup, update `.opencode/bc-isv-base.md` to note which ISV products are installed and any relevant version or configuration details.

---

## Checking for updates

When a user asks "is my bc-isv template up to date?":

```powershell
$projectVersion = Get-Content ".opencode\bc-isv-version.txt" -ErrorAction SilentlyContinue
$tempPath = "C:\Users\$env:USERNAME\AppData\Local\Temp\bc-isv-template"
if (Test-Path $tempPath) { Remove-Item -Recurse -Force $tempPath }
git clone https://github.com/dgroenkjaer-multi-agent-lab/bc-isv $tempPath --depth 1 2>$null
$latestVersion = Get-Content "$tempPath\VERSION"
```

Show CHANGELOG entries newer than current version. If up to date, say so. If update confirmed, run `Copy-IfMissing` again and overwrite VERSION file.

---

## Maintaining this repo — automatic versioning

### One-time setup after cloning

```powershell
pwsh scripts/install-hooks.ps1
```

Every commit automatically bumps VERSION (patch) and prepends an entry to CHANGELOG.md.
Use manual invocation with `-CommitMessage "feat: ..."` for a minor bump.

---

## Adding a new ISV product

1. Create `skills/<isv-name>/SKILL.md`
2. Optionally create `agents/bc-<isv-name>.md`
3. Add the ISV to the table in `README.md`
4. Add it to the selection list in Step 2 of this file
5. Commit — the hook bumps the version automatically
