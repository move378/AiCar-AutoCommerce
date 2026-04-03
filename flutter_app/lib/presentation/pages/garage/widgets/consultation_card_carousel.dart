import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/consultation_card.dart';
import 'package:aicar/domain/entities/vehicle.dart';

/// ConsultationCard 가로 캐러셀 (다크 카드)
///
/// Figma: 가상차고 탭 상단 — 저장된 상담 카드 PageView + dot indicator
class ConsultationCardCarousel extends ConsumerStatefulWidget {
  const ConsultationCardCarousel({
    super.key,
    required this.cards,
  });

  final List<ConsultationCard> cards;

  @override
  ConsumerState<ConsultationCardCarousel> createState() =>
      _ConsultationCardCarouselState();
}

class _ConsultationCardCarouselState
    extends ConsumerState<ConsultationCardCarousel> {
  int _currentPage = 0;
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.cards.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
                child: _ConsultationCardItem(card: widget.cards[index]),
              );
            },
          ),
        ),
        if (widget.cards.length > 1) ...[
          const SizedBox(height: AppSpacing.space3),
          _buildDotIndicator(),
        ],
      ],
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.cards.length, (index) {
        final isActive = index == _currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.textOnDark : AppColors.textDisabled,
          ),
        );
      }),
    );
  }
}

/// 개별 ConsultationCard 아이템 (다크 배경)
class _ConsultationCardItem extends ConsumerWidget {
  const _ConsultationCardItem({required this.card});

  final ConsultationCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Vehicle?>(
      future: ref.read(vehicleRepositoryProvider).getVehicleById(card.vehicleId),
      builder: (context, snapshot) {
        final vehicle = snapshot.data;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppShape.radiusMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 차량 이미지 ──
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 80,
                      color: AppColors.textDisabled,
                    ),
                  ),
                ),
              ),
              // ── 차량 정보 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space3,
                  AppSpacing.space4,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle != null
                          ? '${vehicle.brand} ${vehicle.model}'
                          : '차량 정보 로딩...',
                      style: AppTypography.headingXl.copyWith(
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Text(
                      vehicle != null
                          ? '${vehicle.fuelType} · ${vehicle.year}년'
                          : '',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              // ── 가격 정보 3칸 ──
              Padding(
                padding: const EdgeInsets.all(AppSpacing.space4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.space3,
                    horizontal: AppSpacing.space2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: AppShape.radiusMd,
                  ),
                  child: Row(
                    children: [
                      _buildPriceColumn(
                        '차량 가격',
                        vehicle?.formattedPrice ?? '-',
                      ),
                      _buildDivider(),
                      _buildPriceColumn('월 납부금', '69만원'),
                      _buildDivider(),
                      _buildPriceColumn('총비용 계산', '5,364만원'),
                    ],
                  ),
                ),
              ),
              // ── 에이카 상담 기록 링크 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  0,
                  AppSpacing.space4,
                  AppSpacing.space4,
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        '에이카 상담 기록',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.textDisabled,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.space1),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AppColors.textDisabled,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceColumn(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textDisabled,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            value,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.textDisabled.withValues(alpha: 0.3),
    );
  }
}
