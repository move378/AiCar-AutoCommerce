import 'dart:math';

import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle_card.dart';

/// 차량 성능 레이더 차트 (5축: 마력, 토크, 연비, 제로백, 가격)
class RadarChart extends StatelessWidget {
  const RadarChart({
    super.key,
    required this.specs,
    required this.price,
    this.size = 200,
  });

  final VehicleSpecs specs;

  /// 가격 (만원 단위)
  final int price;

  /// 위젯 크기 (정사각형)
  final double size;

  @override
  Widget build(BuildContext context) {
    final values = _normalize();
    const labels = ['마력', '토크', '연비', '제로백', '가격'];

    return SizedBox(
      width: size,
      height: size + AppSpacing.space2,
      child: CustomPaint(
        size: Size(size, size),
        painter: _RadarChartPainter(values: values, labels: labels),
      ),
    );
  }

  /// 각 축을 0~1로 정규화
  List<double> _normalize() {
    return [
      (specs.power / 400).clamp(0.0, 1.0),
      (specs.torque / 60).clamp(0.0, 1.0),
      (specs.fuelEfficiency / 25).clamp(0.0, 1.0),
      ((12 - specs.zeroToHundred) / 9).clamp(0.0, 1.0), // 역수: 빠를수록 높음
      ((10000 - price) / 7000).clamp(0.0, 1.0), // 역수: 저렴할수록 높음
    ];
  }
}

class _RadarChartPainter extends CustomPainter {
  _RadarChartPainter({
    required this.values,
    required this.labels,
  });

  final List<double> values;
  final List<String> labels;

  static const int _sides = 5;
  static const int _gridLevels = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 24; // 라벨 공간 확보

    // 그리드 라인
    final gridPaint = Paint()
      ..color = AppColors.textDisabled.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var level = 1; level <= _gridLevels; level++) {
      final levelRadius = radius * level / _gridLevels;
      final path = Path();
      for (var i = 0; i < _sides; i++) {
        final angle = _angleFor(i);
        final point = Offset(
          center.dx + levelRadius * cos(angle),
          center.dy + levelRadius * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 축 라인
    final axisPaint = Paint()
      ..color = AppColors.textDisabled.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    for (var i = 0; i < _sides; i++) {
      final angle = _angleFor(i);
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        ),
        axisPaint,
      );
    }

    // 데이터 영역 (fill)
    final fillPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final dataPath = Path();
    for (var i = 0; i < _sides; i++) {
      final angle = _angleFor(i);
      final value = values[i];
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath, fillPaint);

    // 데이터 영역 (stroke)
    final strokePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(dataPath, strokePaint);

    // 데이터 포인트
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    for (var i = 0; i < _sides; i++) {
      final angle = _angleFor(i);
      final value = values[i];
      final point = Offset(
        center.dx + radius * value * cos(angle),
        center.dy + radius * value * sin(angle),
      );
      canvas.drawCircle(point, 3, dotPaint);
    }

    // 축 라벨
    for (var i = 0; i < _sides; i++) {
      final angle = _angleFor(i);
      final labelOffset = Offset(
        center.dx + (radius + 16) * cos(angle),
        center.dy + (radius + 16) * sin(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: AppTypography.captionXs.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - textPainter.width / 2,
          labelOffset.dy - textPainter.height / 2,
        ),
      );
    }
  }

  /// 각 축의 각도 (12시 방향부터 시계방향)
  double _angleFor(int index) {
    return -pi / 2 + (2 * pi * index / _sides);
  }

  @override
  bool shouldRepaint(covariant _RadarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
