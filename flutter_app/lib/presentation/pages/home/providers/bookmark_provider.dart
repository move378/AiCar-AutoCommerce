import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/domain/repositories/i_bookmark_repository.dart';

/// 북마크 상태
@immutable
class BookmarkState {
  const BookmarkState({
    this.bookmarkedIds = const {},
    this.isLoading = false,
  });

  final Set<String> bookmarkedIds;
  final bool isLoading;

  BookmarkState copyWith({
    Set<String>? bookmarkedIds,
    bool? isLoading,
  }) {
    return BookmarkState(
      bookmarkedIds: bookmarkedIds ?? this.bookmarkedIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 북마크 상태 관리 Notifier (Drift 영속 저장)
class BookmarkNotifier extends Notifier<BookmarkState> {
  late final IBookmarkRepository _repository;

  @override
  BookmarkState build() {
    _repository = ref.read(bookmarkRepositoryProvider);
    _loadBookmarks();
    return const BookmarkState(isLoading: true);
  }

  Future<void> _loadBookmarks() async {
    final ids = await _repository.getBookmarkedIds();
    state = state.copyWith(bookmarkedIds: ids, isLoading: false);
  }

  /// 북마크 토글 (있으면 제거, 없으면 추가)
  Future<void> toggleBookmark(String vehicleId) async {
    // Optimistic update
    final current = Set<String>.from(state.bookmarkedIds);
    if (current.contains(vehicleId)) {
      current.remove(vehicleId);
    } else {
      current.add(vehicleId);
    }
    state = state.copyWith(bookmarkedIds: current);

    // Persist
    await _repository.toggleBookmark(vehicleId);
  }

  /// 특정 차량 북마크 여부
  bool isBookmarked(String vehicleId) {
    return state.bookmarkedIds.contains(vehicleId);
  }
}

/// Bookmark Provider
final bookmarkProvider = NotifierProvider<BookmarkNotifier, BookmarkState>(
  BookmarkNotifier.new,
);
