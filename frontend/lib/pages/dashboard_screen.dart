// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const _AppShell(
        activeRoute: '/dashboard',
        searchHint: 'Search accounts, invoices...',
        floatingIcon: Icons.add,
        child: _DashboardContent(),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerState = ref.watch(ledgerDataProvider);
    final loading = ledgerState.isLoading;
    final data =
        loading ? LedgerData.empty() : ledgerState.value ?? LedgerData.empty();

    if (loading) {
      return const _DashboardLoadingContent();
    }

    if (ledgerState.hasError && !loading) {
      final emptyMetrics = _LedgerMetrics.fromData(
        entries: const <LedgerEntry>[],
        balances: const <BankBalance>[],
      );

      return Column(
        children: [
          _DashboardMetricCards(
            metrics: emptyMetrics,
            loading: false,
          ),
          const SizedBox(height: 24),
          _DashboardNoInternet(
            message: ledgerState.error.toString(),
            onRetry: () => ref.invalidate(ledgerDataProvider),
          ),
          const SizedBox(height: 24),
          const _RecentTransactionsTable(entries: <LedgerEntry>[]),
        ],
      );
    }

    final metrics = _LedgerMetrics.fromData(
      entries: data.entries,
      balances: data.balances,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardMetricCards(metrics: metrics, loading: loading),
            const SizedBox(height: 24),
            if (compact)
              Column(
                children: [
                  _PerformanceCard(metrics: metrics),
                  const SizedBox(height: 20),
                  _NetMarginCard(metrics: metrics),
                  const SizedBox(height: 20),
                  _QuickActionsCard(entries: data.entries),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _PerformanceCard(metrics: metrics),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _NetMarginCard(metrics: metrics),
                        const SizedBox(height: 20),
                        _QuickActionsCard(entries: data.entries),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            _RecentTransactionsTable(entries: data.entries),
          ],
        );
      },
    );
  }
}

class _DashboardLoadingContent extends StatelessWidget {
  const _DashboardLoadingContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MetricGridSkeleton(count: 3),
            const SizedBox(height: 24),
            if (compact)
              const Column(
                children: [
                  _PanelSkeleton(rows: 3),
                  SizedBox(height: 20),
                  _PanelSkeleton(rows: 3),
                  SizedBox(height: 20),
                  _PanelSkeleton(rows: 4),
                ],
              )
            else
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _PanelSkeleton(rows: 4)),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _PanelSkeleton(rows: 3),
                        SizedBox(height: 20),
                        _PanelSkeleton(rows: 4),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            const _PanelSkeleton(rows: 5, table: true),
          ],
        );
      },
    );
  }
}

class _DashboardNoInternet extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardNoInternet({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_outlined, color: _red, size: 42),
          const SizedBox(height: 12),
          Text(
            'No internet',
            style: TextStyle(
              color: _appAccent(context),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unable to load dashboard data. Please enable internet or start the backend service.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _appMuted(context)),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: _appMuted(context), fontSize: 12),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: _primary),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetricCards extends StatelessWidget {
  final _LedgerMetrics metrics;
  final bool loading;

  const _DashboardMetricCards({
    required this.metrics,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minTileWidth: 260,
      children: [
        _MetricCard(
          label: 'AVAILABLE CASH / BANK',
          value: _formatCurrency(metrics.availableBalance),
          color: _appAccent(context),
          note: loading ? 'Loading balances' : 'Opening + received - paid',
          icon: Icons.account_balance_wallet_outlined,
        ),
        _MetricCard(
          label: 'TO RECEIVE',
          value: _formatCurrency(metrics.receivable),
          color: _green,
          note: '${metrics.pendingCount} pending vouchers',
          icon: Icons.trending_up,
        ),
        _MetricCard(
          label: 'TO PAY',
          value: _formatCurrency(metrics.payable),
          color: _red,
          note: '${_formatCurrency(metrics.payable)} pending',
          icon: Icons.trending_down,
        ),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final _LedgerMetrics metrics;

  const _PerformanceCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 560;

          final movement = metrics.receivedDebit + metrics.paidCredit;
          final debitShare =
              movement == 0 ? 0.0 : metrics.receivedDebit / movement;

          final debitFlex = (debitShare * 100).round().clamp(0, 100);
          final creditFlex = 100 - debitFlex;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Actual Cash Movement',
                    style: TextStyle(
                      color: _appAccent(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const _Legend(color: _green, label: 'Received'),
                  const _Legend(color: _red, label: 'Paid'),
                ],
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  const Text('Received/Paid split'),
                  Text(
                    '${(debitShare * 100).toStringAsFixed(0)}% Received',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    if (debitFlex > 0)
                      Expanded(
                        flex: debitFlex,
                        child: const ColoredBox(
                          color: _green,
                          child: SizedBox(height: 20),
                        ),
                      ),
                    if (creditFlex > 0)
                      Expanded(
                        flex: creditFlex,
                        child: const ColoredBox(
                          color: _red,
                          child: SizedBox(height: 20),
                        ),
                      ),
                    if (movement == 0)
                      const Expanded(
                        child: ColoredBox(
                          color: Color(0xFFEAE7EF),
                          child: SizedBox(height: 20),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: narrow ? 28 : 80,
                runSpacing: 24,
                children: [
                  _KpiBlock(
                    label: 'RECEIVED DEBIT',
                    value: _formatCurrency(metrics.receivedDebit),
                    color: _green,
                  ),
                  _KpiBlock(
                    label: 'PAID CREDIT',
                    value: _formatCurrency(metrics.paidCredit),
                    color: _red,
                  ),
                ],
              ),
              SizedBox(height: narrow ? 24 : 48),
            ],
          );
        },
      ),
    );
  }
}

class _NetMarginCard extends StatelessWidget {
  final _LedgerMetrics metrics;

  const _NetMarginCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final netMovement = metrics.receivedDebit - metrics.paidCredit;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1F4E5F),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Net Cash Movement',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _formatCurrency(netMovement),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Received debit minus paid credit.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final List<LedgerEntry> entries;

  const _QuickActionsCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('QUICK ACTIONS'),
          const SizedBox(height: 12),
          _DashboardActionButton(
            icon: Icons.add,
            label: 'New Entry',
            color: _appAccent(context),
            onPressed: () => _showAppFlowModal(
              context,
              _AppFlowModalType.ledgerEntry,
            ),
          ),
          const SizedBox(height: 12),
          _DashboardActionButton(
            icon: Icons.menu_book_outlined,
            label: 'Open Ledger',
            color: _green,
            onPressed: () => context.go('/ledger'),
          ),
          const SizedBox(height: 12),
          _DashboardActionButton(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Export Statement',
            color: _red,
            onPressed: () async {
              final balances = await _backendApi.fetchBankBalances();

              if (!context.mounted) {
                return;
              }

              final message = await exportLedgerStatement(entries, balances);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _DashboardActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _RecentTransactionsTable extends StatelessWidget {
  final List<LedgerEntry> entries;

  const _RecentTransactionsTable({required this.entries});

  static const double _dateWidth = 210;
  static const double _typeWidth = 140;
  static const double _statusWidth = 150;
  static const double _amountWidth = 190;
  static const double _minimumParticularsWidth = 420;

  static const double _minimumTableWidth = _dateWidth +
      _minimumParticularsWidth +
      _typeWidth +
      _statusWidth +
      _amountWidth;

  @override
  Widget build(BuildContext context) {
    final recent = entries.take(5).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < _minimumTableWidth
            ? _minimumTableWidth
            : constraints.maxWidth;

        final particularsWidth =
            tableWidth - _dateWidth - _typeWidth - _statusWidth - _amountWidth;

        return Padding(
          padding: const EdgeInsets.only(bottom: 72),
          child: _Panel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent Transactions',
                          style: TextStyle(
                            color: _appAccent(context),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/ledger'),
                        iconAlignment: IconAlignment.end,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('View Ledger'),
                      ),
                    ],
                  ),
                ),
                if (recent.isEmpty)
                  const _EmptyPanelMessage(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    subtitle:
                        'Recent entries will appear after ledger activity is saved.',
                  )
                else
                  _HorizontalScrollView(
                    child: SizedBox(
                      width: tableWidth,
                      child: Column(
                        children: [
                          _RecentHeaderRow(
                            particularsWidth: particularsWidth,
                          ),
                          ...recent.map(
                            (entry) => _RecentDataRow(
                              entry: entry,
                              particularsWidth: particularsWidth,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RecentHeaderRow extends StatelessWidget {
  final double particularsWidth;

  const _RecentHeaderRow({required this.particularsWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _appHeaderSurface(context),
      child: Row(
        children: [
          const _RecentCell(
            width: _RecentTransactionsTable._dateWidth,
            child: _RecentHeader('DATE'),
          ),
          _RecentCell(
            width: particularsWidth,
            child: const _RecentHeader('PARTICULARS / ACCOUNT'),
          ),
          const _RecentCell(
            width: _RecentTransactionsTable._typeWidth,
            child: _RecentHeader('TYPE'),
          ),
          const _RecentCell(
            width: _RecentTransactionsTable._statusWidth,
            child: _RecentHeader('STATUS'),
          ),
          const _RecentCell(
            width: _RecentTransactionsTable._amountWidth,
            alignEnd: true,
            child: _RecentHeader('AMOUNT'),
          ),
        ],
      ),
    );
  }
}

class _RecentDataRow extends StatelessWidget {
  final LedgerEntry entry;
  final double particularsWidth;

  const _RecentDataRow({
    required this.entry,
    required this.particularsWidth,
  });

  @override
  Widget build(BuildContext context) {
    final status = _normalizeLedgerStatus(entry.status);

    final isDebit = entry.debit > 0;
    final isCredit = entry.credit > 0;

    final amount = isDebit ? entry.debit : entry.credit;

    final type = isDebit
        ? status == 'Received'
            ? 'Received'
            : 'To Receive'
        : isCredit
            ? status == 'Paid'
                ? 'Paid'
                : 'To Pay'
            : '-';

    final color = isDebit ? _green : _red;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _appBorder(context))),
      ),
      child: Row(
        children: [
          _RecentCell(
            width: _RecentTransactionsTable._dateWidth,
            child: Text(
              _formatDateTime(entry.date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          _RecentCell(
            width: particularsWidth,
            child: _TwoLineText('${entry.particulars}\n${entry.ledgerRef}'),
          ),
          _RecentCell(
            width: _RecentTransactionsTable._typeWidth,
            child: Text(
              type,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _RecentCell(
            width: _RecentTransactionsTable._statusWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _Chip(
                label: status,
                color: _ledgerStatusColor(status),
              ),
            ),
          ),
          _RecentCell(
            width: _RecentTransactionsTable._amountWidth,
            alignEnd: true,
            child: Text(
              _formatCurrency(amount),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCell extends StatelessWidget {
  final double width;
  final Widget child;
  final bool alignEnd;

  const _RecentCell({
    required this.width,
    required this.child,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Align(
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}

class _RecentHeader extends StatelessWidget {
  final String label;

  const _RecentHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _appText(context),
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}
