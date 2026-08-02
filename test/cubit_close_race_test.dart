import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/features/friends/data/models/relationship_model.dart';
import 'package:venta_mobile/features/friends/data/relationship_repository.dart';
import 'package:venta_mobile/features/profile/bloc/user_profile_cubit.dart';
import 'package:venta_mobile/features/profile/data/models/profile_dto.dart';
import 'package:venta_mobile/features/profile/data/profile_repository.dart';

/// What these cover: `StateError: Cannot emit new states after calling close`,
/// reported from a real handset via Sentry at `user_profile_cubit.dart:89`.
///
/// The shape is generic and the repo was full of it: a cubit is constructed by a
/// screen, kicks off an async load, and the human pops the screen before the
/// load returns. `close()` runs, the awaited call completes a moment later, and
/// the `emit` after the `await` throws.
///
/// Line 89 was the **catch** block, which is the detail that makes this worth a
/// test rather than a one-line guard. The first `emit` throwing inside `try`
/// lands in `catch`, which emits again - so a guard on the success path alone
/// converts a crash on the happy path into the identical crash on the error
/// path, and the Sentry issue does not move.
///
/// Both paths are asserted here for exactly that reason.
class _MockProfiles extends Mock implements ProfileRepository {}

class _MockRelationships extends Mock implements RelationshipRepository {}

const _userId = 'user_1';

ProfileDto _profile() =>
    const ProfileDto(id: 'profile_1', userId: _userId, userName: 'someone');

void main() {
  late _MockProfiles profiles;
  late _MockRelationships relationships;

  setUp(() {
    profiles = _MockProfiles();
    relationships = _MockRelationships();
    when(() => relationships.cached).thenReturn(const <RelationshipModel>[]);
    when(() => relationships.fetch()).thenAnswer((_) async => const []);
  });

  UserProfileCubit build() => UserProfileCubit(
    userId: _userId,
    profileRepository: profiles,
    relationshipRepository: relationships,
  );

  group('a cubit closed while its load is in flight', () {
    test('does not throw when the load then succeeds', () async {
      final inFlight = Completer<ProfileDto>();
      when(
        () => profiles.getByUserId(_userId),
      ).thenAnswer((_) => inFlight.future);

      final cubit = build();
      // The screen is popped: `close()` wins the race against the repository.
      await cubit.close();

      inFlight.complete(_profile());
      // Long enough for `_load` to resume past both awaits and reach its emit.
      await pumpEventQueue();

      expect(cubit.isClosed, isTrue);
    });

    test('does not throw when the load then fails', () async {
      final inFlight = Completer<ProfileDto>();
      when(
        () => profiles.getByUserId(_userId),
      ).thenAnswer((_) => inFlight.future);

      final cubit = build();
      await cubit.close();

      inFlight.completeError(Exception('the request was cancelled'));
      await pumpEventQueue();

      expect(cubit.isClosed, isTrue);
    });

    test(
      'does not throw when the relationship fetch is the slow half',
      () async {
        final inFlight = Completer<List<RelationshipModel>>();
        when(
          () => profiles.getByUserId(_userId),
        ).thenAnswer((_) async => _profile());
        when(() => relationships.fetch()).thenAnswer((_) => inFlight.future);

        final cubit = build();
        // One turn so `_load` gets past `getByUserId` and is parked on `fetch`.
        await pumpEventQueue();
        await cubit.close();

        inFlight.complete(const []);
        await pumpEventQueue();

        expect(cubit.isClosed, isTrue);
      },
    );
  });

  group('a cubit closed while an action is in flight', () {
    setUp(() {
      when(
        () => profiles.getByUserId(_userId),
      ).thenAnswer((_) async => _profile());
    });

    test('does not throw when the action then fails', () async {
      final inFlight = Completer<void>();
      when(
        () => relationships.addFriend(any()),
      ).thenAnswer((_) => inFlight.future);

      final cubit = build();
      await pumpEventQueue();
      unawaited(cubit.sendFriendRequest());
      await cubit.close();

      inFlight.completeError(Exception('the request was cancelled'));
      await pumpEventQueue();

      expect(cubit.isClosed, isTrue);
    });
  });
}
