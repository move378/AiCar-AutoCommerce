// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSessionDto _$ChatSessionDtoFromJson(Map<String, dynamic> json) =>
    ChatSessionDto(
      id: json['id'] as String,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ChatSessionDtoToJson(ChatSessionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) =>
    ChatMessageDto(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      metadata: json['metadata'] as String?,
      feedback: json['feedback'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ChatMessageDtoToJson(ChatMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'session_id': instance.sessionId,
      'role': instance.role,
      'content': instance.content,
      'metadata': instance.metadata,
      'feedback': instance.feedback,
      'created_at': instance.createdAt.toIso8601String(),
    };

CreateSessionRequestDto _$CreateSessionRequestDtoFromJson(
        Map<String, dynamic> json) =>
    CreateSessionRequestDto(
      title: json['title'] as String?,
    );

Map<String, dynamic> _$CreateSessionRequestDtoToJson(
        CreateSessionRequestDto instance) =>
    <String, dynamic>{
      'title': instance.title,
    };

CreateMessageRequestDto _$CreateMessageRequestDtoFromJson(
        Map<String, dynamic> json) =>
    CreateMessageRequestDto(
      role: json['role'] as String,
      content: json['content'] as String,
      metadata: json['metadata'] as String?,
    );

Map<String, dynamic> _$CreateMessageRequestDtoToJson(
        CreateMessageRequestDto instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'metadata': instance.metadata,
    };
