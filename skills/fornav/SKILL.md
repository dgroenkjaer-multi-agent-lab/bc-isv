---
name: fornav
description: Use when working with ForNAV reports or document layouts in Business Central. Also use when asked about ForNAV data items, expressions, report design, dataset structure, or how ForNAV integrates with BC standard reports and report selections.
---

# ForNAV

ForNAV is a report designer for Business Central that replaces RDLC. It uses a drag-and-drop designer and its own expression language, and integrates tightly with BC's report selection and report extension model.

Source: https://docs.fornav.com/

---

## When ForNAV is installed — change the solution design

If ForNAV is installed on a project:
- **All new document layouts** (invoices, order confirmations, reminders, etc.) → ForNAV, not RDLC
- **Existing RDLC reports** → migrate to ForNAV when touching them
- **Report extensions** → ForNAV has its own extension model — check ForNAV docs before using standard BC report extensions

Never create a new RDLC layout on a project that has ForNAV.

---

## Architecture

ForNAV consists of:

| Component | Description |
|---|---|
| **ForNAV Designer** | VS Code extension for designing `.fornav` layout files |
| **ForNAV Converter** | Converts existing RDLC reports to ForNAV format |
| **ForNAV Runtime** | BC extension that renders ForNAV layouts |
| **ForNAV Report Pack** | Pre-built layouts for standard BC documents |

The `.fornav` file is a JSON-based layout file committed to the AL project alongside the report object.

---

## Report structure

A ForNAV report mirrors BC's standard report structure:

```
Report
  └── DataSet
        ├── DataItem: Header table (e.g. Sales Invoice Header)
        │     └── DataItem: Lines table (e.g. Sales Invoice Line)
        └── DataItem: Company Information (for logo, address)
```

**Key difference from RDLC:** ForNAV uses a visual band-based layout (Header band, Body band, Footer band, Group bands) rather than a tablix/matrix model.

---

## Expression language

ForNAV uses its own expression language — a mix of VBA-like syntax and BC field references.

```
// Field reference
[Sales Invoice Header]."Sell-to Customer Name"

// Conditional
IIF([Sales Invoice Header].Amount > 1000, "Large order", "Standard order")

// Formatting
FORMAT([Sales Invoice Header]."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>')

// Running total
RUNNINGSUM([Sales Invoice Line].Amount)
```

---

## BC integration points

### Report Selection

ForNAV layouts are assigned via **Report Selection** (standard BC) — same setup as RDLC. The report object ID stays the same; only the layout changes.

### Report Extensions

To add fields from a custom table extension to a ForNAV layout:
1. Create a standard BC report extension that adds the fields to the dataset
2. ForNAV picks up the extended dataset automatically in the designer

### Events

ForNAV exposes events for customising output:
- `OnBeforePrintDocument` — modify data before rendering
- `OnAfterPrintDocument` — post-processing

---

## Implementation checklist for a new document layout

1. Identify the source report (e.g. `1306 "Standard Sales - Invoice"`)
2. Open ForNAV Designer in VS Code
3. Create a new `.fornav` file linked to the report object
4. Build the dataset: header DataItem → lines DataItem → totals
5. Design bands: page header, document header, body (lines), totals, page footer
6. Add company logo via `Company Information` DataItem
7. Test with ForNAV preview in VS Code
8. Assign via Report Selection in BC

---

## Common gotchas

- **Page numbering**: ForNAV's `PAGE()` and `PAGES()` functions work differently from RDLC — test multi-page documents carefully
- **Translations**: ForNAV layouts support captions from BC's translation system — use `[Field Caption]` references rather than hardcoded strings
- **PDF output**: ForNAV generates PDF natively — no dependency on SSRS or Word

---

## Further reading

- ForNAV documentation: https://docs.fornav.com/
- ForNAV community: https://community.fornav.com/
