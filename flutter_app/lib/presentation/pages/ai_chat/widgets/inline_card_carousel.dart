import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_elevation.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle_card.dart';
import 'package:aicar/presentation/pages/ai_card/providers/card_provider.dart';

/// 채팅 내 인라인 카드 캐러셀
///
/// AI 추천 응답 아래에 수평 스크롤 카드 리스트를 표시한다.
class InlineCardCarousel extends ConsumerStatefulWidget {
  const InlineCardCarousel({super.key, required this.query});

  final String query;

  @override
  ConsumerState<InlineCardCarousel> createState() =>
      _InlineCardCarouselState();
}

class _InlineCardCarouselState extends ConsumerState<InlineCardCarousel> {
  List<VehicleCard>? _cards;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final repo = ref.read(cardRepositoryProvider);
    final cards = await repo.getRecommendations(widget.query);
    if (mounted) {
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.space2),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_cards == null || _cards!.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.space4,
        bottom: AppSpacing.space3,
      ),
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: AppSpacing.space4),
          itemCount: _cards!.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppSpacing.space3),
          itemBuilder: (context, index) {
            return _CompactCard(
              card: _cards![index],
              onSave: () => _saveToGarage(_cards![index]),
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveToGarage(VehicleCard card) async {
    final repo = ref.read(cardRepositoryProvider);
    await repo.saveToGarage(card);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.modelName} 가상차고에 저장')),
      );
    }
  }
}

/// 컴팩트 카드 (인라인용, ~200×170px)
class _CompactCard extends StatelessWidget {
  const _CompactCard({
    required this.card,
    required this.onSave,
  });

  final VehicleCard card;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: AppElevation.elevation1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 placeholder
          Container(
            height: 70,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF475569),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_rounded,
                size: 32,
                color: AppColors.textDisabled,
              ),
            ),
          ),

          // 차량 정보
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.brandName,
                    style: AppTypography.captionXs.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                  Text(
                    card.modelName,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        card.formattedPrice,
                        style: AppTypography.captionXs.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: onSave,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.space2,
                            vertical: AppSpacing.space1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '저장',
                            style: AppTypography.captionXs.copyWith(
                              color: AppColors.textOnDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
