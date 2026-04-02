import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// 버튼 크기
enum AiCarButtonSize {
  /// sm — 높이 40px, 아이콘 20px, bodySm 텍스트
  sm,

  /// lg — 높이 48px, 아이콘 22px, bodyMd 텍스트
  lg,
}

/// 버튼 스타일
enum AiCarButtonStyle {
  /// 배경색 채우기 (slate-800)
  solid,

  /// 테두리만 (white bg + primary border)
  outline,
}

/// AiCar 디자인 시스템 버튼
///
/// Figma: Button (sm/lg, solid/outline, hover/disabled)
/// node-ids: 2432-571 ~ 2432-599
class AiCarButton extends StatelessWidget {
  const AiCarButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AiCarButtonSize.lg,
    this.style = AiCarButtonStyle.solid,
    this.leadingIcon,
    this.trailingIcon,
    this.isExpanded = false,
  });

  final String label;

  /// null이면 disabled 상태
  final VoidCallback? onPressed;
  final AiCarButtonSize size;
  final AiCarButtonStyle style;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// true이면 부모 너비를 가득 채움
  final bool isExpanded;

  bool get _isDisabled => onPressed == null;

  double get _height => switch (size) {
        AiCarButtonSize.sm => 40,
        AiCarButtonSize.lg => 48,
      };

  double get _iconSize => switch (size) {
        AiCarButtonSize.sm => 20,
        AiCarButtonSize.lg => 22,
      };

  TextStyle get _textStyle => switch (size) {
        AiCarButtonSize.sm => AppTypography.bodySm,
        AiCarButtonSize.lg => AppTypography.bodyMd,
      };

  @override
  Widget build(BuildContext context) {
    return switch (style) {
      AiCarButtonStyle.solid => _buildSolid(),
      AiCarButtonStyle.outline => _buildOutline(),
    };
  }

  Widget _buildSolid() {
    final bgColor = _isDisabled
        ? AppColors.buttonSolidDisabled
        : AppColors.buttonSolidDefault;
    final fgColor =
        _isDisabled ? AppColors.textDisabled : AppColors.textOnDark;

    return _buildContainer(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      border: null,
    );
  }

  Widget _buildOutline() {
    final fgColor = _isDisabled ? AppColors.textDisabled : AppColors.primary;
    final borderColor =
        _isDisabled ? AppColors.textDisabled : AppColors.primary;

    return Opacity(
      opacity: _isDisabled ? 0.4 : 1.0,
      child: _buildContainer(
        backgroundColor: AppColors.buttonOutlineDefault,
        foregroundColor: fgColor,
        border: Border.all(color: borderColor),
      ),
    );
  }

  Widget _buildContainer({
    required Color backgroundColor,
    required Color foregroundColor,
    required BoxBorder? border,
  }) {
    final content = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _iconSize, color: foregroundColor),
          const SizedBox(width: AppSpacing.space2),
        ],
        Flexible(
          child: Text(
            label,
            style: _textStyle.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.space2),
          Icon(trailingIcon, size: _iconSize, color: foregroundColor),
        ],
      ],
    );

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: _height,
        padding: AppShape.buttonPadding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: AppShape.radiusMd,
          border: border,
        ),
        child: content,
      ),
    );
  }
}
