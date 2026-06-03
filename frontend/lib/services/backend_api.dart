import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/backend_models.dart';
import 'auth_session.dart';

class BackendApi {
  BackendApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  static String get _defaultBaseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'https://ledger-06q7.onrender.com';
    }
    return 'https://ledger-06q7.onrender.com';
// return     'https://ledger-06q7.onrender.com';
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    final data = await _send(
      'POST',
      '/api/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      },
    );
    return AuthResult.fromJson(data as Map<String, dynamic>);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final data = await _send(
      'POST',
      '/api/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
    return AuthResult.fromJson(data as Map<String, dynamic>);
  }

  Future<AuthUser> updateProfile({
    required String firstName,
    required String lastName,
    required String photoUrl,
  }) async {
    final displayName = [firstName.trim(), lastName.trim()]
        .where((part) => part.isNotEmpty)
        .join(' ');
    final data = await _send(
      'PATCH',
      '/api/auth/profile',
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'name': displayName,
        'photoUrl': photoUrl.trim().isEmpty ? null : photoUrl.trim(),
      },
    );
    return AuthUser.fromJson(data as Map<String, dynamic>? ?? {});
  }

  Future<List<LedgerEntry>> fetchLedgerEntries() async {
    final data = await _get('/api/ledger');
    final entries = data as List<dynamic>? ?? const [];
    return entries
        .whereType<Map<String, dynamic>>()
        .map(LedgerEntry.fromJson)
        .toList();
  }

  Future<List<LedgerEntry>> searchLedgerEntries(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final data = await _get(
      '/api/ledger?search=${Uri.encodeQueryComponent(trimmed)}',
    );
    final entries = data as List<dynamic>? ?? const [];
    return entries
        .whereType<Map<String, dynamic>>()
        .map(LedgerEntry.fromJson)
        .toList();
  }

  Future<List<BankBalance>> fetchBankBalances() async {
    return _loadLocalBankBalances();
  }

  Future<LedgerEntry> createLedgerEntry(Map<String, dynamic> entry) async {
    final data = await _send('POST', '/api/ledger/entry', body: entry);
    return LedgerEntry.fromJson(data as Map<String, dynamic>);
  }

  Future<LedgerEntry> updateLedgerEntry(
    String id,
    Map<String, dynamic> entry,
  ) async {
    final data = await _send('PUT', '/api/ledger/entry/$id', body: entry);
    return LedgerEntry.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteLedgerEntry(String id) async {
    await _send('DELETE', '/api/ledger/entry/$id');
  }

  Future<List<LedgerEntry>> syncLedgerEntries(
    List<Map<String, dynamic>> entries,
  ) async {
    final data = await _send(
      'POST',
      '/api/ledger/sync',
      body: {'entries': entries},
    );
    return (data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(LedgerEntry.fromJson)
        .toList();
  }

  Future<BalanceSheetSummary> fetchBalanceSheet() async {
    final data = await _get('/api/balance-sheet/current');
    return BalanceSheetSummary.fromJson(data as Map<String, dynamic>? ?? {});
  }

  Future<BalanceSheetItem> createBalanceSheetItem(
    Map<String, dynamic> item,
  ) async {
    final data = await _send('POST', '/api/balance-sheet/items', body: item);
    return BalanceSheetItem.fromJson(data as Map<String, dynamic>);
  }

  Future<BalanceSheetItem> updateBalanceSheetItem(
    String id,
    Map<String, dynamic> item,
  ) async {
    final data = await _send('PUT', '/api/balance-sheet/items/$id', body: item);
    return BalanceSheetItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteBalanceSheetItem(String id) async {
    await _send('DELETE', '/api/balance-sheet/items/$id');
  }

  Future<List<BalanceSheetItem>> syncBalanceSheetItems(
    List<Map<String, dynamic>> items,
  ) async {
    final data = await _send(
      'POST',
      '/api/balance-sheet/sync',
      body: {'items': items},
    );
    return (data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(BalanceSheetItem.fromJson)
        .toList();
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final data = await _get('/api/notifications/history');
    final notifications = data as List<dynamic>? ?? const [];
    return notifications
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  Future<AppNotification> sendNotification(
    Map<String, dynamic> notification,
  ) async {
    final data = await _send(
      'POST',
      '/api/notifications/send',
      body: notification,
    );
    return AppNotification.fromJson(data as Map<String, dynamic>);
  }

  Future<AppNotification> markNotificationRead(String id, bool isRead) async {
    final data = await _send(
      'PATCH',
      '/api/notifications/$id/read',
      body: {'isRead': isRead},
    );
    return AppNotification.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteNotification(String id) async {
    await _send('DELETE', '/api/notifications/$id');
  }

  Future<List<AppNotification>> syncNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    final data = await _send(
      'POST',
      '/api/notifications/sync',
      body: {'notifications': notifications},
    );
    return (data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchAuditDocuments() async {
    final data = await _get('/api/audit/documents');
    return (data as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<Map<String, dynamic>> uploadAuditDocument({
    required String section,
    required String checklistItem,
    required String fileName,
    required String contentType,
    required String base64Data,
  }) async {
    final data = await _send(
      'POST',
      '/api/audit/documents',
      body: {
        'section': section,
        'checklistItem': checklistItem,
        'fileName': fileName,
        'contentType': contentType,
        'base64Data': base64Data,
      },
    );
    return data as Map<String, dynamic>;
  }

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: _headers())
          .timeout(const Duration(seconds: 30));
    } on TimeoutException {
      throw BackendApiException(_connectionErrorMessage);
    } on http.ClientException {
      throw BackendApiException(_connectionErrorMessage);
    }
    final body = _decodeResponse(response);

    if (response.statusCode >= 400 || body['success'] != true) {
      await _handleAuthFailure(response.statusCode);
      throw BackendApiException(body['error']?.toString() ?? 'Request failed');
    }

    return body['data'];
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = _headers();
    final payload = body == null ? null : jsonEncode(body);
    final timeout = path == '/api/auth/login'
        ? const Duration(seconds: 15)
        : const Duration(seconds: 30);

    late final http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: payload)
              .timeout(timeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: payload)
              .timeout(timeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: payload)
              .timeout(timeout);
          break;
        case 'DELETE':
          response =
              await _client.delete(uri, headers: headers).timeout(timeout);
          break;
        default:
          throw const BackendApiException('Unsupported request method');
      }
    } on TimeoutException {
      throw BackendApiException(_connectionErrorMessage);
    } on http.ClientException {
      throw BackendApiException(_connectionErrorMessage);
    }

    final decoded = response.body.isEmpty
        ? <String, dynamic>{'success': response.statusCode < 400}
        : _decodeResponse(response);

    if (response.statusCode >= 400 || decoded['success'] != true) {
      await _handleAuthFailure(response.statusCode);
      throw BackendApiException(
        decoded['error']?.toString() ??
            decoded['message']?.toString() ??
            'Request failed',
      );
    }

    return decoded['data'];
  }

  Map<String, String> _headers() {
    final token = AuthSession.token;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _handleAuthFailure(int statusCode) async {
    if (statusCode == 401 || statusCode == 403) {
      await AuthSession.clear();
    }
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw BackendApiException(
        'Unexpected response from backend at $_baseUrl.',
      );
    }
  }

  String get _connectionErrorMessage =>
      'Cannot reach backend at $_baseUrl. Start the backend server and try again.';

  Future<List<BankBalance>> _loadLocalBankBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ledger_local_bank_accounts');
    if (raw == null || raw.isEmpty) {
      return const <BankBalance>[];
    }

    try {
      final items = jsonDecode(raw) as List<dynamic>;
      return _dedupeBankBalances(
        items
            .whereType<Map<String, dynamic>>()
            .map(BankBalance.fromJson)
            .toList(),
      );
    } catch (_) {
      await prefs.remove('ledger_local_bank_accounts');
      return const <BankBalance>[];
    }
  }

  List<BankBalance> _dedupeBankBalances(List<BankBalance> accounts) {
    final seen = <String>{};
    final result = <BankBalance>[];

    for (final account in accounts) {
      final key = _bankAccountKey(account);
      if (seen.add(key)) {
        result.add(account);
      }
    }

    return result;
  }

  String _bankAccountKey(BankBalance account) {
    final accountNumber = account.accountNumber.trim().toLowerCase();
    final ifsc = account.ifsc.trim().toLowerCase();
    if (accountNumber.isNotEmpty || ifsc.isNotEmpty) {
      return '$accountNumber|$ifsc';
    }

    return [
      account.accountHolderName,
      account.bankName,
      account.accountType,
    ].map((value) => value.trim().toLowerCase()).join('|');
  }
}

class BackendApiException implements Exception {
  final String message;

  const BackendApiException(this.message);

  bool get isAuthenticationError {
    final normalized = message.toLowerCase();
    return normalized.contains('authentication required') ||
        normalized.contains('valid jwt token') ||
        normalized.contains('unauthorized') ||
        normalized.contains('forbidden');
  }

  @override
  String toString() => message;
}
