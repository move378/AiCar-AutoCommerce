import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/presentation/pages/garage/providers/recently_viewed_provider.dart';
import 'package:aicar/presentation/pages/home/providers/bookmark_provider.dart';
import 'package:aicar/presentation/widgets/chips/aicar_chip.dart';

/// 최근 본 탭 — 카테고리 칩 + 수직 리스트
class RecentlyViewedTab extends ConsumerStatefulWidget {
  const RecentlyViewedTab({super.key});

  @override
  ConsumerState<RecentlyViewedTab> createState() => _RecentlyViewedTabState();
}

class _RecentlyViewedTabState extends ConsumerState<RecentlyViewedTab> {
  String _category = '전체';
  List<Vehicle>? _vehicles;
  bool _isLoading = true;

  static const _categories = ['전체', '일반', '전기차'];

  @override
  void initState() {
    super.initState();
    _loadRecentlyViewed();
  }

  Future<void> _loadRecentlyViewed() async {
    final recentState = ref.read(recentlyViewedProvider);
    final vehicleRepo = ref.read(vehicleRepositoryProvider);

    final vehicles = <Vehicle>[];
    for (final id in recentState.vehicleIds) {
      final vehicle = await vehicleRepo.getVehicleById(id);
      if (vehicle != null) vehicles.add(vehicle);
    }

    if (mounted) {
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
    }
  }

  List<Vehicle> get _filteredVehicles {
    if (_vehicles == null) return [];
    if (_category == '전체') return _vehicles!;
    if (_category == '전기차') {
      return _vehicles!
          .where((v) =>
              v.fuelType.contains('전기') || v.fuelType.contains('EV'))
          .toList();
    }
    return _vehicles!
        .where((v) =>
            !v.fuelType.contains('전기') && !v.fuelType.contains('EV'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // 최근 본 변경 시 리빌드
    ref.listen(recentlyViewedProvider, (_, __) => _loadRecentlyViewed());

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      );
    }

    return Column(
      children: [
        // ── 카테고리 칩 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            AppSpacing.space3,
            AppSpacing.space4,
            AppSpacing.space3,
          ),
          child: Row(
            children: _categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.space2),
                child: AiCarChip(
                  label: category,
                  isSelected: _category == category,
                  onTap: () => setState(() => _category = category),
                ),
              );
            }).toList(),
          ),
        ),
        // ── 리스트 ──
        Expanded(
          child: _filteredVehicles.isEmpty
              ? _buildEmpty()
              : _buildList(),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.space3),
          Text(
            '최근 본 차량이 없습니다',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      itemCount: _filteredVehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        final isBookmarked = ref
            .watch(bookmarkProvider)
            .bookmarkedIds
            .contains(vehicle.id);

        return _RecentlyViewedCard(
          vehicle: vehicle,
          isBookmarked: isBookmarked,
          onTap: () => context.go('/home/vehicle/${vehicle.id}'),
          onToggleBookmark: () =>
              ref.read(bookmarkProvider.notifier).toggleBookmark(vehicle.id),
        );
      },
    );
  }
}

/// 최근 본 차량 카드 (수직 리스트용, 좌 이미지 + 우 정보)
class _RecentlyViewedCard extends StatelessWidget {
  const _RecentlyViewedCard({
    required this.vehicle,
    required this.isBookmarked,
    required this.onTap,
    required this.onToggleBookmark,
  });

  final Vehicle vehicle;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppShape.radiusMd,
          border: Border.all(color: AppColors.surface),
        ),
        child: Row(
          children: [
            // ── 좌측 이미지 ──
            Container(
              width: 140,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
              child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                      child: Image.network(
                        vehicle.imageUrl!,
                        fit: BoxFit.cover,
                        width: 140,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.directions_car_outlined, size: 48, color: AppColors.textTertiary),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(Icons.directions_car_outlined, size: 48, color: AppColors.textTertiary),
                    ),
            ),
            // ── 우측 정보 ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${vehicle.brand} ${vehicle.displayName}',
                            style: AppTypography.bodyMd.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onToggleBookmark,
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? AppColors.secondary
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.fuelType} · ${vehicle.year}년',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      vehicle.formattedPrice,
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '월 --만원',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
