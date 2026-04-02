import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

/// 챗 메시지 역할
enum ChatRole { user, assistant }

/// AI 상담 채팅 메시지 엔티티
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required ChatRole role,
    required String content,
    required DateTime createdAt,

    /// 05-01에서는 null, 05-02 히스토리 그룹핑 키로 활용 예정
    String? sessionId,
  }) = _ChatMessage;

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
}
