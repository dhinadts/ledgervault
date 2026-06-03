import 'package:flutter/material.dart';

class LedgerLogo extends StatelessWidget {
  final double size;
  final LogoVariant variant;

  const LedgerLogo({
    super.key,
    this.size = 120,
    this.variant = LogoVariant.full,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case LogoVariant.icon:
        return _buildIconLogo();
      case LogoVariant.text:
        return _buildTextLogo();
      case LogoVariant.full:
        return _buildFullLogo();
    }
  }

  Widget _buildIconLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B3D2E), Color(0xFF145A32)],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        border: Border.all(
          color: const Color(0xFFF4C430),
          width: size * 0.02,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF4C430).withOpacity(0.3),
            blurRadius: size * 0.1,
            spreadRadius: size * 0.02,
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: size * 0.5,
              color: const Color(0xFFF4C430),
            ),
          ),
          Positioned(
            bottom: size * 0.05,
            right: size * 0.05,
            child: Container(
              padding: EdgeInsets.all(size * 0.02),
              decoration: BoxDecoration(
                color: const Color(0xFFF4C430),
                borderRadius: BorderRadius.circular(size * 0.05),
              ),
              child: Text(
                'D',
                style: TextStyle(
                  color: const Color(0xFF0B3D2E),
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DHINADTS',
          style: TextStyle(
            fontSize: size * 0.25,
            fontWeight: FontWeight.w900,
            letterSpacing: size * 0.02,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [Color(0xFFF4C430), Color(0xFFD4A500)],
              ).createShader(Rect.fromLTWH(0, 0, size * 2, size * 0.3)),
          ),
        ),
        Text(
          'LEDGER',
          style: TextStyle(
            fontSize: size * 0.22,
            fontWeight: FontWeight.w800,
            letterSpacing: size * 0.025,
            color: const Color(0xFFF4C430),
          ),
        ),
        Container(
          width: size * 0.8,
          height: 1.5,
          margin: EdgeInsets.symmetric(vertical: size * 0.03),
          color: const Color(0xFFF4C430).withOpacity(0.5),
        ),
        Text(
          'SECURE BALANCE SHEET LEDGER',
          style: TextStyle(
            fontSize: size * 0.07,
            letterSpacing: 1,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildFullLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconLogo(),
        const SizedBox(height: 16),
        _buildTextLogo(),
      ],
    );
  }
}

enum LogoVariant {
  icon,
  text,
  full,
}
