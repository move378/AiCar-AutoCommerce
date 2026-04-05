import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// Supabase 차량 Repository — UnimplementedError 스텁
class VehicleRepositoryImpl implements IVehicleRepository {
  @override
  Future<List<Vehicle>> getAllVehicles({int page = 1, int size = 20}) =>
      throw UnimplementedError('Supabase vehicle not implemented');

  @override
  Future<List<Vehicle>> searchVehicles(String query,
          {int page = 1, int size = 20}) =>
      throw UnimplementedError('Supabase vehicle not implemented');

  @override
  Future<Vehicle?> getVehicleById(String id) =>
      throw UnimplementedError('Supabase vehicle not implemented');

  @override
  Future<List<Brand>> getBrands() =>
      throw UnimplementedError('Supabase vehicle not implemented');
}
