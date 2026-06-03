# Detailed Design Document

## Executive Summary
This detailed design document explains how the Balance Sheet based ledger system will be built for a small-scale industry using Indian accounting practices. It includes frontend and backend design, database validation, authentication flows, notifications, deployment, and compliance features.

## Core Functional Requirements
- Maintain a ledger with Debit and Credit entries.
- Provide a Balance Sheet reflecting Assets, Liabilities, Capital & Reserves, Income, and Expenditure.
- Support role-based access for Admin, Accountant, Auditor, and Viewer.
- Provide automated alerts for ledger updates, approvals, and compliance deadlines.
- Store all financial records securely with audit logging.

## Frontend Design

### Flutter App Structure
- `lib/main.dart`
- `lib/blocs/` for business logic components.
- `lib/models/` for ledger, balance sheet, user, and notification models.
- `lib/screens/` for dashboard, ledger entry, balance sheet report, audit log, and settings.
- `lib/routes/` using GoRouter for navigation.
- `lib/services/` for API client, authentication, and Firebase messaging.

### UI and UX
- Clear Indian-style ledger tables with Debit and Credit columns.
- Summary cards for assets, liabilities, capital, income, and expenses.
- Compliance alerts displayed prominently.
- Approval workflow UI for pending ledger entries.

## Backend Design

### Service Modules
- `src/modules/ledger/ledger.service.ts`
- `src/modules/balance-sheet/balance-sheet.service.ts`
- `src/modules/auth/auth.service.ts`
- `src/modules/notifications/notification.service.ts`
- `src/modules/audit/audit.service.ts`

### API Contracts
- Use JSON REST API with secure authentication.
- Standard response fields: `success`, `data`, `error`, `message`.

### Example API Request
```
POST /api/ledger/entry
{
  "date": "2026-05-13",
  "particulars": "Sales invoice #S123",
  "debitAccount": "Bank",
  "creditAccount": "Sales",
  "amount": 120000,
  "narration": "Sale of finished goods",
  "gstApplicable": true,
  "gstDetails": {
    "hsnCode": "8409",
    "cgst": 9000,
    "sgst": 9000,
    "igst": 0
  }
}
```

### Data Encryption and Validation
- MongoDB schema validation to enforce required fields and types.
- AES-256 encryption for fields such as `passwordHash`, `refreshTokens`, and audit data where required.
- Use indexes for `userId`, `date`, and `role` for query performance.

## Database Schema Validation Rules
- `amount` must be a positive number.
- `debitAccount` and `creditAccount` must exist in the chart of accounts.
- `gstApplicable` must be boolean, and GST details must be present when true.
- `role` values restricted to `Admin`, `Accountant`, `Auditor`, `Viewer`.

## Authentication and Security
- Register and login flows use secure password hashing.
- Authentication tokens expire after a short period with refresh tokens for session continuity.
- RBAC enforced on every endpoint.
- Audit trail records each user action on ledger and compliance records.

## Notifications and Email
- Gmail App Password configured in environment variables.
- Automatic email alerts for:
  - New ledger entry creation.
  - Approval requests.
  - Compliance due date reminders.
- Firebase messaging for mobile/web push notifications.

## Deployment and Infrastructure

### Containerization
- Docker files for frontend, backend, and database.
- Use AWS ECS / EKS or AWS Fargate for hosting.
- VPC segmentation for application and database subnets.

### Security Infrastructure
- HTTPS only via TLS 1.3.
- AWS IAM roles for service access, least privilege.
- Logging to secure storage with rotation and retention.

### Backup and Compliance
- Daily automated backup schedule.
- Retention policy: 30 days for daily backups, 1 year for monthly archives.
- Secure logs and audit trail retention to meet Indian Companies Act requirements.
- GST-ready reports and audit logs to support compliance filings.

## Sample Ledger Table Format in Indian Standard English
| Particulars | Dr (₹) | Cr (₹) | Classification |
| --- | --- | --- | --- |
| Cash | 12,50,000 | | Current Asset |
| Bank | 8,00,000 | | Current Asset |
| Debtors | 6,20,000 | | Current Asset |
| Inventory | 4,60,000 | | Current Asset |
| Sales | | 60,00,000 | Income |
| Direct Expenses | 22,00,000 | | Expense |
| Taxes | 3,70,000 | | Expense |
| Owner's Capital | | 40,00,000 | Capital |

## Reporting and Audit
- Provide ledger reports, trial balance view, and balance sheet snapshots.
- Maintain a detailed audit trail of all financial entries with user, timestamp, and action.
- Generate compliance reports for GST, Companies Act, and internal review.
