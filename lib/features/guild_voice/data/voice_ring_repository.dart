import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../../core/realtime/realtime_transport.dart';
import 'models/voice_ring_dto.dart';
import 'voice_ring_api.dart';

/// Everything that can happen to a ring, as one sealed hierarchy the cubit can
/// switch on exhaustively.
sealed class VoiceRingEvent {
  const VoiceRingEvent();
}

/// Somebody is asking this account into a channel. Every device gets it.
class VoiceRingIncoming extends VoiceRingEvent {
  const VoiceRingIncoming(this.invitation);
  final VoiceRingInvitationDto invitation;
}

/// A ring this account sent went out. Not a confirmation of the request - that
/// arrived as the HTTP response - but the signal that this account's **other**
/// windows and devices should stop offering to send one that is already out.
class VoiceRingSent extends VoiceRingEvent {
  const VoiceRingSent(this.invitation);
  final VoiceRingInvitationDto invitation;
}

/// A ring ended, whichever way. Delivered to the target and the inviter alike.
class VoiceRingResolved extends VoiceRingEvent {
  const VoiceRingResolved(this.resolution);
  final VoiceRingResolvedDto resolution;
}

/// This device specifically should take the card down, because another of this
/// account's devices answered.
class VoiceRingDismissed extends VoiceRingEvent {
  const VoiceRingDismissed(this.dismissal);
  final VoiceRingDismissedDto dismissal;
}

/// The realtime and REST surface behind the ring, in the shape the rest of this
/// feature's repositories use: a filtered subscription in, a sealed event stream
/// out, and no state of its own.
class VoiceRingRepository {
  VoiceRingRepository({
    required this.api,
    required RealtimeService realtimeService,
  }) : _realtimeService = realtimeService {
    // A set rather than a prefix. `guild.voice.*` is reserved for voice *room
    // state*, which every client must be able to rebuild from a version number
    // after missing an event; a ring is not room state - its audience is
    // somebody who is not in the room and may never be - so it sits under the
    // plain `guild.` prefix alongside `guild.MemberJoined`, and a prefix filter
    // here would either miss it or swallow half the guild's traffic.
    _realtimeSub = realtimeService.events
        .where((e) => _ringEvents.contains(e.name))
        .listen(_handleRealtimeEvent);
  }

  static const incomingEvent = 'guild.VoiceRingIncoming';
  static const sentEvent = 'guild.VoiceRingSent';
  static const resolvedEvent = 'guild.VoiceRingResolved';
  static const dismissedEvent = 'guild.VoiceRingDismissed';

  static const _ringEvents = {
    incomingEvent,
    sentEvent,
    resolvedEvent,
    dismissedEvent,
  };

  final VoiceRingApi api;
  final RealtimeService _realtimeService;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  final _eventsController = StreamController<VoiceRingEvent>.broadcast();
  Stream<VoiceRingEvent> get events => _eventsController.stream;

  /// A reconnect means events broadcast during the gap were dropped - SignalR
  /// queues nothing - which is exactly when the catch-up read has to run.
  Stream<RealtimeConnectionStatus> get connectionStatus =>
      _realtimeService.connectionStatus;

  Future<List<VoiceRingDto>> pending() => api.pending();

  Future<VoiceRingDto> ring({
    required String guildId,
    required String channelId,
    required String targetUserId,
  }) => api.ring(
    guildId: guildId,
    channelId: channelId,
    targetUserId: targetUserId,
  );

  /// The quiet form. No ring, so nothing here can ever come back through
  /// [events] - a message invitation raises no `guild.VoiceRing*` at all, and
  /// the response is the only thing that ever reports it.
  Future<VoiceInviteSentDto> invite({
    required String guildId,
    required String channelId,
    required String targetUserId,
  }) => api.invite(
    guildId: guildId,
    channelId: channelId,
    targetUserId: targetUserId,
  );

  Future<VoiceRingDto> accept(String ringId) => api.accept(ringId);

  Future<VoiceRingDto> decline(String ringId) => api.decline(ringId);

  Future<VoiceRingDto> cancel(String ringId) => api.cancel(ringId);

  void _handleRealtimeEvent(RealtimeEvent event) {
    final payload = lowerCamelKeys(event.objectPayload);
    if (payload.isEmpty) return;

    try {
      switch (event.name) {
        case incomingEvent:
          _eventsController.add(
            VoiceRingIncoming(VoiceRingInvitationDto.fromJson(payload)),
          );
        case sentEvent:
          _eventsController.add(
            VoiceRingSent(VoiceRingInvitationDto.fromJson(payload)),
          );
        case resolvedEvent:
          _eventsController.add(
            VoiceRingResolved(VoiceRingResolvedDto.fromJson(payload)),
          );
        case dismissedEvent:
          _eventsController.add(
            VoiceRingDismissed(VoiceRingDismissedDto.fromJson(payload)),
          );
      }
    } catch (e) {
      // A payload that will not parse costs one invitation, not the stream.
      debugPrint('${event.name} payload not understood: $e');
    }
  }

  void dispose() {
    _realtimeSub.cancel();
    _eventsController.close();
  }
}

/// Hub payloads arrive PascalCase or camelCase depending on the protocol's
/// naming policy, which is a backend detail this client must not bet on - see
/// `RealtimeEvent.field` for the same problem on the id-carrying events.
///
/// Normalising before `fromJson` matters more here than a null id would: a
/// PascalCase payload parses *successfully* into a DTO of all defaults, and a
/// ring with a blank id and `expiresInSeconds: 0` is an invitation that draws
/// itself and immediately expires.
@visibleForTesting
Map<String, dynamic> lowerCamelKeys(Map<String, dynamic> payload) =>
    _lowerCamelKeys(payload) as Map<String, dynamic>;

Object? _lowerCamelKeys(Object? value) {
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        _lowerFirst('${entry.key}'): _lowerCamelKeys(entry.value),
    };
  }
  if (value is List) return value.map(_lowerCamelKeys).toList();
  return value;
}

String _lowerFirst(String value) =>
    value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);
