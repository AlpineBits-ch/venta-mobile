/// The failure kinds the engine tags its errors with.
///
/// Same vocabulary as Alpine's `MlsErrorKind`, and for the same reason: callers
/// have to tell "this message is from a future epoch, buffer it" apart from
/// "this group is gone, stop trying" without pattern-matching on prose.
enum MlsErrorKind {
  /// The message belongs to an epoch this device has not reached. Fetch the
  /// commits in between and retry - never treat it as corruption.
  wrongEpoch,

  /// The sender is not in the group roster. A valid ciphertext replayed with a
  /// spoofed credential looks exactly like this.
  unknownSender,

  validationError,

  /// No local state for that group: never joined, removed, or wiped.
  groupNotFound,

  /// No signing key loaded for the handle - the session is locked.
  keyNotFound,

  /// The string offered as a recovery code is not one: wrong length, or a
  /// character outside the alphabet.
  ///
  /// Distinct from "that code did not open the wrapping" on purpose. This one is
  /// a typo the user can fix; the other means the code is wrong. Collapsing them
  /// would leave someone re-typing a code that could never have worked with no
  /// idea why.
  recoveryCodeInvalid,

  /// Anything else, including a panic inside the engine.
  mlsError,
}

class MlsException implements Exception {
  const MlsException(this.kind, this.message);

  /// Turns `"WrongEpoch: ..."` back into a typed failure. The prefix is added
  /// by `map_mls_error` on the Rust side.
  factory MlsException.parse(String raw) {
    for (final entry in _prefixes.entries) {
      if (raw.startsWith('${entry.key}:')) {
        return MlsException(
          entry.value,
          raw.substring(entry.key.length + 1).trimLeft(),
        );
      }
    }
    return MlsException(MlsErrorKind.mlsError, raw);
  }

  static const _prefixes = <String, MlsErrorKind>{
    'WrongEpoch': MlsErrorKind.wrongEpoch,
    'UnknownSender': MlsErrorKind.unknownSender,
    'ValidationError': MlsErrorKind.validationError,
    'GroupNotFound': MlsErrorKind.groupNotFound,
    'KeyNotFound': MlsErrorKind.keyNotFound,
    'RecoveryCodeInvalid': MlsErrorKind.recoveryCodeInvalid,
    'MlsError': MlsErrorKind.mlsError,
  };

  final MlsErrorKind kind;
  final String message;

  @override
  String toString() => 'MlsException(${kind.name}): $message';
}
