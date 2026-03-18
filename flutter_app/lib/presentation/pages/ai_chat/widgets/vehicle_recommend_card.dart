import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/presentation/pages/ai_chat/providers/chat_provider.dart';
import 'package:flutter/material.dart';

class VehicleRecommendCards extends StatelessWidget {
  final List<VehicleRecommendation> recommendations;

  const VehicleRecommendCards({
    super.key,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 16),
        itemCount: recommendations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return _VehicleCard(recommendation: recommendations[index]);
        },
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final VehicleRecommendation recommendation;

  const _VehicleCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle image
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Image.asset(
              recommendation.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.grey100,
                child: const Icon(
                  Icons.directions_car,
                  size: 48,
                  color: AppColors.grey400,
                ),
              ),
            ),
          ),
          // Info section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation.name,
                  style: AppTypography.labelMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.price,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${recommendation.year}${recommendation.specs != null ? ' · ${recommendation.specs}' : ''}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
