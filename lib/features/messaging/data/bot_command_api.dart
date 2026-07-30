import '../../../core/network/api_client.dart';
import 'models/bot_command_dto.dart';

/// One resolved option value for a command invocation - [value] is a raw
/// JSON scalar (string/num/bool); the server looks up each option's
/// declared type from the command's stored schema, so no client-side type
/// tagging is needed on the wire.
class InvokeCommandOption {
  const InvokeCommandOption({required this.name, required this.value});

  final String name;
  final Object value;

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

class BotCommandApi {
  BotCommandApi({required this.client});

  final ApiClient client;

  Future<List<BotCommandDto>> getCommands(String guildId) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url('/api/v1/bots/guilds/$guildId/commands'),
    );
    return response.data!
        .map((json) => BotCommandDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fire-and-forget: the server returns 202 with no body and no
  /// correlation id - the bot's reply arrives later as an ordinary
  /// `guild.MessageCreated` realtime event from `botUserId` in this
  /// channel, which the caller must watch for separately.
  Future<void> invoke({
    required String guildId,
    required String channelId,
    required String botUserId,
    required String commandName,
    required List<InvokeCommandOption> options,
  }) {
    return client.dio.post<void>(
      client.url(
        '/api/v1/bots/guilds/$guildId/channels/$channelId/interactions',
      ),
      data: {
        'botUserId': botUserId,
        'commandName': commandName,
        'options': options.map((o) => o.toJson()).toList(),
      },
    );
  }
}
