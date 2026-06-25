---
name: continia-document-capture
description: Use when working with Continia Document Capture in Business Central. Also use when asked about AP automation, invoice recognition, Continia approval workflows, G/L account suggestion, vendor matching, or how Document Capture changes the standard purchase invoice process.
---

# Continia Document Capture

Continia Document Capture is an AP automation solution for Business Central. It handles incoming documents (primarily purchase invoices) via OCR recognition, G/L account suggestion, and a configurable approval workflow — replacing the standard manual purchase invoice entry process.

Source: https://docs.continia.com/document-capture/

---

## When Document Capture is installed — change the solution design

If Continia Document Capture is installed:
- **Purchase invoice processing** → goes through Document Capture, not standard BC purchase journals or purchase invoices entered manually
- **Approval workflows** → Document Capture has its own approval engine — do not set up standard BC approval workflows for purchase invoices
- **G/L account coding** → Document Capture suggests accounts based on learned patterns — customise via Document Capture setup, not via standard BC posting groups alone

Never design a purchase invoice process that bypasses Document Capture on a project where it is installed.

---

## Architecture

```
Incoming document (email / scan / file)
  ↓
Document Capture Inbox (CDC Incoming Document)
  ↓
OCR Recognition (cloud or on-prem)
  ↓
CDC Document (header + lines recognised)
  ↓
Approval Workflow (CDC Approval)
  ↓
BC Purchase Invoice (standard BC from here)
  ↓
Post
```

Key tables:
| Table | Description |
|---|---|
| `CDC Incoming Document` | Raw document before recognition |
| `CDC Document` | Recognised document with fields and lines |
| `CDC Document Line` | Recognised line items |
| `CDC Approval Entry` | Approval workflow entries |
| `CDC Template` | Recognition templates per vendor or document type |

---

## Recognition and matching

Document Capture uses **templates** to recognise fields from documents:

- **Vendor matching** — matches by VAT registration number, IBAN, or vendor name
- **G/L account suggestion** — learns from historical postings per vendor and line description
- **Purchase order matching** — can match recognised lines to open purchase orders automatically

Templates are configured in the Document Capture setup and are vendor-specific or generic fallbacks.

---

## Approval workflow

Document Capture has its own approval workflow that runs **before** the document becomes a BC purchase invoice:

- Approval is configured in `CDC Approval Setup`
- Approvers can be assigned by amount, G/L account, department, or custom rules
- The document is not posted to BC until fully approved
- Approvers can approve via BC client or email (with Document Capture email approval)

**Important:** Do not configure standard BC approval workflows for purchase invoices on projects with Document Capture — they conflict.

---

## Integration with standard BC

Document Capture creates standard BC purchase invoices/credit memos when approved. From that point:
- Standard BC posting routines apply
- Standard BC posting groups and G/L setup apply
- Standard BC audit trail applies

Custom fields added to `Purchase Header` or `Purchase Line` via table extensions are **not** automatically populated by Document Capture — you must subscribe to Document Capture events to transfer custom fields.

### Key events for customisation

```al
// Subscribe to transfer custom fields from CDC Document to Purchase Header
[EventSubscriber(ObjectType::Codeunit, Codeunit::"CDC Purch. Doc.-Register",
    'OnBeforeInsertPurchaseHeader', '', false, false)]
local procedure TransferCustomFieldsOnBeforeInsertPurchaseHeader(
    var PurchaseHeader: Record "Purchase Header";
    CDCDocument: Record "CDC Document")
begin
    PurchaseHeader."My Custom Field" := CDCDocument."My Custom Field";
end;
```

---

## Implementation checklist for Document Capture setup

1. Configure `CDC Setup` — OCR service, document types, approval rules
2. Create vendor templates or use auto-recognition
3. Configure approval workflow in `CDC Approval Setup`
4. Set up email inbox (if using email-based document intake)
5. Train G/L account suggestions on historical data
6. Test with sample invoices end-to-end
7. Train users on the Document Capture inbox and approval process

---

## Common gotchas

- **Duplicate invoices**: Document Capture checks for duplicates by vendor + invoice number — ensure vendor cards have correct external document number setup
- **Credit memos**: Document Capture handles credit memos separately — configure `CDC Document Type` setup
- **Custom fields**: Must be explicitly transferred via events (see above)
- **PO matching**: Purchase order matching requires PO numbers to appear on the incoming document — not always reliable

---

## Further reading

- Continia Document Capture docs: https://docs.continia.com/document-capture/
- Continia community: https://community.continia.com/
