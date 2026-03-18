import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/presentation/pages/garage/widgets/empty_garage.dart';
import 'package:aicar/presentation/pages/garage/widgets/garage_header.dart';
import 'package:aicar/presentation/pages/garage/widgets/menu_section.dart';
import 'package:aicar/presentation/pages/garage/widgets/saved_vehicle_card.dart';
import 'package:flutter/material.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  final List<Map<String, String>> _savedVehicles = [
    {
      'name': 'BMW X3 xDrive30i',
      'brand': 'BMW',
      'price': '5,480만원',
      'year': '2024',
      'mileage': '1.2만km',
      'fuel': '가솔린',
    },
    {
      'name': 'Volvo XC60 T6',
      'brand': '볼보',
      'price': '5,190만원',
      'year': '2023',
      'mileage': '3.2만km',
      'fuel': '하이브리드',
    },
    {
      'name': 'Tesla Model Y Long Range',
      'brand': '테슬라',
      'price': '5,699만원',
      'year': '2024',
      'mileage': '1.0만km',
      'fuel': '전기',
    },
  ];

  void _removeVehicle(int index) {
    setState(() {
      _savedVehicles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GarageHeader(),
              const SizedBox(height: 16),
              // Section title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      '내 관심 차량',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        '편집',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Vehicle list or empty state
              if (_savedVehicles.isEmpty)
                const EmptyGarage()
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _savedVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _savedVehicles[index];
                    return SavedVehicleCard(
                      name: vehicle['name']!,
                      brand: vehicle['brand']!,
                      price: vehicle['price']!,
                      year: vehicle['year']!,
                      mileage: vehicle['mileage']!,
                      fuel: vehicle['fuel']!,
                      onDelete: () => _removeVehicle(index),
                      onEstimate: () {},
                    );
                  },
                ),
              const SizedBox(height: 24),
              const MenuSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
