// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class _AppShell extends StatefulWidget {
  final String activeRoute;
  final String searchHint;
  final String? fiscalBadge;
  final IconData floatingIcon;
  final Widget child;

  const _AppShell({
    required this.activeRoute,
    required this.searchHint,
    required this.floatingIcon,
    required this.child,
    this.fiscalBadge,
  });

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth >= 1180;
        final showRail = constraints.maxWidth >= 760 && !showSidebar;
        final pagePadding = showSidebar
            ? const EdgeInsets.all(24)
            : showRail
                ? const EdgeInsets.all(20)
                : const EdgeInsets.all(16);

        return Scaffold(
          backgroundColor: _appBackground(context),
          drawer: showSidebar || showRail
              ? null
              : Drawer(
                  child: _SideNav(
                    activeRoute: widget.activeRoute,
                    scrollable: true,
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add',
            backgroundColor: _appAccent(context),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () => _showAppFlowModal(
              context,
              _AppFlowModalType.fromRoute(widget.activeRoute),
            ),
            child: Icon(widget.floatingIcon),
          ),
          body: SafeArea(
            child: Row(
              children: [
                if (showSidebar)
                  _SideNav(
                    activeRoute: widget.activeRoute,
                    scrollable: false,
                  ),
                if (showRail)
                  _TabletNavigationRail(activeRoute: widget.activeRoute),
                Expanded(
                  child: Column(
                    children: [
                      _TopBar(
                        showMenu: !showSidebar,
                        searchHint: widget.searchHint,
                        fiscalBadge: widget.fiscalBadge,
                      ),
                      Expanded(
                        child: _PageScrollView(
                          padding: pagePadding,
                          child: widget.child,
                        ),
                      ),
                    ],
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

class _PageScrollView extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _PageScrollView({required this.padding, required this.child});

  @override
  State<_PageScrollView> createState() => _PageScrollViewState();
}

class _PageScrollViewState extends State<_PageScrollView> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _controller,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _controller,
        padding: widget.padding,
        physics: const ScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height - 200,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showMenu;
  final String searchHint;
  final String? fiscalBadge;

  const _TopBar({
    required this.showMenu,
    required this.searchHint,
    this.fiscalBadge,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 620;

      if (isCompact) {
        return Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _appBackground(context),
            border: Border(bottom: BorderSide(color: _appBorder(context))),
          ),
          child: Row(
            children: [
              if (showMenu) ...[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: LedgerBrandLockup(
                  logoSize: 40,
                  titleSize: 17,
                  subtitleSize: 8,
                  dense: true,
                  titleColor: _appText(context),
                  subtitleColor: _appAccent(context),
                ),
              ),
              IconButton(
                tooltip: _isDark(context)
                    ? 'Switch to light theme'
                    : 'Switch to dark theme',
                icon: Icon(
                  _isDark(context)
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  color: _appText(context),
                ),
                onPressed: AppThemeController.toggleTheme,
              ),
              PopupMenuButton<String>(
                tooltip: 'More',
                icon: Icon(Icons.more_vert, color: _appText(context)),
                onSelected: (value) {
                  switch (value) {
                    case 'voucherHelp':
                      _showVoucherPrefixHelp(context);
                      break;
                    case 'notifications':
                      context.go('/notifications');
                      break;
                    case 'help':
                      context.go('/help');
                      break;
                    case 'profile':
                      context.go('/profile');
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'voucherHelp',
                    child: Text('Voucher Prefix Help'),
                  ),
                  PopupMenuItem(
                    value: 'notifications',
                    child: Text('Notifications'),
                  ),
                  PopupMenuItem(
                    value: 'help',
                    child: Text('Help'),
                  ),
                  PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile'),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 24,
          vertical: isCompact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: _appBackground(context),
          border: Border(bottom: BorderSide(color: _appBorder(context))),
        ),
        child: Row(
          children: [
            if (showMenu) ...[
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: LedgerBrandLockup(
                      logoSize: isCompact ? 40 : 48,
                      titleSize: isCompact ? 18 : 22,
                      subtitleSize: isCompact ? 8 : 10,
                      dense: isCompact,
                      titleColor: _appText(context),
                      subtitleColor: _appAccent(context),
                    ),
                  ),
                  if (fiscalBadge != null) ...[
                    const SizedBox(width: 16),
                    Flexible(
                      child: _Chip(
                        label: fiscalBadge!,
                        color: _green,
                        filled: true,
                        large: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: _isDark(context)
                  ? 'Switch to light theme'
                  : 'Switch to dark theme',
              icon: Icon(
                _isDark(context)
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: _appText(context),
              ),
              onPressed: AppThemeController.toggleTheme,
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: AppRouteNames.notifications,
              icon: Icon(Icons.notifications_none, color: _appText(context)),
              onPressed: () => context.go('/notifications'),
            ),
            const SizedBox(width: 16),
            const _VoucherPrefixHelpButton(),
            const SizedBox(width: 16),
            IconButton(
              tooltip: AppRouteNames.help,
              icon: Icon(Icons.help_outline, color: _appText(context)),
              onPressed: () => context.go('/help'),
            ),
            const SizedBox(width: 16),
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => context.go('/profile'),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) =>
                    _UserAvatar(user: state.user, radius: 18),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SearchBox extends StatefulWidget {
  final String hint;

  const _SearchBox({required this.hint});

  @override
  State<_SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<_SearchBox> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  Future<List<LedgerEntry>>? _resultsFuture;

  @override
  void initState() {
    super.initState();
    _controller.text = _appSearchQuery.value;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 44,
      child: TextField(
        controller: _controller,
        style: TextStyle(color: _appText(context)),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _runSearch(value);
          _showSearchResults(context);
        },
        onChanged: (value) {
          _appSearchQuery.value = value;
          setState(() {});
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 350), () {
            if (mounted) {
              _runSearch(value);
            }
          });
        },
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: _appMuted(context)),
          prefixIcon: Icon(Icons.search, color: _appMuted(context)),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    _appSearchQuery.value = '';
                    setState(() => _resultsFuture = null);
                  },
                ),
          filled: true,
          fillColor: _appSoftSurface(context),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _appBorder(context)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: _appBorder(context)),
          ),
        ),
        onTap: () {
          if (_controller.text.trim().isNotEmpty) {
            _showSearchResults(context);
          }
        },
      ),
    );
  }

  void _runSearch(String value) {
    final query = value.trim();
    _appSearchQuery.value = query;
    setState(() {
      _resultsFuture =
          query.isEmpty ? null : _backendApi.searchLedgerEntries(query);
    });
  }

  void _showSearchResults(BuildContext context) {
    final resultsFuture = _resultsFuture;
    if (resultsFuture == null) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => _SearchResultsDialog(
        query: _controller.text.trim(),
        resultsFuture: resultsFuture,
      ),
    );
  }
}

class _SearchResultsDialog extends StatelessWidget {
  final String query;
  final Future<List<LedgerEntry>> resultsFuture;

  const _SearchResultsDialog({
    required this.query,
    required this.resultsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Search results for "$query"'),
      content: SizedBox(
        width: 560,
        child: _SearchResultsList(
          query: query,
          resultsFuture: resultsFuture,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            context.go('/ledger');
          },
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('Open Ledger'),
        ),
      ],
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final String query;
  final Future<List<LedgerEntry>>? resultsFuture;

  const _SearchResultsList({
    required this.query,
    required this.resultsFuture,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty || resultsFuture == null) {
      return _EmptyPanelMessage(
        icon: Icons.search,
        title: 'Search ledger transactions',
        subtitle: 'Search particulars, account references, status, or tags.',
      );
    }

    return FutureBuilder<List<LedgerEntry>>(
      future: resultsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final results = snapshot.data ?? const <LedgerEntry>[];
        if (results.isEmpty) {
          return _EmptyPanelMessage(
            icon: Icons.search_off,
            title: 'No matching transactions',
            subtitle:
                'Try searching another account, voucher, amount, or status.',
          );
        }

        return SizedBox(
          height: 320,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: results.length,
            separatorBuilder: (_, __) => Divider(color: _appBorder(context)),
            itemBuilder: (context, index) {
              final entry = results[index];
              final amount = entry.debit > 0 ? entry.debit : entry.credit;
              return ListTile(
                leading: Icon(
                  entry.debit > 0
                      ? Icons.south_west_outlined
                      : Icons.north_east_outlined,
                  color: entry.debit > 0 ? _green : _red,
                ),
                title: Text(entry.particulars),
                subtitle: Text('${entry.ledgerRef} • ${entry.status}'),
                trailing: Text(_formatCurrency(amount)),
                onTap: () {
                  Navigator.pop(context);
                  context.go('/ledger');
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _SideNav extends StatelessWidget {
  final String activeRoute;
  final bool scrollable;

  const _SideNav({
    required this.activeRoute,
    required this.scrollable,
  });

  @override
  Widget build(BuildContext context) {
    final content = _SideNavContent(
      activeRoute: activeRoute,
      useFlexibleSpacing: !scrollable,
    );

    return Container(
      width: 320,
      color: _appBackground(context),
      child: SafeArea(
        child: scrollable ? SingleChildScrollView(child: content) : content,
      ),
    );
  }
}

class _SideNavContent extends StatelessWidget {
  final String activeRoute;
  final bool useFlexibleSpacing;

  const _SideNavContent({
    required this.activeRoute,
    required this.useFlexibleSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 22, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LedgerBrandLockup(
                logoSize: 48,
                titleSize: 19,
                subtitleSize: 9,
                dense: true,
                titleColor: _appText(context),
                subtitleColor: _appAccent(context),
              ),
              const SizedBox(height: 18),
              const DhinadtsCompanyMark(height: 52),
            ],
          ),
        ),
        _NavItem(
          icon: Icons.dashboard_outlined,
          label: AppRouteNames.dashboard,
          route: '/dashboard',
          activeRoute: activeRoute,
        ),
        _NavItem(
          icon: Icons.menu_book_outlined,
          label: AppRouteNames.ledger,
          route: '/ledger',
          activeRoute: activeRoute,
        ),
        _NavItem(
          icon: Icons.account_balance_outlined,
          label: AppRouteNames.balanceSheet,
          route: '/balance-sheet',
          activeRoute: activeRoute,
        ),
        _NavItem(
          icon: Icons.assessment_outlined,
          label: AppRouteNames.reports,
          route: '/reports',
          activeRoute: activeRoute,
        ),
        _NavItem(
          icon: Icons.fact_check_outlined,
          label: AppRouteNames.auditChecklist,
          route: '/audit-checklist',
          activeRoute: activeRoute,
        ),
        _NavItem(
          icon: Icons.settings_outlined,
          label: AppRouteNames.settings,
          route: '/settings',
          activeRoute: activeRoute,
        ),
        if (useFlexibleSpacing) const Spacer() else const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(58),
              backgroundColor: _primaryContainer,
              foregroundColor: _isDark(context) ? _financeGold : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () =>
                _showAppFlowModal(context, _AppFlowModalType.ledgerEntry),
            icon: Icon(
              Icons.add,
              color: _isDark(context) ? _financeGold : Colors.white,
            ),
            label: Text(
              'Add Entry',
              style: TextStyle(
                  color: _isDark(context) ? _financeGold : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
          child: Row(
            children: [
              Expanded(child: _CompanySetupStatus()),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final AuthUser? user;
  final double radius;

  const _UserAvatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    final photoUrl = user?.photoUrl.trim() ?? '';
    final initials = _userInitials(user);

    if (photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: _appSoftSurface(context),
        backgroundImage: NetworkImage(photoUrl),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: _appAccent(context),
      child: Text(
        initials,
        style: TextStyle(
          color: _isDark(context) ? const Color(0xFF0B100D) : Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: radius * 0.72,
        ),
      ),
    );
  }
}

String _userInitials(AuthUser? user) {
  final first = user?.firstName.trim() ?? '';
  final last = user?.lastName.trim() ?? '';
  if (first.isNotEmpty || last.isNotEmpty) {
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  final name = user?.name.trim() ?? '';
  if (name.isEmpty) {
    return 'U';
  }
  final parts = name.split(RegExp(r'\s+'));
  return parts
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0])
      .join()
      .toUpperCase();
}

class _CompanySetupStatus extends StatelessWidget {
  const _CompanySetupStatus();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          'Company setup pending: add GSTIN, PAN, bank proof, address proof, and fiscal year.',
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _showCompanySetupDialog(context),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _red.withAlpha(24),
              child: Icon(Icons.business_outlined, color: _red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company not configured',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _appText(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Pending documents',
                    style: TextStyle(color: _appMuted(context), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.info_outline, color: _appMuted(context), size: 18),
          ],
        ),
      ),
    );
  }
}

void _showCompanySetupDialog(BuildContext context) {
  const documents = [
    _CompanyDocument('GST Certificate', 'Pending'),
    _CompanyDocument('PAN Card', 'Pending'),
    _CompanyDocument('Bank Account Proof', 'Pending'),
    _CompanyDocument('Registered Address Proof', 'Pending'),
    _CompanyDocument('Fiscal Year & Opening Balance', 'Pending'),
  ];

  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Configure Company'),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add the required company documents to unlock GST, reports, and audit-ready ledger setup.',
              style: TextStyle(color: _appMuted(context)),
            ),
            const SizedBox(height: 16),
            ...documents.map(
              (document) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.pending_actions, color: _red),
                title: Text(document.name),
                trailing: _Chip(label: document.status, color: _red),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Later'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            context.go('/settings');
          },
          icon: const Icon(Icons.settings_outlined),
          label: const Text('Open Settings'),
        ),
      ],
    ),
  );
}

class _CompanyDocument {
  final String name;
  final String status;

  const _CompanyDocument(this.name, this.status);
}

class _TabletNavigationRail extends StatelessWidget {
  final String activeRoute;

  const _TabletNavigationRail({required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    const items = [
      _RailNavItem(Icons.dashboard_outlined, '/dashboard', 'Dashboard'),
      _RailNavItem(Icons.menu_book_outlined, '/ledger', 'Ledger'),
      _RailNavItem(Icons.account_balance_outlined, '/balance-sheet', 'Balance'),
      _RailNavItem(Icons.assessment_outlined, '/reports', 'Reports'),
      _RailNavItem(Icons.fact_check_outlined, '/audit-checklist', 'Audit'),
      _RailNavItem(Icons.settings_outlined, '/settings', 'Settings'),
    ];

    return Container(
      width: 88,
      decoration: BoxDecoration(
        color: _appBackground(context),
        border: Border(right: BorderSide(color: _appBorder(context))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            Icon(Icons.account_balance_wallet_outlined,
                color: _appAccent(context), size: 30),
            const SizedBox(height: 26),
            ...items.map(
              (item) => Tooltip(
                message: item.label,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: activeRoute == item.route
                        ? _appActiveNav(context)
                        : Colors.transparent,
                    foregroundColor: activeRoute == item.route
                        ? _appAccent(context)
                        : _appText(context),
                    minimumSize: const Size(52, 52),
                  ),
                  onPressed: () => context.go(item.route),
                  icon: Icon(item.icon),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: IconButton.filled(
                onPressed: () =>
                    _showAppFlowModal(context, _AppFlowModalType.ledgerEntry),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailNavItem {
  final IconData icon;
  final String route;
  final String label;

  const _RailNavItem(this.icon, this.route, this.label);
}

enum _AppFlowModalType {
  ledgerEntry,
  dashboardAction,
  reportExport,
  auditChecklist,
  balanceSheetAction,
  settingsUpdate,
  notificationsReview,
  helpRequest,
  profileEdit;

  static _AppFlowModalType fromRoute(String route) {
    switch (route) {
      case '/dashboard':
        return _AppFlowModalType.dashboardAction;
      case '/reports':
        return _AppFlowModalType.reportExport;
      case '/audit-checklist':
        return _AppFlowModalType.auditChecklist;
      case '/balance-sheet':
        return _AppFlowModalType.balanceSheetAction;
      case '/settings':
        return _AppFlowModalType.settingsUpdate;
      case '/notifications':
        return _AppFlowModalType.notificationsReview;
      case '/help':
        return _AppFlowModalType.helpRequest;
      case '/profile':
        return _AppFlowModalType.profileEdit;
      case '/ledger':
      default:
        return _AppFlowModalType.ledgerEntry;
    }
  }
}

Future<void> _showAppFlowModal(
  BuildContext context,
  _AppFlowModalType modalType,
) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final useDialog = screenWidth >= 720;

  if (useDialog) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: _AppFlowModalContent(modalType: modalType),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: _appSurface(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: _AppFlowModalContent(modalType: modalType),
    ),
  );
}

class _AppFlowModalContent extends StatelessWidget {
  final _AppFlowModalType modalType;

  const _AppFlowModalContent({required this.modalType});

  @override
  Widget build(BuildContext context) {
    switch (modalType) {
      case _AppFlowModalType.dashboardAction:
        return const _DashboardActionModal();
      case _AppFlowModalType.reportExport:
        return const _ReportExportModal();
      case _AppFlowModalType.auditChecklist:
        return const _AuditChecklistModal();
      case _AppFlowModalType.balanceSheetAction:
        return const _BalanceSheetActionModal();
      case _AppFlowModalType.settingsUpdate:
        return const _SettingsUpdateModal();
      case _AppFlowModalType.notificationsReview:
        return const _NotificationsReviewModal();
      case _AppFlowModalType.helpRequest:
        return const _HelpRequestModal();
      case _AppFlowModalType.profileEdit:
        return const _ProfileEditModal();
      case _AppFlowModalType.ledgerEntry:
        return const _LedgerEntryModal();
    }
  }
}

class _AppFlowModalShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;
  final bool primaryActionDisabled;

  const _AppFlowModalShell({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    required this.primaryActionLabel,
    this.secondaryActionLabel = 'Cancel',
    this.onPrimaryPressed,
    this.onSecondaryPressed,
    this.primaryActionDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: _primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: TextStyle(color: _appMuted(context))),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: _primary),
                  onPressed: onSecondaryPressed ?? () => Navigator.pop(context),
                  child: Text(secondaryActionLabel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: _primary),
                  onPressed: primaryActionDisabled
                      ? null
                      : onPrimaryPressed ?? () => Navigator.pop(context),
                  child: Text(primaryActionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerEntryModal extends ConsumerStatefulWidget {
  const _LedgerEntryModal();

  @override
  ConsumerState<_LedgerEntryModal> createState() => _LedgerEntryModalState();
}

class _LedgerEntryModalState extends ConsumerState<_LedgerEntryModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '0.00');
  final _narrationController = TextEditingController();
  late final Future<List<BankBalance>> _bankBalancesFuture;
  String _voucherType = 'Journal';
  String _entryType = 'Select';
  String _status = 'Select';
  String? _selectedAccount;
  DateTime _entryDate = DateTime.now();
  bool _isSaving = false;
  String? _error;

  static const _voucherTypes = [
    'Journal',
    'Payment',
    'Receipt',
    'Sales',
    'Purchase',
  ];

  @override
  void initState() {
    super.initState();
    _bankBalancesFuture = _backendApi.fetchBankBalances();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _narrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppFlowModalShell(
      title: 'Add Ledger Entry',
      subtitle: 'Create a voucher-ready transaction for the active ledger.',
      icon: Icons.add_circle_outline,
      primaryActionLabel: _isSaving ? 'Saving...' : 'Save Entry',
      secondaryActionLabel: 'Save Draft',
      primaryActionDisabled: _isSaving,
      onPrimaryPressed: _saveEntry,
      onSecondaryPressed: _isSaving ? null : () => Navigator.pop(context),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _voucherType,
                decoration: const InputDecoration(
                  labelText: 'Voucher Type',
                  border: OutlineInputBorder(),
                  suffixIcon: _VoucherPrefixHelpButton(),
                ),
                items: _voucherTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) => setState(
                          () => _voucherType = value ?? _voucherType,
                        ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _isSaving ? null : _pickDateTime,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Entry Date & Time',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.event_available_outlined),
                  ),
                  child: Text(_formatDateTime(_entryDate)),
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<BankBalance>>(
                future: _bankBalancesFuture,
                builder: (context, snapshot) {
                  final accounts = snapshot.data ?? const <BankBalance>[];
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedAccount,
                    decoration: InputDecoration(
                      labelText: 'Account',
                      border: const OutlineInputBorder(),
                      helperText: isLoading
                          ? 'Loading bank accounts...'
                          : 'Select linked bank account',
                    ),
                    items: accounts
                        .map(
                          (account) => DropdownMenuItem(
                            value: account.displayName,
                            child: Text(
                              '${account.displayName} (${_formatCurrency(account.balance)})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _isSaving || isLoading
                        ? null
                        : (value) => setState(() => _selectedAccount = value),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Select an account.';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _entryType,
                decoration: const InputDecoration(
                  labelText: 'Entry Type',
                  border: OutlineInputBorder(),
                ),
                items: const ['Select', 'Debit', 'Credit']
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving
                    ? null
                    : (value) => setState(() {
                          _entryType = value ?? 'Select';
                          _status = 'Select';
                        }),
                validator: (value) {
                  if (value == null || value == 'Select') {
                    return 'Select debit or credit.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _amountController,
                enabled: !_isSaving,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: _entryType == 'Debit'
                      ? 'Debit Amount'
                      : _entryType == 'Credit'
                          ? 'Credit Amount'
                          : 'Amount',
                  prefixText: '₹ ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                key: ValueKey(
                    'ledger-status-$_status-${_availableStatuses.join('|')}'),
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: const OutlineInputBorder(),
                  helperText: _statusHelperText,
                ),
                items: ['Select', ..._availableStatuses]
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ),
                    )
                    .toList(),
                onChanged: _isSaving || _availableStatuses.isEmpty
                    ? null
                    : (value) => setState(() => _status = value ?? 'Select'),
                validator: (value) {
                  if (value == null || value == 'Select') {
                    return 'Select status.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _narrationController,
                enabled: !_isSaving,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Narration',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: const TextStyle(color: _red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_entryDate),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _entryDate = DateTime(
        selected.year,
        selected.month,
        selected.day,
        time.hour,
        time.minute,
      );
    });
  }

  List<String> get _availableStatuses {
    if (_entryType == 'Debit') {
      return const ['Received', 'To Receive'];
    }
    if (_entryType == 'Credit') {
      return const ['Paid', 'Unpaid', 'On Hold'];
    }
    return const <String>[];
  }

  String get _statusHelperText {
    if (_entryType == 'Debit') {
      return 'Debit entries use received statuses';
    }
    if (_entryType == 'Credit') {
      return 'Credit entries use payment statuses';
    }
    return 'Select debit or credit first';
  }

  Future<void> _saveEntry() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_entryType == 'Select') {
      setState(() => _error = 'Select debit or credit.');
      return;
    }
    final amount = _parseAmount(_amountController.text);
    if (amount <= 0) {
      setState(() => _error = 'Enter amount greater than zero.');
      return;
    }
    if (_status == 'Select') {
      setState(() => _error = 'Select status.');
      return;
    }
    final debit = _entryType == 'Debit' ? amount : 0.0;
    final credit = _entryType == 'Credit' ? amount : 0.0;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final account = _selectedAccount ?? '';
    final narration = _narrationController.text.trim();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(backendApiProvider).createLedgerEntry({
        'date': _entryDate.toIso8601String(),
        'particulars':
            narration.isEmpty ? '$_voucherType - $account' : narration,
        'ledgerRef': account,
        'debit': debit,
        'credit': credit,
        'status': _status,
        'tags': [_voucherType],
      });

      ref.invalidate(ledgerDataProvider);
      await ref.read(ledgerDataProvider.future);
      if (mounted) {
        navigator.pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Ledger entry saved.',
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  double _parseAmount(String value) {
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }
}

class _DashboardActionModal extends StatelessWidget {
  const _DashboardActionModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Quick Dashboard Action',
      subtitle: 'Start a common cash-flow task from the dashboard.',
      icon: Icons.flash_on_outlined,
      primaryActionLabel: 'Continue',
      children: [
        _ModalChoiceTile(
          icon: Icons.receipt_long_outlined,
          title: 'New Invoice',
          subtitle: 'Create a sales invoice and add it to receivables.',
        ),
        _ModalChoiceTile(
          icon: Icons.payments_outlined,
          title: 'Payment In',
          subtitle: 'Record received cash or bank payment.',
        ),
        _ModalChoiceTile(
          icon: Icons.upload_file_outlined,
          title: 'Import Statement',
          subtitle: 'Prepare bank statement lines for reconciliation.',
        ),
      ],
    );
  }
}

class _ReportExportModal extends StatelessWidget {
  const _ReportExportModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Generate Report',
      subtitle: 'Choose the report package for audit and management review.',
      icon: Icons.assessment_outlined,
      primaryActionLabel: 'Generate',
      children: [
        _ModalField(label: 'Report Type', value: 'Not selected'),
        _ModalField(label: 'Period', value: 'Not selected'),
        _ModalField(label: 'Format', value: 'Not selected'),
        _ModalField(label: 'Include GST Notes', value: 'No'),
      ],
    );
  }
}

class _AuditChecklistModal extends StatelessWidget {
  const _AuditChecklistModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Audit Checklist',
      subtitle: 'Review demo readiness items before auditor handoff.',
      icon: Icons.fact_check_outlined,
      primaryActionLabel: 'Review Checklist',
      children: [
        _ModalChoiceTile(
          icon: Icons.receipt_long_outlined,
          title: 'Voucher Review',
          subtitle: 'Check receipts, payments, and journal entries.',
        ),
        _ModalChoiceTile(
          icon: Icons.account_balance_outlined,
          title: 'Bank Reconciliation',
          subtitle: 'Compare ledger balances with managed accounts.',
        ),
        _ModalChoiceTile(
          icon: Icons.verified_outlined,
          title: 'Approval Trail',
          subtitle: 'Confirm open approvals and audit events.',
        ),
      ],
    );
  }
}

class _BalanceSheetActionModal extends StatelessWidget {
  const _BalanceSheetActionModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Balance Sheet Action',
      subtitle: 'Prepare closing figures for print, export, or auditor review.',
      icon: Icons.account_balance_outlined,
      primaryActionLabel: 'Prepare Export',
      children: [
        _ModalField(label: 'Statement Date', value: 'Not selected'),
        _ModalField(label: 'Output', value: 'Not selected'),
        _ModalField(label: 'Auditor Sign-off', value: 'Not selected'),
      ],
    );
  }
}

class _SettingsUpdateModal extends StatelessWidget {
  const _SettingsUpdateModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Update Settings',
      subtitle: 'Review changes before applying them to company defaults.',
      icon: Icons.settings_outlined,
      primaryActionLabel: 'Apply Settings',
      children: [
        _ModalField(label: 'Currency', value: 'Indian Rupee (₹)'),
        _ModalField(label: 'Voucher Prefix', value: 'GL / PV / SI'),
        _ModalField(label: 'Approval Mode', value: 'Admin review required'),
      ],
    );
  }
}

class _NotificationsReviewModal extends StatelessWidget {
  const _NotificationsReviewModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Review Notifications',
      subtitle: 'Mark alerts reviewed after checking the compliance queue.',
      icon: Icons.notifications_active_outlined,
      primaryActionLabel: 'Mark Reviewed',
      children: [
        _ModalChoiceTile(
          icon: Icons.warning_amber_outlined,
          title: 'GST Reconciliation',
          subtitle: '0 entries need attention before filing.',
        ),
        _ModalChoiceTile(
          icon: Icons.event_note_outlined,
          title: 'Annual Return',
          subtitle: 'No due date configured.',
        ),
      ],
    );
  }
}

class _HelpRequestModal extends StatelessWidget {
  const _HelpRequestModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Request Support',
      subtitle: 'Send context to the support team for faster assistance.',
      icon: Icons.support_agent_outlined,
      primaryActionLabel: 'Send Request',
      children: [
        _ModalField(label: 'Topic', value: 'Month-end close assistance'),
        _ModalField(label: 'Priority', value: 'Normal'),
        _ModalField(label: 'Contact', value: 'Not configured'),
      ],
    );
  }
}

class _ProfileEditModal extends StatelessWidget {
  const _ProfileEditModal();

  @override
  Widget build(BuildContext context) {
    return const _AppFlowModalShell(
      title: 'Edit Profile',
      subtitle: 'Update admin session details and company contact metadata.',
      icon: Icons.person_outline,
      primaryActionLabel: 'Save Profile',
      children: [
        _ModalField(label: 'Display Name', value: 'Not configured'),
        _ModalField(label: 'Role', value: 'Not configured'),
        _ModalField(label: 'Email', value: 'Not configured'),
      ],
    );
  }
}

class _ModalField extends StatelessWidget {
  final String label;
  final String value;

  const _ModalField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: _appMuted(context),
                fontSize: 12,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _appSoftSurface(context),
              border: Border.all(color: _appBorder(context)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(value, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _ModalChoiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ModalChoiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: _appBorder(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: _primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: _appMuted(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String activeRoute;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeRoute == route;

    return InkWell(
      onTap: () {
        Navigator.maybePop(context);
        context.go(route);
      },
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: active ? _appActiveNav(context) : Colors.transparent,
          border: Border(
            right: BorderSide(
              color: active ? _primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? _appAccent(context) : _appText(context)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? _appAccent(context) : _appText(context),
                  fontSize: 18,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
