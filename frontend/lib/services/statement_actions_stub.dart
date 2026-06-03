import '../models/backend_models.dart';

Future<String> exportLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  return 'Excel workbook export is available in the web build.';
}

Future<String> emailLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  return 'WhatsApp sharing is available in the web build.';
}

Future<String> whatsappLedgerStatement(
  List<LedgerEntry> entries,
  List<BankBalance> balances,
) async {
  return 'WhatsApp sharing is available in the web build.';
}
