import 'package:aicar/constants/assets.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/presentation/pages/vehicle_explore/widgets/search_header.dart';
import 'package:aicar/presentation/pages/vehicle_explore/widgets/sort_filter_bar.dart';
import 'package:aicar/presentation/pages/vehicle_explore/widgets/vehicle_card.dart';
import 'package:flutter/material.dart';

class VehicleExplorePage extends StatefulWidget {
  const VehicleExplorePage({super.key});

  @override
  State<VehicleExplorePage> createState() => _VehicleExplorePageState();
}

class _VehicleExplorePageState extends State<VehicleExplorePage> {
  String _selectedFilter = '전체';

  static const List<String> _vehicleImages = [
    Assets.rectangle3464044,
    Assets.rectangle43568,
    Assets.rectangle43569,
    Assets.rectangle43570,
    Assets.rectangle3464056,
  ];

  static const List<Map<String, String>> _vehicles = [
    {
      'name': 'BMW X3',
      'brand': 'BMW',
      'price': '5,480만원',
      'year': '2024',
      'mileage': '1.2만km',
      'fuel': '가솔린',
      'transmission': '자동',
      'location': '서울 강남',
    },
    {
      'name': 'Mercedes-Benz GLC',
      'brand': '벤츠',
      'price': '6,320만원',
      'year': '2024',
      'mileage': '0.8만km',
      'fuel': '디젤',
      'transmission': '자동',
      'location': '서울 서초',
    },
    {
      'name': 'Audi Q5',
      'brand': '아우디',
      'price': '5,980만원',
      'year': '2023',
      'mileage': '2.1만km',
      'fuel': '가솔린',
      'transmission': '자동',
      'location': '경기 성남',
    },
    {
      'name': 'Volvo XC60',
      'brand': '볼보',
      'price': '5,190만원',
      'year': '2023',
      'mileage': '3.2만km',
      'fuel': '하이브리드',
      'transmission': '자동',
      'location': '서울 송파',
    },
    {
      'name': 'Land Rover Discovery Sport',
      'brand': '랜드로버',
      'price': '4,890만원',
      'year': '2023',
      'mileage': '2.8만km',
      'fuel': '디젤',
      'transmission': '자동',
      'location': '서울 용산',
    },
    {
      'name': 'Porsche Macan',
      'brand': '포르쉐',
      'price': '7,250만원',
      'year': '2024',
      'mileage': '0.5만km',
      'fuel': '가솔린',
      'transmission': '자동',
      'location': '서울 강남',
    },
    {
      'name': 'Tesla Model Y',
      'brand': '테슬라',
      'price': '5,699만원',
      'year': '2024',
      'mileage': '1.0만km',
      'fuel': '전기',
      'transmission': '자동',
      'location': '경기 판교',
    },
    {
      'name': 'Lexus NX',
      'brand': '렉서스',
      'price': '5,380만원',
      'year': '2023',
      'mileage': '1.5만km',
      'fuel': '하이브리드',
      'transmission': '자동',
      'location': '서울 마포',
    },
    {
      'name': 'MINI Countryman',
      'brand': '미니',
      'price': '4,280만원',
      'year': '2023',
      'mileage': '2.0만km',
      'fuel': '가솔린',
      'transmission': '자동',
      'location': '서울 이태원',
    },
    {
      'name': 'Jaguar E-Pace',
      'brand': '재규어',
      'price': '4,590만원',
      'year': '2022',
      'mileage': '3.5만km',
      'fuel': '디젤',
      'transmission': '자동',
      'location': '인천 송도',
    },
  ];

  List<Map<String, String>> get _filteredVehicles {
    if (_selectedFilter == '전체' || _selectedFilter == 'SUV') {
      return _vehicles;
    }
    if (_selectedFilter == '세단' || _selectedFilter == '해치백') {
      // No sedan/hatchback in dummy data — show empty
      return [];
    }
    if (_selectedFilter == '전기차') {
      return _vehicles.where((v) => v['fuel'] == '전기').toList();
    }
    if (_selectedFilter == '하이브리드') {
      return _vehicles.where((v) => v['fuel'] == '하이브리드').toList();
    }
    return _vehicles;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredVehicles;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            SortFilterBar(resultCount: filtered.length),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        '검색 결과가 없습니다',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final vehicle = filtered[index];
                        final imageIndex = index % _vehicleImages.length;
                        return VehicleCard(
                          name: vehicle['name']!,
                          brand: vehicle['brand']!,
                          price: vehicle['price']!,
                          year: vehicle['year']!,
                          mileage: vehicle['mileage']!,
                          fuel: vehicle['fuel']!,
                          transmission: vehicle['transmission']!,
                          location: vehicle['location']!,
                          imageAsset: _vehicleImages[imageIndex],
                          onTap: () {
                            // TODO: Navigate to vehicle detail
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
