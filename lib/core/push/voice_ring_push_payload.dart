import 'dart:convert';

import 'voice_strings.dart';

/// A voice-channel ring push, as the backend's `VoiceRingPushService` builds it.
///
/// **This is an ordinary alert push, and that is a decision rather than an
/// oversight.** It deliberately does not take the CallKit/VoIP path a DM call
/// takes: a VoIP push obliges iOS to report an incoming call to CallKit for
/// *every* payload received, which would put a fullscreen system call UI and an
/// entry in the phone log behind an invitation nobody is waiting on the line
/// for. So it is told apart from a call on the first key either parser reads,
/// `type`, and it never reaches [CallKitService].
class VoiceRingPushPayload {
  const VoiceRingPushPayload({
    required this.subtype,
    required this.ringId,
    required this.guildId,
    required this.channelId,
    required this.inviterId,
    this.recipientUserId,
    this.inviterAvatarUrl,
    this.hidden = false,
    this.expiresInSeconds = 0,
    this.title = '',
    this.body = '',
    this.titleLocKey,
    this.titleLocArgs = const [],
    this.bodyLocKey,
    this.bodyLocArgs = const [],
    this.cancelReason,
    this.excludeDeviceId,
  });

  static const type = 'voice_ring';
  static const inviteSubtype = 'invite';
  static const cancelSubtype = 'cancel';

  /// `invite` draws a notification; `cancel` takes one down. The two arrive on
  /// the same `type` because they are the same conversation.
  final String subtype;

  final String ringId;
  final String guildId;
  final String channelId;
  final String inviterId;
  final String? recipientUserId;
  final String? inviterAvatarUrl;

  /// The recipient has hide-push-content on, so [title] and [body] are already
  /// the server's neutral stand-ins and the inviter's name, the channel name and
  /// the avatar have all been withheld. Nothing extra to do - it is here so a
  /// client that renders its own richer copy does not.
  final bool hidden;

  /// **As of publication, not as of delivery.** If the push sat in a queue
  /// longer than this, drop it rather than drawing a dead invitation - see
  /// [isStale].
  final int expiresInSeconds;

  final String title;
  final String body;
  final String? titleLocKey;
  final List<String> titleLocArgs;
  final String? bodyLocKey;
  final List<String> bodyLocArgs;

  /// On a `cancel`: why the ring ended. Not shown - the card simply goes.
  final String? cancelReason;

  /// On a `cancel`: the device that answered.
  ///
  /// **If this is our own device id, ignore the push.** That device already
  /// knows. The server addresses it anyway because a push token only knows which
  /// device it belongs to if it was registered after the device-identity
  /// consolidation, and filtering server-side spared whole accounts - leaving
  /// handsets showing invitations that had been answered.
  final String? excludeDeviceId;

  bool get isCancel => subtype == cancelSubtype;

  /// The notification tag, matching the server's collapse key, so a second push
  /// about one ring replaces the first rather than stacking - and so the cancel
  /// can address exactly the notification the invite drew.
  String get notificationTag => 'voiceRing:$ringId';

  /// Whether this cancel is about an answer this very device gave.
  bool isSelfCancel(String? myDeviceId) {
    final exclude = excludeDeviceId;
    if (exclude == null || exclude.isEmpty) return false;
    if (myDeviceId == null || myDeviceId.isEmpty) return false;
    return exclude == myDeviceId;
  }

  /// A ring whose whole life elapsed while the push was queued.
  ///
  /// Drawn against [expiresInSeconds] rather than a deadline, because the value
  /// is the server's own remaining-time count at publication and needs no clock
  /// agreement to be read.
  bool get isStale => !isCancel && expiresInSeconds <= 0;

  /// What to show, in the reader's language where there is one.
  ///
  /// Only reached in the foreground - a backgrounded or dead app has the OS
  /// resolve the same key against the app bundle and never runs this, which is
  /// why the two tables have to agree.
  String get localizedTitle =>
      VoiceStrings.resolve(titleLocKey, titleLocArgs) ?? title;

  String get localizedBody =>
      VoiceStrings.resolve(bodyLocKey, bodyLocArgs) ?? body;

  static bool matches(Map<String, dynamic> data) => data['type'] == type;

  static VoiceRingPushPayload? tryParse(Map<String, dynamic> data) {
    if (!matches(data)) return null;

    final ringId = _string(data['ringId']);
    if (ringId == null) return null;

    return VoiceRingPushPayload(
      subtype: _string(data['ringSubtype']) ?? inviteSubtype,
      ringId: ringId,
      guildId: _string(data['guildId']) ?? '',
      channelId: _string(data['channelId']) ?? '',
      inviterId: _string(data['inviterId']) ?? '',
      recipientUserId: _string(data['recipientUserId']),
      inviterAvatarUrl: _string(data['inviterAvatarUrl']),
      hidden: data['hidden'] == '1' || data['hidden'] == true,
      expiresInSeconds: _int(data['expiresInSeconds']),
      title: _string(data['title']) ?? 'Voice invite',
      body: _string(data['body']) ?? '',
      titleLocKey: _string(data['titleLocKey']),
      titleLocArgs: _args(data['titleLocArgs']),
      bodyLocKey: _string(data['bodyLocKey']),
      bodyLocArgs: _args(data['bodyLocArgs']),
      cancelReason: _string(data['cancelReason']),
      excludeDeviceId: _string(data['excludeDeviceId']),
    );
  }

  static String? _string(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  /// FCM data values are strings only, so a number arrives as one.
  static int _int(Object? value) {
    final text = _string(value);
    if (text == null) return 0;
    return int.tryParse(text) ?? 0;
  }

  /// Anything unparseable yields an empty list rather than throwing: this runs
  /// in a background isolate where an exception is a notification that silently
  /// never arrives, and an empty list only costs the reader the translation.
  static List<String> _args(Object? value) {
    final text = _string(value);
    if (text == null) return const [];

    try {
      final decoded = jsonDecode(text);
      if (decoded is! List) return const [];
      return decoded.map((e) => e?.toString() ?? '').toList(growable: false);
    } on FormatException {
      return const [];
    }
  }
}
