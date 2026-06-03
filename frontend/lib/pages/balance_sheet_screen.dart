part of 'screens.dart';

class BalanceSheetScreen extends StatelessWidget {
  const BalanceSheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/balance-sheet',
      searchHint: 'Search balance sheet...',
      floatingIcon: Icons.account_balance,
      child: _BalanceSheetContent(),
    );
  }
}

class _BalanceSheetContent extends ConsumerStatefulWidget {
  const _BalanceSheetContent();

  @override
  ConsumerState<_BalanceSheetContent> createState() =>
      _BalanceSheetContentState();
}

class _BalanceSheetContentState extends ConsumerState<_BalanceSheetContent> {
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerDataProvider);
    final loading = ledgerState.isLoading;
    final data =
        loading ? LedgerData.empty() : ledgerState.value ?? LedgerData.empty();

    if (loading) {
      return const _BalanceSheetLoadingContent();
    }

    final filteredEntries = _filterEntries(data.entries);
    final filteredBalances =
        balancesWithLedgerActivity(data.balances, filteredEntries);
    final metrics = _LedgerMetrics.fromData(
      entries: filteredEntries,
      balances: filteredBalances,
    );

    final totalAssets = metrics.availableBalance + metrics.receivable;
    final totalLiabilities = metrics.payable;
    final netWorth = totalAssets - totalLiabilities;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ledgerState.hasError && !loading) ...[
          _LedgerLoadError(
            message: ledgerState.error.toString(),
            onRetry: () => ref.invalidate(ledgerDataProvider),
          ),
          const SizedBox(height: 24),
        ],
        _BalanceSheetDateFilter(
          fromDate: _fromDate,
          toDate: _toDate,
          onFromDateChanged: (value) => setState(() {
            _fromDate = value;
          }),
          onToDateChanged: (value) => setState(() {
            _toDate = value;
          }),
          onClear: () => setState(() {
            _fromDate = null;
            _toDate = null;
          }),
        ),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 260,
          children: [
            _MetricCard(
              label: 'TOTAL ASSETS',
              value: _formatCurrency(totalAssets),
              color: _green,
              note: loading ? 'Loading...' : 'Cash/bank + receivables',
              icon: Icons.trending_up,
            ),
            _MetricCard(
              label: 'TOTAL LIABILITIES',
              value: _formatCurrency(totalLiabilities),
              color: _red,
              note: loading ? 'Loading...' : 'Pending payable amount',
              icon: Icons.trending_down,
            ),
            _MetricCard(
              label: 'NET WORTH',
              value: _formatCurrency(netWorth),
              color: _appAccent(context),
              note: 'Assets minus liabilities',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _BalanceSheetSummary(
          metrics: metrics,
          totalAssets: totalAssets,
          totalLiabilities: totalLiabilities,
          netWorth: netWorth,
        ),
        const SizedBox(height: 24),
        _BalanceSheetBankTable(
          balances: filteredBalances,
          entries: filteredEntries,
          loading: loading,
        ),
      ],
    );
  }

  List<LedgerEntry> _filterEntries(List<LedgerEntry> entries) {
    return entries.where((entry) {
      if (_fromDate != null && entry.date.isBefore(_fromDate!)) {
        return false;
      }
      if (_toDate != null && entry.date.isAfter(_toDate!)) {
        return false;
      }
      return true;
    }).toList();
  }
}

class _BalanceSheetDateFilter extends StatelessWidget {
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;
  final VoidCallback onClear;

  const _BalanceSheetDateFilter({
    required this.fromDate,
    required this.toDate,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final from = _DateTimeFilterButton(
            value: fromDate,
            placeholder: 'Start date & time',
            onChanged: onFromDateChanged,
          );
          final to = _DateTimeFilterButton(
            value: toDate,
            placeholder: 'End date & time',
            onChanged: onToDateChanged,
          );
          final clear = OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _appAccent(context),
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: onClear,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('CUSTOM DATE FILTER'),
              const SizedBox(height: 14),
              if (compact)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    from,
                    const SizedBox(height: 12),
                    to,
                    const SizedBox(height: 12),
                    clear,
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: from),
                    const SizedBox(width: 12),
                    Expanded(child: to),
                    const SizedBox(width: 12),
                    SizedBox(width: 130, child: clear),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceSheetLoadingContent extends StatelessWidget {
  const _BalanceSheetLoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricGridSkeleton(count: 3),
        SizedBox(height: 24),
        _PanelSkeleton(rows: 5),
        SizedBox(height: 24),
        _PanelSkeleton(rows: 6, table: true),
      ],
    );
  }
}

class _BalanceSheetSummary extends StatelessWidget {
  final _LedgerMetrics metrics;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;

  const _BalanceSheetSummary({
    required this.metrics,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _BalanceRow(
            label: 'Available Cash / Bank',
            amount: metrics.availableBalance,
            color: _appAccent(context),
          ),
          _BalanceRow(
            label: 'Receivables - To Receive',
            amount: metrics.receivable,
            color: _green,
          ),
          _BalanceRow(
            label: 'Total Assets',
            amount: totalAssets,
            color: _green,
            strong: true,
          ),
          _BalanceRow(
            label: 'Payables - To Pay',
            amount: totalLiabilities,
            color: _red,
          ),
          _BalanceRow(
            label: 'Net Worth',
            amount: netWorth,
            color: netWorth >= 0 ? _primary : _red,
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _BalanceSheetBankTable extends StatelessWidget {
  final List<BankBalance> balances;
  final List<LedgerEntry> entries;
  final bool loading;

  const _BalanceSheetBankTable({
    required this.balances,
    required this.entries,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bank-wise Balance Sheet',
                style: TextStyle(
                  color: _appAccent(context),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          if (balances.isEmpty && !loading)
            const _EmptyPanelMessage(
              icon: Icons.account_balance_outlined,
              title: 'No bank accounts',
              subtitle:
                  'Bank-wise balance will appear after accounts are configured.',
            )
          else
            ...balances.map((account) {
              final bankEntries = entries.where((entry) {
                return _sameAccount(entry.ledgerRef, account.displayName);
              }).toList();

              final metrics = _LedgerMetrics.fromData(
                entries: bankEntries,
                balances: [account],
                selectedAccount: account.displayName,
              );

              final assets = metrics.availableBalance + metrics.receivable;
              final liabilities = metrics.payable;
              final netWorth = assets - liabilities;

              return Column(
                children: [
                  _BalanceRow(
                    label: account.displayName,
                    amount: metrics.availableBalance,
                    color: _appAccent(context),
                    subtitle: 'Available balance',
                  ),
                  _BalanceRow(
                    label: 'Receivable',
                    amount: metrics.receivable,
                    color: _green,
                  ),
                  _BalanceRow(
                    label: 'Payable',
                    amount: metrics.payable,
                    color: _red,
                  ),
                  _BalanceRow(
                    label: 'Bank Net Worth',
                    amount: netWorth,
                    color: netWorth >= 0 ? _green : _red,
                    strong: true,
                  ),
                ],
              );
            }),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String label;
  final String? subtitle;
  final double amount;
  final Color color;
  final bool strong;

  const _BalanceRow({
    required this.label,
    required this.amount,
    required this.color,
    this.subtitle,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: strong ? _appHeaderSurface(context) : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: subtitle == null
                ? Text(
                    label,
                    style: TextStyle(
                      color: _appText(context),
                      fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: _appText(context),
                          fontWeight:
                              strong ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: _appMuted(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
          Text(
            _formatCurrency(amount),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontSize: strong ? 17 : 15,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
