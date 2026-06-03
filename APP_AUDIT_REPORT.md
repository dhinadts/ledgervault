# LedgerVault App Audit Report

## Executive Summary

The application is a ledger-first finance workflow for small businesses. It supports login, local bank account setup, employee-maintained ledger transactions, dashboard metrics, balance sheet views, reports, notifications, audit checklist preparation, Excel export, and WhatsApp sharing.

The app is strongest as an internal transaction register and reporting tool. Bank balances are now treated as master setup data entered by the employee, while transactions drive current balance and reporting changes.

## Current Application Coverage

- Authentication: JWT-based login/register flow with token storage on the Flutter side.
- Ledger: transaction entry, status updates, delete, filters, and status confirmation before save.
- Bank setup: local account details and starting/current balance capture.
- Dashboard: high-level cash, receivable, payable, recent transactions, and quick actions.
- Balance Sheet: transaction-reflected assets, liabilities, net worth, and bank-wise summaries.
- Reports: revenue, expense, profit/loss, GST payable, account-wise charts, and transaction table.
- Audit Checklist: readiness sections plus required document upload workflow.
- Export/Share: Excel-compatible multi-sheet workbook and WhatsApp summary sharing.

## Recent Fixes Implemented

- Removed frontend dependency on bank APIs.
- Added custom start date/time to end date/time filter in Balance Sheet.
- Added audit document upload API and frontend upload panel.
- Extended audit document picking to web, mobile, and desktop builds.
- Added Director review confirmation for this month, this quarter, and this year.
- Added GV/PV/SI voucher-prefix help dialog available globally across the app.
- Added JWT protection to secure API fetches.
- Added shimmer loading states to avoid false zero-value displays.
- Added Excel workbook export with Summary, Bank Balances, and Ledger Entries sheets.

## Key Risks

- Audit uploads are currently stored on server disk under `uploads/audit-documents`; this is acceptable for local/demo use but not durable on many cloud hosts.
- Director review confirmations are currently stored locally on the device/browser. Move them to backend audit logs before production.
- Balance sheet and reports depend on accurate ledger status values. Wrong status selection can affect receivables/payables.
- Local bank master data is device/browser-local. If the user changes browser/device, bank setup data may not follow unless later synced to a backend profile store.
- Prisma build may fail on Windows when the query engine DLL is locked by running Node processes.

## Recommended Functional Additions

- Add role-based permissions: Admin, Accountant, Auditor, Employee.
- Add transaction approval workflow before a ledger entry becomes final.
- Add document categories and expiry reminders for GST, invoices, agreements, bank statements, and audit evidence.
- Add immutable audit logs for status changes, deletes, exports, and document uploads.
- Add backend persistence for Director monthly/quarterly/yearly review confirmations.
- Add backend storage for bank master data only if multi-device continuity is required.
- Add voucher numbering and duplicate voucher detection.
- Add Excel import for ledger transactions.
- Add reconciliation screen comparing ledger-derived balance with uploaded bank statement closing balance.
- Add dashboard alert tiles for overdue receivables/payables.
- Add cloud object storage for audit documents, such as S3, Cloudinary, Firebase Storage, or Azure Blob.

## Suggested App Names

- LedgerVault
- AuditLedger
- BalanceDesk
- FinProof Ledger
- LedgerBridge
- AccountReady
- ClearBooks Audit
- Dhinadts LedgerPro

Recommended name: **LedgerVault**. It communicates secure transaction storage, audit readiness, and finance records without being too narrow.

## Priority Roadmap

1. Stabilize auth, ledger status audit logs, and document uploads.
2. Add role-based access and approval workflow.
3. Move audit documents to durable cloud storage.
4. Add bank statement import and reconciliation.
5. Add production-grade backup, monitoring, and export history.
