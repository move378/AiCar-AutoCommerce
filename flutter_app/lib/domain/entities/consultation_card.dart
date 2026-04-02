import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation_card.freezed.dart';
part 'consultation_card.g.dart';

/// AI 상담 추천 카드 엔티티 — 상담 맥락 중심
///
/// Vehicle을 vehicleId로 참조 (nested 아님).
/// 챗봇이 추천한 결과를 표현하며, 가상차고에 저장되는 단위.
@freezed
abstract class ConsultationCard with _$ConsultationCard {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ConsultationCard({
    required String id,

    /// 참조하는 Vehicle의 ID
    required String vehicleId,

    /// AI가 추천한 이유
    required String recommendReason,

    /// 매칭 점수 (0.0 ~ 1.0)
    required double matchScore,

    /// 사용자 메모
    String? customNote,

    /// 상담 시점
    required DateTime createdAt,
  }) = _ConsultationCard;

  factory ConsultationCard.fromJson(Map<String, dynamic> json) =>
      _$ConsultationCardFromJson(json);
}
