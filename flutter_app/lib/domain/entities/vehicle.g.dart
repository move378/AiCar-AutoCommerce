// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Vehicle _$VehicleFromJson(Map<String, dynamic> json) => _Vehicle(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      fuelType: json['fuel_type'] as String,
      imageUrl: json['image_url'] as String?,
      trimName: json['trim_name'] as String?,
      transmission: json['transmission'] as String?,
      engineDisplacement: (json['engine_displacement'] as num?)?.toInt(),
      fuelEfficiency: (json['fuel_efficiency'] as num?)?.toDouble(),
      status: json['status'] as String?,
      modelId: json['model_id'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => VehicleImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      specs: json['specs'] == null
          ? null
          : VehicleSpecs.fromJson(json['specs'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VehicleToJson(_Vehicle instance) => <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'model': instance.model,
      'year': instance.year,
      'price': instance.price,
      'fuel_type': instance.fuelType,
      'image_url': instance.imageUrl,
      'trim_name': instance.trimName,
      'transmission': instance.transmission,
      'engine_displacement': instance.engineDisplacement,
      'fuel_efficiency': instance.fuelEfficiency,
      'status': instance.status,
      'model_id': instance.modelId,
      'images': instance.images,
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
