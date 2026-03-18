import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class QuickActionBar extends StatelessWidget {
  final ValueChanged<String> onTap;

  const QuickActionBar({
    super.key,
    required this.onTap,
  });

  static const List<String> _actions = [
    '5000만원 이하 SUV 추천해줘',
    '유지비 적게 드는 차 뭐야?',
    '가족들과 나들이 갈 SUV',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _ActionChip(
            label: _actions[index],
            onTap: () => onTap(_actions[index]),
          );
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.quickAction,
          border: Border.all(color: AppColors.quickActionBorder),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
