import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';

/// AI 상담 채팅 Repository 인터페이스
///
/// AI 응답: 로컬 키워드 매칭 (MVP)
/// 세션/메시지: 백엔드 API 영속화
abstract class IChatRepository {
  /// 사용자 메시지에 대한 AI 응답 (로컬 키워드 매칭)
  Future<String> getResponse(String userMessage);

  // --- 세션 관리 (백엔드) ---

  /// 새 세션 생성
  Future<ChatSession> createSession({String? title});

  /// 세션 목록 조회
  Future<List<ChatSession>> getSessions();

  /// 세션 삭제
  Future<void> deleteSession(String sessionId);

  // --- 메시지 (백엔드 영속화) ---

  /// 메시지 저장 (백엔드 API)
  Future<ChatMessage> saveMessage(String sessionId, ChatMessage message);

  /// 세션별 메시지 로드
  Future<List<ChatMessage>> loadMessages(String sessionId);

  // --- 로컬 (Drift) ---

  /// 메시지를 로컬 DB에 저장
  Future<void> saveMessageLocal(ChatMessage message);

  /// 로컬 대화 기록 전체 로드
  Future<List<ChatMessage>> loadHistory();

  /// 세션별 로컬 메시지 로드
  Future<List<ChatMessage>> loadLocalMessages(String sessionId);

  /// 로컬 세션 목록 조회 (sessionId 기준 그룹화)
  Future<List<ChatSession>> getLocalSessions();

  /// 로컬 세션 삭제
  Future<void> deleteLocalSession(String sessionId);

  /// 로컬 대화 기록 초기화
  Future<void> clearHistory();
}
