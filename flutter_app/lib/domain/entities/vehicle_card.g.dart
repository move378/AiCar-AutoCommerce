// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleCard _$VehicleCardFromJson(Map<String, dynamic> json) => _VehicleCard(
      id: json['id'] as String,
      brandName: json['brand_name'] as String,
      modelName: json['model_name'] as String,
      year: (json['year'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      fuelType: json['fuel_type'] as String,
      imageUrl: json['image_url'] as String?,
      specs: VehicleSpecs.fromJson(json['specs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleCardToJson(_VehicleCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand_name': instance.brandName,
      'model_name': instance.modelName,
      'year': instance.year,
      'price': instance.price,
      'fuel_type': instance.fuelType,
      'image_url': instance.imageUrl,
      'specs': instance.specs,
    };

_VehicleSpecs _$VehicleSpecsFromJson(Map<String, dynamic> json) =>
    _VehicleSpecs(
      power: (json['power'] as num).toInt(),
      torque: (json['torque'] as num).toDouble(),
      fuelEfficiency: (json['fuel_efficiency'] as num).toDouble(),
      zeroToHundred: (json['zero_to_hundred'] as num).toDouble(),
    );

Map<String, dynamic> _$VehicleSpecsToJson(_VehicleSpecs instance) =>
    <String, dynamic>{
      'power': instance.power,
      'torque': instance.torque,
      'fuel_efficiency': instance.fuelEfficiency,
      'zero_to_hundred': instance.zeroToHundred,
    };
