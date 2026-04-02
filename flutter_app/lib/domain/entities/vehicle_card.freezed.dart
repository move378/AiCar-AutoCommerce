// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleCard {
  String get id;
  String get brandName;
  String get modelName;
  int get year;

  /// 가격 (만원 단위)
  int get price;
  String get fuelType;
  String? get imageUrl;
  VehicleSpecs get specs;

  /// Create a copy of VehicleCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VehicleCardCopyWith<VehicleCard> get copyWith =>
      _$VehicleCardCopyWithImpl<VehicleCard>(this as VehicleCard, _$identity);

  /// Serializes this VehicleCard to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VehicleCard &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.specs, specs) || other.specs == specs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, brandName, modelName, year,
      price, fuelType, imageUrl, specs);

  @override
  String toString() {
    return 'VehicleCard(id: $id, brandName: $brandName, modelName: $modelName, year: $year, price: $price, fuelType: $fuelType, imageUrl: $imageUrl, specs: $specs)';
  }
}

/// @nodoc
abstract mixin class $VehicleCardCopyWith<$Res> {
  factory $VehicleCardCopyWith(
          VehicleCard value, $Res Function(VehicleCard) _then) =
      _$VehicleCardCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String brandName,
      String modelName,
      int year,
      int price,
      String fuelType,
      String? imageUrl,
      VehicleSpecs specs});

  $VehicleSpecsCopyWith<$Res> get specs;
}

/// @nodoc
class _$VehicleCardCopyWithImpl<$Res> implements $VehicleCardCopyWith<$Res> {
  _$VehicleCardCopyWithImpl(this._self, this._then);

  final VehicleCard _self;
  final $Res Function(VehicleCard) _then;

  /// Create a copy of VehicleCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brandName = null,
    Object? modelName = null,
    Object? year = null,
    Object? price = null,
    Object? fuelType = null,
    Object? imageUrl = freezed,
    Object? specs = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _self.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      modelName: null == modelName
          ? _self.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
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
      specs: null == specs
          ? _self.specs
          : specs // ignore: cast_nullable_to_non_nullable
              as VehicleSpecs,
    ));
  }

  /// Create a copy of VehicleCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VehicleSpecsCopyWith<$Res> get specs {
    return $VehicleSpecsCopyWith<$Res>(_self.specs, (value) {
      return _then(_self.copyWith(specs: value));
    });
  }
}

/// Adds pattern-matching-related methods to [VehicleCard].
extension VehicleCardPatterns on VehicleCard {
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
    TResult Function(_VehicleCard value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VehicleCard() when $default != null:
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
    TResult Function(_VehicleCard value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleCard():
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
    TResult? Function(_VehicleCard value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleCard() when $default != null:
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
    TResult Function(String id, String brandName, String modelName, int year,
            int price, String fuelType, String? imageUrl, VehicleSpecs specs)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VehicleCard() when $default != null:
        return $default(_that.id, _that.brandName, _that.modelName, _that.year,
            _that.price, _that.fuelType, _that.imageUrl, _that.specs);
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
    TResult Function(String id, String brandName, String modelName, int year,
            int price, String fuelType, String? imageUrl, VehicleSpecs specs)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleCard():
        return $default(_that.id, _that.brandName, _that.modelName, _that.year,
            _that.price, _that.fuelType, _that.imageUrl, _that.specs);
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
    TResult? Function(String id, String brandName, String modelName, int year,
            int price, String fuelType, String? imageUrl, VehicleSpecs specs)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleCard() when $default != null:
        return $default(_that.id, _that.brandName, _that.modelName, _that.year,
            _that.price, _that.fuelType, _that.imageUrl, _that.specs);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VehicleCard extends VehicleCard {
  const _VehicleCard(
      {required this.id,
      required this.brandName,
      required this.modelName,
      required this.year,
      required this.price,
      required this.fuelType,
      this.imageUrl,
      required this.specs})
      : super._();
  factory _VehicleCard.fromJson(Map<String, dynamic> json) =>
      _$VehicleCardFromJson(json);

  @override
  final String id;
  @override
  final String brandName;
  @override
  final String modelName;
  @override
  final int year;

  /// 가격 (만원 단위)
  @override
  final int price;
  @override
  final String fuelType;
  @override
  final String? imageUrl;
  @override
  final VehicleSpecs specs;

  /// Create a copy of VehicleCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VehicleCardCopyWith<_VehicleCard> get copyWith =>
      __$VehicleCardCopyWithImpl<_VehicleCard>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VehicleCardToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VehicleCard &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brandName, brandName) ||
                other.brandName == brandName) &&
            (identical(other.modelName, modelName) ||
                other.modelName == modelName) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.specs, specs) || other.specs == specs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, brandName, modelName, year,
      price, fuelType, imageUrl, specs);

  @override
  String toString() {
    return 'VehicleCard(id: $id, brandName: $brandName, modelName: $modelName, year: $year, price: $price, fuelType: $fuelType, imageUrl: $imageUrl, specs: $specs)';
  }
}

/// @nodoc
abstract mixin class _$VehicleCardCopyWith<$Res>
    implements $VehicleCardCopyWith<$Res> {
  factory _$VehicleCardCopyWith(
          _VehicleCard value, $Res Function(_VehicleCard) _then) =
      __$VehicleCardCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String brandName,
      String modelName,
      int year,
      int price,
      String fuelType,
      String? imageUrl,
      VehicleSpecs specs});

  @override
  $VehicleSpecsCopyWith<$Res> get specs;
}

/// @nodoc
class __$VehicleCardCopyWithImpl<$Res> implements _$VehicleCardCopyWith<$Res> {
  __$VehicleCardCopyWithImpl(this._self, this._then);

  final _VehicleCard _self;
  final $Res Function(_VehicleCard) _then;

  /// Create a copy of VehicleCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? brandName = null,
    Object? modelName = null,
    Object? year = null,
    Object? price = null,
    Object? fuelType = null,
    Object? imageUrl = freezed,
    Object? specs = null,
  }) {
    return _then(_VehicleCard(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brandName: null == brandName
          ? _self.brandName
          : brandName // ignore: cast_nullable_to_non_nullable
              as String,
      modelName: null == modelName
          ? _self.modelName
          : modelName // ignore: cast_nullable_to_non_nullable
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
      specs: null == specs
          ? _self.specs
          : specs // ignore: cast_nullable_to_non_nullable
              as VehicleSpecs,
    ));
  }

  /// Create a copy of VehicleCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VehicleSpecsCopyWith<$Res> get specs {
    return $VehicleSpecsCopyWith<$Res>(_self.specs, (value) {
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
