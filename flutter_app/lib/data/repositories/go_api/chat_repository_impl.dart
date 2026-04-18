import 'package:drift/drift.dart';

import 'package:aicar/core/constants/api_constants.dart';
import 'package:aicar/data/datasources/local/app_database.dart';
import 'package:aicar/data/dto/chat_dto.dart';
import 'package:aicar/data/mappers/chat_message_mapper.dart';
import 'package:aicar/data/mappers/chat_session_mapper.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/entities/chat_session.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';
import 'package:dio/dio.dart';

/// Go API 채팅 Repository 구현체
///
/// AI 응답: 로컬 키워드 매칭 (MVP)
/// 세션/메시지: 백엔드 API 영속화 + 로컬 Drift 캐시
class ChatRepositoryImpl implements IChatRepository {
  ChatRepositoryImpl(this._db, this._dio);

  final AppDatabase _db;
  final Dio _dio;

  // ─── AI 응답 (로컬 키워드 매칭) ───

  @override
  Future<String> getResponse(String userMessage) async {
    final lower = userMessage.toLowerCase();

    if (_matchesAny(lower, ['3천', '5천', '예산', '가격대', '만원'])) {
      return '예산에 맞는 수입차를 추천해 드릴게요!\n\n'
          '3,000만원대: BMW 3시리즈, 벤츠 A클래스, 아우디 A3\n'
          '5,000만원대: BMW 5시리즈, 벤츠 C클래스, 아우디 A4\n\n'
          '더 자세한 추천을 원하시면 선호하는 차종(세단/SUV)을 알려주세요!';
    }
    if (_matchesAny(lower, ['suv', '에스유브이'])) {
      return '인기 수입 SUV를 추천해 드릴게요!\n\n'
          '컴팩트: BMW X1, 벤츠 GLA, 아우디 Q3\n'
          '중형: BMW X3, 벤츠 GLC, 아우디 Q5\n'
          '대형: BMW X5, 벤츠 GLE, 아우디 Q7';
    }
    if (_matchesAny(lower, ['세단', 'sedan'])) {
      return '인기 수입 세단을 추천해 드릴게요!\n\n'
          '엔트리: BMW 3시리즈, 벤츠 C클래스, 아우디 A4\n'
          '프리미엄: BMW 5시리즈, 벤츠 E클래스, 아우디 A6';
    }
    if (_matchesAny(lower, ['벤츠', 'bmw', '아우디', '렉서스', '볼보'])) {
      final brand = _extractBrand(lower);
      return '$brand의 인기 모델을 안내해 드릴게요!\n\n'
          '관심 있는 차종이나 예산을 알려주시면 맞춤 추천해 드릴게요!';
    }
    if (_matchesAny(lower, ['연비', '하이브리드', '전기차', 'ev'])) {
      return '연비 좋은 수입차를 찾고 계시군요!\n\n'
          '하이브리드: BMW 330e, 렉서스 ES300h\n'
          '전기차: BMW iX, 벤츠 EQE, 아우디 e-tron';
    }
    if (_matchesAny(lower, ['견적', '할인', '프로모션', '가격', '얼마'])) {
      return '견적 확인을 도와드릴게요!\n\n'
          '관심 있는 차량 모델을 알려주시면 가격 정보를 안내해 드릴게요.';
    }

    return '안녕하세요! 에이카 AI 상담사입니다.\n\n'
        '수입차 구매에 관한 모든 것을 도와드릴게요!\n'
        '예산, 차종, 브랜드 등을 말씀해 주세요.';
  }

  // ─── 세션 관리 (백엔드 API) ───

  @override
  Future<ChatSession> createSession({String? title}) async {
    final request = CreateSessionRequestDto(title: title);
    final response = await _dio.post(
      ApiConstants.chatSessions,
      data: request.toJson(),
    );
    final json = response.data as Map<String, dynamic>;
    return ChatApiMapper.sessionFromDto(ChatSessionDto.fromJson(json));
  }

  @override
  Future<List<ChatSession>> getSessions() async {
    final response = await _dio.get(ApiConstants.chatSessions);
    final json = response.data;

    final List<dynamic> items;
    if (json is List) {
      items = json;
    } else if (json is Map<String, dynamic>) {
      items = json['items'] as List<dynamic>? ?? [];
    } else {
      items = [];
    }

    return items
        .map((e) => ChatApiMapper.sessionFromDto(
            ChatSessionDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _dio.delete(ApiConstants.chatSession(sessionId));
  }

  // ─── 메시지 (백엔드 영속화) ───

  @override
  Future<ChatMessage> saveMessage(
      String sessionId, ChatMessage message) async {
    final request = CreateMessageRequestDto(
      role: message.role.name,
      content: message.content,
    );

    final response = await _dio.post(
      ApiConstants.chatMessages(sessionId),
      data: request.toJson(),
    );

    final json = response.data as Map<String, dynamic>;
    final dto = ChatMessageDto.fromJson(json);
    final saved = ChatApiMapper.messageFromDto(dto);

    // 로컬 Drift에도 캐시
    await _db.into(_db.chatHistoryTable).insert(
          ChatMessageMapper.toDrift(saved),
        );

    return saved;
  }

  @override
  Future<List<ChatMessage>> loadMessages(String sessionId) async {
    final response = await _dio.get(ApiConstants.chatMessages(sessionId));
    final json = response.data;

    final List<dynamic> items;
    if (json is List) {
      items = json;
    } else if (json is Map<String, dynamic>) {
      items = json['items'] as List<dynamic>? ?? [];
    } else {
      items = [];
    }

    return items
        .map((e) => ChatApiMapper.messageFromDto(
            ChatMessageDto.fromJson(e as Map<String, dynamic>)))
        .toList();
  }

  // ─── 로컬 (Drift) ───

  @override
  Future<void> saveMessageLocal(ChatMessage message) async {
    await _db.into(_db.chatHistoryTable).insert(
          ChatMessageMapper.toDrift(message),
        );
  }

  @override
  Future<List<ChatMessage>> loadHistory() async {
    final rows = await (_db.select(_db.chatHistoryTable)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(ChatMessageMapper.fromDrift).toList();
  }

  @override
  Future<List<ChatMessage>> loadLocalMessages(String sessionId) async {
    final rows = await (_db.select(_db.chatHistoryTable)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(ChatMessageMapper.fromDrift).toList();
  }

  @override
  Future<List<ChatSession>> getLocalSessions() async {
    // sessionId로 그룹화하여 세션 목록 생성
    final rows = await (_db.select(_db.chatHistoryTable)
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();

    final sessionMap = <String, ChatHistoryTableData>{};
    final sessionCounts = <String, int>{};

    for (final row in rows) {
      final sid = row.sessionId ?? 'unknown';
      sessionCounts[sid] = (sessionCounts[sid] ?? 0) + 1;
      // 첫 번째 메시지(가장 오래된)를 대표로 저장
      sessionMap.putIfAbsent(sid, () => row);
    }

    return sessionMap.entries.map((entry) {
      final row = entry.value;
      return ChatSession(
        id: entry.key,
        title: 'AI 상담',
        createdAt: row.createdAt,
        messageCount: sessionCounts[entry.key] ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> deleteLocalSession(String sessionId) async {
    await (_db.delete(_db.chatHistoryTable)
          ..where((t) => t.sessionId.equals(sessionId)))
        .go();
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_db.chatHistoryTable).go();
  }

  // ─── 유틸 ───

  bool _matchesAny(String text, List<String> keywords) =>
      keywords.any((k) => text.contains(k));

  String _extractBrand(String text) {
    if (text.contains('벤츠')) return '메르세데스-벤츠';
    if (text.contains('bmw')) return 'BMW';
    if (text.contains('아우디')) return '아우디';
    if (text.contains('렉서스')) return '렉서스';
    if (text.contains('볼보')) return '볼보';
    return '해당 브랜드';
  }
}
