import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_image.freezed.dart';
part 'vehicle_image.g.dart';

/// 차량 이미지
@freezed
abstract class VehicleImage with _$VehicleImage {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VehicleImage({
    required String id,
    required String imageUrl,
    @Default(false) bool isThumbnail,
    @Default(0) int sortOrder,
  }) = _VehicleImage;

  factory VehicleImage.fromJson(Map<String, dynamic> json) =>
      _$VehicleImageFromJson(json);
}
