# bc-isv

opencode skills and agents for Business Central ISV products.

## Purpose

This repo contains domain knowledge for third-party ISV products commonly used with Business Central. Each ISV product has its own skill and/or agent. Copy only the skills relevant to your project.

**This repo** → universal ISV product knowledge (architecture, integration points, implementation patterns)  
**Project `AGENTS.md`** → project-specific: which ISV modules are licensed, version, customer-specific configuration

## Getting started on a new project

Open the project in opencode and say:

> "Set up ISV knowledge for this project. See https://github.com/dgroenkjaer-multi-agent-lab/bc-isv-template/blob/main/GETTING-STARTED.md"

The agent will ask which ISV products are in scope and copy only the relevant skills.

## Available ISV skills

| ISV | Skill | Agent | Description |
|---|---|---|---|
| ForNAV | `skills/fornav/` | `agents/bc-fornav.md` | Report designer replacing RDLC — layouts, data items, expressions |
| Continia Document Capture | `skills/continia-document-capture/` | `agents/bc-continia.md` | AP automation — invoice recognition, approval workflows, G/L account suggestion |

## Contributing

When you work with a new ISV product, add a skill for it and push. The pre-commit hook bumps the version automatically.

### One-time setup after cloning

```powershell
pwsh scripts/install-hooks.ps1
```
