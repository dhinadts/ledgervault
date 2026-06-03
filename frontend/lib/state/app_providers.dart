import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/balance_calculator.dart';
import '../models/backend_models.dart';
import '../services/backend_api.dart';

final backendApiProvider = Provider<BackendApi>((ref) => BackendApi());

final ledgerDataProvider = FutureProvider<LedgerData>((ref) async {
  final api = ref.watch(backendApiProvider);
  final results = await Future.wait([
    api.fetchLedgerEntries(),
    api.fetchBankBalances(),
  ]);
  final entries = results[0] as List<LedgerEntry>;
  final balances = results[1] as List<BankBalance>;

  return LedgerData(
    entries: entries,
    balances: balancesWithLedgerActivity(balances, entries),
  );
});

class LedgerData {
  final List<LedgerEntry> entries;
  final List<BankBalance> balances;

  const LedgerData({
    required this.entries,
    required this.balances,
  });

  factory LedgerData.empty() {
    return const LedgerData(
      entries: <LedgerEntry>[],
      balances: <BankBalance>[],
    );
  }
}

class LoginFormState {
  final bool obscurePassword;
  final bool rememberMe;
  final bool isSubmitting;
  final String? error;

  const LoginFormState({
    this.obscurePassword = true,
    this.rememberMe = true,
    this.isSubmitting = false,
    this.error,
  });

  LoginFormState copyWith({
    bool? obscurePassword,
    bool? rememberMe,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return LoginFormState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormController, LoginFormState>(
  (ref) => LoginFormController(ref.watch(backendApiProvider)),
);

class LoginFormController extends StateNotifier<LoginFormState> {
  LoginFormController(this._api) : super(const LoginFormState());

  final BackendApi _api;

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(obscurePassword: !state.obscurePassword);
  }

  void setError(String error) {
    state = state.copyWith(error: error);
  }

  Future<AuthResult?> submit({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      return await _api.login(email: email, password: password);
    } catch (error) {
      state = state.copyWith(error: error.toString());
      return null;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
