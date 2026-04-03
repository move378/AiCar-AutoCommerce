import 'package:aicar/domain/entities/vehicle.dart';

/// 차량 정보 Repository 인터페이스
///
/// 홈 탭 차량 탐색 + AI 추천 검색용.
/// go_api: 목업 데이터 (MVP), Post-MVP: Go API 연동
abstract class IVehicleRepository {
  /// 전체 차량 목록 (홈 탐색)
  Future<List<Vehicle>> getAllVehicles();

  /// 키워드 기반 차량 검색 (AI 추천 필터)
  Future<List<Vehicle>> searchVehicles(String query);

  /// ID로 차량 단건 조회
  Future<Vehicle?> getVehicleById(String id);
}
