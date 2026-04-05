import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aicar/core/providers/repository_providers.dart';
import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/chat_bubble.dart';
import 'package:aicar/presentation/pages/ai_chat/widgets/inline_card_carousel.dart';
import 'package:aicar/presentation/widgets/headers/aicar_header.dart';

/// 상담 히스토리 목록 페이지
class ChatHistoryPage extends ConsumerStatefulWidget {
  const ChatHistoryPage({super.key});

  @override
  ConsumerState<ChatHistoryPage> createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends ConsumerState<ChatHistoryPage> {
  List<_SessionPreview>? _sessions;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final repo = ref.read(chatRepositoryProvider);
    final chatSessions = await repo.getSessions();

    final sessions = <_SessionPreview>[];
    for (final session in chatSessions) {
      final messages = await repo.loadMessages(session.id);
      if (messages.isNotEmpty) {
        final firstUserMessage = messages.firstWhere(
          (m) => m.isUser,
          orElse: () => messages.first,
        );
        sessions.add(_SessionPreview(
          sessionId: session.id,
          preview: session.title ?? firstUserMessage.content,
          date: session.createdAt,
          messageCount: messages.length,
        ));
      } else {
        sessions.add(_SessionPreview(
          sessionId: session.id,
          preview: session.title ?? '새 상담',
          date: session.createdAt,
          messageCount: 0,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.deleteSession(sessionId);
    setState(() {
      _sessions?.removeWhere((s) => s.sessionId == sessionId);
    });
  }

  void _showSessionDetail(String sessionId) async {
    final repo = ref.read(chatRepositoryProvider);
    final messages = await repo.loadMessages(sessionId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Column(
          children: [
            // 핸들 바
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.space3),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.space4),
              child: Text(
                _formatDate(messages.first.createdAt),
                style: AppTypography.headingXl.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: AppSpacing.space4),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ChatBubble(message: message),
                      if (message.isAssistant &&
                          _isRecommendationResponse(message.content))
                        InlineCardCarousel(
                            query: _findUserQuery(messages, index)),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AiCarHeader(
            title: '상담 기록',
            showBack: true,
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sessions == null || _sessions!.isEmpty
                    ? _buildEmptyState()
                    : _buildSessionList(),
          ),
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
            Icons.history_rounded,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpacing.space3),
          Text(
            '아직 상담 기록이 없습니다',
            style: AppTypography.headingXl.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space4),
      itemCount: _sessions!.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space3),
      itemBuilder: (context, index) {
        final session = _sessions![index];
        return _SessionCard(
          session: session,
          onTap: () => _showSessionDetail(session.sessionId),
          onDelete: () => _deleteSession(session.sessionId),
        );
      },
    );
  }

  bool _isRecommendationResponse(String content) {
    return content.contains('추천해 드릴게요') ||
        content.contains('안내해 드릴게요');
  }

  String _findUserQuery(List<ChatMessage> messages, int assistantIndex) {
    for (int i = assistantIndex - 1; i >= 0; i--) {
      if (messages[i].isUser) return messages[i].content;
    }
    return '';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

/// 세션 미리보기 데이터
class _SessionPreview {
  const _SessionPreview({
    required this.sessionId,
    required this.preview,
    required this.date,
    required this.messageCount,
  });

  final String sessionId;
  final String preview;
  final DateTime date;
  final int messageCount;
}

/// 세션 카드 위젯
class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  final _SessionPreview session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(session.date),
                  style: AppTypography.captionXs.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${session.messageCount}개 메시지',
                      style: AppTypography.captionXs.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.space2),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.space2),
            Text(
              session.preview,
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
