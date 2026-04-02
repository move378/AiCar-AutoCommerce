import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_card.freezed.dart';
part 'vehicle_card.g.dart';

/// 차량 추천 카드 엔티티
@freezed
abstract class VehicleCard with _$VehicleCard {
  const VehicleCard._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VehicleCard({
    required String id,
    required String brandName,
    required String modelName,
    required int year,

    /// 가격 (만원 단위)
    required int price,
    required String fuelType,
    String? imageUrl,
    required VehicleSpecs specs,
  }) = _VehicleCard;

  factory VehicleCard.fromJson(Map<String, dynamic> json) =>
      _$VehicleCardFromJson(json);

  /// 가격 포맷 (예: "4,990만원")
  String get formattedPrice {
    final formatted = price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$formatted만원';
  }
}

/// 차량 스펙
@freezed
abstract class VehicleSpecs with _$VehicleSpecs {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory VehicleSpecs({
    /// 마력
    required int power,

    /// 토크 (kgm)
    required double torque,

    /// 연비 (km/L)
    required double fuelEfficiency,

    /// 제로백 (초)
    required double zeroToHundred,
  }) = _VehicleSpecs;

  factory VehicleSpecs.fromJson(Map<String, dynamic> json) =>
      _$VehicleSpecsFromJson(json);
}
