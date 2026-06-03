import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BankAccountSetupSession {
  static const _completeKey = 'ledger_bank_account_setup_complete';

  static bool _isComplete = false;
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static bool get isComplete => _isComplete;

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _isComplete = prefs.getBool(_completeKey) ?? false;
    _notifyChanged();
  }

  static Future<void> markComplete() async {
    _isComplete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_completeKey, true);
    _notifyChanged();
  }

  static Future<void> reset() async {
    _isComplete = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completeKey);
    _notifyChanged();
  }

  static void _notifyChanged() {
    revision.value++;
  }
}
