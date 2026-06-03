part of 'screens.dart';

class BankDetailsScreen extends StatelessWidget {
  final bool isOnboarding;

  const BankDetailsScreen({super.key, this.isOnboarding = false});

  @override
  Widget build(BuildContext context) {
    if (isOnboarding) {
      return Scaffold(
        backgroundColor: _appBackground(context),
        body: SafeArea(
          child: _BankDetailsContent(isOnboarding: isOnboarding),
        ),
      );
    }

    return _AppShell(
      activeRoute: '/profile',
      searchHint: 'Search bank details...',
      floatingIcon: Icons.account_balance_outlined,
      child: _BankDetailsContent(isOnboarding: isOnboarding),
    );
  }
}

class _BankDetailsContent extends StatefulWidget {
  final bool isOnboarding;

  const _BankDetailsContent({required this.isOnboarding});

  @override
  State<_BankDetailsContent> createState() => _BankDetailsContentState();
}

class _BankDetailsContentState extends State<_BankDetailsContent> {
  final _formKey = GlobalKey<FormState>();
  final List<_BankAccountDraft> _drafts = [_BankAccountDraft.demo()];

  @override
  void initState() {
    super.initState();
    context.read<BankAccountsCubit>().load();
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BankAccountsCubit, BankAccountsState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 980;
            final horizontalPadding =
                widget.isOnboarding ? (wide ? 44.0 : 18.0) : 0.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: widget.isOnboarding ? 24 : 0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BankOnboardingHeader(isOnboarding: widget.isOnboarding),
                    const SizedBox(height: 24),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: _buildForm(state)),
                          const SizedBox(width: 24),
                          Expanded(
                              flex: 4,
                              child: _BankAccountsSummary(state: state)),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildForm(state),
                          const SizedBox(height: 20),
                          _BankAccountsSummary(state: state),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildForm(BankAccountsState state) {
    return _Panel(
      padding: const EdgeInsets.all(22),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Account Details',
                  style: TextStyle(
                    color: _appAccent(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                _Chip(
                  label:
                      '${_drafts.length} draft account${_drafts.length == 1 ? '' : 's'}',
                  color: _green,
                ),
              ],
            ),
            const SizedBox(height: 18),
            ..._drafts.asMap().entries.map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key == _drafts.length - 1 ? 0 : 18,
                    ),
                    child: _BankAccountDraftCard(
                      index: entry.key,
                      draft: entry.value,
                      canRemove: _drafts.length > 1,
                      onRemove: () => _removeDraft(entry.key),
                    ),
                  ),
                ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: state.saving ? null : _addDraft,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Account'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: _appAccent(context)),
                  onPressed: state.saving ? null : () => _save(state),
                  icon: state.saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: Text(state.saving ? 'Saving...' : 'Save & Continue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addDraft() {
    setState(() => _drafts.add(_BankAccountDraft.empty()));
  }

  void _removeDraft(int index) {
    final draft = _drafts.removeAt(index);
    draft.dispose();
    setState(() {});
  }

  Future<void> _save(BankAccountsState state) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final payloads = _drafts.map((draft) => draft.toPayload()).toList();
    try {
      await context.read<BankAccountsCubit>().saveAccounts(
            payloads,
            completeSetup: widget.isOnboarding,
          );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank account details saved.')),
    );

    if (widget.isOnboarding) {
      context.go('/dashboard');
    }
  }
}

class _BankOnboardingHeader extends StatelessWidget {
  final bool isOnboarding;

  const _BankOnboardingHeader({required this.isOnboarding});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final title = isOnboarding ? 'Add Bank Details' : 'Bank Accounts';
          final subtitle = isOnboarding
              ? 'Set up company or individual accounts before entering the dashboard.'
              : 'Add, review, or remove bank details connected to this profile.';

          final icon = Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _appAccent(context).withAlpha(22),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.account_balance_outlined,
                color: _appAccent(context)),
          );
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(color: _appMuted(context), fontSize: 16),
              ),
            ],
          );
          final badges = isOnboarding
              ? Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    const _Chip(
                      label: 'Login complete',
                      color: _green,
                      large: true,
                    ),
                    _Chip(
                      label: 'Dashboard next',
                      color: _appAccent(context),
                      large: true,
                    ),
                  ],
                )
              : const SizedBox.shrink();

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(height: 14),
                copy,
                if (isOnboarding) ...[
                  const SizedBox(height: 18),
                  badges,
                ],
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 18),
              Expanded(child: copy),
              if (isOnboarding) ...[
                const SizedBox(width: 18),
                badges,
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BankAccountDraftCard extends StatefulWidget {
  final int index;
  final _BankAccountDraft draft;
  final bool canRemove;
  final VoidCallback onRemove;

  const _BankAccountDraftCard({
    required this.index,
    required this.draft,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  State<_BankAccountDraftCard> createState() => _BankAccountDraftCardState();
}

class _BankAccountDraftCardState extends State<_BankAccountDraftCard> {
  static const _ownerTypes = [
    'Company',
    'Individual',
    'Joint Account',
    'Trust',
    'Partnership'
  ];
  static const _accountTypes = [
    'Current',
    'Savings',
    'Salary',
    'OD/CC',
    'NRE/NRO'
  ];

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _appSoftSurface(context),
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Account ${widget.index + 1}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              if (widget.canRemove)
                IconButton(
                  tooltip: 'Remove account',
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 2 : 1;
              final fieldWidth =
                  (constraints.maxWidth - ((columns - 1) * 14)) / columns;

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: draft.ownerType,
                      decoration: const InputDecoration(
                        labelText: 'Owner Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      items: _ownerTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(
                          () => draft.ownerType = value ?? draft.ownerType),
                    ),
                  ),
                  _field(
                    width: fieldWidth,
                    controller: draft.holderName,
                    label: 'Account Holder Name',
                    icon: Icons.person_outline,
                  ),
                  _field(
                    width: fieldWidth,
                    controller: draft.bankName,
                    label: 'Bank Name',
                    icon: Icons.account_balance_outlined,
                  ),
                  _field(
                    width: fieldWidth,
                    controller: draft.branchName,
                    label: 'Branch',
                    icon: Icons.location_on_outlined,
                    required: false,
                  ),
                  _field(
                    width: fieldWidth,
                    controller: draft.accountNumber,
                    label: 'Account Number',
                    icon: Icons.numbers_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  _field(
                    width: fieldWidth,
                    controller: draft.ifsc,
                    label: 'IFSC',
                    icon: Icons.qr_code_2_outlined,
                    validator: _ifscValidator,
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: draft.accountType,
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_tree_outlined),
                      ),
                      items: _accountTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (value) => setState(
                          () => draft.accountType = value ?? draft.accountType),
                    ),
                  ),
                  _field(
                    width: fieldWidth,
                    controller: draft.openingBalance,
                    label: 'Current Balance',
                    icon: Icons.currency_rupee_outlined,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: _amountValidator,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: draft.primaryAccount,
            onChanged: (value) =>
                setState(() => draft.primaryAccount = value ?? false),
            title: const Text('Mark as primary account'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required double width,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: validator ??
            (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return 'Required';
              }
              return null;
            },
      ),
    );
  }

  String? _ifscValidator(String? value) {
    final ifsc = value?.trim().toUpperCase() ?? '';
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
      return 'Enter a valid IFSC';
    }
    return null;
  }

  String? _amountValidator(String? value) {
    final amount = double.tryParse((value ?? '').replaceAll(',', '').trim());
    if (amount == null || amount < 0) {
      return 'Enter a valid amount';
    }
    return null;
  }
}

class _BankAccountsSummary extends StatelessWidget {
  final BankAccountsState state;

  const _BankAccountsSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final accounts = state.accounts;

    return _Panel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: _appAccent(context)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Managed Accounts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
          if (state.loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: LinearProgressIndicator(),
            )
          else if (accounts.isEmpty)
            const _EmptyPanelMessage(
              icon: Icons.account_balance_outlined,
              title: 'No accounts saved',
              subtitle:
                  'Saved company and individual accounts will appear here.',
            )
          else
            ...accounts
                .map((account) => _SavedBankAccountTile(account: account)),
        ],
      ),
    );
  }
}

class _SavedBankAccountTile extends StatelessWidget {
  final BankBalance account;

  const _SavedBankAccountTile({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _appBorder(context))),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _appAccent(context).withAlpha(20),
          child:
              Icon(Icons.account_balance_outlined, color: _appAccent(context)),
        ),
        title: Text(
          account.accountHolderName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${account.bankName} • ${account.accountType} • ${account.maskedAccountNumber}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(account.balance),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (account.primaryAccount) ...[
              const SizedBox(height: 4),
              const _Chip(label: 'Primary', color: _green),
            ],
          ],
        ),
      ),
    );
  }
}

class _BankAccountDraft {
  String ownerType;
  String accountType;
  bool primaryAccount;
  final TextEditingController holderName;
  final TextEditingController bankName;
  final TextEditingController branchName;
  final TextEditingController accountNumber;
  final TextEditingController ifsc;
  final TextEditingController openingBalance;

  _BankAccountDraft({
    required this.ownerType,
    required this.accountType,
    required this.primaryAccount,
    required this.holderName,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifsc,
    required this.openingBalance,
  });

  factory _BankAccountDraft.demo() {
    return _BankAccountDraft(
      ownerType: 'Company',
      accountType: 'Current',
      primaryAccount: true,
      holderName: TextEditingController(
        text: 'DHINADTS IT SOLUTIONS AND SUPPORT (OPC) PRIVATE LIMITED',
      ),
      bankName: TextEditingController(text: 'Axis Bank'),
      branchName: TextEditingController(text: 'Chennai Main'),
      accountNumber: TextEditingController(text: '000000000001'),
      ifsc: TextEditingController(text: 'UTIB0000001'),
      openingBalance: TextEditingController(text: '100000'),
    );
  }

  factory _BankAccountDraft.empty() {
    return _BankAccountDraft(
      ownerType: 'Individual',
      accountType: 'Savings',
      primaryAccount: false,
      holderName: TextEditingController(),
      bankName: TextEditingController(),
      branchName: TextEditingController(),
      accountNumber: TextEditingController(),
      ifsc: TextEditingController(),
      openingBalance: TextEditingController(text: '0'),
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'accountHolderName': holderName.text.trim(),
      'ownerType': ownerType,
      'bankName': bankName.text.trim(),
      'branchName': branchName.text.trim(),
      'accountNumber': accountNumber.text.trim(),
      'ifsc': ifsc.text.trim().toUpperCase(),
      'accountType': accountType,
      'openingBalance': double.tryParse(
            openingBalance.text.replaceAll(',', '').trim(),
          ) ??
          0,
      'primaryAccount': primaryAccount,
    };
  }

  void dispose() {
    holderName.dispose();
    bankName.dispose();
    branchName.dispose();
    accountNumber.dispose();
    ifsc.dispose();
    openingBalance.dispose();
  }
}
