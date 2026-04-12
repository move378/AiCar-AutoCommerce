import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_elevation.dart';
import 'package:aicar/core/theme/app_shape.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/widgets/buttons/bookmark_button.dart';

/// 차량 카드 표시 변형
enum VehicleCardVariant {
  /// 전체 너비, 높이 ~210px (이미지 140 + 정보 70)
  list,

  /// 고정 너비 200px, 높이 ~190px (이미지 120 + 정보 70)
  card,
}

/// 차량 카드 위젯
///
/// Figma: card (List/Card)
/// List — node 2450:3665: 343×210px
/// Card — node 2450:3684: 200×190px
class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    this.subtitle,
    this.isBookmarked = false,
    this.onTap,
    this.onBookmarkTap,
    this.variant = VehicleCardVariant.list,
  });

  final String name;
  final String price;
  final String? imageUrl;
  final String? subtitle;
  final bool isBookmarked;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final VehicleCardVariant variant;

  double get _imageHeight => switch (variant) {
        VehicleCardVariant.list => 140,
        VehicleCardVariant.card => 120,
      };

  double? get _width => switch (variant) {
        VehicleCardVariant.list => null, // fills parent
        VehicleCardVariant.card => 200,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _width,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppShape.radiusMd,
          boxShadow: AppElevation.elevation1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildImage(),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    debugPrint('[VehicleCard] imageUrl=$imageUrl, name=$name');
    return Container(
      height: _imageHeight,
      width: double.infinity,
      color: AppColors.surface,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                );
              },
              errorBuilder: (_, error, __) {
                debugPrint('[VehicleCard] Image load FAILED: $error');
                return _buildImagePlaceholder();
              },
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.directions_car_outlined,
        size: 48,
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.captionXs.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.space1),
                Text(
                  price,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          BookmarkButton(
            isBookmarked: isBookmarked,
            onTap: onBookmarkTap,
          ),
        ],
      ),
    );
  }
}
