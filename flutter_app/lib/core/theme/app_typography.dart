import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String fontFamily = 'Pretendard';

  // Headings
  static const TextStyle h1 = TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle h2 = TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.w700, height: 1.3);
  static const TextStyle h3 = TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle h4 = TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);

  // Body
  static const TextStyle bodyLg = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodyMd = TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle bodySm = TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);

  // Labels
  static const TextStyle labelLg = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle labelMd = TextStyle(fontFamily: fontFamily, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle labelSm = TextStyle(fontFamily: fontFamily, fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);

  // Caption
  static const TextStyle caption = TextStyle(fontFamily: fontFamily, fontSize: 11, fontWeight: FontWeight.w400, height: 1.4);
}
