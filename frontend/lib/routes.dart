import 'package:balance_sheet_ledger/pages/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/login_screen.dart';
import 'pages/screens.dart';
import 'services/bank_account_setup_session.dart';
import 'services/auth_session.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: Listenable.merge([
    AuthSession.revision,
    BankAccountSetupSession.revision,
  ]),
  redirect: (BuildContext context, GoRouterState state) {
    final path = state.location;
    final isAuthRoute = path == '/' || path == '/login' || path == '/signup';
    final isTourRoute = path == '/app-tour';

    final isLoggedIn = AuthSession.isAuthenticated;

    if (!isLoggedIn && !isAuthRoute && !isTourRoute) {
      return '/login';
    }

    if (isLoggedIn && (path == '/login' || path == '/signup')) {
      return '/dashboard';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const LoginScreen()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const SignUpScreen()),
    ),
    GoRoute(
      path: '/app-tour',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const AppTourScreen()),
    ),
    GoRoute(
      path: '/dashboard',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const DashboardScreen()),
    ),
    GoRoute(
      path: '/bank-details',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const BankDetailsScreen(isOnboarding: true)),
    ),
    GoRoute(
      path: '/ledger',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const LedgerScreen()),
    ),
    GoRoute(
      path: '/balance-sheet',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const BalanceSheetScreen()),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const ReportsScreen()),
    ),
    GoRoute(
      path: '/audit-checklist',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const AuditChecklistScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const SettingsScreen()),
    ),
    GoRoute(
      path: '/notifications',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const NotificationsScreen()),
    ),
    GoRoute(
      path: '/help',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const HelpScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const ProfileScreen()),
    ),
    GoRoute(
      path: '/profile/bank-details',
      pageBuilder: (context, state) =>
          _buildWebsitePage(state, const BankDetailsScreen()),
    ),
    GoRoute(
      path: '/screen1',
      pageBuilder: (context, state) => _buildWebsitePage(
        state,
        const ScreenPage(screenKey: 'screen1', title: 'Screen 1'),
      ),
    ),
    GoRoute(
      path: '/screen2',
      pageBuilder: (context, state) => _buildWebsitePage(
        state,
        const ScreenPage(screenKey: 'screen2', title: 'Screen 2'),
      ),
    ),
    GoRoute(
      path: '/screen3',
      pageBuilder: (context, state) => _buildWebsitePage(
        state,
        const ScreenPage(screenKey: 'screen3', title: 'Screen 3'),
      ),
    ),
    GoRoute(
      path: '/screen4',
      pageBuilder: (context, state) => _buildWebsitePage(
        state,
        const ScreenPage(screenKey: 'screen4', title: 'Screen 4'),
      ),
    ),
  ],
);

NoTransitionPage<void> _buildWebsitePage(GoRouterState state, Widget child) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}
