import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/inputs/aicar_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 회원정보 수정 — 프로필 정보 페이지
///
/// 2탭: 차량 보유 계정 / 소셜 전용 계정
/// 하단: 변경하기 + 회원탈퇴
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // 차량 보유 계정 폼
  final _ownerController = TextEditingController();
  final _plateController = TextEditingController();
  bool _hasSearchResult = false;

  // 소셜 전용 계정 폼
  final _nicknameController = TextEditingController();

  // Mock 차량 조회 결과
  static const _mockVehicleResult = {
    '모델명': '벤츠 CLE클래스',
    '연식': '2026년형',
    '최초등록': '2026년 1월 9일',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // mock 초기값
    final auth = ref.read(authProvider);
    _ownerController.text = auth.userName ?? '';
    _nicknameController.text = auth.userName ?? '';
    _plateController.text = '08나 6543';
    _hasSearchResult = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ownerController.dispose();
    _plateController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVehicleOwnerTab(),
                _buildSocialOnlyTab(),
              ],
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  /// 헤더: "프로필 정보" + 우측 X 닫기
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 56), // 좌측 밸런스용 빈 공간
            Expanded(
              child: Center(
                child: Text(
                  '프로필 정보',
                  style: AppTypography.headingXl.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 56,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: const Icon(
                  Icons.close,
                  size: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 바: 차량 보유 계정 / 소셜 전용 계정
  Widget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textTertiary,
      labelStyle: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: AppTypography.bodyMd,
      indicatorColor: AppColors.textPrimary,
      indicatorWeight: 2,
      tabs: const [
        Tab(text: '차량 보유 계정'),
        Tab(text: '소셜 전용 계정'),
      ],
    );
  }

  // ── 탭 1: 차량 보유 계정 ──────────────────────

  Widget _buildVehicleOwnerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space4),
          _buildSectionTitle('차량정보'),
          const SizedBox(height: AppSpacing.space4),
          AiCarInputField(
            label: '소유자',
            controller: _ownerController,
            suffixIcon: _buildClearButton(_ownerController),
          ),
          const SizedBox(height: AppSpacing.space4),
          AiCarInputField(
            controller: _plateController,
            hint: '차량번호 입력',
            suffixIcon: _buildClearButton(_plateController),
          ),
          const SizedBox(height: AppSpacing.space4),
          AiCarButton(
            label: '조회',
            onPressed: () {
              setState(() => _hasSearchResult = true);
            },
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
            isExpanded: true,
          ),
          if (_hasSearchResult) ...[
            const SizedBox(height: AppSpacing.space4),
            _buildVehicleResultCard(),
          ],
          const SizedBox(height: AppSpacing.space8),
          _buildSectionTitle('연결계정'),
          const SizedBox(height: AppSpacing.space4),
          const _ConnectedAccountsCard(),
        ],
      ),
    );
  }

  Widget _buildVehicleResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textDisabled),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: _mockVehicleResult.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── 탭 2: 소셜 전용 계정 ──────────────────────

  Widget _buildSocialOnlyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.space4),
          _buildNoVehiclePlaceholder(),
          const SizedBox(height: AppSpacing.space8),
          _buildSectionTitle('기본정보'),
          const SizedBox(height: AppSpacing.space4),
          AiCarInputField(
            label: '닉네임',
            controller: _nicknameController,
            suffixIcon: _buildClearButton(_nicknameController),
          ),
          const SizedBox(height: AppSpacing.space8),
          _buildSectionTitle('연결계정'),
          const SizedBox(height: AppSpacing.space4),
          const _ConnectedAccountsCard(),
        ],
      ),
    );
  }

  Widget _buildNoVehiclePlaceholder() {
    return GestureDetector(
      onTap: () => _tabController.animateTo(0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.space6,
          horizontal: AppSpacing.space4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.textDisabled,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            Text(
              '등록된 차량이 없습니다',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space3),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textSecondary),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.space2),
                Text(
                  '차량번호로 차량등록하기',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── 공용 위젯 ──────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.bodyMd.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildClearButton(TextEditingController controller) {
    return GestureDetector(
      onTap: () {
        controller.clear();
        setState(() {});
      },
      child: const Icon(
        Icons.cancel,
        size: 20,
        color: AppColors.textTertiary,
      ),
    );
  }

  /// 하단: 회원탈퇴 + 변경하기 버튼
  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4,
          AppSpacing.space2,
          AppSpacing.space4,
          AppSpacing.space4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _showWithdrawDialog,
              child: Text(
                '회원탈퇴',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.error,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.error,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.space2),
            AiCarButton(
              label: '변경하기',
              onPressed: () {
                // MVP: 변경 완료 스낵바 표시 후 pop
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('프로필 정보가 변경되었습니다.')),
                );
                context.pop();
              },
              size: AiCarButtonSize.lg,
              style: AiCarButtonStyle.solid,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '회원탈퇴',
          style: AppTypography.headingXl.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '정말 탈퇴하시겠습니까?\n탈퇴 후 모든 데이터가 삭제됩니다.',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              '취소',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).deleteAccount();
              if (context.mounted) context.go('/home');
            },
            child: Text(
              '탈퇴하기',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 연결계정 카드 — 실제 로그인 provider 기반 표시
class _ConnectedAccountsCard extends ConsumerWidget {
  const _ConnectedAccountsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final provider = auth.provider;
    final email = auth.userEmail;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textDisabled),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildAccountRow('카카오',
              email: provider == 'kakao' ? email : null,
              isConnected: provider == 'kakao'),
          const Divider(height: AppSpacing.space6, color: AppColors.surface),
          _buildAccountRow('구글',
              email: provider == 'google' ? email : null,
              isConnected: provider == 'google'),
        ],
      ),
    );
  }

  Widget _buildAccountRow(
    String provider, {
    String? email,
    required bool isConnected,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.space1),
              Text(
                isConnected ? (email ?? '연결됨') : '미연결',
                style: AppTypography.bodySm.copyWith(
                  color: isConnected
                      ? AppColors.textSecondary
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (isConnected)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3,
              vertical: AppSpacing.space1,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '연결됨',
              style: AppTypography.captionXs.copyWith(
                color: AppColors.textOnDark,
              ),
            ),
          ),
      ],
    );
  }
}
