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
  }) {
    // Never cancelled: this is an app-lifetime singleton and both ends outlive
    // every session. `stop()` tears down the connection, not this class.
    transport.connectionStatus.listen(_statusController.add);
  }

  final RealtimeTransport transport;
  final AuthRepository authRepository;
  final DeviceIdService deviceIdService;
  bool _configured = false;

  /// The transport's status, plus the synthetic `connected` [resume] emits.
  /// Owned here rather than passed through so this class can announce one -
  /// see [resume] for why that is not a lie.
  final _statusController =
      StreamController<RealtimeConnectionStatus>.broadcast();

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
    // A group was renamed or had its icon replaced. Carries the new
    // `name` and `iconUpdatedAt` outright, so the cache is patched from
    // the push rather than answered with a refetch.
    'conversation.ConversationUpdated',
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
    // A membership change that is not an ordinary commit push. Both are
    // nudges of the same shape as `MlsCommit` and are answered the same
    // way - see `MlsRealtimeBridge`, which has always handled them and
    // could not, because a name absent from this list is never delivered.
    'conversation.MlsDeviceAdmitted',
    'conversation.MlsDeviceRemoved',
    // Somebody is asking to be let into an encrypted context.
    'conversation.MlsJoinRequest',
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
    // A bot reply only this user was sent, which the server never stored. It
    // lives in the thread's in-memory list and nowhere else - a reload loses
    // it, which is the whole point - so nothing may offer edit, delete, pin or
    // reply on it: there is no row for any of those to act on.
    'guild.EphemeralMessageCreated',
    // A bot asking this user to fill in a form. Server->client only; the answer
    // goes back over REST (`modal-submit`), not the hub.
    'guild.ModalOpen',
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
    // Conversation-scoped rather than room-scoped: it reaches every member
    // of the conversation, including people the ring never addressed. It is
    // what turns the thread header's call button into a Join button while a
    // call is running, and what takes it away again when the call ends.
    'conversation.CallStateChanged',
    'call.IncomingCall',
    // The recovery channel, and it has to be registered to exist: the transport
    // only delivers methods named here, so a handler for an unregistered event
    // is unreachable code. `Snapshot` and `Resync` are what the version gate
    // repairs itself with - without them a dropped event is permanent, which is
    // the exact failure the gate was written to prevent.
    'call.Snapshot',
    'call.Resync',
    'call.ParticipantJoined',
    // No `call.ParticipantLeft` here: the server has no such event (see
    // Echo.Voice's VoiceEvents). Departures arrive as `call.CallParticipantLeft`
    // below, and a room-level one as `call.Resync` with reason `participantLeft`.
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
    'call.DeafenChanged',
    'call.TrackPublished',
    'call.TrackClosed',
    'call.ScreenShareStarted',
    'call.ScreenShareStopped',
    'call.ShareViewersChanged',
    // What this client should now be pulling. Sent without any user action -
    // the conversation moved - and per-recipient, so it is nobody else's set.
    // Relay only: it carries the room version without being a change to it.
    'call.SubscriptionsChanged',
    'guild.voice.UserJoinedVoice',
    'guild.voice.UserLeftVoice',
    'guild.voice.Snapshot',
    'guild.voice.Resync',
    'guild.voice.ParticipantJoined',
    'guild.voice.TrackPublished',
    'guild.voice.TrackClosed',
    'guild.voice.MuteChanged',
    'guild.voice.DeafenChanged',
    'guild.voice.CameraChanged',
    'guild.voice.SpeakingChanged',
    'guild.voice.ScreenShareStarted',
    'guild.voice.ScreenShareStopped',
    'guild.voice.ShareViewersChanged',
    'guild.voice.SubscriptionsChanged',
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
      _statusController.stream;

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

  /// Brings the hub - and everything downstream of it - back in step after the
  /// app has been in the background.
  ///
  /// A backgrounded process has no timers, so the client's own 30-second server
  /// timeout is what eventually notices the socket died while it was away: the
  /// app can sit in the foreground showing an hour-old picture of the world
  /// until that fires and the reconnect ladder finishes behind it. That is the
  /// "it doesn't backfill on wake" this exists to remove - the state does
  /// repair itself, just far too late to look like anything but a bug.
  ///
  /// Nothing here is new machinery. `connected` is already the app's "you
  /// missed things, re-read them" signal - SignalR queues nothing across a gap,
  /// so every cubit that cares already refetches on it. So:
  ///
  /// * down and idle → [start] it, which announces `connected` on its own;
  /// * mid-handshake or mid-reconnect → leave it alone, its own ladder is
  ///   already the faster path and a second `start` throws;
  /// * still connected → announce `connected` anyway. Not a lie about the
  ///   socket, which is genuinely up: it is the same "re-read what you hold"
  ///   instruction, and it has to be sent because a socket that *looks* alive
  ///   after a long suspension is exactly the case that shows stale state.
  Future<void> resume() async {
    // Never started this session - a signed-out app has nothing to resync.
    if (!_configured) return;

    if (transport.isConnected) {
      _statusController.add(RealtimeConnectionStatus.connected);
      return;
    }
    if (!transport.isDisconnected) return;

    try {
      await transport.start();
    } catch (_) {
      // The reconnect ladder owns retrying; a failed nudge is not an error the
      // user can act on, and the socket was already down before it.
    }
  }

  Future<void> stop() async {
    await transport.stop();
    _configured = false;
  }

  Future<void> invoke(String method, {List<Object>? args}) =>
      transport.invoke(method, args: args);
}
