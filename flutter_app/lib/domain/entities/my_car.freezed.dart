// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_car.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyCar {
  String get id;
  String get userId;
  String get licensePlate;
  String? get brand;
  String? get model;
  int? get year;
  String? get fuelType;
  DateTime get createdAt;

  /// Create a copy of MyCar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MyCarCopyWith<MyCar> get copyWith =>
      _$MyCarCopyWithImpl<MyCar>(this as MyCar, _$identity);

  /// Serializes this MyCar to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MyCar &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.licensePlate, licensePlate) ||
                other.licensePlate == licensePlate) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, licensePlate, brand,
      model, year, fuelType, createdAt);

  @override
  String toString() {
    return 'MyCar(id: $id, userId: $userId, licensePlate: $licensePlate, brand: $brand, model: $model, year: $year, fuelType: $fuelType, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $MyCarCopyWith<$Res> {
  factory $MyCarCopyWith(MyCar value, $Res Function(MyCar) _then) =
      _$MyCarCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String licensePlate,
      String? brand,
      String? model,
      int? year,
      String? fuelType,
      DateTime createdAt});
}

/// @nodoc
class _$MyCarCopyWithImpl<$Res> implements $MyCarCopyWith<$Res> {
  _$MyCarCopyWithImpl(this._self, this._then);

  final MyCar _self;
  final $Res Function(MyCar) _then;

  /// Create a copy of MyCar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? licensePlate = null,
    Object? brand = freezed,
    Object? model = freezed,
    Object? year = freezed,
    Object? fuelType = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      licensePlate: null == licensePlate
          ? _self.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String,
      brand: freezed == brand
          ? _self.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      fuelType: freezed == fuelType
          ? _self.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [MyCar].
extension MyCarPatterns on MyCar {
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
    TResult Function(_MyCar value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MyCar() when $default != null:
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
    TResult Function(_MyCar value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MyCar():
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
    TResult? Function(_MyCar value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MyCar() when $default != null:
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
            String userId,
            String licensePlate,
            String? brand,
            String? model,
            int? year,
            String? fuelType,
            DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MyCar() when $default != null:
        return $default(_that.id, _that.userId, _that.licensePlate, _that.brand,
            _that.model, _that.year, _that.fuelType, _that.createdAt);
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
            String userId,
            String licensePlate,
            String? brand,
            String? model,
            int? year,
            String? fuelType,
            DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MyCar():
        return $default(_that.id, _that.userId, _that.licensePlate, _that.brand,
            _that.model, _that.year, _that.fuelType, _that.createdAt);
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
            String userId,
            String licensePlate,
            String? brand,
            String? model,
            int? year,
            String? fuelType,
            DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MyCar() when $default != null:
        return $default(_that.id, _that.userId, _that.licensePlate, _that.brand,
            _that.model, _that.year, _that.fuelType, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _MyCar implements MyCar {
  const _MyCar(
      {required this.id,
      required this.userId,
      required this.licensePlate,
      this.brand,
      this.model,
      this.year,
      this.fuelType,
      required this.createdAt});
  factory _MyCar.fromJson(Map<String, dynamic> json) => _$MyCarFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String licensePlate;
  @override
  final String? brand;
  @override
  final String? model;
  @override
  final int? year;
  @override
  final String? fuelType;
  @override
  final DateTime createdAt;

  /// Create a copy of MyCar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MyCarCopyWith<_MyCar> get copyWith =>
      __$MyCarCopyWithImpl<_MyCar>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MyCarToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MyCar &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.licensePlate, licensePlate) ||
                other.licensePlate == licensePlate) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.fuelType, fuelType) ||
                other.fuelType == fuelType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, licensePlate, brand,
      model, year, fuelType, createdAt);

  @override
  String toString() {
    return 'MyCar(id: $id, userId: $userId, licensePlate: $licensePlate, brand: $brand, model: $model, year: $year, fuelType: $fuelType, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$MyCarCopyWith<$Res> implements $MyCarCopyWith<$Res> {
  factory _$MyCarCopyWith(_MyCar value, $Res Function(_MyCar) _then) =
      __$MyCarCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String licensePlate,
      String? brand,
      String? model,
      int? year,
      String? fuelType,
      DateTime createdAt});
}

/// @nodoc
class __$MyCarCopyWithImpl<$Res> implements _$MyCarCopyWith<$Res> {
  __$MyCarCopyWithImpl(this._self, this._then);

  final _MyCar _self;
  final $Res Function(_MyCar) _then;

  /// Create a copy of MyCar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? licensePlate = null,
    Object? brand = freezed,
    Object? model = freezed,
    Object? year = freezed,
    Object? fuelType = freezed,
    Object? createdAt = null,
  }) {
    return _then(_MyCar(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      licensePlate: null == licensePlate
          ? _self.licensePlate
          : licensePlate // ignore: cast_nullable_to_non_nullable
              as String,
      brand: freezed == brand
          ? _self.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      model: freezed == model
          ? _self.model
          : model // ignore: cast_nullable_to_non_nullable
              as String?,
      year: freezed == year
          ? _self.year
          : year // ignore: cast_nullable_to_non_nullable
              as int?,
      fuelType: freezed == fuelType
          ? _self.fuelType
          : fuelType // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
