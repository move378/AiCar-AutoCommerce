import 'package:aicar/domain/entities/vehicle_card.dart';

/// 차량 추천 카드 Repository 인터페이스
///
/// MVP: 목업 데이터 (go_api 구현체)
/// Post-MVP: Go API 연동
abstract class ICardRepository {
  /// 검색어 기반 추천 카드 반환
  Future<List<VehicleCard>> getRecommendations(String query);

  /// 가상차고에 저장
  Future<void> saveToGarage(VehicleCard card);
}
