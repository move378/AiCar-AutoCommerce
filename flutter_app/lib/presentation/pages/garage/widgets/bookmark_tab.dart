import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/presentation/pages/home/providers/bookmark_provider.dart';
import 'package:aicar/presentation/widgets/chips/aicar_chip.dart';

/// 북마크 탭 — 카테고리 칩 + 2열 그리드
class BookmarkTab extends ConsumerStatefulWidget {
  const BookmarkTab({super.key});

  @override
  ConsumerState<BookmarkTab> createState() => _BookmarkTabState();
}

class _BookmarkTabState extends ConsumerState<BookmarkTab> {
  String _category = '전체';
  List<Vehicle>? _vehicles;
  bool _isLoading = true;

  static const _categories = ['전체', '일반', '전기차'];

  @override
  void initState() {
    super.initState();
    Future(_loadBookmarkedVehicles);
  }

  Future<void> _loadBookmarkedVehicles() async {
    final bookmarkState = ref.read(bookmarkProvider);
    if (bookmarkState.isLoading) {
      // 아직 로딩 중이면 잠시 후 재시도
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) return _loadBookmarkedVehicles();
      return;
    }
    final vehicleRepo = ref.read(vehicleRepositoryProvider);

    final vehicles = <Vehicle>[];
    for (final id in bookmarkState.bookmarkedIds) {
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
    // 일반: 전기차가 아닌 나머지
    return _vehicles!
        .where((v) =>
            !v.fuelType.contains('전기') && !v.fuelType.contains('EV'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // 북마크 변경 시 리빌드
    ref.listen(bookmarkProvider, (_, __) => _loadBookmarkedVehicles());

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
        // ── 그리드 ──
        Expanded(
          child: _filteredVehicles.isEmpty
              ? _buildEmpty()
              : _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.space3),
          Text(
            '북마크한 차량이 없습니다',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.space3,
        crossAxisSpacing: AppSpacing.space3,
        childAspectRatio: 0.65,
      ),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return _BookmarkVehicleCard(
          vehicle: vehicle,
          onTap: () => context.go('/home/vehicle/${vehicle.id}'),
          onToggleBookmark: () =>
              ref.read(bookmarkProvider.notifier).toggleBookmark(vehicle.id),
        );
      },
    );
  }
}

/// 북마크 차량 카드 (2열 그리드용)
class _BookmarkVehicleCard extends StatelessWidget {
  const _BookmarkVehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.onToggleBookmark,
  });

  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppShape.radiusMd,
          border: Border.all(color: AppColors.surface),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 이미지 + 북마크 ──
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            vehicle.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 110,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.directions_car_outlined, size: 48, color: AppColors.textTertiary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.directions_car_outlined, size: 48, color: AppColors.textTertiary,
                        ),
                ),
                Positioned(
                  top: AppSpacing.space2,
                  right: AppSpacing.space2,
                  child: GestureDetector(
                    onTap: onToggleBookmark,
                    child: Icon(
                      Icons.bookmark,
                      color: AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            // ── 정보 ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehicle.brand} ${vehicle.model}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
