import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/domain/entities/consultation_card.dart';
import 'package:aicar/domain/repositories/i_garage_repository.dart';

/// 가상차고 상태
@immutable
class GarageState {
  const GarageState({
    this.cards = const [],
    this.isLoading = false,
  });

  final List<ConsultationCard> cards;
  final bool isLoading;

  GarageState copyWith({
    List<ConsultationCard>? cards,
    bool? isLoading,
  }) {
    return GarageState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 가상차고 상태 관리 Notifier
class GarageNotifier extends Notifier<GarageState> {
  late final IGarageRepository _repository;

  @override
  GarageState build() {
    _repository = ref.read(garageRepositoryProvider);
    _loadCards();
    return const GarageState(isLoading: true);
  }

  Future<void> _loadCards() async {
    final cards = await _repository.getSavedCards();
    state = state.copyWith(cards: cards, isLoading: false);
  }

  Future<void> removeCard(String cardId) async {
    await _repository.removeFromGarage(cardId);
    state = state.copyWith(
      cards: state.cards.where((c) => c.id != cardId).toList(),
    );
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadCards();
  }
}

/// Garage Provider
final garageProvider = NotifierProvider<GarageNotifier, GarageState>(
  GarageNotifier.new,
);
