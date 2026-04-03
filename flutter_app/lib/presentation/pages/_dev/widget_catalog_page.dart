// ignore_for_file: avoid_hardcoded_colors
// 임시 Widget Catalog 프리뷰 페이지 — 개발 확인 후 삭제
import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/buttons/bookmark_button.dart';
import 'package:aicar/presentation/widgets/cards/vehicle_card.dart';
import 'package:aicar/presentation/widgets/chips/aicar_chip.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';
import 'package:aicar/presentation/widgets/inputs/aicar_input_field.dart';
import 'package:aicar/presentation/widgets/map/map_pin.dart';
import 'package:aicar/presentation/widgets/tab_bar/aicar_tab_bar.dart';
import 'package:aicar/presentation/widgets/tab_bar/aicar_tabs.dart';

class WidgetCatalogPage extends StatefulWidget {
  const WidgetCatalogPage({super.key});

  @override
  State<WidgetCatalogPage> createState() => _WidgetCatalogPageState();
}

class _WidgetCatalogPageState extends State<WidgetCatalogPage> {
  // ── State for interactive widgets ──────────────
  int _gnbIndex = 0;
  int _tabIndex = 0;
  bool _chipSelected1 = false;
  bool _chipSelected2 = true;
  bool _chipSelected3 = false;
  bool _bookmarked1 = false;
  bool _bookmarked2 = true;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            _buildSectionTitle('AiCarHeader'),
            _buildHeaderSection(),
            _buildSectionTitle('AiCarButton — Solid'),
            _buildButtonSolidSection(),
            _buildSectionTitle('AiCarButton — Outline'),
            _buildButtonOutlineSection(),
            _buildSectionTitle('AiCarInputField'),
            _buildInputFieldSection(),
            _buildSectionTitle('AiCarChip'),
            _buildChipSection(),
            _buildSectionTitle('AiCarTabs'),
            _buildTabsSection(),
            _buildSectionTitle('BookmarkButton'),
            _buildBookmarkSection(),
            _buildSectionTitle('VehicleCard — List'),
            _buildVehicleCardListSection(),
            _buildSectionTitle('VehicleCard — Card'),
            _buildVehicleCardCardSection(),
            _buildSectionTitle('MapPin'),
            _buildMapPinSection(),
          ],
        ),
      ),
      bottomNavigationBar: AiCarTabBar(
        currentIndex: _gnbIndex,
        onTap: (i) => setState(() => _gnbIndex = i),
      ),
    );
  }

  // ── Section Title ─────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space4,
        AppSpacing.space6,
        AppSpacing.space4,
        AppSpacing.space2,
      ),
      child: Text(
        title,
        style: AppTypography.heading2xl.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  // ── Header ────────────────────────────────────
  Widget _buildHeaderSection() {
    return Column(
      children: [
        _buildLabel('기본 (title only)'),
        const AiCarHeader(title: 'Widget Catalog'),
        _buildLabel('뒤로가기 + 액션'),
        AiCarHeader(
          title: '상세 페이지',
          showBack: true,
          onBack: () {},
          actions: [
            Icon(Icons.share_outlined, color: AppColors.textPrimary, size: 22),
            Icon(Icons.more_vert, color: AppColors.textPrimary, size: 22),
          ],
        ),
      ],
    );
  }

  // ── Button Solid ──────────────────────────────
  Widget _buildButtonSolidSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('LG — Enabled'),
          AiCarButton(
            label: 'Button LG Solid',
            onPressed: () {},
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('LG — With Icons'),
          AiCarButton(
            label: 'Send Email',
            onPressed: () {},
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
            leadingIcon: Icons.mail_outline,
            trailingIcon: Icons.arrow_forward,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('LG — Disabled'),
          const AiCarButton(
            label: 'Button LG Disabled',
            onPressed: null,
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('SM — Enabled'),
          AiCarButton(
            label: 'Button SM',
            onPressed: () {},
            size: AiCarButtonSize.sm,
            style: AiCarButtonStyle.solid,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('SM — Disabled'),
          const AiCarButton(
            label: 'Button SM Disabled',
            onPressed: null,
            size: AiCarButtonSize.sm,
            style: AiCarButtonStyle.solid,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('LG — Expanded'),
          AiCarButton(
            label: '전체 너비 버튼',
            onPressed: () {},
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  // ── Button Outline ────────────────────────────
  Widget _buildButtonOutlineSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('LG — Enabled'),
          AiCarButton(
            label: 'Button LG Outline',
            onPressed: () {},
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.outline,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('LG — With Icons'),
          AiCarButton(
            label: 'View Details',
            onPressed: () {},
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.outline,
            leadingIcon: Icons.visibility_outlined,
            trailingIcon: Icons.arrow_forward,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('LG — Disabled'),
          const AiCarButton(
            label: 'Outline Disabled',
            onPressed: null,
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.outline,
          ),
          const SizedBox(height: AppSpacing.space3),
          _buildLabel('SM — Enabled'),
          AiCarButton(
            label: 'SM Outline',
            onPressed: () {},
            size: AiCarButtonSize.sm,
            style: AiCarButtonStyle.outline,
          ),
        ],
      ),
    );
  }

  // ── InputField ────────────────────────────────
  Widget _buildInputFieldSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('기본 (label + hint)'),
          AiCarInputField(
            label: '이메일',
            hint: 'email@example.com',
            controller: _textController,
          ),
          const SizedBox(height: AppSpacing.space4),
          _buildLabel('에러 상태'),
          const AiCarInputField(
            label: '비밀번호',
            hint: '8자 이상 입력',
            errorText: '비밀번호가 너무 짧습니다',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.space4),
          _buildLabel('비활성 상태'),
          const AiCarInputField(
            label: '차량번호',
            hint: '12가 3456',
            enabled: false,
          ),
          const SizedBox(height: AppSpacing.space4),
          _buildLabel('아이콘 포함'),
          AiCarInputField(
            label: '검색',
            hint: '차량명 또는 모델 검색',
            prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textTertiary),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // ── Chip ──────────────────────────────────────
  Widget _buildChipSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Wrap(
        spacing: AppSpacing.space2,
        runSpacing: AppSpacing.space2,
        children: [
          AiCarChip(
            label: 'SUV',
            isSelected: _chipSelected1,
            onTap: () => setState(() => _chipSelected1 = !_chipSelected1),
          ),
          AiCarChip(
            label: '세단',
            isSelected: _chipSelected2,
            onTap: () => setState(() => _chipSelected2 = !_chipSelected2),
          ),
          AiCarChip(
            label: '전기차',
            isSelected: _chipSelected3,
            onTap: () => setState(() => _chipSelected3 = !_chipSelected3),
            icon: Icons.bolt,
          ),
          const AiCarChip(
            label: '하이브리드',
            isSelected: false,
            onTap: null,
          ),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────
  Widget _buildTabsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AiCarTabs(
          tabs: const ['전체', '벤츠', 'BMW', '아우디', '포르쉐', '테슬라'],
          selectedIndex: _tabIndex,
          onTap: (i) => setState(() => _tabIndex = i),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.space4),
          child: Text(
            '선택된 탭: ${['전체', '벤츠', 'BMW', '아우디', '포르쉐', '테슬라'][_tabIndex]}',
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  // ── Bookmark ──────────────────────────────────
  Widget _buildBookmarkSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Wrap(
        spacing: AppSpacing.space6,
        runSpacing: AppSpacing.space3,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabel('미저장'),
              const SizedBox(width: AppSpacing.space1),
              BookmarkButton(
                isBookmarked: _bookmarked1,
                onTap: () => setState(() => _bookmarked1 = !_bookmarked1),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabel('저장됨'),
              const SizedBox(width: AppSpacing.space1),
              BookmarkButton(
                isBookmarked: _bookmarked2,
                onTap: () => setState(() => _bookmarked2 = !_bookmarked2),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabel('큰 사이즈'),
              const SizedBox(width: AppSpacing.space1),
              BookmarkButton(
                isBookmarked: true,
                onTap: () {},
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── VehicleCard List ──────────────────────────
  Widget _buildVehicleCardListSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        children: [
          VehicleCard(
            name: 'Mercedes-Benz E 300',
            subtitle: 'E-Class Sedan · 2024',
            price: '7,250만원',
            isBookmarked: true,
            onTap: () {},
            onBookmarkTap: () {},
            variant: VehicleCardVariant.list,
          ),
          const SizedBox(height: AppSpacing.space4),
          VehicleCard(
            name: 'BMW 520i',
            subtitle: '5시리즈 · 2024',
            price: '6,890만원',
            onTap: () {},
            onBookmarkTap: () {},
            variant: VehicleCardVariant.list,
          ),
        ],
      ),
    );
  }

  // ── VehicleCard Card ──────────────────────────
  Widget _buildVehicleCardCardSection() {
    return SizedBox(
      height: 220,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
        children: [
          VehicleCard(
            name: 'Audi A6',
            price: '6,450만원',
            isBookmarked: true,
            onTap: () {},
            onBookmarkTap: () {},
            variant: VehicleCardVariant.card,
          ),
          const SizedBox(width: AppSpacing.space3),
          VehicleCard(
            name: 'Porsche Taycan',
            price: '1억 2,000만원',
            onTap: () {},
            onBookmarkTap: () {},
            variant: VehicleCardVariant.card,
          ),
          const SizedBox(width: AppSpacing.space3),
          VehicleCard(
            name: 'Tesla Model 3',
            subtitle: 'Long Range',
            price: '5,999만원',
            isBookmarked: true,
            onTap: () {},
            onBookmarkTap: () {},
            variant: VehicleCardVariant.card,
          ),
        ],
      ),
    );
  }

  // ── MapPin ────────────────────────────────────
  Widget _buildMapPinSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Selected (말풍선 — 로고 + 위치 라벨)'),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space4,
            runSpacing: AppSpacing.space4,
            children: [
              const MapPin(
                brandName: 'Mercedes-Benz',
                isSelected: true,
                brandLogoAsset: 'assets/icons/brands/benz.png',
                locationLabel: '한남 전시장',
              ),
              const MapPin(
                brandName: 'BMW',
                isSelected: true,
                brandLogoAsset: 'assets/icons/brands/bmw.png',
                locationLabel: '한남 전시장',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.space6),
          _buildLabel('Default (드롭핀 — 로고만)'),
          const SizedBox(height: AppSpacing.space2),
          Wrap(
            spacing: AppSpacing.space6,
            runSpacing: AppSpacing.space4,
            children: [
              const MapPin(
                brandName: 'Mercedes-Benz',
                isSelected: false,
                brandLogoAsset: 'assets/icons/brands/benz.png',
              ),
              const MapPin(
                brandName: 'BMW',
                isSelected: false,
                brandLogoAsset: 'assets/icons/brands/bmw.png',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Label helper ──────────────────────────────
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.space1),
      child: Text(
        text,
        style: AppTypography.captionXs.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
