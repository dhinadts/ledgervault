import '../models/backend_models.dart';

List<BankBalance> balancesWithLedgerActivity(
  List<BankBalance> balances,
  List<LedgerEntry> entries,
) {
  return balances.map((account) {
    final movement = entries
        .where((entry) => entryMatchesAccount(entry, account))
        .fold<double>(
          0,
          (sum, entry) => sum + entry.debit - entry.credit,
        );

    return account.copyWith(balance: account.openingBalance + movement);
  }).toList();
}

bool entryMatchesAccount(LedgerEntry entry, BankBalance account) {
  final ref = normalizeAccountText(entry.ledgerRef);
  if (ref.isEmpty) {
    return false;
  }

  final candidates = <String>[
    account.displayName,
    account.accountName,
    account.accountHolderName,
    '${account.accountType} Account - ${account.bankName}',
    '${account.accountType} - ${account.bankName}',
    account.bankName,
    account.accountNumber,
  ].map(normalizeAccountText).where((value) => value.isNotEmpty);

  return candidates.any((candidate) => ref == candidate);
}

String normalizeAccountText(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}
