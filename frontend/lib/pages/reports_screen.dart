// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/reports',
      searchHint: 'Search reports...',
      floatingIcon: Icons.analytics_outlined,
      child: _ReportsContent(),
    );
  }
}

class _ReportsContent extends ConsumerStatefulWidget {
  const _ReportsContent();

  @override
  ConsumerState<_ReportsContent> createState() => _ReportsContentState();
}

class _ReportsContentState extends ConsumerState<_ReportsContent> {
  DateTime? _fromDate;
  DateTime? _toDate;
  String _period = 'month';

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerDataProvider);
    final loading = ledgerState.isLoading;
    final data =
        loading ? LedgerData.empty() : ledgerState.value ?? LedgerData.empty();

    if (loading) {
      return _ReportsLoadingContent(
        period: _period,
        fromDate: _fromDate,
        toDate: _toDate,
        onPeriodChanged: (value) {
          setState(() {
            _period = value;
            _fromDate = null;
            _toDate = null;
          });
        },
        onFromDateChanged: (value) => setState(() {
          _fromDate = value;
          _period = 'custom';
        }),
        onToDateChanged: (value) => setState(() {
          _toDate = value;
          _period = 'custom';
        }),
        onClear: () => setState(() {
          _period = 'month';
          _fromDate = null;
          _toDate = null;
        }),
      );
    }

    final filteredEntries = _filterEntries(data.entries);

    final metrics = _LedgerMetrics.fromData(
      entries: filteredEntries,
      balances: data.balances,
    );

    final report = _ReportData.fromEntries(
      entries: filteredEntries,
      balances: data.balances,
    );

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
        _ReportHeader(
          period: _period,
          fromDate: _fromDate,
          toDate: _toDate,
          onPeriodChanged: (value) {
            setState(() {
              _period = value;
              _fromDate = null;
              _toDate = null;
            });
          },
          onFromDateChanged: (value) => setState(() {
            _fromDate = value;
            _period = 'custom';
          }),
          onToDateChanged: (value) => setState(() {
            _toDate = value;
            _period = 'custom';
          }),
          onClear: () => setState(() {
            _period = 'month';
            _fromDate = null;
            _toDate = null;
          }),
        ),
        const SizedBox(height: 24),
        _ReportMetricCards(
          metrics: metrics,
          report: report,
          loading: loading,
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 900;

            if (compact) {
              return Column(
                children: [
                  _AccountBarChart(report: report),
                  const SizedBox(height: 20),
                  _ProfitLossChart(report: report),
                  const SizedBox(height: 20),
                  _GstComplianceCard(report: report),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _AccountBarChart(report: report),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      _ProfitLossChart(report: report),
                      const SizedBox(height: 20),
                      _GstComplianceCard(report: report),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _RevenueBreakdownTable(entries: filteredEntries),
      ],
    );
  }

  List<LedgerEntry> _filterEntries(List<LedgerEntry> entries) {
    final now = DateTime.now();

    DateTime start;
    DateTime end = now;

    if (_period == 'week') {
      start = now.subtract(const Duration(days: 7));
    } else if (_period == 'year') {
      start = DateTime(now.year, 1, 1);
    } else if (_period == 'custom') {
      start = _fromDate ?? DateTime(2000);
      end = _toDate ?? now;
    } else {
      start = DateTime(now.year, now.month, 1);
    }

    return entries.where((entry) {
      return !entry.date.isBefore(start) && !entry.date.isAfter(end);
    }).toList();
  }
}

class _ReportsLoadingContent extends StatelessWidget {
  final String period;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;
  final VoidCallback onClear;

  const _ReportsLoadingContent({
    required this.period,
    required this.fromDate,
    required this.toDate,
    required this.onPeriodChanged,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ReportHeader(
          period: period,
          fromDate: fromDate,
          toDate: toDate,
          onPeriodChanged: onPeriodChanged,
          onFromDateChanged: onFromDateChanged,
          onToDateChanged: onToDateChanged,
          onClear: onClear,
        ),
        const SizedBox(height: 24),
        const _MetricGridSkeleton(count: 4, minTileWidth: 240),
        const SizedBox(height: 24),
        const _PanelSkeleton(rows: 5),
        const SizedBox(height: 24),
        const _PanelSkeleton(rows: 6, table: true),
      ],
    );
  }
}

class _ReportData {
  final double revenue;
  final double expense;
  final double profitOrLoss;
  final double receivable;
  final double payable;
  final double gstOutput;
  final double gstInput;
  final List<_AccountReport> accounts;

  const _ReportData({
    required this.revenue,
    required this.expense,
    required this.profitOrLoss,
    required this.receivable,
    required this.payable,
    required this.gstOutput,
    required this.gstInput,
    required this.accounts,
  });

  factory _ReportData.fromEntries({
    required List<LedgerEntry> entries,
    required List<BankBalance> balances,
  }) {
    final accountMap = <String, _AccountReport>{};

    double revenue = 0;
    double expense = 0;
    double receivable = 0;
    double payable = 0;

    for (final entry in entries) {
      final status = _normalizeLedgerStatus(entry.status);
      final account =
          entry.ledgerRef.trim().isEmpty ? 'Unknown' : entry.ledgerRef;

      final existing = accountMap[account] ??
          _AccountReport(
            account: account,
            revenue: 0,
            expense: 0,
            receivable: 0,
            payable: 0,
          );

      if (entry.debit > 0) {
        if (status == 'Received') {
          revenue += entry.debit;
          accountMap[account] = existing.copyWith(
            revenue: existing.revenue + entry.debit,
          );
        } else {
          receivable += entry.debit;
          accountMap[account] = existing.copyWith(
            receivable: existing.receivable + entry.debit,
          );
        }
      }

      if (entry.credit > 0) {
        if (status == 'Paid') {
          expense += entry.credit;
          accountMap[account] = existing.copyWith(
            expense: existing.expense + entry.credit,
          );
        } else {
          payable += entry.credit;
          accountMap[account] = existing.copyWith(
            payable: existing.payable + entry.credit,
          );
        }
      }
    }

    final gstOutput = revenue * 0.18;
    final gstInput = expense * 0.18;

    return _ReportData(
      revenue: revenue,
      expense: expense,
      profitOrLoss: revenue - expense,
      receivable: receivable,
      payable: payable,
      gstOutput: gstOutput,
      gstInput: gstInput,
      accounts: accountMap.values.toList(),
    );
  }
}

class _AccountReport {
  final String account;
  final double revenue;
  final double expense;
  final double receivable;
  final double payable;

  const _AccountReport({
    required this.account,
    required this.revenue,
    required this.expense,
    required this.receivable,
    required this.payable,
  });

  _AccountReport copyWith({
    double? revenue,
    double? expense,
    double? receivable,
    double? payable,
  }) {
    return _AccountReport(
      account: account,
      revenue: revenue ?? this.revenue,
      expense: expense ?? this.expense,
      receivable: receivable ?? this.receivable,
      payable: payable ?? this.payable,
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final String period;
  final DateTime? fromDate;
  final DateTime? toDate;
  final ValueChanged<String> onPeriodChanged;
  final ValueChanged<DateTime?> onFromDateChanged;
  final ValueChanged<DateTime?> onToDateChanged;
  final VoidCallback onClear;

  const _ReportHeader({
    required this.period,
    required this.fromDate,
    required this.toDate,
    required this.onPeriodChanged,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(
            width: 260,
            child: DropdownButtonFormField<String>(
              initialValue: period,
              decoration: const InputDecoration(
                labelText: 'Report Period',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'week', child: Text('This Week')),
                DropdownMenuItem(value: 'month', child: Text('This Month')),
                DropdownMenuItem(value: 'year', child: Text('This Year')),
                DropdownMenuItem(value: 'custom', child: Text('Custom Date')),
              ],
              onChanged: (value) {
                if (value != null) onPeriodChanged(value);
              },
            ),
          ),
          SizedBox(
            width: 230,
            child: _ReportDateButton(
              value: fromDate,
              label: 'From Date',
              onChanged: onFromDateChanged,
            ),
          ),
          SizedBox(
            width: 230,
            child: _ReportDateButton(
              value: toDate,
              label: 'To Date',
              onChanged: onToDateChanged,
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _primary,
              minimumSize: const Size(130, 52),
              side: const BorderSide(color: _primary),
            ),
            onPressed: onClear,
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _ReportDateButton extends StatelessWidget {
  final DateTime? value;
  final String label;
  final ValueChanged<DateTime?> onChanged;

  const _ReportDateButton({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );

        if (picked != null) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(value == null ? 'Select date' : _formatDate(value!)),
      ),
    );
  }
}

class _ReportMetricCards extends StatelessWidget {
  final _LedgerMetrics metrics;
  final _ReportData report;
  final bool loading;

  const _ReportMetricCards({
    required this.metrics,
    required this.report,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minTileWidth: 240,
      children: [
        _MetricCard(
          label: 'REVENUE',
          value: _formatCurrency(report.revenue),
          color: _green,
          note: loading ? 'Loading...' : 'Received debit',
          icon: Icons.trending_up,
        ),
        _MetricCard(
          label: 'EXPENSE',
          value: _formatCurrency(report.expense),
          color: _red,
          note: 'Paid credit',
          icon: Icons.trending_down,
        ),
        _MetricCard(
          label: report.profitOrLoss >= 0 ? 'PROFIT' : 'LOSS',
          value: _formatCurrency(report.profitOrLoss.abs()),
          color: report.profitOrLoss >= 0 ? _green : _red,
          note: 'Revenue minus expense',
          icon: Icons.analytics_outlined,
        ),
        _MetricCard(
          label: 'GST PAYABLE',
          value: _formatCurrency(
              (report.gstOutput - report.gstInput).clamp(0, double.infinity)),
          color: _appAccent(context),
          note: 'Output GST - Input GST',
          icon: Icons.receipt_long_outlined,
        ),
      ],
    );
  }
}

class _AccountBarChart extends StatelessWidget {
  final _ReportData report;

  const _AccountBarChart({required this.report});

  @override
  Widget build(BuildContext context) {
    final accounts = report.accounts.take(8).toList();

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account-wise Revenue / Expense',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            children: [
              const _Legend(color: _green, label: 'Revenue'),
              const _Legend(color: _red, label: 'Expense'),
              _Legend(color: _appAccent(context), label: 'Receivable'),
            ],
          ),
          const SizedBox(height: 24),
          if (accounts.isEmpty)
            const _EmptyPanelMessage(
              icon: Icons.bar_chart_outlined,
              title: 'No chart data',
              subtitle: 'Charts will appear after ledger entries are saved.',
            )
          else
            SizedBox(
              height: 320,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _maxChartY(accounts),
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value == 0
                                ? '0'
                                : '${(value / 1000).toStringAsFixed(0)}k',
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= accounts.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SizedBox(
                              width: 70,
                              child: Text(
                                accounts[index].account,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(accounts.length, (index) {
                    final account = accounts[index];

                    return BarChartGroupData(
                      x: index,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: account.revenue,
                          width: 10,
                          color: _green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: account.expense,
                          width: 10,
                          color: _red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: account.receivable,
                          width: 10,
                          color: _appAccent(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
                swapAnimationDuration: const Duration(milliseconds: 700),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),
        ],
      ),
    );
  }

  double _maxChartY(List<_AccountReport> accounts) {
    double max = 1000;

    for (final account in accounts) {
      max = [
        max,
        account.revenue,
        account.expense,
        account.receivable,
        account.payable,
      ].reduce((a, b) => a > b ? a : b);
    }

    return max * 1.25;
  }
}

class _ProfitLossChart extends StatelessWidget {
  final _ReportData report;

  const _ProfitLossChart({required this.report});

  @override
  Widget build(BuildContext context) {
    final profit = report.profitOrLoss >= 0 ? report.profitOrLoss : 0.0;
    final loss = report.profitOrLoss < 0 ? report.profitOrLoss.abs() : 0.0;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profit / Loss Analysis',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 48,
                sections: [
                  PieChartSectionData(
                    value: report.revenue <= 0 ? 1 : report.revenue,
                    title: 'Revenue',
                    color: _green,
                    radius: 58,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  PieChartSectionData(
                    value: report.expense <= 0 ? 1 : report.expense,
                    title: 'Expense',
                    color: _red,
                    radius: 58,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              swapAnimationDuration: const Duration(milliseconds: 700),
              swapAnimationCurve: Curves.easeOutCubic,
            ),
          ),
          const SizedBox(height: 16),
          _MiniReportRow(
              label: 'Revenue', value: report.revenue, color: _green),
          _MiniReportRow(label: 'Expense', value: report.expense, color: _red),
          _MiniReportRow(
            label: profit > 0
                ? 'Profit'
                : loss > 0
                    ? 'Loss'
                    : 'No Profit/Loss',
            value: report.profitOrLoss.abs(),
            color: report.profitOrLoss >= 0 ? _green : _red,
          ),
        ],
      ),
    );
  }
}

class _GstComplianceCard extends StatelessWidget {
  final _ReportData report;

  const _GstComplianceCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final gstPayable = report.gstOutput - report.gstInput;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GST Compliance Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 20),
          _ComplianceTile(
            icon: Icons.receipt_long_outlined,
            title: 'Output GST',
            subtitle: _formatCurrency(report.gstOutput),
            color: _green,
          ),
          _ComplianceTile(
            icon: Icons.payments_outlined,
            title: 'Input GST',
            subtitle: _formatCurrency(report.gstInput),
            color: _appAccent(context),
          ),
          _ComplianceTile(
            icon: gstPayable >= 0
                ? Icons.warning_amber_outlined
                : Icons.check_circle_outline,
            title: gstPayable >= 0 ? 'GST Payable' : 'GST Credit',
            subtitle: _formatCurrency(gstPayable.abs()),
            color: gstPayable >= 0 ? _red : _green,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: _primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('GST summary generated.')),
                );
              },
              icon: const Icon(Icons.summarize_outlined),
              label: const Text('Generate GST Summary'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueBreakdownTable extends StatelessWidget {
  final List<LedgerEntry> entries;

  const _RevenueBreakdownTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    final List<List<Widget>> rows = entries.map((entry) {
      final status = _normalizeLedgerStatus(entry.status);
      final revenue = entry.debit > 0 ? entry.debit : 0.0;
      final cost = entry.credit > 0 ? entry.credit : 0.0;
      final margin = revenue - cost;

      return [
        Text(entry.particulars),
        Text(_formatCurrency(revenue)),
        Text(_formatCurrency(cost)),
        Text(
          _formatCurrency(margin),
          style: TextStyle(
            color: margin >= 0 ? _green : _red,
            fontWeight: FontWeight.w700,
          ),
        ),
        _Chip(
          label: status,
          color: _ledgerStatusColor(status),
        ),
      ];
    }).toList();

    return _DataPanel(
      title: 'Detailed Revenue Report',
      columns: const [
        'PARTICULARS',
        'REVENUE (₹)',
        'COST (₹)',
        'MARGIN (₹)',
        'STATUS',
      ],
      rows: rows,
      footer: rows.isEmpty
          ? const _EmptyPanelMessage(
              icon: Icons.stacked_line_chart,
              title: 'No revenue breakdown yet',
              subtitle:
                  'Breakdowns will appear after ledger entries are saved.',
            )
          : null,
    );
  }
}

class _MiniReportRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniReportRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ComplianceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withAlpha(70),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
