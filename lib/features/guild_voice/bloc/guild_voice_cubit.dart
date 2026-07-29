import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show MediaStreamTrack;

import '../../../core/sound/sound_service.dart';
import '../../../core/webrtc/track_kind.dart';
import '../../auth/data/auth_repository.dart';
import '../data/guild_voice_repository.dart';
import '../data/models/guild_voice_dto.dart';
import '../webrtc/guild_voice_webrtc_service.dart';

enum GuildVoicePhase { idle, connecting, active }

class VoiceParticipantState extends Equatable {
  const VoiceParticipantState({
    required this.userId,
    this.isMuted = false,
    this.isDeafened = false,
    this.isStreaming = false,
    this.hasCamera = false,
  });

  final String userId;
  final bool isMuted;
  final bool isDeafened;

  /// Screen sharing — kept as `isStreaming` for backward compatibility with
  /// existing UI/roster code; [hasCamera] is the separate camera-on flag.
  final bool isStreaming;
  final bool hasCamera;

  VoiceParticipantState copyWith({
    bool? isMuted,
    bool? isDeafened,
    bool? isStreaming,
    bool? hasCamera,
  }) => VoiceParticipantState(
    userId: userId,
    isMuted: isMuted ?? this.isMuted,
    isDeafened: isDeafened ?? this.isDeafened,
    isStreaming: isStreaming ?? this.isStreaming,
    hasCamera: hasCamera ?? this.hasCamera,
  );

  @override
  List<Object?> get props => [
    userId,
    isMuted,
    isDeafened,
    isStreaming,
    hasCamera,
  ];
}

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
  });

  final GuildVoicePhase phase;
  final String? guildId;
  final String? channelId;
  final String? channelName;
  final String? guildName;
  final bool isMuted;
  final bool isDeafened;

  /// Whether output is routed to the loud/speakerphone output rather than
  /// the quiet call (earpiece) speaker. Defaults on — with no headset
  /// connected, calls were otherwise landing on the quiet earpiece route
  /// with no way to switch, unlike every other calling app.
  final bool isSpeakerOn;

  /// Set once, the moment the channel join reaches [GuildVoicePhase.active]
  /// — drives the elapsed-time display. Never touched again until the next
  /// join (leave/error reset to a fresh [GuildVoiceState] with this null).
  final DateTime? connectedAt;

  /// Every voice channel's roster, keyed by channelId — not just the one
  /// the local user has joined. This is what lets the sidebar show live
  /// participant avatars for channels the user hasn't joined, like Discord.
  final Map<String, List<VoiceParticipantState>> rosters;
  final String? errorMessage;

  bool get isInVoice => phase != GuildVoicePhase.idle;

  List<VoiceParticipantState> rosterFor(String channelId) =>
      rosters[channelId] ?? const [];

  /// Identity fields (guildId/channelId/channelName/guildName) intentionally
  /// never fall back to null here — a full reset (leave/error) constructs a
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
  );

  /// Bumped on every local/remote camera or screen-share track add/remove —
  /// `MediaStreamTrack`s themselves can't live in this `Equatable` state (not
  /// comparable/immutable-safe), so `VideoParticipantTile`/`ScreenShareView`
  /// instead pull the current track imperatively from the webrtc service and
  /// rely on this counter changing to know when to re-pull and rebuild.
  final int videoRevision;

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
  ];
}

/// App-lifetime singleton owning the one guild voice channel the app can be
/// joined to at a time, plus live rosters for every voice channel visible in
/// the sidebar — the guild-voice counterpart to `CallCubit`. Joining a
/// channel does not force any particular screen; unlike 1:1 calling, guild
/// voice deliberately keeps the user free to browse other text channels
/// while connected (mirrors Alpine's persistent `voice-status-bar`).
class GuildVoiceCubit extends Cubit<GuildVoiceState> {
  GuildVoiceCubit({
    required this.repository,
    required this.authRepository,
    required this.soundService,
    required GuildVoiceWebRtcService Function() webRtcServiceFactory,
  }) : _webRtcServiceFactory = webRtcServiceFactory,
       super(const GuildVoiceState()) {
    _sub = repository.events.listen(_handleEvent);
  }

  final GuildVoiceRepository repository;
  final AuthRepository authRepository;
  final SoundService soundService;
  final GuildVoiceWebRtcService Function() _webRtcServiceFactory;
  late final StreamSubscription<GuildVoiceEvent> _sub;
  GuildVoiceWebRtcService? _webRtc;
  Timer? _heartbeatTimer;

  String get _myUserId => authRepository.currentUserId ?? '';

  /// Populates the roster for one voice channel without joining it — used
  /// when a guild's channel list loads, so sidebar participant counts show
  /// up even for channels the user hasn't entered.
  Future<void> hydrateChannelRoster(String guildId, String channelId) async {
    try {
      final voiceState = await repository.getState(guildId, channelId);
      _setRoster(
        channelId,
        voiceState.participants.map(_toParticipantState).toList(),
      );
    } catch (_) {
      // Best-effort — realtime events will keep it eventually consistent.
    }
  }

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
    emit(
      state.copyWith(
        phase: GuildVoicePhase.connecting,
        guildId: guildId,
        channelId: channelId,
        channelName: channelName,
        guildName: guildName,
      ),
    );
    try {
      final voiceState = await repository.join(guildId, channelId);
      await _connect(guildId, channelId, voiceState);
    } catch (_) {
      emit(
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
    _stopHeartbeat();
    final webRtc = _webRtc;
    _webRtc = null;
    final rosters = Map<String, List<VoiceParticipantState>>.from(
      state.rosters,
    );
    rosters[channelId] = (rosters[channelId] ?? const [])
        .where((p) => p.userId != _myUserId)
        .toList();
    emit(GuildVoiceState(rosters: rosters));
    await webRtc?.disconnect();
    try {
      await repository.leave(guildId, channelId);
    } catch (_) {
      // Best-effort — we've already torn down locally.
    }
  }

  Future<void> toggleMute() async {
    if (state.phase != GuildVoicePhase.active) return;
    final isMuted = !state.isMuted;
    final channelId = state.channelId;
    _webRtc?.setMuted(isMuted);
    if (channelId != null)
      _updateParticipant(
        channelId,
        _myUserId,
        (p) => p.copyWith(isMuted: isMuted),
      );
    emit(state.copyWith(isMuted: isMuted));
    if (channelId != null) {
      await repository.invokeMuteChanged(
        channelId: channelId,
        isMuted: isMuted,
      );
    }
  }

  Future<void> toggleDeafen() async {
    if (state.phase != GuildVoicePhase.active) return;
    final isDeafened = !state.isDeafened;
    final channelId = state.channelId;
    _webRtc?.setDeafened(isDeafened);
    if (channelId != null) {
      _updateParticipant(
        channelId,
        _myUserId,
        (p) => p.copyWith(isDeafened: isDeafened),
      );
    }
    emit(state.copyWith(isDeafened: isDeafened));
    if (channelId != null) {
      await repository.invokeDeafenChanged(
        channelId: channelId,
        isDeafened: isDeafened,
      );
    }
  }

  Future<void> toggleSpeaker() async {
    if (state.phase != GuildVoicePhase.active) return;
    final isSpeakerOn = !state.isSpeakerOn;
    emit(state.copyWith(isSpeakerOn: isSpeakerOn));
    await _webRtc?.setSpeakerphoneOn(isSpeakerOn);
  }

  /// Current local camera state — read from the roster rather than a
  /// separate field, since the self-tile in [state.rosters] is already the
  /// source of truth other participants' badges read from.
  bool get isCameraOn {
    final channelId = state.channelId;
    if (channelId == null) return false;
    return state
        .rosterFor(channelId)
        .where((p) => p.userId == _myUserId)
        .firstOrNull
        ?.hasCamera ??
        false;
  }

  Future<void> toggleCamera() async {
    if (state.phase != GuildVoicePhase.active) return;
    final channelId = state.channelId;
    final webRtc = _webRtc;
    if (channelId == null || webRtc == null) return;
    final turningOn = !isCameraOn;
    try {
      if (turningOn) {
        await webRtc.publishLocalVideo();
      } else {
        await webRtc.stopLocalVideo();
      }
    } catch (_) {
      return; // Capture failed (denied permission, no camera, etc.) — bail.
    }
    _updateParticipant(
      channelId,
      _myUserId,
      (p) => p.copyWith(hasCamera: turningOn),
    );
    _bumpVideoRevision();
    await repository.invokeCameraChanged(
      channelId: channelId,
      isCameraOn: turningOn,
    );
  }

  /// Mirrors [isCameraOn] for screen sharing — Android only (see
  /// `toggleScreenShare` callers, which gate the button by platform).
  bool get isScreenSharing {
    final channelId = state.channelId;
    if (channelId == null) return false;
    return state
            .rosterFor(channelId)
            .where((p) => p.userId == _myUserId)
            .firstOrNull
            ?.isStreaming ??
        false;
  }

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
        // Best-effort — fall through to update local state regardless.
      }
      _updateParticipant(
        channelId,
        _myUserId,
        (p) => p.copyWith(isStreaming: false),
      );
      _bumpVideoRevision();
      if (shareId != null) {
        await repository.invokeScreenShareStopped(
          channelId: channelId,
          shareId: shareId,
        );
      }
    } else {
      final shareId =
          '${DateTime.now().microsecondsSinceEpoch}-${identityHashCode(this)}';
      try {
        await webRtc.startScreenShare(shareId);
      } catch (_) {
        return; // Permission denied/cancelled the system picker — bail.
      }
      _myShareId = shareId;
      _updateParticipant(
        channelId,
        _myUserId,
        (p) => p.copyWith(isStreaming: true),
      );
      _bumpVideoRevision();
      await repository.invokeScreenShareStarted(
        channelId: channelId,
        shareId: shareId,
        trackName: 'screen-$shareId',
      );
    }
  }

  void _bumpVideoRevision() =>
      emit(state.copyWith(videoRevision: state.videoRevision + 1));

  /// Track getters for the UI — read imperatively (see [GuildVoiceState.videoRevision]
  /// doc comment for why `MediaStreamTrack`s can't live in cubit state itself).
  MediaStreamTrack? get localVideoTrack => _webRtc?.localVideoTrack;
  MediaStreamTrack? get localScreenTrack => _webRtc?.localScreenTrack;
  MediaStreamTrack? remoteVideoTrackFor(String userId) =>
      _webRtc?.remoteVideoTrackFor(userId);
  MediaStreamTrack? remoteScreenTrackFor(String userId) =>
      _webRtc?.remoteScreenTrackFor(userId);

  Future<void> _connect(
    String guildId,
    String channelId,
    VoiceStateDto voiceState,
  ) async {
    final webRtc = _webRtcServiceFactory();
    _webRtc = webRtc;

    final rosters = Map<String, List<VoiceParticipantState>>.from(
      state.rosters,
    );
    rosters[channelId] = [
      VoiceParticipantState(
        userId: _myUserId,
        isMuted: state.isMuted,
        isDeafened: state.isDeafened,
      ),
      for (final p in voiceState.participants)
        if (p.userId != _myUserId) _toParticipantState(p),
    ];
    emit(
      state.copyWith(
        phase: GuildVoicePhase.active,
        rosters: rosters,
        connectedAt: DateTime.now(),
      ),
    );
    unawaited(soundService.playJoinCall());
    _startHeartbeat();

    try {
      await webRtc.connect(guildId, channelId);
      webRtc.setMuted(state.isMuted);
      webRtc.setDeafened(state.isDeafened);
      await webRtc.setSpeakerphoneOn(state.isSpeakerOn);
      for (final p in voiceState.participants) {
        final cfSessionId = p.cfSessionId;
        final trackName = p.audioTrackName;
        if (p.userId != _myUserId && cfSessionId != null && trackName != null) {
          unawaited(
            webRtc.subscribeToParticipant(
              userId: p.userId,
              cfSessionId: cfSessionId,
              trackName: trackName,
            ),
          );
        }
      }
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not connect audio.'));
    }
  }

  void _handleEvent(GuildVoiceEvent event) {
    switch (event) {
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
        if (channelId == state.channelId)
          _webRtc?.unsubscribeParticipant(userId);

      case VoiceParticipantJoined(
        :final userId,
        :final channelId,
        :final cfSessionId,
        :final audioTrackName,
      ):
        if (userId == _myUserId ||
            channelId != state.channelId ||
            state.phase != GuildVoicePhase.active) {
          return;
        }
        _addToRoster(channelId, VoiceParticipantState(userId: userId));
        unawaited(
          _webRtc?.subscribeToParticipant(
            userId: userId,
            cfSessionId: cfSessionId,
            trackName: audioTrackName,
          ),
        );

      case VoiceTrackPublished(
        :final userId,
        :final channelId,
        :final cfSessionId,
        :final trackName,
        :final kind,
      ):
        if (userId == _myUserId) return;
        final trackKind = trackKindFromWire(kind);
        if (trackKind == null) return; // screenAudio or unknown - ignored
        if (channelId == state.channelId) {
          unawaited(
            _webRtc?.subscribeToTrack(
              userId: userId,
              cfSessionId: cfSessionId,
              trackName: trackName,
              kind: trackKind,
            ),
          );
          _bumpVideoRevision();
        }
        _updateParticipant(
          channelId,
          userId,
          trackKind == TrackKind.screen
              ? (p) => p.copyWith(isStreaming: true)
              : (p) => p.copyWith(hasCamera: true),
        );

      case VoiceTrackClosed(:final userId, :final channelId, :final trackName):
        final trackKind = trackName == 'camera'
            ? TrackKind.video
            : trackName.startsWith('screen-')
            ? TrackKind.screen
            : null;
        if (trackKind == null) return;
        if (channelId == state.channelId) {
          _webRtc?.unsubscribeTrack(userId: userId, kind: trackKind);
          _bumpVideoRevision();
        }
        _updateParticipant(
          channelId,
          userId,
          trackKind == TrackKind.screen
              ? (p) => p.copyWith(isStreaming: false)
              : (p) => p.copyWith(hasCamera: false),
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

      case VoiceCameraChanged(:final userId, :final channelId, :final isCameraOn):
        if (userId == _myUserId) return;
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(hasCamera: isCameraOn),
        );

      case VoiceScreenShareStarted(:final userId, :final channelId):
        _updateParticipant(
          channelId,
          userId,
          (p) => p.copyWith(isStreaming: true),
        );

      case VoiceScreenShareStopped():
        break; // Teardown rides on VoiceTrackClosed, same as Alpine.

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
        _stopHeartbeat();
        final webRtc = _webRtc;
        _webRtc = null;
        final rosters = Map<String, List<VoiceParticipantState>>.from(
          state.rosters,
        );
        rosters[channelId] = (rosters[channelId] ?? const [])
            .where((p) => p.userId != _myUserId)
            .toList();
        emit(
          GuildVoiceState(
            rosters: rosters,
            errorMessage: 'You joined this channel from another device.',
          ),
        );
        unawaited(webRtc?.disconnect());
    }
  }

  VoiceParticipantState _toParticipantState(VoiceParticipantDto p) =>
      VoiceParticipantState(
        userId: p.userId,
        isMuted: p.isSelfMuted || p.isServerMuted,
        isDeafened: p.isSelfDeafened || p.isServerDeafened,
        isStreaming: p.isStreaming,
      );

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

  void _setRoster(String channelId, List<VoiceParticipantState> list) {
    final rosters = Map<String, List<VoiceParticipantState>>.from(
      state.rosters,
    );
    rosters[channelId] = list;
    emit(state.copyWith(rosters: rosters));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => repository.invokeHeartbeat(),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  Future<void> close() {
    _stopHeartbeat();
    unawaited(_sub.cancel());
    return super.close();
  }
}
