import 'package:flutter/material.dart';

/// AiCar 디자인 시스템 Shape 토큰
/// Border Radius + 컴포넌트 Padding 프리셋
abstract final class AppShape {
  // ── Border Radius ─────────────────────────────────
  /// Button, Card, Input Field — 10px
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(10));

  /// Chip (pill) — 100px
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(100));

  /// Avatar (circle) — 999px
  static const BorderRadius radiusCircle = BorderRadius.all(Radius.circular(999));

  // ── Component Padding ─────────────────────────────
  /// Button (sm/lg) — H16 V10
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 10,
  );

  /// Chip — H10 V6
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );

  /// Tab Bar — H16 V0
  static const EdgeInsets tabBarPadding = EdgeInsets.symmetric(
    horizontal: 16,
  );
}
