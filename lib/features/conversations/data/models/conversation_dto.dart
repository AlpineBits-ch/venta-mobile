import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/format/api_date_time.dart';

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
  @ApiDateTimeConverter()
  const factory ConversationDto({
    required String id,
    String? name,
    required List<ConversationMemberDto> members,
    required ConversationEncryption encryptionState,

    /// When the group icon was last written, or null when there is none.
    ///
    /// Doubles as the icon URL's cache key. The address is derived from the
    /// conversation id and so says nothing about the image behind it - without
    /// a stamp on the query string, a replaced icon would keep serving the old
    /// bytes out of the image cache for as long as the app lives.
    DateTime? iconUpdatedAt,
  }) = _ConversationDto;

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);
}
