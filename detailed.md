# Detailed Design Document: Small Scale Industry Ledger & Balance Sheet System

## 1. Overview
This document outlines the technical architecture and low-level design for a financial ledger and balance sheet application tailored for Small Scale Industries (SSIs) in India. The system is designed for high reliability, compliance with Indian accounting standards (GST, Companies Act), and secure multi-tier deployment.

## 2. Architecture Layers

### 2.1 Frontend Layer (Mobile & Web)
- **Framework:** Flutter
- **State Management:** BLoC (Business Logic Component) for predictable state transitions.
- **Routing:** Go Router for deep linking and declarative routing.
- **Backend-as-a-Service:** Firebase (for push notifications and real-time triggers).

### 2.2 Backend Layer (Service-Oriented Design)
The backend is composed of modular services to ensure scalability and separation of concerns:
- **Auth Service:** Handles JWT-based authentication, refresh tokens, and RBAC.
- **Ledger Service:** Manages Debit/Credit entries, audit trails, and financial validation.
- **Balance Sheet Service:** Aggregates ledger data into Assets, Liabilities, and Capital reports.
- **Notification Service:** Integrates with Gmail (App Passwords) for alerts and compliance reminders.

### 2.3 Database Layer
- **Primary Database:** MongoDB
- **Security:** AES-256 encryption at rest.
- **Validation:** JSON Schema validation for all financial transactions to prevent data corruption.

## 3. Data Model & Accounting Logic

### 3.1 Ledger Schema
- **Assets:**
  - Current: Cash, Bank, Debtors, Inventory.
  - Fixed: Plant, Machinery, Furniture, Land & Building.
- **Liabilities:**
  - Current: Creditors, Short-term Loans.
  - Long-term: Secured Loans, Unsecured Loans.
- **Capital & Reserves:** Owner’s Capital, Retained Earnings, Reserves.
- **Transactions:** Sales, Other Income, Direct/Indirect Expenses, Depreciation, Taxes.

### 3.2 Indian Standard Formatting
- Tabular format with "Particulars", "LF", "Debit (₹)", and "Credit (₹)" columns.
- T-shape Balance Sheet or vertical schedule-based format.

## 4. Security & Compliance
- **Authentication:** JWT with Refresh Tokens; Passwords hashed with bcrypt/argon2.
- **Authorization:** Role-Based Access Control (Admin, Accountant, Viewer).
- **Audit Trail:** immutable logs of every "Create/Update" action on financial records.
- **Compliance:** Indian Companies Act and GST norms.

## 5. Infrastructure & Deployment
- **Containerization:** Docker & Docker Compose.
- **Hosting:** AWS (VPC, IAM roles).
- **Security:** TLS 1.3 for all HTTPS traffic.
- **Backup:** Daily automated backups with 30-day retention.

## 6. Low-Level Design (LLD)
- **Error Handling:** Global exception filters and structured logging.
- **CI/CD:** Automated pipelines for testing and container deployment.
- **API Documentation:** OpenAPI/Swagger for service communication.
