import 'package:aicar/domain/entities/vehicle_image.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

/// 차량 정보 엔티티 — 홈 탐색, 차량 스펙 중심
@freezed
abstract class Vehicle with _$Vehicle {
  const Vehicle._();

  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Vehicle({
    required String id,
    required String brand,
    required String model,
    required int year,

    /// 가격 (원 단위 — API 기준)
    required int price,
    required String fuelType,
    String? imageUrl,

    // --- 추가 필드 (nullable, CardCacheTable JSON 호환) ---
    String? trimName,
    String? transmission,
    int? engineDisplacement,
    double? fuelEfficiency,
    String? status,
    String? modelId,
    List<VehicleImage>? images,

    // specs → nullable (Car API에는 power/torque/zeroToHundred 없음)
    VehicleSpecs? specs,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  /// 트림명 우선 표시 (예: "GLC 300 4MATIC")
  /// trimName이 model명을 포함하면 trimName만, 아니면 "model trimName"
  String get displayName {
    if (trimName == null || trimName!.isEmpty) return model;
    // trimName이 이미 model의 핵심 키워드를 포함하면 trimName만 사용
    // 예: model="GLC", trimName="GLC 300 4MATIC" → "GLC 300 4MATIC"
    // 예: model="3 Series", trimName="320i" → "320i"
    return trimName!;
  }

  /// 가격 포맷 (예: "2,300만원")
  String get formattedPrice {
    final inManwon = price ~/ 10000;
    final formatted = inManwon.toString().replaceAllMapped(
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
