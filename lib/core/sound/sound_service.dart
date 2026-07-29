import 'package:audioplayers/audioplayers.dart';

/// One-shot and looping UI sound effects — the mobile counterpart to
/// Alpine's `SoundSettingsService`. Alpine's `ring_incoming.wav` has no
/// equivalent here: this app always shows the native CallKit incoming-call
/// UI (see `CallKitService`), which already rings via the system ringtone,
/// so a second custom ring on top would just double up.
class SoundService {
  final AudioPlayer _oneShotPlayer = AudioPlayer();
  final AudioPlayer _ringbackPlayer = AudioPlayer()
    ..setReleaseMode(ReleaseMode.loop);

  Future<void> playJoinCall() => _playOneShot('sounds/join_call.wav');

  Future<void> playLeaveCall() => _playOneShot('sounds/leave_call.wav');

  Future<void> playNewMessage() => _playOneShot('sounds/new_message.wav');

  /// Loops the outgoing-call ringback tone until [stopRingOutgoing] is
  /// called — there's no native ringback UI for outgoing calls, unlike
  /// incoming ones, so this has no double-ring risk.
  Future<void> startRingOutgoing() =>
      _ringbackPlayer.play(AssetSource('sounds/ring_outgoing.wav'));

  Future<void> stopRingOutgoing() => _ringbackPlayer.stop();

  Future<void> _playOneShot(String asset) async {
    try {
      await _oneShotPlayer.stop();
      await _oneShotPlayer.play(AssetSource(asset));
    } catch (_) {
      // Best-effort — a missing audio route shouldn't break the call/voice
      // action that triggered the sound.
    }
  }

  Future<void> dispose() async {
    await _oneShotPlayer.dispose();
    await _ringbackPlayer.dispose();
  }
}
