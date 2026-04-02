import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// 지도 마커 핀
///
/// Figma: Map pin (default/selected × benz/bmw)
/// node-id: 2534-2573
///
/// **Selected:** 말풍선 형태 — 로고 + 텍스트 라벨 + 하단 꼬리
/// **Default:** 드롭핀 형태 — 로고만 + 뾰족한 꼬리
class MapPin extends StatelessWidget {
  const MapPin({
    super.key,
    required this.brandName,
    this.isSelected = false,
    this.brandLogoAsset,
    this.locationLabel,
  });

  final String brandName;
  final bool isSelected;
  final String? brandLogoAsset;

  /// Selected 상태에서 표시할 위치 라벨 (e.g. "한남 전시장")
  final String? locationLabel;

  @override
  Widget build(BuildContext context) {
    return isSelected ? _buildSelectedPin() : _buildDefaultPin();
  }

  // ── Selected: 말풍선 형태 ─────────────────────
  Widget _buildSelectedPin() {
    final isDarkBrand = _isDarkBrand;
    final bgColor = isDarkBrand ? AppColors.primary : AppColors.background;
    final fgColor = isDarkBrand ? AppColors.textOnDark : AppColors.textPrimary;
    final borderColor = isDarkBrand ? Colors.transparent : AppColors.textDisabled;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 말풍선 본체
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space3,
            vertical: AppSpacing.space2,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            border: borderColor != Colors.transparent
                ? Border.all(color: borderColor)
                : null,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 12,
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogoCircle(size: 32, borderWidth: 1.5, bgColor: bgColor),
              if (locationLabel != null) ...[
                const SizedBox(width: AppSpacing.space2),
                Text(
                  locationLabel!,
                  style: AppTypography.bodySm.copyWith(
                    color: fgColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        // 꼬리 삼각형
        CustomPaint(
          size: const Size(14, 8),
          painter: _TrianglePainter(color: bgColor),
        ),
        // 그림자
        Container(
          width: 20,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            color: Colors.black.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  // ── Default: 드롭핀 형태 ──────────────────────
  Widget _buildDefaultPin() {
    final isDarkBrand = _isDarkBrand;
    final pinColor = isDarkBrand ? AppColors.primary : AppColors.background;
    final borderColor =
        isDarkBrand ? Colors.transparent : AppColors.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 핀 본체
        Container(
          width: 52,
          height: 62,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // 핀 형태 (원 + 꼬리)
              Positioned(
                top: 0,
                child: CustomPaint(
                  size: const Size(52, 60),
                  painter: _PinShapePainter(
                    fillColor: pinColor,
                    borderColor: borderColor,
                  ),
                ),
              ),
              // 로고 원
              Positioned(
                top: 4,
                child: _buildLogoCircle(
                  size: 44,
                  borderWidth: 2,
                  bgColor: pinColor,
                ),
              ),
            ],
          ),
        ),
        // 그림자
        Container(
          width: 18,
          height: 5,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  // ── 로고 원 ───────────────────────────────────
  Widget _buildLogoCircle({
    required double size,
    required double borderWidth,
    required Color bgColor,
  }) {
    final isDarkBrand = _isDarkBrand;
    final ringColor = isDarkBrand
        ? AppColors.textSecondary.withValues(alpha: 0.5)
        : AppColors.textDisabled;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: borderWidth),
        color: bgColor,
      ),
      clipBehavior: Clip.antiAlias,
      child: brandLogoAsset != null
          ? Padding(
              padding: EdgeInsets.all(size * 0.12),
              child: Image.asset(
                brandLogoAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _buildInitial(),
              ),
            )
          : _buildInitial(),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        brandName.isNotEmpty ? brandName[0].toUpperCase() : '?',
        style: AppTypography.bodyMd.copyWith(
          color: _isDarkBrand ? AppColors.textOnDark : AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 벤츠 등 어두운 배경 브랜드인지 판단
  /// 확장 가능: 브랜드별 색상 맵으로 전환 가능
  bool get _isDarkBrand {
    final name = brandName.toLowerCase();
    return name.contains('benz') || name.contains('mercedes');
  }
}

/// 말풍선 하단 삼각형
class _TrianglePainter extends CustomPainter {
  _TrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) =>
      color != oldDelegate.color;
}

/// 드롭핀 형태 (원 + 뾰족한 꼬리)
class _PinShapePainter extends CustomPainter {
  _PinShapePainter({required this.fillColor, required this.borderColor});
  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final circleRadius = size.width / 2;
    final circleCenter = Offset(size.width / 2, circleRadius);

    // 꼬리 시작 각도 계산
    final tailWidth = size.width * 0.22;
    final tailTipY = size.height;

    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // 원 + 꼬리 합쳐 그리기
    final path = Path()
      ..addOval(Rect.fromCircle(center: circleCenter, radius: circleRadius))
      ..moveTo(size.width / 2 - tailWidth, circleRadius + circleRadius * 0.7)
      ..lineTo(size.width / 2, tailTipY)
      ..lineTo(size.width / 2 + tailWidth, circleRadius + circleRadius * 0.7)
      ..close();

    canvas.drawPath(path, paint);

    // 테두리
    if (borderColor != Colors.transparent) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_PinShapePainter oldDelegate) =>
      fillColor != oldDelegate.fillColor || borderColor != oldDelegate.borderColor;
}
