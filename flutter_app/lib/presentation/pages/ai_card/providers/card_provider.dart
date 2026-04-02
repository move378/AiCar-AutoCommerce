import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/domain/entities/consultation_card.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/repositories/i_garage_repository.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// 카드 리스트 상태
@immutable
class CardListState {
  const CardListState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isLoading = false,
  });

  final List<Vehicle> cards;
  final int currentIndex;
  final bool isLoading;

  CardListState copyWith({
    List<Vehicle>? cards,
    int? currentIndex,
    bool? isLoading,
  }) {
    return CardListState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 카드 리스트 Notifier
class CardNotifier extends Notifier<CardListState> {
  late final IVehicleRepository _vehicleRepo;
  late final IGarageRepository _garageRepo;

  @override
  CardListState build() {
    _vehicleRepo = ref.read(vehicleRepositoryProvider);
    _garageRepo = ref.read(garageRepositoryProvider);
    return const CardListState();
  }

  /// 추천 카드 로드
  Future<void> loadRecommendations(String query) async {
    state = state.copyWith(isLoading: true);
    final cards = await _vehicleRepo.searchVehicles(query);
    state = state.copyWith(cards: cards, isLoading: false, currentIndex: 0);
  }

  /// 현재 카드 인덱스 업데이트
  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  /// 가상차고에 저장
  Future<void> saveToGarage() async {
    if (state.cards.isEmpty) return;
    final vehicle = state.cards[state.currentIndex];
    final card = ConsultationCard(
      id: 'card-${vehicle.id}-${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: vehicle.id,
      recommendReason: '키워드 매칭 추천',
      matchScore: 0.8,
      createdAt: DateTime.now(),
    );
    await _garageRepo.saveToGarage(card);
  }
}

/// Card Provider
final cardProvider = NotifierProvider<CardNotifier, CardListState>(
  CardNotifier.new,
);
