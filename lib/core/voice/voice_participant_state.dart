import 'package:equatable/equatable.dart';

import 'voice_snapshot_dto.dart';

/// One live screen share, as the UI sees it.
///
/// A share is identified by its [shareId], not by its publisher: one
/// participant can run more than one, and the two halves of a single share -
/// video and, optionally, the shared application's own audio - are tied
/// together by this id and nothing else.
class VoiceShareState extends Equatable {
  const VoiceShareState({
    required this.shareId,
    this.trackNames = const [],
    this.viewerIds = const [],
  });

  final String shareId;

  /// Exactly the tracks that exist. A share may be video-only, so the audio
  /// half is read from here rather than assumed.
  final List<String> trackNames;

  final List<String> viewerIds;

  int get viewerCount => viewerIds.length;

  VoiceShareState copyWith({
    List<String>? trackNames,
    List<String>? viewerIds,
  }) => VoiceShareState(
    shareId: shareId,
    trackNames: trackNames ?? this.trackNames,
    viewerIds: viewerIds ?? this.viewerIds,
  );

  @override
  List<Object?> get props => [shareId, trackNames, viewerIds];
}

/// One participant of a voice room, for a guild channel and a direct call
/// alike - the two are the same system, so they get the same participant.
class VoiceParticipantState extends Equatable {
  const VoiceParticipantState({
    required this.userId,
    this.isMuted = false,
    this.isDeafened = false,
    this.hasCamera = false,
    this.isSpeaking = false,
    this.isPublishing = false,
    this.shares = const [],
  });

  /// Projects one snapshot row. The snapshot is authoritative, so everything
  /// here comes from it rather than being merged with what was held before.
  factory VoiceParticipantState.fromSnapshot(
    VoiceParticipantSnapshotDto p, {
    bool isSpeaking = false,
    bool hasCamera = false,
  }) => VoiceParticipantState(
    userId: p.userId,
    isMuted: p.isMuted,
    isDeafened: p.isDeafened,
    isPublishing: p.isPublishing,
    hasCamera: hasCamera,
    isSpeaking: isSpeaking,
    shares: [
      for (final s in p.shares)
        VoiceShareState(shareId: s.shareId, trackNames: s.trackNames),
    ],
  );

  final String userId;
  final bool isMuted;
  final bool isDeafened;
  final bool hasCamera;

  /// Voice-activity detection. Relay only - never persisted server-side, so it
  /// is not carried in a snapshot and survives one only by being passed
  /// forward explicitly.
  final bool isSpeaking;

  /// Whether this participant's microphone is actually pullable. A session id
  /// alone is not enough, so this is the only condition under which a
  /// subscribe is attempted.
  final bool isPublishing;

  final List<VoiceShareState> shares;

  /// Whether this participant is live - screen sharing, in Discord's sense of
  /// the word. Derived from [shares] rather than stored, so it cannot disagree
  /// with the shares actually being rendered.
  bool get isStreaming => shares.isNotEmpty;

  VoiceShareState? shareById(String shareId) =>
      shares.where((s) => s.shareId == shareId).firstOrNull;

  VoiceParticipantState copyWith({
    bool? isMuted,
    bool? isDeafened,
    bool? hasCamera,
    bool? isSpeaking,
    bool? isPublishing,
    List<VoiceShareState>? shares,
  }) => VoiceParticipantState(
    userId: userId,
    isMuted: isMuted ?? this.isMuted,
    isDeafened: isDeafened ?? this.isDeafened,
    hasCamera: hasCamera ?? this.hasCamera,
    isSpeaking: isSpeaking ?? this.isSpeaking,
    isPublishing: isPublishing ?? this.isPublishing,
    shares: shares ?? this.shares,
  );

  /// Adds a share, or merges track names into one already known. Both a
  /// `ScreenShareStarted` and the `TrackPublished` for each half can be the
  /// first thing that names a given share, so this has to be idempotent.
  VoiceParticipantState withShare(String shareId, {String? trackName}) {
    final existing = shareById(shareId);
    if (existing == null) {
      return copyWith(
        shares: [
          ...shares,
          VoiceShareState(shareId: shareId, trackNames: [?trackName]),
        ],
      );
    }
    if (trackName == null || existing.trackNames.contains(trackName)) {
      return this;
    }
    return copyWith(
      shares: [
        for (final s in shares)
          if (s.shareId == shareId)
            s.copyWith(trackNames: [...s.trackNames, trackName])
          else
            s,
      ],
    );
  }

  VoiceParticipantState withoutShare(String shareId) =>
      copyWith(shares: shares.where((s) => s.shareId != shareId).toList());

  VoiceParticipantState withShareViewers(
    String shareId,
    List<String> viewerIds,
  ) => copyWith(
    shares: [
      for (final s in shares)
        if (s.shareId == shareId) s.copyWith(viewerIds: viewerIds) else s,
    ],
  );

  @override
  List<Object?> get props => [
    userId,
    isMuted,
    isDeafened,
    hasCamera,
    isSpeaking,
    isPublishing,
    shares,
  ];
}
