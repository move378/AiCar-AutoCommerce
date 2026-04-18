import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/presentation/pages/home/providers/bookmark_provider.dart';
import 'package:aicar/presentation/pages/home/providers/home_provider.dart';
import 'package:aicar/presentation/widgets/cards/vehicle_card.dart'
    as card_widget;
import 'package:aicar/presentation/widgets/chips/aicar_chip.dart';

/// 홈 탭 — 차량 탐색 (MVP: 네이티브 목록, Post-MVP: SvelteKit WebView)
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _categories = ['전체', 'SUV', '세단'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: state.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.secondary),
                )
              : CustomScrollView(
                  slivers: [
                    // ── 헤더 ──
                    SliverToBoxAdapter(child: _buildHeader()),
                    // ── 검색바 ──
                    SliverToBoxAdapter(child: _buildSearchBar(context)),
                    // ── 추천 차량 캐러셀 ──
                    SliverToBoxAdapter(
                      child: _buildFeaturedSection(context, ref, state),
                    ),
                    // ── 카테고리 칩 ──
                    SliverToBoxAdapter(
                      child: _buildCategoryChips(ref, state),
                    ),
                    // ── 전체 차량 리스트 ──
                    _buildVehicleList(context, ref, state),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: AppSpacing.space8),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space4,
        AppSpacing.space4,
        AppSpacing.space2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AiCar',
            style: AppTypography.heading2xl.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          // TODO: 알림 기능 구현 후 복원
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(
          //     Icons.notifications_outlined,
          //     color: AppColors.textSecondary,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: GestureDetector(
        onTap: () => context.go('/chat'),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space3,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppShape.radiusMd,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: AppColors.textTertiary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.space2),
              Text(
                'AI에게 차량 추천받기',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(
      BuildContext context, WidgetRef ref, HomeState state) {
    final featured = state.featuredVehicles;
    if (featured.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space4,
            AppSpacing.space5,
            AppSpacing.space4,
            AppSpacing.space3,
          ),
          child: Text(
            '추천 차량',
            style: AppTypography.headingXl.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            itemCount: featured.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.space3),
            itemBuilder: (context, index) {
              final vehicle = featured[index];
              final isBookmarked = ref
                  .watch(bookmarkProvider)
                  .bookmarkedIds
                  .contains(vehicle.id);
              return card_widget.VehicleCard(
                variant: card_widget.VehicleCardVariant.card,
                name: '${vehicle.brand} ${vehicle.displayName}',
                price: vehicle.formattedPrice,
                imageUrl: vehicle.imageUrl,
                subtitle: '${vehicle.year} · ${vehicle.fuelType}',
                isBookmarked: isBookmarked,
                onBookmarkTap: () => ref
                    .read(bookmarkProvider.notifier)
                    .toggleBookmark(vehicle.id),
                onTap: () => _navigateToVehicle(context, vehicle),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(WidgetRef ref, HomeState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space5,
        AppSpacing.space4,
        AppSpacing.space3,
      ),
      child: Row(
        children: [
          Text(
            '전체 차량',
            style: AppTypography.headingXl.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.space3),
          ..._categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space2),
              child: AiCarChip(
                label: category,
                isSelected: state.selectedCategory == category,
                onTap: () =>
                    ref.read(homeProvider.notifier).selectCategory(category),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVehicleList(
    BuildContext context,
    WidgetRef ref,
    HomeState state,
  ) {
    final vehicles = state.filteredVehicles;

    if (vehicles.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.all(AppSpacing.space8),
            child: Center(
              child: Text(
                '해당 카테고리의 차량이 없습니다',
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ]),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      sliver: SliverList.separated(
        itemCount: vehicles.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          final isBookmarked = ref
              .watch(bookmarkProvider)
              .bookmarkedIds
              .contains(vehicle.id);
          return card_widget.VehicleCard(
            variant: card_widget.VehicleCardVariant.list,
            name: '${vehicle.brand} ${vehicle.displayName}',
            price: vehicle.formattedPrice,
            imageUrl: vehicle.imageUrl,
            subtitle: '${vehicle.year} · ${vehicle.fuelType}',
            isBookmarked: isBookmarked,
            onBookmarkTap: () => ref
                .read(bookmarkProvider.notifier)
                .toggleBookmark(vehicle.id),
            onTap: () => _navigateToVehicle(context, vehicle),
          );
        },
      ),
    );
  }

  void _navigateToVehicle(BuildContext context, Vehicle vehicle) {
    context.go('/home/vehicle/${vehicle.id}');
  }
}
