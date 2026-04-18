import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/inputs/aicar_input_field.dart';

/// 차량 조회 온보딩 — 4단계 플로우
///
/// Figma: 온보딩 (2413-826)
/// 1. 차량번호 입력
/// 2. 소유자명 입력
/// 3. 공공API 조회 결과 표시
/// 4. 등록 완료
enum _Step { plateInput, ownerInput, result, complete }

class VehicleCheckPage extends ConsumerStatefulWidget {
  const VehicleCheckPage({super.key});

  @override
  ConsumerState<VehicleCheckPage> createState() => _VehicleCheckPageState();
}

class _VehicleCheckPageState extends ConsumerState<VehicleCheckPage> {
  _Step _currentStep = _Step.plateInput;

  final _plateController = TextEditingController();
  final _ownerController = TextEditingController();

  // Mock 조회 결과
  String? _modelName;
  String? _modelYear;
  String? _registrationDate;

  @override
  void dispose() {
    _plateController.dispose();
    _ownerController.dispose();
    super.dispose();
  }

  void _onPlateSubmit() {
    if (_plateController.text.trim().isEmpty) return;
    setState(() => _currentStep = _Step.ownerInput);
  }

  void _onOwnerSubmit() {
    if (_ownerController.text.trim().isEmpty) return;
    // Mock 공공API 조회 결과
    setState(() {
      _modelName = '벤츠 CLE클래스';
      _modelYear = '2026년형';
      _registrationDate = '2026년 1월 9일';
      _currentStep = _Step.result;
    });
  }

  Future<void> _onRegisterComplete() async {
    // 백엔드에 차량 등록
    final auth = ref.read(authProvider);
    if (auth.userId != null) {
      try {
        final myCarRepo = ref.read(myCarRepositoryProvider);
        await myCarRepo.registerCar(
          userId: auth.userId!,
          licensePlate: _plateController.text.trim(),
        );
      } catch (_) {
        // 등록 실패해도 온보딩은 계속 진행
      }
    }

    setState(() => _currentStep = _Step.complete);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/home');
    });
  }

  void _skipToHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space6),
          child: switch (_currentStep) {
            _Step.plateInput => _buildPlateInput(),
            _Step.ownerInput => _buildOwnerInput(),
            _Step.result => _buildResult(),
            _Step.complete => _buildComplete(),
          },
        ),
      ),
    );
  }

  // ── Step 1: 차량번호 입력 ─────────────────────
  Widget _buildPlateInput() {
    return Column(
      children: [
        const Spacer(flex: 1),
        _buildCharacter(),
        const SizedBox(height: AppSpacing.space6),
        Text(
          '차량이 있으신가요?',
          style: AppTypography.heading2xl.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          '에이카가 차량에 맞춰\n더 정확하게 추천해드릴게요!',
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(flex: 1),
        Text(
          '차량 번호를 입력해주세요',
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space2),
        AiCarInputField(
          hint: '00가 0000',
          controller: _plateController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.space4),
        if (_plateController.text.trim().isNotEmpty)
          AiCarButton(
            label: '다음',
            onPressed: _onPlateSubmit,
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
            isExpanded: true,
          ),
        const Spacer(flex: 2),
        _buildSkipButton(),
        const SizedBox(height: AppSpacing.space8),
      ],
    );
  }

  // ── Step 2: 소유자명 입력 ─────────────────────
  Widget _buildOwnerInput() {
    return Column(
      children: [
        const Spacer(flex: 1),
        _buildCharacter(),
        const SizedBox(height: AppSpacing.space6),
        Text(
          '차량 소유자명을 알려주세요!',
          style: AppTypography.heading2xl.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          '법인/리스 차량은\n법인명(리스사명)을 입력해주세요',
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(flex: 1),
        Text(
          '소유자명을 입력해주세요',
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.space2),
        AiCarInputField(
          hint: '에이카',
          controller: _ownerController,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.space4),
        // 입력된 차량번호 표시
        _buildInfoChip(_plateController.text),
        const SizedBox(height: AppSpacing.space4),
        if (_ownerController.text.trim().isNotEmpty)
          AiCarButton(
            label: '조회하기',
            onPressed: _onOwnerSubmit,
            size: AiCarButtonSize.lg,
            style: AiCarButtonStyle.solid,
            isExpanded: true,
          ),
        const Spacer(flex: 2),
      ],
    );
  }

  // ── Step 3: 조회 결과 ─────────────────────────
  Widget _buildResult() {
    return Column(
      children: [
        const Spacer(flex: 1),
        _buildCharacter(),
        const SizedBox(height: AppSpacing.space6),
        Text(
          '차량 소유자명을 알려주세요!',
          style: AppTypography.heading2xl.copyWith(color: AppColors.textPrimary),
        ),
        const Spacer(flex: 1),
        _buildInfoChip(_plateController.text),
        const SizedBox(height: AppSpacing.space3),
        _buildVehicleInfoCard(),
        const SizedBox(height: AppSpacing.space6),
        AiCarButton(
          label: '차량 등록하기',
          onPressed: _onRegisterComplete,
          size: AiCarButtonSize.lg,
          style: AiCarButtonStyle.solid,
          isExpanded: true,
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  // ── Step 4: 등록 완료 ─────────────────────────
  Widget _buildComplete() {
    return Column(
      children: [
        const Spacer(flex: 1),
        _buildCharacter(),
        const SizedBox(height: AppSpacing.space6),
        Text(
          '차량 등록을 완료했어요!',
          style: AppTypography.heading2xl.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.space2),
        Text(
          '이제 에이카가 취향에 꼭 맞는\n차량을 추천해드릴게요',
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const Spacer(flex: 1),
        _buildInfoChip(_ownerController.text),
        const SizedBox(height: AppSpacing.space2),
        _buildInfoChip(_plateController.text),
        const SizedBox(height: AppSpacing.space3),
        _buildVehicleInfoCard(),
        const Spacer(flex: 2),
      ],
    );
  }

  // ── Shared widgets ────────────────────────────
  Widget _buildCharacter() {
    return Image.asset(
      'assets/images/character.png',
      width: 100,
      height: 100,
      errorBuilder: (_, __, ___) => Icon(
        Icons.smart_toy_outlined,
        size: 80,
        color: AppColors.secondary,
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _skipToHome,
      child: Text(
        '아직 차량이 없어요',
        style: AppTypography.bodySm.copyWith(
          color: AppColors.textAccent,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.textAccent,
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        border: Border.all(color: AppColors.textDisabled),
      ),
      child: Text(
        text,
        style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildVehicleInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.space4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: AppColors.textDisabled),
      ),
      child: Column(
        children: [
          _buildInfoRow('모델명', _modelName ?? '-'),
          const SizedBox(height: AppSpacing.space2),
          _buildInfoRow('연식', _modelYear ?? '-'),
          const SizedBox(height: AppSpacing.space2),
          _buildInfoRow('최초등록', _registrationDate ?? '-'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
