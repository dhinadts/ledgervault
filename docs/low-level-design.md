# Low-Level Design: Balance Sheet Ledger System

## Purpose
This document captures the low-level design for the ledger system, including database schemas, API endpoints, module responsibilities, and security controls.

## System Components

### 1. Ledger Service
Responsibilities:
- Create, update, delete ledger entries.
- Validate debit and credit totals.
- Maintain audit trail metadata (`createdBy`, `updatedBy`, `timestamp`).

Key endpoints:
- `POST /api/ledger/entry`
- `GET /api/ledger/entries`
- `GET /api/ledger/entry/:id`
- `PUT /api/ledger/entry/:id`
- `DELETE /api/ledger/entry/:id`

### 2. Balance Sheet Service
Responsibilities:
- Generate balance sheet snapshots.
- Produce asset-liability comparison.
- Provide income and expenditure summaries.

Key endpoints:
- `GET /api/balance-sheet/current`
- `GET /api/balance-sheet/period?from=&to=`

### 3. Authentication Service
Responsibilities:
- User registration and login.
- JWT issuance, refresh tokens, and secure session control.
- Role-based access enforcement.

Key endpoints:
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`

### 4. Notification Service
Responsibilities:
- Send email alerts for ledger updates, approvals, and due dates.
- Push notifications via Firebase.
- Notification history for audit review.

Key endpoints:
- `POST /api/notifications/send`
- `GET /api/notifications/history`

## Database Schemas

### Ledger Entry Schema
```
{
  _id: ObjectId,
  date: ISODate,
  particulars: String,
  debitAccount: String,
  creditAccount: String,
  amount: Number,
  narration: String,
  voucherType: String,
  gstApplicable: Boolean,
  gstDetails: {
    hsnCode: String,
    cgst: Number,
    sgst: Number,
    igst: Number
  },
  audit: {
    createdBy: ObjectId,
    updatedBy: ObjectId,
    createdAt: ISODate,
    updatedAt: ISODate
  }
}
```

### User Schema
```
{
  _id: ObjectId,
  name: String,
  email: String,
  passwordHash: String,
  role: String, // Admin, Accountant, Auditor, Viewer
  refreshTokens: [String],
  createdAt: ISODate,
  updatedAt: ISODate
}
```

### Notification Schema
```
{
  _id: ObjectId,
  userId: ObjectId,
  type: String,
  title: String,
  message: String,
  status: String,
  createdAt: ISODate
}
```

## Security Controls
- Password hashing with `bcrypt` or `argon2`.
- JWT signed with strong secret, stored in HTTP-only cookies or Authorization header.
- Refresh tokens stored encrypted and rotated.
- Role checks on each protected endpoint.
- Encryption at rest for sensitive fields using AES-256 on MongoDB.
- Validation and sanitisation of all inputs.

## Error Handling and Logging
- Use structured JSON logs with `timestamp`, `service`, `level`, `message`, `context`.
- Capture request IDs for traceability.
- Return consistent API errors with codes like `BAD_REQUEST`, `UNAUTHORIZED`, `FORBIDDEN`, `SERVER_ERROR`.
- Log warnings for business rule failures and errors for uncaught exceptions.

## Workflow Example
1. Accountant logs in and creates a ledger entry for a sale.
2. The Ledger Service validates debit and credit values.
3. The entry is saved to MongoDB with audit metadata.
4. Notification Service sends an email alert and Firebase push.
5. The Balance Sheet Service aggregates the financial positions.

## Compliance Notes
- Ledger postings support GST fields for Indian indirect tax compliance.
- Daily backups and audit logs support Companies Act record-keeping requirements.
- Notification workflows support compliance deadlines and approvals.
