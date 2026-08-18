import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/bloc/safe_emit.dart';
import '../../../core/device/device_id_service.dart';
import '../../guilds/data/guild_repository.dart';
import '../../guild_voice/bloc/guild_voice_cubit.dart';
import '../../guild_voice/data/guild_voice_repository.dart';
import '../../guild_voice/data/models/voice_state_dto.dart';
import '../data/models/ongoing_call_dto.dart';
import '../data/voice_repository.dart';
import 'call_cubit.dart';

/// A room this client was in when it went away, and can be put back into.
sealed class VoiceResumeOffer extends Equatable {
  const VoiceResumeOffer();
}

class ChannelResumeOffer extends VoiceResumeOffer {
  const ChannelResumeOffer({
    required this.guildId,
    required this.channelId,
    required this.channelName,
    required this.deviceId,
  });

  final String guildId;
  final String channelId;
  final String? channelName;

  /// The device the roster holds the seat for - see
  /// [VoiceResumeCubit.reconnect].
  final String? deviceId;

  @override
  List<Object?> get props => [guildId, channelId, channelName, deviceId];
}

class CallResumeOffer extends VoiceResumeOffer {
  const CallResumeOffer({required this.callId, required this.conversationId});

  final String callId;
  final String conversationId;

  @override
  List<Object?> get props => [callId, conversationId];
}

class VoiceResumeState extends Equatable {
  const VoiceResumeState({this.offer, this.busy = false});

  final VoiceResumeOffer? offer;

  /// A reconnect is in flight, so the banner's buttons stop inviting a second
  /// one.
  final bool busy;

  VoiceResumeState copyWith({
    VoiceResumeOffer? offer,
    bool clearOffer = false,
    bool? busy,
  }) => VoiceResumeState(
    offer: clearOffer ? null : (offer ?? this.offer),
    busy: busy ?? this.busy,
  );

  @override
  List<Object?> get props => [offer, busy];
}

/// "You were in a voice room when this app last went away - do you want to go
/// back?"
///
/// Force-quitting or crashing skips the leave path entirely, and the two room
/// kinds fail differently afterwards. A **guild channel seat outlives the
/// client**: nothing but the server's eviction sweep removes a participant, so
/// the reopened app is still on the roster and everybody else is looking at a
/// ghost until it says otherwise. A **call is hung up as the socket drops**, so
/// there is no stale seat - only, sometimes, a call that carried on without us.
///
/// Which is why declining matters as much as accepting. Dismissing a channel
/// offer sends a real leave: it is the only thing that releases the seat now
/// rather than up to a sweep interval from now, so the banner is the fix for
/// the stale presence rather than a remark about it.
///
/// **Asked once per launch, never on reconnect.** This is a question about what
/// happened while the app was not running. Re-asking it whenever the socket
/// blinks would offer to rejoin a room the user is already sitting in.
class VoiceResumeCubit extends Cubit<VoiceResumeState>
    with SafeEmit<VoiceResumeState> {
  VoiceResumeCubit({
    required this.guildVoiceRepository,
    required this.voiceRepository,
    required this.guildRepository,
    required this.guildVoiceCubit,
    required this.callCubit,
    required this.deviceIdService,
  }) : super(const VoiceResumeState());

  final GuildVoiceRepository guildVoiceRepository;
  final VoiceRepository voiceRepository;
  final GuildRepository guildRepository;
  final GuildVoiceCubit guildVoiceCubit;
  final CallCubit callCubit;
  final DeviceIdService deviceIdService;

  bool _asked = false;

  /// Asks the server where it places this client, once.
  ///
  /// Both reads go out together and neither is allowed to fail the other: they
  /// are answered by different services, so a guild outage must not cost the
  /// call answer or the other way round. Every failure is swallowed to null -
  /// there is no banner to show for a question that could not be asked, and
  /// nothing here is worth a toast.
  ///
  /// The channel wins a tie. Both cannot be true of a well-behaved server, and
  /// if they somehow are, the channel is the one carrying a seat other people
  /// can see.
  Future<void> check() async {
    if (_asked) return;
    _asked = true;

    // Already in a room: joining one before getting round to the banner
    // answers the question by doing.
    if (guildVoiceCubit.state.isInVoice ||
        callCubit.state.phase != CallPhase.idle) {
      return;
    }

    final results = await Future.wait([
      guildVoiceRepository.getVoiceState().then<Object?>(
        (v) => v,
        onError: (Object _) => null,
      ),
      voiceRepository.getActiveCall().then<Object?>(
        (v) => v,
        onError: (Object _) => null,
      ),
    ]);

    final offer = _toOffer(
      results[0] as VoiceStateDto?,
      results[1] as OngoingCallDto?,
    );
    if (offer == null) return;
    emitIfOpen(state.copyWith(offer: offer));
  }

  /// Takes the banner down without touching the server. The two answers below
  /// do that themselves.
  void clear() => emitIfOpen(state.copyWith(clearOffer: true));

  /// Goes back into the room the offer named.
  ///
  /// Through the ordinary authorised path in both cases - [GuildVoiceCubit.join]
  /// and [CallCubit.acceptIncomingCallById] - never by asserting we are still
  /// there. The server refuses to re-admit anybody on their own say-so, and it
  /// is right to: a seat held by somebody since kicked, banned, or denied
  /// Connect is exactly the one this banner would otherwise hand back. A
  /// refusal is reported by the join path itself, which `AppShell` already
  /// surfaces.
  ///
  /// The banner comes down first either way. The offer has been answered; if
  /// the rejoin fails, what the user needs is the error the join path raises,
  /// not a banner still asking.
  ///
  /// **The seat is released before it is taken again.** A join by somebody
  /// already on the roster refreshes their device and nothing else, so every
  /// trace of the session that went away survives it: the media session id,
  /// the track names, the screen shares nobody closed, the original join time
  /// the video cap ranks by, and this user's entry in the room's attention
  /// state. Peers are still subscribed to tracks that no longer exist and are
  /// never told otherwise. Only a leave clears any of it.
  Future<void> reconnect() async {
    final offer = state.offer;
    if (offer == null || state.busy) return;

    emitIfOpen(state.copyWith(busy: true, clearOffer: true));
    try {
      switch (offer) {
        case CallResumeOffer(:final callId):
          await callCubit.acceptIncomingCallById(callId);
        case ChannelResumeOffer():
          await _releaseOwnSeat(offer);
          await _rejoinChannel(offer);
      }
    } catch (e) {
      debugPrint('[Voice] could not rejoin the room this session was in: $e');
    } finally {
      emitIfOpen(state.copyWith(busy: false));
    }
  }

  /// Releases the seat the offer named.
  ///
  /// Only meaningful for a channel: a call was already hung up by the
  /// disconnect that ended the last session, so declining one is nothing but
  /// taking the banner down.
  ///
  /// Fire and forget. The user has said they are not going back, and a failed
  /// leave leaves them exactly where the sweep would have found them anyway -
  /// so there is nothing to report and nothing to retry.
  void dismiss() {
    final offer = state.offer;
    clear();
    if (offer is! ChannelResumeOffer) return;
    guildVoiceRepository
        .leave(offer.guildId, offer.channelId)
        .catchError(
          (Object e) => debugPrint('[Voice] dismissed seat not released: $e'),
        );
  }

  Future<void> _rejoinChannel(ChannelResumeOffer offer) async {
    // The guild is read rather than synthesised from the three fields the
    // offer carries: `join` puts the guild's name on the status bar, and a
    // hand-built stand-in would be a second, quietly diverging idea of what a
    // channel is. Cached first because at launch it usually is, and a cold
    // cache is worth one request rather than a rejoin that silently does
    // nothing.
    var guild = guildRepository.cachedById(offer.guildId);
    if (guild == null) {
      try {
        guild = await guildRepository.fetchGuild(offer.guildId);
      } catch (e) {
        debugPrint('[Voice] could not read the guild to rejoin: $e');
      }
    }

    final channelName =
        offer.channelName ??
        guild?.channels.where((c) => c.id == offer.channelId).firstOrNull?.name;

    await guildVoiceCubit.join(
      guildId: offer.guildId,
      channelId: offer.channelId,
      channelName: channelName ?? '',
      guildName: guild?.name ?? '',
    );
  }

  /// Drops the ghost seat so the rejoin starts from an empty roster entry.
  ///
  /// Only when the roster holds it for this device. A seat under another device
  /// id is this user's phone or second machine, and it is live rather than
  /// stale: leaving on its behalf takes it off the roster with nothing sent to
  /// tell it, where the join transfers it and sends `KickedByOtherDevice`. A
  /// device id we cannot read is treated as somebody else's.
  ///
  /// A failed leave is logged and not retried. It leaves the rejoin exactly
  /// where it was before this ran, which is worth having anyway.
  Future<void> _releaseOwnSeat(ChannelResumeOffer offer) async {
    final ours = deviceIdService.deviceIdOrNull;
    if (offer.deviceId != null && offer.deviceId != ours) return;

    try {
      await guildVoiceRepository.leave(offer.guildId, offer.channelId);
    } catch (e) {
      debugPrint('[Voice] could not release the seat left behind: $e');
    }
  }

  /// Forgets that the question was asked, so the next session asks it again.
  /// Called from `resetSessionScopedCaches()` - a different account is a
  /// different set of rooms.
  void reset() {
    _asked = false;
    emitIfOpen(const VoiceResumeState());
  }
}

/// Picks what to offer from the two answers.
///
/// Split out and given a name so the precedence is one readable decision
/// rather than a nested conditional inside an async body.
@visibleForTesting
VoiceResumeOffer? toResumeOffer(VoiceStateDto? channel, OngoingCallDto? call) =>
    _toOffer(channel, call);

VoiceResumeOffer? _toOffer(VoiceStateDto? channel, OngoingCallDto? call) {
  if (channel != null) {
    return ChannelResumeOffer(
      guildId: channel.guildId,
      channelId: channel.channelId,
      channelName: channel.channelName,
      deviceId: channel.deviceId,
    );
  }
  if (call != null) {
    return CallResumeOffer(
      callId: call.callId,
      conversationId: call.conversationId,
    );
  }
  return null;
}
