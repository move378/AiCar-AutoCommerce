import 'package:drift/drift.dart';

class CardCacheTable extends Table {
  @override
  String get tableName => 'card_cache';

  TextColumn get cardId => text()();
  TextColumn get cardJson => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {cardId};
}
