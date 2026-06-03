// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

part of 'screens.dart';

class ScreenPage extends StatelessWidget {
  final String screenKey;
  final String title;

  const ScreenPage({super.key, required this.screenKey, required this.title});

  @override
  Widget build(BuildContext context) {
    final spec = _ScreenSpec.fromKey(screenKey);

    return _AppShell(
      activeRoute: spec.route,
      searchHint: spec.searchHint,
      fiscalBadge: spec.fiscalBadge,
      floatingIcon: spec.floatingIcon,
      child: spec.builder(context),
    );
  }
}

class _ScreenSpec {
  final String route;
  final String searchHint;
  final String? fiscalBadge;
  final IconData floatingIcon;
  final WidgetBuilder builder;

  const _ScreenSpec({
    required this.route,
    required this.searchHint,
    required this.floatingIcon,
    required this.builder,
    this.fiscalBadge,
  });

  static _ScreenSpec fromKey(String key) {
    switch (key) {
      case 'screen2':
        return _ScreenSpec(
          route: '/dashboard',
          searchHint: 'Search accounts, invoices...',
          floatingIcon: Icons.add,
          builder: (_) => const _DashboardContent(),
        );
      case 'screen3':
        return _ScreenSpec(
          route: '/reports',
          searchHint: 'Search records...',
          floatingIcon: Icons.lightbulb_outline,
          builder: (_) => const _ReportsContent(),
        );
      case 'screen4':
        return _ScreenSpec(
          route: '/balance-sheet',
          searchHint: 'Search Ledgers...',
          fiscalBadge: 'FY not configured',
          floatingIcon: Icons.receipt_long,
          builder: (_) => const _BalanceSheetContent(),
        );
      case 'screen1':
      default:
        return _ScreenSpec(
          route: '/ledger',
          searchHint: 'Search entries, vouchers...',
          floatingIcon: Icons.task_alt,
          builder: (_) => const _LedgerContent(),
        );
    }
  }
}

class AppRouteNames {
  static const dashboard = 'Dashboard';
  static const ledger = 'Ledger';
  static const balanceSheet = 'Balance Sheet';
  static const reports = 'Reports';
  static const auditChecklist = 'Audit Checklist';
  static const settings = 'Settings';
  static const notifications = 'Notifications';
  static const help = 'Help';
  static const profile = 'Profile';
}
