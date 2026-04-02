import 'package:drift/drift.dart';

/// 차량 북마크(찜) 테이블 — Drift 영속 저장
class BookmarkTable extends Table {
  @override
  String get tableName => 'bookmarks';

  TextColumn get vehicleId => text()();
  DateTimeColumn get bookmarkedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {vehicleId};
}
