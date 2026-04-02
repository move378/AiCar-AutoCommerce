import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/presentation/pages/home/providers/bookmark_provider.dart';

/// 차량 상세 페이지
///
/// 홈 탭에서 차량 카드 탭 시 진입.
/// 차량 스펙 + 가격 + 북마크 토글.
class VehicleDetailPage extends ConsumerWidget {
  const VehicleDetailPage({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarkState = ref.watch(bookmarkProvider);
    final isBookmarked = bookmarkState.bookmarkedIds.contains(vehicleId);

    return FutureBuilder<Vehicle?>(
      future: ref.read(vehicleRepositoryProvider).getVehicleById(vehicleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
          );
        }

        final vehicle = snapshot.data;
        if (vehicle == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('차량 상세'),
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
            ),
            body: Center(
              child: Text(
                '차량 정보를 찾을 수 없습니다',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('차량 상세'),
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 이미지 영역 ──
                _buildImageSection(vehicle),
                // ── 차량 정보 ──
                _buildInfoSection(vehicle),
                // ── 스펙 카드 ──
                _buildSpecsGrid(vehicle),
                const SizedBox(height: AppSpacing.space8),
              ],
            ),
          ),
          // ── 하단 고정: 북마크 + 상담하기 ──
          bottomNavigationBar: _buildBottomBar(
            context,
            ref,
            vehicle,
            isBookmarked,
          ),
        );
      },
    );
  }

  Widget _buildImageSection(Vehicle vehicle) {
    return Container(
      width: double.infinity,
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShape.radiusMd,
      ),
      child: vehicle.imageUrl != null
          ? ClipRRect(
              borderRadius: AppShape.radiusMd,
              child: Image.network(
                vehicle.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              ),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '차량 이미지',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Vehicle vehicle) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehicle.brand,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            vehicle.model,
            style: AppTypography.headingXl.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.space1),
          Text(
            '${vehicle.year}년 · ${vehicle.fuelType}',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            vehicle.formattedPrice,
            style: AppTypography.heading2xl.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(Vehicle vehicle) {
    final specs = vehicle.specs;
    final items = [
      _SpecItem(icon: Icons.speed, label: '마력', value: '${specs.power}hp'),
      _SpecItem(
          icon: Icons.rotate_right, label: '토크', value: '${specs.torque}kgm'),
      _SpecItem(
          icon: Icons.local_gas_station,
          label: '연비',
          value: '${specs.fuelEfficiency}km/L'),
      _SpecItem(
          icon: Icons.timer,
          label: '제로백',
          value: '${specs.zeroToHundred}초'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.space3,
        crossAxisSpacing: AppSpacing.space3,
        childAspectRatio: 2.2,
        children: items.map((item) => _buildSpecCard(item)).toList(),
      ),
    );
  }

  Widget _buildSpecCard(_SpecItem item) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShape.radiusMd,
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 24, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.space2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.label,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                item.value,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
    bool isBookmarked,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space3,
        AppSpacing.space4,
        AppSpacing.space6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.textDisabled.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // 북마크 버튼
          GestureDetector(
            onTap: () =>
                ref.read(bookmarkProvider.notifier).toggleBookmark(vehicleId),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textDisabled),
                borderRadius: AppShape.radiusMd,
              ),
              child: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked
                    ? AppColors.secondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          // AI 상담하기 버튼
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppShape.radiusMd,
                ),
                child: Center(
                  child: Text(
                    'AI 상담하기',
                    style: AppTypography.bodyMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecItem {
  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}
