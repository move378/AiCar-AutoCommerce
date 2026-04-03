import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// Supabase 백엔드용 차량 Repository 스텁
class VehicleRepositoryImpl implements IVehicleRepository {
  @override
  Future<List<Vehicle>> getAllVehicles() {
    throw UnimplementedError('Supabase vehicle not implemented');
  }

  @override
  Future<List<Vehicle>> searchVehicles(String query) {
    throw UnimplementedError('Supabase vehicle not implemented');
  }

  @override
  Future<Vehicle?> getVehicleById(String id) {
    throw UnimplementedError('Supabase vehicle not implemented');
  }
}
