import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';

/// Supabase 채팅 Repository — UnimplementedError 스텁
class ChatRepositoryImpl implements IChatRepository {
  @override
  Future<String> getResponse(String userMessage) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<ChatSession> createSession({String? title}) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatSession>> getSessions() =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<void> deleteSession(String sessionId) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<ChatMessage> saveMessage(String sessionId, ChatMessage message) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<void> saveMessageLocal(ChatMessage message) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatMessage>> loadHistory() =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatMessage>> loadLocalMessages(String sessionId) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<List<ChatSession>> getLocalSessions() =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<void> deleteLocalSession(String sessionId) =>
      throw UnimplementedError('Supabase chat not implemented');

  @override
  Future<void> clearHistory() =>
      throw UnimplementedError('Supabase chat not implemented');
}
