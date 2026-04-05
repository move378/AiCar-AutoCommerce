import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/dto/my_car_dto.dart';
import 'package:aicar/data/mappers/my_car_mapper.dart';
import 'package:aicar/domain/entities/my_car.dart';
import 'package:aicar/domain/repositories/i_my_car_repository.dart';
import 'package:dio/dio.dart';

/// Go API 내 차량 Repository 구현체
///
/// 데이터 흐름: 사용자 입력(번호판) → POST /cars/register → MyCar
class MyCarRepositoryImpl implements IMyCarRepository {
  MyCarRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<MyCar> registerCar({
    required String userId,
    required String licensePlate,
  }) async {
    final request = RegisterMyCarRequestDto(
      userId: userId,
      licensePlate: licensePlate,
    );

    final response = await _dio.post(
      ApiConstants.registerCar,
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    return MyCarMapper.fromDto(MyCarDto.fromJson(json));
  }

  @override
  Future<List<MyCar>> getMyCars(String userId) async {
    final response = await _dio.get(ApiConstants.myCars(userId));
    final json = response.data;

    final List<dynamic> items;
    if (json is List) {
      items = json;
    } else if (json is Map<String, dynamic>) {
      items = json['items'] as List<dynamic>? ?? [];
    } else {
      items = [];
    }

    return items
        .map((e) =>
            MyCarMapper.fromDto(MyCarDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }
}
