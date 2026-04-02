import 'package:aicar/data/datasources/local/app_database.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:drift/drift.dart';

/// ChatHistoryTableData ↔ ChatMessage 변환
abstract final class ChatMessageMapper {
  /// Drift → Domain
  static ChatMessage fromDrift(ChatHistoryTableData data) {
    return ChatMessage(
      id: data.id.toString(),
      role: data.role == 'user' ? ChatRole.user : ChatRole.assistant,
      content: data.content,
      createdAt: data.createdAt,
      sessionId: data.sessionId,
    );
  }

  /// Domain → Drift (insert용 Companion)
  static ChatHistoryTableCompanion toDrift(ChatMessage message) {
    return ChatHistoryTableCompanion.insert(
      role: message.role.name,
      content: message.content,
      createdAt: message.createdAt,
      sessionId: Value(message.sessionId),
    );
  }
}
