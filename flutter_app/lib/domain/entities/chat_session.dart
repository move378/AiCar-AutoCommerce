import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_session.freezed.dart';
part 'chat_session.g.dart';

/// 채팅 세션 (백엔드 연동)
@freezed
abstract class ChatSession with _$ChatSession {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatSession({
    required String id,
    String? title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
}
