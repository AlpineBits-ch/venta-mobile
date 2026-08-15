import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/rate_limit_interceptor.dart';
import 'models/audit_log_entry_dto.dart';
import 'models/auto_mod_config_dto.dart';
import 'models/ban_dto.dart';
import 'models/category_dto.dart';
import 'models/channel_dto.dart';
import 'models/channel_follower_dto.dart';
import 'models/forum_config_dto.dart';
import 'models/forum_post_dto.dart';
import 'models/forum_tag_dto.dart';
import 'models/guild_dto.dart';
import 'models/guild_emoji_dto.dart';
import 'models/guild_features.dart';
import 'models/guild_template_dto.dart';
import 'models/guild_member_dto.dart';
import 'models/guild_permissions.dart';
import 'models/guild_self_permissions.dart';
import 'models/invite_dto.dart';
import 'models/onboarding_dto.dart';
import 'models/role_dto.dart';
import 'models/scheduled_event_dto.dart';
import 'models/welcome_screen_dto.dart';

/// `{baseUrl}/api/v1/guild` is genuinely the base segment (singular) -
/// Alpine's own `GuildService` uses it as-is, endpoints then append
/// `/guilds`, `/channels`, `/categories`, `/invites` etc.
class GuildApi {
  GuildApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/guild');

  /// [kind] seeds the guild's `features` from that kind's preset - the module
  /// set can't be set directly at creation, only PATCHed afterwards. Omitting
  /// it gives a `Community`, which gates nothing.
  Future<GuildDto> createGuild({
    required String name,
    String? description,
    GuildKind? kind,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds',
      data: {
        'name': name,
        'description': description,
        if (kind != null) 'kind': kind.wireValue,
      },
    );
    return GuildDto.fromJson(response.data!);
  }

  Future<List<GuildDto>> getGuilds() async {
    final response = await client.dio.get<List<dynamic>>('$_base/guilds');
    return response.data!
        .map((json) => GuildDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<GuildDto> getGuild(String id) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$id',
    );
    return GuildDto.fromJson(response.data!);
  }

  /// Where a guild's icon image lives.
  ///
  /// Always returns a URL - like the profile-avatar route, this one **404s**
  /// when the guild has never had an icon uploaded rather than being absent
  /// from the guild payload, so callers must render their own fallback on an
  /// image error instead of branching on null. It is deliberately not derived
  /// from `GuildDto.iconUrl`, which the backend still doesn't send: that field
  /// being null is why the server rail drew a bare letter for every server,
  /// including one whose icon the invite popup had just shown.
  ///
  /// Anonymous (the redirect it answers with is a presigned S3 URL), so it
  /// works from a plain image widget with no auth header - and from the invite
  /// popup, where the viewer isn't a member yet.
  String iconUrl(String guildId) => '$_base/guilds/$guildId/icon';

  Future<void> leaveGuild(String guildId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId/members/me');
  }

  /// [kind] and [features] are independent, with one trap: sending [kind]
  /// *alone* re-seeds `features` from that kind's preset, wiping a
  /// customised module set. Send both when you only mean to relabel.
  ///
  /// Effects are immediate server-side, so callers refetch the guild and its
  /// channels afterwards.
  Future<GuildDto> updateGuild(
    String guildId, {
    String? name,
    String? description,
    String? systemChannelId,
    VerificationLevel? verificationLevel,
    GuildKind? kind,
    GuildFeatures? features,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/guilds/$guildId',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (systemChannelId != null) 'systemChannelId': systemChannelId,
        if (verificationLevel != null)
          'verificationLevel': _verificationLevelWireValue(verificationLevel),
        if (kind != null) 'kind': kind.wireValue,
        // Names, not the numeric mask - readable in a network log and immune
        // to a flag being renumbered server-side.
        if (features != null) 'features': features.toWireString(),
      },
    );
    return GuildDto.fromJson(response.data!);
  }

  String _verificationLevelWireValue(VerificationLevel level) =>
      switch (level) {
        VerificationLevel.none => 'None',
        VerificationLevel.low => 'Low',
        VerificationLevel.medium => 'Medium',
        VerificationLevel.high => 'High',
      };

  Future<GuildDto> uploadGuildIcon(
    String guildId, {
    required List<int> bytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/icon',
      data: formData,
    );
    return GuildDto.fromJson(response.data!);
  }

  Future<GuildDto> deleteGuildIcon(String guildId) async {
    final response = await client.dio.delete<Map<String, dynamic>>(
      '$_base/guilds/$guildId/icon',
    );
    return GuildDto.fromJson(response.data!);
  }

  Future<void> deleteGuild(String guildId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId');
  }

  String guildIconUrl(String guildId) => '$_base/guilds/$guildId/icon';

  Future<RoleDto> createRole({
    required String guildId,
    required String name,
    String? description,
    String? color,
    GuildPermissions? permissions,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/roles',
      data: {
        'name': name,
        'description': description,
        'color': color ?? defaultRoleColor,
        'type': 'None',
        'permissions': (permissions ?? GuildPermissions.none).toWireString(),
      },
    );
    return RoleDto.fromJson(response.data!);
  }

  /// Returns nothing: unlike `POST .../roles`, the PATCH answers with a bare
  /// `200` and an **empty body** (`Results.Ok()` server-side, `Observable<void>`
  /// in the web client). Parsing a `RoleDto` out of it threw on every single
  /// save - which, because creating a role opens the editor straight away, read
  /// to the user as "roles can't be created". Re-read the role from the guild
  /// refresh the repository does instead of trusting a response that isn't there.
  Future<void> updateRole({
    required String roleId,
    required String name,
    String? description,
    String? color,
    required GuildPermissions permissions,
  }) async {
    await client.dio.patch<void>(
      '$_base/roles/$roleId',
      data: {
        'name': name,
        'description': description,
        'color': color ?? defaultRoleColor,
        'permissions': permissions.toWireString(),
      },
    );
  }

  Future<void> deleteRole(String roleId) async {
    await client.dio.delete<void>('$_base/roles/$roleId');
  }

  Future<void> reorderRoles(
    String guildId,
    List<({String roleId, int position})> positions,
  ) async {
    await client.dio.patch<void>(
      '$_base/guilds/$guildId/roles/reorder',
      data: {
        'roles': [
          for (final p in positions)
            {'roleId': p.roleId, 'position': p.position},
        ],
      },
    );
  }

  /// What comes back here are **role-membership join rows**, not members:
  /// `{id, roleId, memberId, expiresAt, member?}` - `RoleMemberDto` server-side,
  /// whose nested `member` is a `FlatMemberDto`. Reading a row straight into a
  /// [GuildMemberDto] threw on the absent `userId`/`guildId`, and the one caller
  /// swallows that into an empty list, so the role editor said "No members have
  /// this role yet" no matter who held it.
  ///
  /// `member` stays nullable because whether the projection carries it is the
  /// server's business, not something worth crashing over; callers that need
  /// the member resolve [memberId] instead.
  Future<List<({String memberId, GuildMemberDto? member})>> getRoleMembers(
    String roleId, {
    int skip = 0,
    int take = 30,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/roles/$roleId/members?skip=$skip&take=$take',
    );
    return [
      for (final row in response.data!.cast<Map<String, dynamic>>())
        (
          memberId: row['memberId'] as String,
          member: row['member'] is Map<String, dynamic>
              ? GuildMemberDto.fromJson(row['member'] as Map<String, dynamic>)
              : null,
        ),
    ];
  }

  Future<void> addRoleMember(String roleId, String memberId) async {
    await client.dio.put<void>('$_base/roles/$roleId/members/$memberId');
  }

  Future<void> removeRoleMember(String roleId, String memberId) async {
    await client.dio.delete<void>('$_base/roles/$roleId/members/$memberId');
  }

  Future<List<GuildMemberDto>> searchMembers(
    String guildId,
    String search,
  ) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/members/search?search=${Uri.encodeQueryComponent(search)}',
    );
    return response.data!
        .map((json) => GuildMemberDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> kickMember(String guildId, String memberId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId/members/$memberId');
  }

  Future<List<BanDto>> getBans(String guildId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/bans',
    );
    return response.data!
        .map((json) => BanDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBan(
    String guildId, {
    required String userId,
    String? reason,
  }) async {
    await client.dio.post<void>(
      '$_base/guilds/$guildId/bans',
      data: {'userId': userId, 'reason': reason},
    );
  }

  Future<void> deleteBan(String guildId, String bannedUserId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId/bans/$bannedUserId');
  }

  Future<AutoModConfigDto> getAutoMod(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$guildId/automod',
    );
    return AutoModConfigDto.fromJson(response.data!);
  }

  Future<AutoModConfigDto> updateAutoMod(
    String guildId,
    AutoModConfigDto config,
  ) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/guilds/$guildId/automod',
      data: config.toJson(),
    );
    return AutoModConfigDto.fromJson(response.data!);
  }

  /// `403 Forbid` from the server just surfaces as a plain [DioException] -
  /// the caller decides how to explain "you don't manage that channel".
  Future<void> followChannel({
    required String sourceChannelId,
    required String targetChannelId,
  }) async {
    await client.dio.post<void>(
      '$_base/channels/$sourceChannelId/followers',
      data: {'targetChannelId': targetChannelId},
    );
  }

  Future<List<ChannelFollowerDto>> getFollowers(String sourceChannelId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$sourceChannelId/followers',
    );
    return response.data!
        .map(
          (json) => ChannelFollowerDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<void> unfollowChannel({
    required String sourceChannelId,
    required String followId,
  }) async {
    await client.dio.delete<void>(
      '$_base/channels/$sourceChannelId/followers/$followId',
    );
  }

  Future<List<ScheduledEventDto>> getEvents(String guildId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/events',
    );
    return response.data!
        .map((json) => ScheduledEventDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ScheduledEventDto> createEvent(
    String guildId, {
    required String title,
    String? description,
    required DateTime startsAt,
    DateTime? endsAt,
    String? location,
    String? voiceChannelId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/events',
      data: {
        'title': title,
        if (description != null) 'description': description,
        'startsAt': startsAt.toUtc().toIso8601String(),
        if (endsAt != null) 'endsAt': endsAt.toUtc().toIso8601String(),
        if (location != null) 'location': location,
        if (voiceChannelId != null) 'voiceChannelId': voiceChannelId,
      },
    );
    return ScheduledEventDto.fromJson(response.data!);
  }

  /// `PATCH` only touches fields you include - `null` means unchanged, same
  /// convention used elsewhere in this API.
  Future<ScheduledEventDto> updateEvent(
    String eventId, {
    String? title,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    String? location,
    String? voiceChannelId,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/events/$eventId',
      data: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (startsAt != null) 'startsAt': startsAt.toUtc().toIso8601String(),
        if (endsAt != null) 'endsAt': endsAt.toUtc().toIso8601String(),
        if (location != null) 'location': location,
        if (voiceChannelId != null) 'voiceChannelId': voiceChannelId,
      },
    );
    return ScheduledEventDto.fromJson(response.data!);
  }

  /// Soft-cancels - there's no hard delete, per the guide.
  Future<void> cancelEvent(String eventId) async {
    await client.dio.delete<void>('$_base/events/$eventId');
  }

  Future<void> markEventInterested(String eventId) async {
    await client.dio.post<void>('$_base/events/$eventId/interested');
  }

  Future<void> removeEventInterest(String eventId) async {
    await client.dio.delete<void>('$_base/events/$eventId/interested');
  }

  Future<GuildTemplateDto> createTemplate(
    String guildId, {
    required String name,
    String? description,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/templates',
      data: {'name': name, 'description': description},
    );
    return GuildTemplateDto.fromJson(response.data!);
  }

  /// No permission check beyond being logged in - templates are meant to be
  /// shareable by id/link, same spirit as an invite code.
  Future<GuildTemplateDetailDto> getTemplate(String templateId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/templates/$templateId',
    );
    return GuildTemplateDetailDto.fromJson(response.data!);
  }

  Future<GuildDto> useTemplate(
    String templateId, {
    required String name,
    String? description,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/templates/$templateId/use',
      data: {'name': name, 'description': description},
    );
    return GuildDto.fromJson(response.data!);
  }

  Future<OnboardingConfigDto> getOnboarding(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$guildId/onboarding',
    );
    return OnboardingConfigDto.fromJson(response.data!);
  }

  Future<OnboardingConfigDto> updateOnboarding(
    String guildId,
    OnboardingConfigDto config,
  ) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/guilds/$guildId/onboarding',
      data: config.toJson(),
    );
    return OnboardingConfigDto.fromJson(response.data!);
  }

  Future<OnboardingStatusDto> getOwnOnboardingStatus(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$guildId/onboarding/me',
    );
    return OnboardingStatusDto.fromJson(response.data!);
  }

  /// Idempotent - accepting twice is a no-op, and the second call does *not*
  /// re-apply [responses]. On success roles and channel access are live
  /// immediately, but the guild's channel list and the member's own roles
  /// both need refetching.
  Future<void> acceptOnboarding(
    String guildId, {
    List<OnboardingResponseDto> responses = const [],
  }) async {
    await client.dio.post<void>(
      '$_base/guilds/$guildId/onboarding/accept',
      // A JSON body is required even with nothing to answer - an entirely
      // empty request is rejected by the model binder before the endpoint
      // runs, so a rules-only guild still sends `{"responses": []}`.
      data: {
        'responses': [for (final r in responses) r.toJson()],
      },
    );
  }

  /// Every prompt - join-flow and Channels & Roles alike - with the calling
  /// member's current picks marked on each option.
  Future<List<OnboardingPromptDto>> getOnboardingPrompts(String guildId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/onboarding/prompts',
    );
    return response.data!
        .map(
          (json) => OnboardingPromptDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  /// Full replace of this member's picks across *all* prompts - a prompt left
  /// out counts as "nothing selected" and its grants are revoked.
  Future<void> updateOwnOnboardingResponses(
    String guildId,
    List<OnboardingResponseDto> responses,
  ) async {
    await client.dio.put<void>(
      '$_base/guilds/$guildId/onboarding/me/responses',
      data: {
        'responses': [for (final r in responses) r.toJson()],
      },
    );
  }

  Future<WelcomeScreenDto> getWelcomeScreen(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$guildId/welcome-screen',
    );
    return WelcomeScreenDto.fromJson(response.data!);
  }

  Future<WelcomeScreenDto> updateWelcomeScreen(
    String guildId,
    WelcomeScreenDto screen,
  ) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/guilds/$guildId/welcome-screen',
      data: screen.toJson(),
    );
    return WelcomeScreenDto.fromJson(response.data!);
  }

  /// Members who joined while onboarding was enabled and haven't finished it.
  /// Requires `ModerateMembers` or `ManageGuild`.
  Future<List<PendingMemberDto>> getPendingMembers(
    String guildId, {
    int limit = 100,
    int offset = 0,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/members/pending?limit=$limit&offset=$offset',
    );
    return response.data!
        .map((json) => PendingMemberDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AuditLogEntryDto>> getAuditLog(
    String guildId, {
    int skip = 0,
    int take = 50,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/audit-log?skip=$skip&take=$take',
    );
    return response.data!
        .map((json) => AuditLogEntryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Every invite a guild has. **Requires `ManageGuild`** - it used to take
  /// `ManageChannel`, which is the wrong scope (channel, not guild) and the
  /// wrong level of trust for the guild's entire set of live join credentials.
  ///
  /// Revoked invites are excluded unless [includeRevoked] is set, which is what
  /// keeps the default list the shape it was before revocation existed.
  Future<List<InviteDto>> getInvites(
    String guildId, {
    bool includeRevoked = false,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/invites',
      queryParameters: includeRevoked ? const {'includeRevoked': true} : null,
    );
    return response.data!
        .map((json) => InviteDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Revokes an invite. Still `DELETE`, still answers the invite - but the row
  /// survives now, moved to `state: Revoked` with a `revokedAt`, because
  /// `guildMember.inviteId` points at it and deleting it once took every member
  /// who had joined through it with it.
  ///
  /// Idempotent: revoking an already-revoked invite answers the same body and
  /// writes no second audit entry.
  Future<InviteDto?> deleteInvite(String inviteId) async {
    final response = await client.dio.delete<Map<String, dynamic>>(
      '$_base/invites/$inviteId',
    );
    final data = response.data;
    if (data == null) return null;
    try {
      return InviteDto.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<ChannelDto> createChannel({
    required String guildId,
    required String name,
    String? description,
    ChannelType type = ChannelType.text,
    String? categoryId,
    required int position,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/channels',
      data: {
        'guildId': guildId,
        'name': name,
        'description': description,
        'type': _channelTypeWireValue(type),
        'categoryId': categoryId,
        'position': position,
      },
    );
    return ChannelDto.fromJson(response.data!);
  }

  Future<void> deleteChannel(String channelId) async {
    await client.dio.delete<void>('$_base/channels/$channelId');
  }

  Future<ChannelDto> updateChannel(
    String channelId, {
    required String name,
    String? description,
    required bool isPrivate,
    required bool isAgeRestricted,
    required int slowModeSeconds,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/channels/$channelId',
      data: {
        'name': name,
        'description': description,
        'isPrivate': isPrivate,
        'isAgeRestricted': isAgeRestricted,
        'slowModeSeconds': slowModeSeconds,
      },
    );
    return ChannelDto.fromJson(response.data!);
  }

  Future<void> reorderChannels(
    String guildId, {
    List<({String channelId, int position, String? categoryId})> channels =
        const [],
    List<({String categoryId, int position})> categories = const [],
  }) async {
    await client.dio.patch<void>(
      '$_base/guilds/$guildId/channels/reorder',
      data: {
        'categories': [
          for (final c in categories)
            {'categoryId': c.categoryId, 'position': c.position},
        ],
        'channels': [
          for (final c in channels)
            {
              'channelId': c.channelId,
              'position': c.position,
              if (c.categoryId != null) 'categoryId': c.categoryId,
            },
        ],
      },
    );
  }

  Future<CategoryDto> createCategory({
    required String guildId,
    required String name,
    String? description,
    required int position,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/categories',
      data: {
        'guildId': guildId,
        'name': name,
        'description': description,
        'position': position,
      },
    );
    return CategoryDto.fromJson(response.data!);
  }

  Future<void> deleteCategory(String categoryId) async {
    await client.dio.delete<void>('$_base/categories/$categoryId');
  }

  /// Singular `/category/{id}` - matches Alpine's `updateCategory` exactly;
  /// every other category endpoint here is the plural `/categories/...`.
  Future<CategoryDto> updateCategory(
    String categoryId, {
    required String name,
    String? description,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/category/$categoryId',
      data: {'name': name, 'description': description},
    );
    return CategoryDto.fromJson(response.data!);
  }

  /// Who can actually see a channel - the guild members holding `ViewChannel`
  /// here, after roles and channel overwrites are resolved.
  ///
  /// Exists for end-to-end encryption, which needs the exact roster: anyone
  /// handed group keys can read the traffic, so falling back to the whole member
  /// list is a confidentiality bug on any channel with restrictive overwrites,
  /// not a cosmetic one.
  Future<List<String>> getChannelViewers(String channelId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/${Uri.encodeComponent(channelId)}/viewers',
    );
    return (response.data?['userIds'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList();
  }

  Future<List<GuildMemberDto>> getMembers(
    String guildId, {
    int skip = 0,
    int take = 50,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/members?skip=$skip&take=$take',
    );
    return response.data!
        .map((json) => GuildMemberDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<GuildSelfPermissions> getOwnMember(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/guilds/$guildId/me',
    );
    return GuildSelfPermissions.fromJson(response.data!);
  }

  /// Mints an invite.
  ///
  /// [maxUses] and [expiresAt] were both accepted by this endpoint before
  /// anything sent them. `null` means unlimited / never; **`0` is refused with
  /// a `400`**, because an invite that is exhausted the moment it exists is a
  /// link somebody is about to share.
  ///
  /// A [targetType] of [InviteTargetType.voiceChannel] requires [channelId] and
  /// that the channel be a voice channel in this guild - all validated at
  /// creation rather than at redemption, because the person who can still fix a
  /// bad target is the one filling in the form.
  Future<InviteDto> createInvite({
    required String guildId,
    InviteType type = InviteType.permanent,
    String? channelId,
    DateTime? expiresAt,
    int? maxUses,
    bool temporary = false,
    InviteTargetType targetType = InviteTargetType.none,
    String? targetUserId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/invite',
      data: {
        'type': _inviteTypeWireValue(type),
        'channelId': channelId,
        'expiresAt': expiresAt?.toUtc().toIso8601String(),
        'maxUses': maxUses,
        'temporary': temporary,
        'targetType': _inviteTargetTypeWireValue(targetType),
        'targetUserId': targetUserId,
      },
    );
    return InviteDto.fromJson(response.data!);
  }

  /// Throws [InvitePreviewRateLimitedException] on the preview routes' own
  /// budget - they are the only unauthenticated surface that will say whether a
  /// code exists, so they carry one on top of the gateway's.
  Future<InviteDto> getInviteByCode(String code) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        '$_base/invites/code/$code',
        options: _invitePreviewOptions,
      );
      return InviteDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapInvitePreviewError(e);
    }
  }

  /// Opts the preview routes out of the generic `429` retry.
  ///
  /// Their budget is their own - 30 a minute, burst 60, **a miss spends a token
  /// too** - and it is not the gateway's shared bucket. Retrying it three times
  /// automatically spends three tokens answering one question, and its
  /// `global`-less body would park every other request in the app behind one
  /// invite lookup. The retry the guidance actually asks for is one the user
  /// presses, which is what the dialog offers.
  Options get _invitePreviewOptions =>
      Options(extra: const {RateLimitInterceptor.ownBudgetKey: true});

  /// Throws [VerificationLevelNotMetException] when the guild's
  /// `verificationLevel` blocks this account from joining (structured `403`
  /// body: `{error: "verification_level_not_met", requiredLevel}`).
  ///
  /// Still a `202`, now with a body. Every field of [RedeemResultDto] is
  /// additive - this route answered with nothing at all before - so a body that
  /// will not parse must never cost the join that has already happened.
  Future<RedeemResultDto?> redeemInvite(String inviteId) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_base/invites/$inviteId/redeem',
      );
      final data = response.data;
      if (data == null) return null;
      try {
        return RedeemResultDto.fromJson(data);
      } catch (_) {
        return null;
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (e.response?.statusCode == 403 &&
          data is Map &&
          data['error'] == 'verification_level_not_met') {
        throw VerificationLevelNotMetException(
          data['requiredLevel'] as String? ?? 'Medium',
        );
      }
      rethrow;
    }
  }

  /// A `429` from a preview route is "ask again in a moment", which is a
  /// different thing to say than "this invite is not real" - and the dialog
  /// showed the second for both until this was told apart.
  Object _mapInvitePreviewError(DioException e) {
    final data = e.response?.data;
    if (e.response?.statusCode == 429 &&
        data is Map &&
        data['error'] == 'rate_limited') {
      return InvitePreviewRateLimitedException(
        data['message'] as String? ??
            'Too many invite lookups; try again shortly.',
      );
    }
    return e;
  }

  String _inviteTypeWireValue(InviteType type) => switch (type) {
    InviteType.oneTime => 'OneTime',
    // An invite this build cannot name is not a shape to send back; permanent
    // is what the endpoint defaults to anyway.
    InviteType.permanent || InviteType.unknown => 'Permanent',
  };

  String _inviteTargetTypeWireValue(InviteTargetType type) => switch (type) {
    InviteTargetType.voiceChannel => 'VoiceChannel',
    InviteTargetType.none || InviteTargetType.unknown => 'None',
  };

  String _channelTypeWireValue(ChannelType type) => switch (type) {
    ChannelType.text => 'Text',
    ChannelType.voice => 'Voice',
    ChannelType.thread => 'Thread',
    ChannelType.announcement => 'Announcement',
    ChannelType.forum => 'Forum',
    ChannelType.media => 'Media',
    ChannelType.list => 'List',
    ChannelType.chores => 'Chores',
    ChannelType.ledger => 'Ledger',
    ChannelType.pantry => 'Pantry',
    ChannelType.decisions => 'Decisions',
    ChannelType.meals => 'Meals',
    ChannelType.maintenance => 'Maintenance',
    // Only ever produced by *decoding* a type this build doesn't know; it's
    // never offered as something to create. Loud rather than silently posting
    // a bogus type the server would reject anyway.
    ChannelType.unknown => throw ArgumentError(
      'Cannot create a channel of an unrecognised type',
    ),
  };

  Future<List<GuildEmojiDto>> getEmojis(String guildId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/emojis',
    );
    return response.data!
        .map((json) => GuildEmojiDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<GuildEmojiDto> uploadEmoji(
    String guildId, {
    required String name,
    required bool animated,
    required List<int> bytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'animated': animated.toString(),
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/emojis',
      data: formData,
    );
    return GuildEmojiDto.fromJson(response.data!);
  }

  Future<void> deleteEmoji(String guildId, String emojiId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId/emojis/$emojiId');
  }

  /// Creates a "post" (a `Thread`-typed channel parented to a Forum channel)
  /// - identical shape to a Text-channel thread. When [content] is present
  /// it's posted as the first message automatically, server-side.
  ///
  /// [tagIds] applies forum tags at creation; it's required (non-empty) when
  /// the forum's config has `requireTag`, and applying a `moderated` tag needs
  /// `ManageChannel`/`ManageAnyThread` or the whole call is refused - hence
  /// the picker hides moderated chips from non-moderators rather than letting
  /// the request fail.
  Future<ChannelDto> createThread(
    String channelId, {
    required String name,
    String? content,
    List<String> tagIds = const [],
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/threads',
      data: {
        'name': name,
        if (content != null) 'content': content,
        if (tagIds.isNotEmpty) 'tagIds': tagIds,
      },
    );
    return ChannelDto.fromJson(response.data!);
  }

  /// The legacy thread list - **capped at the 50 most recent** and with no tag
  /// filtering, activity sort, pinning awareness or pagination. Still the
  /// right call for a text channel's thread sidebar; forums use
  /// [getForumPosts] instead.
  Future<List<ChannelDto>> getThreads(String channelId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$channelId/threads',
    );
    return response.data!
        .map((json) => ChannelDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> archiveThread(String threadId) async {
    await client.dio.patch<void>('$_base/threads/$threadId/archive');
  }

  // ---------------------------------------------------------------------
  // Forum tags, config and posts
  //
  // Every endpoint below works identically for `Forum` and `Media` channels
  // (see `ChannelTypeX.isForumLike`) and reuses existing permission bits -
  // `ViewChannel` to read, `ManageChannel`/`ManageAnyThread` to write - so
  // nothing needs granting before forums work.
  // ---------------------------------------------------------------------

  Future<List<ForumTagDto>> getForumTags(String forumChannelId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/channels/$forumChannelId/tags',
    );
    return response.data!
        .map((json) => ForumTagDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Throws [ForumTagNameTakenException] on the `409` a duplicate name gets -
  /// the one error users hit routinely, so it's surfaced inline on the name
  /// field rather than as a toast.
  Future<ForumTagDto> createForumTag(
    String forumChannelId, {
    required String name,
    String? emojiId,
    String? emojiName,
    String? color,
    bool moderated = false,
  }) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        '$_base/channels/$forumChannelId/tags',
        data: {
          'name': name,
          if (emojiId != null) 'emojiId': emojiId,
          if (emojiName != null) 'emojiName': emojiName,
          if (color != null) 'color': color,
          'moderated': moderated,
        },
      );
      return ForumTagDto.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ForumTagNameTakenException(name);
      }
      rethrow;
    }
  }

  /// Only the fields you pass are touched. To *clear* an emoji send an empty
  /// string rather than null - null is this API's "leave unchanged".
  Future<ForumTagDto> updateForumTag(
    String tagId, {
    String? name,
    String? emojiId,
    String? emojiName,
    String? color,
    bool? moderated,
  }) async {
    try {
      final response = await client.dio.patch<Map<String, dynamic>>(
        '$_base/forum-tags/$tagId',
        data: {
          if (name != null) 'name': name,
          if (emojiId != null) 'emojiId': emojiId,
          if (emojiName != null) 'emojiName': emojiName,
          if (color != null) 'color': color,
          if (moderated != null) 'moderated': moderated,
        },
      );
      return ForumTagDto.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409 && name != null) {
        throw ForumTagNameTakenException(name);
      }
      rethrow;
    }
  }

  /// The tag is removed from every post carrying it, in the same transaction.
  Future<void> deleteForumTag(String tagId) async {
    await client.dio.delete<void>('$_base/forum-tags/$tagId');
  }

  /// Send the forum's **complete** ordered tag id list - positions come from
  /// the array index and a partial list is rejected with `400`.
  Future<void> reorderForumTags(
    String forumChannelId,
    List<String> tagIds,
  ) async {
    await client.dio.patch<void>(
      '$_base/channels/$forumChannelId/tags/reorder',
      data: {'tagIds': tagIds},
    );
  }

  Future<ForumConfigDto> getForumConfig(String forumChannelId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/channels/$forumChannelId/forum-config',
    );
    return ForumConfigDto.fromJson(response.data!);
  }

  Future<ForumConfigDto> updateForumConfig(
    String forumChannelId, {
    bool? requireTag,
    ForumSortOrder? defaultSortOrder,
    ForumLayout? defaultLayout,
    String? defaultReactionEmojiId,
    String? defaultReactionEmojiName,
    int? defaultThreadSlowModeSeconds,
    int? defaultAutoArchiveMinutes,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/channels/$forumChannelId/forum-config',
      data: {
        if (requireTag != null) 'requireTag': requireTag,
        if (defaultSortOrder != null)
          'defaultSortOrder': defaultSortOrder == ForumSortOrder.latestActivity
              ? 'LatestActivity'
              : 'CreationDate',
        if (defaultLayout != null)
          'defaultLayout': defaultLayout == ForumLayout.gallery
              ? 'Gallery'
              : 'List',
        if (defaultReactionEmojiId != null)
          'defaultReactionEmojiId': defaultReactionEmojiId,
        if (defaultReactionEmojiName != null)
          'defaultReactionEmojiName': defaultReactionEmojiName,
        if (defaultThreadSlowModeSeconds != null)
          'defaultThreadSlowModeSeconds': defaultThreadSlowModeSeconds,
        if (defaultAutoArchiveMinutes != null)
          'defaultAutoArchiveMinutes': defaultAutoArchiveMinutes,
      },
    );
    return ForumConfigDto.fromJson(response.data!);
  }

  /// One keyset-paginated page of posts. Pinned posts are hoisted ahead of
  /// pagination and so only appear on the first page - never re-sort the
  /// result client-side or the ordering breaks across pages.
  ///
  /// [cursor] must be a `nextCursor` handed back by a previous call made with
  /// the *same* sort and filters; changing any of them means starting over.
  Future<ForumPostPageDto> getForumPosts(
    String forumChannelId, {
    List<String> tagIds = const [],
    bool matchAll = false,
    ForumSortOrder? sort,
    ForumArchiveFilter archived = ForumArchiveFilter.active,
    int limit = 25,
    String? cursor,
  }) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        '$_base/channels/$forumChannelId/posts',
        queryParameters: {
          if (tagIds.isNotEmpty) ...{
            'tagIds': tagIds.join(','),
            'match': matchAll ? 'all' : 'any',
          },
          if (sort != null) 'sort': sort.querySortValue,
          'archived': archived.wireValue,
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      return ForumPostPageDto.fromJson(response.data!);
    } on DioException catch (e) {
      // Transitional: `/posts` ships with the forum-parity work, and until
      // that's deployed the route simply isn't there. Rather than showing a
      // dead forum on older servers, fall back to the v1 thread list - one
      // unfiltered, unpaginated page, which is exactly what forums did
      // before. Remove once every server this client talks to has `/posts`.
      final status = e.response?.statusCode;
      if (status == 404 || status == 405) {
        final threads = await getThreads(forumChannelId);
        return ForumPostPageDto(
          posts: [
            for (final thread in threads)
              ForumPostDto(
                id: thread.id,
                guildId: thread.guildId,
                parentChannelId: thread.parentChannelId,
                name: thread.name,
                description: thread.description,
                tagIds: thread.tagIds,
                isPinned: thread.isPinned,
                isLocked: thread.isLocked,
                isArchived: thread.isArchived,
                lastActivityAt: thread.lastActivityAt,
                messageCount: thread.messageCount,
                autoArchiveAt: thread.autoArchiveAt,
                isAgeRestricted: thread.isAgeRestricted,
                isPrivate: thread.isPrivate,
                slowModeSeconds: thread.slowModeSeconds,
              ),
          ],
        );
      }
      rethrow;
    }
  }

  /// **Replace semantics** - send the complete desired set, not a delta, which
  /// is what makes a retry after a network blip safe.
  Future<ForumPostDto> setPostTags(String threadId, List<String> tagIds) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '$_base/threads/$threadId/tags',
      data: {'tagIds': tagIds},
    );
    return ForumPostDto.fromJson(response.data!);
  }

  /// Post pinning - entirely separate from pinning a *message inside* a post,
  /// which is the messaging service's own feature.
  Future<void> setPostPinned(String threadId, bool pinned) async {
    await client.dio.patch<void>(
      '$_base/threads/$threadId/pin',
      data: {'pinned': pinned},
    );
  }

  Future<void> setPostLocked(String threadId, bool locked) async {
    await client.dio.patch<void>(
      '$_base/threads/$threadId/lock',
      data: {'locked': locked},
    );
  }
}

/// Thrown by the tag create/rename calls on the `409` a name collision gets -
/// names are unique per forum, case-insensitively.
class ForumTagNameTakenException implements Exception {
  const ForumTagNameTakenException(this.name);
  final String name;
}

/// Thrown by [GuildApi.redeemInvite] when the guild's `verificationLevel`
/// blocks this account from joining - `requiredLevel` names the tier that
/// wasn't met, e.g. `"Medium"`, so the caller can explain exactly what's
/// missing instead of showing a generic failure.
class VerificationLevelNotMetException implements Exception {
  const VerificationLevelNotMetException(this.requiredLevel);
  final String requiredLevel;
}

/// Thrown by the invite preview routes on their own `429`.
///
/// Those routes are the only unauthenticated surface that will tell anybody
/// whether a code exists, so they carry a budget on top of the gateway's - 30 a
/// minute, burst 60, and **a miss spends a token too**, because a miss is the
/// request worth pricing: it is the one that probes the code space.
///
/// Worth a distinct type rather than a bare `DioException`, because the only
/// thing a caller could do with the latter is show the same "this invite is not
/// valid" panel a `404` gets - which is wrong, and permanently wrong-looking,
/// for a condition that clears itself in seconds.
class InvitePreviewRateLimitedException implements Exception {
  const InvitePreviewRateLimitedException(this.message);
  final String message;
}
