import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/pages/garage/providers/garage_provider.dart';
import 'package:aicar/presentation/pages/garage/widgets/consultation_card_carousel.dart';
import 'package:aicar/presentation/pages/garage/widgets/dealership_card.dart';
import 'package:aicar/presentation/widgets/chips/aicar_chip.dart';

/// 가상 차고 탭 — ConsultationCard 캐러셀 + 전시장 목업
class VirtualGarageTab extends ConsumerStatefulWidget {
  const VirtualGarageTab({super.key});

  @override
  ConsumerState<VirtualGarageTab> createState() => _VirtualGarageTabState();
}

class _VirtualGarageTabState extends ConsumerState<VirtualGarageTab> {
  String _dealershipFilter = '내 주변 전시장';
  final Set<String> _savedDealerships = {};

  @override
  void initState() {
    super.initState();
    // 탭 진입 시 가상차고 데이터 새로고침
    Future(() {
      ref.read(garageProvider.notifier).refresh();
    });
  }

  static const _mockDealerships = [
    Dealership(
      brand: 'BMW',
      name: '한남 전시장',
      address: '서울특별시 용산구 한남대로 142',
      hours: '09:00 - 20:00',
      distance: '1.2 km',
    ),
    Dealership(
      brand: '메르세데스 벤츠',
      name: '한남 전시장 / 서비스센터',
      address: '서울특별시 용산구 한남대로 142',
      hours: '09:00 - 18:00',
      distance: '1.2 km',
    ),
    Dealership(
      brand: '아우디',
      name: '도산대로 전시장',
      address: '서울특별시 강남구 도산대로 218',
      hours: '09:00 - 19:00',
      distance: '2.8 km',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final garageState = ref.watch(garageProvider);

    if (garageState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space4),
          // ── ConsultationCard 캐러셀 ──
          if (garageState.cards.isEmpty)
            _buildEmptyGarage()
          else
            ConsultationCardCarousel(cards: garageState.cards),
          const SizedBox(height: AppSpacing.space6),
          // ── 전시장 섹션 ──
          _buildDealershipSection(),
          const SizedBox(height: AppSpacing.space8),
        ],
      ),
    );
  }

  Widget _buildEmptyGarage() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space8,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.garage_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              '저장된 상담 카드가 없습니다',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              'AI 상담에서 추천받은 차량을\n가상차고에 저장해 보세요',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealershipSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 칩 토글
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
          child: Row(
            children: [
              AiCarChip(
                label: '내 주변 전시장',
                isSelected: _dealershipFilter == '내 주변 전시장',
                onTap: () =>
                    setState(() => _dealershipFilter = '내 주변 전시장'),
              ),
              const SizedBox(width: AppSpacing.space2),
              AiCarChip(
                label: '저장한 전시장',
                isSelected: _dealershipFilter == '저장한 전시장',
                onTap: () =>
                    setState(() => _dealershipFilter = '저장한 전시장'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.space3),
        // 전시장 목록
        ..._buildDealershipList(),
      ],
    );
  }

  List<Widget> _buildDealershipList() {
    final List<Dealership> dealerships;

    if (_dealershipFilter == '저장한 전시장') {
      dealerships = _mockDealerships
          .where((d) => _savedDealerships.contains(d.name))
          .toList();
    } else {
      dealerships = _mockDealerships;
    }

    if (dealerships.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space8,
          ),
          child: Center(
            child: Text(
              _dealershipFilter == '저장한 전시장'
                  ? '저장한 전시장이 없습니다'
                  : '주변 전시장이 없습니다',
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ];
    }

    return List.generate(dealerships.length, (index) {
      final dealership = dealerships[index];
      final isSaved = _savedDealerships.contains(dealership.name);
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.space4,
          index == 0 ? 0 : AppSpacing.space3,
          AppSpacing.space4,
          0,
        ),
        child: DealershipCard(
          dealership: dealership,
          isSaved: isSaved,
          onSave: () => _toggleSaveDealership(dealership),
        ),
      );
    });
  }

  void _toggleSaveDealership(Dealership dealership) {
    setState(() {
      if (_savedDealerships.contains(dealership.name)) {
        _savedDealerships.remove(dealership.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dealership.name} 저장 해제')),
        );
      } else {
        _savedDealerships.add(dealership.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${dealership.name} 저장 완료')),
        );
      }
    });
  }
}
