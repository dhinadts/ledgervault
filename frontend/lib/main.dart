import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'app_theme.dart';
import 'routes.dart';
import 'state/bank_accounts_cubit.dart';
import 'state/auth_cubit.dart';
import 'services/bank_account_setup_session.dart';
import 'services/auth_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AuthSession.restore();
    await BankAccountSetupSession.restore();
  } catch (e) {
    debugPrint('Session restore failed: $e');
  }

  runApp(const BalanceSheetLedgerApp());
  FlutterNativeSplash.remove();
}

class BalanceSheetLedgerApp extends StatelessWidget {
  const BalanceSheetLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AuthCubit()),
          BlocProvider(create: (_) => BankAccountsCubit()),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: AppThemeController.themeMode,
          builder: (context, themeMode, child) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'LedgerVault',
              routerConfig: appRouter,
              themeMode: themeMode,
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
            );
          },
        ),
      ),
    );
  }
}
