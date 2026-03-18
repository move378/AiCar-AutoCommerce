import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/pages/onboarding/widgets/onboarding_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  static const _slides = [
    _SlideData(
      icon: Icons.chat_bubble_outline,
      title: 'AI와 대화하며\n나에게 맞는 차를 찾아보세요',
      subtitle: 'AI 컨시어지가 당신의 취향을 분석합니다',
    ),
    _SlideData(
      icon: Icons.directions_car_outlined,
      title: '다양한 차량을\n탐색하고 비교해보세요',
      subtitle: '수입차 시세와 스펙을 한눈에 확인',
    ),
    _SlideData(
      icon: Icons.garage_outlined,
      title: '나만의 가상 차고에\n관심 차량을 저장하세요',
      subtitle: '비교하고, 견적받고, 한번에 관리',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = PageController();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // PageView
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: _slides.length,
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return OnboardingSlide(
                    icon: slide.icon,
                    title: slide.title,
                    subtitle: slide.subtitle,
                  );
                },
              ),
            ),

            // Page indicator
            SmoothPageIndicator(
              controller: pageController,
              count: _slides.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColors.accent,
                dotColor: AppColors.grey300,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
                spacing: 6,
              ),
            ),

            const SizedBox(height: 32),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _BottomButtons(
                pageController: pageController,
                totalPages: _slides.length,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BottomButtons extends StatefulWidget {
  const _BottomButtons({
    required this.pageController,
    required this.totalPages,
  });

  final PageController pageController;
  final int totalPages;

  @override
  State<_BottomButtons> createState() => _BottomButtonsState();
}

class _BottomButtonsState extends State<_BottomButtons> {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    widget.pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    widget.pageController.removeListener(_onPageChanged);
    super.dispose();
  }

  void _onPageChanged() {
    final page = widget.pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  bool get _isLastPage => _currentPage == widget.totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Skip button (hidden on last page)
        if (!_isLastPage)
          TextButton(
            onPressed: () => context.go('/home/chat'),
            child: Text(
              '건너뛰기',
              style: AppTypography.labelMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          const SizedBox(width: 80),

        // Next / Start button
        if (_isLastPage)
          SizedBox(
            width: 160,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.go('/home/chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTypography.labelLg,
              ),
              child: const Text('시작하기'),
            ),
          )
        else
          SizedBox(
            width: 100,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTypography.labelLg,
              ),
              child: const Text('다음'),
            ),
          ),
      ],
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
