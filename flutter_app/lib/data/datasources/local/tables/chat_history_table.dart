import 'package:drift/drift.dart';

class ChatHistoryTable extends Table {
  @override
  String get tableName => 'chat_history';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get role => text()(); // 'user' | 'assistant'
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime()();
}
