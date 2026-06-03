// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

const double _ledgerDateWidth = 150;
const double _ledgerMinimumParticularsWidth = 320;
const double _ledgerRefWidth = 280;
const double _ledgerDebitWidth = 170;
const double _ledgerCreditWidth = 170;
const double _ledgerActionWidth = 210;

const double _ledgerTableWidth = _ledgerDateWidth +
    _ledgerMinimumParticularsWidth +
    _ledgerRefWidth +
    _ledgerDebitWidth +
    _ledgerCreditWidth +
    _ledgerActionWidth;

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/ledger',
      searchHint: 'Search entries, vouchers...',
      floatingIcon: Icons.task_alt,
      child: _LedgerContent(),
    );
  }
}

class _LedgerContent extends ConsumerStatefulWidget {
  const _LedgerContent();

  @override
  ConsumerState<_LedgerContent> createState() => _LedgerContentState();
}

class _LedgerContentState extends ConsumerState<_LedgerContent> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _selectedAccount;

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerDataProvider);
    final loading = ledgerState.isLoading;
    final data =
        loading ? LedgerData.empty() : ledgerState.value ?? LedgerData.empty();

    if (loading) {
      return const _LedgerLoadingContent();
    }

    return ValueListenableBuilder<String>(
      valueListenable: _appSearchQuery,
      builder: (context, searchQuery, _) {
        final entries = _filterEntries(data.entries, searchQuery);
        final metrics = _LedgerMetrics.fromData(
          entries: entries,
          balances: data.balances,
          selectedAccount: _selectedAccount,
        );

        return Column(
          children: [
            if (ledgerState.hasError && !loading) ...[
              _LedgerLoadError(
                message: ledgerState.error.toString(),
                onRetry: () => ref.invalidate(ledgerDataProvider),
              ),
              const SizedBox(height: 24),
            ],
            _LedgerMetricCards(metrics: metrics, loading: loading),
            const SizedBox(height: 24),
            _BankAccountDetails(
              balances: data.balances,
              loading: loading,
              selectedAccount: _selectedAccount,
              entries: data.entries,
            ),
            const SizedBox(height: 24),
            _LedgerFilters(
              entries: entries,
              bankBalances: data.balances,
              fromDate: _fromDate,
              toDate: _toDate,
              selectedAccount: _selectedAccount,
              onFromDateChanged: (value) => setState(() {
                _fromDate = value;
              }),
              onToDateChanged: (value) => setState(() {
                _toDate = value;
              }),
              onAccountChanged: (value) => setState(() {
                _selectedAccount = value;
              }),
              onClearFilters: () => setState(() {
                _fromDate = null;
                _toDate = null;
                _selectedAccount = null;
              }),
            ),
            const SizedBox(height: 20),
            _LedgerTableView(
              entries: entries,
              metrics: metrics,
              loading: loading,
            ),
          ],
        );
      },
    );
  }

  List<LedgerEntry> _filterEntries(List<LedgerEntry> entries, String query) {
    final normalizedQuery = query.trim().toLowerCase();

    return entries.where((entry) {
      if (normalizedQuery.isNotEmpty &&
          !_entryMatchesQuery(entry, normalizedQuery)) {
        return false;
      }

      if (_fromDate != null && entry.date.isBefore(_fromDate!)) {
        return false;
      }

      if (_toDate != null && entry.date.isAfter(_toDate!)) {
        return false;
      }

      if (_selectedAccount != null &&
          !_sameAccount(entry.ledgerRef, _selectedAccount!)) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _entryMatchesQuery(LedgerEntry entry, String query) {
    final searchable = [
      entry.particulars,
      entry.ledgerRef,
      entry.status,
      _formatCurrency(entry.debit),
      _formatCurrency(entry.credit),
      ...entry.tags,
    ].join(' ').toLowerCase();

    return searchable.contains(query);
  }
}

class _LedgerLoadingContent extends StatelessWidget {
  const _LedgerLoadingContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _MetricGridSkeleton(count: 3),
        SizedBox(height: 24),
        _PanelSkeleton(rows: 3),
        SizedBox(height: 24),
        _PanelSkeleton(rows: 2),
        SizedBox(height: 20),
        _PanelSkeleton(rows: 6, table: true),
      ],
    );
  }
}

class _LedgerMetrics {
  final double openingBalance;
  final double receivedDebit;
  final double paidCredit;
  final double receivable;
  final double payable;
  final double availableBalance;
  final int pendingCount;

  const _LedgerMetrics({
    required this.openingBalance,
    required this.receivedDebit,
    required this.paidCredit,
    required this.receivable,
    required this.payable,
    required this.availableBalance,
    required this.pendingCount,
  });

  factory _LedgerMetrics.fromData({
    required List<LedgerEntry> entries,
    required List<BankBalance> balances,
    String? selectedAccount,
  }) {
    final openingBalance = selectedAccount == null
        ? balances.fold<double>(0, (sum, account) => sum + account.balance)
        : balances
            .where(
                (account) => _sameAccount(account.displayName, selectedAccount))
            .fold<double>(0, (sum, account) => sum + account.balance);

    var receivedDebit = 0.0;
    var paidCredit = 0.0;
    var receivable = 0.0;
    var payable = 0.0;
    var pendingCount = 0;

    for (final entry in entries) {
      final status = _normalizeLedgerStatus(entry.status);

      if (entry.debit > 0) {
        if (status == 'Received') {
          receivedDebit += entry.debit;
        } else {
          receivable += entry.debit;
          pendingCount++;
        }
      }

      if (entry.credit > 0) {
        if (status == 'Paid') {
          paidCredit += entry.credit;
        } else {
          payable += entry.credit;
          pendingCount++;
        }
      }
    }

    return _LedgerMetrics(
      openingBalance: openingBalance,
      receivedDebit: receivedDebit,
      paidCredit: paidCredit,
      receivable: receivable,
      payable: payable,
      availableBalance: openingBalance + receivedDebit - paidCredit,
      pendingCount: pendingCount,
    );
  }
}

class _LedgerMetricCards extends StatelessWidget {
  final _LedgerMetrics metrics;
  final bool loading;

  const _LedgerMetricCards({
    required this.metrics,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minTileWidth: 260,
      children: [
        _MetricCard(
          label: 'AVAILABLE BALANCE',
          value: _formatCurrency(metrics.availableBalance),
          color: _appAccent(context),
          note: loading ? 'Loading balances' : 'Opening + received - paid',
        ),
        _MetricCard(
          label: 'TO RECEIVE',
          value: _formatCurrency(metrics.receivable),
          color: _green,
          note: '${metrics.pendingCount} pending vouchers',
        ),
        _MetricCard(
          label: 'TO PAY',
          value: _formatCurrency(metrics.payable),
          color: _red,
          note: '${_formatCurrency(metrics.payable)} pending',
        ),
      ],
    );
  }
}

class _BankAccountDetails extends StatelessWidget {
  final List<BankBalance> balances;
  final bool loading;
  final String? selectedAccount;
  final List<LedgerEntry> entries;

  const _BankAccountDetails({
    required this.balances,
    required this.loading,
    required this.selectedAccount,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final visibleBalances = selectedAccount == null
        ? balances
        : balances.where((account) {
            return _sameAccount(account.displayName, selectedAccount!);
          }).toList();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: _Label('LINKED BANK ACCOUNTS')),
              Text(
                loading
                    ? 'Sync pending'
                    : selectedAccount == null
                        ? '${balances.length} accounts'
                        : 'Selected bank',
                style: TextStyle(
                  color: _appMuted(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (visibleBalances.isEmpty)
            Text(
              loading
                  ? 'Loading bank account balances...'
                  : 'No bank accounts configured.',
              style: TextStyle(color: _appMuted(context)),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 1080;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: visibleBalances.map((account) {
                    final bankEntries = entries.where((entry) {
                      return _sameAccount(entry.ledgerRef, account.displayName);
                    }).toList();

                    final metrics = _LedgerMetrics.fromData(
                      entries: bankEntries,
                      balances: [account],
                      selectedAccount: account.displayName,
                    );

                    return SizedBox(
                      width: compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 24) / 3,
                      child: _BankAccountTile(
                        account: account,
                        availableBalance: metrics.availableBalance,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BankAccountTile extends StatelessWidget {
  final BankBalance account;
  final double availableBalance;

  const _BankAccountTile({
    required this.account,
    required this.availableBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _appSoftSurface(context),
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            account.accountName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            '${account.bankName} • ${account.accountType}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _appMuted(context)),
          ),
          const SizedBox(height: 14),
          Text(
            _formatCurrency(availableBalance),
            style: TextStyle(
              color: _appAccent(context),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Available balance',
            style: TextStyle(
              color: _appMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerFilters extends StatelessWidget {
  final List<LedgerEntry> entries;
  final List<BankBalance> bankBalances;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? selectedAccount;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;
  final ValueChanged<String?> onAccountChanged;
  final VoidCallback onClearFilters;

  const _LedgerFilters({
    required this.entries,
    required this.bankBalances,
    required this.fromDate,
    required this.toDate,
    required this.selectedAccount,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onAccountChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1080;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('DATE RANGE'),
                const SizedBox(height: 8),
                _DateTimeFilterButton(
                  value: fromDate,
                  placeholder: 'Start date & time',
                  onChanged: onFromDateChanged,
                ),
                const SizedBox(height: 10),
                _DateTimeFilterButton(
                  value: toDate,
                  placeholder: 'End date & time',
                  onChanged: onToDateChanged,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: selectedAccount,
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Accounts'),
                    ),
                    ...bankBalances.map(
                      (account) => DropdownMenuItem<String>(
                        value: account.displayName,
                        child: Text(
                          account.displayName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: onAccountChanged,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: _appAccent(context),
                          minimumSize: const Size.fromHeight(52),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('${entries.length} entries matched.')),
                          );
                        },
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filter'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _appAccent(context),
                          minimumSize: const Size.fromHeight(52),
                          side: const BorderSide(color: _primary),
                        ),
                        onPressed: onClearFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _LedgerStatementButton(
                      icon: Icons.table_view_outlined,
                      label: 'Export Excel',
                      onPressed: () => _runStatementAction(
                        context,
                        exportLedgerStatement(entries, bankBalances),
                      ),
                    ),
                    _LedgerStatementButton(
                      icon: Icons.chat_outlined,
                      label: 'Send WhatsApp',
                      onPressed: () => _runStatementAction(
                        context,
                        emailLedgerStatement(entries, bankBalances),
                      ),
                    ),
                    _LedgerStatementButton(
                      icon: Icons.chat_outlined,
                      label: 'WhatsApp',
                      onPressed: () => _runStatementAction(
                        context,
                        whatsappLedgerStatement(entries, bankBalances),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }

          final availableWidth = constraints.maxWidth;
          final gap = 14.0;
          final buttonWidth = 150.0;
          final dateWidth = 460.0;
          final accountWidth = availableWidth -
              dateWidth -
              buttonWidth -
              buttonWidth -
              (gap * 3);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: dateWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Label('DATE RANGE'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DateTimeFilterButton(
                                value: fromDate,
                                placeholder: 'Start date & time',
                                onChanged: onFromDateChanged,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text('to'),
                            ),
                            Expanded(
                              child: _DateTimeFilterButton(
                                value: toDate,
                                placeholder: 'End date & time',
                                onChanged: onToDateChanged,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: accountWidth.clamp(260.0, 420.0),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedAccount,
                      decoration: const InputDecoration(
                        labelText: 'Account',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Accounts'),
                        ),
                        ...bankBalances.map(
                          (account) => DropdownMenuItem<String>(
                            value: account.displayName,
                            child: Text(
                              account.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: onAccountChanged,
                    ),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: buttonWidth,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: _appAccent(context),
                        minimumSize: const Size(150, 52),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('${entries.length} entries matched.')),
                        );
                      },
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                    ),
                  ),
                  SizedBox(width: gap),
                  SizedBox(
                    width: buttonWidth,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _appAccent(context),
                        minimumSize: const Size(150, 52),
                        side: const BorderSide(color: _primary),
                      ),
                      onPressed: onClearFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _LedgerStatementButton(
                    icon: Icons.table_view_outlined,
                    label: 'Export Excel',
                    onPressed: () => _runStatementAction(
                      context,
                      exportLedgerStatement(entries, bankBalances),
                    ),
                  ),
                  _LedgerStatementButton(
                    icon: Icons.chat_outlined,
                    label: 'Send WhatsApp',
                    onPressed: () => _runStatementAction(
                      context,
                      emailLedgerStatement(entries, bankBalances),
                    ),
                  ),
                  _LedgerStatementButton(
                    icon: Icons.chat_outlined,
                    label: 'WhatsApp',
                    onPressed: () => _runStatementAction(
                      context,
                      whatsappLedgerStatement(entries, bankBalances),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _runStatementAction(
    BuildContext context,
    Future<String> action,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final message = await action;
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LedgerStatementButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _LedgerStatementButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: _appAccent(context),
          minimumSize: const Size(150, 48),
          side: const BorderSide(color: _primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _LedgerTableView extends StatelessWidget {
  final List<LedgerEntry> entries;
  final _LedgerMetrics metrics;
  final bool loading;

  const _LedgerTableView({
    required this.entries,
    required this.metrics,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth < _ledgerTableWidth
            ? _ledgerTableWidth
            : constraints.maxWidth;

        final particularsWidth = tableWidth -
            _ledgerDateWidth -
            _ledgerRefWidth -
            _ledgerDebitWidth -
            _ledgerCreditWidth -
            _ledgerActionWidth;

        return _Panel(
          padding: EdgeInsets.zero,
          child: _HorizontalScrollView(
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _LedgerHeaderRow(particularsWidth: particularsWidth),
                  if (loading)
                    const _LedgerLoadingRow()
                  else if (entries.isEmpty)
                    const _LedgerEmptyRow()
                  else
                    ...entries.map(
                      (entry) => _LedgerDataRow(
                        entry: entry,
                        particularsWidth: particularsWidth,
                      ),
                    ),
                  _LedgerFooterRow(
                    metrics: metrics,
                    particularsWidth: particularsWidth,
                    loading: loading,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LedgerHeaderRow extends StatelessWidget {
  final double particularsWidth;

  const _LedgerHeaderRow({required this.particularsWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _appHeaderSurface(context),
      child: Row(
        children: [
          const _LedgerCell(
            width: _ledgerDateWidth,
            child: _LedgerHeader('DATE'),
          ),
          _LedgerCell(
            width: particularsWidth,
            child: const _LedgerHeader('PARTICULARS'),
          ),
          const _LedgerCell(
            width: _ledgerRefWidth,
            child: _LedgerHeader('ACCOUNT'),
          ),
          const _LedgerCell(
            width: _ledgerDebitWidth,
            alignEnd: true,
            child: _LedgerHeader('DEBIT RECEIVED'),
          ),
          const _LedgerCell(
            width: _ledgerCreditWidth,
            alignEnd: true,
            child: _LedgerHeader('CREDIT PAID'),
          ),
          const _LedgerCell(
            width: _ledgerActionWidth,
            alignCenter: true,
            child: _LedgerHeader('STATUS / ACTION'),
          ),
        ],
      ),
    );
  }
}

class _LedgerDataRow extends StatelessWidget {
  final LedgerEntry entry;
  final double particularsWidth;

  const _LedgerDataRow({
    required this.entry,
    required this.particularsWidth,
  });

  @override
  Widget build(BuildContext context) {
    final status = _normalizeLedgerStatus(entry.status);

    final debitReceived =
        entry.debit > 0 && status == 'Received' ? entry.debit : 0.0;

    final creditPaid =
        entry.credit > 0 && status == 'Paid' ? entry.credit : 0.0;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _appBorder(context))),
      ),
      child: Row(
        children: [
          _LedgerCell(
            width: _ledgerDateWidth,
            child: Text(
              _formatDate(entry.date),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          _LedgerCell(
            width: particularsWidth,
            child: _TwoLineText(entry.particulars),
          ),
          _LedgerCell(
            width: _ledgerRefWidth,
            child: Text(
              entry.ledgerRef,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
          _LedgerCell(
            width: _ledgerDebitWidth,
            alignEnd: true,
            child: _LedgerAmountText(
              value: _formatIndianAmount(debitReceived),
              color: debitReceived == 0 ? _appMuted(context) : _green,
            ),
          ),
          _LedgerCell(
            width: _ledgerCreditWidth,
            alignEnd: true,
            child: _LedgerAmountText(
              value: _formatIndianAmount(creditPaid),
              color: creditPaid == 0 ? _appMuted(context) : _red,
            ),
          ),
          _LedgerCell(
            width: _ledgerActionWidth,
            alignCenter: true,
            child: _LedgerStatusAction(entry: entry),
          ),
        ],
      ),
    );
  }
}

class _LedgerFooterRow extends StatelessWidget {
  final _LedgerMetrics metrics;
  final double particularsWidth;
  final bool loading;

  const _LedgerFooterRow({
    required this.metrics,
    required this.particularsWidth,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _appHeaderSurface(context),
      child: Row(
        children: [
          _LedgerCell(
            width: _ledgerDateWidth + particularsWidth + _ledgerRefWidth,
            child: Text(
              loading ? 'LOADING LIVE LEDGER...' : 'AVAILABLE BALANCE TOTAL',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _appAccent(context),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _LedgerCell(
            width: _ledgerDebitWidth,
            alignEnd: true,
            child: _LedgerAmountText(
              value: _formatCurrency(metrics.receivedDebit),
              color: _green,
              large: true,
            ),
          ),
          _LedgerCell(
            width: _ledgerCreditWidth,
            alignEnd: true,
            child: _LedgerAmountText(
              value: _formatCurrency(metrics.paidCredit),
              color: _red,
              large: true,
            ),
          ),
          _LedgerCell(
            width: _ledgerActionWidth,
            alignEnd: true,
            child: _LedgerAmountText(
              value: _formatCurrency(metrics.availableBalance),
              color: _appAccent(context),
              large: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerStatusAction extends ConsumerWidget {
  final LedgerEntry entry;

  const _LedgerStatusAction({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStatus = _normalizeLedgerStatus(entry.status);

    final statuses = entry.debit > 0
        ? const ['Received', 'To Receive']
        : const ['Paid', 'Unpaid', 'On Hold'];

    return PopupMenuButton<String>(
      tooltip: 'Change status',
      onSelected: (value) {
        if (value == '__delete') {
          _deleteEntry(context, ref);
          return;
        }

        _updateStatus(context, ref, value);
      },
      itemBuilder: (context) {
        return [
          ...statuses.map(
            (status) => PopupMenuItem(
              value: status,
              child: Row(
                children: [
                  Icon(
                    status == currentStatus
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: _ledgerStatusColor(status),
                  ),
                  const SizedBox(width: 10),
                  Text(status),
                ],
              ),
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: '__delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 18, color: _red),
                SizedBox(width: 10),
                Text('Delete', style: TextStyle(color: _red)),
              ],
            ),
          ),
        ];
      },
      child: _StatusActionChip(status: currentStatus),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    final currentStatus = _normalizeLedgerStatus(entry.status);
    if (status == currentStatus) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save status change?'),
        content: Text(
          'Save "${entry.particulars}" as $status for now? You can change it again later if the transaction moves from on hold, unpaid, or pending.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref
          .read(backendApiProvider)
          .updateLedgerEntry(entry.id, {'status': status});
      ref.invalidate(ledgerDataProvider);
      await ref.read(ledgerDataProvider.future);

      messenger.showSnackBar(
        SnackBar(content: Text('Status changed to $status.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  Future<void> _deleteEntry(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete ledger entry?'),
        content: Text(
          'This will remove "${entry.particulars}" from the ledger.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(backendApiProvider).deleteLedgerEntry(entry.id);
      ref.invalidate(ledgerDataProvider);
      await ref.read(ledgerDataProvider.future);

      messenger.showSnackBar(
        const SnackBar(content: Text('Ledger entry deleted.')),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _StatusActionChip extends StatelessWidget {
  final String status;

  const _StatusActionChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _ledgerStatusColor(status);

    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        border: Border.all(color: color.withAlpha(90)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.expand_more, color: color, size: 16),
        ],
      ),
    );
  }
}

class _LedgerLoadingRow extends StatelessWidget {
  const _LedgerLoadingRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _appBorder(context))),
      ),
      child: const CircularProgressIndicator(),
    );
  }
}

class _LedgerEmptyRow extends StatelessWidget {
  const _LedgerEmptyRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _appBorder(context))),
      ),
      child: Text(
        'No ledger entries found',
        style: TextStyle(
          color: _appMuted(context),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LedgerCell extends StatelessWidget {
  final double width;
  final Widget child;
  final bool alignEnd;
  final bool alignCenter;

  const _LedgerCell({
    required this.width,
    required this.child,
    this.alignEnd = false,
    this.alignCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Align(
          alignment: alignCenter
              ? Alignment.center
              : alignEnd
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}

class _LedgerHeader extends StatelessWidget {
  final String label;

  const _LedgerHeader(this.label);

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

class _LedgerAmountText extends StatelessWidget {
  final String value;
  final Color color;
  final bool large;

  const _LedgerAmountText({
    required this.value,
    required this.color,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: color,
        fontSize: large ? 16 : 15,
        fontWeight: large ? FontWeight.w800 : FontWeight.w600,
      ),
    );
  }
}

class _DateTimeFilterButton extends StatelessWidget {
  final DateTime? value;
  final String placeholder;
  final ValueChanged<DateTime?> onChanged;

  const _DateTimeFilterButton({
    required this.value,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _pickDateTime(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.event_available_outlined),
        ),
        child: Text(value == null ? placeholder : _formatDateTime(value!)),
      ),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final base = value ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null || !context.mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );

    if (time == null) {
      return;
    }

    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }
}

String _cleanAccountName(String value) {
  return value
      .toLowerCase()
      .replaceAll('...', '')
      .replaceAll('•', '-')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _sameAccount(String a, String b) {
  final left = _cleanAccountName(a);
  final right = _cleanAccountName(b);

  return left == right || left.contains(right) || right.contains(left);
}
