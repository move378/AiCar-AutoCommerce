import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/domain/entities/vehicle.dart';

/// 홈 탭 상태
@immutable
class HomeState {
  const HomeState({
    this.vehicles = const [],
    this.selectedCategory = '전체',
    this.isLoading = false,
  });

  final List<Vehicle> vehicles;
  final String selectedCategory;
  final bool isLoading;

  List<Vehicle> get filteredVehicles {
    if (selectedCategory == '전체') return vehicles;
    if (selectedCategory == 'SUV') {
      return vehicles
          .where((v) =>
              v.model.contains('X') ||
              v.model.contains('GL') ||
              v.model.contains('Q') ||
              v.model.contains('XC'))
          .toList();
    }
    // 세단: SUV가 아닌 나머지
    return vehicles
        .where((v) =>
            !v.model.contains('X') &&
            !v.model.contains('GL') &&
            !v.model.contains('Q') &&
            !v.model.contains('XC'))
        .toList();
  }

  /// 추천 차량 (처음 5대)
  List<Vehicle> get featuredVehicles =>
      vehicles.length > 5 ? vehicles.sublist(0, 5) : vehicles;

  HomeState copyWith({
    List<Vehicle>? vehicles,
    String? selectedCategory,
    bool? isLoading,
  }) {
    return HomeState(
      vehicles: vehicles ?? this.vehicles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 홈 탭 Notifier
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    _loadVehicles();
    return const HomeState(isLoading: true);
  }

  Future<void> _loadVehicles() async {
    final repository = ref.read(vehicleRepositoryProvider);
    final vehicles = await repository.getAllVehicles();
    for (final v in vehicles) {
      debugPrint('[Home] ${v.brand} ${v.model}: imageUrl=${v.imageUrl}');
    }
    state = state.copyWith(vehicles: vehicles, isLoading: false);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadVehicles();
  }
}

/// Home Provider
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
