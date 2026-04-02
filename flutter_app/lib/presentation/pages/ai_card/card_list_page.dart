import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/pages/ai_card/card_front_widget.dart';
import 'package:aicar/presentation/pages/ai_card/providers/card_provider.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 추천 차량 카드 리스트 페이지
class CardListPage extends ConsumerStatefulWidget {
  const CardListPage({super.key, this.query = ''});

  final String query;

  @override
  ConsumerState<CardListPage> createState() => _CardListPageState();
}

class _CardListPageState extends ConsumerState<CardListPage> {
  final _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(cardProvider.notifier).loadRecommendations(widget.query);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardState = ref.watch(cardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AiCarHeader(
            title: '추천 차량',
            showBack: true,
            onBack: () => Navigator.of(context).pop(),
          ),

          // 카드 리스트
          Expanded(
            child: cardState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cardState.cards.isEmpty
                    ? _buildEmptyState()
                    : _buildCardList(cardState),
          ),

          // 하단 액션 버튼
          if (cardState.cards.isNotEmpty) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.style_rounded,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            '추천 차량이 없습니다',
            style: AppTypography.headingXl.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardList(CardListState cardState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: cardState.cards.length,
            onPageChanged: (index) {
              ref.read(cardProvider.notifier).setCurrentIndex(index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space2,
                ),
                child: Center(
                  child: CardFrontWidget(card: cardState.cards[index]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.space4),

        // 페이지 인디케이터
        SmoothPageIndicator(
          controller: _pageController,
          count: cardState.cards.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            activeDotColor: AppColors.primary,
            dotColor: AppColors.textDisabled,
            spacing: AppSpacing.space2,
          ),
        ),

        const SizedBox(height: AppSpacing.space2),

        // 카드 번호
        Text(
          '${cardState.currentIndex + 1} / ${cardState.cards.length}',
          style: AppTypography.captionXs.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space4),
        child: Row(
          children: [
            Expanded(
              child: AiCarButton(
                label: '견적확인',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('견적 기능은 준비 중입니다')),
                  );
                },
                size: AiCarButtonSize.lg,
                style: AiCarButtonStyle.outline,
              ),
            ),
            const SizedBox(width: AppSpacing.space3),
            Expanded(
              child: AiCarButton(
                label: '가상차고 저장',
                onPressed: () async {
                  await ref.read(cardProvider.notifier).saveToGarage();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('가상차고에 저장되었습니다')),
                    );
                  }
                },
                size: AiCarButtonSize.lg,
                style: AiCarButtonStyle.solid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
