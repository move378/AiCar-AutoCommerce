// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleImage _$VehicleImageFromJson(Map<String, dynamic> json) =>
    _VehicleImage(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      isThumbnail: json['is_thumbnail'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VehicleImageToJson(_VehicleImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'image_url': instance.imageUrl,
      'is_thumbnail': instance.isThumbnail,
      'sort_order': instance.sortOrder,
    };
