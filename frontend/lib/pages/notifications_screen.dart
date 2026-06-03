// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/notifications',
      searchHint: 'Search notifications...',
      floatingIcon: Icons.done_all,
      child: _NotificationsContent(),
    );
  }
}

class _NotificationsContent extends ConsumerWidget {
  const _NotificationsContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerState = ref.watch(ledgerDataProvider);
    final loading = ledgerState.isLoading;
    final entries = loading
        ? const <LedgerEntry>[]
        : ledgerState.value?.entries ?? const <LedgerEntry>[];
    final items = _recentTransactionNotifications(entries);
    final useDemoFallback = items.isEmpty && !loading;
    final visibleItems = useDemoFallback ? _demoNotificationItems() : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PageTitle(
          title: 'Notifications',
          subtitle: 'Latest compliance alerts, ledger activity, and approvals.',
        ),
        const SizedBox(height: 24),
        _Panel(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(height: 20, width: 220),
                      SizedBox(height: 18),
                      _SkeletonBox(height: 58),
                      SizedBox(height: 14),
                      _SkeletonBox(height: 58),
                      SizedBox(height: 14),
                      _SkeletonBox(height: 58),
                    ],
                  ),
                )
              else ...[
                if (ledgerState.hasError)
                  _InlineErrorMessage(
                    message: ledgerState.error.toString(),
                    onRetry: () => ref.invalidate(ledgerDataProvider),
                  ),
                ...visibleItems.map((item) => _NotificationTile(item: item)),
                if (useDemoFallback)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Real transaction notifications will sync after the user performs real transactions.',
                      style: TextStyle(
                        color: _appMuted(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String detail;
  final String time;
  final Color color;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
  });
}

List<_NotificationItem> _recentTransactionNotifications(
  List<LedgerEntry> entries,
) {
  final now = DateTime.now();
  final last24Hours = entries.where((entry) {
    final age = now.difference(entry.date);
    return !entry.date.isAfter(now) && age.inHours < 24;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  return last24Hours.map((entry) {
    final isDebit = entry.debit > 0;
    final amount = isDebit ? entry.debit : entry.credit;
    final type = isDebit ? 'Receipt recorded' : 'Payment recorded';

    return _NotificationItem(
      icon: isDebit ? Icons.south_west_outlined : Icons.north_east_outlined,
      title: type,
      detail:
          '${entry.particulars} • ${entry.ledgerRef} • ${_formatCurrency(amount)}',
      time: _relativeNotificationTime(entry.date),
      color: isDebit ? _green : _red,
    );
  }).toList();
}

// Temporary fallback until real transaction notifications are available.
List<_NotificationItem> _demoNotificationItems() {
  return const [
    _NotificationItem(
      icon: Icons.receipt_long_outlined,
      title: 'Demo receipt ready for review',
      detail: 'Sample customer receipt is available in the ledger workspace.',
      time: 'Demo',
      color: _green,
    ),
    _NotificationItem(
      icon: Icons.payments_outlined,
      title: 'Demo payment pending',
      detail: 'Sample supplier payment is waiting for confirmation.',
      time: 'Demo',
      color: _red,
    ),
    _NotificationItem(
      icon: Icons.fact_check_outlined,
      title: 'Demo audit reminder',
      detail: 'Review managed accounts before generating audit reports.',
      time: 'Demo',
      color: _financeGold,
    ),
  ];
}

String _relativeNotificationTime(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) {
    return 'Just now';
  }
  if (diff.inHours < 1) {
    return '${diff.inMinutes} min ago';
  }
  return '${diff.inHours} hr ago';
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _appBorder(context))),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: item.color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 6,
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        if (compact)
                          Text(item.time,
                              style: TextStyle(
                                  color: _appMuted(context), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.detail,
                        style: TextStyle(color: _appMuted(context))),
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 16),
                Text(item.time,
                    style: TextStyle(color: _appMuted(context), fontSize: 12)),
              ],
            ],
          );
        },
      ),
    );
  }
}
