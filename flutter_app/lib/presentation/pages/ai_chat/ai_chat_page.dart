import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/presentation/pages/ai_chat/providers/chat_provider.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/chat_bubble.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/inline_card_carousel.dart';
import 'package:aicar/presentation/widgets/buttons/aicar_button.dart';
import 'package:aicar/presentation/widgets/chips/aicar_chip.dart';
import 'package:aicar/presentation/router/route_names.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 챗봇 탭 — AI 상담 (키워드 매칭 MVP)
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _messageController = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage([String? overrideText]) {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _messageController.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final isEmpty = chatState.messages.isEmpty && !chatState.isStreaming;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 헤더
          AiCarHeader(
            title: 'AI 상담',
            actions: [
              // 히스토리 버튼
              IconButton(
                onPressed: () => context.pushNamed(RouteNames.chatHistory),
                icon: const Icon(
                  Icons.history_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
              // 새 대화 시작 (기존 대화는 히스토리에 보존)
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

          // 메시지 리스트 또는 빈 상태
          Expanded(
            child: isEmpty
                ? _buildEmptyState()
                : _buildMessageList(chatState),
          ),

          // 퀵 액션 (대화 시작 전에만)
          if (isEmpty) _buildQuickActions(),

          // 하단 입력바
          _buildInputBar(chatState.isStreaming),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            '무엇이든 물어보세요',
            style: AppTypography.headingXl.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.space2),
          Text(
            '수입차 구매에 관한 모든 것을 도와드릴게요',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    final messages = chatState.messages;
    // 스트리밍 중이면 임시 메시지 추가
    final hasStreamingMessage = chatState.isStreaming;
    final totalCount = messages.length + (hasStreamingMessage ? 1 : 0);

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.space2),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        // reverse: true이므로 index 0이 최하단(최신)
        final reversedIndex = totalCount - 1 - index;

        // 스트리밍 메시지 (마지막 항목)
        if (hasStreamingMessage && reversedIndex == totalCount - 1) {
          final streamingMessage = ChatMessage(
            id: 'streaming',
            role: ChatRole.assistant,
            content: chatState.streamingText,
            createdAt: DateTime.now(),
          );
          return ChatBubble(
            message: streamingMessage,
            isStreaming: true,
          );
        }

        final message = messages[reversedIndex];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatBubble(message: message),
            if (message.isAssistant && _isRecommendationResponse(message.content))
              InlineCardCarousel(
                query: _findUserQuery(messages, reversedIndex),
              ),
          ],
        );
      },
    );
  }

  /// AI 응답이 차량 추천 내용인지 판별
  bool _isRecommendationResponse(String content) {
    return content.contains('추천해 드릴게요') ||
        content.contains('안내해 드릴게요');
  }

  /// AI 응답을 트리거한 사용자 메시지에서 쿼리 추출
  ///
  /// AI 응답 텍스트가 아닌 사용자 입력을 그대로 전달하여
  /// VehicleRepositoryImpl.searchVehicles()의 키워드 필터와 정확히 매칭.
  String _findUserQuery(List<ChatMessage> messages, int assistantIndex) {
    for (int i = assistantIndex - 1; i >= 0; i--) {
      if (messages[i].isUser) return messages[i].content;
    }
    return '';
  }

  Widget _buildQuickActions() {
    const quickActions = [
      '5000만원 이하 SUV 추천해줘',
      '유지비 적게 드는 차 뭐야?',
      '가족들과 주말에 나들이 갈 때 쓸 SUV가 필요해요',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: quickActions.map((text) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.space2),
              child: AiCarChip(
                label: text,
                isSelected: false,
                onTap: () => _sendMessage(text),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isStreaming) {
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
                  enabled: !isStreaming,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요',
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
                onPressed: _hasText && !isStreaming ? _sendMessage : null,
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
}
