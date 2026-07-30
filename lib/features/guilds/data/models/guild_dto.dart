import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_dto.dart';
import 'channel_dto.dart';
import 'guild_features.dart';
import 'role_dto.dart';

part 'guild_dto.freezed.dart';
part 'guild_dto.g.dart';

/// Gates who may *join* a guild via invite redemption based on how
/// established their account is - mirrors Discord's verification levels.
/// v1 is join-time only: already-joined members are never re-checked, and a
/// level raised after someone joined doesn't retroactively restrict them.
enum VerificationLevel {
  @JsonValue('None')
  none,
  @JsonValue('Low')
  low,
  @JsonValue('Medium')
  medium,
  @JsonValue('High')
  high,
}

/// What a guild *is* - presentation only. It seeds `features` at creation and
/// whenever it's changed, but nothing is gated on it: read `features` for
/// that. Use this for nomenclature ("House" vs "Server"), which settings pages
/// to render, and whether to surface discovery.
enum GuildKind {
  @JsonValue('Community')
  community,
  @JsonValue('Household')
  household,
  @JsonValue('Team')
  team,
  @JsonValue('Study')
  study,
  @JsonValue('Event')
  event,
}

extension GuildKindX on GuildKind {
  String get wireValue => switch (this) {
    GuildKind.community => 'Community',
    GuildKind.household => 'Household',
    GuildKind.team => 'Team',
    GuildKind.study => 'Study',
    GuildKind.event => 'Event',
  };

  String get label => switch (this) {
    GuildKind.community => 'Community',
    GuildKind.household => 'Household',
    GuildKind.team => 'Team',
    GuildKind.study => 'Study group',
    GuildKind.event => 'Event',
  };

  /// What this kind is *for*, in the create flow's own words.
  String get description => switch (this) {
    GuildKind.community =>
      'A public-ish space for a game, a project or a '
          'scene - forums, announcements, moderation.',
    GuildKind.household =>
      'A flat or a family. Shared lists, chores and '
          'money, without the moderation apparatus.',
    GuildKind.team =>
      'A working group - channels, threads and a wiki, '
          'nothing to run a public server with.',
    GuildKind.study =>
      'A class or a study group: notes in the wiki, '
          'sessions in the calendar.',
    GuildKind.event =>
      'One occasion. Channels and a schedule, and not much '
          'else to set up.',
  };

  /// The noun this kind's members would use for the guild itself.
  String get noun => switch (this) {
    GuildKind.community => 'Server',
    GuildKind.household => 'House',
    GuildKind.team => 'Team',
    GuildKind.study => 'Group',
    GuildKind.event => 'Event',
  };
}

@freezed
sealed class GuildDto with _$GuildDto {
  const factory GuildDto({
    required String id,
    required String name,
    String? description,
    required String ownerId,
    @Default(<CategoryDto>[]) List<CategoryDto> categories,
    @Default(<ChannelDto>[]) List<ChannelDto> channels,
    @Default(<RoleDto>[]) List<RoleDto> roles,
    String? bannerUrl,

    /// Not yet sent by the backend - forward-compatible plumbing only, so
    /// the client doesn't need a second change once it starts being sent.
    /// `ServerRailIcon` falls back to the initial-letter circle while null.
    String? iconUrl,
    String? systemChannelId,
    @Default(VerificationLevel.none)
    @JsonKey(unknownEnumValue: VerificationLevel.none)
    VerificationLevel verificationLevel,
    @Default(GuildKind.community)
    @JsonKey(unknownEnumValue: GuildKind.community)
    GuildKind kind,

    /// Comma-separated flag names, or `"None"`. Deliberately nullable and
    /// read through [GuildDtoX.featureSet]: **absent** means an older backend
    /// that predates modules, which is not the same as `"None"`.
    String? features,
  }) = _GuildDto;

  factory GuildDto.fromJson(Map<String, dynamic> json) =>
      _$GuildDtoFromJson(json);
}

extension GuildDtoX on GuildDto {
  /// The guild's modules. A server that doesn't report `features` yet is
  /// treated as a full community preset, so this client keeps behaving
  /// exactly as it did before modules existed rather than hiding everything.
  GuildFeatures get featureSet => features == null
      ? GuildFeatures.communityPreset
      : GuildFeatures.parse(features!);

  bool hasFeature(String feature) => featureSet.has(feature);
}
