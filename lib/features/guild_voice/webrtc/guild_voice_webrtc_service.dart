import '../../../core/voice/voice_webrtc_service.dart';
import '../data/guild_voice_api.dart';
import '../data/guild_voice_media_api.dart';

/// The WebRTC session for one guild voice channel.
///
/// Everything it does lives in [VoiceWebRtcService], which is shared with 1:1
/// calls because the server runs one implementation for both. Guild voice used
/// to carry its own near-identical copy, which is how the two drifted - the
/// deferred-subscribe queue that fixed one-way silence in calls, for instance,
/// existed only on the call side.
class GuildVoiceWebRtcService extends VoiceWebRtcService {
  GuildVoiceWebRtcService({required this.api});

  final GuildVoiceApi api;

  Future<void> connect(String guildId, String channelId) => connectTo(
    GuildVoiceMediaApi(api: api, guildId: guildId, channelId: channelId),
  );
}
