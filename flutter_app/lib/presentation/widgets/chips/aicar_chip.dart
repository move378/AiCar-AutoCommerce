import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// AiCar 디자인 시스템 Chip
///
/// Figma: Chip (Selected/Default, Size S)
/// node-id: 2451-1172 ~
/// Pill shape (100px radius), 토글 가능한 선택 상태
class AiCarChip extends StatelessWidget {
  const AiCarChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  /// 선택적 leading 아이콘
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isSelected ? AppColors.chipSelected : AppColors.chipUnselected;
    final textColor =
        isSelected ? AppColors.textOnDark : AppColors.chipSelected;
    final iconColor = textColor;
    final border = isSelected
        ? null
        : Border.all(color: AppColors.textTertiary);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: AppShape.chipPadding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppShape.radiusFull,
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: AppSpacing.space1),
            ],
            Text(
              label,
              style: AppTypography.bodySm.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
