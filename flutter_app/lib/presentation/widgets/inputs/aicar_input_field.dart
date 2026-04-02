import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// AiCar 디자인 시스템 텍스트 입력 필드
///
/// AppTheme.light의 inputDecorationTheme을 기반으로 하며,
/// label, hint, error, prefix/suffix 등의 커스터마이징을 지원.
class AiCarInputField extends StatelessWidget {
  const AiCarInputField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.focusNode,
  });

  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          focusNode: focusNode,
          style: AppTypography.bodyMd.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: !enabled,
            fillColor: enabled ? null : AppColors.surface,
          ),
        ),
      ],
    );
  }
}
