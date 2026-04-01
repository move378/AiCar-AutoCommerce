import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// AiCar 콘텐츠 탭 (페이지 내 수평 탭 전환)
///
/// Figma: Tabs (size=sm, isFitted=false)
/// node-id: 2451-1136
/// 수평 스크롤, 선택된 탭에 하단 인디케이터
class AiCarTabs extends StatelessWidget {
  const AiCarTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppShape.tabBarPadding,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.only(
                right: index < tabs.length - 1 ? AppSpacing.space5 : 0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tabs[index],
                    style: AppTypography.bodySm.copyWith(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: _calculateTextWidth(tabs[index], isSelected),
                    color: isSelected
                        ? AppColors.primary
                        : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 텍스트 너비 계산 (인디케이터 길이 매칭)
  double _calculateTextWidth(String text, bool isSelected) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: AppTypography.bodySm.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
