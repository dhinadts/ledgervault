import { prisma } from "../../prisma";

export interface BankAccount {
  id: string;
  accountHolderName: string;
  ownerType: string;
  accountName: string;
  bankName: string;
  branchName?: string | null;
  accountNumber: string;
  ifsc: string;
  accountType: string;
  openingBalance: number;
  balance: number;
  primaryAccount: boolean;
  createdBy?: string | null;
}

export class BankBalancesService {
  async listBalances(createdBy?: string): Promise<BankAccount[]> {
    try {
      const [accounts, entries] = await Promise.all([
        prisma.bankAccount.findMany({
          where: createdBy ? { createdBy } : undefined,
          orderBy: [{ primaryAccount: "desc" }, { createdAt: "asc" }],
        }),
        prisma.ledgerEntry.findMany({
          where: createdBy ? { createdBy } : undefined,
        }),
      ]);

      if (accounts.length > 0) {
        return accounts.map((account) => toBankAccount(account, entries));
      }

      return this.demoBalances(entries);
    } catch (error) {
      console.error("[BankBalances] Falling back to demo balances:", error);
    }

    return this.demoBalances();
  }

  async createAccount(payload: Record<string, unknown>, createdBy?: string) {
    const data = normalizePayload(payload, createdBy);

    if (data.primaryAccount) {
      await this.clearPrimaryAccount(createdBy);
    }

    const [account, entries] = await Promise.all([
      prisma.bankAccount.create({ data }),
      prisma.ledgerEntry.findMany({
        where: createdBy ? { createdBy } : undefined,
      }),
    ]);
    return toBankAccount(account, entries);
  }

  async updateAccount(
    id: string,
    payload: Record<string, unknown>,
    createdBy?: string,
  ) {
    const data = normalizePayload(payload, createdBy, true);

    if (createdBy) {
      await this.assertAccountOwner(id, createdBy);
    }

    if (data.primaryAccount) {
      await this.clearPrimaryAccount(createdBy, id);
    }

    const [account, entries] = await Promise.all([
      prisma.bankAccount.update({
        where: { id },
        data,
      }),
      prisma.ledgerEntry.findMany({
        where: createdBy ? { createdBy } : undefined,
      }),
    ]);
    return toBankAccount(account, entries);
  }

  async deleteAccount(id: string, createdBy?: string) {
    if (createdBy) {
      await this.assertAccountOwner(id, createdBy);
    }

    await prisma.bankAccount.delete({ where: { id } });
    return { id };
  }

  async syncAccounts(accounts: Record<string, unknown>[], createdBy?: string) {
    const saved: BankAccount[] = [];

    for (const account of accounts) {
      saved.push(await this.createAccount(account, createdBy));
    }

    return saved;
  }

  private async clearPrimaryAccount(createdBy?: string, exceptId?: string) {
    await prisma.bankAccount.updateMany({
      where: {
        ...(createdBy ? { createdBy } : {}),
        ...(exceptId ? { id: { not: exceptId } } : {}),
      },
      data: { primaryAccount: false },
    });
  }

  private demoBalances(entries: LedgerMovement[] = []): BankAccount[] {
    return [
      {
        id: "axis-savings",
        accountHolderName:
          "DHINADTS IT SOLUTIONS AND SUPPORT (OPC) PRIVATE LIMITED",
        ownerType: "Company",
        accountName: "Savings Account",
        bankName: "Axis Bank",
        branchName: "Chennai Main",
        accountNumber: "000000000001",
        ifsc: "UTIB0000001",
        accountType: "Savings",
        openingBalance: 100000,
        balance: 100000,
        primaryAccount: true,
      },
      {
        id: "axis-current",
        accountHolderName:
          "DHINADTS IT SOLUTIONS AND SUPPORT (OPC) PRIVATE LIMITED",
        ownerType: "Company",
        accountName: "Current Account",
        bankName: "Axis Bank",
        branchName: "Chennai Main",
        accountNumber: "000000000002",
        ifsc: "UTIB0000001",
        accountType: "Current",
        openingBalance: 100000,
        balance: 100000,
        primaryAccount: false,
      },
      {
        id: "hdfc-salary",
        accountHolderName:
          "DHINADTS IT SOLUTIONS AND SUPPORT (OPC) PRIVATE LIMITED",
        ownerType: "Company",
        accountName: "Salary Account",
        bankName: "HDFC Bank",
        branchName: "Chennai T Nagar",
        accountNumber: "000000000003",
        ifsc: "HDFC0000001",
        accountType: "Salary",
        openingBalance: 55000,
        balance: 55000,
        primaryAccount: false,
      },
    ].map((account) => applyLedgerMovement(account, entries));
  }

  private async assertAccountOwner(id: string, createdBy: string) {
    const account = await prisma.bankAccount.findFirst({
      where: { id, createdBy },
      select: { id: true },
    });

    if (!account) {
      throw new Error("Bank account not found");
    }
  }
}

function normalizePayload(
  payload: Record<string, unknown>,
  createdBy?: string,
  partial = false,
) {
  const required = (key: string, fallback = "") => {
    const value = payload[key]?.toString().trim() || fallback;
    if (!partial && !value) {
      throw new Error(`${key} is required`);
    }
    return value;
  };

  const openingBalance = Number(payload.openingBalance ?? payload.balance ?? 0);

  return {
    accountHolderName: required("accountHolderName"),
    ownerType: required("ownerType", "Company"),
    bankName: required("bankName"),
    branchName: payload.branchName?.toString().trim() || null,
    accountNumber: required("accountNumber"),
    ifsc: required("ifsc").toUpperCase(),
    accountType: required("accountType", "Current"),
    openingBalance: Number.isFinite(openingBalance) ? openingBalance : 0,
    primaryAccount: Boolean(payload.primaryAccount),
    ...(createdBy ? { createdBy } : {}),
  };
}

function toBankAccount(account: {
  id: string;
  accountHolderName: string;
  ownerType: string;
  bankName: string;
  branchName?: string | null;
  accountNumber: string;
  ifsc: string;
  accountType: string;
  openingBalance: number;
  primaryAccount: boolean;
  createdBy?: string | null;
}, entries: LedgerMovement[] = []): BankAccount {
  return applyLedgerMovement({
    id: account.id,
    accountHolderName: account.accountHolderName,
    ownerType: account.ownerType,
    accountName: account.accountHolderName,
    bankName: account.bankName,
    branchName: account.branchName,
    accountNumber: account.accountNumber,
    ifsc: account.ifsc,
    accountType: account.accountType,
    openingBalance: account.openingBalance,
    balance: account.openingBalance,
    primaryAccount: account.primaryAccount,
    createdBy: account.createdBy,
  }, entries);
}

type LedgerMovement = {
  ledgerRef: string;
  debit: number;
  credit: number;
};

function applyLedgerMovement(
  account: BankAccount,
  entries: LedgerMovement[],
): BankAccount {
  const movement = entries
    .filter((entry) => entryMatchesAccount(entry, account))
    .reduce((sum, entry) => sum + entry.debit - entry.credit, 0);

  return {
    ...account,
    balance: account.openingBalance + movement,
  };
}

function entryMatchesAccount(entry: LedgerMovement, account: BankAccount) {
  const ref = normalizeAccountText(entry.ledgerRef);
  if (!ref) {
    return false;
  }

  const candidates = [
    account.accountName,
    account.accountHolderName,
    `${account.accountType} Account - ${account.bankName}`,
    `${account.accountType} - ${account.bankName}`,
    account.bankName,
    account.accountNumber,
  ]
    .map(normalizeAccountText)
    .filter(Boolean);

  return candidates.some((candidate) => ref === candidate);
}

function normalizeAccountText(value: string) {
  return value
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, " ")
    .trim()
    .replace(/\s+/g, " ");
}
