import 'package:aicar/data/dto/my_car_dto.dart';
import 'package:aicar/domain/entities/my_car.dart';

/// MyCarDto (API) -> MyCar (domain) 변환
abstract final class MyCarMapper {
  static MyCar fromDto(MyCarDto dto) => MyCar(
        id: dto.id,
        userId: dto.userId,
        licensePlate: dto.licensePlate,
        brand: dto.brand,
        model: dto.model,
        year: dto.year,
        fuelType: dto.fuelType,
        createdAt: dto.createdAt,
      );
}
