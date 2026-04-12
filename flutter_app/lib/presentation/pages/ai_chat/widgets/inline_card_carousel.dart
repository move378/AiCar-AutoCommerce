import 'dart:math';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_elevation.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/consultation_card.dart';
import 'package:aicar/domain/entities/consultation_question.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/presentation/pages/ai_card/card_back_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 채팅 내 인라인 카드 캐러셀
///
/// AI 추천 응답 아래에 수평 스크롤 카드 리스트를 표시한다.
class InlineCardCarousel extends ConsumerStatefulWidget {
  const InlineCardCarousel({
    super.key,
    required this.query,
    this.answers,
  });

  final String query;
  final ConsultationAnswers? answers;

  @override
  ConsumerState<InlineCardCarousel> createState() =>
      _InlineCardCarouselState();
}

class _InlineCardCarouselState extends ConsumerState<InlineCardCarousel> {
  List<Vehicle>? _cards;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final repo = ref.read(vehicleRepositoryProvider);
    List<Vehicle> cards;
    if (widget.answers != null) {
      final all = await repo.getAllVehicles(size: 100);
      cards = all.where((v) {
        return widget.answers!.matchesVehicle(
          vehicleBrand: v.brand,
          vehiclePrice: v.price,
          vehicleModel: v.model,
          vehicleFuelType: v.fuelType,
        );
      }).toList();
      if (cards.isEmpty) {
        cards = all.take(5).toList();
      }
    } else {
      cards = await repo.searchVehicles(widget.query);
    }
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

  Future<void> _saveToGarage(Vehicle card) async {
    final garageRepo = ref.read(garageRepositoryProvider);
    final consultationCard = ConsultationCard(
      id: 'card-${card.id}-${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: card.id,
      recommendReason: '키워드 매칭 추천',
      matchScore: 0.8,
      createdAt: DateTime.now(),
    );
    await garageRepo.saveToGarage(consultationCard);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${card.displayName} 가상차고에 저장')),
      );
    }
  }
}

/// 컴팩트 카드 (인라인용, ~200×180px) + flip 애니메이션
class _CompactCard extends StatefulWidget {
  const _CompactCard({
    required this.card,
    required this.onSave,
  });

  final Vehicle card;
  final VoidCallback onSave;

  @override
  State<_CompactCard> createState() => _CompactCardState();
}

class _CompactCardState extends State<_CompactCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFlip,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final isFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
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
          Container(
            height: 70,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF475569),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: widget.card.imageUrl != null && widget.card.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      widget.card.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.directions_car_rounded, size: 32, color: AppColors.textDisabled),
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(Icons.directions_car_rounded, size: 32, color: AppColors.textDisabled),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.card.brand,
                    style: AppTypography.captionXs.copyWith(
                      color: AppColors.textDisabled,
                    ),
                  ),
                  Text(
                    widget.card.displayName,
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
                        widget.card.formattedPrice,
                        style: AppTypography.captionXs.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onSave,
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

  Widget _buildBack() {
    return CardBackWidget(
      card: widget.card,
      isCompact: true,
    );
  }
}
