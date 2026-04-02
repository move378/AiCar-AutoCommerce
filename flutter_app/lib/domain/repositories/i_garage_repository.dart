import 'package:aicar/domain/entities/consultation_card.dart';

/// 가상차고 Repository 인터페이스
///
/// AI 상담 추천 카드를 저장/관리.
/// go_api: Drift 기반 로컬 저장 (MVP)
abstract class IGarageRepository {
  /// 가상차고에 저장
  Future<void> saveToGarage(ConsultationCard card);

  /// 저장된 카드 목록
  Future<List<ConsultationCard>> getSavedCards();

  /// 가상차고에서 제거
  Future<void> removeFromGarage(String cardId);
}
