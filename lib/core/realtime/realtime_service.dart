import 'dart:async';

import '../../features/auth/data/auth_repository.dart';
import '../device/device_id_service.dart';
import 'realtime_event.dart';
import 'realtime_transport.dart';

/// The single shared hub connection for the whole app - mirrors Alpine's
/// `RealtimeConnectionService`. Dumb typed re-broadcast only: it knows
/// nothing about blocs or domain rules, it just turns hub methods into a
/// broadcast [Stream<RealtimeEvent>] that feature repositories subscribe to
/// and interpret.
class RealtimeService {
  RealtimeService({
    required this.transport,
    required this.authRepository,
    required this.deviceIdService,
  });

  final RealtimeTransport transport;
  final AuthRepository authRepository;
  final DeviceIdService deviceIdService;
  bool _configured = false;

  static const _watchedEvents = [
    'conversation.MessageCreated',
    'conversation.MessageUpdated',
    'conversation.MessageDeleted',
    'conversation.ConversationCreated',
    'conversation.ConversationDeleted',
    'conversation.MemberLeft',
    'conversation.UserTyping',
    'conversation.ReactionCreated',
    'conversation.ReactionRemoved',
    'conversation.MessagePinned',
    'conversation.MessageUnpinned',
    // Friend requests live on the `social.` prefix and reach both parties
    // (see RelationshipRepository). `conversation.FriendRequestReceived` was
    // watched here for a long time and never once fired - the backend has no
    // such method - which is why an incoming request needed an app restart to
    // appear. Kept alongside `conversation.FriendRequestAccepted` only until
    // the backend change ships.
    'social.FriendRequestCreated',
    'social.FriendRequestAccepted',
    'social.FriendRequestRejected',
    'social.FriendRemoved',
    'conversation.FriendRequestAccepted',
    // MLS (E2EE) key-exchange bootstrap signal, not a hydration event
    // despite the name - Alpine's handler fetches "pending welcomes" and
    // joins an MLS group for this conversationId. venta_mobile has no MLS
    // yet (plaintext-first v1 scope), so this stays watched-but-unconsumed
    // until E2EE lands rather than being wired to a no-op MLS stub.
    'conversation.Welcome',
    'presence.UserOnline',
    'presence.UserOffline',
    'guild.MessageCreated',
    'guild.MessageUpdated',
    // The backend has no per-message guild delete - a purge arrives as one
    // `MessagesBulkDeleted` carrying every id. `guild.MessageDeleted` stays
    // watched because the handler costs nothing and the name may yet appear;
    // the bulk one is what actually fires today.
    'guild.MessageDeleted',
    'guild.MessagesBulkDeleted',
    'guild.UserTyping',
    'guild.ChannelCreated',
    'guild.ChannelDeleted',
    'guild.ChannelUpdated',
    'guild.ChannelReordered',
    'guild.CategoryCreated',
    'guild.CategoryDeleted',
    'guild.CategoryUpdated',
    // Forum posts ride the thread events - `ThreadCreated` now carries
    // `tagIds`, and applied-tag changes, pins, locks and archives all arrive
    // as one `ThreadUpdated` carrying the full current state of those flags
    // (a replace, not a patch), rather than as separate events.
    'guild.ThreadCreated',
    'guild.ThreadUpdated',
    'guild.ForumTagCreated',
    'guild.ForumTagUpdated',
    'guild.ForumTagDeleted',
    'guild.ForumTagsReordered',
    'guild.ForumConfigUpdated',
    'guild.GuildCreated',
    'guild.GuildDeleted',
    'guild.GuildUpdated',
    'guild.RolesReordered',
    'guild.MemberJoined',
    'guild.MemberLeft',
    'guild.MemberBanned',
    'guild.MemberKicked',
    'guild.MemberMuted',
    'guild.MemberUnmuted',
    // Nickname changes.
    'guild.MemberUpdated',
    'guild.BotInstalled',
    'guild.BotUninstalled',
    'guild.PresenceChanged',
    'guild.ReactionCreated',
    'guild.ReactionRemoved',
    'guild.MessagePinned',
    'guild.MessageUnpinned',
    'guild.EmojiCreated',
    'guild.EmojiDeleted',
    'guild.EventCreated',
    'guild.EventUpdated',
    'guild.EventCancelled',
    'guild.WikiPageCreated',
    'guild.WikiPageUpdated',
    'guild.WikiPageDeleted',
    'guild.WikiCategoryCreated',
    'guild.WikiCategoryUpdated',
    'guild.WikiCategoryDeleted',
    'call.IncomingCall',
    'call.ParticipantJoined',
    'call.ParticipantLeft',
    'call.MuteChanged',
    'call.CallEnded',
    // Multi-device calling (see docs/multi-device-calls-client-spec.md):
    // dismissing a ringing device's UI when another of the user's devices
    // accepted/took over, plus the new group-leave/alone-timeout lifecycle.
    'call.CallAccepted',
    'call.CallDeviceDismissed',
    'call.CallDeviceTakeover',
    'call.CallParticipantLeft',
    'call.CallAlone',
    // Camera/screenshare - mirrors guild.voice.*'s equivalents (see
    // GuildVoiceRepository); the backend has always supported these
    // symmetrically for calls too, the client just never watched them.
    'call.SpeakingChanged',
    'call.CameraChanged',
    'call.TrackPublished',
    'call.TrackClosed',
    'call.ScreenShareStarted',
    'call.ScreenShareStopped',
    'guild.voice.UserJoinedVoice',
    'guild.voice.UserLeftVoice',
    'guild.voice.ParticipantJoined',
    'guild.voice.TrackPublished',
    'guild.voice.TrackClosed',
    'guild.voice.MuteChanged',
    'guild.voice.DeafenChanged',
    'guild.voice.CameraChanged',
    'guild.voice.ScreenShareStarted',
    'guild.voice.ScreenShareStopped',
    'guild.voice.MovedToChannel',
    'guild.voice.KickedByOtherDevice',
  ];

  final _eventsController = StreamController<RealtimeEvent>.broadcast();

  /// Every watched hub method, tagged by name - repositories filter with
  /// `.where((e) => e.name == '...')`.
  Stream<RealtimeEvent> get events => _eventsController.stream;

  Stream<RealtimeConnectionStatus> get connectionStatus =>
      transport.connectionStatus;

  /// Idempotent: call once per authenticated session (login, or app cold
  /// start with a restored session). Safe to call again after [stop].
  Future<void> start() async {
    if (!_configured) {
      transport.configure(
        hubUrl:
            '${authRepository.baseUrl}/api/v1/ws/hub?deviceId=${deviceIdService.deviceId}',
        accessTokenFactory: () => authRepository.ensureValidToken(),
      );
      for (final event in _watchedEvents) {
        transport.on(
          event,
          (args) => _eventsController.add(RealtimeEvent(event, args)),
        );
      }
      _configured = true;
    }
    await transport.start();
  }

  Future<void> stop() async {
    await transport.stop();
    _configured = false;
  }

  Future<void> invoke(String method, {List<Object>? args}) =>
      transport.invoke(method, args: args);
}
