import 'package:flutter/material.dart';

/// AiCar 디자인 시스템 Elevation 토큰
/// 라이트 모드 전용, 3단계
abstract final class AppElevation {
  /// Level 0 — none (기본 상태)
  static const List<BoxShadow> elevation0 = [];

  /// Level 1 — 카드, 드롭다운
  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 3,
      color: Color(0x140F172A), // rgba(15,23,42,0.08)
    ),
  ];

  /// Level 2 — 모달, FAB
  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 12,
      color: Color(0x1F0F172A), // rgba(15,23,42,0.12)
    ),
  ];

  /// Level 3 — 바텀시트, 오버레이
  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 24,
      color: Color(0x290F172A), // rgba(15,23,42,0.16)
    ),
  ];
}
