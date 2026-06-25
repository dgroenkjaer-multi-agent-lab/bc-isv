# BC ISV — AGENTS.md

Core domain knowledge about ISV products used with Business Central.
This file is always active — it reminds the agent to consider ISV products when relevant.

## ISV Products in Scope

> This section should be updated in the project's `.opencode/bc-isv-base.md` to reflect which ISV products are actually installed on this project.

## General Principle: ISV Products Change the Solution Design

Before designing a solution, check whether an ISV product already handles the requirement — or changes how it should be implemented. Common examples:

- **ForNAV installed** → use ForNAV for all new reports and document layouts, not RDLC
- **Continia Document Capture installed** → purchase invoice processing goes through Continia, not standard BC purchase journals
- **Continia Expense Management installed** → employee expense handling goes through Continia, not standard expense journals

Never design around standard BC when an ISV product is in scope and covers the requirement.

## Sources for ISV Documentation

- ForNAV: https://www.fornav.com/ and https://docs.fornav.com/
- Continia: https://www.continia.com/ and https://docs.continia.com/
- Use `microsoft.docs.mcp` for BC integration points (events, interfaces, posting routines)
