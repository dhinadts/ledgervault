import 'package:flutter/material.dart';

const ledgerAppLogoAsset = 'assets/logo/app_logo.png';
const ledgerCompanyLogoAsset = 'assets/dhinadts/dhinadts_opc_full.png';
const ledgerBrandTitle = 'DHINADTS LEDGER';
const ledgerBrandSubtitle = 'SECURE BALANCE SHEET LEDGER';
const ledgerCompanyName =
    'DHINADTS IT SOLUTIONS AND SUPPORT (OPC) PRIVATE LIMITED';

class LedgerBrandLockup extends StatelessWidget {
  final double logoSize;
  final double titleSize;
  final double subtitleSize;
  final bool dense;
  final bool center;
  final Color? titleColor;
  final Color? subtitleColor;

  const LedgerBrandLockup({
    super.key,
    this.logoSize = 56,
    this.titleSize = 24,
    this.subtitleSize = 12,
    this.dense = false,
    this.center = false,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveTitleColor = titleColor ?? theme.colorScheme.onSurface;
    final effectiveSubtitleColor = subtitleColor ??
        (theme.brightness == Brightness.dark
            ? const Color(0xFFF4C430)
            : const Color(0xFF0B3D2E));

    final logo = Container(
      width: logoSize,
      height: logoSize,
      padding: EdgeInsets.all(dense ? 3 : 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3D2E),
        border: Border.all(color: const Color(0xFFF4C430), width: 1.2),
        borderRadius: BorderRadius.circular(dense ? 10 : 14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(dense ? 7 : 10),
        child: Image.asset(
          ledgerAppLogoAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.account_balance_wallet_rounded,
            color: const Color(0xFFF4C430),
            size: logoSize * 0.54,
          ),
        ),
      ),
    );

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          ledgerBrandTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: effectiveTitleColor,
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: dense ? 2 : 4),
        Text(
          ledgerBrandSubtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: effectiveSubtitleColor,
            fontSize: subtitleSize,
            fontWeight: FontWeight.w900,
            letterSpacing: dense ? 0.4 : 1.1,
          ),
        ),
      ],
    );

    if (center) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          SizedBox(height: dense ? 8 : 14),
          copy,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        SizedBox(width: dense ? 10 : 14),
        Flexible(child: copy),
      ],
    );
  }
}

class DhinadtsCompanyMark extends StatelessWidget {
  final double height;
  final bool showMadeBy;
  final bool center;

  const DhinadtsCompanyMark({
    super.key,
    this.height = 58,
    this.showMadeBy = true,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.brightness == Brightness.dark
        ? const Color(0xFFE1E9DD)
        : const Color(0xFF0B3D2E);

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        ledgerCompanyLogoAsset,
        height: height,
        fit: BoxFit.contain,
        alignment: center ? Alignment.center : Alignment.centerLeft,
        errorBuilder: (_, __, ___) => Text(
          ledgerCompanyName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (showMadeBy) ...[
          Text(
            'Made by',
            style: TextStyle(
              color: labelColor.withOpacity(0.72),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
        ],
        image,
      ],
    );
  }
}
