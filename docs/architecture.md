# Balance Sheet Ledger Architecture

## Overview
This document defines a Balance Sheet based ledger system for a small-scale industry, using Indian accounting terminology and standards.

The solution is split into three main layers:
- Frontend: Flutter app with BLoC state management, GoRouter navigation, Firebase integration.
- Backend: Service-oriented Node.js API with separate modules for Ledger, Balance Sheet, Authentication, Notifications.
- Database: MongoDB with schema validation, encryption at rest, and audit trails.

## Business Scope
The ledger supports:
- Assets: Current Assets (Cash, Bank, Debtors, Inventory) and Fixed Assets (Plant, Machinery, Furniture, Land & Building).
- Liabilities: Current Liabilities (Creditors, Short-term Loans) and Long-term Liabilities (Secured Loans, Unsecured Loans).
- Capital & Reserves: Owner's Capital, Retained Earnings, Reserves.
- Income & Expenditure: Sales, Other Income, Direct Expenses, Indirect Expenses, Depreciation, Taxes.

## Architecture Layers

### 1. Presentation Layer (Frontend)
- Flutter mobile/web application.
- BLoC for predictable state management of ledger entries, balance sheet, approvals, and notifications.
- GoRouter for route-based navigation between dashboards, ledger entry forms, compliance alerts, and reports.
- Firebase for push notifications, authentication token refresh tracking, and email event triggers.

### 2. Service Layer (Backend)
- Modular service-oriented APIs:
  - `Ledger Service`
  - `Balance Sheet Service`
  - `Authentication Service`
  - `Notification Service`
- Each service exposes RESTful endpoints and validates requests.
- Strong error handling and structured logging at service boundaries.

### 3. Database Layer
- MongoDB with strict schema validation for financial records.
- AES-256 encryption for sensitive fields at rest.
- Audit trails for all changes to financial entries.

## Security and Compliance
- JWT-based authentication with refresh tokens.
- Role-based access control (RBAC): Admin, Accountant, Auditor, Viewer.
- Secure password storage with bcrypt/argon2.
- Email integration through Gmail App Password for alerts and approvals.
- AWS hosting with VPC isolation, IAM roles, and TLS 1.3.
- Compliance aligned to Indian Companies Act and GST norms.

## Deployment and Infrastructure
- Docker containers for frontend, backend, and database.
- CI/CD pipeline for safe, automated updates.
- Daily backups, secure log rotation, and retention policies.

## Sample Balance Sheet Ledger Table
| Particulars | Debit (₹) | Credit (₹) | Notes |
| --- | --- | --- | --- |
| Cash | 12,50,000 | | Current Asset |
| Bank | 8,00,000 | | Current Asset |
| Debtors | 6,20,000 | | Current Asset |
| Inventory | 4,60,000 | | Current Asset |
| Plant | 18,00,000 | | Fixed Asset |
| Machinery | 12,75,000 | | Fixed Asset |
| Furniture | 2,20,000 | | Fixed Asset |
| Land & Building | 30,00,000 | | Fixed Asset |
| Creditors | | 7,80,000 | Current Liability |
| Short-term Loans | | 5,20,000 | Current Liability |
| Secured Loans | | 18,50,000 | Long-term Liability |
| Unsecured Loans | | 6,00,000 | Long-term Liability |
| Owner's Capital | | 40,00,000 | Capital & Reserves |
| Retained Earnings | | 2,50,000 | Capital & Reserves |
| Reserves | | 1,20,000 | Capital & Reserves |
| Sales | | 60,00,000 | Income |
| Other Income | | 3,20,000 | Income |
| Direct Expenses | 22,00,000 | | Expenditure |
| Indirect Expenses | 9,50,000 | | Expenditure |
| Depreciation | 4,80,000 | | Expenditure |
| Taxes | 3,70,000 | | Expenditure |

## Notes
- The ledger is designed to support Indian-style double-entry bookkeeping with clear Debit and Credit columns.
- All financial records are managed with audit trails and secure access control.
