import 'package:aicar/data/dto/car_dto.dart';
import 'package:aicar/domain/entities/brand.dart';
import 'package:aicar/domain/entities/vehicle.dart';
import 'package:aicar/domain/entities/vehicle_image.dart';

/// CarDto (API) -> Vehicle (domain) 변환
///
/// 데이터 흐름: GET /cars -> JSON -> CarDto -> CarMapper -> Vehicle
abstract final class CarMapper {
  /// 목록 아이템 변환
  static Vehicle fromDto(CarDto dto) => Vehicle(
        id: dto.id,
        brand: dto.brandName,
        model: dto.modelName,
        year: dto.year,
        price: dto.price,
        fuelType: dto.fuelType ?? '',
        imageUrl: dto.thumbnailUrl,
        trimName: dto.trimName,
        transmission: dto.transmission,
        engineDisplacement: dto.engineDisplacement,
        fuelEfficiency: dto.fuelEfficiency,
        status: dto.status,
        modelId: dto.modelId,
      );

  /// 상세 응답 변환 (이미지 포함)
  static Vehicle fromDetailDto(CarDetailDto dto) => Vehicle(
        id: dto.id,
        brand: dto.brandName,
        model: dto.modelName,
        year: dto.year,
        price: dto.price,
        fuelType: dto.fuelType ?? '',
        imageUrl: dto.thumbnailUrl,
        trimName: dto.trimName,
        transmission: dto.transmission,
        engineDisplacement: dto.engineDisplacement,
        fuelEfficiency: dto.fuelEfficiency,
        status: dto.status,
        modelId: dto.modelId,
        images: dto.images
            ?.map(
              (img) => VehicleImage(
                id: img.id,
                imageUrl: img.imageUrl,
                isThumbnail: img.isThumbnail,
                sortOrder: img.sortOrder,
              ),
            )
            .toList(),
      );

  /// BrandDto -> Brand
  static Brand brandFromDto(BrandDto dto) => Brand(
        id: dto.id,
        name: dto.name,
      );
}
