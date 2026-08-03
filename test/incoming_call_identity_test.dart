import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/push/call_kit_service.dart';
import 'package:venta_mobile/features/voice/data/models/call_dto.dart';

/// Naming the caller on the native incoming-call screen.
///
/// The screen came up nameless or - worse - labelled with the recipient's own
/// name, intermittently and only on iOS, because who the caller *is* was
/// inferred from the call roster instead of being told. `CallDto.creatorId` now
/// carries it (`Call.CreatorId`, which the backend has always serialised and
/// this DTO simply dropped); the inference survives only as a fallback for a
/// call that reached the device before the field existed.
void main() {
  const me = 'user-me';
  const caller = 'user-caller';
  const other = 'user-third';

  CallDto call({String? creatorId, required List<String> participants}) =>
      CallDto(
        id: 'call-1',
        conversationId: 'conv-1',
        creatorId: creatorId,
        participants: [
          for (final id in participants) CallParticipantDto(userId: id),
        ],
      );

  group('callerUserIdOf', () {
    test('prefers creatorId over anything on the roster', () {
      final resolved = callerUserIdOf(
        call(creatorId: caller, participants: [me, caller]),
        me,
      );

      expect(resolved, caller);
    });

    test('picks the caller out of a group call, not an arbitrary invitee', () {
      // The roster order here is exactly what VoiceController.CallAsync builds:
      // the invitees first, the caller appended last. "First participant that
      // isn't me" lands on the other *invitee* and rings with their name on it.
      final resolved = callerUserIdOf(
        call(creatorId: caller, participants: [me, other, caller]),
        me,
      );

      expect(resolved, caller);
    });

    test('falls back to the other participant in a 1:1 call', () {
      final resolved = callerUserIdOf(call(participants: [me, caller]), me);

      expect(resolved, caller);
    });

    test('resolves nobody rather than this user when auth is not loaded', () {
      // A cold start from a VoIP push runs before the session is restored. Every
      // participant differs from null, so the old fallback returned the first
      // one - which for an incoming call is the recipient, so the ring came up
      // labelled with the user's own name.
      final resolved = callerUserIdOf(call(participants: [me, caller]), null);

      expect(resolved, isEmpty);
    });

    test('resolves nobody rather than this user when the roster is only me', () {
      final resolved = callerUserIdOf(call(participants: [me]), me);

      expect(resolved, isEmpty);
    });
  });
}
