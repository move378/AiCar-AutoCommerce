// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Vehicle {
  String get id;
  String get brand;
  String get model;
  int get year;

  /// 가격 (원 단위 — API 기준)
  int get price;
  String get fuelType;
  String? get imageUrl; // --- 추가 필드 (nullable, CardCacheTable JSON 호환) ---
  String? get trimName;
  String? get transmission;
  int? get engineDisplacement;
  double? get fuelEfficiency;
  String? get status;
  String? get modelId;
  List<VehicleImage>?
      get images; // specs → nullable (Car API에는 power/torque/zeroToHundred 없음)
  VehicleSpecs? get specs;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VehicleCopyWith<Vehicle> get copyWith =>
      _$VehicleCopyWithImpl<Vehicle>(this as Vehicle, _$identity);

  /// Serializes this Vehicle to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Vehicle &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.trimName, trimName) ||
                other.trimName == trimName) &&
            (identical(other.transmission, transmission) ||
                other.transmission == transmission) &&
            (identical(other.engineDisplacement, engineDisplacement) ||
                other.engineDisplacement == engineDisplacement) &&
            (identical(other.fuelEfficiency, fuelEfficiency) ||
                other.fuelEfficiency == fuelEfficiency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            const DeepCollectionEquality().equals(other.images, images) &&
            (identical(other.specs, specs) || other.specs == specs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      brand,
      model,
      year,
      price,
      fuelType,
      imageUrl,
      trimName,
      transmission,
      engineDisplacement,
      fuelEfficiency,
      status,
      modelId,
      const DeepCollectionEquality().hash(images),
      specs);

  @override
  String toString() {
    return 'Vehicle(id: $id, brand: $brand, model: $model, year: $year, price: $price, fuelType: $fuelType, imageUrl: $imageUrl, trimName: $trimName, transmission: $transmission, engineDisplacement: $engineDisplacement, fuelEfficiency: $fuelEfficiency, status: $status, modelId: $modelId, images: $images, specs: $specs)';
  }
}

/// @nodoc
abstract mixin class $VehicleCopyWith<$Res> {
  factory $VehicleCopyWith(Vehicle value, $Res Function(Vehicle) _then) =
      _$VehicleCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String brand,
      String model,
      int year,
      int price,
      String fuelType,
      String? imageUrl,
      String? trimName,
      String? transmission,
      int? engineDisplacement,
      double? fuelEfficiency,
      String? status,
      String? modelId,
      List<VehicleImage>? images,
      VehicleSpecs? specs});

  $VehicleSpecsCopyWith<$Res>? get specs;
}

/// @nodoc
class _$VehicleCopyWithImpl<$Res> implements $VehicleCopyWith<$Res> {
  _$VehicleCopyWithImpl(this._self, this._then);

  final Vehicle _self;
  final $Res Function(Vehicle) _then;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? model = null,
    Object? year = null,
    Object? price = null,
    Object? fuelType = null,
    Object? imageUrl = freezed,
    Object? trimName = freezed,
    Object? transmission = freezed,
    Object? engineDisplacement = freezed,
    Object? fuelEfficiency = freezed,
    Object? status = freezed,
    Object? modelId = freezed,
    Object? images = freezed,
    Object? specs = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _self.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      fuelType: null == fuelType
          ? _self.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      trimName: freezed == trimName
          ? _self.trimName
          : trimName // ignore: cast_nullable_to_non_nullable
              as String?,
      transmission: freezed == transmission
          ? _self.transmission
          : transmission // ignore: cast_nullable_to_non_nullable
              as String?,
      engineDisplacement: freezed == engineDisplacement
          ? _self.engineDisplacement
          : engineDisplacement // ignore: cast_nullable_to_non_nullable
              as int?,
      fuelEfficiency: freezed == fuelEfficiency
          ? _self.fuelEfficiency
          : fuelEfficiency // ignore: cast_nullable_to_non_nullable
              as double?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      modelId: freezed == modelId
          ? _self.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _self.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<VehicleImage>?,
      specs: freezed == specs
          ? _self.specs
          : specs // ignore: cast_nullable_to_non_nullable
              as VehicleSpecs?,
    ));
  }

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VehicleSpecsCopyWith<$Res>? get specs {
    if (_self.specs == null) {
      return null;
    }

    return $VehicleSpecsCopyWith<$Res>(_self.specs!, (value) {
      return _then(_self.copyWith(specs: value));
    });
  }
}

/// Adds pattern-matching-related methods to [Vehicle].
extension VehiclePatterns on Vehicle {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Vehicle value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Vehicle() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Vehicle value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Vehicle():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Vehicle value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Vehicle() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String brand,
            String model,
            int year,
            int price,
            String fuelType,
            String? imageUrl,
            String? trimName,
            String? transmission,
            int? engineDisplacement,
            double? fuelEfficiency,
            String? status,
            String? modelId,
            List<VehicleImage>? images,
            VehicleSpecs? specs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Vehicle() when $default != null:
        return $default(
            _that.id,
            _that.brand,
            _that.model,
            _that.year,
            _that.price,
            _that.fuelType,
            _that.imageUrl,
            _that.trimName,
            _that.transmission,
            _that.engineDisplacement,
            _that.fuelEfficiency,
            _that.status,
            _that.modelId,
            _that.images,
            _that.specs);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String brand,
            String model,
            int year,
            int price,
            String fuelType,
            String? imageUrl,
            String? trimName,
            String? transmission,
            int? engineDisplacement,
            double? fuelEfficiency,
            String? status,
            String? modelId,
            List<VehicleImage>? images,
            VehicleSpecs? specs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Vehicle():
        return $default(
            _that.id,
            _that.brand,
            _that.model,
            _that.year,
            _that.price,
            _that.fuelType,
            _that.imageUrl,
            _that.trimName,
            _that.transmission,
            _that.engineDisplacement,
            _that.fuelEfficiency,
            _that.status,
            _that.modelId,
            _that.images,
            _that.specs);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String brand,
            String model,
            int year,
            int price,
            String fuelType,
            String? imageUrl,
            String? trimName,
            String? transmission,
            int? engineDisplacement,
            double? fuelEfficiency,
            String? status,
            String? modelId,
            List<VehicleImage>? images,
            VehicleSpecs? specs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Vehicle() when $default != null:
        return $default(
            _that.id,
            _that.brand,
            _that.model,
            _that.year,
            _that.price,
            _that.fuelType,
            _that.imageUrl,
            _that.trimName,
            _that.transmission,
            _that.engineDisplacement,
            _that.fuelEfficiency,
            _that.status,
            _that.modelId,
            _that.images,
            _that.specs);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Vehicle extends Vehicle {
  const _Vehicle(
      {required this.id,
      required this.brand,
      required this.model,
      required this.year,
      required this.price,
      required this.fuelType,
      this.imageUrl,
      this.trimName,
      this.transmission,
      this.engineDisplacement,
      this.fuelEfficiency,
      this.status,
      this.modelId,
      final List<VehicleImage>? images,
      this.specs})
      : _images = images,
        super._();
  factory _Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  @override
  final String id;
  @override
  final String brand;
  @override
  final String model;
  @override
  final int year;

  /// 가격 (원 단위 — API 기준)
  @override
  final int price;
  @override
  final String fuelType;
  @override
  final String? imageUrl;
// --- 추가 필드 (nullable, CardCacheTable JSON 호환) ---
  @override
  final String? trimName;
  @override
  final String? transmission;
  @override
  final int? engineDisplacement;
  @override
  final double? fuelEfficiency;
  @override
  final String? status;
  @override
  final String? modelId;
  final List<VehicleImage>? _images;
  @override
  List<VehicleImage>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// specs → nullable (Car API에는 power/torque/zeroToHundred 없음)
  @override
  final VehicleSpecs? specs;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VehicleCopyWith<_Vehicle> get copyWith =>
      __$VehicleCopyWithImpl<_Vehicle>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VehicleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Vehicle &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.trimName, trimName) ||
                other.trimName == trimName) &&
            (identical(other.transmission, transmission) ||
                other.transmission == transmission) &&
            (identical(other.engineDisplacement, engineDisplacement) ||
                other.engineDisplacement == engineDisplacement) &&
            (identical(other.fuelEfficiency, fuelEfficiency) ||
                other.fuelEfficiency == fuelEfficiency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.modelId, modelId) || other.modelId == modelId) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.specs, specs) || other.specs == specs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      brand,
      model,
      year,
      price,
      fuelType,
      imageUrl,
      trimName,
      transmission,
      engineDisplacement,
      fuelEfficiency,
      status,
      modelId,
      const DeepCollectionEquality().hash(_images),
      specs);

  @override
  String toString() {
    return 'Vehicle(id: $id, brand: $brand, model: $model, year: $year, price: $price, fuelType: $fuelType, imageUrl: $imageUrl, trimName: $trimName, transmission: $transmission, engineDisplacement: $engineDisplacement, fuelEfficiency: $fuelEfficiency, status: $status, modelId: $modelId, images: $images, specs: $specs)';
  }
}

/// @nodoc
abstract mixin class _$VehicleCopyWith<$Res> implements $VehicleCopyWith<$Res> {
  factory _$VehicleCopyWith(_Vehicle value, $Res Function(_Vehicle) _then) =
      __$VehicleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String brand,
      String model,
      int year,
      int price,
      String fuelType,
      String? imageUrl,
      String? trimName,
      String? transmission,
      int? engineDisplacement,
      double? fuelEfficiency,
      String? status,
      String? modelId,
      List<VehicleImage>? images,
      VehicleSpecs? specs});

  @override
  $VehicleSpecsCopyWith<$Res>? get specs;
}

/// @nodoc
class __$VehicleCopyWithImpl<$Res> implements _$VehicleCopyWith<$Res> {
  __$VehicleCopyWithImpl(this._self, this._then);

  final _Vehicle _self;
  final $Res Function(_Vehicle) _then;

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? model = null,
    Object? year = null,
    Object? price = null,
    Object? fuelType = null,
    Object? imageUrl = freezed,
    Object? trimName = freezed,
    Object? transmission = freezed,
    Object? engineDisplacement = freezed,
    Object? fuelEfficiency = freezed,
    Object? status = freezed,
    Object? modelId = freezed,
    Object? images = freezed,
    Object? specs = freezed,
  }) {
    return _then(_Vehicle(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _self.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      model: null == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String,
      year: null == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _self.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      fuelType: null == fuelType
          ? _self.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      trimName: freezed == trimName
          ? _self.trimName
          : trimName // ignore: cast_nullable_to_non_nullable
              as String?,
      transmission: freezed == transmission
          ? _self.transmission
          : transmission // ignore: cast_nullable_to_non_nullable
              as String?,
      engineDisplacement: freezed == engineDisplacement
          ? _self.engineDisplacement
          : engineDisplacement // ignore: cast_nullable_to_non_nullable
              as int?,
      fuelEfficiency: freezed == fuelEfficiency
          ? _self.fuelEfficiency
          : fuelEfficiency // ignore: cast_nullable_to_non_nullable
              as double?,
      status: freezed == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      modelId: freezed == modelId
          ? _self.modelId
          : modelId // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _self._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<VehicleImage>?,
      specs: freezed == specs
          ? _self.specs
          : specs // ignore: cast_nullable_to_non_nullable
              as VehicleSpecs?,
    ));
  }

  /// Create a copy of Vehicle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VehicleSpecsCopyWith<$Res>? get specs {
    if (_self.specs == null) {
      return null;
    }

    return $VehicleSpecsCopyWith<$Res>(_self.specs!, (value) {
      return _then(_self.copyWith(specs: value));
    });
  }
}

/// @nodoc
mixin _$VehicleSpecs {
  /// 마력
  int get power;

  /// 토크 (kgm)
  double get torque;

  /// 연비 (km/L)
  double get fuelEfficiency;

  /// 제로백 (초)
  double get zeroToHundred;

  /// Create a copy of VehicleSpecs
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VehicleSpecsCopyWith<VehicleSpecs> get copyWith =>
      _$VehicleSpecsCopyWithImpl<VehicleSpecs>(
          this as VehicleSpecs, _$identity);

  /// Serializes this VehicleSpecs to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VehicleSpecs &&
            (identical(other.power, power) || other.power == power) &&
            (identical(other.torque, torque) || other.torque == torque) &&
            (identical(other.fuelEfficiency, fuelEfficiency) ||
                other.fuelEfficiency == fuelEfficiency) &&
            (identical(other.zeroToHundred, zeroToHundred) ||
                other.zeroToHundred == zeroToHundred));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, power, torque, fuelEfficiency, zeroToHundred);

  @override
  String toString() {
    return 'VehicleSpecs(power: $power, torque: $torque, fuelEfficiency: $fuelEfficiency, zeroToHundred: $zeroToHundred)';
  }
}

/// @nodoc
abstract mixin class $VehicleSpecsCopyWith<$Res> {
  factory $VehicleSpecsCopyWith(
          VehicleSpecs value, $Res Function(VehicleSpecs) _then) =
      _$VehicleSpecsCopyWithImpl;
  @useResult
  $Res call(
      {int power, double torque, double fuelEfficiency, double zeroToHundred});
}

/// @nodoc
class _$VehicleSpecsCopyWithImpl<$Res> implements $VehicleSpecsCopyWith<$Res> {
  _$VehicleSpecsCopyWithImpl(this._self, this._then);

  final VehicleSpecs _self;
  final $Res Function(VehicleSpecs) _then;

  /// Create a copy of VehicleSpecs
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? power = null,
    Object? torque = null,
    Object? fuelEfficiency = null,
    Object? zeroToHundred = null,
  }) {
    return _then(_self.copyWith(
      power: null == power
          ? _self.power
          : power // ignore: cast_nullable_to_non_nullable
              as int,
      torque: null == torque
          ? _self.torque
          : torque // ignore: cast_nullable_to_non_nullable
              as double,
      fuelEfficiency: null == fuelEfficiency
          ? _self.fuelEfficiency
          : fuelEfficiency // ignore: cast_nullable_to_non_nullable
              as double,
      zeroToHundred: null == zeroToHundred
          ? _self.zeroToHundred
          : zeroToHundred // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [VehicleSpecs].
extension VehicleSpecsPatterns on VehicleSpecs {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_VehicleSpecs value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VehicleSpecs() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_VehicleSpecs value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleSpecs():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_VehicleSpecs value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleSpecs() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int power, double torque, double fuelEfficiency,
            double zeroToHundred)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VehicleSpecs() when $default != null:
        return $default(_that.power, _that.torque, _that.fuelEfficiency,
            _that.zeroToHundred);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int power, double torque, double fuelEfficiency,
            double zeroToHundred)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleSpecs():
        return $default(_that.power, _that.torque, _that.fuelEfficiency,
            _that.zeroToHundred);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int power, double torque, double fuelEfficiency,
            double zeroToHundred)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleSpecs() when $default != null:
        return $default(_that.power, _that.torque, _that.fuelEfficiency,
            _that.zeroToHundred);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VehicleSpecs implements VehicleSpecs {
  const _VehicleSpecs(
      {required this.power,
      required this.torque,
      required this.fuelEfficiency,
      required this.zeroToHundred});
  factory _VehicleSpecs.fromJson(Map<String, dynamic> json) =>
      _$VehicleSpecsFromJson(json);

  /// 마력
  @override
  final int power;

  /// 토크 (kgm)
  @override
  final double torque;

  /// 연비 (km/L)
  @override
  final double fuelEfficiency;

  /// 제로백 (초)
  @override
  final double zeroToHundred;

  /// Create a copy of VehicleSpecs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VehicleSpecsCopyWith<_VehicleSpecs> get copyWith =>
      __$VehicleSpecsCopyWithImpl<_VehicleSpecs>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VehicleSpecsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VehicleSpecs &&
            (identical(other.power, power) || other.power == power) &&
            (identical(other.torque, torque) || other.torque == torque) &&
            (identical(other.fuelEfficiency, fuelEfficiency) ||
                other.fuelEfficiency == fuelEfficiency) &&
            (identical(other.zeroToHundred, zeroToHundred) ||
                other.zeroToHundred == zeroToHundred));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, power, torque, fuelEfficiency, zeroToHundred);

  @override
  String toString() {
    return 'VehicleSpecs(power: $power, torque: $torque, fuelEfficiency: $fuelEfficiency, zeroToHundred: $zeroToHundred)';
  }
}

/// @nodoc
abstract mixin class _$VehicleSpecsCopyWith<$Res>
    implements $VehicleSpecsCopyWith<$Res> {
  factory _$VehicleSpecsCopyWith(
          _VehicleSpecs value, $Res Function(_VehicleSpecs) _then) =
      __$VehicleSpecsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int power, double torque, double fuelEfficiency, double zeroToHundred});
}

/// @nodoc
class __$VehicleSpecsCopyWithImpl<$Res>
    implements _$VehicleSpecsCopyWith<$Res> {
  __$VehicleSpecsCopyWithImpl(this._self, this._then);

  final _VehicleSpecs _self;
  final $Res Function(_VehicleSpecs) _then;

  /// Create a copy of VehicleSpecs
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? power = null,
    Object? torque = null,
    Object? fuelEfficiency = null,
    Object? zeroToHundred = null,
  }) {
    return _then(_VehicleSpecs(
      power: null == power
          ? _self.power
          : power // ignore: cast_nullable_to_non_nullable
              as int,
      torque: null == torque
          ? _self.torque
          : torque // ignore: cast_nullable_to_non_nullable
              as double,
      fuelEfficiency: null == fuelEfficiency
          ? _self.fuelEfficiency
          : fuelEfficiency // ignore: cast_nullable_to_non_nullable
              as double,
      zeroToHundred: null == zeroToHundred
          ? _self.zeroToHundred
          : zeroToHundred // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
