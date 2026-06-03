// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_const_declarations

import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../common/balance_calculator.dart';
import '../models/backend_models.dart';
import '../services/auth_session.dart';
import '../services/backend_api.dart';
import '../services/bank_account_setup_session.dart';
import '../services/audit_document_upload_stub.dart'
    if (dart.library.html) '../services/audit_document_upload_web.dart';
import '../services/statement_actions_stub.dart'
    if (dart.library.html) '../services/statement_actions_web.dart';
import '../state/auth_cubit.dart';
import '../state/app_providers.dart';
import '../state/bank_accounts_cubit.dart';
import '../widgets/brand_identity.dart';

part 'splash_screen.dart';
part 'screen_router.dart';
part 'app_shell.dart';
part 'dashboard_screen.dart';
part 'bank_details_screen.dart';
part 'ledger_screen.dart';
part 'reports_screen.dart';
part 'balance_sheet_screen.dart';
part 'settings_screen.dart';
part 'notifications_screen.dart';
part 'help_profile_screen.dart';
part 'audit_checklist_screen.dart';
part 'common_widgets.dart';

const _primary = Color(0xFF145A32);
const _primaryContainer = Color(0xFF0B3D2E);
const _financeGold = Color(0xFFF4C430);
const _green = Color(0xFF1B7F3A);
const _red = Color(0xFFC31318);
const _softSurface = Color(0xFFF0F4EC);
const _border = Color(0xFFC9D5C7);
const _muted = Color(0xFF4C5A4D);

final _backendApi = BackendApi();
final _appSearchQuery = ValueNotifier<String>('');

String _normalizeLedgerStatus(String status) {
  final value = status.trim().toLowerCase();
  switch (value) {
    case 'paid':
      return 'Paid';
    case 'unpaid':
      return 'Unpaid';
    case 'on hold':
    case 'on-hold':
    case 'on-hold to pay':
    case 'draft':
      return 'On Hold';
    case 'received':
    case 'recieved':
    case 'posted':
      return 'Received';
    case 'to receive':
    case 'yet to receive':
    case 'yet to recieve':
      return 'To Receive';
    case 'not received':
    case 'not recieved':
    case 'not received with reason':
    case 'not recieved with reason':
      return 'Not Received';
    default:
      return status.isEmpty ? 'To Receive' : status;
  }
}

Color _ledgerStatusColor(String status) {
  switch (_normalizeLedgerStatus(status)) {
    case 'Paid':
    case 'Received':
      return const Color(0xFF00C853);
    case 'Unpaid':
    case 'Not Received':
      return const Color(0xFFFF3D00);
    case 'On Hold':
      return const Color(0xFFF0B90B);
    case 'To Receive':
      return const Color(0xFFB7791F);
    default:
      return _muted;
  }
}

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _appBackground(BuildContext context) =>
    Theme.of(context).scaffoldBackgroundColor;

Color _appSurface(BuildContext context) => Theme.of(context).cardColor;

Color _appSoftSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF1D261F) : _softSurface;

Color _appHeaderSurface(BuildContext context) =>
    _isDark(context) ? const Color(0xFF222D24) : const Color(0xFFEAF2E4);

Color _appBorder(BuildContext context) =>
    _isDark(context) ? const Color(0xFF334137) : _border;

Color _appText(BuildContext context) => Theme.of(context).colorScheme.onSurface;

Color _appMuted(BuildContext context) =>
    _isDark(context) ? const Color(0xFFBECAB9) : _muted;

Color _appAccent(BuildContext context) =>
    _isDark(context) ? _financeGold : _primary;

Color _appActiveNav(BuildContext context) =>
    _isDark(context) ? const Color(0xFF24331F) : const Color(0xFFDDEDD6);

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _formatDateTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
          ? date.hour - 12
          : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final period = date.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(date)} $hour:$minute $period';
}

String _formatCurrency(double value) => '₹ ${_formatIndianAmount(value)}';

String _formatIndianAmount(double value) {
  final sign = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final decimals = parts.last;

  if (whole.length <= 3) {
    return '$sign$whole.$decimals';
  }

  final lastThree = whole.substring(whole.length - 3);
  var leading = whole.substring(0, whole.length - 3);
  final groups = <String>[];

  while (leading.length > 2) {
    groups.insert(0, leading.substring(leading.length - 2));
    leading = leading.substring(0, leading.length - 2);
  }

  if (leading.isNotEmpty) {
    groups.insert(0, leading);
  }

  return '$sign${groups.join(',')},$lastThree.$decimals';
}

class _ResponsiveGrid extends StatelessWidget {
  final double minTileWidth;
  final double? tileHeight;
  final List<Widget> children;

  const _ResponsiveGrid({
    required this.minTileWidth,
    required this.children,
    this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minTileWidth)
            .floor()
            .clamp(1, children.length);
        final width = (constraints.maxWidth - ((columns - 1) * 20)) / columns;

        return Wrap(
          spacing: 20,
          runSpacing: 20,
          children: children
              .map(
                (child) => SizedBox(
                  width: width.toDouble(),
                  height: tileHeight,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PageTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _PageTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(subtitle,
            style: TextStyle(color: _appMuted(context), fontSize: 18)),
      ],
    );
  }
}

class _TwoLineText extends StatelessWidget {
  final String text;

  const _TwoLineText(this.text);

  @override
  Widget build(BuildContext context) {
    final parts = text.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          parts.first,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (parts.length > 1)
          Text(parts.last,
              style: TextStyle(color: _appMuted(context), fontSize: 13)),
      ],
    );
  }
}

/* class _AccountColumn extends StatelessWidget {
  final String title;
  final List<_AccountSection> sections;
  final String totalLabel;
  final String total;

  const _AccountColumn({
    required this.title,
    required this.sections,
    required this.totalLabel,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _appHeaderSurface(context),
              border: Border(
                top: BorderSide(color: _appBorder(context)),
                right: BorderSide(color: _appBorder(context)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: Row(
              children: [
                Expanded(
                    child: Text(title,
                        style: const TextStyle(color: _appAccent(context), fontSize: 18))),
                const Text('AMOUNT (₹)',
                    style: TextStyle(color: _appAccent(context), fontSize: 18)),
              ],
            ),
          ),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title,
                      style: const TextStyle(
                          color: _appAccent(context), fontWeight: FontWeight.w800)),
                  const SizedBox(height: 14),
                  ...section.rows.map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        children: [
                          Expanded(child: Text(row[0])),
                          Text(row[1], textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: _primaryContainer,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    totalLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    total,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 */
