import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/database_provider.dart';
import 'package:aicar/data/repositories/go_api/bookmark_repository_impl.dart'
    as go_api_bookmark;
import 'package:aicar/data/repositories/go_api/garage_repository_impl.dart'
    as go_api_garage;
import 'package:aicar/data/repositories/go_api/vehicle_repository_impl.dart'
    as go_api_vehicle;
import 'package:aicar/domain/repositories/i_bookmark_repository.dart';
import 'package:aicar/domain/repositories/i_garage_repository.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// Vehicle Repository Provider — go_api 구현체 (MVP)
///
/// 사용처: home, ai_card, ai_chat (3+ features)
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  return go_api_vehicle.VehicleRepositoryImpl();
});

/// Bookmark Repository Provider — go_api 구현체 (MVP)
///
/// 사용처: home (VehicleDetailPage), garage (북마크 탭)
final bookmarkRepositoryProvider = Provider<IBookmarkRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return go_api_bookmark.BookmarkRepositoryImpl(db);
});

/// Garage Repository Provider — go_api 구현체 (MVP)
///
/// 사용처: ai_card (saveToGarage), ai_chat (인라인 저장), garage (가상차고 탭)
final garageRepositoryProvider = Provider<IGarageRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return go_api_garage.GarageRepositoryImpl(db);
});
