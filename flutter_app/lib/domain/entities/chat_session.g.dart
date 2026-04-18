// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) => _ChatSession(
      id: json['id'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      messageCount: (json['message_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ChatSessionToJson(_ChatSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'message_count': instance.messageCount,
    };
