import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// GNB 탭 아이템 정의
class _TabItem {
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// AiCar GNB (하단 탭바)
///
/// Figma: Tab Bar (홈/시승/챗봇/차고/마이)
/// node-ids: 2598-1904 ~ 2598-2008
/// 375×61px, 5탭, active=slate-900, inactive=slate-400
class AiCarTabBar extends StatelessWidget {
  const AiCarTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_TabItem> _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: '홈'),
    _TabItem(icon: Icons.directions_car_outlined, activeIcon: Icons.directions_car, label: '시승'),
    _TabItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: '챗봇'),
    _TabItem(icon: Icons.garage_outlined, activeIcon: Icons.garage, label: '차고'),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person, label: '마이'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 61,
      decoration: const BoxDecoration(
        color: AppColors.gnbBackground,
        border: Border(
          top: BorderSide(
            color: AppColors.textDisabled,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isActive = index == currentIndex;
            final color = isActive ? AppColors.gnbActive : AppColors.gnbInactive;

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? tab.activeIcon : tab.icon,
                      size: 24,
                      color: color,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab.label,
                      style: AppTypography.captionXs.copyWith(
                        color: color,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
