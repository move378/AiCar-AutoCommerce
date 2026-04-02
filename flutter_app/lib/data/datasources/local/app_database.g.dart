// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SurveySessionTableTable extends SurveySessionTable
    with TableInfo<$SurveySessionTableTable, SurveySessionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurveySessionTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _answersJsonMeta =
      const VerificationMeta('answersJson');
  @override
  late final GeneratedColumn<String> answersJson = GeneratedColumn<String>(
      'answers_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currentStepMeta =
      const VerificationMeta('currentStep');
  @override
  late final GeneratedColumn<int> currentStep = GeneratedColumn<int>(
      'current_step', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, answersJson, currentStep, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'survey_sessions';
  @override
  VerificationContext validateIntegrity(
      Insertable<SurveySessionTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('answers_json')) {
      context.handle(
          _answersJsonMeta,
          answersJson.isAcceptableOrUnknown(
              data['answers_json']!, _answersJsonMeta));
    } else if (isInserting) {
      context.missing(_answersJsonMeta);
    }
    if (data.containsKey('current_step')) {
      context.handle(
          _currentStepMeta,
          currentStep.isAcceptableOrUnknown(
              data['current_step']!, _currentStepMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SurveySessionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurveySessionTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      answersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answers_json'])!,
      currentStep: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_step'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SurveySessionTableTable createAlias(String alias) {
    return $SurveySessionTableTable(attachedDatabase, alias);
  }
}

class SurveySessionTableData extends DataClass
    implements Insertable<SurveySessionTableData> {
  final int id;
  final String sessionId;
  final String answersJson;
  final int currentStep;
  final DateTime updatedAt;
  const SurveySessionTableData(
      {required this.id,
      required this.sessionId,
      required this.answersJson,
      required this.currentStep,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['answers_json'] = Variable<String>(answersJson);
    map['current_step'] = Variable<int>(currentStep);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SurveySessionTableCompanion toCompanion(bool nullToAbsent) {
    return SurveySessionTableCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      answersJson: Value(answersJson),
      currentStep: Value(currentStep),
      updatedAt: Value(updatedAt),
    );
  }

  factory SurveySessionTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurveySessionTableData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      answersJson: serializer.fromJson<String>(json['answersJson']),
      currentStep: serializer.fromJson<int>(json['currentStep']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'answersJson': serializer.toJson<String>(answersJson),
      'currentStep': serializer.toJson<int>(currentStep),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SurveySessionTableData copyWith(
          {int? id,
          String? sessionId,
          String? answersJson,
          int? currentStep,
          DateTime? updatedAt}) =>
      SurveySessionTableData(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        answersJson: answersJson ?? this.answersJson,
        currentStep: currentStep ?? this.currentStep,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SurveySessionTableData copyWithCompanion(SurveySessionTableCompanion data) {
    return SurveySessionTableData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      answersJson:
          data.answersJson.present ? data.answersJson.value : this.answersJson,
      currentStep:
          data.currentStep.present ? data.currentStep.value : this.currentStep,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurveySessionTableData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('answersJson: $answersJson, ')
          ..write('currentStep: $currentStep, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, answersJson, currentStep, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurveySessionTableData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.answersJson == this.answersJson &&
          other.currentStep == this.currentStep &&
          other.updatedAt == this.updatedAt);
}

class SurveySessionTableCompanion
    extends UpdateCompanion<SurveySessionTableData> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<String> answersJson;
  final Value<int> currentStep;
  final Value<DateTime> updatedAt;
  const SurveySessionTableCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.answersJson = const Value.absent(),
    this.currentStep = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SurveySessionTableCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required String answersJson,
    this.currentStep = const Value.absent(),
    required DateTime updatedAt,
  })  : sessionId = Value(sessionId),
        answersJson = Value(answersJson),
        updatedAt = Value(updatedAt);
  static Insertable<SurveySessionTableData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<String>? answersJson,
    Expression<int>? currentStep,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (answersJson != null) 'answers_json': answersJson,
      if (currentStep != null) 'current_step': currentStep,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SurveySessionTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? sessionId,
      Value<String>? answersJson,
      Value<int>? currentStep,
      Value<DateTime>? updatedAt}) {
    return SurveySessionTableCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      answersJson: answersJson ?? this.answersJson,
      currentStep: currentStep ?? this.currentStep,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (answersJson.present) {
      map['answers_json'] = Variable<String>(answersJson.value);
    }
    if (currentStep.present) {
      map['current_step'] = Variable<int>(currentStep.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurveySessionTableCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('answersJson: $answersJson, ')
          ..write('currentStep: $currentStep, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CardCacheTableTable extends CardCacheTable
    with TableInfo<$CardCacheTableTable, CardCacheTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardJsonMeta =
      const VerificationMeta('cardJson');
  @override
  late final GeneratedColumn<String> cardJson = GeneratedColumn<String>(
      'card_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [cardId, cardJson, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_cache';
  @override
  VerificationContext validateIntegrity(Insertable<CardCacheTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('card_json')) {
      context.handle(_cardJsonMeta,
          cardJson.isAcceptableOrUnknown(data['card_json']!, _cardJsonMeta));
    } else if (isInserting) {
      context.missing(_cardJsonMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  CardCacheTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardCacheTableData(
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      cardJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CardCacheTableTable createAlias(String alias) {
    return $CardCacheTableTable(attachedDatabase, alias);
  }
}

class CardCacheTableData extends DataClass
    implements Insertable<CardCacheTableData> {
  final String cardId;
  final String cardJson;
  final DateTime cachedAt;
  const CardCacheTableData(
      {required this.cardId, required this.cardJson, required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['card_json'] = Variable<String>(cardJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CardCacheTableCompanion toCompanion(bool nullToAbsent) {
    return CardCacheTableCompanion(
      cardId: Value(cardId),
      cardJson: Value(cardJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory CardCacheTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardCacheTableData(
      cardId: serializer.fromJson<String>(json['cardId']),
      cardJson: serializer.fromJson<String>(json['cardJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'cardJson': serializer.toJson<String>(cardJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CardCacheTableData copyWith(
          {String? cardId, String? cardJson, DateTime? cachedAt}) =>
      CardCacheTableData(
        cardId: cardId ?? this.cardId,
        cardJson: cardJson ?? this.cardJson,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CardCacheTableData copyWithCompanion(CardCacheTableCompanion data) {
    return CardCacheTableData(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      cardJson: data.cardJson.present ? data.cardJson.value : this.cardJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardCacheTableData(')
          ..write('cardId: $cardId, ')
          ..write('cardJson: $cardJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, cardJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardCacheTableData &&
          other.cardId == this.cardId &&
          other.cardJson == this.cardJson &&
          other.cachedAt == this.cachedAt);
}

class CardCacheTableCompanion extends UpdateCompanion<CardCacheTableData> {
  final Value<String> cardId;
  final Value<String> cardJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CardCacheTableCompanion({
    this.cardId = const Value.absent(),
    this.cardJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardCacheTableCompanion.insert({
    required String cardId,
    required String cardJson,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : cardId = Value(cardId),
        cardJson = Value(cardJson),
        cachedAt = Value(cachedAt);
  static Insertable<CardCacheTableData> custom({
    Expression<String>? cardId,
    Expression<String>? cardJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (cardJson != null) 'card_json': cardJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardCacheTableCompanion copyWith(
      {Value<String>? cardId,
      Value<String>? cardJson,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CardCacheTableCompanion(
      cardId: cardId ?? this.cardId,
      cardJson: cardJson ?? this.cardJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (cardJson.present) {
      map['card_json'] = Variable<String>(cardJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardCacheTableCompanion(')
          ..write('cardId: $cardId, ')
          ..write('cardJson: $cardJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatHistoryTableTable extends ChatHistoryTable
    with TableInfo<$ChatHistoryTableTable, ChatHistoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, role, content, createdAt, sessionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_history';
  @override
  VerificationContext validateIntegrity(
      Insertable<ChatHistoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatHistoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatHistoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id']),
    );
  }

  @override
  $ChatHistoryTableTable createAlias(String alias) {
    return $ChatHistoryTableTable(attachedDatabase, alias);
  }
}

class ChatHistoryTableData extends DataClass
    implements Insertable<ChatHistoryTableData> {
  final int id;
  final String role;
  final String content;
  final DateTime createdAt;
  final String? sessionId;
  const ChatHistoryTableData(
      {required this.id,
      required this.role,
      required this.content,
      required this.createdAt,
      this.sessionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    return map;
  }

  ChatHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return ChatHistoryTableCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
    );
  }

  factory ChatHistoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatHistoryTableData(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sessionId': serializer.toJson<String?>(sessionId),
    };
  }

  ChatHistoryTableData copyWith(
          {int? id,
          String? role,
          String? content,
          DateTime? createdAt,
          Value<String?> sessionId = const Value.absent()}) =>
      ChatHistoryTableData(
        id: id ?? this.id,
        role: role ?? this.role,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        sessionId: sessionId.present ? sessionId.value : this.sessionId,
      );
  ChatHistoryTableData copyWithCompanion(ChatHistoryTableCompanion data) {
    return ChatHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatHistoryTableData(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, role, content, createdAt, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatHistoryTableData &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.sessionId == this.sessionId);
}

class ChatHistoryTableCompanion extends UpdateCompanion<ChatHistoryTableData> {
  final Value<int> id;
  final Value<String> role;
  final Value<String> content;
  final Value<DateTime> createdAt;
  final Value<String?> sessionId;
  const ChatHistoryTableCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  ChatHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    required String content,
    required DateTime createdAt,
    this.sessionId = const Value.absent(),
  })  : role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<ChatHistoryTableData> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<DateTime>? createdAt,
    Expression<String>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  ChatHistoryTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? role,
      Value<String>? content,
      Value<DateTime>? createdAt,
      Value<String?>? sessionId}) {
    return ChatHistoryTableCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SurveySessionTableTable surveySessionTable =
      $SurveySessionTableTable(this);
  late final $CardCacheTableTable cardCacheTable = $CardCacheTableTable(this);
  late final $ChatHistoryTableTable chatHistoryTable =
      $ChatHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [surveySessionTable, cardCacheTable, chatHistoryTable];
}

typedef $$SurveySessionTableTableCreateCompanionBuilder
    = SurveySessionTableCompanion Function({
  Value<int> id,
  required String sessionId,
  required String answersJson,
  Value<int> currentStep,
  required DateTime updatedAt,
});
typedef $$SurveySessionTableTableUpdateCompanionBuilder
    = SurveySessionTableCompanion Function({
  Value<int> id,
  Value<String> sessionId,
  Value<String> answersJson,
  Value<int> currentStep,
  Value<DateTime> updatedAt,
});

class $$SurveySessionTableTableFilterComposer
    extends Composer<_$AppDatabase, $SurveySessionTableTable> {
  $$SurveySessionTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentStep => $composableBuilder(
      column: $table.currentStep, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SurveySessionTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SurveySessionTableTable> {
  $$SurveySessionTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentStep => $composableBuilder(
      column: $table.currentStep, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SurveySessionTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SurveySessionTableTable> {
  $$SurveySessionTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get answersJson => $composableBuilder(
      column: $table.answersJson, builder: (column) => column);

  GeneratedColumn<int> get currentStep => $composableBuilder(
      column: $table.currentStep, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SurveySessionTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SurveySessionTableTable,
    SurveySessionTableData,
    $$SurveySessionTableTableFilterComposer,
    $$SurveySessionTableTableOrderingComposer,
    $$SurveySessionTableTableAnnotationComposer,
    $$SurveySessionTableTableCreateCompanionBuilder,
    $$SurveySessionTableTableUpdateCompanionBuilder,
    (
      SurveySessionTableData,
      BaseReferences<_$AppDatabase, $SurveySessionTableTable,
          SurveySessionTableData>
    ),
    SurveySessionTableData,
    PrefetchHooks Function()> {
  $$SurveySessionTableTableTableManager(
      _$AppDatabase db, $SurveySessionTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurveySessionTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurveySessionTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurveySessionTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<String> answersJson = const Value.absent(),
            Value<int> currentStep = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SurveySessionTableCompanion(
            id: id,
            sessionId: sessionId,
            answersJson: answersJson,
            currentStep: currentStep,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sessionId,
            required String answersJson,
            Value<int> currentStep = const Value.absent(),
            required DateTime updatedAt,
          }) =>
              SurveySessionTableCompanion.insert(
            id: id,
            sessionId: sessionId,
            answersJson: answersJson,
            currentStep: currentStep,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SurveySessionTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SurveySessionTableTable,
    SurveySessionTableData,
    $$SurveySessionTableTableFilterComposer,
    $$SurveySessionTableTableOrderingComposer,
    $$SurveySessionTableTableAnnotationComposer,
    $$SurveySessionTableTableCreateCompanionBuilder,
    $$SurveySessionTableTableUpdateCompanionBuilder,
    (
      SurveySessionTableData,
      BaseReferences<_$AppDatabase, $SurveySessionTableTable,
          SurveySessionTableData>
    ),
    SurveySessionTableData,
    PrefetchHooks Function()>;
typedef $$CardCacheTableTableCreateCompanionBuilder = CardCacheTableCompanion
    Function({
  required String cardId,
  required String cardJson,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$CardCacheTableTableUpdateCompanionBuilder = CardCacheTableCompanion
    Function({
  Value<String> cardId,
  Value<String> cardJson,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CardCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $CardCacheTableTable> {
  $$CardCacheTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardJson => $composableBuilder(
      column: $table.cardJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CardCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CardCacheTableTable> {
  $$CardCacheTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardJson => $composableBuilder(
      column: $table.cardJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CardCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardCacheTableTable> {
  $$CardCacheTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get cardJson =>
      $composableBuilder(column: $table.cardJson, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CardCacheTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardCacheTableTable,
    CardCacheTableData,
    $$CardCacheTableTableFilterComposer,
    $$CardCacheTableTableOrderingComposer,
    $$CardCacheTableTableAnnotationComposer,
    $$CardCacheTableTableCreateCompanionBuilder,
    $$CardCacheTableTableUpdateCompanionBuilder,
    (
      CardCacheTableData,
      BaseReferences<_$AppDatabase, $CardCacheTableTable, CardCacheTableData>
    ),
    CardCacheTableData,
    PrefetchHooks Function()> {
  $$CardCacheTableTableTableManager(
      _$AppDatabase db, $CardCacheTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardCacheTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cardId = const Value.absent(),
            Value<String> cardJson = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardCacheTableCompanion(
            cardId: cardId,
            cardJson: cardJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cardId,
            required String cardJson,
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CardCacheTableCompanion.insert(
            cardId: cardId,
            cardJson: cardJson,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardCacheTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardCacheTableTable,
    CardCacheTableData,
    $$CardCacheTableTableFilterComposer,
    $$CardCacheTableTableOrderingComposer,
    $$CardCacheTableTableAnnotationComposer,
    $$CardCacheTableTableCreateCompanionBuilder,
    $$CardCacheTableTableUpdateCompanionBuilder,
    (
      CardCacheTableData,
      BaseReferences<_$AppDatabase, $CardCacheTableTable, CardCacheTableData>
    ),
    CardCacheTableData,
    PrefetchHooks Function()>;
typedef $$ChatHistoryTableTableCreateCompanionBuilder
    = ChatHistoryTableCompanion Function({
  Value<int> id,
  required String role,
  required String content,
  required DateTime createdAt,
  Value<String?> sessionId,
});
typedef $$ChatHistoryTableTableUpdateCompanionBuilder
    = ChatHistoryTableCompanion Function({
  Value<int> id,
  Value<String> role,
  Value<String> content,
  Value<DateTime> createdAt,
  Value<String?> sessionId,
});

class $$ChatHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatHistoryTableTable> {
  $$ChatHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));
}

class $$ChatHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatHistoryTableTable> {
  $$ChatHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));
}

class $$ChatHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatHistoryTableTable> {
  $$ChatHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);
}

class $$ChatHistoryTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatHistoryTableTable,
    ChatHistoryTableData,
    $$ChatHistoryTableTableFilterComposer,
    $$ChatHistoryTableTableOrderingComposer,
    $$ChatHistoryTableTableAnnotationComposer,
    $$ChatHistoryTableTableCreateCompanionBuilder,
    $$ChatHistoryTableTableUpdateCompanionBuilder,
    (
      ChatHistoryTableData,
      BaseReferences<_$AppDatabase, $ChatHistoryTableTable,
          ChatHistoryTableData>
    ),
    ChatHistoryTableData,
    PrefetchHooks Function()> {
  $$ChatHistoryTableTableTableManager(
      _$AppDatabase db, $ChatHistoryTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatHistoryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatHistoryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatHistoryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> sessionId = const Value.absent(),
          }) =>
              ChatHistoryTableCompanion(
            id: id,
            role: role,
            content: content,
            createdAt: createdAt,
            sessionId: sessionId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String role,
            required String content,
            required DateTime createdAt,
            Value<String?> sessionId = const Value.absent(),
          }) =>
              ChatHistoryTableCompanion.insert(
            id: id,
            role: role,
            content: content,
            createdAt: createdAt,
            sessionId: sessionId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatHistoryTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatHistoryTableTable,
    ChatHistoryTableData,
    $$ChatHistoryTableTableFilterComposer,
    $$ChatHistoryTableTableOrderingComposer,
    $$ChatHistoryTableTableAnnotationComposer,
    $$ChatHistoryTableTableCreateCompanionBuilder,
    $$ChatHistoryTableTableUpdateCompanionBuilder,
    (
      ChatHistoryTableData,
      BaseReferences<_$AppDatabase, $ChatHistoryTableTable,
          ChatHistoryTableData>
    ),
    ChatHistoryTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SurveySessionTableTableTableManager get surveySessionTable =>
      $$SurveySessionTableTableTableManager(_db, _db.surveySessionTable);
  $$CardCacheTableTableTableManager get cardCacheTable =>
      $$CardCacheTableTableTableManager(_db, _db.cardCacheTable);
  $$ChatHistoryTableTableTableManager get chatHistoryTable =>
      $$ChatHistoryTableTableTableManager(_db, _db.chatHistoryTable);
}
