import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/database_provider.dart';
import 'package:aicar/data/repositories/go_api/card_repository_impl.dart'
    as go_api;
import 'package:aicar/domain/entities/vehicle_card.dart';
import 'package:aicar/domain/repositories/i_card_repository.dart';

/// 카드 리스트 상태
@immutable
class CardListState {
  const CardListState({
    this.cards = const [],
    this.currentIndex = 0,
    this.isLoading = false,
  });

  final List<VehicleCard> cards;
  final int currentIndex;
  final bool isLoading;

  CardListState copyWith({
    List<VehicleCard>? cards,
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
  late final ICardRepository _repository;

  @override
  CardListState build() {
    _repository = ref.read(cardRepositoryProvider);
    return const CardListState();
  }

  /// 추천 카드 로드
  Future<void> loadRecommendations(String query) async {
    state = state.copyWith(isLoading: true);
    final cards = await _repository.getRecommendations(query);
    state = state.copyWith(cards: cards, isLoading: false, currentIndex: 0);
  }

  /// 현재 카드 인덱스 업데이트
  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  /// 가상차고에 저장
  Future<void> saveToGarage() async {
    if (state.cards.isEmpty) return;
    final card = state.cards[state.currentIndex];
    await _repository.saveToGarage(card);
  }
}

/// Card Repository Provider — go_api 구현체 (MVP)
final cardRepositoryProvider = Provider<ICardRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return go_api.CardRepositoryImpl(db);
});

/// Card Provider
final cardProvider = NotifierProvider<CardNotifier, CardListState>(
  CardNotifier.new,
);
