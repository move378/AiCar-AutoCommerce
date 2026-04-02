import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';

/// 북마크 토글 버튼
///
/// Figma: Bookmark_light
/// 저장됨: filled bookmark (emerald-500)
/// 미저장: outlined bookmark (slate-400)
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
    required this.isBookmarked,
    required this.onTap,
    this.size = 24,
  });

  final bool isBookmarked;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.space1),
        child: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: size,
          color: isBookmarked
              ? AppColors.secondary
              : AppColors.textTertiary,
        ),
      ),
    );
  }
}
