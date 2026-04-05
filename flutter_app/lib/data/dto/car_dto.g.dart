// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CarDto _$CarDtoFromJson(Map<String, dynamic> json) => CarDto(
      id: json['id'] as String,
      modelId: json['model_id'] as String,
      brandName: json['brand_name'] as String,
      modelName: json['model_name'] as String,
      trimName: json['trim_name'] as String?,
      year: (json['year'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      fuelType: json['fuel_type'] as String?,
      fuelEfficiency: (json['fuel_efficiency'] as num?)?.toDouble(),
      transmission: json['transmission'] as String?,
      engineDisplacement: (json['engine_displacement'] as num?)?.toInt(),
      status: json['status'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );

Map<String, dynamic> _$CarDtoToJson(CarDto instance) => <String, dynamic>{
      'id': instance.id,
      'model_id': instance.modelId,
      'brand_name': instance.brandName,
      'model_name': instance.modelName,
      'trim_name': instance.trimName,
      'year': instance.year,
      'price': instance.price,
      'fuel_type': instance.fuelType,
      'fuel_efficiency': instance.fuelEfficiency,
      'transmission': instance.transmission,
      'engine_displacement': instance.engineDisplacement,
      'status': instance.status,
      'thumbnail_url': instance.thumbnailUrl,
    };

CarDetailDto _$CarDetailDtoFromJson(Map<String, dynamic> json) => CarDetailDto(
      id: json['id'] as String,
      modelId: json['model_id'] as String,
      brandName: json['brand_name'] as String,
      modelName: json['model_name'] as String,
      trimName: json['trim_name'] as String?,
      year: (json['year'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      fuelType: json['fuel_type'] as String?,
      fuelEfficiency: (json['fuel_efficiency'] as num?)?.toDouble(),
      transmission: json['transmission'] as String?,
      engineDisplacement: (json['engine_displacement'] as num?)?.toInt(),
      status: json['status'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => CarImageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CarDetailDtoToJson(CarDetailDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'model_id': instance.modelId,
      'brand_name': instance.brandName,
      'model_name': instance.modelName,
      'trim_name': instance.trimName,
      'year': instance.year,
      'price': instance.price,
      'fuel_type': instance.fuelType,
      'fuel_efficiency': instance.fuelEfficiency,
      'transmission': instance.transmission,
      'engine_displacement': instance.engineDisplacement,
      'status': instance.status,
      'thumbnail_url': instance.thumbnailUrl,
      'images': instance.images,
    };

CarImageDto _$CarImageDtoFromJson(Map<String, dynamic> json) => CarImageDto(
      id: json['id'] as String,
      carId: json['car_id'] as String,
      imageUrl: json['image_url'] as String,
      isThumbnail: json['is_thumbnail'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CarImageDtoToJson(CarImageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'car_id': instance.carId,
      'image_url': instance.imageUrl,
      'is_thumbnail': instance.isThumbnail,
      'sort_order': instance.sortOrder,
    };

BrandDto _$BrandDtoFromJson(Map<String, dynamic> json) => BrandDto(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$BrandDtoToJson(BrandDto instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };
