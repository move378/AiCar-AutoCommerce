import 'package:aicar/domain/entities/my_car.dart';
import 'package:aicar/domain/repositories/i_my_car_repository.dart';

/// Supabase 내 차량 Repository — UnimplementedError 스텁
class MyCarRepositoryImpl implements IMyCarRepository {
  @override
  Future<MyCar> registerCar({
    required String userId,
    required String licensePlate,
  }) =>
      throw UnimplementedError('Supabase my_car not implemented');

  @override
  Future<List<MyCar>> getMyCars(String userId) =>
      throw UnimplementedError('Supabase my_car not implemented');
}
