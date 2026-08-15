import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../device/device_id_service.dart';
import '../mls/mls_store.dart';
import '../routing/route_paths.dart';
import 'call_kit_service.dart';
import 'household_notifier.dart';
import 'household_push_payload.dart';
import 'message_notifier.dart';
import 'message_push_decryptor.dart';
import 'message_push_payload.dart';
import 'push_token_api.dart';
import 'voice_ring_notifier.dart';
import 'voice_ring_push_payload.dart';

/// Marks a push as call-signaling rather than a normal notification - see
/// `docs/native-call-push-backend-spec.md`. Anything with this data type is
/// left entirely to [CallKitService] (via native PushKit/FCM delivery); this
/// service only ever surfaces `message`-type pushes as a visible banner.
const _callPushType = 'call';

/// Must be a top-level (or static) function - the platform relaunches a
/// separate background isolate to run it, so it can't close over any state
/// from the running app (no [getIt], no existing Dio/auth session).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == _callPushType) {
    // Android only - iOS call pushes arrive via PushKit straight into
    // native Swift and never reach this FCM background handler at all.
    await showCallKitFromPushData(message.data);
    return;
  }
  // A voice ring is an ordinary alert push and explicitly **not** the CallKit
  // path above: a VoIP payload obliges iOS to report a call to CallKit for every
  // one received, which would put a fullscreen system call UI and a phone-log
  // entry behind an invitation nobody is waiting on the line for.
  //
  // The invite half already has its notification drawn by the OS, like a
  // household alert. The cancel half is data-only and has no notification at
  // all, which is exactly why it reaches here: taking the card off the lock
  // screen is the whole of its job, and it is the one thing the OS will not do
  // on its own.
  final ring = VoiceRingPushPayload.tryParse(message.data);
  if (ring != null) {
    if (ring.isCancel) await VoiceRingNotifier.cancel(ring);
    return;
  }

  // Household pushes carry a real notification block, so the OS has already
  // drawn this one by the time the isolate runs. Anything shown here would be
  // the second copy of it.
  if (HouseholdPushPayload.matches(message.data)) return;
  await PushNotificationService.handleMessagePush(message);
}

/// Regular (non-call) push notifications - the Flutter counterpart to
/// Alpine's `NotificationService`/`UserTokenService`. Registers this install's
/// push token with the backend and draws every incoming-message notification
/// itself, foregrounded or not.
///
/// Drawing it ourselves is the point: message pushes arrive data-only on
/// Android, carrying the MLS ciphertext rather than a body, so that
/// [MessageNotifier] can decrypt it here and show what was actually said
/// instead of "you have a new encrypted message". iOS cannot run Dart for a
/// notification while the app is dead, so it receives an APNs alert with
/// `mutable-content` and the notification service extension in
/// `ios/NotificationService/` does the same job in Swift.
///
/// Call-signaling pushes are a separate, silent, data-only path owned by
/// [CallKitService] - this service explicitly ignores them.
class PushNotificationService {
  PushNotificationService({
    required this.api,
    required this.deviceIdService,
    required this.mlsStore,
  });

  final PushTokenApi api;
  final DeviceIdService deviceIdService;

  /// The app's own store, handed to the decryptor so a push decrypted while the
  /// app is running lands in the same in-memory cache the conversation reads
  /// from - see [MessagePushDecryptor.decrypt].
  final MlsStore mlsStore;

  final _navigationController = StreamController<String>.broadcast();

  /// Route paths to push (via the root [GoRouter]) when the user taps a
  /// message notification - synthesized from the tapped push's
  /// `conversationId` through the same `venta://conversation/<id>` shape
  /// [DeepLinkHandler] already resolves.
  Stream<String> get onNotificationTap => _navigationController.stream;

  final _voiceRingTapController = StreamController<String>.broadcast();

  /// Ring ids whose notification the user tapped.
  ///
  /// A ring id rather than a route, because a ring has no screen of its own -
  /// the card is an overlay wherever the app already is. Tapping it opens the
  /// card and joins nothing.
  Stream<String> get onVoiceRingTap => _voiceRingTapController.stream;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Call once per authenticated session, after `Firebase.initializeApp()`
  /// and [firebaseMessagingBackgroundHandler] registration have already run
  /// in `main()`.
  Future<void> start() async {
    _isForeground = true;
    await MessageNotifier.initializeForApp(onTap: _handleLocalTap);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    await _registerToken();
    _tokenRefreshSub = messaging.onTokenRefresh.listen((_) => _registerToken());

    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      // Foreground calls normally arrive over the already-open websocket
      // (CallCubit -> CallKitService); this is just a defensive fallback in
      // case the socket dropped without the app noticing yet.
      if (message.data['type'] == _callPushType) {
        showCallKitFromPushData(message.data);
        return;
      }
      // Same split as the background isolate, and for the same reason: never
      // CallKit. The realtime event is what actually raises the in-app card
      // while the app is open; this only draws the tray entry neither platform
      // will, and honours the cancel.
      final ring = VoiceRingPushPayload.tryParse(message.data);
      if (ring != null) {
        if (ring.isCancel) {
          // The device that answered already knows, and it is addressed anyway
          // because a push token only knows which device it belongs to if it
          // was registered after the device-identity consolidation.
          if (!ring.isSelfCancel(deviceIdService.deviceIdOrNull)) {
            unawaited(VoiceRingNotifier.cancel(ring));
          }
        } else {
          unawaited(VoiceRingNotifier.show(ring));
        }
        return;
      }

      // A household alert that lands while the app is in front is shown by
      // neither platform, so this is the only place it can come from.
      final household = HouseholdPushPayload.tryParse(message.data);
      if (household != null) {
        unawaited(HouseholdNotifier.show(household));
        return;
      }
      unawaited(handleMessagePush(message, store: mlsStore));
    });
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage);
  }

  /// The token this session registered, so [unregisterToken] can name it on
  /// sign-out without depending on Firebase still handing back the same value.
  String? _registeredToken;

  /// Both platforms register their FCM registration token - the backend
  /// sends all regular push through FCM (see `PushNotifiaction.cs`), which
  /// relays to APNs internally for iOS. Both land under `kind: Fcm`
  /// server-side. VoIP/CallKit push is the one exception and uses a separate
  /// PushKit token - see `call_kit_service.dart`.
  ///
  /// Registered *with* this installation's device id: that's what lets the
  /// backend address one of a user's devices rather than all of them, which
  /// among other things keeps the device that answered a call from being sent
  /// the cancel push for it.
  Future<void> _registerToken() async {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token == null) return;
    _registeredToken = token;
    await api.registerToken(
      token: token,
      kind: PushTokenKind.fcm,
      deviceId: deviceIdService.deviceIdOrNull,
    );
  }

  /// Deregisters this installation's FCM token. Must run *before* the session
  /// is torn down - it is an authenticated call, and a token left behind keeps
  /// a signed-out handset receiving the previous account's notifications.
  Future<void> unregisterToken() async {
    final token =
        _registeredToken ?? await FirebaseMessaging.instance.getToken();
    if (token == null) return;
    _registeredToken = null;
    await api.deleteToken(token: token, kind: PushTokenKind.fcm);
  }

  void _handleTap(RemoteMessage message) {
    final route = MessagePushPayload.tryParse(message.data)?.route;
    if (route != null) {
      _navigationController.add(route);
      return;
    }
    // **Tapping a ring opens the card, it does not join anything.** The card
    // lives wherever the app happens to be, so this only has to bring the app
    // forward and let the catch-up read raise it - which is why there is no
    // route here and no navigation. A cancel is silent and never tappable.
    final ring = VoiceRingPushPayload.tryParse(message.data);
    if (ring != null) {
      if (!ring.isCancel) _voiceRingTapController.add(ring.ringId);
      return;
    }
    // Routed on `kind`'s payload rather than on the kind itself: every
    // household notification is about a row on a board, and the board is where
    // you want to be regardless of which module sent it.
    final household = HouseholdPushPayload.tryParse(message.data);
    if (household != null) {
      _navigationController.add(household.route);
      return;
    }
    // Pre-`type: message` payloads, and anything else that names a conversation.
    final conversationId = message.data['conversationId'];
    if (conversationId == null || conversationId.isEmpty) return;
    _navigationController.add(RoutePaths.conversationPath(conversationId));
  }

  /// Tapping a notification this app drew itself, as opposed to one the OS drew
  /// from an APNs alert - those come back through [_handleTap] instead.
  void _handleLocalTap(NotificationResponse response) {
    final route = response.payload;
    if (route != null && route.isNotEmpty) _navigationController.add(route);
  }

  /// Shows a new-message push.
  ///
  /// Static, and reachable from the background isolate: on Android this is the
  /// only thing that turns a data-only push into a visible notification, and it
  /// is what decrypts the body on the way.
  ///
  /// iOS deliberately falls through to doing nothing while the app is
  /// backgrounded - the system already displayed the APNs alert (as rewritten by
  /// the notification service extension), and posting a local notification on
  /// top of it would show the message twice.
  static Future<void> handleMessagePush(
    RemoteMessage message, {
    MlsStore? store,
  }) async {
    final payload = MessagePushPayload.tryParse(message.data);
    if (payload == null) return;
    if (Platform.isIOS && !_isForeground) return;
    await MessageNotifier.show(payload, store: store);
  }

  /// True only inside the running app. The FCM background isolate never sets
  /// it, which is exactly the distinction iOS needs above.
  static bool _isForeground = false;

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
    await _tokenRefreshSub?.cancel();
    await _navigationController.close();
    await _voiceRingTapController.close();
  }
}
