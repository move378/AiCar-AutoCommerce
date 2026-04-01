import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// 지도 마커 핀
///
/// Figma: Map pin (selected/default, brand)
/// node-id: 2534-2574
/// 50×62px — shadow + pin body + brand circle (42px)
class MapPin extends StatelessWidget {
  const MapPin({
    super.key,
    required this.brandName,
    this.isSelected = false,
    this.brandLogoUrl,
  });

  final String brandName;
  final bool isSelected;
  final String? brandLogoUrl;

  @override
  Widget build(BuildContext context) {
    final pinColor = isSelected
        ? AppColors.primary
        : AppColors.textTertiary;

    return SizedBox(
      width: 50,
      height: 62,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── Shadow ─────────────────────────────
          Positioned(
            bottom: 0,
            child: Container(
              width: 17,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(3)),
                color: Colors.black.withValues(alpha: isSelected ? 0.2 : 0.1),
              ),
            ),
          ),

          // ── Pin body ───────────────────────────
          Positioned(
            top: 0,
            child: CustomPaint(
              size: const Size(50, 58),
              painter: _PinPainter(color: pinColor),
            ),
          ),

          // ── Brand circle ───────────────────────
          Positioned(
            top: 4,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              child: Center(
                child: Text(
                  brandName.isNotEmpty ? brandName[0].toUpperCase() : '?',
                  style: AppTypography.headingXl.copyWith(
                    color: pinColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 핀 모양 그리기 (역 드롭 형태)
class _PinPainter extends CustomPainter {
  _PinPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      // 상단 원형 부분
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.width / 2),
        width: size.width,
        height: size.width,
      ))
      // 하단 뾰족한 부분
      ..moveTo(size.width * 0.3, size.width * 0.75)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width * 0.7, size.width * 0.75)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) => color != oldDelegate.color;
}
