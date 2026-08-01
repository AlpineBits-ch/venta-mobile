import 'package:flutter/foundation.dart';

/// Counted, surfaced MLS failures - per context.
///
/// Every failure mode on the encrypted read path is silent by nature: a message
/// that will not decrypt looks exactly like a message that has not arrived, and
/// a device that was never admitted to a group looks exactly like a quiet
/// conversation. That silence is why the double-base64 bug shipped undetected,
/// so failures are counted here rather than swallowed at the call site.
///
/// The distinction the UI needs is *"this one message is past the ratchet"*
/// versus *"this device cannot read this conversation at all"*. Nothing in a
/// single failure tells them apart - MLS reports both as a deserialization or
/// epoch error - so the signal is repetition: [unreadableThreshold] consecutive
/// failures with no success in between means the device is out, and
/// [cannotRead] flips. One success clears the count, because a working ratchet
/// that skipped a couple of old messages is not a broken device.
///
/// Deliberately not a stream: the banner and the badge are both pull-based and
/// rebuild off [ChangeNotifier]. A stream would need a subscription per open
/// thread for a value that is read once per build.
class MlsFailureLog extends ChangeNotifier {
  MlsFailureLog();

  /// The instance the app uses. A plain static rather than a `getIt`
  /// registration because the FCM background isolate and the notification
  /// service extension path both reach the decrypt code with no container to
  /// resolve from; tests pass their own instance instead.
  static final MlsFailureLog shared = MlsFailureLog();

  /// Consecutive failures before a context is called unreadable.
  ///
  /// Not 1: paging back through history legitimately walks off the end of the
  /// ratchet, and calling that "re-link this device" would tell almost every
  /// user to wipe their keys for messages that predate their join.
  static const unreadableThreshold = 3;

  final _decryptFailures = <String, int>{};
  final _joinFailures = <String, int>{};
  final _lastReason = <String, String>{};

  int decryptFailures(String contextId) => _decryptFailures[contextId] ?? 0;

  int joinFailures(String contextId) => _joinFailures[contextId] ?? 0;

  /// The last thing that went wrong here, for the diagnostics line under the
  /// banner. Free-form: it is the engine's own message, and paraphrasing it
  /// would lose the one detail that makes a bug report actionable.
  String? lastReason(String contextId) => _lastReason[contextId];

  /// True when this device has failed often enough that the honest answer is
  /// "it is not in this group", not "that message was old".
  bool cannotRead(String contextId) =>
      decryptFailures(contextId) >= unreadableThreshold ||
      joinFailures(contextId) >= unreadableThreshold;

  /// Contexts currently reporting as unreadable, for a settings-screen summary.
  Iterable<String> get unreadableContexts =>
      {..._decryptFailures.keys, ..._joinFailures.keys}.where(cannotRead);

  void recordDecryptFailure({
    required String contextId,
    required String messageId,
    required Object reason,
  }) {
    _lastReason[contextId] = reason.toString();
    final before = cannotRead(contextId);
    _decryptFailures[contextId] = decryptFailures(contextId) + 1;
    debugPrint(
      'MLS: could not decrypt $messageId in $contextId '
      '(${decryptFailures(contextId)} in a row): $reason',
    );
    if (!before && cannotRead(contextId)) notifyListeners();
  }

  void recordJoinFailure({required String contextId, required Object reason}) {
    _lastReason[contextId] = reason.toString();
    final before = cannotRead(contextId);
    _joinFailures[contextId] = joinFailures(contextId) + 1;
    debugPrint(
      'MLS: could not join $contextId '
      '(${joinFailures(contextId)} in a row): $reason',
    );
    if (!before && cannotRead(contextId)) notifyListeners();
  }

  /// Anything that proves this device is still in the group: a decrypt, a join,
  /// an applied commit. Clears the streak rather than decrementing it - the
  /// count means "consecutive", and a device that reads one message is a device
  /// that holds the keys.
  void recordSuccess(String contextId) {
    if (!_decryptFailures.containsKey(contextId) &&
        !_joinFailures.containsKey(contextId)) {
      return;
    }
    final before = cannotRead(contextId);
    _decryptFailures.remove(contextId);
    _joinFailures.remove(contextId);
    _lastReason.remove(contextId);
    if (before) notifyListeners();
  }

  /// On sign-out and account switch. The counts belong to one account's view of
  /// one set of groups; carrying them across would tell the next user their
  /// brand-new conversations are unreadable.
  void clear() {
    final hadTrouble = unreadableContexts.isNotEmpty;
    _decryptFailures.clear();
    _joinFailures.clear();
    _lastReason.clear();
    if (hadTrouble) notifyListeners();
  }
}
