import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/pages/ai_card/card_front_widget.dart';
import 'package:aicar/presentation/pages/ai_card/providers/card_provider.dart';
import 'package:aicar/presentation/widgets/chips/aicar_chip.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 카드 커스터마이즈 페이지 (MVP: UI만, 실제 데이터 변경 없음)
class CardCustomizePage extends ConsumerStatefulWidget {
  const CardCustomizePage({super.key});

  @override
  ConsumerState<CardCustomizePage> createState() => _CardCustomizePageState();
}

class _CardCustomizePageState extends ConsumerState<CardCustomizePage> {
  int _selectedColorIndex = 0;
  int _selectedTrimIndex = 0;

  static const _colors = [
    ('화이트', Color(0xFFFFFFFF)),
    ('블랙', Color(0xFF1E293B)),
    ('실버', Color(0xFFCBD5E1)),
    ('블루', Color(0xFF3B82F6)),
    ('레드', Color(0xFFEF4444)),
    ('그레이', Color(0xFF64748B)),
  ];

  static const _trims = ['기본', '프리미엄', 'M스포츠'];

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(cardProvider);
    final currentCard = cardState.cards.isNotEmpty
        ? cardState.cards[cardState.currentIndex]
        : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AiCarHeader(
            title: '커스터마이즈',
            showBack: true,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: currentCard == null
                ? const Center(child: Text('카드를 선택해주세요'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.space4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 카드 미리보기
                        Center(child: CardFrontWidget(card: currentCard)),
                        const SizedBox(height: AppSpacing.space8),

                        // 색상 선택
                        Text(
                          '외장 색상',
                          style: AppTypography.headingXl.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Wrap(
                          spacing: AppSpacing.space3,
                          runSpacing: AppSpacing.space3,
                          children: List.generate(_colors.length, (index) {
                            final (name, color) = _colors[index];
                            final isSelected = _selectedColorIndex == index;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColorIndex = index),
                              child: Column(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.secondary
                                            : AppColors.textDisabled,
                                        width: isSelected ? 3 : 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.space1),
                                  Text(
                                    name,
                                    style: AppTypography.captionXs.copyWith(
                                      color: isSelected
                                          ? AppColors.textPrimary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.space8),

                        // 트림 선택
                        Text(
                          '트림',
                          style: AppTypography.headingXl.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Row(
                          children: List.generate(_trims.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  right: AppSpacing.space2),
                              child: AiCarChip(
                                label: _trims[index],
                                isSelected: _selectedTrimIndex == index,
                                onTap: () => setState(
                                    () => _selectedTrimIndex = index),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: AppSpacing.space4),

                        // MVP 안내
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.space3),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: AppSpacing.space2),
                              Expanded(
                                child: Text(
                                  '커스터마이즈 기능은 준비 중입니다. 곧 실제 옵션 선택이 가능해져요!',
                                  style: AppTypography.captionXs.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
