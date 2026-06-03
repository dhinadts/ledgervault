import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/backend_models.dart';

class AuthSession {
  static const _rememberKey = 'ledger_remember_session';
  static const _sessionKey = 'ledger_auth_session';

  static AuthResult? _current;
  static bool _rememberMe = false;
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static AuthResult? get current => _current;
  static String? get token => _current?.token;
  static bool get isAuthenticated => _current?.token.isNotEmpty == true;
  static bool get rememberMe => _rememberMe;

  static Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool(_rememberKey) ?? false;
    if (!_rememberMe) {
      _current = null;
      _notifyChanged();
      return;
    }

    final rawSession = prefs.getString(_sessionKey);
    if (rawSession == null || rawSession.isEmpty) {
      _current = null;
      _notifyChanged();
      return;
    }

    try {
      _current = AuthResult.fromJson(
        jsonDecode(rawSession) as Map<String, dynamic>,
      );
    } catch (_) {
      _current = null;
      await prefs.remove(_sessionKey);
    }
    _notifyChanged();
  }

  static Future<void> save(AuthResult result,
      {required bool rememberMe}) async {
    _current = result;
    _rememberMe = rememberMe;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberKey, rememberMe);

    if (rememberMe) {
      await prefs.setString(_sessionKey, jsonEncode(result.toJson()));
    } else {
      await prefs.remove(_sessionKey);
    }
    _notifyChanged();
  }

  static Future<void> clear() async {
    _current = null;
    _rememberMe = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.setBool(_rememberKey, false);
    _notifyChanged();
  }

  static void _notifyChanged() {
    revision.value++;
  }
}
