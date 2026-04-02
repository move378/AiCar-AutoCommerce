import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/data/datasources/local/app_database.dart';

/// AppDatabase Provider — 2+ feature 공유 (chat, garage)
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
