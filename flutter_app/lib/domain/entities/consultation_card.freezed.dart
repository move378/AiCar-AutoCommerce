// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConsultationCard {
  String get id;

  /// 참조하는 Vehicle의 ID
  String get vehicleId;

  /// AI가 추천한 이유
  String get recommendReason;

  /// 매칭 점수 (0.0 ~ 1.0)
  double get matchScore;

  /// 사용자 메모
  String? get customNote;

  /// 상담 시점
  DateTime get createdAt;

  /// Create a copy of ConsultationCard
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConsultationCardCopyWith<ConsultationCard> get copyWith =>
      _$ConsultationCardCopyWithImpl<ConsultationCard>(
          this as ConsultationCard, _$identity);

  /// Serializes this ConsultationCard to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConsultationCard &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.recommendReason, recommendReason) ||
                other.recommendReason == recommendReason) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore) &&
            (identical(other.customNote, customNote) ||
                other.customNote == customNote) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, vehicleId, recommendReason,
      matchScore, customNote, createdAt);

  @override
  String toString() {
    return 'ConsultationCard(id: $id, vehicleId: $vehicleId, recommendReason: $recommendReason, matchScore: $matchScore, customNote: $customNote, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $ConsultationCardCopyWith<$Res> {
  factory $ConsultationCardCopyWith(
          ConsultationCard value, $Res Function(ConsultationCard) _then) =
      _$ConsultationCardCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String vehicleId,
      String recommendReason,
      double matchScore,
      String? customNote,
      DateTime createdAt});
}

/// @nodoc
class _$ConsultationCardCopyWithImpl<$Res>
    implements $ConsultationCardCopyWith<$Res> {
  _$ConsultationCardCopyWithImpl(this._self, this._then);

  final ConsultationCard _self;
  final $Res Function(ConsultationCard) _then;

  /// Create a copy of ConsultationCard
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vehicleId = null,
    Object? recommendReason = null,
    Object? matchScore = null,
    Object? customNote = freezed,
    Object? createdAt = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleId: null == vehicleId
          ? _self.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      recommendReason: null == recommendReason
          ? _self.recommendReason
          : recommendReason // ignore: cast_nullable_to_non_nullable
              as String,
      matchScore: null == matchScore
          ? _self.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as double,
      customNote: freezed == customNote
          ? _self.customNote
          : customNote // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [ConsultationCard].
extension ConsultationCardPatterns on ConsultationCard {
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
    TResult Function(_ConsultationCard value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConsultationCard() when $default != null:
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
    TResult Function(_ConsultationCard value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConsultationCard():
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
    TResult? Function(_ConsultationCard value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConsultationCard() when $default != null:
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
    TResult Function(String id, String vehicleId, String recommendReason,
            double matchScore, String? customNote, DateTime createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ConsultationCard() when $default != null:
        return $default(_that.id, _that.vehicleId, _that.recommendReason,
            _that.matchScore, _that.customNote, _that.createdAt);
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
    TResult Function(String id, String vehicleId, String recommendReason,
            double matchScore, String? customNote, DateTime createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConsultationCard():
        return $default(_that.id, _that.vehicleId, _that.recommendReason,
            _that.matchScore, _that.customNote, _that.createdAt);
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
    TResult? Function(String id, String vehicleId, String recommendReason,
            double matchScore, String? customNote, DateTime createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ConsultationCard() when $default != null:
        return $default(_that.id, _that.vehicleId, _that.recommendReason,
            _that.matchScore, _that.customNote, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ConsultationCard implements ConsultationCard {
  const _ConsultationCard(
      {required this.id,
      required this.vehicleId,
      required this.recommendReason,
      required this.matchScore,
      this.customNote,
      required this.createdAt});
  factory _ConsultationCard.fromJson(Map<String, dynamic> json) =>
      _$ConsultationCardFromJson(json);

  @override
  final String id;

  /// 참조하는 Vehicle의 ID
  @override
  final String vehicleId;

  /// AI가 추천한 이유
  @override
  final String recommendReason;

  /// 매칭 점수 (0.0 ~ 1.0)
  @override
  final double matchScore;

  /// 사용자 메모
  @override
  final String? customNote;

  /// 상담 시점
  @override
  final DateTime createdAt;

  /// Create a copy of ConsultationCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConsultationCardCopyWith<_ConsultationCard> get copyWith =>
      __$ConsultationCardCopyWithImpl<_ConsultationCard>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ConsultationCardToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConsultationCard &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vehicleId, vehicleId) ||
                other.vehicleId == vehicleId) &&
            (identical(other.recommendReason, recommendReason) ||
                other.recommendReason == recommendReason) &&
            (identical(other.matchScore, matchScore) ||
                other.matchScore == matchScore) &&
            (identical(other.customNote, customNote) ||
                other.customNote == customNote) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, vehicleId, recommendReason,
      matchScore, customNote, createdAt);

  @override
  String toString() {
    return 'ConsultationCard(id: $id, vehicleId: $vehicleId, recommendReason: $recommendReason, matchScore: $matchScore, customNote: $customNote, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$ConsultationCardCopyWith<$Res>
    implements $ConsultationCardCopyWith<$Res> {
  factory _$ConsultationCardCopyWith(
          _ConsultationCard value, $Res Function(_ConsultationCard) _then) =
      __$ConsultationCardCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String vehicleId,
      String recommendReason,
      double matchScore,
      String? customNote,
      DateTime createdAt});
}

/// @nodoc
class __$ConsultationCardCopyWithImpl<$Res>
    implements _$ConsultationCardCopyWith<$Res> {
  __$ConsultationCardCopyWithImpl(this._self, this._then);

  final _ConsultationCard _self;
  final $Res Function(_ConsultationCard) _then;

  /// Create a copy of ConsultationCard
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? vehicleId = null,
    Object? recommendReason = null,
    Object? matchScore = null,
    Object? customNote = freezed,
    Object? createdAt = null,
  }) {
    return _then(_ConsultationCard(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleId: null == vehicleId
          ? _self.vehicleId
          : vehicleId // ignore: cast_nullable_to_non_nullable
              as String,
      recommendReason: null == recommendReason
          ? _self.recommendReason
          : recommendReason // ignore: cast_nullable_to_non_nullable
              as String,
      matchScore: null == matchScore
          ? _self.matchScore
          : matchScore // ignore: cast_nullable_to_non_nullable
              as double,
      customNote: freezed == customNote
          ? _self.customNote
          : customNote // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
