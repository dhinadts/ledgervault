// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/help',
      searchHint: 'Search help...',
      floatingIcon: Icons.support_agent_outlined,
      child: _HelpContent(),
    );
  }
}

class _HelpContent extends StatelessWidget {
  const _HelpContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageTitle(
          title: 'Help Center',
          subtitle:
              'Guides for ledger entry, balance sheet review, reports, and GST workflows.',
        ),
        SizedBox(height: 24),
        _ResponsiveGrid(
          minTileWidth: 300,
          tileHeight: 230,
          children: [
            _HelpCard(
              icon: Icons.menu_book_outlined,
              title: 'Ledger Entries',
              description:
                  'Create vouchers, apply filters, export ledger details, and reconcile balances.',
            ),
            _HelpCard(
              icon: Icons.account_balance_outlined,
              title: 'Balance Sheet',
              description:
                  'Review liabilities, assets, compliance notes, and auditor sign-off.',
            ),
            _HelpCard(
              icon: Icons.assessment_outlined,
              title: 'Reports',
              description:
                  'Read performance charts, GST compliance cards, and revenue breakdowns.',
            ),
            _HelpCard(
              icon: Icons.settings_outlined,
              title: 'Administration',
              description:
                  'Configure company details, roles, alerts, and fiscal-year defaults.',
            ),
          ],
        ),
        SizedBox(height: 24),
        _LedgerHelpSection(),
        SizedBox(height: 24),
        _SupportPanel(),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppShell(
      activeRoute: '/profile',
      searchHint: 'Search profile...',
      floatingIcon: Icons.edit_outlined,
      child: _ProfileContent(),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageTitle(
              title: 'Profile',
              subtitle: 'Signed-in user and company account details.',
            ),
            SizedBox(height: 24),
            _Panel(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 620;
                  final profileDetails = Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _UserAvatar(user: user, radius: 38),
                          Positioned(
                            right: -6,
                            bottom: -6,
                            child: IconButton.filled(
                              tooltip: 'Update photo',
                              style: IconButton.styleFrom(
                                backgroundColor: _appAccent(context),
                                foregroundColor: _isDark(context)
                                    ? const Color(0xFF0B100D)
                                    : Colors.white,
                                minimumSize: const Size(34, 34),
                              ),
                              onPressed: state.isAuthenticated
                                  ? () => _showProfilePhotoEditor(
                                        context,
                                        user,
                                      )
                                  : null,
                              icon: const Icon(Icons.edit, size: 18),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name
                                  : 'User not available',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 6),
                            Text(
                              state.isAuthenticated
                                  ? 'ACTIVE SESSION'
                                  : 'NO ACTIVE SESSION',
                              style: TextStyle(color: _appMuted(context)),
                            ),
                            SizedBox(height: 18),
                            _ProfileFact(
                                label: 'Role',
                                value: user?.role ?? 'Not configured'),
                            _ProfileFact(
                                label: 'Email',
                                value: user?.email ?? 'Not configured'),
                            _ProfileFact(
                                label: 'GSTIN', value: 'Not configured'),
                            _ProfileFact(
                                label: 'Fiscal Year', value: 'Not configured'),
                          ],
                        ),
                      ),
                    ],
                  );

                  final logoutButton = FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _red),
                    onPressed: () {
                      context.read<AuthCubit>().logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        profileDetails,
                        const SizedBox(height: 20),
                        logoutButton,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: profileDetails),
                      const SizedBox(width: 20),
                      logoutButton,
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            _ResponsiveGrid(
              minTileWidth: 260,
              children: [
                Tooltip(
                  message:
                      'Open Approvals shows items waiting for approval. It helps you review pending work before it affects reports. New entries appear here when approvals are enabled.',
                  child: _MetricCard(
                    label: 'OPEN APPROVALS',
                    value: '0',
                    color: _appAccent(context),
                    note: 'No approvals yet',
                  ),
                ),
                _MetricCard(
                  label: 'LAST LOGIN',
                  value: state.isAuthenticated ? 'Active' : 'None',
                  color: _green,
                  note: 'Session status',
                ),
                Tooltip(
                  message:
                      'Audit Events shows important account and ledger changes. It helps trace who changed what and when. Events will list here as users work in the app.',
                  child: _MetricCard(
                    label: 'AUDIT EVENTS',
                    value: '0',
                    color: _appAccent(context),
                    note: 'No audit events yet',
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            _Panel(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 640;
                  final action = FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: _appAccent(context),
                    ),
                    onPressed: () => context.go('/profile/bank-details'),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Manage Bank Accounts'),
                  );
                  final children = [
                    Icon(
                      Icons.account_balance_outlined,
                      color: _appAccent(context),
                      size: 32,
                    ),
                    SizedBox(width: compact ? 0 : 16, height: compact ? 12 : 0),
                    compact
                        ? _ProfileBankDetailsCopy()
                        : Expanded(child: _ProfileBankDetailsCopy()),
                    SizedBox(width: compact ? 0 : 16, height: compact ? 16 : 0),
                    compact
                        ? SizedBox(width: double.infinity, child: action)
                        : action,
                  ];

                  return Flex(
                    direction: compact ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: compact
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: children,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileBankDetailsCopy extends StatelessWidget {
  const _ProfileBankDetailsCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bank Details',
          style: TextStyle(
            color: _appAccent(context),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Manage company, individual, joint, trust, and partnership accounts.',
          style: TextStyle(color: _appMuted(context)),
        ),
      ],
    );
  }
}

class _LedgerHelpSection extends StatelessWidget {
  const _LedgerHelpSection();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.menu_book_outlined, color: _appAccent(context)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'About Ledger',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Ledger is the transaction book for the company. It records each debit and credit with account reference, voucher details, date, status, and supporting tags so bank balances, receivables, payables, reports, and balance sheet figures stay aligned.',
            style: TextStyle(color: _appText(context), fontSize: 16),
          ),
          const SizedBox(height: 18),
          _ResponsiveGrid(
            minTileWidth: 260,
            children: const [
              _LedgerHelpPoint(
                icon: Icons.add_circle_outline,
                title: 'Add Entries',
                description:
                    'Use Add Entry to create receipt, payment, journal, sales, or purchase transactions.',
              ),
              _LedgerHelpPoint(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Track Accounts',
                description:
                    'Select linked bank accounts to compare opening balance, received debit, paid credit, receivable, and payable.',
              ),
              _LedgerHelpPoint(
                icon: Icons.filter_alt_outlined,
                title: 'Filter & Search',
                description:
                    'Filter by date or account, and use the header search to find transactions from any screen.',
              ),
              _LedgerHelpPoint(
                icon: Icons.verified_outlined,
                title: 'Reconcile Status',
                description:
                    'Use Received, To Receive, Paid, Unpaid, and On Hold statuses to keep pending items visible.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LedgerHelpPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _LedgerHelpPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _appAccent(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(description, style: TextStyle(color: _appMuted(context))),
            ],
          ),
        ),
      ],
    );
  }
}

void _showProfilePhotoEditor(BuildContext context, AuthUser? user) {
  if (user == null) {
    return;
  }

  final firstNameController = TextEditingController(text: user.firstName);
  final lastNameController = TextEditingController(text: user.lastName);
  final photoUrlController = TextEditingController(text: user.photoUrl);
  var saving = false;

  showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Edit Profile Photo'),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Photo URL',
                  helperText: 'Leave empty to show initials.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: saving ? null : () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: saving
                ? null
                : () async {
                    setState(() => saving = true);
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final updated = await _backendApi.updateProfile(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        photoUrl: photoUrlController.text,
                      );
                      await context.read<AuthCubit>().updateUser(updated);
                      if (context.mounted) {
                        Navigator.pop(dialogContext);
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Profile updated.')),
                        );
                      }
                    } catch (error) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    } finally {
                      if (context.mounted) {
                        setState(() => saving = false);
                      }
                    }
                  },
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(saving ? 'Saving...' : 'Save'),
          ),
        ],
      ),
    ),
  ).then((_) {
    firstNameController.dispose();
    lastNameController.dispose();
    photoUrlController.dispose();
  });
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _appAccent(context), size: 30),
          const SizedBox(height: 16),
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(
            description,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _appMuted(context)),
          ),
        ],
      ),
    );
  }
}

class _SupportPanel extends StatelessWidget {
  const _SupportPanel();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 620;

          return Wrap(
            spacing: 24,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: compact ? constraints.maxWidth : 420,
                child: const Text(
                  'Need help with month-end close? Contact support or generate an audit preparation checklist.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : null,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _primary),
                  onPressed: () => _showContactSupportDialog(context),
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Contact Support'),
                ),
              ),
              SizedBox(
                width: compact ? constraints.maxWidth : null,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: _primary),
                  onPressed: () => context.go('/audit-checklist'),
                  icon: const Icon(Icons.checklist),
                  label: const Text('Audit Checklist'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showContactSupportDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Contact Support'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SupportDetail(label: 'Company name', value: 'Demo Ledger Support'),
          _SupportDetail(
            label: 'Address',
            value: 'Demo Business Park, Chennai, Tamil Nadu',
          ),
          _SupportDetail(label: 'Phone number', value: '+91 90000 00000'),
          _SupportDetail(label: 'Email', value: 'support@example.com'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _SupportDetail extends StatelessWidget {
  final String label;
  final String value;

  const _SupportDetail({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _appMuted(context),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ProfileFact extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileFact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: _appMuted(context))),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            );
          }

          return Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(label, style: TextStyle(color: _appMuted(context))),
              ),
              Expanded(
                child: Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }
}
