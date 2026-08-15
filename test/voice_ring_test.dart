import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/device/device_id_service.dart';
import 'package:venta_mobile/core/realtime/realtime_transport.dart';
import 'package:venta_mobile/features/guild_voice/bloc/voice_ring_cubit.dart';
import 'package:venta_mobile/features/guild_voice/data/models/voice_ring_dto.dart';
import 'package:venta_mobile/features/guild_voice/data/voice_ring_api.dart';
import 'package:venta_mobile/features/guild_voice/data/voice_ring_repository.dart';

/// The ring, and the four things about it that are not the DM call ring.
///
/// **Accepting does not join.** It closes the invitation and hands back the
/// channel's coordinates; the client then makes the ordinary join call. There is
/// exactly one join path in this app and the ring does not fork it.
///
/// **A block is not reported as a block.** Every reason somebody cannot be
/// reached comes back as `Unavailable`, deliberately indistinguishable, because
/// naming it would turn the endpoint into a block detector.
///
/// **A `409` is not an error.** It is the ordinary outcome of owning more than
/// one device: whichever answers first wins and the rest are told so.
///
/// **Every ending arrives on one event.** `guild.VoiceRingResolved` carries all
/// six reasons rather than one event name per reason, so a client that meets an
/// unknown reason can fall back on the status instead of silently ceasing to
/// notice that its invitations finish.
class _MockVoiceRingApi extends Mock implements VoiceRingApi {}

class _MockDeviceIdService extends Mock implements DeviceIdService {}

const _ringId = 'ring_9f2c';
const _guildId = 'guild_1';
const _channelId = 'chan_1';
const _myDevice = 'device_mine';

VoiceRingInvitationDto _invitation({
  String ringId = _ringId,
  String inviterId = 'user_them',
  String channelId = _channelId,
  int expiresInSeconds = 60,
}) => VoiceRingInvitationDto(
  ringId: ringId,
  guildId: _guildId,
  channelId: channelId,
  channelName: 'General',
  inviterId: inviterId,
  inviterName: 'Ada',
  targetUserId: 'user_me',
  expiresInSeconds: expiresInSeconds,
  participantUserIds: const ['user_them', 'user_c'],
);

VoiceRingResolvedDto _resolution({
  String ringId = _ringId,
  VoiceRingStatus status = VoiceRingStatus.cancelled,
  VoiceRingReason? reason,
  String? resolvedByDeviceId,
  String inviterId = 'user_them',
}) => VoiceRingResolvedDto(
  ringId: ringId,
  guildId: _guildId,
  channelId: _channelId,
  inviterId: inviterId,
  targetUserId: 'user_me',
  status: status,
  reason: reason,
  resolvedByDeviceId: resolvedByDeviceId,
);

VoiceRingDto _ring({
  String ringId = _ringId,
  VoiceRingStatus status = VoiceRingStatus.pending,
  String targetUserId = 'user_them',
  int expiresInSeconds = 60,
}) => VoiceRingDto(
  ringId: ringId,
  guildId: _guildId,
  channelId: _channelId,
  channelName: 'General',
  inviterId: 'user_me',
  targetUserId: targetUserId,
  status: status,
  expiresInSeconds: expiresInSeconds,
);

void main() {
  late _MockVoiceRingApi api;
  late _MockDeviceIdService devices;
  late StreamController<VoiceRingEvent> events;
  late StreamController<RealtimeConnectionStatus> connection;

  VoiceRingCubit build() {
    final repository = _StubRepository(
      api: api,
      events: events.stream,
      connectionStatus: connection.stream,
    );
    return VoiceRingCubit(repository: repository, deviceIdService: devices);
  }

  setUp(() {
    api = _MockVoiceRingApi();
    devices = _MockDeviceIdService();
    when(() => devices.deviceIdOrNull).thenReturn(_myDevice);
    events = StreamController<VoiceRingEvent>.broadcast();
    connection = StreamController<RealtimeConnectionStatus>.broadcast();
    when(api.pending).thenAnswer((_) async => const []);
  });

  tearDown(() async {
    await events.close();
    await connection.close();
  });

  group('receiving', () {
    test('raises a card for an incoming ring', () async {
      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      expect(cubit.state.incoming, hasLength(1));
      expect(cubit.state.incoming.single.ringId, _ringId);
      // Counted from the server's own remaining seconds, not from a deadline a
      // wrong device clock would misread.
      expect(cubit.state.incoming.single.remainingSeconds, 60);

      await cubit.close();
    });

    /// Two different people can ask you into two different channels at once.
    /// Both are live, both are answered independently, and neither replaces the
    /// other.
    test('two different people both get a card', () async {
      final cubit = build();
      events.add(VoiceRingIncoming(_invitation(ringId: 'r1')));
      events.add(
        VoiceRingIncoming(_invitation(ringId: 'r2', inviterId: 'user_other')),
      );
      await pumpEventQueue();

      expect(cubit.state.incoming, hasLength(2));

      await cubit.close();
    });

    /// The same inviter ringing you into a second channel supersedes the first
    /// server-side. Never two cards from one face.
    test('the same person ringing twice replaces rather than stacks', () async {
      final cubit = build();
      events.add(VoiceRingIncoming(_invitation(ringId: 'r1')));
      events.add(
        VoiceRingIncoming(_invitation(ringId: 'r2', channelId: 'chan_2')),
      );
      await pumpEventQueue();

      expect(cubit.state.incoming, hasLength(1));
      expect(cubit.state.incoming.single.ringId, 'r2');

      await cubit.close();
    });

    /// The catch-up read is the third leg alongside the live event and the
    /// push, neither of which is guaranteed - and it carries the *correct
    /// remaining time*, not a fresh 60 seconds.
    test('the catch-up read finds a ring nobody told this client about', () async {
      when(api.pending).thenAnswer((_) async => [_ring(expiresInSeconds: 14)]);

      final cubit = build();
      await cubit.catchUp();

      expect(cubit.state.incoming, hasLength(1));
      expect(cubit.state.incoming.single.remainingSeconds, 14);

      await cubit.close();
    });

    test('a reconnect re-runs the catch-up read', () async {
      final cubit = build();
      connection.add(RealtimeConnectionStatus.connected);
      await pumpEventQueue();

      verify(api.pending).called(greaterThanOrEqualTo(1));

      await cubit.close();
    });

    test('a failed catch-up costs nothing', () async {
      when(api.pending).thenThrow(Exception('offline'));

      final cubit = build();
      await cubit.catchUp();

      expect(cubit.state.incoming, isEmpty);

      await cubit.close();
    });
  });

  group('answering', () {
    /// The one rule that shapes everything: accept resolves the invitation and
    /// hands over coordinates. The join is a separate, ordinary call.
    test('accepting closes the card and hands over the channel', () async {
      when(
        () => api.accept(_ringId),
      ).thenAnswer((_) async => _ring(status: VoiceRingStatus.accepted));

      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      await cubit.accept(_ringId);

      expect(cubit.state.incoming, isEmpty);
      expect(cubit.state.acceptedChannel?.guildId, _guildId);
      expect(cubit.state.acceptedChannel?.channelId, _channelId);

      await cubit.close();
    });

    /// `410 ChannelGone` - deleted, no longer voice, or access lost while the
    /// ring was out. Take the card down and offer no join button: there is
    /// nothing there to join.
    test('a 410 closes the card and offers nothing to join', () async {
      when(
        () => api.accept(_ringId),
      ).thenThrow(const VoiceRingChannelGoneException());

      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      await cubit.accept(_ringId);

      expect(cubit.state.incoming, isEmpty);
      expect(cubit.state.acceptedChannel, isNull);
      expect(cubit.state.notice, 'That channel is no longer available.');

      await cubit.close();
    });

    /// Never surfaced as an error: it is what happens when the phone answers a
    /// second before the laptop.
    test('a 409 on accept is not an error', () async {
      when(() => api.accept(_ringId)).thenThrow(
        VoiceRingAlreadyResolvedException(
          _ring(status: VoiceRingStatus.declined),
        ),
      );

      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      await cubit.accept(_ringId);

      expect(cubit.state.incoming, isEmpty);
      expect(cubit.state.notice, isNull);
      expect(cubit.state.acceptedChannel, isNull);

      await cubit.close();
    });

    /// Closed silently. The user knows what they pressed, and declining is not
    /// a thing to confirm back at them.
    test('declining closes the card and says nothing', () async {
      when(
        () => api.decline(_ringId),
      ).thenAnswer((_) async => _ring(status: VoiceRingStatus.declined));

      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      await cubit.decline(_ringId);

      expect(cubit.state.incoming, isEmpty);
      expect(cubit.state.notice, isNull);
      verify(() => api.decline(_ringId)).called(1);

      await cubit.close();
    });

    /// Addressed to exactly one device, and it means "you already answered this
    /// somewhere else". Nothing to tear down - a ring holds no media session and
    /// no roster slot, which is why there is no takeover event to pair with it.
    test('a dismissal takes the card down on this device alone', () async {
      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      events.add(
        VoiceRingDismissed(
          const VoiceRingDismissedDto(
            ringId: _ringId,
            deviceId: _myDevice,
            status: VoiceRingStatus.accepted,
          ),
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.incoming, isEmpty);
      expect(cubit.state.notice, isNull);

      await cubit.close();
    });
  });

  group('every termination reason', () {
    /// One event for every ending, so this is one table rather than six
    /// subscriptions. What changes between them is only what, if anything, the
    /// person is told.
    Future<VoiceRingState> resolveIncoming(
      VoiceRingStatus status,
      VoiceRingReason? reason,
    ) async {
      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      events.add(
        VoiceRingResolved(_resolution(status: status, reason: reason)),
      );
      await pumpEventQueue();

      final state = cubit.state;
      await cubit.close();
      return state;
    }

    test('InviterCancelled closes the card silently', () async {
      final state = await resolveIncoming(
        VoiceRingStatus.cancelled,
        VoiceRingReason.inviterCancelled,
      );
      expect(state.incoming, isEmpty);
      expect(state.notice, isNull);
    });

    /// The invitation said "come and join me" and the person is no longer there
    /// for it to be true, which is worth a word - unlike a cancel, which the
    /// inviter chose and the target has no stake in.
    test('InviterLeft closes the card and says why', () async {
      final state = await resolveIncoming(
        VoiceRingStatus.cancelled,
        VoiceRingReason.inviterLeft,
      );
      expect(state.incoming, isEmpty);
      expect(state.notice, 'They left the channel.');
    });

    test('Superseded closes the card silently', () async {
      final state = await resolveIncoming(
        VoiceRingStatus.cancelled,
        VoiceRingReason.superseded,
      );
      expect(state.incoming, isEmpty);
      expect(state.notice, isNull);
    });

    /// Not an accept - the target may never have seen the card - but the
    /// invitation has plainly got what it wanted, and leaving it up would ask
    /// somebody to join a room they are in.
    test('TargetJoined closes the card silently', () async {
      final state = await resolveIncoming(
        VoiceRingStatus.cancelled,
        VoiceRingReason.targetJoined,
      );
      expect(state.incoming, isEmpty);
      expect(state.notice, isNull);
    });

    test('ChannelGone closes the card and says the channel is gone', () async {
      final state = await resolveIncoming(
        VoiceRingStatus.cancelled,
        VoiceRingReason.channelGone,
      );
      expect(state.incoming, isEmpty);
      expect(state.notice, 'That channel is no longer available.');
    });

    test('TimedOut closes the card silently', () async {
      final state = await resolveIncoming(
        VoiceRingStatus.expired,
        VoiceRingReason.timedOut,
      );
      expect(state.incoming, isEmpty);
      expect(state.notice, isNull);
    });

    /// A reason added after this build shipped must still take the card down -
    /// which is exactly why every ending shares one event and one status field.
    test('a reason this build has never heard of still closes the card', () async {
      final state = await resolveIncoming(
        VoiceRingStatus.cancelled,
        VoiceRingReason.unknown,
      );
      expect(state.incoming, isEmpty);
      expect(state.notice, isNull);
    });

    test('an accept resolution closes the card', () async {
      final state = await resolveIncoming(VoiceRingStatus.accepted, null);
      expect(state.incoming, isEmpty);
    });

    /// This device answered it and already re-rendered when it did; re-rendering
    /// would replace a connecting state with a resolution notice.
    test('a resolution this device caused is not re-announced', () async {
      final cubit = build();
      events.add(VoiceRingIncoming(_invitation()));
      await pumpEventQueue();

      events.add(
        VoiceRingResolved(
          _resolution(
            status: VoiceRingStatus.cancelled,
            reason: VoiceRingReason.channelGone,
            resolvedByDeviceId: _myDevice,
          ),
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.incoming, isEmpty);
      expect(cubit.state.notice, isNull);

      await cubit.close();
    });
  });

  group('sending', () {
    test('a sent ring becomes a pending outgoing invitation', () async {
      when(
        () => api.ring(
          guildId: any(named: 'guildId'),
          channelId: any(named: 'channelId'),
          targetUserId: any(named: 'targetUserId'),
        ),
      ).thenAnswer((_) async => _ring());

      final cubit = build();
      await cubit.sendRing(
        guildId: _guildId,
        channelId: _channelId,
        targetUserId: 'user_them',
      );

      expect(cubit.state.outgoing, hasLength(1));
      expect(
        cubit.state.hasOutgoingTo(
          channelId: _channelId,
          targetUserId: 'user_them',
        ),
        isTrue,
      );

      await cubit.close();
    });

    /// Repeating a ring already out is idempotent: the same ring comes back with
    /// no second event and no second push, so the button can be naive and the
    /// state must not grow a duplicate.
    test('ringing the same person twice does not stack', () async {
      when(
        () => api.ring(
          guildId: any(named: 'guildId'),
          channelId: any(named: 'channelId'),
          targetUserId: any(named: 'targetUserId'),
        ),
      ).thenAnswer((_) async => _ring());

      final cubit = build();
      await cubit.sendRing(
        guildId: _guildId,
        channelId: _channelId,
        targetUserId: 'user_them',
      );
      await cubit.sendRing(
        guildId: _guildId,
        channelId: _channelId,
        targetUserId: 'user_them',
      );

      expect(cubit.state.outgoing, hasLength(1));

      await cubit.close();
    });

    /// **The one that must not leak.** A block in either direction comes back as
    /// `Unavailable`, and the copy must not say "blocked" - the server
    /// deliberately does not say which direction it runs in, or whether a block
    /// is what this is at all.
    test('Unavailable never says "blocked"', () async {
      when(
        () => api.ring(
          guildId: any(named: 'guildId'),
          channelId: any(named: 'channelId'),
          targetUserId: any(named: 'targetUserId'),
        ),
      ).thenThrow(
        const VoiceRingRefusedException(
          VoiceRingRefusalDto(reason: VoiceRingRefusal.unavailable),
        ),
      );

      final cubit = build();
      await cubit.sendRing(
        guildId: _guildId,
        channelId: _channelId,
        targetUserId: 'user_them',
      );

      expect(cubit.state.notice, 'You cannot invite this person.');
      expect(cubit.state.notice, isNot(contains('block')));
      expect(cubit.state.notice, isNot(contains('Block')));

      await cubit.close();
    });

    test('TargetCannotJoinChannel says what it is', () async {
      expect(
        VoiceRingRefusal.targetCannotJoinChannel.message,
        'They do not have access to this channel.',
      );
    });

    /// `retryAfterSeconds` can be up to 24 hours. "Later" is kinder than a
    /// multi-hour countdown and just as true, so no copy here quotes a number.
    test('RecentlyDeclined does not present a countdown', () async {
      final message = VoiceRingRefusal.recentlyDeclined.message;
      expect(message, contains('later'));
      expect(RegExp(r'\d').hasMatch(message), isFalse);
    });

    test('the two flooding refusals are worded for whose fault it is', () {
      expect(VoiceRingRefusal.inviterFlooding.message, contains('You have'));
      expect(VoiceRingRefusal.targetSaturated.message, contains('They have'));
    });

    /// They walked in while the button was being pressed. The roster will say
    /// so; there is nothing to tell anybody.
    test('TargetAlreadyInChannel is silent', () async {
      when(
        () => api.ring(
          guildId: any(named: 'guildId'),
          channelId: any(named: 'channelId'),
          targetUserId: any(named: 'targetUserId'),
        ),
      ).thenThrow(
        const VoiceRingRefusedException(
          VoiceRingRefusalDto(reason: VoiceRingRefusal.targetAlreadyInChannel),
        ),
      );

      final cubit = build();
      await cubit.sendRing(
        guildId: _guildId,
        channelId: _channelId,
        targetUserId: 'user_them',
      );

      expect(cubit.state.notice, isNull);
      expect(cubit.state.outgoing, isEmpty);

      await cubit.close();
    });

    test('the inviter hears about a decline and a timeout', () async {
      when(
        () => api.ring(
          guildId: any(named: 'guildId'),
          channelId: any(named: 'channelId'),
          targetUserId: any(named: 'targetUserId'),
        ),
      ).thenAnswer((_) async => _ring());

      final cubit = build();
      await cubit.sendRing(
        guildId: _guildId,
        channelId: _channelId,
        targetUserId: 'user_them',
      );

      events.add(
        VoiceRingResolved(
          _resolution(status: VoiceRingStatus.declined, inviterId: 'user_me'),
        ),
      );
      await pumpEventQueue();

      expect(cubit.state.notice, 'They declined.');
      expect(cubit.state.outgoing, isEmpty);

      await cubit.close();
    });

    test('cancelling takes the pending state down immediately', () async {
      when(
        () => api.ring(
          guildId: any(named: 'guildId'),
          channelId: any(named: 'channelId'),
          targetUserId: any(named: 'targetUserId'),
        ),
      ).thenAnswer((_) async => _ring());
      when(
        () => api.cancel(_ringId),
      ).thenAnswer((_) async => _ring(status: VoiceRingStatus.cancelled));

      final cubit = build();
      await cubit.sendRing(
        guildId: _guildId,
        channelId: _channelId,
        targetUserId: 'user_them',
      );
      await cubit.cancel(_ringId);

      expect(cubit.state.outgoing, isEmpty);
      verify(() => api.cancel(_ringId)).called(1);

      await cubit.close();
    });

    /// `guild.VoiceRingSent` is not a confirmation of our own request - the HTTP
    /// response was that. It exists so this account's *other* windows stop
    /// offering to send an invitation that is already out.
    test('a sent event teaches the other windows about the ring', () async {
      final cubit = build();
      events.add(VoiceRingSent(_invitation()));
      await pumpEventQueue();

      expect(cubit.state.outgoing, hasLength(1));

      await cubit.close();
    });
  });

  group('the wire', () {
    /// Hub payloads arrive PascalCase or camelCase depending on the protocol's
    /// naming policy. A PascalCase payload parses *successfully* into a DTO of
    /// all defaults - a ring with a blank id and `expiresInSeconds: 0`, which
    /// draws itself and immediately expires - so normalising is not cosmetic.
    test('a PascalCase payload is read, not silently defaulted', () {
      final normalised = lowerCamelKeys({
        'RingId': _ringId,
        'GuildId': _guildId,
        'ChannelId': _channelId,
        'ChannelName': 'General',
        'InviterId': 'user_them',
        'TargetUserId': 'user_me',
        'ExpiresInSeconds': 60,
        'ParticipantUserIds': ['user_them'],
      });

      final invitation = VoiceRingInvitationDto.fromJson(normalised);
      expect(invitation.ringId, _ringId);
      expect(invitation.expiresInSeconds, 60);
      expect(invitation.participantUserIds, ['user_them']);
    });

    test('a camelCase payload is left alone', () {
      final invitation = VoiceRingInvitationDto.fromJson(
        lowerCamelKeys({
          'ringId': _ringId,
          'guildId': _guildId,
          'channelId': _channelId,
          'inviterId': 'user_them',
          'targetUserId': 'user_me',
          'expiresInSeconds': 45,
        }),
      );

      expect(invitation.ringId, _ringId);
      expect(invitation.expiresInSeconds, 45);
    });

    test('an unknown status or reason does not throw', () {
      final resolved = VoiceRingResolvedDto.fromJson({
        'ringId': _ringId,
        'guildId': _guildId,
        'channelId': _channelId,
        'inviterId': 'user_them',
        'targetUserId': 'user_me',
        'status': 'Vaporised',
        'reason': 'SomethingNew',
      });

      expect(resolved.status, VoiceRingStatus.unknown);
      expect(resolved.reason, VoiceRingReason.unknown);
    });

    test('an unknown refusal reason does not throw', () {
      final refusal = VoiceRingRefusalDto.fromJson({
        'reason': 'SomethingNew',
        'retryAfterSeconds': 30,
      });

      expect(refusal.reason, VoiceRingRefusal.unknown);
      expect(refusal.retryAfterSeconds, 30);
    });
  });
}

/// A repository whose streams the test drives directly, over a mocked API.
///
/// Cheaper than mocking `RealtimeService` and its watched-event list, and it
/// keeps these tests about the ring rather than about SignalR.
class _StubRepository implements VoiceRingRepository {
  _StubRepository({
    required this.api,
    required Stream<VoiceRingEvent> events,
    required Stream<RealtimeConnectionStatus> connectionStatus,
  }) : _events = events,
       _connectionStatus = connectionStatus;

  @override
  final VoiceRingApi api;
  final Stream<VoiceRingEvent> _events;
  final Stream<RealtimeConnectionStatus> _connectionStatus;

  @override
  Stream<VoiceRingEvent> get events => _events;

  @override
  Stream<RealtimeConnectionStatus> get connectionStatus => _connectionStatus;

  @override
  Future<List<VoiceRingDto>> pending() => api.pending();

  @override
  Future<VoiceRingDto> ring({
    required String guildId,
    required String channelId,
    required String targetUserId,
  }) => api.ring(
    guildId: guildId,
    channelId: channelId,
    targetUserId: targetUserId,
  );

  @override
  Future<VoiceRingDto> accept(String ringId) => api.accept(ringId);

  @override
  Future<VoiceRingDto> decline(String ringId) => api.decline(ringId);

  @override
  Future<VoiceRingDto> cancel(String ringId) => api.cancel(ringId);

  @override
  void dispose() {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
