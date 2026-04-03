import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 최근 본 차량 상태 (인메모리 MVP)
@immutable
class RecentlyViewedState {
  const RecentlyViewedState({
    this.vehicleIds = const [],
  });

  /// 최근 본 순서 (최신 먼저, 최대 20개)
  final List<String> vehicleIds;

  RecentlyViewedState copyWith({List<String>? vehicleIds}) {
    return RecentlyViewedState(
      vehicleIds: vehicleIds ?? this.vehicleIds,
    );
  }
}

/// 최근 본 차량 추적 Notifier
///
/// MVP: 인메모리 (앱 재시작 시 초기화)
/// Post-MVP: Drift 테이블로 영속 저장
class RecentlyViewedNotifier extends Notifier<RecentlyViewedState> {
  static const _maxItems = 20;

  @override
  RecentlyViewedState build() {
    return const RecentlyViewedState();
  }

  /// 차량 조회 기록 추가 (이미 있으면 맨 앞으로 이동)
  void addViewed(String vehicleId) {
    final current = List<String>.from(state.vehicleIds);
    current.remove(vehicleId);
    current.insert(0, vehicleId);
    if (current.length > _maxItems) {
      current.removeRange(_maxItems, current.length);
    }
    state = state.copyWith(vehicleIds: current);
  }
}

/// Recently Viewed Provider
final recentlyViewedProvider =
    NotifierProvider<RecentlyViewedNotifier, RecentlyViewedState>(
  RecentlyViewedNotifier.new,
);
