# 챗봇 3단계 상담 시스템 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 키워드 매칭 챗봇을 3단계 구조화 질문(칩 선택 + 텍스트 입력) → 차량 추천 카드 흐름으로 교체

**Architecture:** ChatProvider에 ConsultationStep 상태 머신 추가. 1~2단계는 칩 선택 UI, 3단계는 텍스트 입력. 결과는 ConsultationAnswers 기반 클라이언트 필터링으로 차량 추천. 기존 자유 입력 모드는 결과 이후 유지.

**Tech Stack:** Flutter (Riverpod Notifier, 기존 ChatMessage/IChatRepository 재활용)

**Spec:** `docs/superpowers/specs/2026-04-08-google-login-chatbot-images-design.md` §2

---

### Task 1: 상담 데이터 모델 정의

**Files:**
- Create: `flutter_app/lib/domain/entities/consultation_question.dart`

- [ ] **Step 1: ConsultationStep, ConsultationAnswers, ConsultationQuestion 정의**

```dart
/// 상담 단계
enum ConsultationStep {
  /// 1단계: 선호도 & 구매의사
  brand,
  vehicleType,
  budget,

  /// 2단계: 용도 & 라이프스타일
  driver,
  purpose,

  /// 3단계: 주관식
  freeText,

  /// 결과 표시
  result,

  /// 자유 채팅 (결과 이후)
  freeChat,
}

/// 누적된 사용자 답변
class ConsultationAnswers {
  String? brand;
  String? vehicleType;
  String? budgetRange;
  String? driver;
  String? purpose;
  String? freeText;

  /// 필터 조건으로 변환
  /// brand → 브랜드명 매칭
  /// vehicleType → fuelType 또는 model 키워드 매칭
  /// budgetRange → price 범위
  bool matchesVehicle({
    required String vehicleBrand,
    required int vehiclePrice,
    required String vehicleModel,
    required String vehicleFuelType,
  }) {
    if (brand != null && brand != '상관없음') {
      if (!vehicleBrand.toLowerCase().contains(brand!.toLowerCase())) {
        return false;
      }
    }
    if (vehicleType != null && vehicleType != '상관없음') {
      // SUV/세단/쿠페 → model 이름에서 매칭
      final type = vehicleType!.toLowerCase();
      final model = vehicleModel.toLowerCase();
      if (type == 'suv' && !_isSuv(model)) return false;
      if (type == '세단' && !_isSedan(model)) return false;
      if (type == '쿠페' && !_isCoupe(model)) return false;
    }
    if (budgetRange != null && budgetRange != '상관없음') {
      final range = _parseBudgetRange(budgetRange!);
      if (range != null) {
        if (vehiclePrice < range.$1 || vehiclePrice > range.$2) return false;
      }
    }
    return true;
  }

  bool _isSuv(String model) {
    return model.contains('x') ||
        model.contains('gl') ||
        model.contains('q') ||
        model.contains('xc') ||
        model.contains('eq');
  }

  bool _isSedan(String model) {
    return model.contains('시리즈') ||
        model.contains('클래스') ||
        model.contains('a4') ||
        model.contains('a6') ||
        model.contains('es') ||
        model.contains('s60') ||
        model.contains('e ') ||
        model.contains('c ');
  }

  bool _isCoupe(String model) {
    return model.contains('쿠페') ||
        model.contains('coupe') ||
        model.contains('coupé') ||
        model.contains('cle') ||
        model.contains('cla');
  }

  /// "5천~7천" → (50000000, 70000000)
  (int, int)? _parseBudgetRange(String range) {
    if (range.contains('5천~7천')) return (50000000, 70000000);
    if (range.contains('7천~9천')) return (70000000, 90000000);
    if (range.contains('9천~1억')) return (90000000, 100000000);
    return null;
  }
}

/// 질문 정의
class ConsultationQuestion {
  const ConsultationQuestion({
    required this.step,
    required this.question,
    this.choices,
  });

  final ConsultationStep step;
  final String question;

  /// null이면 텍스트 입력 (3단계)
  final List<String>? choices;
}

/// 전체 질문 목록 (순서대로)
const consultationQuestions = [
  ConsultationQuestion(
    step: ConsultationStep.brand,
    question: '어떤 브랜드에 관심이 있으세요?',
    choices: ['벤츠', 'BMW', '아우디', '볼보', '테슬라', '렉서스', '상관없음'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.vehicleType,
    question: '어떤 차종을 선호하세요?',
    choices: ['SUV', '세단', '쿠페', '상관없음'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.budget,
    question: '예산은 어느 정도로 생각하세요?',
    choices: ['5천~7천', '7천~9천', '9천~1억', '상관없음'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.driver,
    question: '주로 누가 운전하시나요?',
    choices: ['본인', '배우자', '가족 공용'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.purpose,
    question: '차량의 주 용도는 무엇인가요?',
    choices: ['출퇴근', '주말 나들이', '장거리 여행', '업무용', '복합'],
  ),
  ConsultationQuestion(
    step: ConsultationStep.freeText,
    question: '차량 구매 시 가장 중요하게 생각하는 점을 자유롭게 알려주세요!',
    choices: null,
  ),
];
```

- [ ] **Step 2: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/domain/entities/consultation_question.dart`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/domain/entities/consultation_question.dart
git commit -m "feat(flutter): 상담 데이터 모델 정의 (ConsultationStep, ConsultationAnswers, ConsultationQuestion)"
```

---

### Task 2: ChoiceChipsBar 위젯 생성

**Files:**
- Create: `flutter_app/lib/presentation/pages/ai_chat/widgets/choice_chips_bar.dart`

- [ ] **Step 1: 칩 선택 바 위젯 작성**

```dart
import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';

/// 상담 질문의 선택지 칩 바
///
/// AI 메시지 아래에 수평 스크롤로 선택지를 표시한다.
/// 사용자가 칩을 탭하면 [onSelected] 콜백에 선택된 텍스트를 전달한다.
class ChoiceChipsBar extends StatelessWidget {
  const ChoiceChipsBar({
    super.key,
    required this.choices,
    required this.onSelected,
  });

  final List<String> choices;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: Wrap(
        spacing: AppSpacing.space2,
        runSpacing: AppSpacing.space2,
        children: choices.map((choice) {
          return GestureDetector(
            onTap: () => onSelected(choice),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space4,
                vertical: AppSpacing.space2,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: AppColors.secondary),
              ),
              child: Text(
                choice,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 2: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/presentation/pages/ai_chat/widgets/choice_chips_bar.dart`
Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add flutter_app/lib/presentation/pages/ai_chat/widgets/choice_chips_bar.dart
git commit -m "feat(flutter): ChoiceChipsBar 위젯 생성"
```

---

### Task 3: ChatState 확장 & ChatProvider 상담 흐름 구현

**Files:**
- Modify: `flutter_app/lib/presentation/pages/ai_chat/providers/chat_provider.dart`

이 Task는 가장 핵심적인 변경입니다. ChatState에 상담 상태를 추가하고, ChatNotifier에 상담 흐름 로직을 구현합니다.

- [ ] **Step 1: import 추가**

파일 상단에 추가:

```dart
import 'package:aicar/domain/entities/consultation_question.dart';
```

- [ ] **Step 2: ChatState 확장**

기존 ChatState를 교체:

```dart
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

  /// 현재 상담 단계
  final ConsultationStep consultationStep;

  /// 현재 표시할 선택지 (null이면 칩 미표시)
  final List<String>? currentChoices;

  /// 상담 모드 (false면 자유 채팅)
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
```

- [ ] **Step 3: ChatNotifier 교체**

전체 ChatNotifier를 교체:

```dart
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

    // 새 세션: 인사 + 첫 질문으로 시작
    Future.microtask(() => _startConsultation());

    return const ChatState();
  }

  /// 상담 흐름 시작 — 인사 메시지 + 첫 질문
  Future<void> _startConsultation() async {
    final greeting = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.assistant,
      content: '안녕하세요! 에이카 AI 상담사입니다.\n맞춤 차량을 추천해 드릴게요!',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(messages: [greeting]);

    // 첫 질문 (브랜드)
    await _askQuestion(ConsultationStep.brand);
  }

  /// 현재 단계의 질문을 AI 메시지로 추가
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
  }

  /// 칩 선택 처리
  Future<void> handleChoice(String choice) async {
    if (state.isStreaming) return;

    _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();

    // 사용자 답변을 메시지로 추가
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: ChatRole.user,
      content: choice,
      createdAt: DateTime.now(),
      sessionId: _currentSessionId,
    );

    // 칩 숨기기 + 사용자 메시지 추가
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      currentChoices: () => null,
    );

    // 답변 저장
    _saveAnswer(state.consultationStep, choice);

    // 다음 단계로 이동
    final nextStep = _getNextStep(state.consultationStep);
    if (nextStep == ConsultationStep.result) {
      await _showResults();
    } else {
      await _askQuestion(nextStep);
    }
  }

  /// 3단계 주관식 답변 처리
  Future<void> sendFreeTextAnswer(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;

    _currentSessionId ??= DateTime.now().millisecondsSinceEpoch.toString();

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

    _answers.freeText = text.trim();

    await _showResults();
  }

  /// 기존 자유 채팅 메시지 (결과 이후)
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;

    // 상담 모드 중 freeText 단계면 주관식 답변 처리
    if (state.isConsultationMode &&
        state.consultationStep == ConsultationStep.freeText) {
      return sendFreeTextAnswer(text);
    }

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

    // 키워드 매칭 응답 (기존 로직)
    final responseText = await _repository.getResponse(text);

    // 스트리밍 효과
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

  /// 추천 결과 표시
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
  }

  /// 답변을 ConsultationAnswers에 저장
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

  /// 다음 상담 단계 반환
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

  /// ConsultationAnswers getter (InlineCardCarousel에서 사용)
  ConsultationAnswers get answers => _answers;

  /// 새 세션 시작
  void startNewSession() {
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

  /// 대화 기록 초기화
  Future<void> clearHistory() async {
    _streamingTimer?.cancel();
    _streamingTimer = null;
    _currentSessionId = null;
    await _repository.clearHistory();
    state = const ChatState();
  }
}
```

- [ ] **Step 4: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/presentation/pages/ai_chat/providers/chat_provider.dart`
Expected: 에러 없음

- [ ] **Step 5: 커밋**

```bash
git add flutter_app/lib/presentation/pages/ai_chat/providers/chat_provider.dart
git commit -m "feat(flutter): ChatProvider에 3단계 상담 흐름 구현"
```

---

### Task 4: AiChatPage UI 업데이트 — 칩 선택 + 상담 흐름

**Files:**
- Modify: `flutter_app/lib/presentation/pages/ai_chat/ai_chat_page.dart`

- [ ] **Step 1: import 추가**

파일 상단에 추가:

```dart
import 'package:aicar/domain/entities/consultation_question.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/choice_chips_bar.dart';
```

- [ ] **Step 2: _buildEmptyState 교체**

빈 상태는 더 이상 필요 없음 (상담이 자동 시작되므로). 기존 `_buildEmptyState()` 메서드를 간단하게 교체:

```dart
  Widget _buildEmptyState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
```

- [ ] **Step 3: _buildQuickActions를 _buildChoiceChips로 교체**

기존 `_buildQuickActions()` 메서드를 삭제하고 교체:

```dart
  Widget _buildChoiceChips(ChatState chatState) {
    if (chatState.currentChoices == null || chatState.currentChoices!.isEmpty) {
      return const SizedBox.shrink();
    }

    return ChoiceChipsBar(
      choices: chatState.currentChoices!,
      onSelected: (choice) {
        ref.read(chatProvider.notifier).handleChoice(choice);
      },
    );
  }
```

- [ ] **Step 4: build 메서드의 body Column 업데이트**

build 메서드 안의 Column children을 교체:

```dart
        children: [
          // 헤더
          AiCarHeader(
            title: 'AI 상담',
            actions: [
              IconButton(
                onPressed: () => context.pushNamed(RouteNames.chatHistory),
                icon: const Icon(
                  Icons.history_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              IconButton(
                onPressed: () {
                  ref.read(chatProvider.notifier).startNewSession();
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // 메시지 리스트
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : _buildMessageList(chatState),
          ),

          // 선택지 칩 (상담 모드)
          _buildChoiceChips(chatState),

          // 하단 입력바
          _buildInputBar(chatState),
        ],
```

- [ ] **Step 5: _buildInputBar 수정**

입력바의 enabled 조건을 상담 모드에 따라 변경:

```dart
  Widget _buildInputBar(ChatState chatState) {
    // 상담 모드에서 칩 선택 단계면 입력 비활성화
    final isChipStep = chatState.isConsultationMode &&
        chatState.consultationStep != ConsultationStep.freeText &&
        chatState.consultationStep != ConsultationStep.freeChat;
    final isDisabled = chatState.isStreaming || isChipStep;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.textDisabled, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  enabled: !isDisabled,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: isChipStep
                        ? '위 선택지를 탭하세요'
                        : '메시지를 입력하세요',
                    hintStyle: AppTypography.bodyMd.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space3,
                      vertical: AppSpacing.space2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.space2),
              AiCarButton(
                label: '',
                onPressed:
                    _hasText && !isDisabled ? _sendMessage : null,
                size: AiCarButtonSize.sm,
                style: AiCarButtonStyle.solid,
                trailingIcon: Icons.send_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 6: _buildMessageList에서 추천 카드 표시 조건 업데이트**

기존 `_isRecommendationResponse`를 교체하여 상담 결과 메시지에서도 카드가 표시되도록:

```dart
  /// AI 응답이 차량 추천 내용인지 판별
  bool _isRecommendationResponse(String content) {
    return content.contains('추천해 드릴게요') ||
        content.contains('추천드립니다') ||
        content.contains('안내해 드릴게요');
  }
```

- [ ] **Step 7: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/presentation/pages/ai_chat/`
Expected: 에러 없음

- [ ] **Step 8: 커밋**

```bash
git add flutter_app/lib/presentation/pages/ai_chat/ai_chat_page.dart
git commit -m "feat(flutter): AiChatPage 상담 칩 선택 UI 적용"
```

---

### Task 5: InlineCardCarousel 필터링 로직 업데이트

**Files:**
- Modify: `flutter_app/lib/presentation/pages/ai_chat/widgets/inline_card_carousel.dart:28-47`

상담 결과에서는 ConsultationAnswers 기반 필터링으로 차량을 추천합니다.

- [ ] **Step 1: import 추가**

```dart
import 'package:aicar/domain/entities/consultation_question.dart';
import 'package:aicar/presentation/pages/ai_chat/providers/chat_provider.dart';
```

- [ ] **Step 2: 생성자에 answers 파라미터 추가**

```dart
class InlineCardCarousel extends ConsumerStatefulWidget {
  const InlineCardCarousel({
    super.key,
    required this.query,
    this.answers,
  });

  final String query;
  final ConsultationAnswers? answers;

  @override
  ConsumerState<InlineCardCarousel> createState() =>
      _InlineCardCarouselState();
}
```

- [ ] **Step 3: _loadCards 메서드에 answers 필터링 추가**

```dart
  Future<void> _loadCards() async {
    final repo = ref.read(vehicleRepositoryProvider);

    List<Vehicle> cards;
    if (widget.answers != null) {
      // 상담 결과: 전체 조회 후 클라이언트 필터링
      final all = await repo.getAllVehicles(size: 100);
      cards = all.where((v) {
        return widget.answers!.matchesVehicle(
          vehicleBrand: v.brand,
          vehiclePrice: v.price,
          vehicleModel: v.model,
          vehicleFuelType: v.fuelType,
        );
      }).toList();

      // 필터 결과가 없으면 전체에서 상위 5개
      if (cards.isEmpty) {
        cards = all.take(5).toList();
      }
    } else {
      // 기존 키워드 검색
      cards = await repo.searchVehicles(widget.query);
    }

    if (mounted) {
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    }
  }
```

- [ ] **Step 4: AiChatPage에서 InlineCardCarousel에 answers 전달**

`ai_chat_page.dart`의 `_buildMessageList`에서 InlineCardCarousel 호출 부분을 수정:

```dart
            if (message.isAssistant && _isRecommendationResponse(message.content))
              InlineCardCarousel(
                query: _findUserQuery(messages, reversedIndex),
                answers: ref.read(chatProvider.notifier).answers,
              ),
```

- [ ] **Step 5: analyze 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze lib/presentation/pages/ai_chat/`
Expected: 에러 없음

- [ ] **Step 6: 커밋**

```bash
git add flutter_app/lib/presentation/pages/ai_chat/widgets/inline_card_carousel.dart flutter_app/lib/presentation/pages/ai_chat/ai_chat_page.dart
git commit -m "feat(flutter): InlineCardCarousel 상담 답변 기반 필터링 추가"
```

---

### Task 6: 전체 통합 검증

**Files:** (변경 없음, 검증만)

- [ ] **Step 1: flutter analyze 전체 실행**

Run: `cd /Users/lims/AiCar/flutter_app && flutter analyze`
Expected: 기존 에러 1개 (widget_test.dart) 외 신규 에러 없음

- [ ] **Step 2: 빌드 확인**

Run: `cd /Users/lims/AiCar/flutter_app && flutter build apk --debug 2>&1 | tail -5`
Expected: "Built build/app/outputs/flutter-apk/app-debug.apk" 성공

- [ ] **Step 3: 동작 시나리오 확인 (수동)**

에뮬레이터 또는 실기기에서:
1. 챗봇 탭 진입 → 인사 메시지 + 브랜드 질문 + 칩 표시 확인
2. 브랜드 칩 탭 → 사용자 버블 + 차종 질문 + 칩 표시 확인
3. 차종 → 예산 → 운전자 → 용도 순서로 칩 탭
4. 주관식 질문 → 텍스트 입력 → 전송
5. 추천 카드 캐러셀 표시 확인
6. 이후 자유 입력 채팅 동작 확인

- [ ] **Step 4: 최종 커밋 (필요 시)**

```bash
git add -A
git commit -m "feat(flutter): 챗봇 3단계 상담 시스템 통합 완료"
```
