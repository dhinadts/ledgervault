import { prisma } from '../../prisma';

interface NotificationPayload {
    title: string;
    detail: string;
    time: string;
    color?: string;
    level?: string;
    isRead?: boolean;
}

export class NotificationService {
    async listNotifications() {
        return prisma.notification.findMany({
            orderBy: { createdAt: 'desc' },
        });
    }

    async logNotification(notification: NotificationPayload) {
        return prisma.notification.create({
            data: {
                title: notification.title,
                detail: notification.detail,
                time: notification.time,
                color: notification.color || '#000666',
                level: notification.level || 'info',
                isRead: notification.isRead ?? false,
            },
        });
    }

    async markRead(id: string, isRead = true) {
        return prisma.notification.update({
            where: { id },
            data: { isRead },
        });
    }

    async deleteNotification(id: string) {
        await prisma.notification.delete({ where: { id } });
        return { id };
    }

    async syncNotifications(notifications: NotificationPayload[]) {
        const results = [];

        for (const notification of notifications) {
            results.push(await this.logNotification(notification));
        }

        return results;
    }
}
