import 'package:aicar/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  static const _menuItems = <_MenuItem>[
    _MenuItem(icon: Icons.receipt_long_outlined, title: '견적 내역'),
    _MenuItem(icon: Icons.history, title: '최근 본 차량'),
    _MenuItem(icon: Icons.campaign_outlined, title: '프로모션'),
    _MenuItem(icon: Icons.help_outline, title: '고객센터'),
    _MenuItem(icon: Icons.info_outline, title: '앱 정보'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _menuItems.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 52,
          color: AppColors.divider,
        ),
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Icon(
              item.icon,
              color: AppColors.grey600,
              size: 22,
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.grey400,
              size: 20,
            ),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;

  const _MenuItem({required this.icon, required this.title});
}
