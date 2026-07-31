import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../mls/mls_store.dart';
import 'message_push_decryptor.dart';
import 'message_push_payload.dart';
import 'sender_avatar_cache.dart';

/// Builds and posts the tray entry for a new message.
///
/// Shared by the foreground listener and the FCM background isolate, because
/// they need to produce exactly the same notification and the background one has
/// no access to anything the app set up. That is also why [_ensureInitialized]
/// exists: a background isolate gets a fresh
/// [FlutterLocalNotificationsPlugin] that has never been initialized, and
/// `show` on an uninitialized plugin throws instead of notifying.
class MessageNotifier {
  const MessageNotifier._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  static const channel = AndroidNotificationChannel(
    'messages',
    'Messages',
    description: 'New direct messages and server messages',
    importance: Importance.high,
  );

  /// Held as a future, not a bool: two pushes can arrive close enough together
  /// that the second reaches `show` while the first is still initializing, and
  /// `show` on a half-initialized plugin throws.
  static Future<void>? _initialization;

  /// [onTap] is only wired up by the app; the background isolate has no router
  /// to navigate. A tap that happens while the app is not running is delivered
  /// again through `FirebaseMessaging.getInitialMessage` instead.
  static Future<void> _ensureInitialized({
    void Function(NotificationResponse)? onTap,
  }) =>
      // Cleared on failure: a cached failed future would mean one bad
      // initialization silently costs every notification from then on.
      _initialization ??= _initialize(onTap).onError((error, stack) {
        _initialization = null;
        Error.throwWithStackTrace(error!, stack);
      });

  static Future<void> _initialize(
    void Function(NotificationResponse)? onTap,
  ) async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: onTap,
    );
  }

  /// Called once from `PushNotificationService.start`, and always before any
  /// push can reach [show] in this isolate - which is what guarantees the tap
  /// handler is the one that gets registered.
  static Future<void> initializeForApp({
    required void Function(NotificationResponse) onTap,
  }) => _ensureInitialized(onTap: onTap);

  /// Decrypts if it can, fetches the sender's picture if it can, and shows the
  /// result. Neither step is allowed to prevent the notification.
  ///
  /// [store] is the app's own MLS store when the app is the caller - see
  /// [MessagePushDecryptor.decrypt] for why sharing it is not optional.
  static Future<void> show(MessagePushPayload payload, {MlsStore? store}) async {
    try {
      await _ensureInitialized();

      final decrypted = await MessagePushDecryptor.decrypt(
        payload,
        store: store,
      );
      final body = decrypted ?? payload.placeholderBody;
      final avatarPath = await SenderAvatarCache.fetch(payload.senderAvatarUrl);

      final sender = Person(
        name: payload.senderName,
        key: payload.authorId,
        icon: avatarPath == null ? null : BitmapFilePathAndroidIcon(avatarPath),
      );

      await _plugin.show(
        // Keyed on the message, so a redelivered push replaces its own entry
        // rather than stacking a duplicate on top of it.
        id: payload.messageId.hashCode,
        title: payload.senderName,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            // Bundles a conversation's notifications under one heading instead
            // of scattering them through the shade.
            groupKey: payload.contextId,
            largeIcon: avatarPath == null
                ? null
                : FilePathAndroidBitmap(avatarPath),
            // The messaging style is what makes Android draw the avatar as a
            // chat notification - large icon alone gets a generic app entry with
            // a picture stuck on the side.
            styleInformation: MessagingStyleInformation(
              // The *local* user, which is what Android's MessagingStyle takes
              // here - it is only ever drawn for messages with no sender of
              // their own, and this notification's one message has one.
              Person(name: 'You', key: payload.recipientUserId),
              groupConversation: payload.isChannel,
              messages: [Message(body, DateTime.now(), sender)],
            ),
          ),
          iOS: DarwinNotificationDetails(
            attachments: avatarPath == null
                ? null
                : [DarwinNotificationAttachment(avatarPath)],
          ),
        ),
        payload: payload.route,
      );
    } catch (e, stack) {
      // A background isolate that throws here drops the notification silently,
      // which is the single worst outcome available.
      debugPrint('MessageNotifier: failed to show ${payload.messageId}: $e\n$stack');
    }
  }
}
