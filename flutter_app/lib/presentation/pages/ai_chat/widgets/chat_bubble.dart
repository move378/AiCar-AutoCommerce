import 'package:flutter/material.dart';

import 'package:aicar/core/theme/app_colors.dart';
import 'package:aicar/core/theme/app_spacing.dart';
import 'package:aicar/core/theme/app_typography.dart';
import 'package:aicar/domain/entities/chat_message.dart';

/// AI 상담 채팅 버블 위젯
///
/// 사용자 버블: 오른쪽 정렬, primary 배경
/// AI 버블: 왼쪽 정렬, surface 배경
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  final ChatMessage message;

  /// true이면 텍스트 끝에 커서(▍) 깜빡임 표시
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space1,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (isUser) const Spacer(flex: 2),
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.space3),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(10),
                      topRight: const Radius.circular(10),
                      bottomLeft: Radius.circular(isUser ? 10 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 10),
                    ),
                  ),
                  child: isStreaming
                      ? _StreamingText(
                          text: message.content,
                          isUser: isUser,
                        )
                      : Text(
                          message.content,
                          style: AppTypography.bodyMd.copyWith(
                            color: isUser
                                ? AppColors.textOnDark
                                : AppColors.textPrimary,
                          ),
                        ),
                ),
                const SizedBox(height: AppSpacing.space1),
                Text(
                  _formatTime(message.createdAt),
                  style: AppTypography.captionXs.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (!isUser) const Spacer(flex: 2),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// 스트리밍 텍스트 + 커서 깜빡임 애니메이션
class _StreamingText extends StatefulWidget {
  const _StreamingText({
    required this.text,
    required this.isUser,
  });

  final String text;
  final bool isUser;

  @override
  State<_StreamingText> createState() => _StreamingTextState();
}

class _StreamingTextState extends State<_StreamingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorController,
      builder: (context, child) {
        final cursorOpacity = _cursorController.value;
        return RichText(
          text: TextSpan(
            style: AppTypography.bodyMd.copyWith(
              color: widget.isUser
                  ? AppColors.textOnDark
                  : AppColors.textPrimary,
            ),
            children: [
              TextSpan(text: widget.text),
              TextSpan(
                text: '▍',
                style: TextStyle(
                  color: (widget.isUser
                          ? AppColors.textOnDark
                          : AppColors.textPrimary)
                      .withValues(alpha: cursorOpacity),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
