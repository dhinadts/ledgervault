// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import '../models/backend_models.dart';

Future<String> exportLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  final workbook = _workbookXml(entries, balances);
  final bytes = utf8.encode(workbook);
  final blob = html.Blob([bytes], 'application/vnd.ms-excel');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final fileName =
      'ledger-workbook-${DateTime.now().millisecondsSinceEpoch}.xls';

  html.AnchorElement(href: url)
    ..download = fileName
    ..click();

  return 'Excel workbook downloaded with Summary, Bank Balances, and Ledger Entries sheets.';
}

Future<String> emailLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  return whatsappLedgerStatement(entries, balances);
}

Future<String> whatsappLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  final text = Uri.encodeComponent(
    '${_statementText(entries, balances)}\n\nExcel workbook is downloaded. Please attach it in this WhatsApp chat.',
  );
  html.window.open('https://wa.me/919677096359?text=$text', '_blank');
  return 'WhatsApp opened for +91 96770 96359. Attach the downloaded Excel workbook.';
}

String _workbookXml(List<LedgerEntry> entries, List<BankBalance> balances) {
  final totals = _totals(entries, balances);
  final summaryRows = [
    ['Metric', 'Value'],
    ['Generated On', _formatDate(DateTime.now())],
    ['Cash Balance', totals.cashBalance],
    ['Total Debit', totals.totalDebit],
    ['Total Credit', totals.totalCredit],
    ['Ledger Entries', entries.length],
    ['Bank Accounts', balances.length],
  ];
  final bankRows = [
    ['Account', 'Bank', 'Type', 'Account Number', 'Opening Balance', 'Balance'],
    ...balances.map((account) => [
          account.displayName,
          account.bankName,
          account.accountType,
          account.accountNumber,
          account.openingBalance,
          account.balance,
        ]),
  ];
  final ledgerRows = [
    ['Date', 'Particulars', 'Ledger Ref', 'Debit', 'Credit', 'Status', 'Tags'],
    ...entries.map((entry) => [
          _formatDate(entry.date),
          entry.particulars,
          entry.ledgerRef,
          entry.debit,
          entry.credit,
          entry.status,
          entry.tags.join(', '),
        ]),
  ];

  return '''
<?xml version="1.0"?>
<?mso-application progid="Excel.Sheet"?>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet">
  <Styles>
    <Style ss:ID="Header"><Font ss:Bold="1"/><Interior ss:Color="#EAF2E4" ss:Pattern="Solid"/></Style>
    <Style ss:ID="Currency"><NumberFormat ss:Format="&quot;Rs.&quot;#,##0.00"/></Style>
  </Styles>
  ${_worksheet('Summary', summaryRows)}
  ${_worksheet('Bank Balances', bankRows)}
  ${_worksheet('Ledger Entries', ledgerRows)}
</Workbook>
''';
}

String _worksheet(String name, List<List<Object?>> rows) {
  final xmlRows = rows.asMap().entries.map((rowEntry) {
    final style = rowEntry.key == 0 ? ' ss:StyleID="Header"' : '';
    final cells = rowEntry.value.map((value) => _cell(value)).join();
    return '<Row$style>$cells</Row>';
  }).join();

  return '''
  <Worksheet ss:Name="${_xmlEscape(name)}">
    <Table>$xmlRows</Table>
  </Worksheet>
''';
}

String _cell(Object? value) {
  if (value is num) {
    return '<Cell ss:StyleID="Currency"><Data ss:Type="Number">$value</Data></Cell>';
  }

  return '<Cell><Data ss:Type="String">${_xmlEscape(value?.toString() ?? '')}</Data></Cell>';
}

String _statementText(List<LedgerEntry> entries, List<BankBalance> balances) {
  final totals = _totals(entries, balances);
  final accountLines = balances
      .map((account) =>
          '${account.displayName}: Rs. ${_formatAmount(account.balance)}')
      .join('\n');
  return '''
Dhinadts IT Solutions & Services (OPC) Pvt. Ltd.
Ledger statement

Cash Balance: Rs. ${_formatAmount(totals.cashBalance)}
Total Receivables: Rs. ${_formatAmount(totals.totalDebit)}
Total Payables: Rs. ${_formatAmount(totals.totalCredit)}

Linked Bank Balances:
$accountLines

Entries: ${entries.length}
''';
}

_StatementTotals _totals(
    List<LedgerEntry> entries, List<BankBalance> balances) {
  final totalDebit = entries.fold<double>(0, (sum, entry) => sum + entry.debit);
  final totalCredit =
      entries.fold<double>(0, (sum, entry) => sum + entry.credit);
  final openingBalance =
      balances.fold<double>(0, (sum, account) => sum + account.balance);
  return _StatementTotals(
    totalDebit: totalDebit,
    totalCredit: totalCredit,
    cashBalance: openingBalance,
  );
}

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

String _formatAmount(double value) {
  final sign = value < 0 ? '-' : '';
  final fixed = value.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts.first;
  final decimal = parts.last;

  if (whole.length <= 3) {
    return '$sign$whole.$decimal';
  }

  final lastThree = whole.substring(whole.length - 3);
  var prefix = whole.substring(0, whole.length - 3);
  final groups = <String>[];
  while (prefix.length > 2) {
    groups.insert(0, prefix.substring(prefix.length - 2));
    prefix = prefix.substring(0, prefix.length - 2);
  }
  if (prefix.isNotEmpty) {
    groups.insert(0, prefix);
  }

  return '$sign${groups.join(',')},$lastThree.$decimal';
}

String _xmlEscape(String value) {
  return const HtmlEscape().convert(value);
}

class _StatementTotals {
  final double totalDebit;
  final double totalCredit;
  final double cashBalance;

  const _StatementTotals({
    required this.totalDebit,
    required this.totalCredit,
    required this.cashBalance,
  });
}
