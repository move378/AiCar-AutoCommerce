import 'dart:convert';
import 'dart:developer' as dev;

import 'package:aicar/data/datasources/local/app_database.dart';
import 'package:aicar/domain/entities/consultation_card.dart';
import 'package:aicar/domain/repositories/i_garage_repository.dart';

/// Go API 백엔드용 가상차고 Repository 구현체
///
/// MVP: Drift CardCacheTable 기반 로컬 저장
class GarageRepositoryImpl implements IGarageRepository {
  GarageRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> saveToGarage(ConsultationCard card) async {
    await _db.into(_db.cardCacheTable).insertOnConflictUpdate(
          CardCacheTableCompanion.insert(
            cardId: card.id,
            cardJson: jsonEncode(card.toJson()),
            cachedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<List<ConsultationCard>> getSavedCards() async {
    final rows = await _db.select(_db.cardCacheTable).get();
    final cards = <ConsultationCard>[];

    for (final row in rows) {
      try {
        final json = jsonDecode(row.cardJson) as Map<String, dynamic>;
        cards.add(ConsultationCard.fromJson(json));
      } catch (e) {
        // JSON 마이그레이션: 기존 VehicleCard JSON은 ConsultationCard 스키마와
        // 호환되지 않으므로 파싱 실패 시 깨진 레코드를 조용히 삭제
        dev.log('Garage: removing incompatible record ${row.cardId}', error: e);
        await (_db.delete(_db.cardCacheTable)
              ..where((t) => t.cardId.equals(row.cardId)))
            .go();
      }
    }

    return cards;
  }

  @override
  Future<void> removeFromGarage(String cardId) async {
    await (_db.delete(_db.cardCacheTable)
          ..where((t) => t.cardId.equals(cardId)))
        .go();
  }
}
