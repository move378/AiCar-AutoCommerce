import 'package:aicar/domain/entities/consultation_card.dart';
import 'package:aicar/domain/repositories/i_garage_repository.dart';

/// Supabase 백엔드용 가상차고 Repository 스텁
class GarageRepositoryImpl implements IGarageRepository {
  @override
  Future<void> saveToGarage(ConsultationCard card) {
    throw UnimplementedError('Supabase garage not implemented');
  }

  @override
  Future<List<ConsultationCard>> getSavedCards() {
    throw UnimplementedError('Supabase garage not implemented');
  }

  @override
  Future<void> removeFromGarage(String cardId) {
    throw UnimplementedError('Supabase garage not implemented');
  }
}
