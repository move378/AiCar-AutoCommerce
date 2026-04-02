import 'package:aicar/data/datasources/local/tables/bookmark_table.dart';
import 'package:aicar/data/datasources/local/tables/card_cache_table.dart';
import 'package:aicar/data/datasources/local/tables/chat_history_table.dart';
import 'package:aicar/data/datasources/local/tables/survey_session_table.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(
    tables: [SurveySessionTable, CardCacheTable, ChatHistoryTable, BookmarkTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(chatHistoryTable, chatHistoryTable.sessionId);
          }
          if (from < 3) {
            await m.createTable(bookmarkTable);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'aicar_db');
  }
}
