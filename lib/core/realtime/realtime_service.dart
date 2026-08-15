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

  /// Every hub method registered on the transport. Public so a test can hold
  /// it against the household event list - a name missing here is dropped
  /// before any repository sees it, which looks exactly like a backend that
  /// stopped broadcasting.
  static const watchedEvents = [
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
    // MLS (E2EE). All three are nudges carrying no key material - see
    // `MlsRealtimeBridge` for what each one triggers.
    //
    // `Welcome` in particular is a key-exchange bootstrap signal rather than
    // the hydration event its name suggests: it means "there is a Welcome
    // waiting for this device", and the fetch behind it is device-scoped.
    'conversation.Welcome',
    // A commit advanced a group we are in. Deliberately carries no commit
    // bytes: applying commits in push-arrival order forks an MLS client off
    // the group permanently, so the ordered GET is the only path that
    // mutates group state.
    'conversation.MlsCommit',
    'conversation.MlsStateChanged',
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
    // A channel's encryption was toggled. Messaging owns the MLS group but not
    // channel membership, so this one is fanned out by Guild rather than
    // riding the `conversation.` prefix like its DM equivalent.
    'guild.ChannelMlsStateChanged',
    // Somebody is asking to be let into an encrypted channel. Members need to
    // see the review queue without polling; the requester is excluded from the
    // fanout server-side.
    'guild.ChannelMlsJoinRequested',
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
    // The voice-channel ring. Deliberately under the plain `guild.` prefix and
    // not `guild.voice.*`, which is reserved for voice *room state* - every
    // client has to be able to rebuild that from a version number after missing
    // an event, and a ring is not room state: its audience is somebody who is
    // not in the room and may never be. So it sits alongside
    // `guild.MemberJoined` and `guild.HouseholdAlert` instead.
    'guild.VoiceRingIncoming',
    'guild.VoiceRingSent',
    'guild.VoiceRingResolved',
    'guild.VoiceRingDismissed',
    'guild.MemberLeft',
    'guild.MemberBanned',
    'guild.MemberKicked',
    'guild.MemberMuted',
    'guild.MemberUnmuted',
    // A household's only removal: the `Household` preset leaves Moderation
    // off, so there is no kick to watch for instead. Guild-wide, because the
    // leaver's chores and ledger balance were everyone's.
    'guild.MemberMovedOut',
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
    // Inbox. Server->client only - there are no client->server inbox methods,
    // the REST endpoints are the write side. `MentionAdded` reaches only the
    // users a message actually mentioned and only those who can see the
    // channel; `ReadStateChanged` goes to the acking user's *other* devices,
    // so a device never sees its own acks come back (see `InboxRepository`).
    'inbox.MentionAdded',
    'inbox.ReadStateChanged',
    // Platform status. A latency improvement over `StatusRepository`'s 60s
    // poll, never a replacement for it: the hub is authenticated, so a
    // signed-out user - who is quite possibly signed out *because* of the
    // incident - receives neither of these.
    'status.SummaryChanged',
    'status.IncidentUpdated',
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
    // Household modules (see `HouseholdEvents`, which mirrors this list and is
    // what the screens actually filter on). Every mutation is broadcast to the
    // online members holding `ViewChannel` on that channel, which is the whole
    // design of these modules rather than a nicety: two people in the same shop
    // with the same list open is the *normal* case, and a tick has to strike
    // through on the other phone within the second or the milk gets bought
    // twice. A hub method that isn't registered here is dropped by the
    // transport, so leaving one out silently turns its board back into
    // pull-to-refresh.
    'guild.ListItemCreated',
    'guild.ListItemUpdated',
    'guild.ListItemChecked',
    'guild.ListItemDeleted',
    'guild.ListItemsReordered',
    'guild.ListCleared',
    'guild.ChoreCreated',
    'guild.ChoreUpdated',
    'guild.ChoreDeleted',
    'guild.ChoreOccurrenceCreated',
    'guild.ChoreOccurrenceUpdated',
    // The one envelope every household *alert* arrives in - the events that
    // are also a push, and the only household events that are. One method name
    // for every kind on purpose: kinds keep being added, and a per-kind name
    // would mean silently missing each new one. Replaces `guild.ChoreReminder`.
    'guild.HouseholdAlert',
    'guild.PantryItemCreated',
    'guild.PantryItemUpdated',
    'guild.PantryItemDeleted',
    'guild.ExpenseCreated',
    'guild.ExpenseUpdated',
    'guild.ExpenseDeleted',
    'guild.SettlementRecorded',
    'guild.DecisionCreated',
    'guild.DecisionUpdated',
    'guild.DecisionClosed',
    'guild.DecisionCancelled',
    'guild.HomeStatusChanged',
    // Bills: the schedules and the obligations they generate. State
    // replication only - a bill falling due reaches a phone as a
    // `guild.HouseholdAlert`, never as one of these.
    'guild.RecurringExpenseCreated',
    'guild.RecurringExpenseUpdated',
    'guild.RecurringExpenseDeleted',
    'guild.BillOccurrenceCreated',
    'guild.BillOccurrenceUpdated',
    'guild.ExpenseReceiptAdded',
    'guild.ExpenseReceiptDeleted',
    // Carries `{ occurrenceId, nudgedAt }` and **no sender**, by design - see
    // `HouseholdApiWave2.nudgeOccurrence`.
    'guild.ChoreOccurrenceNudged',
    // Guild-scoped, like home status: an absence belongs to a person rather
    // than to a channel.
    'guild.AbsenceCreated',
    'guild.AbsenceUpdated',
    'guild.AbsenceDeleted',
    'guild.RecipeCreated',
    'guild.RecipeUpdated',
    'guild.RecipeDeleted',
    'guild.MealPlanEntryCreated',
    'guild.MealPlanEntryUpdated',
    'guild.MealPlanEntryDeleted',
    'guild.MaintenanceAssetCreated',
    'guild.MaintenanceAssetUpdated',
    'guild.MaintenanceAssetDeleted',
    'guild.MaintenanceRecordCreated',
    'guild.MaintenanceRecordUpdated',
    'guild.MaintenanceRecordDeleted',
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
      for (final event in watchedEvents) {
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
