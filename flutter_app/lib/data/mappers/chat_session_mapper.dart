import 'package:aicar/data/dto/chat_dto.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';

/// Chat DTO -> Domain 변환
abstract final class ChatApiMapper {
  /// ChatSessionDto -> ChatSession
  static ChatSession sessionFromDto(ChatSessionDto dto) => ChatSession(
        id: dto.id,
        title: dto.title,
        createdAt: dto.createdAt,
        updatedAt: dto.updatedAt,
      );

  /// ChatMessageDto -> ChatMessage
  static ChatMessage messageFromDto(ChatMessageDto dto) => ChatMessage(
        id: dto.id,
        role: dto.role == 'user' ? ChatRole.user : ChatRole.assistant,
        content: dto.content,
        createdAt: dto.createdAt,
        sessionId: dto.sessionId,
        feedback: dto.feedback,
      );
}
