import type { LedgerEntry } from "@prisma/client";
import { prisma } from "../../prisma";

interface LedgerEntryPayload {
  date: string;
  particulars: string;
  ledgerRef: string;
  debit: number;
  credit: number;
  status?: string;
  tags?: string[];
  createdBy?: string;
}

export class LedgerService {
  async listEntries(search?: string, createdBy?: string) {
    const entries = await prisma.ledgerEntry.findMany({
      where: createdBy ? { createdBy } : undefined,
      orderBy: { date: "desc" },
    });

    const query = search?.trim().toLowerCase();
    if (!query) {
      return entries;
    }

    return entries.filter((entry: LedgerEntry) =>
      [
        entry.particulars,
        entry.ledgerRef,
        entry.status,
        entry.debit.toString(),
        entry.credit.toString(),
        ...entry.tags,
      ]
        .join(" ")
        .toLowerCase()
        .includes(query),
    );
  }

  async createEntry(entry: LedgerEntryPayload) {
    const debit = Number(entry.debit || 0);
    const credit = Number(entry.credit || 0);
    const date = new Date(entry.date);
    const particulars = entry.particulars?.trim();
    const ledgerRef = entry.ledgerRef?.trim();

    if (!particulars) {
      throw new Error("Particulars are required");
    }

    if (!ledgerRef) {
      throw new Error("Ledger reference is required");
    }

    if (Number.isNaN(date.getTime())) {
      throw new Error("Entry date is invalid");
    }

    if (debit < 0 || credit < 0) {
      throw new Error("Ledger amounts cannot be negative");
    }

    if (debit === 0 && credit === 0) {
      throw new Error("Enter either debit or credit amount");
    }

    if (debit > 0 && credit > 0) {
      throw new Error("Ledger entry cannot have both debit and credit amounts");
    }

    return prisma.ledgerEntry.create({
      data: {
        date,
        particulars,
        ledgerRef,
        debit,
        credit,
        status: entry.status || "PENDING",
        tags: entry.tags || [],
        createdBy: entry.createdBy || "system",
      },
    });
  }

  async updateEntry(
    id: string,
    entry: Partial<LedgerEntryPayload>,
    createdBy?: string,
  ) {
    if ((entry.debit ?? 0) > 0 && (entry.credit ?? 0) > 0) {
      throw new Error("Ledger entry cannot have both debit and credit amounts");
    }

    if (createdBy) {
      await this.assertEntryOwner(id, createdBy);
    }

    return prisma.ledgerEntry.update({
      where: { id },
      data: {
        ...(entry.date ? { date: new Date(entry.date) } : {}),
        ...(entry.particulars !== undefined
          ? { particulars: entry.particulars }
          : {}),
        ...(entry.ledgerRef !== undefined
          ? { ledgerRef: entry.ledgerRef }
          : {}),
        ...(entry.debit !== undefined ? { debit: Number(entry.debit) } : {}),
        ...(entry.credit !== undefined ? { credit: Number(entry.credit) } : {}),
        ...(entry.status !== undefined ? { status: entry.status } : {}),
        ...(entry.tags !== undefined ? { tags: entry.tags } : {}),
        ...(entry.createdBy !== undefined
          ? { createdBy: entry.createdBy }
          : {}),
      },
    });
  }

  async deleteEntry(id: string, createdBy?: string) {
    if (createdBy) {
      await this.assertEntryOwner(id, createdBy);
    }

    await prisma.ledgerEntry.delete({ where: { id } });
    return { id };
  }

  private async assertEntryOwner(id: string, createdBy: string) {
    const entry = await prisma.ledgerEntry.findFirst({
      where: { id, createdBy },
      select: { id: true },
    });

    if (!entry) {
      throw new Error("Ledger entry not found");
    }
  }

  async resetTestData() {
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth();
    const day = now.getDate();
    const sampleEntries = [
      {
        date: new Date(year, month, day, 9, 15),
        particulars: "Salary Credit",
        ledgerRef: "Salary Account - HDFC Bank",
        debit: 25000,
        credit: 0,
        status: "Received",
        tags: ["Test", "Salary"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day, 10, 0),
        particulars: "Client Invoice",
        ledgerRef: "Current Account - Axis Bank",
        debit: 18000,
        credit: 0,
        status: "To Receive",
        tags: ["Test", "Receivable"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day, 10, 30),
        particulars: "Vendor Payment",
        ledgerRef: "Current Account - Axis Bank",
        debit: 0,
        credit: 8500,
        status: "Paid",
        tags: ["Test", "Payable"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day, 11, 0),
        particulars: "Office Rent",
        ledgerRef: "Current Account - Axis Bank",
        debit: 0,
        credit: 12000,
        status: "Unpaid",
        tags: ["Test", "Payable"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day, 11, 30),
        particulars: "Equipment Advance",
        ledgerRef: "Savings Account - Axis Bank",
        debit: 0,
        credit: 6000,
        status: "On Hold",
        tags: ["Test", "Hold"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day, 12, 0),
        particulars: "Service Refund",
        ledgerRef: "Savings Account - Axis Bank",
        debit: 5200,
        credit: 0,
        status: "Received",
        tags: ["Test", "Refund"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day - 1, 14, 15),
        particulars: "Software Subscription",
        ledgerRef: "Current Account - Axis Bank",
        debit: 0,
        credit: 3200,
        status: "Paid",
        tags: ["Test", "Operations"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day - 1, 16, 45),
        particulars: "Maintenance Invoice",
        ledgerRef: "Current Account - Axis Bank",
        debit: 14500,
        credit: 0,
        status: "Received",
        tags: ["Test", "Income"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day - 2, 10, 10),
        particulars: "GST Payment",
        ledgerRef: "Current Account - Axis Bank",
        debit: 0,
        credit: 7800,
        status: "Unpaid",
        tags: ["Test", "Tax"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day - 2, 13, 30),
        particulars: "Consulting Retainer",
        ledgerRef: "Salary Account - HDFC Bank",
        debit: 30000,
        credit: 0,
        status: "To Receive",
        tags: ["Test", "Receivable"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
      {
        date: new Date(year, month, day - 3, 15, 0),
        particulars: "Travel Advance",
        ledgerRef: "Savings Account - Axis Bank",
        debit: 0,
        credit: 4500,
        status: "On Hold",
        tags: ["Test", "Advance"],
        createdBy: "test-data",
        createdAt: now,
        updatedAt: now,
      },
    ];

    await prisma.ledgerEntry.deleteMany({});

    return Promise.all(
      sampleEntries.map((entry) => prisma.ledgerEntry.create({ data: entry })),
    );
  }

  async syncEntries(entries: LedgerEntryPayload[], createdBy?: string) {
    const results = [];

    for (const entry of entries) {
      results.push(await this.createEntry({ ...entry, createdBy }));
    }

    return results;
  }
}
