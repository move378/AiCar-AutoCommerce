import 'dart:async';

import 'package:aicar/core/providers/auth_provider.dart';
import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/consultation_question.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 채팅 상태
@immutable
class ChatState {
  const ChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.streamingText = '',
    this.consultationStep = ConsultationStep.brand,
    this.currentChoices,
    this.isConsultationMode = true,
  });

  final List<ChatMessage> messages;
  final bool isStreaming;
  final String streamingText;
  final ConsultationStep consultationStep;
  final List<String>? currentChoices;
  final bool isConsultationMode;

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? streamingText,
    ConsultationStep? consultationStep,
    List<String>? Function()? currentChoices,
    bool? isConsultationMode,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      streamingText: streamingText ?? this.streamingText,
      consultationStep: consultationStep ?? this.consultationStep,
      currentChoices:
          currentChoices != null ? currentChoices() : this.currentChoices,
      isConsultationMode: isConsultationMode ?? this.isConsultationMode,
    );
  }
}

/// 채팅 상태 관리 Notifier
class ChatNotifier extends Notifier<ChatState> {
  late final IChatRepository _repository;
  Timer? _streamingTimer;
  String? _currentSessionId;
  final ConsultationAnswers _answers = ConsultationAnswers();

  @override
  ChatState build() {
    _repository = ref.read(chatRepositoryProvider);
    ref.onDispose(() => _streamingTimer?.cancel());
    Future.microtask(() => _startConsultation());
    return const ChatState();
  }

  /// 로그인 상태 확인
  bool get _isLoggedIn => ref.read(authProvider).isLoggedIn;

  /// 백엔드 세션 ID인지 (UUID 형식) vs 로컬 ID인지 판별
  bool get _hasBackendSession =>
      _currentSessionId != null && _currentSessionId!.contains('-');

  /// 백엔드 세션 생성 (로그인 시만, 실패해도 상담 계속 진행)
  Future<void> _ensureBackendSession() async {
    // 이미 백엔드 세션이면 스킵
    if (_hasBackendSession) return;

    if (!_isLoggedIn) {
      _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
      return;
    }

    try {
      final session = await _repository.createSession(title: 'AI 상담');
      _currentSessionId = session.id;
    } catch (e) {
      debugPrint('[ChatProvider] 세션 생성 실패: $e');
      _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    }
  }

  /// 로그인 후 백엔드 세션 업그레이드 (로컬→백엔드)
  Future<void> _upgradeToBackendSession() async {
    if (_hasBackendSession || !_isLoggedIn) return;
    try {
      final session = await _repository.createSession(title: 'AI 상담');
      _currentSessionId = session.id;

      // 기존 메시지들을 백엔드에 저장
      for (final msg in state.messages) {
        try {
          await _repository.saveMessage(_currentSessionId!, msg);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[ChatProvider] 세션 업그레이드 실패: $e');
    }
  }

  /// 메시지를 백엔드에 저장 (백엔드 세션 시만, 실패해도 무시)
  Future<void> _persistMessage(ChatMessage message) async {
    if (!_hasBackendSession) return;
    try {
      await _repository.saveMessage(_currentSessionId!, message);
    } catch (_) {
      // 저장 실패해도 상담 계속 진행
    }
  }

  Future<void> _startConsultation() async {
    await _ensureBackendSession();

    final greeting = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.assistant,
      content: '안녕하세요! 에이카 AI 상담사입니다.\n맞춤 차량을 추천해 드릴게요!',
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );
    state = state.copyWith(messages: [greeting]);
    _persistMessage(greeting);
    await _askQuestion(ConsultationStep.brand);
  }

  Future<void> _askQuestion(ConsultationStep step) async {
    final question = consultationQuestions.firstWhere((q) => q.step == step);
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.assistant,
      content: question.question,
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );
    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      consultationStep: step,
      currentChoices: () => question.choices,
    );
    _persistMessage(aiMessage);
  }

  Future<void> handleChoice(String choice) async {
    if (state.isStreaming) return;
    await _ensureBackendSession();
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: choice,
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      currentChoices: () => null,
    );
    _persistMessage(userMessage);
    _saveAnswer(state.consultationStep, choice);
    final nextStep = _getNextStep(state.consultationStep);
    if (nextStep == ConsultationStep.result) {
      await _showResults();
    } else {
      await _askQuestion(nextStep);
    }
  }

  Future<void> sendFreeTextAnswer(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;
    await _ensureBackendSession();
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      currentChoices: () => null,
    );
    _persistMessage(userMessage);
    _answers.freeText = text.trim();
    await _showResults();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;
    if (state.isConsultationMode &&
        state.consultationStep == ConsultationStep.freeText) {
      return sendFreeTextAnswer(text);
    }
    _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: text.trim(),
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );
    state = state.copyWith(messages: [...state.messages, userMessage]);
    final responseText = await _repository.getResponse(text);
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

  Future<void> _showResults() async {
    state = state.copyWith(
      consultationStep: ConsultationStep.result,
      isConsultationMode: false,
    );
    final aiMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.assistant,
      content: '고객님의 조건에 맞는 차량을 추천드립니다!',
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );
    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      consultationStep: ConsultationStep.freeChat,
    );
    _persistMessage(aiMessage);
  }

  void _saveAnswer(ConsultationStep step, String choice) {
    switch (step) {
      case ConsultationStep.brand:
        _answers.brand = choice;
      case ConsultationStep.vehicleType:
        _answers.vehicleType = choice;
      case ConsultationStep.budget:
        _answers.budgetRange = choice;
      case ConsultationStep.driver:
        _answers.driver = choice;
      case ConsultationStep.purpose:
        _answers.purpose = choice;
      default:
        break;
    }
  }

  ConsultationStep _getNextStep(ConsultationStep current) {
    switch (current) {
      case ConsultationStep.brand:
        return ConsultationStep.vehicleType;
      case ConsultationStep.vehicleType:
        return ConsultationStep.budget;
      case ConsultationStep.budget:
        return ConsultationStep.driver;
      case ConsultationStep.driver:
        return ConsultationStep.purpose;
      case ConsultationStep.purpose:
        return ConsultationStep.freeText;
      case ConsultationStep.freeText:
        return ConsultationStep.result;
      default:
        return ConsultationStep.freeChat;
    }
  }

  ConsultationAnswers get answers => _answers;

  void startNewSession() {
    // 현재 세션이 로컬 ID이고 로그인 상태면, 먼저 백엔드에 저장 시도
    if (!_hasBackendSession && _isLoggedIn && state.messages.isNotEmpty) {
      _upgradeToBackendSession();
    }

    _streamingTimer?.cancel();
    _streamingTimer = null;
    _currentSessionId = null;
    _answers.brand = null;
    _answers.vehicleType = null;
    _answers.budgetRange = null;
    _answers.driver = null;
    _answers.purpose = null;
    _answers.freeText = null;
    state = const ChatState();
    Future.microtask(() => _startConsultation());
  }

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
