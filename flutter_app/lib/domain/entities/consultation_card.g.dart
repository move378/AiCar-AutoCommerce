// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConsultationCard _$ConsultationCardFromJson(Map<String, dynamic> json) =>
    _ConsultationCard(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      recommendReason: json['recommend_reason'] as String,
      matchScore: (json['match_score'] as num).toDouble(),
      customNote: json['custom_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ConsultationCardToJson(_ConsultationCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicle_id': instance.vehicleId,
      'recommend_reason': instance.recommendReason,
      'match_score': instance.matchScore,
      'custom_note': instance.customNote,
      'created_at': instance.createdAt.toIso8601String(),
    };
