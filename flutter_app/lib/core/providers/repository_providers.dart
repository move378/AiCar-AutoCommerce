import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/database_provider.dart';
import 'package:aicar/core/providers/dio_provider.dart';
import 'package:aicar/data/repositories/go_api/auth_repository_impl.dart'
    as go_api_auth;
import 'package:aicar/data/repositories/go_api/bookmark_repository_impl.dart'
    as go_api_bookmark;
import 'package:aicar/data/repositories/go_api/chat_repository_impl.dart'
    as go_api_chat;
import 'package:aicar/data/repositories/go_api/garage_repository_impl.dart'
    as go_api_garage;
import 'package:aicar/data/repositories/go_api/my_car_repository_impl.dart'
    as go_api_mycar;
import 'package:aicar/data/repositories/go_api/vehicle_repository_impl.dart'
    as go_api_vehicle;
import 'package:aicar/domain/repositories/i_auth_repository.dart';
import 'package:aicar/domain/repositories/i_bookmark_repository.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';
import 'package:aicar/domain/repositories/i_garage_repository.dart';
import 'package:aicar/domain/repositories/i_my_car_repository.dart';
import 'package:aicar/domain/repositories/i_vehicle_repository.dart';

/// Auth Repository Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dio = ref.read(dioProvider);
  final tokenStorage = ref.read(tokenStorageProvider);
  return go_api_auth.AuthRepositoryImpl(dio, tokenStorage);
});

/// Vehicle Repository Provider — Go API (/cars 엔드포인트)
final vehicleRepositoryProvider = Provider<IVehicleRepository>((ref) {
  final dio = ref.read(dioProvider);
  return go_api_vehicle.VehicleRepositoryImpl(dio);
});

/// Bookmark Repository Provider — Drift 로컬
final bookmarkRepositoryProvider = Provider<IBookmarkRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return go_api_bookmark.BookmarkRepositoryImpl(db);
});

/// Garage Repository Provider — Drift 로컬
final garageRepositoryProvider = Provider<IGarageRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return go_api_garage.GarageRepositoryImpl(db);
});

/// Chat Repository Provider — 키워드 매칭(로컬) + 세션/메시지(백엔드)
final chatRepositoryProvider = Provider<IChatRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  final dio = ref.read(dioProvider);
  return go_api_chat.ChatRepositoryImpl(db, dio);
});

/// MyCar Repository Provider — Go API (/cars/register 엔드포인트)
final myCarRepositoryProvider = Provider<IMyCarRepository>((ref) {
  final dio = ref.read(dioProvider);
  return go_api_mycar.MyCarRepositoryImpl(dio);
});
