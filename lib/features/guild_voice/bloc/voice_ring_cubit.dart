import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../../../core/device/device_id_service.dart';
import '../../../core/realtime/realtime_transport.dart';
import '../data/models/voice_ring_dto.dart';
import '../data/voice_ring_api.dart';
import '../data/voice_ring_repository.dart';

/// One invitation asking this account in, with its own countdown.
class IncomingRing extends Equatable {
  const IncomingRing({required this.invitation, required this.remainingSeconds});

  final VoiceRingInvitationDto invitation;

  /// Counted down from `expiresInSeconds`, **not** derived from `expiresAt`. A
  /// handset whose clock is a few minutes out is ordinary rather than exotic,
  /// and trusting the absolute deadline there draws an invitation that is
  /// already dead or one that never lapses.
  final int remainingSeconds;

  String get ringId => invitation.ringId;

  IncomingRing copyWith({int? remainingSeconds}) => IncomingRing(
    invitation: invitation,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
  );

  @override
  List<Object?> get props => [invitation.ringId, remainingSeconds];
}

/// An invitation this account has out, from the inviter's side.
class OutgoingRing extends Equatable {
  const OutgoingRing({
    required this.ringId,
    required this.channelId,
    required this.targetUserId,
    required this.remainingSeconds,
  });

  final String ringId;
  final String channelId;
  final String targetUserId;
  final int remainingSeconds;

  OutgoingRing copyWith({int? remainingSeconds}) => OutgoingRing(
    ringId: ringId,
    channelId: channelId,
    targetUserId: targetUserId,
    remainingSeconds: remainingSeconds ?? this.remainingSeconds,
  );

  @override
  List<Object?> get props => [ringId, channelId, targetUserId, remainingSeconds];
}

class VoiceRingState extends Equatable {
  const VoiceRingState({
    this.incoming = const [],
    this.outgoing = const [],
    this.notice,
    this.acceptedChannel,
  });

  /// Newest first. Two different people can ask you into two different channels
  /// at once, and each is answered independently, so this is a stack rather than
  /// a single slot.
  final List<IncomingRing> incoming;

  /// Keyed by nothing - a person can have several out at once, into different
  /// channels, from different windows.
  final List<OutgoingRing> outgoing;

  /// One-shot copy for a snackbar: a refusal, or "they declined". Always
  /// assigned as given rather than coalesced, so null means "nothing to show"
  /// and a stale message cannot survive into the next state.
  final String? notice;

  /// A ring this device just accepted, which the UI turns into an ordinary
  /// join. One-shot, for the same reason.
  ///
  /// **Accepting is not joining.** It closes the invitation and hands back the
  /// channel's coordinates; the caller then makes the ordinary join call. There
  /// is deliberately no second join path here.
  final ({String guildId, String channelId, String? channelName})?
  acceptedChannel;

  VoiceRingState copyWith({
    List<IncomingRing>? incoming,
    List<OutgoingRing>? outgoing,
    String? notice,
    ({String guildId, String channelId, String? channelName})? acceptedChannel,
  }) => VoiceRingState(
    incoming: incoming ?? this.incoming,
    outgoing: outgoing ?? this.outgoing,
    notice: notice,
    acceptedChannel: acceptedChannel,
  );

  bool hasOutgoingTo({required String channelId, required String targetUserId}) =>
      outgoing.any(
        (r) => r.channelId == channelId && r.targetUserId == targetUserId,
      );

  @override
  List<Object?> get props => [
    incoming,
    outgoing,
    notice,
    acceptedChannel?.channelId,
  ];
}

/// The ring, end to end.
///
/// Deliberately **not** modelled on [CallCubit]'s phases. A ring holds no media
/// session and no roster slot; there is nothing to connect, nothing to tear
/// down, and nothing for CallKit to report. What it has instead is a stack of
/// invitations with countdowns.
class VoiceRingCubit extends Cubit<VoiceRingState> with SafeEmit<VoiceRingState> {
  VoiceRingCubit({required this.repository, required this.deviceIdService})
    : super(const VoiceRingState()) {
    _sub = repository.events.listen(_handleEvent);
    _connectionSub = repository.connectionStatus.listen(_handleConnectionStatus);
  }

  final VoiceRingRepository repository;
  final DeviceIdService deviceIdService;

  late final StreamSubscription<VoiceRingEvent> _sub;
  late final StreamSubscription<RealtimeConnectionStatus> _connectionSub;
  Timer? _ticker;

  String? get _myDeviceId => deviceIdService.deviceIdOrNull;

  // ── Catch-up ──────────────────────────────────────────────────────────────

  /// The third leg, alongside the realtime event and the push.
  ///
  /// `guild.VoiceRingIncoming` is a live broadcast that is never replayed, and a
  /// push is best-effort by nature. Without this a client that was offline for
  /// ten seconds never finds out it was asked - so it runs at launch and again
  /// on every reconnect.
  Future<void> catchUp() async {
    try {
      final pending = await repository.pending();
      if (isClosed) return;

      // Newest first, which is the order the stack is shown in.
      final rings =
          pending
              .where((r) => r.status == VoiceRingStatus.pending)
              .map(
                (r) => IncomingRing(
                  invitation: VoiceRingInvitationDto(
                    ringId: r.ringId,
                    guildId: r.guildId,
                    channelId: r.channelId,
                    channelName: r.channelName,
                    inviterId: r.inviterId,
                    targetUserId: r.targetUserId,
                    createdAt: r.createdAt,
                    expiresAt: r.expiresAt,
                    expiresInSeconds: r.expiresInSeconds,
                  ),
                  // The read carries the *correct remaining time*, not a fresh
                  // 60 seconds, which is what makes a catch-up honest about an
                  // invitation that is nearly over.
                  remainingSeconds: r.expiresInSeconds,
                ),
              )
              .toList()
            ..sort(
              (a, b) => b.remainingSeconds.compareTo(a.remainingSeconds),
            );

      emitIfOpen(state.copyWith(incoming: rings));
      _syncTicker();
    } catch (_) {
      // Best-effort. The live event and the push are the other two legs.
    }
  }

  void _handleConnectionStatus(RealtimeConnectionStatus status) {
    if (status == RealtimeConnectionStatus.connected) unawaited(catchUp());
  }

  // ── Sending ───────────────────────────────────────────────────────────────

  /// Asks one member into the voice channel this account is sitting in.
  ///
  /// Repeating a ring already out is idempotent server-side and answers the same
  /// ring, so this does not guard against a double press.
  Future<void> sendRing({
    required String guildId,
    required String channelId,
    required String targetUserId,
  }) async {
    try {
      final ring = await repository.ring(
        guildId: guildId,
        channelId: channelId,
        targetUserId: targetUserId,
      );
      _rememberOutgoing(ring);
    } on VoiceRingRefusedException catch (e) {
      // `TargetAlreadyInChannel` is a `409` and not really a refusal - they
      // walked in while the button was being pressed, and the roster will say
      // so. Nothing to tell anybody.
      if (e.reason == VoiceRingRefusal.targetAlreadyInChannel) return;
      emitIfOpen(state.copyWith(notice: e.reason.message));
    } catch (e) {
      // A bare 403 is "you are not in that voice channel", which means the
      // affordance should not have been offered - a bug here, not news for the
      // user.
      debugPrint('VoiceRingCubit.sendRing: $e');
    }
  }

  void _rememberOutgoing(VoiceRingDto ring) {
    if (ring.status != VoiceRingStatus.pending) return;
    if (state.outgoing.any((r) => r.ringId == ring.ringId)) return;

    emitIfOpen(
      state.copyWith(
        outgoing: [
          ...state.outgoing,
          OutgoingRing(
            ringId: ring.ringId,
            channelId: ring.channelId,
            targetUserId: ring.targetUserId,
            remainingSeconds: ring.expiresInSeconds,
          ),
        ],
      ),
    );
    _syncTicker();
  }

  /// The inviter takes it back. Distinct from the target's decline, which is a
  /// different act with different consequences.
  Future<void> cancel(String ringId) async {
    _dropOutgoing(ringId);
    try {
      await repository.cancel(ringId);
    } catch (_) {
      // The card is already down; the server's own resolution will follow.
    }
  }

  // ── Answering ─────────────────────────────────────────────────────────────

  /// Closes the invitation and hands the caller the channel to join.
  ///
  /// Does **not** join. The caller makes the ordinary join call with
  /// [VoiceRingState.acceptedChannel]; if that fails, the invitation is still
  /// correctly closed and the right offer is a plain "Join" pointing at the same
  /// channel, not a second accept.
  Future<void> accept(String ringId) async {
    _dropIncoming(ringId);
    try {
      final ring = await repository.accept(ringId);
      emitIfOpen(
        state.copyWith(
          acceptedChannel: (
            guildId: ring.guildId,
            channelId: ring.channelId,
            channelName: ring.channelName,
          ),
        ),
      );
    } on VoiceRingChannelGoneException {
      emitIfOpen(
        state.copyWith(notice: 'That channel is no longer available.'),
      );
    } on VoiceRingAlreadyResolvedException {
      // The normal multi-device outcome: another of this account's devices got
      // there first, or the deadline passed while this was in flight. Never an
      // error to surface - the card is already down.
    } catch (e) {
      debugPrint('VoiceRingCubit.accept: $e');
    }
  }

  Future<void> decline(String ringId) async {
    // Closed silently. The user knows what they pressed, and confirming it back
    // at them is noise.
    _dropIncoming(ringId);
    try {
      await repository.decline(ringId);
    } on VoiceRingAlreadyResolvedException {
      // As above.
    } catch (e) {
      debugPrint('VoiceRingCubit.decline: $e');
    }
  }

  // ── Events ────────────────────────────────────────────────────────────────

  void _handleEvent(VoiceRingEvent event) {
    switch (event) {
      case VoiceRingIncoming(:final invitation):
        _raiseIncoming(invitation);

      case VoiceRingSent(:final invitation):
        // Not a confirmation of our own request - that was the HTTP response.
        // This is so this account's *other* windows stop offering to send an
        // invitation that is already out.
        _rememberOutgoing(
          VoiceRingDto(
            ringId: invitation.ringId,
            guildId: invitation.guildId,
            channelId: invitation.channelId,
            inviterId: invitation.inviterId,
            targetUserId: invitation.targetUserId,
            expiresInSeconds: invitation.expiresInSeconds,
          ),
        );

      case VoiceRingResolved(:final resolution):
        _resolve(resolution);

      case VoiceRingDismissed(:final dismissal):
        // Addressed to this device alone: another of this account's devices
        // answered. Take the card down and say nothing - the user answered it,
        // they just did it somewhere else.
        _dropIncoming(dismissal.ringId);
    }
  }

  void _raiseIncoming(VoiceRingInvitationDto invitation) {
    // The same person ringing you into a second channel supersedes the first
    // server-side, and the resolution for the older one arrives on its own. This
    // guards the display anyway: never two cards from one face.
    final rest = state.incoming
        .where(
          (r) =>
              r.ringId != invitation.ringId &&
              r.invitation.inviterId != invitation.inviterId,
        )
        .toList();

    emitIfOpen(
      state.copyWith(
        incoming: [
          IncomingRing(
            invitation: invitation,
            remainingSeconds: invitation.expiresInSeconds,
          ),
          ...rest,
        ],
      ),
    );
    _syncTicker();
  }

  void _resolve(VoiceRingResolvedDto resolution) {
    // This device answered it. It already re-rendered when it did, and doing so
    // again would replace a "connecting" state with a resolution notice.
    final mine = _myDeviceId;
    final answeredHere =
        mine != null && resolution.resolvedByDeviceId == mine;

    final notice = answeredHere ? null : _noticeFor(resolution);

    emitIfOpen(
      VoiceRingState(
        incoming: state.incoming
            .where((r) => r.ringId != resolution.ringId)
            .toList(),
        outgoing: state.outgoing
            .where((r) => r.ringId != resolution.ringId)
            .toList(),
        notice: notice,
      ),
    );
    _syncTicker();
  }

  /// What, if anything, to say when a ring ends.
  ///
  /// Most endings are silent by design. The inviter hears about a decline and a
  /// timeout because those are answers; the target hears only about the two
  /// endings that are a statement about the world rather than about a button
  /// somebody pressed.
  String? _noticeFor(VoiceRingResolvedDto resolution) {
    final wasMineToSend = state.outgoing.any((r) => r.ringId == resolution.ringId);

    if (wasMineToSend) {
      return switch (resolution.status) {
        // Quiet, and the invite button stays disabled - re-enabling it only
        // earns a 429.
        VoiceRingStatus.declined => 'They declined.',
        VoiceRingStatus.expired => 'No answer.',
        _ => null,
      };
    }

    return resolution.reason.targetNotice;
  }

  // ── Countdown ─────────────────────────────────────────────────────────────

  /// One timer for every card, rather than one per card.
  ///
  /// The countdown is display only: the server decides expiry against its own
  /// deadline, and a ring that reaches zero here is removed because there is
  /// nothing left to press, not because this client decided it was over. The
  /// authoritative resolution arrives as an event either way.
  void _syncTicker() {
    final needed = state.incoming.isNotEmpty || state.outgoing.isNotEmpty;
    if (!needed) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final incoming = [
      for (final ring in state.incoming)
        if (ring.remainingSeconds > 1)
          ring.copyWith(remainingSeconds: ring.remainingSeconds - 1),
    ];
    final outgoing = [
      for (final ring in state.outgoing)
        if (ring.remainingSeconds > 1)
          ring.copyWith(remainingSeconds: ring.remainingSeconds - 1),
    ];

    emitIfOpen(
      VoiceRingState(incoming: incoming, outgoing: outgoing),
    );
    _syncTicker();
  }

  void _dropIncoming(String ringId) {
    emitIfOpen(
      VoiceRingState(
        incoming: state.incoming.where((r) => r.ringId != ringId).toList(),
        outgoing: state.outgoing,
      ),
    );
    _syncTicker();
  }

  void _dropOutgoing(String ringId) {
    emitIfOpen(
      VoiceRingState(
        incoming: state.incoming,
        outgoing: state.outgoing.where((r) => r.ringId != ringId).toList(),
      ),
    );
    _syncTicker();
  }

  /// Clears a one-shot field once the UI has shown it.
  void acknowledge() {
    if (state.notice == null && state.acceptedChannel == null) return;
    emitIfOpen(
      VoiceRingState(incoming: state.incoming, outgoing: state.outgoing),
    );
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _sub.cancel();
    _connectionSub.cancel();
    return super.close();
  }
}
