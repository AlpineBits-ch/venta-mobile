import 'package:freezed_annotation/freezed_annotation.dart';

part 'bot_command_dto.freezed.dart';
part 'bot_command_dto.g.dart';

/// Discord's own option-type numbering, reused as-is by the backend (see
/// `Bots.Application`) — no dedicated server-side enum, just raw ints.
/// Only `string`/`integer`/`boolean`/`number` get a typed input in the
/// options dialog; the rest fall back to a plain text field for a raw id,
/// matching desktop (`discordOptionInputKind`).
enum BotCommandOptionType {
  @JsonValue(3)
  string,
  @JsonValue(4)
  integer,
  @JsonValue(5)
  boolean,
  @JsonValue(6)
  user,
  @JsonValue(7)
  channel,
  @JsonValue(8)
  role,
  @JsonValue(9)
  mentionable,
  @JsonValue(10)
  number,
}

@freezed
sealed class BotCommandOptionDto with _$BotCommandOptionDto {
  const factory BotCommandOptionDto({
    required String name,
    String? description,
    @Default(BotCommandOptionType.string) BotCommandOptionType type,
    @Default(false) bool required,
  }) = _BotCommandOptionDto;

  factory BotCommandOptionDto.fromJson(Map<String, dynamic> json) =>
      _$BotCommandOptionDtoFromJson(json);
}

@freezed
sealed class BotCommandDto with _$BotCommandDto {
  const factory BotCommandDto({
    required String botUserId,
    required String botName,
    required String name,
    String? description,
    @Default(<BotCommandOptionDto>[]) List<BotCommandOptionDto> options,
    String? scope,
  }) = _BotCommandDto;

  factory BotCommandDto.fromJson(Map<String, dynamic> json) =>
      _$BotCommandDtoFromJson(json);
}
