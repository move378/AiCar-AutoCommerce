import 'package:json_annotation/json_annotation.dart';

part 'my_car_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterMyCarRequestDto {
  const RegisterMyCarRequestDto({
    required this.userId,
    required this.licensePlate,
  });

  final String userId;
  final String licensePlate;

  Map<String, dynamic> toJson() => _$RegisterMyCarRequestDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MyCarDto {
  const MyCarDto({
    required this.id,
    required this.userId,
    required this.licensePlate,
    this.brand,
    this.model,
    this.year,
    this.fuelType,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String licensePlate;
  final String? brand;
  final String? model;
  final int? year;
  final String? fuelType;
  final DateTime createdAt;

  factory MyCarDto.fromJson(Map<String, dynamic> json) =>
      _$MyCarDtoFromJson(json);
}
