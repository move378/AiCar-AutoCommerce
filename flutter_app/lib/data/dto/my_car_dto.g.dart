// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_car_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterMyCarRequestDto _$RegisterMyCarRequestDtoFromJson(
        Map<String, dynamic> json) =>
    RegisterMyCarRequestDto(
      userId: json['user_id'] as String,
      licensePlate: json['license_plate'] as String,
    );

Map<String, dynamic> _$RegisterMyCarRequestDtoToJson(
        RegisterMyCarRequestDto instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'license_plate': instance.licensePlate,
    };

MyCarDto _$MyCarDtoFromJson(Map<String, dynamic> json) => MyCarDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      licensePlate: json['license_plate'] as String,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: (json['year'] as num?)?.toInt(),
      fuelType: json['fuel_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MyCarDtoToJson(MyCarDto instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'license_plate': instance.licensePlate,
      'brand': instance.brand,
      'model': instance.model,
      'year': instance.year,
      'fuel_type': instance.fuelType,
      'created_at': instance.createdAt.toIso8601String(),
    };
