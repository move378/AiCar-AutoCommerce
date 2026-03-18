import 'package:aicar/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SortFilterBar extends StatelessWidget {
  const SortFilterBar({
    super.key,
    required this.resultCount,
  });

  final int resultCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '검색결과 $resultCount대',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Row(
              children: [
                Icon(
                  Icons.swap_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4),
                Text(
                  '추천순',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
