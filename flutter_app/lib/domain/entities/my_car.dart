import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_car.freezed.dart';
part 'my_car.g.dart';

/// 사용자 등록 차량 (내 차고)
@freezed
abstract class MyCar with _$MyCar {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MyCar({
    required String id,
    required String userId,
    required String licensePlate,
    String? brand,
    String? model,
    int? year,
    String? fuelType,
    required DateTime createdAt,
  }) = _MyCar;

  factory MyCar.fromJson(Map<String, dynamic> json) => _$MyCarFromJson(json);
}
