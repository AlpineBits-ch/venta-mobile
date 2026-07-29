import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_dto.freezed.dart';
part 'conversation_dto.g.dart';

enum ConversationEncryption {
  @JsonValue('Plain')
  plain,
  @JsonValue('Encrypted')
  encrypted,
}

@freezed
sealed class ConversationMemberDto with _$ConversationMemberDto {
  const factory ConversationMemberDto({
    required String id,
    required String userId,
    required String cachedUserName,
    String? lastReadMessageId,
    @Default(0) int mentionCount,
  }) = _ConversationMemberDto;

  factory ConversationMemberDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberDtoFromJson(json);
}

@freezed
sealed class ConversationDto with _$ConversationDto {
  const factory ConversationDto({
    required String id,
    String? name,
    required List<ConversationMemberDto> members,
    required ConversationEncryption encryptionState,
  }) = _ConversationDto;

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);
}
