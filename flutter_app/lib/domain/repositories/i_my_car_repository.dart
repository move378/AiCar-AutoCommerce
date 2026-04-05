import 'package:aicar/domain/entities/my_car.dart';

/// 내 차량 등록 Repository 인터페이스
///
/// 데이터 소스: POST /api/v1/cars/register, GET /api/v1/cars/register/{user_id}
abstract interface class IMyCarRepository {
  /// 번호판으로 차량 등록
  Future<MyCar> registerCar({
    required String userId,
    required String licensePlate,
  });

  /// 사용자의 등록 차량 목록 조회
  Future<List<MyCar>> getMyCars(String userId);
}
