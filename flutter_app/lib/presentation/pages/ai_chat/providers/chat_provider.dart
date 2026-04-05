import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';

/// 채팅 상태
@immutable
class ChatState {
  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.streamingText = '',
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final String streamingText;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? streamingText,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
    );
  }
}

/// 채팅 상태 관리 Notifier
class ChatNotifier extends Notifier<ChatState> {
  late final IChatRepository _repository;
  Timer? _streamingTimer;
  String? _currentSessionId;

  @override
  ChatState build() {
    _repository = ref.read(chatRepositoryProvider);
    ref.onDispose(() => _streamingTimer?.cancel());

    // 비동기 초기화: 이전 대화 로드
    _loadHistory();

    return const ChatState();
  }

  Future<void> _loadHistory() async {
    final history = await _repository.loadHistory();
    if (history.isNotEmpty) {
      state = state.copyWith(messages: history);
      // 마지막 세션 ID 복원
      _currentSessionId = history.last.sessionId;
    }
  }

  /// 새 세션 시작
  void startNewSession() {
    _currentSessionId = null;
    state = state.copyWith(messages: []);
  }

  /// 메시지 전송 + 키워드 매칭 응답 (스트리밍 효과)
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;

    // 첫 메시지 시 새 세션 생성
    _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();

    // 사용자 메시지 추가
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
    );
    await _repository.saveMessage(_currentSessionId!, userMessage);

    // AI 응답 획득
    final responseText = await _repository.getResponse(text);

    // 스트리밍 효과 시작
    state = state.copyWith(isStreaming: true, streamingText: '');

    int charIndex = 0;
    final completer = Completer<void>();

    _streamingTimer?.cancel();
    _streamingTimer = Timer.periodic(
      const Duration(milliseconds: 30),
      (timer) {
        if (charIndex >= responseText.length) {
          timer.cancel();
          _streamingTimer = null;

          // 완성된 메시지 추가
          final assistantMessage = ChatMessage(
            id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
            role: ChatRole.assistant,
            content: responseText,
            createdAt: DateTime.now(),
            sessionId: _currentSessionId,
          );

          state = state.copyWith(
            messages: [...state.messages, assistantMessage],
            isStreaming: false,
            streamingText: '',
          );

          _repository.saveMessage(_currentSessionId!, assistantMessage);
          completer.complete();
          return;
        }

        charIndex++;
        state = state.copyWith(
          streamingText: responseText.substring(0, charIndex),
        );
      },
    );

    await completer.future;
  }

  /// 대화 기록 초기화
  Future<void> clearHistory() async {
    _streamingTimer?.cancel();
    _streamingTimer = null;
    _currentSessionId = null;
    await _repository.clearHistory();
    state = const ChatState();
  }
}

/// Chat Provider
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
