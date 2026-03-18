import 'package:aicar/data/datasources/local/tables/card_cache_table.dart';
import 'package:aicar/data/datasources/local/tables/chat_history_table.dart';
import 'package:aicar/data/datasources/local/tables/survey_session_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [SurveySessionTable, CardCacheTable, ChatHistoryTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'aicar_db');
  }
}
