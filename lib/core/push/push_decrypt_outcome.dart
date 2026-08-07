/// Why a message push did or did not become readable text.
///
/// The Android counterpart to `NseOutcome` in `ios/NotificationService/`, and
/// deliberately the same vocabulary: the two platforms run different code in
/// different languages against the same MLS state, and a report is only useful
/// if "this device was never in the group" reads the same whichever handset it
/// came from. `push_decrypt_diagnostics_test.dart` asserts the shared names stay
/// aligned with `NseDiagnosticsReporter.knownOutcomes`.
///
/// This exists because the Android path had no diagnosis at all. Every failure
/// in [MessagePushDecryptor] collapses to null by design - a notification that
/// says the wrong thing beats one that never arrives - and the caller then shows
/// the server's placeholder. That placeholder is also exactly what a *correctly
/// working* client shows when the device genuinely cannot read the message, so
/// "I always see 'You have a new encrypted message'" described a dozen distinct
/// causes and none of them left a trace: the FCM background isolate has no
/// Sentry, and `debugPrint` goes to a console nobody is attached to in
/// production.
enum PushDecryptOutcome {
  /// Read off the wire and decrypted here.
  decrypted,

  /// Already decrypted by the app over the websocket, which usually wins when
  /// the app is merely backgrounded.
  servedFromCache,

  /// A plaintext message: `body` was the real text all along. Worth recording
  /// because it is indistinguishable from a failure at the notification, and a
  /// run of these on a conversation the user believes is encrypted means the
  /// server is not setting `encrypted`.
  notEncrypted,

  /// No `recipientUserId` on the payload, so nothing below could name a
  /// directory. An old server, or a field lost in transit.
  noRecipient,

  /// The push names an account this process does not have loaded. Correct
  /// behaviour, not a fault: repointing the process-global engine would tear
  /// down the live session's groups and signers.
  otherAccountLoaded,

  /// The keychain would not give up the state key, so the sealed state file
  /// cannot be opened. Usually a background isolate reaching a keystore that is
  /// unavailable before first unlock.
  stateKeyUnavailable,

  /// The server sent no ciphertext: it did not fit in FCM's 4KB data budget and
  /// said so with `truncated`. The placeholder is the correct answer.
  noCiphertext,

  /// Neither the payload nor the local registry could name a generation.
  noGeneration,

  /// A generation is known but this device holds no group for it - it was never
  /// admitted, or the Welcome was never processed. The placeholder is correct
  /// here too, though a run of these on a conversation the user can read in the
  /// app is a real bug wearing an expected outcome's clothes.
  noGroupForGeneration,

  /// The engine refused to open the state directory.
  initStorageFailed,

  /// openmls could not process the message. Most often a ratchet that has
  /// already moved past this message.
  processMessageFailed,

  /// A commit or proposal rather than an application message - there is no text
  /// in it to show.
  notApplicationMessage,

  /// Decrypted, but openmls could not name the sender. Refused rather than
  /// shown: a lock screen is the one place the app asserts "X sent you this".
  senderUnnamed,

  /// Decrypted, but sealed by someone other than the author the server named.
  senderMismatch,

  /// Decrypted and named, but the sender is not in the group's roster at this
  /// epoch.
  senderNotInRoster,

  /// The plaintext was not valid base64 UTF-8.
  undecodablePlaintext,

  /// Anything that threw. [PushDecryptResult.detail] carries the message.
  threw;

  /// Outcomes where the placeholder is the *correct* answer and nothing is
  /// broken. Mirrors `NseDiagnosticsReporter`'s set, and for the same reason:
  /// reported, but at a level that does not drown the ones that are always
  /// wrong.
  static const expected = {
    decrypted,
    servedFromCache,
    notEncrypted,
    noGroupForGeneration,
    noCiphertext,
  };

  /// Nothing to report: it worked, one way or the other.
  bool get isSuccess =>
      this == decrypted || this == servedFromCache || this == notEncrypted;

  bool get isExpected => expected.contains(this);
}

/// What [MessagePushDecryptor] produced, and why.
///
/// A record rather than a bare `String?` so the reason survives the call. The
/// text alone cannot carry it: null means "show the placeholder" for a dozen
/// different reasons, and telling them apart is the whole point.
class PushDecryptResult {
  const PushDecryptResult(this.text, this.outcome, {this.detail});

  const PushDecryptResult.failed(PushDecryptOutcome outcome, {String? detail})
    : this(null, outcome, detail: detail);

  /// The readable body, or null when the caller should show the server's
  /// placeholder.
  final String? text;

  final PushDecryptOutcome outcome;

  /// Free text for the outcomes that have something to add - an exception
  /// message, a generation number. Never the plaintext.
  final String? detail;
}
