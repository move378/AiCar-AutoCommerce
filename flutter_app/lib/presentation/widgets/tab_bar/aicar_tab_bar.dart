import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// GNB 탭 아이템 정의
class _TabItem {
  const _TabItem({
    required this.iconPath,
    required this.activeIconPath,
    required this.label,
  });

  final String iconPath;
  final String activeIconPath;
  final String label;
}

/// AiCar GNB (하단 탭바)
///
/// Figma: Tab Bar (홈/시승찾기/챗봇/차고/마이)
/// node-id: 2598-1903
/// Pill shape 컨테이너, 활성 탭에 원형 배경
class AiCarTabBar extends StatelessWidget {
  const AiCarTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_TabItem> _tabs = [
    _TabItem(
      iconPath: 'assets/icons/gnb/home.svg',
      activeIconPath: 'assets/icons/gnb/home_active.svg',
      label: '홈',
    ),
    _TabItem(
      iconPath: 'assets/icons/gnb/test_drive.svg',
      activeIconPath: 'assets/icons/gnb/test_drive_active.svg',
      label: '시승찾기',
    ),
    _TabItem(
      iconPath: 'assets/icons/gnb/chatbot.svg',
      activeIconPath: 'assets/icons/gnb/chatbot_active.svg',
      label: '챗봇',
    ),
    _TabItem(
      iconPath: 'assets/icons/gnb/garage.svg',
      activeIconPath: 'assets/icons/gnb/garage_active.svg',
      label: '차고',
    ),
    _TabItem(
      iconPath: 'assets/icons/gnb/my.svg',
      activeIconPath: 'assets/icons/gnb/my_active.svg',
      label: '마이',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.gnbBackground,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface, // slate-50 연한 배경
              borderRadius: BorderRadius.all(Radius.circular(32)), // pill shape
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: _buildTabItem(tab, isActive),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(_TabItem tab, bool isActive) {
    final color = isActive ? AppColors.gnbActive : AppColors.gnbInactive;
    final iconSize = isActive ? 28.0 : 24.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 활성 탭: 원형 배경
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 48 : 24,
          height: isActive ? 48 : 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.textDisabled.withValues(alpha: 0.3) // 연한 원형 배경
                : Colors.transparent,
          ),
          child: Center(
            child: SvgPicture.asset(
              isActive ? tab.activeIconPath : tab.iconPath,
              width: iconSize,
              height: iconSize,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          tab.label,
          style: AppTypography.captionXs.copyWith(
            color: color,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            fontSize: 10,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
