import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'household_push_payload.dart';

/// Draws the tray entry for a household alert push while the app is
/// **foregrounded**, and only then.
///
/// Unlike the message path, the server sends these as a plain alert - nothing
/// is encrypted, so it already knows what the notification says. That means the
/// OS draws it itself whenever the app is backgrounded or dead, on both
/// platforms, and this class exists solely for the case the OS skips: a
/// notification-block push that arrives while the app is in front is delivered
/// to `onMessage` and displayed by nobody. "Your turn, and it's due now" is
/// worth seeing whether or not the app happens to be open.
///
/// Drawing it in the FCM background isolate too would show every reminder
/// twice.
class HouseholdNotifier {
  const HouseholdNotifier._();

  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Separate from the messages channel so a house can silence its chores and
  /// its ledger without silencing their conversations - they're wanted at very
  /// different times of day.
  static const channel = AndroidNotificationChannel(
    'household',
    'Home',
    description: 'Chores, expenses, decisions and everything else at home',
    importance: Importance.high,
  );

  static Future<void>? _channelCreation;

  static Future<void> show(HouseholdPushPayload payload) async {
    try {
      _channelCreation ??= _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
      await _channelCreation;

      await _plugin.show(
        // Keyed on the row, matching the server's own collapse key: a second
        // reminder about one chore replaces the first instead of stacking.
        id: (payload.targetId ?? payload.kind).hashCode,
        // Resolved from the localization key where the server sent one, so this
        // says exactly what the OS-drawn version of the same push would have
        // said - see [HouseholdStrings].
        title: payload.localizedTitle,
        body: payload.localizedBody,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            importance: Importance.high,
            priority: Priority.high,
            tag: payload.targetId,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload.route,
      );
    } catch (e, stack) {
      debugPrint(
        'HouseholdNotifier: failed to show ${payload.kind}: $e\n$stack',
      );
    }
  }
}
