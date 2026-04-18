import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/inputs/aicar_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 회원정보 수정 — 프로필 정보 페이지 (단일 화면)
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _nicknameController = TextEditingController();
  final _plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _nicknameController.text = auth.userName ?? auth.userEmail ?? '';
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.space4),
                  // ── 차량 정보 ──
                  _buildVehicleSection(),
                  const SizedBox(height: AppSpacing.space8),
                  // ── 기본정보 ──
                  _buildSectionTitle('기본정보'),
                  const SizedBox(height: AppSpacing.space4),
                  AiCarInputField(
                    label: '닉네임',
                    controller: _nicknameController,
                    suffixIcon: _buildClearButton(_nicknameController),
                  ),
                  const SizedBox(height: AppSpacing.space8),
                  // ── 연결계정 ──
                  _buildSectionTitle('연결계정'),
                  const SizedBox(height: AppSpacing.space4),
                  const _ConnectedAccountsCard(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  /// 헤더
  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 56),
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

  /// 차량 정보 섹션
  Widget _buildVehicleSection() {
    final auth = ref.watch(authProvider);
    final hasVehicle = auth.carPlate != null && auth.carPlate!.isNotEmpty;

    if (hasVehicle) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondary),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, size: 20, color: AppColors.secondary),
                const SizedBox(width: AppSpacing.space2),
                Text('내 차량', style: AppTypography.bodyMd.copyWith(
                  color: AppColors.secondary, fontWeight: FontWeight.w600,
                )),
              ],
            ),
            const SizedBox(height: AppSpacing.space3),
            _buildInfoRow('차량번호', auth.carPlate!),
            if (auth.carOwner != null && auth.carOwner!.isNotEmpty)
              _buildInfoRow('소유자', auth.carOwner!),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.textDisabled),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_outlined, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.space3),
          Text('등록된 차량이 없습니다',
            style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.space4),
          AiCarInputField(
            hint: '차량번호 입력 (예: 08나 6543)',
            controller: _plateController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.space3),
          AiCarButton(
            label: '차량 등록',
            onPressed: _plateController.text.trim().isNotEmpty
                ? () {
                    ref.read(authProvider.notifier).registerCar(
                      plate: _plateController.text.trim(),
                      owner: '',
                    );
                  }
                : null,
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space1),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label,
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary))),
          Expanded(child: Text(value,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

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
      child: const Icon(Icons.cancel, size: 20, color: AppColors.textTertiary),
    );
  }

  Widget _buildBottomActions() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.space4, AppSpacing.space2, AppSpacing.space4, AppSpacing.space4,
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
          style: AppTypography.headingXl.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          '정말 탈퇴하시겠습니까?\n탈퇴 후 모든 데이터가 삭제됩니다.',
          style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('취소', style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authProvider.notifier).deleteAccount();
              if (context.mounted) context.go('/home');
            },
            child: Text('탈퇴하기', style: AppTypography.bodyMd.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// 연결계정 카드
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

  Widget _buildAccountRow(String provider, {String? email, required bool isConnected}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(provider, style: AppTypography.bodyMd.copyWith(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: AppSpacing.space1),
              Text(
                isConnected ? (email ?? '연결됨') : '미연결',
                style: AppTypography.bodySm.copyWith(
                  color: isConnected ? AppColors.textSecondary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
        if (isConnected)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space3, vertical: AppSpacing.space1,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text('연결됨', style: AppTypography.captionXs.copyWith(color: AppColors.textOnDark)),
          ),
      ],
    );
  }
}
