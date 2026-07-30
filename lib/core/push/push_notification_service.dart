import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../routing/route_paths.dart';
import 'call_kit_service.dart';
import 'push_token_api.dart';

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
  await PushNotificationService.showLocalNotification(message);
}

/// Regular (non-call) push notifications - the Flutter counterpart to
/// Alpine's `NotificationService`/`UserTokenService`. Registers this
/// install's push token with the backend and surfaces incoming-message
/// pushes as a local notification while the app is foregrounded (the OS
/// already does this for us when backgrounded/killed, since the backend
/// sends a `Notification`-block FCM message / `.Alert`-type APNs push).
///
/// Call-signaling pushes are a separate, silent, data-only path owned by
/// [CallKitService] - this service explicitly ignores them.
class PushNotificationService {
  PushNotificationService({required this.api});

  final PushTokenApi api;

  static final _localNotifications = FlutterLocalNotificationsPlugin();
  static const _messagesChannel = AndroidNotificationChannel(
    'messages',
    'Messages',
    description: 'New direct messages and server messages',
    importance: Importance.high,
  );

  final _navigationController = StreamController<String>.broadcast();

  /// Route paths to push (via the root [GoRouter]) when the user taps a
  /// message notification - synthesized from the tapped push's
  /// `conversationId` through the same `venta://conversation/<id>` shape
  /// [DeepLinkHandler] already resolves.
  Stream<String> get onNotificationTap => _navigationController.stream;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;
  StreamSubscription<String>? _tokenRefreshSub;

  /// Call once per authenticated session, after `Firebase.initializeApp()`
  /// and [firebaseMessagingBackgroundHandler] registration have already run
  /// in `main()`.
  Future<void> start() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_messagesChannel);
    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

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
      showLocalNotification(message);
    });
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(_handleTap);
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _handleTap(initialMessage);
  }

  /// Both platforms register their FCM registration token - the backend
  /// sends all regular push through FCM (see `PushNotifiaction.cs`), which
  /// relays to APNs internally for iOS. Both land in the same generic
  /// `/device-token` field server-side. VoIP/CallKit push is the one
  /// exception and uses a separate PushKit token - see `call_kit_service.dart`.
  Future<void> _registerToken() async {
    final messaging = FirebaseMessaging.instance;
    final token = await messaging.getToken();
    if (token == null) return;
    await api.registerDeviceToken(token);
  }

  void _handleTap(RemoteMessage message) {
    final conversationId = message.data['conversationId'];
    if (conversationId == null || conversationId.isEmpty) return;
    _navigationController.add(RoutePaths.conversationPath(conversationId));
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _messagesChannel.id,
          _messagesChannel.name,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['conversationId'],
    );
  }

  Future<void> dispose() async {
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
    await _tokenRefreshSub?.cancel();
    await _navigationController.close();
  }
}
