import Foundation

/// Why a push notification did or did not get its real text.
///
/// Every failure path in `MlsNotificationDecryptor` used to `return nil`, and
/// the caller's only response either way is the server's placeholder - so
/// "the keychain refused", "this device is not in that group" and "the ratchet
/// has moved past this message" were one indistinguishable outcome on the one
/// code path nobody can attach a debugger to. That is how a decryption failure
/// stayed a mystery: the symptom is identical for a dozen causes, and none of
/// them said anything.
///
/// Some of these are *correct*. `noGroupForGeneration` on a device that was
/// never admitted, or `noKeyMaterialYet` on a fresh install, mean the
/// placeholder is the honest answer. They are still recorded, because "the
/// placeholder is correct here" and "decryption is broken" are the two things
/// that have to be told apart, and only the reason code tells them apart.
enum NseOutcome: String {
  /// The body was replaced with real text.
  case decrypted

  /// The app had already decrypted this over the websocket; the cached
  /// plaintext was used. Also a success.
  case servedFromCache

  /// A plaintext (non-MLS) message. There was nothing to improve.
  case notEncrypted

  // MARK: Failures

  /// `containerURL(forSecurityApplicationGroupIdentifier:)` returned nil - the
  /// App Group entitlement is missing from this build.
  case noAppGroupContainer

  /// The keychain would not hand over the state key. Carries the `OSStatus`,
  /// which is the whole diagnosis: -34018 is a signing/entitlement mistake,
  /// -25308 is a locked device, -25300 is genuinely no such item.
  case stateKeyUnavailable

  /// The state key was not in the access group this extension asks for, but a
  /// group-less search found it somewhere else. Carries the group it was
  /// actually in. Means the hardcoded team prefix is wrong.
  case stateKeyInAnotherGroup

  /// A sealed state file that this process could not open. Distinct from
  /// "missing": the contents are irreplaceable and must not be written over.
  case sealedFileUnreadable

  /// The push carried no ciphertext - the server sends `truncated: 1` instead
  /// when it does not fit in the 4KB FCM budget.
  case noCiphertext

  /// Neither the push nor the registry named a generation for this context,
  /// **and the registry does hold entries**. Carries the same census as
  /// `noGroupForGeneration`.
  case noGeneration

  /// This device's registry has no MLS group for that (context, generation),
  /// **and the registry does hold other entries**. The ordinary reading is that
  /// it was never admitted to that group - which makes the placeholder correct,
  /// and makes a *run* of these the signal that a Welcome was never processed.
  ///
  /// Carries a census of the registry (`entries N, for this context M`). That
  /// one number is what separates this reading from the two below, and nothing
  /// in a shipped build could tell them apart before it was added.
  case noGroupForGeneration

  /// `mls_group_registry.json` does not exist.
  ///
  /// Not an exclusion from one group: nothing was ever recorded, so there is
  /// nothing this device could have been excluded *from*. It means the account
  /// directory was never written, the user id in the push resolves to a
  /// directory the app never populated, or MLS was never initialised on this
  /// handset. All three used to arrive as `noGroupForGeneration` and be read as
  /// its opposite.
  ///
  /// `MlsNotificationDecryptor.read` still answers `[:]` for a missing file, and
  /// must: absence has to stay distinct from sealed-and-unopenable, whose
  /// contents are irreplaceable and must never be written over. This case is
  /// decided by a separate existence check rather than by weakening that one.
  case registryAbsent

  /// `mls_group_registry.json` exists and holds no entries at all.
  ///
  /// Same reading as `registryAbsent` - this device is in no groups whatsoever,
  /// rather than out of one - and kept apart from it because a file that was
  /// written empty and a file that was never written are different bugs.
  case registryEmpty

  /// The engine would not open the state directory.
  case initStorageFailed

  /// `processMessage` failed outright - a deserialization error, or an epoch
  /// the ratchet has already passed.
  case processMessageFailed

  /// The message decrypted but was a commit or a proposal rather than
  /// application data.
  case notApplicationMessage

  /// openmls could not name the sender, so "X said this" cannot be asserted.
  case senderUnnamed

  /// The credential that sealed the message is not the account the server named
  /// as the author. A server-side attribution lie, or a bug.
  case senderMismatch

  /// The sender is not in the group's roster for this epoch.
  case senderNotInRoster

  /// The plaintext came back but was not decodable UTF-8, or was empty.
  case undecodablePlaintext
}

/// A breadcrumb dropped in the App Group container for the app to pick up and
/// report to Sentry on its next launch or resume.
///
/// The extension cannot report anything itself. `sentry-cocoa` is a CocoaPod on
/// the `Runner` target only, and there is no NotificationService target in the
/// `Podfile` - adding one is a `project.pbxproj` change that
/// `docs/push-decryption.md` records as having cost a release cycle the last
/// two times it was attempted from a machine without Xcode. The container is
/// already shared, already written by both processes, and needs no build change
/// at all.
///
/// **Deliberately unsealed, and therefore deliberately contentless.** The whole
/// class of failure being diagnosed here is "the state key was unavailable", so
/// a diagnostic sealed under that key would be silent in exactly the case it
/// exists for. What it carries is a reason code, ids that were already in the
/// push in the clear, and an `OSStatus`. No plaintext, no ciphertext, no
/// display names.
enum NseDiagnostics {

  /// Kept small enough that the app's drain is one cheap read. An extension
  /// firing more often than the app launches is itself the interesting signal,
  /// and the newest entries are the ones worth keeping.
  private static let maxEntries = 50

  static func record(
    _ outcome: NseOutcome,
    appGroupIdentifier: String,
    messageId: String?,
    contextId: String?,
    detail: String? = nil
  ) {
    NSLog(
      "[venta] notification %@: %@%@",
      messageId ?? "?", outcome.rawValue, detail.map { " (\($0))" } ?? "")

    // Successes are logged for a local `log stream` session and nothing more.
    // The app already knows a notification it decrypted went well, and a
    // breadcrumb per delivered message would be the file's whole budget.
    switch outcome {
    case .decrypted, .servedFromCache, .notEncrypted: return
    default: break
    }

    guard
      let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    else { return }

    var entry: [String: Any] = [
      "outcome": outcome.rawValue,
      "at": ISO8601DateFormatter().string(from: Date()),
    ]
    if let messageId { entry["messageId"] = messageId }
    if let contextId { entry["contextId"] = contextId }
    if let detail { entry["detail"] = detail }

    let url = container.appendingPathComponent("nse-diagnostics.json")

    // Read-modify-write with no coordination. Two pushes arriving together can
    // lose one entry, which for a diagnostic is a fair trade against an
    // `NSFileCoordinator` deadlock inside a process iOS kills for taking too
    // long.
    var entries: [[String: Any]] = []
    if let data = try? Data(contentsOf: url),
      let existing = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
    {
      entries = existing
    }
    entries.append(entry)
    if entries.count > maxEntries { entries.removeFirst(entries.count - maxEntries) }

    guard let out = try? JSONSerialization.data(withJSONObject: entries) else { return }
    try? out.write(to: url, options: .atomic)
  }
}
