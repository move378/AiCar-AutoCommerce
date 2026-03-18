import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConsentPage extends StatelessWidget {
  const ConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('이용약관 동의')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text('이용약관 동의 화면', style: AppTypography.h3.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('(준비 중)', style: AppTypography.bodyMd.copyWith(color: AppColors.textTertiary)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go(RouteNames.chat),
                child: const Text('동의하고 시작하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
