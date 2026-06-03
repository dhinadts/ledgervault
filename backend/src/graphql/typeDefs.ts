import { gql } from 'apollo-server-express';

export const typeDefs = gql`
  scalar DateTime

  type User {
    id: String!
    name: String!
    email: String!
    role: String!
    createdAt: DateTime!
    updatedAt: DateTime!
  }

  type AuthPayload {
    token: String!
    refreshToken: String!
    user: User!
  }

  type LedgerEntry {
    id: String!
    date: DateTime!
    particulars: String!
    ledgerRef: String!
    debit: Float!
    credit: Float!
    status: String!
    tags: [String!]!
    createdBy: String!
    createdAt: DateTime!
    updatedAt: DateTime!
  }

  type BalanceSheetItem {
    id: String!
    name: String!
    group: String!
    type: String!
    value: Float!
    createdAt: DateTime!
    updatedAt: DateTime!
  }

  type BalanceSheetSummary {
    assets: [BalanceSheetItem!]!
    liabilities: [BalanceSheetItem!]!
    equity: [BalanceSheetItem!]!
  }

  type Notification {
    id: String!
    title: String!
    detail: String!
    time: String!
    color: String!
    level: String!
    isRead: Boolean!
    createdAt: DateTime!
  }

  input RegisterInput {
    name: String!
    email: String!
    password: String!
    role: String!
  }

  input LoginInput {
    email: String!
    password: String!
  }

  input LedgerEntryInput {
    date: String!
    particulars: String!
    ledgerRef: String!
    debit: Float!
    credit: Float!
    status: String!
    tags: [String!]!
  }

  input BalanceSheetItemInput {
    name: String!
    group: String!
    type: String!
    value: Float!
  }

  input NotificationInput {
    title: String!
    detail: String!
    time: String!
    color: String!
    level: String!
    isRead: Boolean
  }

  type Query {
    me: User
    ledgerEntries: [LedgerEntry!]!
    balanceSheet: BalanceSheetSummary!
    notifications: [Notification!]!
  }

  type Mutation {
    register(input: RegisterInput!): AuthPayload!
    login(input: LoginInput!): AuthPayload!
    refreshToken(refreshToken: String!): AuthPayload!
    createLedgerEntry(input: LedgerEntryInput!): LedgerEntry!
    addBalanceSheetItem(input: BalanceSheetItemInput!): BalanceSheetItem!
    sendNotification(input: NotificationInput!): Notification!
  }
`;
