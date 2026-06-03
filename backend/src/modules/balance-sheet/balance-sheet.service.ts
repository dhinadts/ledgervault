import { prisma } from '../../prisma';

interface BalanceSheetItemPayload {
    name: string;
    group: string;
    type: string;
    value: number;
}

export class BalanceSheetService {
    async getCurrentBalanceSheet() {
        const [assets, liabilities, equity] = await Promise.all([
            prisma.balanceSheetItem.findMany({ where: { type: 'asset' }, orderBy: { group: 'asc' } }),
            prisma.balanceSheetItem.findMany({ where: { type: 'liability' }, orderBy: { group: 'asc' } }),
            prisma.balanceSheetItem.findMany({ where: { type: 'equity' }, orderBy: { group: 'asc' } }),
        ]);
        return { assets, liabilities, equity };
    }

    async addItem(item: BalanceSheetItemPayload) {
        return prisma.balanceSheetItem.create({
            data: {
                name: item.name,
                group: item.group,
                type: item.type,
                value: Number(item.value || 0),
            },
        });
    }

    async updateItem(id: string, item: Partial<BalanceSheetItemPayload>) {
        return prisma.balanceSheetItem.update({
            where: { id },
            data: {
                ...(item.name !== undefined ? { name: item.name } : {}),
                ...(item.group !== undefined ? { group: item.group } : {}),
                ...(item.type !== undefined ? { type: item.type } : {}),
                ...(item.value !== undefined ? { value: Number(item.value) } : {}),
            },
        });
    }

    async deleteItem(id: string) {
        await prisma.balanceSheetItem.delete({ where: { id } });
        return { id };
    }

    async syncItems(items: BalanceSheetItemPayload[]) {
        const results = [];

        for (const item of items) {
            results.push(await this.addItem(item));
        }

        return results;
    }
}
