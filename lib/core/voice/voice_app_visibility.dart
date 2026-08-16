import 'package:flutter/widgets.dart';

/// Reports whether this client is backgrounded, so the server can stop sending
/// it video nobody is looking at.
///
/// The mobile answer to the spec's "report `paused` on `visibilitychange`".
/// There is no visibility event on a handset; [AppLifecycleState] is the same
/// question asked differently.
///
/// # Which states count as hidden, and why not all of them
///
/// Only `paused` and `hidden` are reported. `inactive` deliberately is not: on
/// iOS it fires for every transient interruption - the control centre being
/// pulled down, a notification banner, the app switcher being *previewed* and
/// dismissed - and a subscription plan recomputed on each of those would cost
/// the room a resubscription every time somebody glanced at a notification.
/// `detached` is not reported either, because a client being torn down has a
/// leave to send rather than a preference to express.
///
/// **This only ever drops video.** A backgrounded client is still in the
/// conversation and still hears the room - which is why it is safe to report
/// eagerly, and why the phone in somebody's pocket does not go quiet.
class VoiceAppVisibility {
  VoiceAppVisibility({required this.onChanged}) {
    _listener = AppLifecycleListener(onStateChange: _handle);
  }

  /// Called only on a genuine transition, with true meaning "hidden".
  final void Function(bool isPaused) onChanged;

  late final AppLifecycleListener _listener;
  bool _isPaused = false;

  bool get isPaused => _isPaused;

  void _handle(AppLifecycleState state) {
    final paused = switch (state) {
      AppLifecycleState.paused || AppLifecycleState.hidden => true,
      AppLifecycleState.resumed => false,
      // See the class comment: too noisy to act on, and acting on it costs the
      // whole room rather than this client alone.
      AppLifecycleState.inactive || AppLifecycleState.detached => _isPaused,
    };
    if (paused == _isPaused) return;
    _isPaused = paused;
    onChanged(paused);
  }

  void dispose() => _listener.dispose();
}
