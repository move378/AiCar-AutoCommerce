import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// Go API 백엔드용 차량 Repository 구현체
///
/// MVP: 목업 차량 데이터 10종
/// Post-MVP: Go API 연동
class VehicleRepositoryImpl implements IVehicleRepository {
  static final _mockVehicles = [
    const Vehicle(
      id: 'bmw-3',
      brand: 'BMW',
      model: '320i',
      year: 2025,
      price: 5390,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 184, torque: 30.6, fuelEfficiency: 11.4, zeroToHundred: 7.1,
      ),
    ),
    const Vehicle(
      id: 'bmw-5',
      brand: 'BMW',
      model: '530i',
      year: 2025,
      price: 7190,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 252, torque: 35.7, fuelEfficiency: 10.2, zeroToHundred: 6.1,
      ),
    ),
    const Vehicle(
      id: 'benz-c',
      brand: '메르세데스-벤츠',
      model: 'C 200',
      year: 2025,
      price: 5860,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 204, torque: 30.6, fuelEfficiency: 11.1, zeroToHundred: 7.3,
      ),
    ),
    const Vehicle(
      id: 'benz-e',
      brand: '메르세데스-벤츠',
      model: 'E 300',
      year: 2025,
      price: 8120,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 258, torque: 37.7, fuelEfficiency: 9.8, zeroToHundred: 6.2,
      ),
    ),
    const Vehicle(
      id: 'audi-a4',
      brand: '아우디',
      model: 'A4 40 TFSI',
      year: 2025,
      price: 5470,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 190, torque: 32.6, fuelEfficiency: 11.0, zeroToHundred: 7.3,
      ),
    ),
    const Vehicle(
      id: 'bmw-x3',
      brand: 'BMW',
      model: 'X3 xDrive20i',
      year: 2025,
      price: 6650,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 184, torque: 30.6, fuelEfficiency: 10.6, zeroToHundred: 8.2,
      ),
    ),
    const Vehicle(
      id: 'benz-glc',
      brand: '메르세데스-벤츠',
      model: 'GLC 300',
      year: 2025,
      price: 7310,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 258, torque: 37.7, fuelEfficiency: 9.5, zeroToHundred: 6.2,
      ),
    ),
    const Vehicle(
      id: 'audi-q5',
      brand: '아우디',
      model: 'Q5 45 TFSI',
      year: 2025,
      price: 6980,
      fuelType: '가솔린',
      specs: VehicleSpecs(
        power: 265, torque: 37.7, fuelEfficiency: 9.2, zeroToHundred: 5.9,
      ),
    ),
    const Vehicle(
      id: 'lexus-es',
      brand: '렉서스',
      model: 'ES 300h',
      year: 2025,
      price: 5990,
      fuelType: '하이브리드',
      specs: VehicleSpecs(
        power: 218, torque: 22.5, fuelEfficiency: 18.1, zeroToHundred: 8.9,
      ),
    ),
    const Vehicle(
      id: 'volvo-xc60',
      brand: '볼보',
      model: 'XC60 B5',
      year: 2025,
      price: 6390,
      fuelType: '가솔린(MHEV)',
      specs: VehicleSpecs(
        power: 250, torque: 35.7, fuelEfficiency: 10.0, zeroToHundred: 6.7,
      ),
    ),
  ];

  @override
  Future<List<Vehicle>> getAllVehicles() async {
    return List.of(_mockVehicles);
  }

  @override
  Future<List<Vehicle>> searchVehicles(String query) async {
    final lower = query.toLowerCase();

    // 브랜드 필터
    if (lower.contains('bmw')) {
      return _mockVehicles.where((v) => v.brand == 'BMW').toList();
    }
    if (lower.contains('벤츠')) {
      return _mockVehicles
          .where((v) => v.brand == '메르세데스-벤츠')
          .toList();
    }
    if (lower.contains('아우디')) {
      return _mockVehicles.where((v) => v.brand == '아우디').toList();
    }

    // 차종 필터
    if (lower.contains('suv')) {
      return _mockVehicles
          .where((v) =>
              v.model.contains('X') ||
              v.model.contains('GL') ||
              v.model.contains('Q') ||
              v.model.contains('XC'))
          .toList();
    }
    if (lower.contains('세단') || lower.contains('sedan')) {
      return _mockVehicles
          .where((v) =>
              !v.model.contains('X') &&
              !v.model.contains('GL') &&
              !v.model.contains('Q') &&
              !v.model.contains('XC'))
          .toList();
    }

    // 예산 필터
    if (lower.contains('5천') || lower.contains('5000')) {
      return _mockVehicles.where((v) => v.price <= 6000).toList();
    }
    if (lower.contains('7천') || lower.contains('7000')) {
      return _mockVehicles.where((v) => v.price <= 8000).toList();
    }

    // 기본: 전체 반환
    return List.of(_mockVehicles);
  }

  @override
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      return _mockVehicles.firstWhere((v) => v.id == id);
    } on StateError {
      return null;
    }
  }
}
