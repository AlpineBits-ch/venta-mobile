import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/audit_log_entry_dto.dart';
import 'models/ban_dto.dart';
import 'models/category_dto.dart';
import 'models/channel_dto.dart';
import 'models/guild_dto.dart';
import 'models/guild_emoji_dto.dart';
import 'models/guild_member_dto.dart';
import 'models/guild_permissions.dart';
import 'models/guild_self_permissions.dart';
import 'models/invite_dto.dart';
import 'models/role_dto.dart';

/// `{baseUrl}/api/v1/guild` is genuinely the base segment (singular) -
/// Alpine's own `GuildService` uses it as-is, endpoints then append
/// `/guilds`, `/channels`, `/categories`, `/invites` etc.
class GuildApi {
  GuildApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/guild');

  Future<GuildDto> createGuild({
    required String name,
    String? description,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds',
      data: {'name': name, 'description': description},
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

  Future<void> leaveGuild(String guildId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId/members/me');
  }

  Future<GuildDto> updateGuild(
    String guildId, {
    String? name,
    String? description,
    String? systemChannelId,
    VerificationLevel? verificationLevel,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/guilds/$guildId',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (systemChannelId != null) 'systemChannelId': systemChannelId,
        if (verificationLevel != null)
          'verificationLevel': _verificationLevelWireValue(verificationLevel),
      },
    );
    return GuildDto.fromJson(response.data!);
  }

  String _verificationLevelWireValue(VerificationLevel level) => switch (level) {
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
        'color': color,
        'type': 'None',
        'permissions': (permissions ?? GuildPermissions.none).toWireString(),
      },
    );
    return RoleDto.fromJson(response.data!);
  }

  Future<RoleDto> updateRole({
    required String roleId,
    required String name,
    String? description,
    String? color,
    required GuildPermissions permissions,
  }) async {
    final response = await client.dio.patch<Map<String, dynamic>>(
      '$_base/roles/$roleId',
      data: {
        'name': name,
        'description': description,
        'color': color,
        'permissions': permissions.toWireString(),
      },
    );
    return RoleDto.fromJson(response.data!);
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

  Future<List<GuildMemberDto>> getRoleMembers(
    String roleId, {
    int skip = 0,
    int take = 30,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/roles/$roleId/members?skip=$skip&take=$take',
    );
    return response.data!
        .map((json) => GuildMemberDto.fromJson(json as Map<String, dynamic>))
        .toList();
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

  Future<List<InviteDto>> getInvites(String guildId) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/invites',
    );
    return response.data!
        .map((json) => InviteDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteInvite(String inviteId) async {
    await client.dio.delete<void>('$_base/invites/$inviteId');
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

  Future<InviteDto> createInvite({
    required String guildId,
    InviteType type = InviteType.permanent,
    String? channelId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds/$guildId/invite',
      data: {
        'type': type == InviteType.oneTime ? 'OneTime' : 'Permanent',
        'channelId': channelId,
      },
    );
    return InviteDto.fromJson(response.data!);
  }

  Future<InviteDto> getInviteByCode(String code) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/invites/code/$code',
    );
    return InviteDto.fromJson(response.data!);
  }

  /// Throws [VerificationLevelNotMetException] when the guild's
  /// `verificationLevel` blocks this account from joining (structured `403`
  /// body: `{error: "verification_level_not_met", requiredLevel}`).
  Future<void> redeemInvite(String inviteId) async {
    try {
      await client.dio.post<void>('$_base/invites/$inviteId/redeem');
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

  String _channelTypeWireValue(ChannelType type) => switch (type) {
    ChannelType.text => 'Text',
    ChannelType.voice => 'Voice',
    ChannelType.thread => 'Thread',
    ChannelType.announcement => 'Announcement',
    ChannelType.forum => 'Forum',
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
  Future<ChannelDto> createThread(
    String channelId, {
    required String name,
    String? content,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/channels/$channelId/threads',
      data: {'name': name, if (content != null) 'content': content},
    );
    return ChannelDto.fromJson(response.data!);
  }

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
}

/// Thrown by [GuildApi.redeemInvite] when the guild's `verificationLevel`
/// blocks this account from joining - `requiredLevel` names the tier that
/// wasn't met, e.g. `"Medium"`, so the caller can explain exactly what's
/// missing instead of showing a generic failure.
class VerificationLevelNotMetException implements Exception {
  const VerificationLevelNotMetException(this.requiredLevel);
  final String requiredLevel;
}
