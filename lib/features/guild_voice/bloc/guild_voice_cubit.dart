import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStreamTrack;

import '../../../core/bloc/safe_emit.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../../../core/sound/sound_service.dart';
import '../../../core/voice/track_naming.dart';
import '../../../core/voice/video_layers.dart';
import '../../../core/voice/voice_app_visibility.dart';
import '../../../core/voice/voice_heartbeat.dart';
import '../../../core/voice/voice_liveness.dart';
import '../../../core/voice/voice_media_api.dart';
import '../../../core/voice/voice_participant_state.dart';
import '../../../core/voice/voice_snapshot_dto.dart';
import '../../../core/voice/voice_speaking_detector.dart';
import '../../auth/data/auth_repository.dart';
import '../../billing/data/entitlement_reader.dart';
import '../../billing/data/models/entitlement_degradation_dto.dart';
import '../../billing/data/models/entitlement_denial.dart';
import '../data/guild_voice_repository.dart';
import '../webrtc/guild_voice_webrtc_service.dart';

enum GuildVoicePhase { idle, connecting, active }

class GuildVoiceState extends Equatable {
  const GuildVoiceState({
    this.phase = GuildVoicePhase.idle,
    this.guildId,
    this.channelId,
    this.channelName,
    this.guildName,
    this.isMuted = false,
    this.isDeafened = false,
    this.isSpeakerOn = true,
    this.connectedAt,
    this.rosters = const {},
    this.errorMessage,
    this.videoRevision = 0,
    this.limits,
    this.videoNotice,
  });

  final GuildVoicePhase phase;
  final String? guildId;
  final String? channelId;
  final String? channelName;
  final String? guildName;
  final bool isMuted;
  final bool isDeafened;

  /// Whether output is routed to the loud/speakerphone output rather than
  /// the quiet call (earpiece) speaker. Defaults on - with no headset
  /// connected, calls were otherwise landing on the quiet earpiece route
  /// with no way to switch, unlike every other calling app.
  final bool isSpeakerOn;

  /// Set once, the moment the channel join reaches [GuildVoicePhase.active] -
  /// drives the elapsed-time display. Never touched again until the next join.
  final DateTime? connectedAt;

  /// Every voice channel's roster, keyed by channelId - not just the one the
  /// local user has joined. This is what lets the sidebar show live
  /// participant avatars for channels the user hasn't joined.
  final Map<String, List<VoiceParticipantState>> rosters;
  final String? errorMessage;

  /// Bumped on every local/remote camera or screen-share track add/remove -
  /// `MediaStreamTrack`s themselves can't live in this `Equatable` state (not
  /// comparable/immutable-safe), so `VideoParticipantTile`/`ScreenShareView`
  /// instead pull the current track imperatively from the webrtc service and
  /// rely on this counter changing to know when to re-pull and rebuild.
  final int videoRevision;

  /// What the joined channel may carry, as of the last snapshot. Null on a
  /// server that does not send limits and on a channel whose limits have never
  /// been computed - which is "nobody said", not "no limits", so nothing here
  /// substitutes a permissive default.
  final VoiceRoomLimitsDto? limits;

  /// One sentence about this device's own video, in the moment: the rung a
  /// publish was clamped to, or why one could not happen at all.
  ///
  /// Explanation only. There is no companion field for what would lift it and
  /// no action attached to it anywhere it renders - see `EntitlementNotice`.
  /// Cleared when the camera and the share are both off, because it describes
  /// a picture that is no longer being sent.
  final String? videoNotice;

  bool get isInVoice => phase != GuildVoicePhase.idle;

  List<VoiceParticipantState> rosterFor(String channelId) =>
      rosters[channelId] ?? const [];

  /// Identity fields (guildId/channelId/channelName/guildName) intentionally
  /// never fall back to null here - a full reset (leave/error) constructs a
  /// fresh `GuildVoiceState` instead, same pattern as `CallState`/`CallCubit`.
  GuildVoiceState copyWith({
    GuildVoicePhase? phase,
    String? guildId,
    String? channelId,
    String? channelName,
    String? guildName,
    bool? isMuted,
    bool? isDeafened,
    bool? isSpeakerOn,
    DateTime? connectedAt,
    Map<String, List<VoiceParticipantState>>? rosters,
    String? errorMessage,
    int? videoRevision,
    VoiceRoomLimitsDto? limits,
    String? videoNotice,
    bool clearVideoNotice = false,
  }) => GuildVoiceState(
    phase: phase ?? this.phase,
    guildId: guildId ?? this.guildId,
    channelId: channelId ?? this.channelId,
    channelName: channelName ?? this.channelName,
    guildName: guildName ?? this.guildName,
    isMuted: isMuted ?? this.isMuted,
    isDeafened: isDeafened ?? this.isDeafened,
    isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    connectedAt: connectedAt ?? this.connectedAt,
    rosters: rosters ?? this.rosters,
    errorMessage: errorMessage,
    videoRevision: videoRevision ?? this.videoRevision,
    limits: limits ?? this.limits,
    // Coalesces rather than following [errorMessage], because a mute toggle
    // must not wipe the sentence explaining why the camera is off. Clearing it
    // is therefore explicit, and only the two places that turn video off do it.
    videoNotice: clearVideoNotice ? null : (videoNotice ?? this.videoNotice),
  );

  @override
  List<Object?> get props => [
    phase,
    guildId,
    channelId,
    channelName,
    guildName,
    isMuted,
    isDeafened,
    isSpeakerOn,
    connectedAt,
    rosters,
    errorMessage,
    videoRevision,
    limits,
    videoNotice,
  ];
}

/// App-lifetime singleton owning the one guild voice channel the app can be
/// joined to at a time, plus live rosters for every voice channel visible in
/// the sidebar - the guild-voice counterpart to `CallCubit`, and deliberately
/// the same shape, because the server runs one voice implementation for both.
///
/// Joining a channel does not force any particular screen; unlike 1:1 calling,
/// guild voice keeps the user free to browse other channels while connected.
class GuildVoiceCubit extends Cubit<GuildVoiceState>
    with SafeEmit<GuildVoiceState> {
  GuildVoiceCubit({
    required this.repository,
    required this.authRepository,
    required this.soundService,
    required GuildVoiceWebRtcService Function() webRtcServiceFactory,
    this.entitlements,
  }) : _webRtcServiceFactory = webRtcServiceFactory,
       super(const GuildVoiceState()) {
    _sub = repository.events.listen(_handleEvent);
    _connectionSub = repository.connectionStatus.listen(
      _handleConnectionStatus,
    );
    _heartbeat = VoiceHeartbeat(send: _sendHeartbeat);
    _liveness = VoiceLiveness(
      assertAlive: _assertAlive,
      onRoomGone: () => unawaited(_handleRoomGone()),
    );
  }

  final GuildVoiceRepository repository;
  final AuthRepository authRepository;
  final SoundService soundService;

  /// Where the video ladder is read from, so the camera captures at what this
  /// room's rung permits. Optional: without it the camera falls back to
  /// [VideoPublishIntent.conservative], which is what it captured at before the
  /// ladder was on the wire.
  final EntitlementReader? entitlements;

  final GuildVoiceWebRtcService Function() _webRtcServiceFactory;
  late final StreamSubscription<GuildVoiceEvent> _sub;
  late final StreamSubscription<RealtimeConnectionStatus> _connectionSub;
  late final VoiceHeartbeat _heartbeat;

  /// The second, independent liveness channel. Kept as its own timer rather
  /// than folded into [_heartbeat] on purpose: the heartbeat goes over the hub,
  /// and the case this covers is the hub being down.
  late final VoiceLiveness _liveness;
  GuildVoiceWebRtcService? _webRtc;

  /// Whether the joined channel's screen shares are on screen. Viewer claims
  /// and the subscriptions behind them are only held while they are - guild
  /// voice is explicitly a background activity, so this is false far more
  /// often than it is true, and paying for a stream nobody is looking at is
  /// exactly what the watch protocol exists to prevent.
  bool _sharesVisible = false;

  /// Share ids this device holds a viewer claim on. Re-posted on the heartbeat
  /// timer, because a claim expires after 90 seconds.
  final Set<String> _watchedShares = {};

  String get _myUserId => authRepository.currentUserId ?? '';

  // ── Rosters ───────────────────────────────────────────────────────────────

  /// Populates the roster for one voice channel without joining it - used when
  /// a guild's channel list loads, so sidebar participant avatars show up even
  /// for channels the user hasn't entered.
  ///
  /// Safe for a channel this user is not in: the snapshot withholds session
  /// ids and track names for anyone not actually publishing, so a roster read
  /// hands out nothing subscribable.
  Future<void> hydrateChannelRoster(String guildId, String channelId) async {
    try {
      final snapshot = await repository.getSnapshot(guildId, channelId);
      _setRoster(channelId, [
        for (final p in snapshot.participants)
          VoiceParticipantState.fromSnapshot(p),
      ]);
    } catch (_) {
      // Best-effort - realtime events keep it eventually consistent.
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> join({
    required String guildId,
    required String channelId,
    required String channelName,
    required String guildName,
  }) async {
    if (state.phase != GuildVoicePhase.idle) {
      if (state.channelId == channelId) return;
      await leave();
    }
    emitIfOpen(
      state.copyWith(
        phase: GuildVoicePhase.connecting,
        guildId: guildId,
        channelId: channelId,
        channelName: channelName,
        guildName: guildName,
      ),
    );
    try {
      // Join first: it puts this user in the roster before any media work, and
      // hands back the authoritative snapshot.
      final snapshot = await repository.join(guildId, channelId);
      await _connect(guildId, channelId, snapshot);
    } catch (_) {
      repository.exitChannel();
      emitIfOpen(
        GuildVoiceState(
          rosters: state.rosters,
          errorMessage: 'Could not join voice channel.',
        ),
      );
    }
  }

  Future<void> leave() async {
    final guildId = state.guildId;
    final channelId = state.channelId;
    if (guildId == null || channelId == null) return;
    unawaited(soundService.playLeaveCall());
    final webRtc = await _teardown();

    final rosters = Map<String, List<VoiceParticipantState>>.from(
      state.rosters,
    );
    rosters[channelId] = (rosters[channelId] ?? const [])
        .where((p) => p.userId != _myUserId)
        .toList();
    emitIfOpen(GuildVoiceState(rosters: rosters));

    await webRtc?.disconnect();
    try {
      await repository.leave(guildId, channelId);
    } catch (_) {
      // Best-effort - we've already torn down locally.
    }
  }

  /// Releases everything local about the joined channel, returning the WebRTC
  /// service so the caller can dispose it after emitting. Viewer claims go
  /// first: they outlive this client by 90 seconds otherwise, and a phantom
  /// viewer keeps a publisher's egress alive for nothing.
  Future<GuildVoiceWebRtcService?> _teardown() async {
    _heartbeat.stop();
    // Before anything that can block. A ping for a channel the user has left
    // keeps a ghost participant in everybody else's roster until it stops.
    _liveness.stop();
    _stopSpeakingReports();
    _stopVisibilityReports();
    await _releaseAllShareClaims();
    repository.exitChannel();
    final webRtc = _webRtc;
    _webRtc = null;
    return webRtc;
  }

  /// A transport with its callbacks wired. Built here rather than at each call site so a rebuild
  /// cannot come back with fewer of them than the original had - which would be silent, and would
  /// show up much later as one of the conditions they exist to answer.
  ///
  /// Two that used to be here are gone with the SDP relay: `onStaleSubscription` and
  /// `onSessionGone`. Neither condition exists any more - there is no subscribe for this backend to
  /// refuse, and no minted session id to be spent - so the media-rebuild path they drove has gone
  /// with them, along with the local publications it had to retire.
  GuildVoiceWebRtcService _buildTransport() {
    final webRtc = _webRtcServiceFactory();
    // A track arriving is its own event, later than the subscribe that asked
    // for it and with nothing else attached to it. Without this the screen
    // renders whatever it read before the media existed - see
    // [GuildVoiceState.videoRevision].
    webRtc.onTracksChanged = _bumpVideoRevision;
    // A reduction is a success: it changes no media state and tears nothing
    // down. It only puts the sentence where the person who is publishing can
    // read it.
    webRtc.onPublishReduced = _noteReduction;
    // Raw, and deliberately not reported from here - it goes through the
    // detector, which is where the hysteresis lives.
    webRtc.onLocalSpeakingChanged = (isSpeaking) =>
        _speaking?.update(isSpeaking: isSpeaking);
    // The SDK gave up reconnecting. A fresh connection is the only recovery -
    // and it is cheap, because minting one touches nothing but the token.
    webRtc.onMediaDisconnected = () => unawaited(_reconnectMedia());
    return webRtc;
  }

  /// Guards [_reconnectMedia] against a second attempt while one is running.
  bool _reconnectingMedia = false;

  /// Rebuilds the media half after the SDK's own reconnect ladder is exhausted.
  ///
  /// A token is good for minutes rather than hours, so the case this covers is
  /// a device asleep or in a tunnel for longer than that: the resume is refused
  /// and the SDK stops. Asking for another connection is the documented answer,
  /// it does not touch the roster, and it does not re-announce this client to
  /// anybody.
  ///
  /// **Channel membership is untouched.** The roster and the version tracker
  /// both survive; this is not a rejoin. The camera and any screen share do not
  /// survive - they were publications on a connection that is gone - so the
  /// room is told they stopped rather than left advertising a picture nobody is
  /// receiving.
  Future<void> _reconnectMedia() async {
    final guildId = state.guildId;
    final channelId = state.channelId;
    if (_reconnectingMedia || guildId == null || channelId == null) return;
    if (state.phase != GuildVoicePhase.active) return;
    _reconnectingMedia = true;
    try {
      final dead = _webRtc;
      _webRtc = null;
      await dead?.disconnect();

      await _retireLocalPublications(channelId);

      final webRtc = _buildTransport();
      _webRtc = webRtc;
      await webRtc.connect(guildId, channelId);
      await webRtc.setMuted(state.isMuted);
      webRtc.setDeafened(state.isDeafened);
      await webRtc.setSpeakerphoneOn(state.isSpeakerOn);

      // The roster is unchanged, but every subscription went with the old
      // connection, so this is what pulls the room back in.
      await repository.refetchSnapshot();
    } catch (_) {
      emitIfOpen(state.copyWith(errorMessage: 'Lost the connection to voice.'));
    } finally {
      _reconnectingMedia = false;
    }
  }

  /// Drops the camera and screen share that went with the old connection, and
  /// tells the room.
  Future<void> _retireLocalPublications(String channelId) async {
    final shareId = _myShareId;
    _myShareId = null;
    _updateParticipant(
      channelId,
      _myUserId,
      (p) => shareId == null
          ? p.copyWith(hasCamera: false)
          : p.copyWith(hasCamera: false).withoutShare(shareId),
    );
    _clearVideoNoticeIfIdle();
    _bumpVideoRevision();
    try {
      await repository.invokeCameraChanged(
        channelId: channelId,
        isCameraOn: false,
      );
      if (shareId != null) {
        await repository.invokeScreenShareStopped(
          channelId: channelId,
          shareId: shareId,
        );
      }
    } catch (_) {
      // Best-effort - the server's own reconcile corrects it from the next
      // heartbeat either way.
    }
  }

  /// Debounces this device's voice activity into `guild.voice.SpeakingChanged`.
  ///
  /// **This is what a guild channel never sent**, which is why every guild room
  /// stayed `mode: "all"` at any size: ranking has exactly one input, and no
  /// client was providing it. Nothing looked broken and nothing was saved.
  ///
  /// Built per session rather than per cubit so its "what the server currently
  /// believes" state cannot survive into a channel the belief is not about.
  VoiceSpeakingDetector? _speaking;

  /// Tells the server when this client is backgrounded, so it stops sending
  /// video nobody is looking at. Audio is unaffected - see
  /// [VoiceAppVisibility].
  VoiceAppVisibility? _visibility;

  void _startVisibilityReports() {
    _visibility?.dispose();
    _visibility = VoiceAppVisibility(
      onChanged: (isPaused) => unawaited(
        _webRtc?.setPaused(isPaused) ?? Future.value(),
      ),
    );
  }

  void _stopVisibilityReports() {
    _visibility?.dispose();
    _visibility = null;
  }

  void _startSpeakingReports() {
    _speaking?.dispose();
    _speaking = VoiceSpeakingDetector(
      report: (isSpeaking) async {
        final channelId = state.channelId;
        if (channelId == null || state.phase != GuildVoicePhase.active) return;
        await repository.invokeSpeakingChanged(
          channelId: channelId,
          isSpeaking: isSpeaking,
        );
      },
    );
  }

  void _stopSpeakingReports() {
    // Silenced rather than merely disposed: a detector torn down mid-word
    // leaves the server believing this device is still talking, which keeps it
    // ranked - and every other client in the room subscribed to it.
    _speaking?.silenceNow();
    _speaking?.dispose();
    _speaking = null;
  }

  /// Files a clamped publish where the room can render it.
  ///
  /// One sentence rather than a list: two reductions on one publish would be a
  /// paragraph on a call screen, and the video ceiling is the one that
  /// describes what the user is now sending. The rest are still recorded in the
  /// session log by the interceptor, which is where a complete account belongs.
  void _noteReduction(List<EntitlementDegradationDto> degradations) {
    final video = degradations.firstWhere(
      (d) => d.key == EntitlementKeys.voiceVideoCeiling,
      orElse: () => degradations.first,
    );
    emitIfOpen(state.copyWith(videoNotice: video.notice));
  }

  Future<void> _connect(
    String guildId,
    String channelId,
    VoiceRoomSnapshotDto snapshot,
  ) async {
    final webRtc = _buildTransport();
    _webRtc = webRtc;
    repository.enterChannel(guildId: guildId, channelId: channelId);
    repository.adoptSnapshot(snapshot);

    emitIfOpen(
      state.copyWith(
        phase: GuildVoicePhase.active,
        connectedAt: DateTime.now(),
      ),
    );
    _applySnapshot(snapshot);
    unawaited(soundService.playJoinCall());

    try {
      await webRtc.connect(guildId, channelId);
      await webRtc.setMuted(state.isMuted);
      webRtc.setDeafened(state.isDeafened);
      await webRtc.setSpeakerphoneOn(state.isSpeakerOn);
      _startSpeakingReports();
      _startVisibilityReports();
    } on VoiceMediaException catch (e) {
      // A self-hosted instance with no SFU configured is a supported state, not
      // a fault - and there is no capability read to ask up front, so this is
      // where it is discovered. Saying "could not connect" for it would send
      // somebody looking for a network problem that does not exist.
      emitIfOpen(
        state.copyWith(
          errorMessage: e.isVoiceNotConfigured
              ? 'Voice is not available on this server.'
              : 'Could not connect audio.',
        ),
      );
    } catch (_) {
      emitIfOpen(state.copyWith(errorMessage: 'Could not connect audio.'));
    }

    // Re-read after connecting: anyone who started publishing while we were
    // behind the microphone prompt is only in this second snapshot.
    await repository.refetchSnapshot();
    _heartbeat.start();
    _liveness.start();
  }

  // ── Snapshot ──────────────────────────────────────────────────────────────

  /// Adopts an authoritative snapshot wholesale and reconciles the transport
  /// with it. Camera and speaking state are carried forward rather than read
  /// from it: the server does not store either, so a snapshot that took them
  /// literally would blank every camera badge on every resync.
  void _applySnapshot(VoiceRoomSnapshotDto snapshot) {
    final channelId = snapshot.roomId;
    final isJoinedChannel = channelId == state.channelId;
    final previous = {for (final p in state.rosterFor(channelId)) p.userId: p};

    final participants = [
      for (final p in snapshot.participants)
        VoiceParticipantState.fromSnapshot(
          p,
          hasCamera: previous[p.userId]?.hasCamera ?? false,
          isSpeaking: previous[p.userId]?.isSpeaking ?? false,
        ),
    ];
    _setRoster(channelId, participants);

    if (!isJoinedChannel) return;
    // Only for the channel this device is actually in. A sidebar roster read
    // for a channel nobody joined carries that channel's limits, and adopting
    // one would have the call controls describing a room the user is not in.
    //
    // Absent limits leave the last known set alone rather than blanking it: a
    // room that stops reporting has not stopped having ceilings, and a control
    // that re-enables itself because a field went missing is the one direction
    // this must not fail in.
    if (snapshot.limits != null) {
      emitIfOpen(state.copyWith(limits: snapshot.limits));
    }
    final webRtc = _webRtc;
    if (webRtc == null) return;

    final present = participants.map((p) => p.userId).toSet();
    for (final gone in previous.keys.where((id) => !present.contains(id))) {
      webRtc.unsubscribeParticipant(gone);
    }

    // Taken wholesale, exactly like the roster. Applied *before* the subscribes
    // below so they are filtered by it on the way through rather than issued
    // and then withdrawn - and a snapshot with no `subscriptions` clears any set
    // that was in force, which is the ordinary small room saying "pull everyone
    // who is publishing".
    webRtc.applySubscriptionSet(snapshot.subscriptions);

    for (final p in snapshot.publishersExcept(_myUserId)) {
      unawaited(
        webRtc.subscribeToParticipant(
          userId: p.userId,
          mediaSessionId: p.mediaSessionId!,
          trackName: p.audioTrackName!,
        ),
      );
    }
    unawaited(_reconcileShares(snapshot));
  }

  /// Brings viewer claims and share subscriptions in line with the snapshot
  /// and with whether the shares are on screen at all.
  Future<void> _reconcileShares(VoiceRoomSnapshotDto snapshot) async {
    final webRtc = _webRtc;
    final guildId = state.guildId;
    final channelId = state.channelId;
    if (webRtc == null || guildId == null || channelId == null) return;

    final live = <String, VoiceParticipantSnapshotDto>{};
    for (final p in snapshot.participants) {
      if (p.userId == _myUserId) continue;
      for (final share in p.shares) {
        live[share.shareId] = p;
      }
    }

    for (final shareId in _watchedShares.toList()) {
      if (live.containsKey(shareId) && _sharesVisible) continue;
      await _stopWatching(shareId, ownerUserId: live[shareId]?.userId);
    }

    if (!_sharesVisible) return;

    for (final entry in live.entries) {
      final publisher = entry.value;
      if (!publisher.isPublishing) continue;
      final share = publisher.shares.firstWhere((s) => s.shareId == entry.key);
      if (_watchedShares.add(entry.key)) unawaited(_claimShare(entry.key));
      await webRtc.subscribeToShare(
        userId: publisher.userId,
        // The share's own session, not the publisher's microphone one - they
        // are the same session only by coincidence. See [VoiceShareDto].
        mediaSessionId: share.mediaSessionId ?? publisher.mediaSessionId!,
        shareId: share.shareId,
        trackNames: share.trackNames,
      );
    }
  }

  Future<void> _claimShare(String shareId) async {
    final guildId = state.guildId;
    final channelId = state.channelId;
    if (guildId == null || channelId == null) return;
    try {
      await repository.watchShare(
        guildId: guildId,
        channelId: channelId,
        shareId: shareId,
      );
    } catch (_) {
      // A lost claim only understates a viewer count; the heartbeat re-posts.
    }
  }

  Future<void> _stopWatching(String shareId, {String? ownerUserId}) async {
    _watchedShares.remove(shareId);
    if (ownerUserId != null) {
      _webRtc?.unsubscribeShare(userId: ownerUserId, shareId: shareId);
    }
    final guildId = state.guildId;
    final channelId = state.channelId;
    if (guildId == null || channelId == null) return;
    try {
      await repository.unwatchShare(
        guildId: guildId,
        channelId: channelId,
        shareId: shareId,
      );
    } catch (_) {
      // Best-effort - the claim expires on its own within 90 seconds.
    }
  }

  Future<void> _releaseAllShareClaims() async {
    final guildId = state.guildId;
    final channelId = state.channelId;
    final shareIds = _watchedShares.toList();
    _watchedShares.clear();
    if (guildId == null || channelId == null) return;
    for (final shareId in shareIds) {
      try {
        await repository.unwatchShare(
          guildId: guildId,
          channelId: channelId,
          shareId: shareId,
        );
      } catch (_) {
        // Best-effort.
      }
    }
  }

  /// Called by the voice screen as it appears and disappears.
  void setSharesVisible(bool visible) {
    if (_sharesVisible == visible) return;
    _sharesVisible = visible;
    if (state.phase == GuildVoicePhase.active) {
      unawaited(repository.refetchSnapshot());
    }
  }

  // ── Heartbeat ─────────────────────────────────────────────────────────────

  Future<void> _sendHeartbeat() async {
    final channelId = state.channelId;
    if (channelId == null || state.phase != GuildVoicePhase.active) return;
    final webRtc = _webRtc;
    await repository.invokeHeartbeat(
      channelId: channelId,
      state: VoiceHeartbeatState(
        knownInstanceId: repository.knownInstanceId,
        knownVersion: repository.knownVersion,
        mediaSessionId: webRtc?.mediaSessionId,
        audioTrackName: webRtc?.publishedAudioTrackName,
      ),
    );
    for (final shareId in _watchedShares) {
      unawaited(_claimShare(shareId));
    }
  }

  /// One tick of the HTTP liveness loop - see [VoiceLiveness].
  ///
  /// Null when there is no joined channel to assert. The timer is started after
  /// the phase goes active and stopped in [_teardown], so that only happens to
  /// a tick that raced a leave - and a leave is not the server evicting us,
  /// which is the one thing a non-null answer here would be read as.
  Future<VoiceLivenessOutcome?> _assertAlive() async {
    final guildId = state.guildId;
    final channelId = state.channelId;
    if (guildId == null ||
        channelId == null ||
        state.phase != GuildVoicePhase.active) {
      return null;
    }
    return repository.assertAlive(guildId: guildId, channelId: channelId);
  }

  /// A reconnect is when to assert this client's state, not when to rebuild it.
  ///
  /// A dropped socket is not a departure. The server shortens this client's liveness window rather
  /// than evicting it, and reconnecting restores it - so nothing here touches the SFU connection.
  /// The hub and the media are entirely independent transports, the SDK has its own reconnect for
  /// its own socket, and rebuilding media on a hub blip drops audio for a fault that was never on
  /// the media path.
  ///
  /// The heartbeat goes first and immediately, rather than waiting up to 30 seconds for the next
  /// tick: it restores the liveness window and, if this client fell behind while away, brings back a
  /// snapshot on its own. The refetch covers the rest - SignalR does not queue what it missed.
  void _handleConnectionStatus(RealtimeConnectionStatus status) {
    if (status != RealtimeConnectionStatus.connected) return;
    if (state.phase != GuildVoicePhase.active) return;
    unawaited(_sendHeartbeat());
    unawaited(repository.refetchSnapshot());
  }

  // ── Local controls ────────────────────────────────────────────────────────

  Future<void> toggleMute() async {
    if (state.phase != GuildVoicePhase.active) return;
    final isMuted = !state.isMuted;
    final channelId = state.channelId;
    await _webRtc?.setMuted(isMuted);
    // Muting is not a pause in speech and must not be debounced like one: held
    // through the release delay, this device stays ranked as talking with its
    // microphone off, and every other client in the room stays subscribed to
    // the silence.
    if (isMuted) _speaking?.silenceNow();
    emitIfOpen(state.copyWith(isMuted: isMuted));
    if (channelId == null) return;
    _updateParticipant(
      channelId,
      _myUserId,
      (p) => p.copyWith(isMuted: isMuted),
    );
    await repository.invokeMuteChanged(channelId: channelId, isMuted: isMuted);
  }

  Future<void> toggleDeafen() async {
    if (state.phase != GuildVoicePhase.active) return;
    final isDeafened = !state.isDeafened;
    final channelId = state.channelId;
    _webRtc?.setDeafened(isDeafened);
    emitIfOpen(state.copyWith(isDeafened: isDeafened));
    if (channelId == null) return;
    _updateParticipant(
      channelId,
      _myUserId,
      (p) => p.copyWith(isDeafened: isDeafened),
    );
    await repository.invokeDeafenChanged(
      channelId: channelId,
      isDeafened: isDeafened,
    );
  }

  Future<void> toggleSpeaker() async {
    if (state.phase != GuildVoicePhase.active) return;
    final isSpeakerOn = !state.isSpeakerOn;
    emitIfOpen(state.copyWith(isSpeakerOn: isSpeakerOn));
    await _webRtc?.setSpeakerphoneOn(isSpeakerOn);
  }

  /// Current local camera state - read from the roster rather than a separate
  /// field, since the self-tile is already the source of truth other
  /// participants' badges read from.
  bool get isCameraOn => _self?.hasCamera ?? false;

  /// Whether asking to publish video here would only be refused.
  ///
  /// Two independent sources, and both have to permit it. The room's limits
  /// describe what this channel allows, and follow a plan that lapses mid-call;
  /// the **connection token** describes what this client was actually granted,
  /// which is the more authoritative of the two - a member whose plan carries
  /// no video connects and hears everyone, and cannot turn a camera on however
  /// the client is patched.
  ///
  /// False when neither has been reported: a control disabled on the strength
  /// of a field nobody sent is worse than one that is pressed and answered.
  bool get isVideoBlocked =>
      !(state.limits?.canPublishVideo ?? true) ||
      !(_webRtc?.canPublishVideo ?? true);

  Future<void> toggleCamera() async {
    if (state.phase != GuildVoicePhase.active) return;
    final channelId = state.channelId;
    final webRtc = _webRtc;
    if (channelId == null || webRtc == null) return;
    final turningOn = !isCameraOn;

    // Pre-empted rather than attempted. The control is already disabled where
    // this is true, so reaching here means the room changed under the button -
    // and the sentence matters more in that case, not less.
    final blocked = turningOn ? state.limits?.videoBlockedSentence : null;
    if (blocked != null) {
      emitIfOpen(state.copyWith(videoNotice: blocked));
      return;
    }

    try {
      if (turningOn) {
        await webRtc.publishLocalVideo(target: await _cameraTarget());
      } else {
        await webRtc.stopLocalVideo();
      }
    } on EntitlementDenialException catch (e) {
      // A publish the server would not carry out at any size. Explained, and
      // not retried: an entitlement refusal answered by asking again is one
      // refusal turned into three.
      emitIfOpen(state.copyWith(videoNotice: e.denial.sentence));
      return;
    } catch (_) {
      return; // Capture failed (denied permission, no camera, etc.) - bail.
    }
    _updateParticipant(
      channelId,
      _myUserId,
      (p) => p.copyWith(hasCamera: turningOn),
    );
    if (!turningOn) _clearVideoNoticeIfIdle();
    _bumpVideoRevision();
    await repository.invokeCameraChanged(
      channelId: channelId,
      isCameraOn: turningOn,
    );
  }

  /// Which way the local camera points, for the self-preview's mirroring and
  /// the flip control's icon. Front while nothing is publishing, which is the
  /// side the next publish will open.
  bool get isFrontCamera => _webRtc?.isFrontCamera ?? true;

  /// Flips the local camera. Nothing is published or declared again, so the
  /// roster does not move and no event goes out - see
  /// `VoiceWebRtcService.switchCamera`. The service bumps the video revision
  /// through `onTracksChanged`, which is what re-attaches the renderers.
  /// Awaited rather than forwarded, so the control that called this stays busy
  /// until the other camera is actually live.
  Future<void> switchCamera() async {
    await _webRtc?.switchCamera();
  }

  /// What to open the camera at here: this room's granted rung, resolved
  /// against the ladder the server publishes.
  ///
  /// The rung comes from the room's own limits rather than from an account
  /// snapshot, because the room's copy is the one that can change mid-call and
  /// the one the server will actually enforce against. The ladder comes from the
  /// account, because it is a property of the instance.
  ///
  /// **A rung that changes mid-call does not move an already-published camera.**
  /// Nothing in this client can change an encoding without republishing, and
  /// tearing a live picture down to re-open it smaller is a worse answer than
  /// letting the server cap the layer - which it does, and says so in the
  /// notice. The next publish picks the new rung up.
  Future<VideoPublishIntent?> _cameraTarget() async {
    final rung = state.limits?.videoRung;
    if (rung == null) return null;
    return cameraTargetFor(
      rung: rung,
      ladder: await entitlements?.videoQualityLadder(),
    );
  }

  /// Drops the video notice once nothing is being published.
  ///
  /// It describes the picture this device is sending, so it outlives neither
  /// the camera nor the share - and it has to survive one of them ending while
  /// the other runs, which is why this asks about both rather than clearing on
  /// either.
  void _clearVideoNoticeIfIdle() {
    if (isCameraOn || isScreenSharing) return;
    if (state.videoNotice == null) return;
    emitIfOpen(state.copyWith(clearVideoNotice: true));
  }

  /// Whether this device is live - screen sharing.
  bool get isScreenSharing => _self?.isStreaming ?? false;

  String? _myShareId;

  Future<void> toggleScreenShare() async {
    if (state.phase != GuildVoicePhase.active) return;
    final channelId = state.channelId;
    final webRtc = _webRtc;
    if (channelId == null || webRtc == null) return;

    if (isScreenSharing) {
      final shareId = _myShareId;
      _myShareId = null;
      try {
        await webRtc.stopScreenShare();
      } catch (_) {
        // Best-effort - fall through to update local state regardless.
      }
      if (shareId != null) {
        _updateParticipant(
          channelId,
          _myUserId,
          (p) => p.withoutShare(shareId),
        );
        _clearVideoNoticeIfIdle();
        _bumpVideoRevision();
        await repository.invokeScreenShareStopped(
          channelId: channelId,
          shareId: shareId,
        );
      }
      return;
    }

    final blocked = state.limits?.videoBlockedSentence;
    if (blocked != null) {
      emitIfOpen(state.copyWith(videoNotice: blocked));
      return;
    }

    final shareId =
        '${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
    try {
      await webRtc.startScreenShare(shareId);
    } on EntitlementDenialException catch (e) {
      emitIfOpen(state.copyWith(videoNotice: e.denial.sentence));
      return;
    } catch (_) {
      return; // Permission denied/cancelled the system picker - bail.
    }
    _myShareId = shareId;
    _updateParticipant(
      channelId,
      _myUserId,
      (p) => p.withShare(shareId, trackName: TrackNaming.screenTrack(shareId)),
    );
    _bumpVideoRevision();
    await repository.invokeScreenShareStarted(
      channelId: channelId,
      shareId: shareId,
    );
  }

  void _bumpVideoRevision() =>
      emitIfOpen(state.copyWith(videoRevision: state.videoRevision + 1));

  /// Track getters for the UI - read imperatively (see
  /// [GuildVoiceState.videoRevision] for why `MediaStreamTrack`s can't live in
  /// cubit state itself).
  MediaStreamTrack? get localVideoTrack => _webRtc?.localVideoTrack;
  MediaStreamTrack? get localScreenTrack => _webRtc?.localScreenTrack;
  MediaStreamTrack? remoteVideoTrackFor(String userId) =>
      _webRtc?.remoteVideoTrackFor(userId);
  MediaStreamTrack? remoteScreenTrackFor(String userId) =>
      _webRtc?.remoteScreenTrackFor(userId);
  MediaStreamTrack? remoteScreenTrackForShare(String shareId) =>
      _webRtc?.remoteScreenTrackForShare(shareId);

  /// How large this client is drawing [userId], which is what the server picks
  /// their simulcast layer from. Reported by the tiles themselves; safe to call
  /// on every layout, and a no-op before the transport exists.
  void reportTileHeight({
    required String tileId,
    required String userId,
    required int devicePixels,
  }) => _webRtc?.reportTileHeight(
    tileId: tileId,
    userId: userId,
    devicePixels: devicePixels,
  );

  void forgetTile(String tileId) => _webRtc?.forgetTile(tileId);

  /// One publisher this client is looking at full-screen, and optionally the
  /// share whose audio it wants with them. Both null returns to the grid. See
  /// `VoiceWebRtcService.setFocus`.
  Future<void> setFocus({String? userId, String? shareId}) async =>
      _webRtc?.setFocus(userId: userId, shareId: shareId);

  // ── Events ────────────────────────────────────────────────────────────────

  void _handleEvent(GuildVoiceEvent event) {
    switch (event) {
      case VoiceSnapshotReceived(:final snapshot):
        _applySnapshot(snapshot);

      case VoiceSubscriptionsChanged(:final channelId, :final subscriptions):
        // Nobody did anything - the conversation moved. The transport diffs
        // this against what it is currently pulling and adjusts; nothing here
        // tears anything down, and everyone stays rendered.
        if (channelId != state.channelId) return;
        _webRtc?.applySubscriptionSet(subscriptions);

      case VoiceResyncRequested():
        // Everything but roomGone was already answered by a refetch in the
        // repository. roomGone means the room no longer exists: rejoining has
        // to go back through the authorised join path, so this device tears
        // down rather than re-asserting itself.
        if (event.isRoomGone && event.channelId == state.channelId) {
          unawaited(_handleRoomGone());
        }

      case UserJoinedVoiceChannel(:final userId, :final channelId):
        if (userId == _myUserId) return;
        if (channelId == state.channelId) {
          unawaited(soundService.playJoinCall());
        }
        _addToRoster(channelId, VoiceParticipantState(userId: userId));

      case UserLeftVoiceChannel(:final userId, :final channelId):
        if (userId != _myUserId && channelId == state.channelId) {
          unawaited(soundService.playLeaveCall());
        }
        _removeFromRoster(channelId, userId);
        if (channelId == state.channelId) {
          _webRtc?.unsubscribeParticipant(userId);
        }

      case VoiceParticipantJoined(
        :final userId,
        :final channelId,
        :final mediaSessionId,
        :final audioTrackName,
      ):
        if (userId == _myUserId) return;
        _upsertParticipant(
          channelId,
          userId,
          (p) => p.copyWith(isPublishing: true),
        );
        if (channelId != state.channelId ||
            state.phase != GuildVoicePhase.active) {
          return;
        }
        unawaited(
          _webRtc?.subscribeToParticipant(
            userId: userId,
            mediaSessionId: mediaSessionId,
            trackName: audioTrackName,
          ),
        );

      case VoiceTrackPublished(
        :final userId,
        :final channelId,
        :final mediaSessionId,
        :final trackName,
        :final kind,
        :final shareId,
      ):
        if (userId == _myUserId) return;
        _handleTrackPublished(
          userId: userId,
          channelId: channelId,
          mediaSessionId: mediaSessionId,
          trackName: trackName,
          kind: trackKindFromWire(kind),
          shareId: shareId,
        );

      case VoiceTrackClosed(
        :final userId,
        :final channelId,
        :final trackName,
        :final shareId,
      ):
        _handleTrackClosed(
          userId: userId,
          channelId: channelId,
          trackName: trackName,
          shareId: shareId,
        );

      case VoiceMuteChanged(:final userId, :final channelId, :final isMuted):
        if (userId == _myUserId) return;
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(isMuted: isMuted),
        );

      case VoiceDeafenChanged(
        :final userId,
        :final channelId,
        :final isDeafened,
      ):
        if (userId == _myUserId) return;
        // Deafen implies mute one-way for the badge: false doesn't auto-unmute.
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(
            isDeafened: isDeafened,
            isMuted: isDeafened ? true : p.isMuted,
          ),
        );

      case VoiceCameraChanged(
        :final userId,
        :final channelId,
        :final isCameraOn,
      ):
        if (userId == _myUserId) return;
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(hasCamera: isCameraOn),
        );

      case VoiceSpeakingChanged(
        :final userId,
        :final channelId,
        :final isSpeaking,
      ):
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(isSpeaking: isSpeaking),
        );

      case VoiceScreenShareStarted(
        :final userId,
        :final channelId,
        :final shareId,
      ):
        _upsertParticipant(channelId, userId, (p) => p.withShare(shareId));

      case VoiceScreenShareStopped(
        :final userId,
        :final channelId,
        :final shareId,
      ):
        _updateParticipant(channelId, userId, (p) => p.withoutShare(shareId));
        if (channelId != state.channelId) return;
        _webRtc?.unsubscribeShare(userId: userId, shareId: shareId);
        _bumpVideoRevision();
        if (_watchedShares.contains(shareId)) {
          unawaited(_stopWatching(shareId));
        }

      case VoiceShareViewersChanged(
        :final channelId,
        :final shareId,
        :final viewerIds,
      ):
        final roster = state.rosters[channelId];
        if (roster == null) return;
        _setRoster(channelId, [
          for (final p in roster)
            p.shareById(shareId) == null
                ? p
                : p.withShareViewers(shareId, viewerIds),
        ]);

      case VoiceMovedToChannel(:final channelId, :final guildId):
        if (channelId != state.channelId) {
          unawaited(
            join(
              guildId: guildId,
              channelId: channelId,
              channelName: state.channelName ?? '',
              guildName: state.guildName ?? '',
            ),
          );
        }

      case VoiceKickedByOtherDevice(:final channelId):
        if (channelId != state.channelId) return;
        unawaited(
          _tearDownLocally('You joined this channel from another device.'),
        );
    }
  }

  /// Reached two ways, and the second is the one that matters during an
  /// outage: `Resync(roomGone)` over the hub, and a `404`/`409` from the HTTP
  /// liveness ping. A client the sweep evicted is announced to the roster it
  /// has just been removed from, so it is the one participant the hub event
  /// does not reach - the ping is the only channel that can tell it.
  Future<void> _handleRoomGone() =>
      _tearDownLocally('Voice channel is no longer available.');

  Future<void> _tearDownLocally(String message) async {
    final channelId = state.channelId;
    final webRtc = await _teardown();
    final rosters = Map<String, List<VoiceParticipantState>>.from(
      state.rosters,
    );
    if (channelId != null) {
      rosters[channelId] = (rosters[channelId] ?? const [])
          .where((p) => p.userId != _myUserId)
          .toList();
    }
    emitIfOpen(GuildVoiceState(rosters: rosters, errorMessage: message));
    await webRtc?.disconnect();
  }

  void _handleTrackPublished({
    required String userId,
    required String channelId,
    required String mediaSessionId,
    required String trackName,
    required TrackKind kind,
    required String? shareId,
  }) {
    final isJoinedChannel = channelId == state.channelId;
    switch (kind) {
      case TrackKind.audio:
        // The microphone is subscribed via ParticipantJoined, the event that
        // guarantees the track exists.
        break;
      case TrackKind.video:
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(hasCamera: true),
        );
        if (!isJoinedChannel) return;
        unawaited(
          _webRtc?.subscribeToTrack(
            userId: userId,
            mediaSessionId: mediaSessionId,
            trackName: trackName,
            kind: kind,
          ),
        );
        _bumpVideoRevision();
      case TrackKind.screen:
      case TrackKind.screenAudio:
        if (shareId == null) return;
        _upsertParticipant(
          channelId,
          userId,
          (p) => p.withShare(shareId, trackName: trackName),
        );
        if (!isJoinedChannel || !_sharesVisible) return;
        if (_watchedShares.add(shareId)) unawaited(_claimShare(shareId));
        unawaited(
          _webRtc?.subscribeToTrack(
            userId: userId,
            mediaSessionId: mediaSessionId,
            trackName: trackName,
            kind: kind,
            shareId: shareId,
          ),
        );
        _bumpVideoRevision();
    }
  }

  void _handleTrackClosed({
    required String userId,
    required String channelId,
    required String trackName,
    required String? shareId,
  }) {
    final descriptor = TrackNaming.describe(trackName);
    final resolvedShareId = shareId ?? descriptor.shareId;
    final isJoinedChannel = channelId == state.channelId;
    switch (descriptor.kind) {
      case TrackKind.audio:
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(isPublishing: false),
        );
        if (isJoinedChannel) {
          _webRtc?.unsubscribeTrack(userId: userId, kind: TrackKind.audio);
        }
      case TrackKind.video:
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(hasCamera: false),
        );
        if (!isJoinedChannel) return;
        _webRtc?.unsubscribeTrack(userId: userId, kind: TrackKind.video);
        _bumpVideoRevision();
      case TrackKind.screen:
      case TrackKind.screenAudio:
        if (resolvedShareId == null) return;
        if (isJoinedChannel) {
          _webRtc?.unsubscribeTrack(
            userId: userId,
            kind: descriptor.kind,
            shareId: resolvedShareId,
          );
        }
        // Only the video half ending retires the share; a share can lose its
        // audio track and keep running.
        if (descriptor.kind != TrackKind.screen) return;
        _updateParticipant(
          channelId,
          userId,
          (p) => p.withoutShare(resolvedShareId),
        );
        if (isJoinedChannel) _bumpVideoRevision();
    }
  }

  // ── Roster helpers ────────────────────────────────────────────────────────

  VoiceParticipantState? get _self {
    final channelId = state.channelId;
    if (channelId == null) return null;
    return state
        .rosterFor(channelId)
        .where((p) => p.userId == _myUserId)
        .firstOrNull;
  }

  void _addToRoster(String channelId, VoiceParticipantState participant) {
    final list = List<VoiceParticipantState>.from(
      state.rosters[channelId] ?? const [],
    );
    if (list.any((p) => p.userId == participant.userId)) return;
    list.add(participant);
    _setRoster(channelId, list);
  }

  void _removeFromRoster(String channelId, String userId) {
    final list = (state.rosters[channelId] ?? const [])
        .where((p) => p.userId != userId)
        .toList();
    _setRoster(channelId, list);
  }

  void _updateParticipant(
    String channelId,
    String userId,
    VoiceParticipantState Function(VoiceParticipantState) update,
  ) {
    final list = state.rosters[channelId];
    if (list == null) return;
    _setRoster(channelId, [
      for (final p in list) p.userId == userId ? update(p) : p,
    ]);
  }

  /// Updates a participant, adding them when the roster has not heard of them
  /// yet - a live event can name someone the last snapshot did not.
  void _upsertParticipant(
    String channelId,
    String userId,
    VoiceParticipantState Function(VoiceParticipantState) update,
  ) {
    final list = state.rosters[channelId] ?? const <VoiceParticipantState>[];
    if (!list.any((p) => p.userId == userId)) {
      _setRoster(channelId, [
        ...list,
        update(VoiceParticipantState(userId: userId)),
      ]);
      return;
    }
    _setRoster(channelId, [
      for (final p in list) p.userId == userId ? update(p) : p,
    ]);
  }

  void _setRoster(String channelId, List<VoiceParticipantState> list) {
    final rosters = Map<String, List<VoiceParticipantState>>.from(
      state.rosters,
    );
    rosters[channelId] = list;
    emitIfOpen(state.copyWith(rosters: rosters));
  }

  @override
  Future<void> close() {
    _heartbeat.stop();
    _liveness.stop();
    unawaited(_sub.cancel());
    unawaited(_connectionSub.cancel());
    return super.close();
  }
}
