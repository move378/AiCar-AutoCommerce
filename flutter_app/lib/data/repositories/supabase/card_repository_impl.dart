import 'package:aicar/domain/entities/vehicle_card.dart';
import 'package:aicar/domain/repositories/i_card_repository.dart';

/// Supabase 백엔드용 카드 Repository 스텁
class CardRepositoryImpl implements ICardRepository {
  @override
  Future<List<VehicleCard>> getRecommendations(String query) {
    throw UnimplementedError('Supabase card not implemented');
  }

  @override
  Future<void> saveToGarage(VehicleCard card) {
    throw UnimplementedError('Supabase card not implemented');
  }
}
