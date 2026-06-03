// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/settings',
      searchHint: 'Search settings...',
      floatingIcon: Icons.save_outlined,
      child: _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatefulWidget {
  const _SettingsContent();

  @override
  State<_SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<_SettingsContent> {
  bool gstAlerts = true;
  bool payableAlerts = true;
  bool monthlyCloseAlerts = true;
  bool adminApproval = true;
  String reviewPeriod = 'This Month';
  final Map<String, String> directorReviews = {};

  static const String companyName =
      'DHINADTS IT SOLUTIONS AND SUPPORT (OPC) PRIVATE LIMITED';
  static const String tradeName =
      'DHINADTS IT SOLUTIONS AND SUPPORT (OPC) PRIVATE LIMITED';
  static const String gstin = '33AALCD1728Q1Z9';
  static const String registrationType = 'Regular';
  static const String registrationDate = '23 Dec 2024';
  static const String directorName = 'DHINAKARAN KALAIMANI';
  static const String directorStatus = 'DIRECTOR';
  static const String state = 'Tamil Nadu';

  static const String address =
      'Old No 74/1, New No 122G/4J, Sakthivel Nager, Seetharam Palayam, Tiruchengode, Namakkal, Tamil Nadu - 637209';

  @override
  void initState() {
    super.initState();
    _loadDirectorReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle(
          title: 'Settings',
          subtitle:
              'Company profile, GST compliance, ledger defaults, alerts, and access control.',
        ),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 320,
          children: [
            _SettingsCard(
              icon: Icons.business_outlined,
              title: 'Company Profile',
              description: companyName,
              status: 'Configured',
              statusColor: _green,
              onTap: () => _showCompanyProfile(context),
            ),
            _SettingsCard(
              icon: Icons.receipt_long_outlined,
              title: 'GST Compliance',
              description: 'GSTIN $gstin • $registrationType registration',
              status: 'Active',
              statusColor: _green,
              onTap: () => _showGstDetails(context),
            ),
            _SettingsCard(
              icon: Icons.menu_book_outlined,
              title: 'Ledger Defaults',
              description:
                  'INR currency, debit/credit status logic, GV/PV/SI voucher prefixes, and account groups.',
              status: 'Ready',
              statusColor: _appAccent(context),
              onTap: () => _showLedgerDefaults(context),
            ),
            _SettingsCard(
              icon: Icons.security_outlined,
              title: 'Access Control',
              description: '$directorName is configured as company admin.',
              status: '1 admin',
              statusColor: _green,
              onTap: () => _showAccessControl(context),
            ),
            _SettingsCard(
              icon: Icons.notifications_active_outlined,
              title: 'Alerts',
              description:
                  'GST filing, overdue payables, and monthly close reminders.',
              status: gstAlerts || payableAlerts || monthlyCloseAlerts
                  ? 'On'
                  : 'Off',
              statusColor: gstAlerts || payableAlerts || monthlyCloseAlerts
                  ? _green
                  : _muted,
              onTap: () => _showAlerts(context),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _PreferencePanel(
          gstAlerts: gstAlerts,
          payableAlerts: payableAlerts,
          monthlyCloseAlerts: monthlyCloseAlerts,
          adminApproval: adminApproval,
          onGstAlertsChanged: (value) => setState(() => gstAlerts = value),
          onPayableAlertsChanged: (value) =>
              setState(() => payableAlerts = value),
          onMonthlyCloseAlertsChanged: (value) =>
              setState(() => monthlyCloseAlerts = value),
          onAdminApprovalChanged: (value) =>
              setState(() => adminApproval = value),
        ),
        const SizedBox(height: 24),
        _DirectorReviewPanel(
          directorName: directorName,
          selectedPeriod: reviewPeriod,
          reviews: directorReviews,
          onPeriodChanged: (value) => setState(() => reviewPeriod = value),
          onReviewDone: _markDirectorReviewDone,
        ),
      ],
    );
  }

  Future<void> _loadDirectorReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = <String, String>{};
    for (final period in _DirectorReviewPanel.periods) {
      final value = prefs.getString(_reviewKey(period));
      if (value != null) {
        entries[period] = value;
      }
    }
    if (mounted) {
      setState(() => directorReviews.addAll(entries));
    }
  }

  Future<void> _markDirectorReviewDone() async {
    final reviewedAt = DateTime.now().toIso8601String();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reviewKey(reviewPeriod), reviewedAt);
    setState(() => directorReviews[reviewPeriod] = reviewedAt);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$reviewPeriod review marked by $directorName.')),
    );
  }

  String _reviewKey(String period) {
    return 'director_review_${period.toLowerCase().replaceAll(' ', '_')}';
  }

  void _showCompanyProfile(BuildContext context) {
    _showSettingsSheet(
      context,
      title: 'Company Profile',
      children: const [
        _PreferenceRow(label: 'Legal Name', value: companyName),
        _PreferenceRow(label: 'Trade Name', value: tradeName),
        _PreferenceRow(label: 'Constitution', value: 'OPC Private Limited'),
        _PreferenceRow(label: 'Principal Place', value: address),
        _PreferenceRow(label: 'State', value: state),
      ],
    );
  }

  void _showGstDetails(BuildContext context) {
    _showSettingsSheet(
      context,
      title: 'GST Compliance Details',
      children: const [
        _PreferenceRow(label: 'GSTIN', value: gstin),
        _PreferenceRow(label: 'Registration Type', value: registrationType),
        _PreferenceRow(label: 'Valid From', value: registrationDate),
        _PreferenceRow(label: 'Validity', value: 'Not Applicable'),
        _PreferenceRow(label: 'Additional Places', value: '0'),
      ],
    );
  }

  void _showLedgerDefaults(BuildContext context) {
    _showSettingsSheet(
      context,
      title: 'Ledger Defaults',
      children: const [
        _PreferenceRow(label: 'Currency', value: 'Indian Rupee (₹)'),
        _PreferenceRow(label: 'Date Format', value: 'DD MMM YYYY'),
        _PreferenceRow(label: 'Voucher Prefix', value: 'GV / PV / SI'),
        _PreferenceRow(label: 'Debit Status', value: 'Received / To Receive'),
        _PreferenceRow(
            label: 'Credit Status', value: 'Paid / Unpaid / On Hold'),
        _PreferenceRow(
            label: 'Balance Logic',
            value: 'Opening + Received Debit - Paid Credit'),
      ],
    );
  }

  void _showAccessControl(BuildContext context) {
    _showSettingsSheet(
      context,
      title: 'Access Control',
      children: const [
        _PreferenceRow(label: 'Admin Name', value: directorName),
        _PreferenceRow(label: 'Role', value: directorStatus),
        _PreferenceRow(label: 'Resident State', value: state),
        _PreferenceRow(label: 'Approval Mode', value: 'Admin review required'),
      ],
    );
  }

  void _showAlerts(BuildContext context) {
    _showSettingsSheet(
      context,
      title: 'Alerts',
      children: [
        _PreferenceRow(
            label: 'GST Filing Reminder',
            value: gstAlerts ? 'Enabled' : 'Disabled'),
        _PreferenceRow(
            label: 'Overdue Payable Alert',
            value: payableAlerts ? 'Enabled' : 'Disabled'),
        _PreferenceRow(
            label: 'Monthly Close Alert',
            value: monthlyCloseAlerts ? 'Enabled' : 'Disabled'),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 176,
      child: _Panel(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: _primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Chip(label: status, color: statusColor),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _appMuted(context),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tap to view details',
                  style: TextStyle(
                    color: _appAccent(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PreferencePanel extends StatelessWidget {
  final bool gstAlerts;
  final bool payableAlerts;
  final bool monthlyCloseAlerts;
  final bool adminApproval;
  final ValueChanged<bool> onGstAlertsChanged;
  final ValueChanged<bool> onPayableAlertsChanged;
  final ValueChanged<bool> onMonthlyCloseAlertsChanged;
  final ValueChanged<bool> onAdminApprovalChanged;

  const _PreferencePanel({
    required this.gstAlerts,
    required this.payableAlerts,
    required this.monthlyCloseAlerts,
    required this.adminApproval,
    required this.onGstAlertsChanged,
    required this.onPayableAlertsChanged,
    required this.onMonthlyCloseAlertsChanged,
    required this.onAdminApprovalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preference Defaults',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          const _PreferenceRow(label: 'Currency', value: 'Indian Rupee (₹)'),
          const _PreferenceRow(label: 'Date Format', value: 'DD MMM YYYY'),
          const _PreferenceRow(label: 'Voucher Prefix', value: 'GV / PV / SI'),
          const Align(
            alignment: Alignment.centerLeft,
            child: _VoucherPrefixHelpButton(),
          ),
          const _PreferenceRow(
              label: 'Company GSTIN', value: _SettingsContentState.gstin),
          const Divider(height: 28),
          _SwitchPreferenceRow(
            label: 'Admin Approval Required',
            value: adminApproval,
            onChanged: onAdminApprovalChanged,
          ),
          _SwitchPreferenceRow(
            label: 'GST Filing Alerts',
            value: gstAlerts,
            onChanged: onGstAlertsChanged,
          ),
          _SwitchPreferenceRow(
            label: 'Overdue Payable Alerts',
            value: payableAlerts,
            onChanged: onPayableAlertsChanged,
          ),
          _SwitchPreferenceRow(
            label: 'Monthly Close Alerts',
            value: monthlyCloseAlerts,
            onChanged: onMonthlyCloseAlertsChanged,
          ),
        ],
      ),
    );
  }
}

class _DirectorReviewPanel extends StatelessWidget {
  final String directorName;
  final String selectedPeriod;
  final Map<String, String> reviews;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onReviewDone;

  static const periods = ['This Month', 'This Quarter', 'This Year'];

  const _DirectorReviewPanel({
    required this.directorName,
    required this.selectedPeriod,
    required this.reviews,
    required this.onPeriodChanged,
    required this.onReviewDone,
  });

  @override
  Widget build(BuildContext context) {
    final reviewedAt = reviews[selectedPeriod];
    final reviewed = reviewedAt != null;

    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      color: _appAccent(context)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Director Review',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ledger and Balance Sheet review is done by $directorName. Mark the review after checking transactions, status changes, balances, and reports for the selected period.',
                style: TextStyle(color: _appMuted(context)),
              ),
              const SizedBox(height: 14),
              if (reviewed)
                _Chip(
                  label: 'Reviewed ${_formatReviewDate(reviewedAt)}',
                  color: _green,
                  filled: true,
                )
              else
                _Chip(
                  label: 'Review pending',
                  color: _red,
                ),
            ],
          );
          final controls = Column(
            crossAxisAlignment:
                compact ? CrossAxisAlignment.stretch : CrossAxisAlignment.end,
            children: [
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Review Period',
                  border: OutlineInputBorder(),
                ),
                items: periods
                    .map(
                      (period) =>
                          DropdownMenuItem(value: period, child: Text(period)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onPeriodChanged(value);
                  }
                },
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _appAccent(context),
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: onReviewDone,
                icon: const Icon(Icons.fact_check_outlined),
                label: Text('Review done for $selectedPeriod'),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                copy,
                const SizedBox(height: 18),
                controls,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: copy),
              const SizedBox(width: 24),
              SizedBox(width: 300, child: controls),
            ],
          );
        },
      ),
    );
  }

  String _formatReviewDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    return _formatDateTime(parsed);
  }
}

class _PreferenceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreferenceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: _appMuted(context))),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(label, style: TextStyle(color: _appMuted(context))),
              ),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SwitchPreferenceRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchPreferenceRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: _appAccent(context),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(value ? 'Enabled' : 'Disabled'),
      value: value,
      onChanged: onChanged,
    );
  }
}

void _showSettingsSheet(
  BuildContext context, {
  required String title,
  required List<Widget> children,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(120),
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final bottomPadding = media.padding.bottom + 16;

      return Padding(
        padding: EdgeInsets.fromLTRB(14, 0, 14, bottomPadding),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: media.size.height * 0.82,
              maxWidth: 680,
            ),
            child: Material(
              color: Theme.of(sheetContext).cardColor,
              elevation: 14,
              shadowColor: Colors.black.withAlpha(50),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 54,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(120),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: _appAccent(context),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ...children,
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
