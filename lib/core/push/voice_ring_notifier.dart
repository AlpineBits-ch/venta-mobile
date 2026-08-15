import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'voice_ring_push_payload.dart';

/// Draws the tray entry for a voice-ring push while the app is **foregrounded**,
/// and takes it down again on the cancel.
///
/// The server sends these as a plain alert - nothing is encrypted, so it already
/// knows what the notification says - which means the OS draws it itself
/// whenever the app is backgrounded or dead. This exists for the case the OS
/// skips: a notification-block push arriving while the app is in front is
/// delivered to `onMessage` and displayed by nobody.
///
/// **Nothing here goes near CallKit.** A ring is not a call: nobody is on the
/// line, there is no media session, and it must not appear in the phone log. The
/// deliberate choice not to use a VoIP push is what makes that possible, since a
/// VoIP payload obliges iOS to report a call to CallKit for every one received.
class VoiceRingNotifier {
  const VoiceRingNotifier._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Its own channel, not the messages one and not the calls one.
  ///
  /// Somebody who does not want to be pulled into voice channels can silence
  /// exactly that without also silencing their conversations - which is the
  /// whole argument for a separate channel, and the reason it is high priority
  /// rather than max: it is an invitation, not a ringing phone.
  static const channel = AndroidNotificationChannel(
    'voice_invites',
    'Voice invites',
    description: 'When somebody asks you to join a voice channel',
    importance: Importance.high,
  );

  static Future<void>? _channelCreation;

  static Future<void> _ensureChannel() async {
    _channelCreation ??= _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await _channelCreation;
  }

  static Future<void> show(VoiceRingPushPayload payload) async {
    // The queue outlived the invitation. Drawing it would put a card on screen
    // that cannot be accepted and will never resolve, because the resolution
    // went out while this was still in transit.
    if (payload.isStale) return;

    try {
      await _ensureChannel();

      await _plugin.show(
        id: payload.notificationTag.hashCode,
        // Resolved from the localization key where the server sent one, so this
        // says exactly what the OS-drawn version of the same push would have -
        // see [VoiceStrings].
        title: payload.localizedTitle,
        body: payload.localizedBody,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            // The server's own collapse key, so a second push about one ring
            // replaces the first - and so [cancel] can address exactly this.
            tag: payload.notificationTag,
            timeoutAfter: payload.expiresInSeconds * 1000,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload.ringId,
      );
    } catch (e, stack) {
      debugPrint('VoiceRingNotifier: failed to show ${payload.ringId}: $e\n$stack');
    }
  }

  /// Takes the card off the lock screen. Silent, data-only, no alert - that is
  /// the whole job of the cancel push.
  static Future<void> cancel(VoiceRingPushPayload payload) async {
    try {
      await _plugin.cancel(
        id: payload.notificationTag.hashCode,
        tag: payload.notificationTag,
      );
    } catch (e) {
      debugPrint('VoiceRingNotifier: failed to cancel ${payload.ringId}: $e');
    }
  }
}
