import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_elevation.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle_card.dart';

/// 차량 추천 카드 앞면 위젯
///
/// Figma 기준 296×280px, slate-500 배경
class CardFrontWidget extends StatelessWidget {
  const CardFrontWidget({
    super.key,
    required this.card,
  });

  final VehicleCard card;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 296,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppShape.radiusMd,
        boxShadow: AppElevation.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 차량 이미지 placeholder
          Container(
            height: 140,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF475569), // slate-600
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_rounded,
                size: 64,
                color: AppColors.textDisabled,
              ),
            ),
          ),

          // 차량 정보
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 브랜드
                Text(
                  card.brandName,
                  style: AppTypography.captionXs.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: AppSpacing.space1),

                // 모델명
                Text(
                  card.modelName,
                  style: AppTypography.headingXl.copyWith(
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),

                // 가격
                Text(
                  card.formattedPrice,
                  style: AppTypography.bodyLg.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.space3),

                // 주요 스펙
                Row(
                  children: [
                    _SpecChip(
                      label: '${card.specs.power}hp',
                      icon: Icons.speed_rounded,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    _SpecChip(
                      label: '${card.specs.fuelEfficiency}km/L',
                      icon: Icons.local_gas_station_rounded,
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    _SpecChip(
                      label: card.fuelType,
                      icon: Icons.eco_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 스펙 표시 칩 (카드 내부용)
class _SpecChip extends StatelessWidget {
  const _SpecChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space2,
        vertical: AppSpacing.space1,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF334155), // slate-700
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textDisabled),
          const SizedBox(width: AppSpacing.space1),
          Text(
            label,
            style: AppTypography.captionXs.copyWith(
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}
