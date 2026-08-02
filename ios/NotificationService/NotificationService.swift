import Foundation
import UserNotifications

/// Rewrites an incoming message notification before iOS shows it: the encrypted
/// body becomes the real text, and the sender's picture becomes the thumbnail.
///
/// This is iOS's answer to Android's FCM background isolate. Dart cannot draw a
/// notification for a killed app here, and a silent (`content-available`) push
/// is throttled hard enough by the system that a messaging app cannot rely on
/// one - so the backend sends a normal APNs alert carrying `mutable-content: 1`
/// plus the ciphertext, and this extension gets ~30 seconds to improve it.
///
/// The contract with the server is `MessagePushService.BuildData` in
/// Messaging.Application; the Dart equivalent of everything below is
/// `MessagePushDecryptor` and `MessageNotifier`.
///
/// Whatever fails, the notification still goes out. `serviceExtensionTimeWillExpire`
/// is the hard version of that rule: iOS delivers whatever content is in hand at
/// that moment, and an extension that has not called the handler gets the
/// original, untouched payload shown instead.
class NotificationService: UNNotificationServiceExtension {

  /// Must match `AppDelegate.appGroupIdentifier` and both targets' entitlements.
  private static let appGroupIdentifier = "group.gg.venta.mobile"

  /// Avatars are small; anything larger is not one, and an extension has a hard
  /// memory ceiling it will simply be killed for crossing.
  private static let maxAvatarBytes = 2 * 1024 * 1024

  private var contentHandler: ((UNNotificationContent) -> Void)?
  private var bestAttempt: UNMutableNotificationContent?

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = contentHandler
    let content = (request.content.mutableCopy() as? UNMutableNotificationContent)
    bestAttempt = content

    guard let content else {
      contentHandler(request.content)
      return
    }

    let info = request.content.userInfo
    guard string(info, "type") == "message" else {
      contentHandler(content)
      return
    }

    if let decrypted = decryptBody(info) {
      content.body = decrypted
    }

    // Group per conversation so a busy channel collapses into one stack rather
    // than burying everything else on the lock screen.
    if let contextId = string(info, "contextId") {
      content.threadIdentifier = contextId
    }
    if let senderName = string(info, "senderName") {
      content.title = senderName
    }

    attachAvatar(urlString: string(info, "senderAvatarUrl")) { [weak self] attachment in
      if let attachment { content.attachments = [attachment] }
      self?.deliver()
    }
  }

  override func serviceExtensionTimeWillExpire() {
    deliver()
  }

  /// Serialises [deliver] against itself. The two callers are on different
  /// threads - `serviceExtensionTimeWillExpire` on the main one, the avatar
  /// completion on `URLSession`'s delegate queue - so the guard and the nil-out
  /// below are a read-modify-write that both can be inside at once.
  ///
  /// Not theoretical: `dataTask`'s default timeout is 60 seconds and the
  /// extension's budget is about 30, so the avatar fetch outliving the deadline
  /// is the ordinary case rather than the exotic one. Calling a
  /// `UNNotificationServiceExtension` handler twice is a runtime error.
  private let deliveryLock = NSLock()

  /// Idempotent: the timeout and the avatar callback race, and calling the
  /// handler twice is a runtime error.
  private func deliver() {
    deliveryLock.lock()
    let handler = contentHandler
    let content = bestAttempt
    contentHandler = nil
    deliveryLock.unlock()

    // Outside the lock: the handler is iOS's, it can do what it likes, and
    // holding a lock across it is how the other kind of bug starts.
    guard let handler, let content else { return }
    handler(content)
  }

  // MARK: - Decryption

  private func decryptBody(_ info: [AnyHashable: Any]) -> String? {
    // A plaintext message already has its real body in the alert; there is
    // nothing here to improve.
    guard string(info, "encrypted") == "1" else { return nil }

    guard let messageId = string(info, "messageId"),
      let contextId = string(info, "contextId"),
      let userId = string(info, "recipientUserId")
    else { return nil }

    return MlsNotificationDecryptor.decrypt(
      ciphertextB64: string(info, "ciphertext"),
      messageId: messageId,
      contextId: contextId,
      userId: userId,
      authorId: string(info, "authorId"),
      generation: string(info, "mlsGeneration").flatMap(Int.init),
      appGroupIdentifier: Self.appGroupIdentifier)
  }

  // MARK: - Avatar

  /// The avatar URL is unauthenticated (it redirects to object storage), which is
  /// what makes it fetchable from here at all - the extension has no session.
  ///
  /// It also 404s for anyone who never uploaded a picture, so a failed fetch is
  /// the normal "no avatar" path and not an error worth reporting.
  private func attachAvatar(
    urlString: String?, completion: @escaping (UNNotificationAttachment?) -> Void
  ) {
    guard let urlString, let url = URL(string: urlString) else {
      completion(nil)
      return
    }

    let task = URLSession.shared.dataTask(with: url) { data, response, _ in
      guard let data, !data.isEmpty, data.count <= Self.maxAvatarBytes,
        (response as? HTTPURLResponse)?.statusCode == 200
      else {
        completion(nil)
        return
      }

      // UNNotificationAttachment insists on a file URL, and copies the file into
      // its own store - so a name unique per delivery is enough and nothing here
      // needs cleaning up.
      let destination = FileManager.default.temporaryDirectory
        .appendingPathComponent("venta-avatar-\(UUID().uuidString)")
      do {
        try data.write(to: destination)
        completion(try UNNotificationAttachment(identifier: "avatar", url: destination))
      } catch {
        try? FileManager.default.removeItem(at: destination)
        completion(nil)
      }
    }
    task.resume()
  }

  // MARK: -

  /// APNs custom data is always strings on the wire, but going through
  /// `as? String` on an `[AnyHashable: Any]` is easy to get subtly wrong, so it
  /// happens in exactly one place.
  private func string(_ info: [AnyHashable: Any], _ key: String) -> String? {
    guard let value = info[key] as? String, !value.isEmpty else { return nil }
    return value
  }
}
