import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_elevation.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/router/route_names.dart';

/// 브랜드 전시장 데이터
class _BrandShowroom {
  const _BrandShowroom({
    required this.name,
    required this.icon,
    required this.url,
  });

  final String name;
  final IconData icon;
  final String url;
}

const _brands = [
  _BrandShowroom(
    name: 'BMW',
    icon: Icons.directions_car,
    url: 'https://www.bmw.co.kr/ko/fastlane/dealer-locator/showroom.html',
  ),
  _BrandShowroom(
    name: 'Mercedes-Benz',
    icon: Icons.directions_car,
    url:
        'https://www.mercedes-benz.co.kr/passengercars/mercedes-benz-cars/dealer-locator.html',
  ),
  _BrandShowroom(
    name: 'Genesis',
    icon: Icons.directions_car,
    url: 'https://www.genesis.com/kr/ko/experience/find-a-showroom.html',
  ),
  _BrandShowroom(
    name: 'Tesla',
    icon: Icons.electric_car,
    url: 'https://www.tesla.com/ko_KR/findus/list/stores/South+Korea',
  ),
  _BrandShowroom(
    name: 'Audi',
    icon: Icons.directions_car,
    url: 'https://www.audi.co.kr/kr/web/ko/dealer-search.html',
  ),
  _BrandShowroom(
    name: 'Lexus',
    icon: Icons.directions_car,
    url: 'https://www.lexus.co.kr/find-a-dealer',
  ),
  _BrandShowroom(
    name: 'Volvo',
    icon: Icons.directions_car,
    url: 'https://www.volvocars.com/kr/dealers/',
  ),
];

/// 시승찾기 탭 — 외부 브랜드 전시장
class TestDrivePage extends StatelessWidget {
  const TestDrivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── 헤더 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space4,
                  AppSpacing.space2,
                ),
                child: Text(
                  '시승찾기',
                  style: AppTypography.heading2xl.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            // ── 안내 텍스트 ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space4,
                ),
                child: Text(
                  '관심 브랜드의 전시장을 방문해보세요',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space5),
            ),
            // ── 브랜드 그리드 ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
              ),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.space3,
                crossAxisSpacing: AppSpacing.space3,
                childAspectRatio: 1.1,
                children: _brands.map((brand) {
                  return _BrandCard(
                    brand: brand,
                    onTap: () => context.pushNamed(
                      RouteNames.testDriveWebview,
                      extra: {'name': brand.name, 'url': brand.url},
                    ),
                  );
                }).toList(),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.space8),
            ),
          ],
        ),
      ),
    );
  }
}

/// 브랜드 카드 위젯
class _BrandCard extends StatelessWidget {
  const _BrandCard({
    required this.brand,
    required this.onTap,
  });

  final _BrandShowroom brand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppShape.radiusMd,
          boxShadow: AppElevation.elevation1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppShape.radiusCircle,
              ),
              child: Icon(
                brand.icon,
                size: 28,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            Text(
              brand.name,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.space1),
            Text(
              '전시장 방문',
              style: AppTypography.captionXs.copyWith(
                color: AppColors.textAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
