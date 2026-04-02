import 'package:aicar/domain/entities/chat_message.dart';

/// AI 상담 채팅 Repository 인터페이스
///
/// MVP: 키워드 매칭 (go_api 구현체)
/// Post-MVP: Python RAG 엔드포인트 교체
abstract class IChatRepository {
  /// 사용자 메시지에 대한 AI 응답 반환 (키워드 매칭 MVP)
  Future<String> getResponse(String userMessage);

  /// 메시지를 로컬 DB에 저장
  Future<void> saveMessage(ChatMessage message);

  /// 저장된 대화 기록 불러오기
  Future<List<ChatMessage>> loadHistory();

  /// 대화 기록 초기화
  Future<void> clearHistory();

  /// 유니크 세션ID 목록 반환 (최신순)
  Future<List<String>> getSessionIds();

  /// 특정 세션의 메시지 로드
  Future<List<ChatMessage>> loadSession(String sessionId);
}
