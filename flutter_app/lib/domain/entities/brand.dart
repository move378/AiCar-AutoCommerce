import 'package:freezed_annotation/freezed_annotation.dart';

part 'brand.freezed.dart';
part 'brand.g.dart';

/// 브랜드 엔티티
@freezed
abstract class Brand with _$Brand {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Brand({
    required String id,
    required String name,
  }) = _Brand;

  factory Brand.fromJson(Map<String, dynamic> json) => _$BrandFromJson(json);
}
