import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';

/// Supabase 백엔드용 채팅 Repository 스텁
///
/// CARL §7: 새 Repository 생성 시 supabase/go_api 양쪽 구현체 필수
/// Go 실패 시 PL이 Supabase 전환 구현 담당
class ChatRepositoryImpl implements IChatRepository {
  @override
  Future<String> getResponse(String userMessage) {
    throw UnimplementedError('Supabase chat not implemented');
  }

  @override
  Future<void> saveMessage(ChatMessage message) {
    throw UnimplementedError('Supabase chat not implemented');
  }

  @override
  Future<List<ChatMessage>> loadHistory() {
    throw UnimplementedError('Supabase chat not implemented');
  }

  @override
  Future<void> clearHistory() {
    throw UnimplementedError('Supabase chat not implemented');
  }

  @override
  Future<List<String>> getSessionIds() {
    throw UnimplementedError('Supabase chat not implemented');
  }

  @override
  Future<List<ChatMessage>> loadSession(String sessionId) {
    throw UnimplementedError('Supabase chat not implemented');
  }

  @override
  Future<void> deleteSession(String sessionId) {
    throw UnimplementedError('Supabase chat not implemented');
  }
}
