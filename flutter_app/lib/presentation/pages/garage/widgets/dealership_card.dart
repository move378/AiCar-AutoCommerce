import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_elevation.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// 전시장 카드 데이터
class Dealership {
  const Dealership({
    required this.brand,
    required this.name,
    required this.address,
    required this.hours,
    required this.distance,
  });

  final String brand;
  final String name;
  final String address;
  final String hours;
  final String distance;
}

/// 전시장 카드 위젯
///
/// Figma: 브랜드 로고 + 거리 + 이름 + 주소 + 영업시간 + 상세정보/시승예약 버튼
class DealershipCard extends StatelessWidget {
  const DealershipCard({
    super.key,
    required this.dealership,
    this.isSaved = false,
    this.onSave,
  });

  final Dealership dealership;
  final bool isSaved;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSave,
      child: Container(
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppShape.radiusMd,
        boxShadow: AppElevation.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 브랜드 + 거리 ──
          Row(
            children: [
              // 브랜드 로고 placeholder
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    dealership.brand[0],
                    style: AppTypography.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                dealership.brand,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                  vertical: AppSpacing.space1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppShape.radiusMd,
                ),
                child: Text(
                  dealership.distance,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          // ── 전시장 정보 + 이미지 ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dealership.name,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      dealership.address,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      dealership.hours,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              // 전시장 이미지 placeholder
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppShape.radiusMd,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space3),
          // ── 버튼 2개 ──
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  isSaved ? '저장 해제' : '상세 정보',
                  false,
                  onTap: onSave,
                ),
              ),
              const SizedBox(width: AppSpacing.space3),
              Expanded(
                child: _buildButton('시승 예약', true, onTap: onSave),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildButton(String label, bool isPrimary, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.background,
          borderRadius: AppShape.radiusMd,
          border: isPrimary
              ? null
              : Border.all(color: AppColors.textDisabled),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: isPrimary ? AppColors.textOnDark : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
