import Foundation
import Security

/// Reads the app's MLS state well enough to turn one ciphertext into one line of
/// notification text.
///
/// A deliberately small re-implementation of `MessagePushDecryptor` (Dart) rather
/// than a shared one: an extension cannot run Dart, and the only thing it needs
/// from the app's MLS layer is "which group, then decrypt". The two must agree on
/// the file layout - `mls/<sanitized user id>/mls_state.json`,
/// `mls_group_registry.json` and `mls_message_cache.json` - and on the fact that
/// both the registry values and the cached plaintext are base64.
///
/// **All three files are sealed on disk** under a key that lives in the keychain
/// and not in the App Group container - see `MlsStore` and `StateFileCipher` on
/// the Dart side. That is the whole point of the scheme: the container is what a
/// device backup carries and the keychain is what it does not. This extension is
/// a full participant in it, and every path below that cannot get the key
/// declines to do anything rather than falling back to plaintext. Writing an
/// unsealed file over a sealed one would not merely undo the sealing, it would
/// replace the device's entire decrypted history with whatever single message
/// this push happens to carry.
///
/// The engine is opened *read-only* (see `init_storage` in the Rust crate). The
/// extension is a separate process: it would load state at one moment and write
/// it back at another, and anything the app committed in between would be
/// silently replaced by the older copy. Losing the ratchet step this decrypt
/// consumed costs nothing, because the plaintext is written to the message cache,
/// which is where the app reads history from anyway.
enum MlsNotificationDecryptor {

  /// What one decrypt attempt produced, and - when it produced nothing - why.
  ///
  /// The reason is the point. Every path below used to `return nil`, so a
  /// keychain refusal, a device that was never admitted to the group, and a
  /// ratchet that has moved on were one outcome, on the one code path that
  /// cannot be attached to a debugger. See [NseOutcome].
  struct DecryptResult {
    let text: String?
    let outcome: NseOutcome

    /// Free-form, for the cases where the code alone is not the whole answer -
    /// an `OSStatus`, the group an item was really found in, the engine's own
    /// error string. Never message content.
    let detail: String?

    /// Something worth reporting that did **not** stop the decrypt. There is
    /// exactly one today - the state key turning up in an access group other
    /// than the one asked for - and it has to survive a success, because the
    /// whole point is that it works while being wrong.
    var warning: (outcome: NseOutcome, detail: String?)?

    static func ok(_ text: String, _ outcome: NseOutcome) -> DecryptResult {
      DecryptResult(text: text, outcome: outcome, detail: nil)
    }

    static func failed(_ outcome: NseOutcome, _ detail: String? = nil) -> DecryptResult {
      DecryptResult(text: nil, outcome: outcome, detail: detail)
    }
  }

  /// Plaintext for `messageId`, or the reason this device cannot produce it.
  static func decrypt(
    ciphertextB64: String?,
    messageId: String,
    contextId: String,
    userId: String,
    authorId: String?,
    generation: Int?,
    appGroupIdentifier: String
  ) -> DecryptResult {
    guard
      let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    else { return .failed(.noAppGroupContainer, appGroupIdentifier) }

    let stateDirectory =
      container
      .appendingPathComponent("mls", isDirectory: true)
      .appendingPathComponent(sanitize(userId), isDirectory: true)

    let cacheURL = stateDirectory.appendingPathComponent("mls_message_cache.json")

    // Fetched once and threaded through, because every file below needs it and a
    // keychain that answers on one call and not the next would otherwise have
    // this process reading a sealed cache and writing an unsealed one.
    let lookup = Self.stateKey(userId: userId)
    let stateKey = lookup.key
    // Carried onto whatever this call returns, success or failure. The one
    // warning that exists means "this worked, and it should not have".
    let warning: (outcome: NseOutcome, detail: String?)? =
      stateKey != nil && lookup.outcome != nil
      ? (lookup.outcome!, lookup.detail) : nil

    func finish(_ result: DecryptResult) -> DecryptResult {
      var out = result
      out.warning = warning
      return out
    }

    // A nil read is "there is something here and this process cannot have it".
    // Not an empty file: carrying on would mean writing over the plaintext of
    // every message this device has ever decrypted, none of which can be
    // produced a second time. The server's placeholder text is the correct
    // outcome.
    //
    // Reported as the *keychain* failure when that is what it was. A sealed file
    // is only unreadable here because the key is missing, and "the keychain said
    // -34018" is an answer where "a file would not open" is a symptom.
    //
    // The registry comes first because the cache key needs the generation out of
    // it, which `MessagePushDecryptor` also resolves before it looks anything up.
    guard
      let registry = read(
        stateDirectory.appendingPathComponent("mls_group_registry.json"), stateKey: stateKey),
      let cacheFile = read(cacheURL, stateKey: stateKey)
    else {
      return finish(
        stateKey == nil
          ? .failed(lookup.outcome ?? .stateKeyUnavailable, lookup.detail)
          : .failed(.sealedFileUnreadable, nil))
    }

    let resolvedGeneration = generation ?? (registry.values["\(contextId)#active"] as? Int)
    let key = cacheKey(contextId: contextId, generation: resolvedGeneration, messageId: messageId)
    var cache = cacheFile.strings

    // The app may already have read this off the websocket. Checking first also
    // keeps a redelivered push from being the thing that discovers the ratchet
    // has moved past this message.
    //
    // The bare `messageId` is the shape this extension used to write, and is
    // read - never written - for the same reason `MlsStore.cachedMessage` still
    // reads it: the entries are already on devices, and each one is plaintext
    // MLS will not hand over again.
    if let cached = cache[key] ?? cache[messageId], let text = decodeBase64Text(cached) {
      return finish(.ok(text, .servedFromCache))
    }

    guard let ciphertextB64, !ciphertextB64.isEmpty else { return finish(.failed(.noCiphertext)) }

    guard let resolvedGeneration else { return finish(.failed(.noGeneration)) }

    guard let groupId = registry.values["\(contextId)#\(resolvedGeneration)"] as? String else {
      // The ordinary reading is that this device was never admitted to the
      // group, which makes the placeholder the correct outcome for this
      // message - and makes a run of these the signal that a Welcome was never
      // processed.
      return finish(.failed(.noGroupForGeneration, "generation \(resolvedGeneration)"))
    }

    // `stateKeyB64` is omitted rather than sent as null when there is no key, so
    // the engine's own "sealed but no key was supplied" error is what fires
    // against a sealed `mls_state.json` - see `init_storage`.
    var storageArgs: [String: Any] = ["dir": stateDirectory.path, "readOnly": true]
    if let stateKey { storageArgs["stateKeyB64"] = stateKey }
    guard call("initStorage", storageArgs) != nil else {
      return finish(.failed(.initStorageFailed, lastEngineError))
    }

    guard
      let processed = call(
        "processMessage", ["groupIdB64": groupId, "messageB64": ciphertextB64])
        as? [String: Any]
    else { return finish(.failed(.processMessageFailed, lastEngineError)) }

    guard processed["kind"] as? String == "application",
      let plaintextB64 = processed["plaintext"] as? String
    else {
      return finish(.failed(.notApplicationMessage, processed["kind"] as? String))
    }

    let attribution = senderIsWhoTheServerSaid(
      processed: processed, groupId: groupId, authorId: authorId, messageId: messageId)
    if let attribution { return finish(.failed(attribution)) }

    guard let text = decodeBase64Text(plaintextB64) else {
      return finish(.failed(.undecodablePlaintext))
    }

    // MLS reads a message off the wire exactly once, and the app never sees this
    // one arrive. Without this write the conversation the user is about to open
    // shows "cannot decrypt" for the very message they just read in the tray.
    //
    // After the attribution check, not before: a message this extension refuses
    // to show must not be cached as though the app had read it.
    cache[key] = plaintextB64
    writeStringMap(cache, to: cacheURL, stateKey: stateKey)

    return finish(.ok(text, .decrypted))
  }

  /// Both that the sender is in the group's roster - a compromised server can
  /// replay a valid ciphertext under a credential that was never a member - and
  /// that they are the account the server named as the author. The second check
  /// is specific to notifications: this is the one place the app puts "X said
  /// this" on a lock screen, where nobody will open the conversation and notice
  /// it was someone else.
  ///
  /// Returns nil when the attribution holds, or the outcome that refused it.
  private static func senderIsWhoTheServerSaid(
    processed: [String: Any], groupId: String, authorId: String?, messageId: String
  ) -> NseOutcome? {
    // **Fail closed.** This used to return "fine" for a message openmls could
    // not name a sender for, which is the one case where there is nothing at all
    // to check the server's claim against - and the server is what supplied the
    // claim. `MessagePushDecryptor._senderIsWhoTheServerSaid` on the Dart side
    // has always refused it; the lock screen is the half that was permissive.
    guard let sender = processed["senderIdentity"] as? String else { return .senderUnnamed }

    if let authorId, sender != authorId {
      NSLog("[venta] %@ was sealed by %@ but attributed to %@", messageId, sender, authorId)
      return .senderMismatch
    }

    guard let members = call("getMembers", ["groupIdB64": groupId]) as? [[String: Any]] else {
      return .senderNotInRoster
    }
    return members.contains { ($0["identity"] as? String) == sender }
      ? nil : .senderNotInRoster
  }

  // MARK: - Keys
  //
  // The registry is `contextId#<generation>` -> base64 group id, plus
  // `contextId#active` -> generation. Keyed by generation because encryption can
  // be switched off and back on, and each stretch is a distinct group whose
  // epochs restart at zero - which is also why the *cache* is keyed that way.

  /// Must match `MlsStore._cacheKey` in Dart exactly.
  ///
  /// The context and the generation are part of the key, not decoration.
  /// `messageId` is chosen by the **server**, and on the id alone a server that
  /// reuses one it has already used in another conversation gets this device to
  /// render one thread's plaintext inside another - without breaking any MLS
  /// property, because a cache hit decrypts nothing and so checks nothing. This
  /// extension wrote the bare id for a while, which made that reachable on iOS
  /// even though both Dart writers had always keyed it properly.
  ///
  /// `?` for an unresolved generation, again matching Dart: it has to be a
  /// stable string, not "no key at all".
  @inline(__always)
  private static func cacheKey(contextId: String, generation: Int?, messageId: String) -> String {
    "\(contextId)#\(generation.map(String.init) ?? "?")#\(messageId)"
  }

  /// Must match `MlsStore.sanitize` in Dart exactly, or the extension looks in a
  /// directory the app never wrote to.
  ///
  /// `.` is **not** in the allowed set, so `..` cannot survive. It used to be
  /// here, under a comment claiming this matched Dart - which had already
  /// removed it, and pins the removal with tests. Every caller takes its user id
  /// from somewhere the server controls (`recipientUserId`, straight off the
  /// push payload), and `sanitize("..")` returning `".."` walks
  /// `stateDirectory` out of `mls/` and into another account's state.
  private static func sanitize(_ userId: String) -> String {
    String(
      userId.map { character in
        character.isASCII
          && (character.isLetter || character.isNumber || character == "_" || character == "-")
          ? character : "_"
      })
  }

  // MARK: - Engine

  /// The engine's own message from the last failed [call].
  ///
  /// Kept because it is the difference between "processMessage failed" - which
  /// is every decrypt problem there is - and the actual sentence openmls
  /// produced, which names the epoch, the deserialization fault or the missing
  /// group. There is no console to read it off in production.
  private(set) static var lastEngineError: String?

  /// One engine command. Returns the decoded `ok` value, or nil on any error -
  /// the caller's only recourse either way is the server's placeholder text.
  private static func call(_ command: String, _ args: [String: Any]) -> Any? {
    guard let argsData = try? JSONSerialization.data(withJSONObject: args),
      let argsJson = String(data: argsData, encoding: .utf8)
    else {
      lastEngineError = "\(command): arguments could not be encoded"
      return nil
    }

    guard let raw = venta_mls_call(command, argsJson) else {
      lastEngineError = "\(command): the engine returned nothing"
      return nil
    }
    defer { venta_mls_free(raw) }

    let response = String(cString: raw)
    guard let data = response.data(using: .utf8),
      let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
      lastEngineError = "\(command): the engine's reply did not parse"
      return nil
    }

    if let error = decoded["error"] {
      let message = String(describing: error)
      NSLog("[venta] MLS %@ failed: %@", command, message)
      lastEngineError = "\(command): \(message)"
      return nil
    }
    // NSNull for commands whose result is void; the caller casts and gets nil,
    // which is why initStorage is checked for `!= nil` rather than for a value.
    return decoded["ok"] ?? NSNull()
  }

  // MARK: - Keychain
  //
  // The state key is written by Dart's `SecureStorageService.readOrCreateMlsStateKey`
  // through `flutter_secure_storage`, so the query below has to reproduce that
  // plugin's item layout exactly: `kSecClassGenericPassword`, the Dart key as
  // `kSecAttrAccount`, the plugin's default service name, and non-synchronizable.

  /// Must match `AppleOptions.defaultAccountName` in `flutter_secure_storage`.
  private static let keychainService = "flutter_secure_storage_service"

  /// Must match `SecureStorageService.sharedKeychainGroup` exactly.
  ///
  /// The team prefix is spelled out because `$(AppIdentifierPrefix)` in
  /// `NotificationService.entitlements` is a *build-time* substitution: the
  /// runtime access group is the expanded string, and a query for the bare
  /// `gg.venta.mobile.shared` matches nothing and reports it as "no such item".
  /// `S33LPKH83B` is `DEVELOPMENT_TEAM` in `Runner.xcodeproj/project.pbxproj`.
  static let keychainAccessGroup = "S33LPKH83B.gg.venta.mobile.shared"

  /// Must match `SecureStorageService.readOrCreateMlsStateKey`.
  private static func stateKeyAccount(_ userId: String) -> String {
    "venta.mls.statekey.\(userId)"
  }

  /// The key the state files are sealed under, base64, plus what to report when
  /// there isn't one.
  ///
  /// Nothing here creates the item. An extension that minted its own key would
  /// seal the message cache under something the app can never open, which is the
  /// same permanent loss as writing plaintext over it.
  struct KeyLookup {
    let key: String?

    /// Nil when the key was where it was supposed to be. Otherwise the thing to
    /// report - which is not the same as the thing that failed: a key found in
    /// the wrong group still decrypts, and still has to be said out loud.
    let outcome: NseOutcome?
    let detail: String?
  }

  private static func stateKey(userId: String) -> KeyLookup {
    let account = stateKeyAccount(userId)

    var query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: account,
      kSecAttrService: keychainService,
      kSecAttrAccessGroup: keychainAccessGroup,
      kSecAttrSynchronizable: false,
      kSecReturnData: true,
      kSecMatchLimit: kSecMatchLimitOne,
    ]

    // `kSecAttrAccessible` is deliberately **not** in this query. It is part of
    // every query `flutter_secure_storage` builds but is not part of a
    // generic-password item's primary key, which is what stranded the app's own
    // items when the accessibility class changed (see `MigratingSecureStore`).
    // Omitting it here means this lookup matches the item whichever class it was
    // written under, before or after any Dart-side migration.
    var item: CFTypeRef?
    var status = SecItemCopyMatching(query as CFDictionary, &item)

    if status == errSecSuccess, let key = Self.string(item), !key.isEmpty {
      return KeyLookup(key: key, outcome: nil, detail: nil)
    }

    // Not in the group this extension asks for. The group string is built from a
    // hardcoded team prefix - `$(AppIdentifierPrefix)` in the entitlements is a
    // *build-time* substitution, so the runtime value has to be spelled out and
    // cannot be checked by the compiler. Dropping `kSecAttrAccessGroup` searches
    // every group this process is entitled to, which is only its own and
    // `.shared` (see `NotificationService.entitlements` - the app's private
    // group is not among them, so this cannot reach the signing key or the auth
    // tokens).
    //
    // Finding it this way is both the answer and the fix: the notification gets
    // decrypted, and the breadcrumb names the group it was really in, which is
    // the one fact nobody can obtain from a shipped build otherwise.
    if status == errSecItemNotFound {
      query.removeValue(forKey: kSecAttrAccessGroup)
      query[kSecReturnAttributes] = true
      item = nil
      status = SecItemCopyMatching(query as CFDictionary, &item)

      if status == errSecSuccess, let found = item as? [CFString: Any],
        let data = found[kSecValueData] as? Data,
        let key = String(data: data, encoding: .utf8), !key.isEmpty
      {
        let group = found[kSecAttrAccessGroup] as? String ?? "unknown"
        NSLog(
          "[venta] the MLS state key is in %@, not %@", group, keychainAccessGroup)
        return KeyLookup(
          key: key,
          outcome: .stateKeyInAnotherGroup,
          detail: "found in \(group), expected \(keychainAccessGroup)")
      }
    }

    NSLog("[venta] the MLS state key is not readable here: OSStatus %d", status)
    return KeyLookup(
      key: nil,
      outcome: .stateKeyUnavailable,
      detail: "OSStatus \(status) (\(Self.statusName(status)))")
  }

  private static func string(_ item: CFTypeRef?) -> String? {
    guard let data = item as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }

  /// So a breadcrumb is greppable against Apple's docs rather than being a bare
  /// negative number. Mirrors `SecureStorageFault.statusName` on the Dart side.
  private static func statusName(_ status: OSStatus) -> String {
    switch status {
    case errSecItemNotFound: return "errSecItemNotFound"
    case errSecInteractionNotAllowed: return "errSecInteractionNotAllowed"
    case errSecMissingEntitlement: return "errSecMissingEntitlement"
    case errSecAuthFailed: return "errSecAuthFailed"
    case errSecParam: return "errSecParam"
    default: return "unmapped"
    }
  }

  // MARK: - Files

  /// Prefix the engine writes on a sealed host blob. Must match `HOST_BLOB_MAGIC`
  /// in the Rust crate and `StateFileCipher.magic` in Dart.
  private static let hostBlobMagic = Data("VENTABOX1".utf8)

  private struct StateFile {
    let values: [String: Any]

    var strings: [String: String] { values.compactMapValues { $0 as? String } }
  }

  /// The file's contents, or **nil when it is sealed and this process cannot
  /// open it**.
  ///
  /// The distinction is the whole safety property. `[:]` means "there is nothing
  /// here"; nil means "there is something here that must not be touched". A
  /// missing or empty file is the former, and a sealed blob without a working key
  /// is the latter - it holds plaintext MLS will not hand over twice.
  private static func read(_ url: URL, stateKey: String?) -> StateFile? {
    // Absence is the only thing that means empty. `try? Data(contentsOf:)`
    // swallows every other failure too - an I/O error, or the allocation losing
    // against the hard memory ceiling an extension is killed for crossing, which
    // a cache at its 20 000-entry cap is a realistic way to hit. Folding those
    // into `[:]` put the merge back exactly where it started: a single-entry file
    // written over the whole history, sealed if there was a key and *plaintext
    // over sealed* if there was not.
    guard FileManager.default.fileExists(atPath: url.path) else {
      return StateFile(values: [:])
    }
    guard let data = try? Data(contentsOf: url) else {
      NSLog("[venta] %@ exists and could not be read", url.lastPathComponent)
      return nil
    }
    if data.isEmpty { return StateFile(values: [:]) }

    let sealed = data.starts(with: hostBlobMagic)
    var payload = data
    if sealed {
      guard let stateKey, let opened = openHostBlob(data, stateKey: stateKey) else {
        NSLog("[venta] %@ is sealed and this extension cannot open it", url.lastPathComponent)
        return nil
      }
      payload = opened
    }

    guard let decoded = try? JSONSerialization.jsonObject(with: payload) as? [String: Any] else {
      // Plain JSON that will not parse is a corrupt file and can be started over.
      // A blob that opened and then would not parse is not: something is wrong
      // with this reader, and the contents are still irreplaceable.
      return sealed ? nil : StateFile(values: [:])
    }
    return StateFile(values: decoded)
  }

  /// Re-reads and merges before writing. The app writes this same file whole, so
  /// a plain overwrite from here deletes whatever it decrypted while this
  /// extension was running - and those messages can never be read again.
  ///
  /// Both the re-read and the seal fail closed. Either one giving up means the
  /// file on disk stays exactly as it is, and this push loses nothing but a line
  /// of preview text.
  private static func writeStringMap(_ values: [String: String], to url: URL, stateKey: String?) {
    guard let existing = read(url, stateKey: stateKey) else {
      NSLog("[venta] leaving the message cache alone - this extension could not open it")
      return
    }

    var merged = existing.strings
    for (key, value) in values { merged[key] = value }

    guard let json = try? JSONSerialization.data(withJSONObject: merged),
      let data = seal(json, stateKey: stateKey)
    else {
      NSLog("[venta] could not seal the message cache, so it was not written")
      return
    }

    let temporary = url.appendingPathExtension("tmp")
    do {
      try data.write(to: temporary, options: .atomic)
      // `replaceItemAt` **throws when there is nothing to replace**, and the
      // first push to a fresh install is exactly that: no cache file yet,
      // because the app has never decrypted anything. That is the one delivery
      // where this write matters most - the tray shows the message and the
      // conversation would then show "cannot decrypt" for it forever.
      if FileManager.default.fileExists(atPath: url.path) {
        _ = try FileManager.default.replaceItemAt(url, withItemAt: temporary)
      } else {
        try FileManager.default.moveItem(at: temporary, to: url)
      }
    } catch {
      NSLog("[venta] could not write the message cache: %@", String(describing: error))
      try? FileManager.default.removeItem(at: temporary)
    }
  }

  /// Sealed bytes when there is a key, the plaintext when there is not, and nil
  /// when sealing was possible in principle and failed.
  ///
  /// The nil case must not degrade to writing plaintext: the file it would land
  /// on is sealed, and the app would then refuse to read it for the rest of the
  /// installation's life.
  private static func seal(_ plaintext: Data, stateKey: String?) -> Data? {
    guard let stateKey else { return plaintext }
    guard
      let sealedB64 = call(
        "sealHostBlob",
        ["plaintextB64": plaintext.base64EncodedString(), "stateKeyB64": stateKey]) as? String
    else { return nil }
    return Data(base64Encoded: sealedB64)
  }

  private static func openHostBlob(_ sealed: Data, stateKey: String) -> Data? {
    guard
      let plaintextB64 = call(
        "openHostBlob",
        ["sealedB64": sealed.base64EncodedString(), "stateKeyB64": stateKey]) as? String
    else { return nil }
    return Data(base64Encoded: plaintextB64)
  }

  /// The engine and the cache both speak base64 of the UTF-8 bytes - that is what
  /// the sending client sealed, so it is what comes back out.
  private static func decodeBase64Text(_ base64: String) -> String? {
    guard let data = Data(base64Encoded: base64),
      let text = String(data: data, encoding: .utf8),
      !text.isEmpty
    else { return nil }
    return text
  }
}
