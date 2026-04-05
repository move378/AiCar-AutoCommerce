import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';

/// 차량 카탈로그 Repository 인터페이스
///
/// 데이터 소스: GET /api/v1/cars, GET /api/v1/brands
abstract class IVehicleRepository {
  /// 차량 목록 (페이지네이션)
  Future<List<Vehicle>> getAllVehicles({int page = 1, int size = 20});

  /// 키워드 기반 차량 검색
  Future<List<Vehicle>> searchVehicles(String query, {int page = 1, int size = 20});

  /// ID로 차량 단건 조회 (이미지 포함)
  Future<Vehicle?> getVehicleById(String id);

  /// 브랜드 목록 조회
  Future<List<Brand>> getBrands();
}
