import 'package:flutter/material.dart';

class LedgerEntry {
  final String id;
  final DateTime date;
  final String particulars;
  final String ledgerRef;
  final double debit;
  final double credit;
  final String status;
  final List<String> tags;

  const LedgerEntry({
    required this.id,
    required this.date,
    required this.particulars,
    required this.ledgerRef,
    required this.debit,
    required this.credit,
    required this.status,
    required this.tags,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      particulars: json['particulars']?.toString() ?? '',
      ledgerRef: json['ledgerRef']?.toString() ?? '',
      debit: _toDouble(json['debit']),
      credit: _toDouble(json['credit']),
      status: json['status']?.toString() ?? 'PENDING',
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((tag) => tag.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'particulars': particulars,
        'ledgerRef': ledgerRef,
        'debit': debit,
        'credit': credit,
        'status': status,
        'tags': tags,
      };
}

class BankBalance {
  final String id;
  final String accountHolderName;
  final String ownerType;
  final String accountName;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String ifsc;
  final String accountType;
  final double openingBalance;
  final double balance;
  final bool primaryAccount;

  const BankBalance({
    required this.id,
    required this.accountHolderName,
    required this.ownerType,
    required this.accountName,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifsc,
    required this.accountType,
    required this.openingBalance,
    required this.balance,
    required this.primaryAccount,
  });

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }
    return '•••• ${accountNumber.substring(accountNumber.length - 4)}';
  }

  String get displayName {
    final holder =
        accountHolderName.isNotEmpty ? accountHolderName : accountName;
    return '$holder - $bankName';
  }

  factory BankBalance.fromJson(Map<String, dynamic> json) {
    final holder = json['accountHolderName']?.toString() ??
        json['accountName']?.toString() ??
        '';
    final balance = _toDouble(json['balance'] ?? json['openingBalance']);
    return BankBalance(
      id: json['id']?.toString() ?? '',
      accountHolderName: holder,
      ownerType: json['ownerType']?.toString() ?? 'Company',
      accountName: json['accountName']?.toString() ?? holder,
      bankName: json['bankName']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      ifsc: json['ifsc']?.toString() ?? '',
      accountType: json['accountType']?.toString() ?? '',
      openingBalance: _toDouble(json['openingBalance'] ?? balance),
      balance: balance,
      primaryAccount: json['primaryAccount'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountHolderName': accountHolderName,
        'ownerType': ownerType,
        'accountName': accountName,
        'bankName': bankName,
        'branchName': branchName,
        'accountNumber': accountNumber,
        'ifsc': ifsc,
        'accountType': accountType,
        'openingBalance': openingBalance,
        'balance': balance,
        'primaryAccount': primaryAccount,
      };

  BankBalance copyWith({
    double? openingBalance,
    double? balance,
  }) {
    return BankBalance(
      id: id,
      accountHolderName: accountHolderName,
      ownerType: ownerType,
      accountName: accountName,
      bankName: bankName,
      branchName: branchName,
      accountNumber: accountNumber,
      ifsc: ifsc,
      accountType: accountType,
      openingBalance: openingBalance ?? this.openingBalance,
      balance: balance ?? this.balance,
      primaryAccount: primaryAccount,
    );
  }
}

class BalanceSheetItem {
  final String id;
  final String name;
  final String group;
  final String type;
  final double value;

  const BalanceSheetItem({
    required this.id,
    required this.name,
    required this.group,
    required this.type,
    required this.value,
  });

  factory BalanceSheetItem.fromJson(Map<String, dynamic> json) {
    return BalanceSheetItem(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      group: json['group']?.toString() ?? 'General',
      type: json['type']?.toString() ?? '',
      value: _toDouble(json['value']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'group': group,
        'type': type,
        'value': value,
      };
}

class BalanceSheetSummary {
  final List<BalanceSheetItem> assets;
  final List<BalanceSheetItem> liabilities;
  final List<BalanceSheetItem> equity;

  const BalanceSheetSummary({
    required this.assets,
    required this.liabilities,
    required this.equity,
  });

  factory BalanceSheetSummary.fromJson(Map<String, dynamic> json) {
    List<BalanceSheetItem> readItems(String key) {
      return (json[key] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(BalanceSheetItem.fromJson)
          .toList();
    }

    return BalanceSheetSummary(
      assets: readItems('assets'),
      liabilities: readItems('liabilities'),
      equity: readItems('equity'),
    );
  }
}

class AppNotification {
  final String id;
  final String title;
  final String detail;
  final String time;
  final Color color;
  final String level;

  const AppNotification({
    required this.id,
    required this.title,
    required this.detail,
    required this.time,
    required this.color,
    required this.level,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final level = json['level']?.toString().toLowerCase() ?? 'info';
    return AppNotification(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      color: _colorFromApi(json['color']?.toString(), level),
      level: level,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'detail': detail,
        'time': time,
        'color':
            '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}',
        'level': level,
      };
}

class AuthUser {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String photoUrl;
  final String email;
  final String role;

  const AuthUser({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
    required this.email,
    required this.role,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final nameParts = name.trim().split(RegExp(r'\s+'));
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: name,
      firstName: json['firstName']?.toString() ??
          (nameParts.isNotEmpty ? nameParts.first : ''),
      lastName: json['lastName']?.toString() ??
          (nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ''),
      photoUrl: json['photoUrl']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'firstName': firstName,
        'lastName': lastName,
        'photoUrl': photoUrl,
        'email': email,
        'role': role,
      };

  AuthUser copyWith({
    String? name,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? email,
    String? role,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photoUrl: photoUrl ?? this.photoUrl,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}

class AuthResult {
  final String token;
  final String refreshToken;
  final AuthUser user;

  const AuthResult({
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      };
}

double _toDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

Color _colorFromApi(String? value, String level) {
  if (value != null && value.startsWith('#')) {
    final hex = value.replaceFirst('#', '');
    final parsed = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    if (parsed != null) {
      return Color(parsed);
    }
  }

  switch (level) {
    case 'success':
      return const Color(0xFF1B7F3A);
    case 'warning':
    case 'error':
      return const Color(0xFFC31318);
    default:
      return const Color(0xFF145A32);
  }
}
