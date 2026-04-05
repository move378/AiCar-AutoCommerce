import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/dto/car_dto.dart';
import 'package:aicar/data/mappers/car_mapper.dart';
import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';
import 'package:dio/dio.dart';

/// Go API 차량 Repository 구현체
///
/// 데이터 흐름: GET /cars → JSON → CarDto → CarMapper → Vehicle
class VehicleRepositoryImpl implements IVehicleRepository {
  VehicleRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Vehicle>> getAllVehicles({int page = 1, int size = 20}) async {
    final response = await _dio.get(
      ApiConstants.cars,
      queryParameters: {'page': page, 'size': size},
    );

    final json = response.data as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CarMapper.fromDto(CarDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<List<Vehicle>> searchVehicles(
    String query, {
    int page = 1,
    int size = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.cars,
      queryParameters: {'q': query, 'page': page, 'size': size},
    );

    final json = response.data as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CarMapper.fromDto(CarDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.carDetail(id));
      final json = response.data as Map<String, dynamic>;
      return CarMapper.fromDetailDto(CarDetailDto.fromJson(json));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<List<Brand>> getBrands() async {
    final response = await _dio.get(ApiConstants.brands);
    final json = response.data as Map<String, dynamic>;
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => CarMapper.brandFromDto(
            BrandDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }
}
