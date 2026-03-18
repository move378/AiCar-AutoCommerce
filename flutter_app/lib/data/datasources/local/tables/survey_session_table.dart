import 'package:drift/drift.dart';

class SurveySessionTable extends Table {
  @override
  String get tableName => 'survey_sessions';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  TextColumn get answersJson => text()();
  IntColumn get currentStep => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();
}
