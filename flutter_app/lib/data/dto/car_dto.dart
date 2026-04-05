import 'package:json_annotation/json_annotation.dart';

part 'car_dto.g.dart';

/// /cars 목록 응답 아이템
@JsonSerializable(fieldRename: FieldRename.snake)
class CarDto {
  const CarDto({
    required this.id,
    required this.modelId,
    required this.brandName,
    required this.modelName,
    this.trimName,
    required this.year,
    required this.price,
    this.fuelType,
    this.fuelEfficiency,
    this.transmission,
    this.engineDisplacement,
    this.status,
    this.thumbnailUrl,
  });

  final String id;
  final String modelId;
  final String brandName;
  final String modelName;
  final String? trimName;
  final int year;
  final int price;
  final String? fuelType;
  final double? fuelEfficiency;
  final String? transmission;
  final int? engineDisplacement;
  final String? status;
  final String? thumbnailUrl;

  factory CarDto.fromJson(Map<String, dynamic> json) => _$CarDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CarDtoToJson(this);
}

/// /cars/{id} 상세 응답 — 이미지 포함
@JsonSerializable(fieldRename: FieldRename.snake)
class CarDetailDto {
  const CarDetailDto({
    required this.id,
    required this.modelId,
    required this.brandName,
    required this.modelName,
    this.trimName,
    required this.year,
    required this.price,
    this.fuelType,
    this.fuelEfficiency,
    this.transmission,
    this.engineDisplacement,
    this.status,
    this.thumbnailUrl,
    this.images,
  });

  final String id;
  final String modelId;
  final String brandName;
  final String modelName;
  final String? trimName;
  final int year;
  final int price;
  final String? fuelType;
  final double? fuelEfficiency;
  final String? transmission;
  final int? engineDisplacement;
  final String? status;
  final String? thumbnailUrl;
  final List<CarImageDto>? images;

  factory CarDetailDto.fromJson(Map<String, dynamic> json) =>
      _$CarDetailDtoFromJson(json);
}

/// 차량 이미지 DTO
@JsonSerializable(fieldRename: FieldRename.snake)
class CarImageDto {
  const CarImageDto({
    required this.id,
    required this.carId,
    required this.imageUrl,
    this.isThumbnail = false,
    this.sortOrder = 0,
  });

  final String id;
  final String carId;
  final String imageUrl;
  final bool isThumbnail;
  final int sortOrder;

  factory CarImageDto.fromJson(Map<String, dynamic> json) =>
      _$CarImageDtoFromJson(json);
}

/// /brands 응답 아이템
@JsonSerializable(fieldRename: FieldRename.snake)
class BrandDto {
  const BrandDto({required this.id, required this.name});

  final String id;
  final String name;

  factory BrandDto.fromJson(Map<String, dynamic> json) =>
      _$BrandDtoFromJson(json);
}
