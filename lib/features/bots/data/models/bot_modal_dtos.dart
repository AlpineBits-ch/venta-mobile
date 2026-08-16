/// The `guild.ModalOpen` push and the component tree it carries.
///
/// **Two different casings live in one payload, and that is not a bug in either
/// of them.** The event itself is an anonymous C# object
/// (`DiscordInteractionEndpoint.CallbackAsync`, the `InteractionCallbackType.Modal`
/// arm) that SignalR's JSON protocol renders through its camelCase policy, so
/// the outer object arrives as `guildId` / `channelId` / `botUserId` /
/// `customId` / `title` / `components`. The tree hanging off `components` is
/// `Bots.Contracts`' `ComponentPayload`, and every member of that class carries
/// an explicit `[JsonPropertyName]` - which wins over any naming policy - so the
/// nodes arrive as `type` / `custom_id` / `min_length` / `max_length`. Reading
/// `customId` off a component finds nothing; reading `custom_id` off the
/// envelope finds nothing either.
///
/// The published AsyncAPI contract disagrees with the second half of that: its
/// generator drops every member carrying `[JsonIgnore]` - which on
/// `ComponentPayload` is all of them but `Type`, since the rest are
/// `WhenWritingNull` - so the contract advertises `{type}` alone. The wire is
/// the authority here, not the contract.
///
/// Rather than bet on either, every field below is read through
/// [readBotPayloadKey], which ignores case *and* underscores. This codebase has
/// been caught by a PascalCase payload before (`platform status`), and a hub
/// naming policy is a backend detail no client should be wagering a silently
/// blank form on.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'bot_modal_dtos.freezed.dart';
part 'bot_modal_dtos.g.dart';

/// Reads [key] from [json] under whatever casing the hub actually used.
///
/// Matches on the name with underscores stripped and case folded, so a single
/// declared `custom_id` finds `custom_id`, `customId` and `CustomId` alike. The
/// exact-hit fast path comes first because that is the overwhelmingly common
/// case and the scan is only worth paying for when it is not.
///
/// Public rather than private because `json_serializable` emits the call from
/// the generated part file, and both DTOs in this library share it.
Object? readBotPayloadKey(Map<dynamic, dynamic> json, String key) {
  final direct = json[key];
  if (direct != null) return direct;
  final wanted = key.replaceAll('_', '').toLowerCase();
  for (final entry in json.entries) {
    if (entry.key.toString().replaceAll('_', '').toLowerCase() == wanted) {
      return entry.value;
    }
  }
  return null;
}

/// Discord's component type tags, as `ComponentPayload.Type` carries them.
///
/// Not an enum. They travel as raw integers in both directions and this client
/// only ever asks "is this an action row" or "is this a text input" - an enum
/// would additionally have to decide what a number added after this build
/// shipped decodes to, and the answer ("something we cannot render") is already
/// what falling through these two checks means.
abstract final class BotComponentType {
  static const actionRow = 1;
  static const button = 2;
  static const stringSelect = 3;
  static const textInput = 4;
  static const userSelect = 5;
  static const roleSelect = 6;
  static const mentionableSelect = 7;
  static const channelSelect = 8;
}

/// One node of a bot-authored component tree.
///
/// One permissive shape for every component type, matching the server's own
/// `ComponentPayload`: this layer carries a bot's components faithfully rather
/// than validating them, and a type-per-shape hierarchy would reject anything
/// it had not already heard of - the wrong failure mode for a compatibility
/// surface. Every field is therefore optional and only meaningful for some
/// values of [type].
@freezed
sealed class BotComponentDto with _$BotComponentDto {
  const factory BotComponentDto({
    /// Absent or unreadable means 0, which matches no known type and therefore
    /// renders as unsupported - see `toModalField`.
    @JsonKey(readValue: readBotPayloadKey) @Default(0) int type,

    /// Set only on an action row, which is the sole container type.
    @JsonKey(readValue: readBotPayloadKey)
    @Default(<BotComponentDto>[])
    List<BotComponentDto> components,

    /// The bot's own handle for this component, echoed back verbatim when the
    /// user answers. A text input without one is unanswerable: there is nothing
    /// to key the typed value on.
    @JsonKey(name: 'custom_id', readValue: readBotPayloadKey) String? customId,
    @JsonKey(readValue: readBotPayloadKey) String? label,

    /// Button style 1-5; on a text input, 1 is single-line and 2 is a paragraph
    /// box.
    @JsonKey(readValue: readBotPayloadKey) int? style,
    @JsonKey(readValue: readBotPayloadKey) String? placeholder,

    // ── Text input (modals only) ──────────────────────────────────────────
    /// Whatever the bot prefilled the field with.
    @JsonKey(readValue: readBotPayloadKey) String? value,

    /// Named around the keyword: `required` is a Dart modifier and cannot be a
    /// parameter name here, so the wire name is pinned with [JsonKey] instead.
    @JsonKey(name: 'required', readValue: readBotPayloadKey)
    @Default(false)
    bool isRequired,
    @JsonKey(name: 'min_length', readValue: readBotPayloadKey) int? minLength,
    @JsonKey(name: 'max_length', readValue: readBotPayloadKey) int? maxLength,
  }) = _BotComponentDto;

  factory BotComponentDto.fromJson(Map<String, dynamic> json) =>
      _$BotComponentDtoFromJson(json);
}

/// `guild.ModalOpen` - a bot asking this client to put a form on screen.
///
/// [customId] is the bot's correlation handle for the answer and goes straight
/// back out on `POST /bots/guilds/{g}/channels/{c}/modal-submit`. [guildId] is
/// nullable in the contract but the submit route needs it in its path, so a
/// modal that arrives without one can be read and not answered - which the
/// dialog says out loud rather than offering a Submit button that cannot work.
///
/// There is no `guild.ModalSubmit` hub method and there does not need to be:
/// the answer is an ordinary authenticated REST call, and the bot's reaction to
/// it comes back as a normal message or ephemeral push.
@freezed
sealed class BotModalOpenDto with _$BotModalOpenDto {
  const factory BotModalOpenDto({
    @JsonKey(readValue: readBotPayloadKey) String? guildId,
    @JsonKey(readValue: readBotPayloadKey) @Default('') String channelId,
    @JsonKey(readValue: readBotPayloadKey) @Default('') String botUserId,
    @JsonKey(readValue: readBotPayloadKey) String? customId,
    @JsonKey(readValue: readBotPayloadKey) String? title,
    @JsonKey(readValue: readBotPayloadKey)
    @Default(<BotComponentDto>[])
    List<BotComponentDto> components,
  }) = _BotModalOpenDto;

  const BotModalOpenDto._();

  factory BotModalOpenDto.fromJson(Map<String, dynamic> json) =>
      _$BotModalOpenDtoFromJson(json);

  /// Whether an answer to this modal could be routed at all.
  ///
  /// Both halves are needed and neither is inferable: [guildId] is a path
  /// segment on the submit route and [customId] is what the bot correlates the
  /// MODAL_SUBMIT interaction on. Without either there is no request to make,
  /// and the server would reject the attempt anyway - `SubmitModalAsync`
  /// 400s on a blank `customId`.
  bool get isAnswerable =>
      (guildId?.trim().isNotEmpty ?? false) &&
      (customId?.trim().isNotEmpty ?? false);
}
