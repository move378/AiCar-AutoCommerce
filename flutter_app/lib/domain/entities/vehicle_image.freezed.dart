// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleImage {
  String get id;
  String get imageUrl;
  bool get isThumbnail;
  int get sortOrder;

  /// Create a copy of VehicleImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $VehicleImageCopyWith<VehicleImage> get copyWith =>
      _$VehicleImageCopyWithImpl<VehicleImage>(
          this as VehicleImage, _$identity);

  /// Serializes this VehicleImage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is VehicleImage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isThumbnail, isThumbnail) ||
                other.isThumbnail == isThumbnail) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, imageUrl, isThumbnail, sortOrder);

  @override
  String toString() {
    return 'VehicleImage(id: $id, imageUrl: $imageUrl, isThumbnail: $isThumbnail, sortOrder: $sortOrder)';
  }
}

/// @nodoc
abstract mixin class $VehicleImageCopyWith<$Res> {
  factory $VehicleImageCopyWith(
          VehicleImage value, $Res Function(VehicleImage) _then) =
      _$VehicleImageCopyWithImpl;
  @useResult
  $Res call({String id, String imageUrl, bool isThumbnail, int sortOrder});
}

/// @nodoc
class _$VehicleImageCopyWithImpl<$Res> implements $VehicleImageCopyWith<$Res> {
  _$VehicleImageCopyWithImpl(this._self, this._then);

  final VehicleImage _self;
  final $Res Function(VehicleImage) _then;

  /// Create a copy of VehicleImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? isThumbnail = null,
    Object? sortOrder = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isThumbnail: null == isThumbnail
          ? _self.isThumbnail
          : isThumbnail // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [VehicleImage].
extension VehicleImagePatterns on VehicleImage {
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
    TResult Function(_VehicleImage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VehicleImage() when $default != null:
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
    TResult Function(_VehicleImage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleImage():
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
    TResult? Function(_VehicleImage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleImage() when $default != null:
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
            String id, String imageUrl, bool isThumbnail, int sortOrder)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _VehicleImage() when $default != null:
        return $default(
            _that.id, _that.imageUrl, _that.isThumbnail, _that.sortOrder);
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
            String id, String imageUrl, bool isThumbnail, int sortOrder)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleImage():
        return $default(
            _that.id, _that.imageUrl, _that.isThumbnail, _that.sortOrder);
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
            String id, String imageUrl, bool isThumbnail, int sortOrder)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _VehicleImage() when $default != null:
        return $default(
            _that.id, _that.imageUrl, _that.isThumbnail, _that.sortOrder);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _VehicleImage implements VehicleImage {
  const _VehicleImage(
      {required this.id,
      required this.imageUrl,
      this.isThumbnail = false,
      this.sortOrder = 0});
  factory _VehicleImage.fromJson(Map<String, dynamic> json) =>
      _$VehicleImageFromJson(json);

  @override
  final String id;
  @override
  final String imageUrl;
  @override
  @JsonKey()
  final bool isThumbnail;
  @override
  @JsonKey()
  final int sortOrder;

  /// Create a copy of VehicleImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$VehicleImageCopyWith<_VehicleImage> get copyWith =>
      __$VehicleImageCopyWithImpl<_VehicleImage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$VehicleImageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _VehicleImage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isThumbnail, isThumbnail) ||
                other.isThumbnail == isThumbnail) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, imageUrl, isThumbnail, sortOrder);

  @override
  String toString() {
    return 'VehicleImage(id: $id, imageUrl: $imageUrl, isThumbnail: $isThumbnail, sortOrder: $sortOrder)';
  }
}

/// @nodoc
abstract mixin class _$VehicleImageCopyWith<$Res>
    implements $VehicleImageCopyWith<$Res> {
  factory _$VehicleImageCopyWith(
          _VehicleImage value, $Res Function(_VehicleImage) _then) =
      __$VehicleImageCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String imageUrl, bool isThumbnail, int sortOrder});
}

/// @nodoc
class __$VehicleImageCopyWithImpl<$Res>
    implements _$VehicleImageCopyWith<$Res> {
  __$VehicleImageCopyWithImpl(this._self, this._then);

  final _VehicleImage _self;
  final $Res Function(_VehicleImage) _then;

  /// Create a copy of VehicleImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? imageUrl = null,
    Object? isThumbnail = null,
    Object? sortOrder = null,
  }) {
    return _then(_VehicleImage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      isThumbnail: null == isThumbnail
          ? _self.isThumbnail
          : isThumbnail // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
