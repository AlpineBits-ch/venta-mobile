import Foundation

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
/// The engine is opened *read-only* (see `init_storage` in the Rust crate). The
/// extension is a separate process: it would load state at one moment and write
/// it back at another, and anything the app committed in between would be
/// silently replaced by the older copy. Losing the ratchet step this decrypt
/// consumed costs nothing, because the plaintext is written to the message cache,
/// which is where the app reads history from anyway.
enum MlsNotificationDecryptor {

  /// Plaintext for `messageId`, or nil when this device cannot produce it.
  static func decrypt(
    ciphertextB64: String?,
    messageId: String,
    contextId: String,
    userId: String,
    authorId: String?,
    generation: Int?,
    appGroupIdentifier: String
  ) -> String? {
    guard
      let container = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    else { return nil }

    let stateDirectory =
      container
      .appendingPathComponent("mls", isDirectory: true)
      .appendingPathComponent(sanitize(userId), isDirectory: true)

    let cacheURL = stateDirectory.appendingPathComponent("mls_message_cache.json")

    // The app may already have read this off the websocket. Checking first also
    // keeps a redelivered push from being the thing that discovers the ratchet
    // has moved past this message.
    var cache = readStringMap(cacheURL)
    if let cached = cache[messageId], let text = decodeBase64Text(cached) {
      return text
    }

    guard let ciphertextB64, !ciphertextB64.isEmpty else { return nil }

    guard
      let groupId = groupId(
        registry: readAnyMap(stateDirectory.appendingPathComponent("mls_group_registry.json")),
        contextId: contextId,
        generation: generation)
    else { return nil }

    guard
      call("initStorage", ["dir": stateDirectory.path, "readOnly": true]) != nil
    else { return nil }

    guard
      let processed = call(
        "processMessage", ["groupIdB64": groupId, "messageB64": ciphertextB64])
        as? [String: Any],
      processed["kind"] as? String == "application",
      let plaintextB64 = processed["plaintext"] as? String
    else { return nil }

    guard
      senderIsWhoTheServerSaid(
        processed: processed, groupId: groupId, authorId: authorId, messageId: messageId)
    else { return nil }

    // MLS reads a message off the wire exactly once, and the app never sees this
    // one arrive. Without this write the conversation the user is about to open
    // shows "cannot decrypt" for the very message they just read in the tray.
    cache[messageId] = plaintextB64
    writeStringMap(cache, to: cacheURL)

    return decodeBase64Text(plaintextB64)
  }

  /// Both that the sender is in the group's roster - a compromised server can
  /// replay a valid ciphertext under a credential that was never a member - and
  /// that they are the account the server named as the author. The second check
  /// is specific to notifications: this is the one place the app puts "X said
  /// this" on a lock screen, where nobody will open the conversation and notice
  /// it was someone else.
  private static func senderIsWhoTheServerSaid(
    processed: [String: Any], groupId: String, authorId: String?, messageId: String
  ) -> Bool {
    guard let sender = processed["senderIdentity"] as? String else { return true }

    if let authorId, sender != authorId {
      NSLog("[venta] %@ was sealed by %@ but attributed to %@", messageId, sender, authorId)
      return false
    }

    guard let members = call("getMembers", ["groupIdB64": groupId]) as? [[String: Any]] else {
      return false
    }
    return members.contains { ($0["identity"] as? String) == sender }
  }

  // MARK: - Group registry
  //
  // `contextId#<generation>` -> base64 group id, plus `contextId#active` ->
  // generation. Keyed by generation because encryption can be switched off and
  // back on, and each stretch is a distinct group whose epochs restart at zero.

  private static func groupId(registry: [String: Any], contextId: String, generation: Int?)
    -> String?
  {
    let resolved = generation ?? (registry["\(contextId)#active"] as? Int)
    guard let resolved else { return nil }
    return registry["\(contextId)#\(resolved)"] as? String
  }

  /// Must match `MlsStore._sanitize` in Dart exactly, or the extension looks in a
  /// directory the app never wrote to.
  private static func sanitize(_ userId: String) -> String {
    String(
      userId.map { character in
        character.isASCII
          && (character.isLetter || character.isNumber || character == "_" || character == "."
            || character == "-")
          ? character : "_"
      })
  }

  // MARK: - Engine

  /// One engine command. Returns the decoded `ok` value, or nil on any error -
  /// the caller's only recourse either way is the server's placeholder text.
  private static func call(_ command: String, _ args: [String: Any]) -> Any? {
    guard let argsData = try? JSONSerialization.data(withJSONObject: args),
      let argsJson = String(data: argsData, encoding: .utf8)
    else { return nil }

    guard let raw = venta_mls_call(command, argsJson) else { return nil }
    defer { venta_mls_free(raw) }

    let response = String(cString: raw)
    guard let data = response.data(using: .utf8),
      let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return nil }

    if let error = decoded["error"] {
      NSLog("[venta] MLS %@ failed: %@", command, String(describing: error))
      return nil
    }
    // NSNull for commands whose result is void; the caller casts and gets nil,
    // which is why initStorage is checked for `!= nil` rather than for a value.
    return decoded["ok"] ?? NSNull()
  }

  // MARK: - Files

  private static func readStringMap(_ url: URL) -> [String: String] {
    readAnyMap(url).compactMapValues { $0 as? String }
  }

  private static func readAnyMap(_ url: URL) -> [String: Any] {
    guard let data = try? Data(contentsOf: url),
      let decoded = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else { return [:] }
    return decoded
  }

  /// Re-reads and merges before writing. The app writes this same file whole, so
  /// a plain overwrite from here deletes whatever it decrypted while this
  /// extension was running - and those messages can never be read again.
  private static func writeStringMap(_ values: [String: String], to url: URL) {
    var merged = readStringMap(url)
    for (key, value) in values { merged[key] = value }

    guard let data = try? JSONSerialization.data(withJSONObject: merged) else { return }
    let temporary = url.appendingPathExtension("tmp")
    do {
      try data.write(to: temporary, options: .atomic)
      _ = try FileManager.default.replaceItemAt(url, withItemAt: temporary)
    } catch {
      NSLog("[venta] could not write the message cache: %@", String(describing: error))
      try? FileManager.default.removeItem(at: temporary)
    }
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
