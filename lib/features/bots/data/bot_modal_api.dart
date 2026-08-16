import '../../../core/network/api_client.dart';

/// The one write behind `guild.ModalOpen`.
///
/// Deliberately its own client rather than a third method on
/// `BotCommandApi`, which Alpine keeps them together on. The two surfaces are
/// reached from opposite directions - a slash command is something the composer
/// initiates and awaits a reply for, a modal is something the server pushes at
/// whatever screen happens to be open - and nothing here shares the command
/// roster, the cached-commands-went-stale retry or the reply-correlation wait
/// that make up the rest of that class.
class BotModalApi {
  BotModalApi({required this.client});

  final ApiClient client;

  /// Answers a modal a bot pushed with `guild.ModalOpen`.
  ///
  /// Channel-scoped rather than message-scoped, unlike a component interaction:
  /// a modal is not attached to a message, only to the interaction that opened
  /// it - so there is no message id to pin it to and no stored `components`
  /// array for the server to validate the `customId` against.
  ///
  /// The server answers `202` and nothing else. That means the MODAL_SUBMIT
  /// interaction has been handed to the bot's gateway connection, *not* that
  /// the bot has done anything with it - it replies on its own schedule, and
  /// whatever it decides to do arrives afterwards as an ordinary message or an
  /// ephemeral push. So there is deliberately no reply to await here, and the
  /// dialog must not claim one: a "Sent!" confirmation would be this client
  /// vouching for a process it cannot see.
  ///
  /// No retry-on-404 twin like `BotCommandApi`'s invoke path. A 404 here means
  /// the bot is disabled or no longer installed in this guild, not that a
  /// cached command list went stale, and refetching commands would not change
  /// the answer.
  ///
  /// [components] is passed as raw JSON rather than as [BotComponentDto]s
  /// because only two of that type's fields may travel outbound - see
  /// `buildModalSubmitRows`, which is the only thing that should be building
  /// this list.
  Future<void> submitModal({
    required String guildId,
    required String channelId,
    required String botUserId,
    required String customId,
    required List<Map<String, dynamic>> components,
  }) {
    return client.dio.post<void>(
      client.url(
        '/api/v1/bots/guilds/$guildId/channels/$channelId/modal-submit',
      ),
      data: {
        'botUserId': botUserId,
        'customId': customId,
        'components': components,
      },
    );
  }
}
