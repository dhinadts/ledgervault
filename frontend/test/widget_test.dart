// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:balance_sheet_ledger/main.dart';
import 'package:balance_sheet_ledger/pages/login_screen.dart';
import 'package:balance_sheet_ledger/routes.dart';
import 'package:balance_sheet_ledger/models/backend_models.dart';
import 'package:balance_sheet_ledger/services/auth_session.dart';
import 'package:balance_sheet_ledger/services/bank_account_setup_session.dart';

void main() {
  testWidgets('logs in and renders generated ledger route',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await AuthSession.clear();
    await BankAccountSetupSession.reset();
    appRouter.go('/');

    await tester.binding.setSurfaceSize(const Size(1280, 900));
    await tester.pumpWidget(const BalanceSheetLedgerApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.text('Create Account'), findsWidgets);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome Back'), findsOneWidget);

    await _authenticateForTests();

    GoRouter.of(tester.element(find.byType(LoginScreen))).go('/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('AVAILABLE CASH / BANK'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Quick Dashboard Action'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Entry'));
    await tester.pumpAndSettle();
    expect(find.text('Add Ledger Entry'), findsOneWidget);

    await tester.tap(find.text('Save Draft'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ledger'));
    await tester.pumpAndSettle();

    expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
  });

  testWidgets('balance sheet remains stable across responsive widths',
      (WidgetTester tester) async {
    final sizes = [
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1366, 768),
      const Size(1920, 1080),
      const Size(3840, 2160),
    ];

    for (final size in sizes) {
      SharedPreferences.setMockInitialValues({});
      await _authenticateForTests();
      appRouter.go('/balance-sheet');
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const BalanceSheetLedgerApp());

      await tester.pumpAndSettle();

      expect(find.text('Bank-wise Balance Sheet'), findsOneWidget);
      expect(find.text('TOTAL LIABILITIES'), findsOneWidget);
      expect(find.text('TOTAL ASSETS'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.height == 196,
        ),
        findsNWidgets(3),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('primary screens stay responsive across device classes',
      (WidgetTester tester) async {
    final routes = [
      '/dashboard',
      '/ledger',
      '/balance-sheet',
      '/reports',
      '/audit-checklist',
      '/settings',
      '/notifications',
      '/help',
      '/profile',
      '/bank-details',
    ];
    final sizes = [
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1366, 768),
      const Size(1920, 1080),
      const Size(3840, 2160),
    ];

    for (final size in sizes) {
      SharedPreferences.setMockInitialValues({});
      await _authenticateForTests();
      appRouter.go('/dashboard');
      await tester.binding.setSurfaceSize(size);
      await tester.pumpWidget(const BalanceSheetLedgerApp());

      for (final route in routes) {
        appRouter.go(route);
        await tester.pumpAndSettle();

        expect(find.byType(Scaffold), findsWidgets);
        expect(tester.takeException(), isNull, reason: '$route at $size');
      }
    }
  });
}

Future<void> _authenticateForTests() async {
  await AuthSession.save(
    const AuthResult(
      token: 'test-token',
      refreshToken: 'test-refresh-token',
      user: AuthUser(
        id: 'test-user',
        name: 'Test User',
        firstName: 'Test',
        lastName: 'User',
        photoUrl: '',
        email: 'test@example.com',
        role: 'admin',
      ),
    ),
    rememberMe: true,
  );
  await BankAccountSetupSession.markComplete();
}
