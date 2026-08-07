import '../../../core/voice/voice_webrtc_service.dart';
import '../data/call_media_api.dart';
import '../data/voice_api.dart';

/// The WebRTC session for one 1:1 call.
///
/// Everything it does lives in [VoiceWebRtcService], which is shared with
/// guild voice channels because the server runs one implementation for both.
/// All that is left here is binding the call's routes.
class CallWebRtcService extends VoiceWebRtcService {
  CallWebRtcService({required this.api});

  final VoiceApi api;

  Future<void> connect(String callId) =>
      connectTo(CallMediaApi(api: api, callId: callId));
}
