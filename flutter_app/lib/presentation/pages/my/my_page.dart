import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 마이페이지 — 차고 헤더 톱니바퀴에서 push 진입
///
/// 미로그인 시: 로그인 유도 화면
/// 로그인 완료 시: 다크 프로필 카드 + 3섹션 메뉴
class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  static const _backgroundGrey = Color(0xFFF1F5F9); // slate-100

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isLoggedIn || !auth.hasConsented) {
      return _buildLoginPrompt(context);
    }

    return _buildMyContent(context, ref, auth);
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: AppSpacing.space4),
              Text(
                '마이페이지를 이용하려면\n로그인이 필요해요',
                textAlign: TextAlign.center,
                style: AppTypography.heading2xl.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.space2),
              Text(
                '로그인하면 프로필과\n설정을 관리할 수 있어요',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.space8),
              AiCarButton(
                label: '로그인하기',
                onPressed: () => context.push('/login'),
                size: AiCarButtonSize.lg,
                style: AiCarButtonStyle.solid,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyContent(BuildContext context, WidgetRef ref, AuthState auth) {
    return Scaffold(
      backgroundColor: _backgroundGrey,
      body: Column(
        children: [
          const AiCarHeader(title: '마이페이지', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                children: [
                  // ── 프로필 카드 (다크, 상담카드 스타일) ──
                  _ProfileCard(
                    auth: auth,
                    onEditProfile: () => context.push('/my/profile-edit'),
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // ── 서비스 이용안내 섹션 ──
                  const _SectionHeader(title: '서비스 이용안내'),
                  const SizedBox(height: AppSpacing.space2),
                  _MenuGroup(
                    items: [
                      _MenuItemData(
                        title: '이용약관',
                        onTap: () => context.push('/my/terms'),
                      ),
                      _MenuItemData(
                        title: '개인정보 처리방침',
                        onTap: () => context.push('/my/privacy'),
                      ),
                      _MenuItemData(
                        title: '위치기반 서비스 이용약관',
                        onTap: () => context.push('/my/location-terms'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.space6),

                  // ── 앱 정보 섹션 ──
                  const _SectionHeader(title: '앱 정보'),
                  const SizedBox(height: AppSpacing.space2),
                  _MenuGroup(
                    items: [
                      const _MenuItemData(
                        title: '버전정보',
                        trailing: 'v0.1.0',
                      ),
                      _MenuItemData(
                        title: '로그아웃',
                        isDestructive: true,
                        onTap: () => _showLogoutDialog(context, ref),
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '로그아웃',
          style: AppTypography.headingXl.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '정말 로그아웃 하시겠습니까?',
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
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(authProvider.notifier).logout();
              context.go('/home');
            },
            child: Text(
              '확인',
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

// ── 프로필 카드 (다크, 상담카드 스타일) ──────────────

/// 다크 프로필 카드 — 상담카드와 동일한 cardBackground 스타일
/// 하단에 "회원정보 수정 >" 네비게이션
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.auth, required this.onEditProfile});

  final AuthState auth;
  final VoidCallback onEditProfile;

  // mock 차량 정보
  static const _mockPlate = '08나 6543';
  static const _mockModel = '벤츠 CLE클래스';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEditProfile,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: AppColors.cardBackground, // slate-500
          borderRadius: AppShape.radiusMd,
        ),
        child: Column(
          children: [
            // 프로필 정보 (이름, 이메일, 차량)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF475569), // slate-600
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.userName ?? '사용자',
                          style: AppTypography.headingXl.copyWith(
                            color: AppColors.textOnDark,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space1),
                        Text(
                          auth.userEmail ?? '',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.space3),
                        Text(
                          '$_mockPlate · $_mockModel',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 회원정보 수정 링크 (더 진한 다크 배경)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space3,
              ),
              color: Colors.black.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '회원정보 수정',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.textDisabled,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textDisabled,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 섹션 헤더 ──────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.space1),
        child: Text(
          title,
          style: AppTypography.bodySm.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── 메뉴 그룹 (흰 배경 카드) ─────────────────────

class _MenuItemData {
  const _MenuItemData({
    required this.title,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  final String title;
  final VoidCallback? onTap;
  final String? trailing;
  final bool isDestructive;
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: AppShape.radiusMd,
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MenuItem(data: items[i]),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: AppSpacing.space4,
                endIndent: AppSpacing.space4,
                color: AppColors.surface,
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.data});

  final _MenuItemData data;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onTap,
      borderRadius: AppShape.radiusMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                data.title,
                style: AppTypography.bodyMd.copyWith(
                  color: data.isDestructive
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (data.trailing != null)
              Text(
                data.trailing!,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.textTertiary,
                ),
              )
            else if (!data.isDestructive && data.onTap != null)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
