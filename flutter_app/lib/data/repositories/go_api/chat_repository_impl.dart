import 'package:drift/drift.dart';

import 'package:aicar/data/datasources/local/app_database.dart';
import 'package:aicar/data/mappers/chat_message_mapper.dart';
import 'package:aicar/domain/entities/chat_message.dart';
import 'package:aicar/domain/repositories/i_chat_repository.dart';

/// Go API 백엔드용 채팅 Repository 구현체
///
/// MVP: 로컬 키워드 매칭 10 시나리오
/// Post-MVP: Go API → Python RAG 엔드포인트 호출로 교체
class ChatRepositoryImpl implements IChatRepository {
  ChatRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<String> getResponse(String userMessage) async {
    final lower = userMessage.toLowerCase();

    // 1. 예산
    if (_matchesAny(lower, ['3천', '5천', '예산', '가격대', '만원'])) {
      return '예산에 맞는 수입차를 추천해 드릴게요!\n\n'
          '3,000만원대: BMW 3시리즈, 벤츠 A클래스, 아우디 A3\n'
          '5,000만원대: BMW 5시리즈, 벤츠 C클래스, 아우디 A4\n\n'
          '더 자세한 추천을 원하시면 선호하는 차종(세단/SUV)을 알려주세요!';
    }

    // 2. SUV
    if (_matchesAny(lower, ['suv', '에스유브이'])) {
      return '인기 수입 SUV를 추천해 드릴게요!\n\n'
          '컴팩트: BMW X1, 벤츠 GLA, 아우디 Q3\n'
          '중형: BMW X3, 벤츠 GLC, 아우디 Q5\n'
          '대형: BMW X5, 벤츠 GLE, 아우디 Q7\n\n'
          '예산이나 용도를 알려주시면 더 맞춤 추천이 가능해요!';
    }

    // 3. 세단
    if (_matchesAny(lower, ['세단', 'sedan'])) {
      return '인기 수입 세단을 추천해 드릴게요!\n\n'
          '엔트리: BMW 3시리즈, 벤츠 C클래스, 아우디 A4\n'
          '프리미엄: BMW 5시리즈, 벤츠 E클래스, 아우디 A6\n'
          '플래그십: BMW 7시리즈, 벤츠 S클래스, 아우디 A8\n\n'
          '어떤 용도로 사용하실 계획이신가요?';
    }

    // 4. 브랜드
    if (_matchesAny(lower, ['벤츠', 'bmw', '아우디', '포르쉐', '렉서스', '볼보', '재규어'])) {
      final brand = _extractBrand(lower);
      return '$brand의 인기 모델을 안내해 드릴게요!\n\n'
          '해당 브랜드의 세단, SUV, 쿠페 라인업을 확인하실 수 있어요.\n'
          '관심 있는 차종이나 예산을 알려주시면 맞춤 추천해 드릴게요!';
    }

    // 5. 연비/친환경
    if (_matchesAny(lower, ['연비', '하이브리드', '전기차', 'ev', '플러그인'])) {
      return '연비 좋은 수입차를 찾고 계시군요!\n\n'
          '하이브리드: BMW 330e, 벤츠 C300e, 렉서스 ES300h\n'
          '전기차: BMW iX, 벤츠 EQE, 아우디 e-tron\n\n'
          '주행 거리나 충전 환경을 알려주시면 더 정확한 추천이 가능해요!';
    }

    // 6. 가족용
    if (_matchesAny(lower, ['가족', '아이', '패밀리', '7인승', '카시트'])) {
      return '가족용 수입차를 추천해 드릴게요!\n\n'
          '5인승 SUV: BMW X3, 벤츠 GLC, 아우디 Q5\n'
          '7인승: BMW X7, 벤츠 GLS, 볼보 XC90\n\n'
          '아이 연령과 주요 용도(통학/나들이)를 알려주시면 맞춤 추천해 드릴게요!';
    }

    // 7. 출퇴근/도심
    if (_matchesAny(lower, ['출퇴근', '도심', '주차', '컴팩트'])) {
      return '도심 출퇴근용 수입차를 추천해 드릴게요!\n\n'
          '컴팩트: BMW 1시리즈, 벤츠 A클래스, 아우디 A3\n'
          '소형 SUV: BMW X1, 벤츠 GLA, 아우디 Q2\n\n'
          '주차 편의성과 연비를 고려하면 컴팩트 모델이 좋아요!';
    }

    // 8. 시승
    if (_matchesAny(lower, ['시승', '직접', '체험', '타보'])) {
      return '시승 예약을 도와드릴게요!\n\n'
          '원하시는 차량과 지역을 알려주시면\n'
          '가까운 전시장의 시승 일정을 안내해 드릴게요.\n\n'
          '예: "강남에서 BMW X3 시승하고 싶어요"';
    }

    // 9. 견적
    if (_matchesAny(lower, ['견적', '할인', '프로모션', '가격', '얼마'])) {
      return '견적 확인을 도와드릴게요!\n\n'
          '관심 있는 차량 모델을 알려주시면\n'
          '출고가, 옵션별 가격, 현재 프로모션 정보를 안내해 드릴게요.\n\n'
          '예: "벤츠 C클래스 견적 알려줘"';
    }

    // 10. 기본 (매칭 없음)
    return '안녕하세요! 에이카 AI 상담사입니다.\n\n'
        '수입차 구매에 관한 모든 것을 도와드릴게요!\n'
        '예산, 차종, 브랜드, 용도 등을 말씀해 주시면\n'
        '맞춤 추천을 해드릴게요.\n\n'
        '예: "예산 5천만원으로 가족용 SUV 추천해줘"';
  }

  @override
  Future<void> saveMessage(ChatMessage message) async {
    await _db.into(_db.chatHistoryTable).insert(
      ChatMessageMapper.toDrift(message),
    );
  }

  @override
  Future<List<ChatMessage>> loadHistory() async {
    final rows = await (_db.select(_db.chatHistoryTable)
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(ChatMessageMapper.fromDrift).toList();
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_db.chatHistoryTable).go();
  }

  @override
  Future<List<String>> getSessionIds() async {
    final query = _db.selectOnly(_db.chatHistoryTable, distinct: true)
      ..addColumns([_db.chatHistoryTable.sessionId])
      ..where(_db.chatHistoryTable.sessionId.isNotNull())
      ..orderBy([
        OrderingTerm(
          expression: _db.chatHistoryTable.createdAt,
          mode: OrderingMode.desc,
        ),
      ]);

    final rows = await query.get();
    final seen = <String>{};
    final result = <String>[];
    for (final row in rows) {
      final sid = row.read(_db.chatHistoryTable.sessionId);
      if (sid != null && seen.add(sid)) {
        result.add(sid);
      }
    }
    return result;
  }

  @override
  Future<List<ChatMessage>> loadSession(String sessionId) async {
    final rows = await (_db.select(_db.chatHistoryTable)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) => OrderingTerm(
                expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(ChatMessageMapper.fromDrift).toList();
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  String _extractBrand(String text) {
    if (text.contains('벤츠')) return '메르세데스-벤츠';
    if (text.contains('bmw')) return 'BMW';
    if (text.contains('아우디')) return '아우디';
    if (text.contains('포르쉐')) return '포르쉐';
    if (text.contains('렉서스')) return '렉서스';
    if (text.contains('볼보')) return '볼보';
    if (text.contains('재규어')) return '재규어';
    return '해당 브랜드';
  }
}
