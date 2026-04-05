import 'package:json_annotation/json_annotation.dart';

part 'chat_dto.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ChatSessionDto {
  const ChatSessionDto({
    required this.id,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ChatSessionDto.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ChatMessageDto {
  const ChatMessageDto({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    this.metadata,
    this.feedback,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String? metadata;
  final String? feedback;
  final DateTime createdAt;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateSessionRequestDto {
  const CreateSessionRequestDto({this.title});

  final String? title;

  Map<String, dynamic> toJson() => _$CreateSessionRequestDtoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateMessageRequestDto {
  const CreateMessageRequestDto({
    required this.role,
    required this.content,
    this.metadata,
  });

  final String role;
  final String content;
  final String? metadata;

  Map<String, dynamic> toJson() => _$CreateMessageRequestDtoToJson(this);
}
