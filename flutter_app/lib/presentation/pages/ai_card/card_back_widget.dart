import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/presentation/pages/ai_card/widgets/radar_chart.dart';

/// 차량 추천 카드 뒷면 위젯 (상세 스펙 + Radar chart)
class CardBackWidget extends StatelessWidget {
  const CardBackWidget({
    super.key,
    required this.card,
    this.isCompact = false,
    this.onCustomize,
  });

  final Vehicle card;
  final bool isCompact;
  final VoidCallback? onCustomize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCompact ? 200 : 296,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: isCompact ? _buildCompact() : _buildFull(),
    );
  }

  Widget _buildCompact() {
    final specs = card.specs;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            card.displayName,
            style: AppTypography.captionXs.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (specs != null)
            Expanded(
              child: Center(
                child: RadarChart(
                  specs: specs,
                  price: card.price,
                  size: 80,
                ),
              ),
            )
          else
            const Expanded(child: SizedBox.shrink()),
          _SpecRow(
            label: '마력',
            value: '${specs?.power ?? '-'}hp',
            isCompact: true,
          ),
          _SpecRow(
            label: '연비',
            value: '${specs?.fuelEfficiency ?? card.fuelEfficiency ?? '-'}km/L',
            isCompact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFull() {
    final specs = card.specs;
    return Column(
      children: [
        // Radar Chart (specs가 있을 때만)
        if (specs != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.space4),
            child: Center(
              child: RadarChart(
                specs: specs,
                price: card.price,
                size: 160,
              ),
            ),
          ),

        // 스펙 리스트
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          child: Column(
            children: [
              _SpecRow(
                label: '마력',
                value: '${specs?.power ?? '-'}hp',
                icon: Icons.speed_rounded,
              ),
              _SpecRow(
                label: '토크',
                value: '${specs?.torque ?? '-'}kgm',
                icon: Icons.rotate_right_rounded,
              ),
              _SpecRow(
                label: '연비',
                value: '${specs?.fuelEfficiency ?? card.fuelEfficiency ?? '-'}km/L',
                icon: Icons.local_gas_station_rounded,
              ),
              _SpecRow(
                label: '제로백',
                value: '${specs?.zeroToHundred ?? '-'}초',
                icon: Icons.timer_rounded,
              ),
            ],
          ),
        ),

        // 커스터마이즈 버튼
        if (onCustomize != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space3),
            child: GestureDetector(
              onTap: onCustomize,
              child: Text(
                '커스터마이즈 >',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 스펙 행 위젯
class _SpecRow extends StatelessWidget {
  const _SpecRow({
    required this.label,
    required this.value,
    this.icon,
    this.isCompact = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isCompact ? 1 : AppSpacing.space1,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.textDisabled),
            const SizedBox(width: AppSpacing.space2),
          ],
          Text(
            label,
            style: (isCompact ? AppTypography.captionXs : AppTypography.bodySm)
                .copyWith(color: AppColors.textDisabled),
          ),
          const Spacer(),
          Text(
            value,
            style: (isCompact ? AppTypography.captionXs : AppTypography.bodySm)
                .copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
