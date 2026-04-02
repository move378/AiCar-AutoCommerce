import 'package:flutter/material.dart';

/// AiCar 디자인 시스템 타이포그래피 토큰
/// Pretendard 폰트, Letter Spacing -2%
abstract final class AppTypography {
  static const String _fontFamily = 'Pretendard';

  // ── Display ───────────────────────────────────────
  /// 4xl — 36/44/Bold (H1)
  static TextStyle get display4xl => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        height: 44 / 36,
        fontWeight: FontWeight.w700,
        letterSpacing: 36 * -0.02,
      );

  /// 3xl — 30/38/Bold (H2)
  static TextStyle get display3xl => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 30,
        height: 38 / 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 30 * -0.02,
      );

  // ── Heading ───────────────────────────────────────
  /// 2xl — 24/32/SemiBold (H3)
  static TextStyle get heading2xl => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 24 * -0.02,
      );

  /// xl — 20/30/SemiBold (H4 / Subtitle)
  static TextStyle get headingXl => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 20,
        height: 30 / 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 20 * -0.02,
      );

  // ── Body ──────────────────────────────────────────
  /// lg — 18/28/Normal (Body Large)
  static TextStyle get bodyLg => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        height: 28 / 18,
        fontWeight: FontWeight.w400,
        letterSpacing: 18 * -0.02,
      );

  /// md — 16/24/Normal (Body Medium)
  static TextStyle get bodyMd => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 16 * -0.02,
      );

  /// sm — 14/20/Normal (Body Small)
  static TextStyle get bodySm => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 14 * -0.02,
      );

  // ── Caption & Overline ────────────────────────────
  /// xs — 12/16/Normal (Caption)
  static TextStyle get captionXs => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 12 * -0.02,
      );

  /// 2xs — 11/14/Medium (Overline)
  static TextStyle get overline2xs => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 11 * -0.02,
      );
}
