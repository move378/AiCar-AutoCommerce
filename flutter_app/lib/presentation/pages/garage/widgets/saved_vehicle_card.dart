import 'package:aicar/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SavedVehicleCard extends StatelessWidget {
  final String name;
  final String brand;
  final String price;
  final String year;
  final String mileage;
  final String fuel;
  final String? imageUrl;
  final VoidCallback? onDelete;
  final VoidCallback? onEstimate;

  const SavedVehicleCard({
    super.key,
    required this.name,
    required this.brand,
    required this.price,
    required this.year,
    required this.mileage,
    required this.fuel,
    this.imageUrl,
    this.onDelete,
    this.onEstimate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 100,
                  height: 75,
                  color: AppColors.grey100,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _PlaceholderImage(),
                        )
                      : const _PlaceholderImage(),
                ),
              ),
              const SizedBox(width: 12),
              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$year  |  $mileage  |  $fuel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions column
              Column(
                children: [
                  const Icon(
                    Icons.bookmark,
                    color: AppColors.accent,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.close,
                      color: AppColors.grey400,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onEstimate,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '견적 요청',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.directions_car_outlined,
        size: 32,
        color: AppColors.grey300,
      ),
    );
  }
}
