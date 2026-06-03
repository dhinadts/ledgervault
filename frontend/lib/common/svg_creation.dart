import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgLogoFromString extends StatelessWidget {
  final double size;
  final String svgString;

  const SvgLogoFromString({super.key, this.size = 120, this.svgString = ''});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
