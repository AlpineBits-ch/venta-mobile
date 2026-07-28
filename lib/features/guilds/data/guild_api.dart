import '../../../core/network/api_client.dart';
import 'models/category_dto.dart';
import 'models/channel_dto.dart';
import 'models/guild_dto.dart';
import 'models/guild_member_dto.dart';
import 'models/invite_dto.dart';

/// `{baseUrl}/api/v1/guild` is genuinely the base segment (singular) —
/// Alpine's own `GuildService` uses it as-is, endpoints then append
/// `/guilds`, `/channels`, `/categories`, `/invites` etc.
class GuildApi {
  GuildApi({required this.client});

  final ApiClient client;

  String get _base => client.url('/api/v1/guild');

  Future<GuildDto> createGuild({required String name, String? description}) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '$_base/guilds',
      data: {'name': name, 'description': description},
    );
    return GuildDto.fromJson(response.data!);
  }

  Future<List<GuildDto>> getGuilds() async {
    final response = await client.dio.get<List<dynamic>>('$_base/guilds');
    return response.data!.map((json) => GuildDto.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<GuildDto> getGuild(String id) async {
    final response = await client.dio.get<Map<String, dynamic>>('$_base/guilds/$id');
    return GuildDto.fromJson(response.data!);
  }

  Future<void> leaveGuild(String guildId) async {
    await client.dio.delete<void>('$_base/guilds/$guildId/members/me');
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

  Future<List<GuildMemberDto>> getMembers(String guildId, {int skip = 0, int take = 50}) async {
    final response = await client.dio.get<List<dynamic>>(
      '$_base/guilds/$guildId/members?skip=$skip&take=$take',
    );
    return response.data!
        .map((json) => GuildMemberDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<GuildMemberDto> getOwnMember(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>('$_base/guilds/$guildId/me');
    return GuildMemberDto.fromJson(response.data!);
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
    final response = await client.dio.get<Map<String, dynamic>>('$_base/invites/code/$code');
    return InviteDto.fromJson(response.data!);
  }

  Future<void> redeemInvite(String inviteId) async {
    await client.dio.post<void>('$_base/invites/$inviteId/redeem');
  }

  String _channelTypeWireValue(ChannelType type) => switch (type) {
        ChannelType.text => 'Text',
        ChannelType.voice => 'Voice',
        ChannelType.thread => 'Thread',
        ChannelType.announcement => 'Announcement',
      };
}
