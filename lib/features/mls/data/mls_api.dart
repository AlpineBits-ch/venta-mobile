import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'models/mls_dtos.dart';

/// Thrown when the server refuses a commit because the group moved on.
///
/// Recoverable by definition: it means someone else committed first, so the
/// caller discards its staged commit, catches up, and re-issues. [conflict]
/// carries where the group actually is.
class MlsEpochConflictException implements Exception {
  const MlsEpochConflictException(this.conflict);

  final MlsEpochConflictDto conflict;

  @override
  String toString() => 'MlsEpochConflictException(${conflict.reason})';
}

/// Thrown when a toggle is refused - already in the requested state, or still
/// inside the server's 30-second cooldown. [conflict.retryAfterSeconds] is set
/// only in the cooldown case.
class MlsToggleConflictException implements Exception {
  const MlsToggleConflictException(this.conflict);

  final MlsToggleConflictDto conflict;

  @override
  String toString() => 'MlsToggleConflictException(${conflict.reason})';
}

/// Thin HTTP layer over the server's MLS transport. No orchestration lives here
/// - see `MlsSyncService` for the ordering and retry rules that make these calls
/// safe to use.
///
/// Conversations and channels have separate routes because their authorization
/// differs (membership versus channel permissions), but the payloads are
/// identical, so each pair collapses to one method taking `isChannel`.
class MlsApi {
  MlsApi({required this.client});

  final ApiClient client;

  String get _base => '/api/v1/messaging';

  String _contextBase(String contextId, bool isChannel) => isChannel
      ? '$_base/channels/${Uri.encodeComponent(contextId)}/mls'
      : '$_base/conversations/${Uri.encodeComponent(contextId)}/mls';

  // ---------------------------------------------------------------------------
  // Commits
  // ---------------------------------------------------------------------------

  /// Every commit above [sinceEpoch], in epoch order.
  ///
  /// This is the *only* way group state should advance. The realtime push
  /// carries no commit bytes precisely so clients cannot apply them in delivery
  /// order - an MLS client that applies commits out of order is forked off the
  /// group for good.
  Future<List<MlsCommitDto>> getCommits({
    required String contextId,
    required bool isChannel,
    required int sinceEpoch,
    int? generation,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url('${_contextBase(contextId, isChannel)}/commits'),
      queryParameters: {'sinceEpoch': sinceEpoch, 'generation': ?generation},
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MlsCommitDto.fromJson)
        .toList();
  }

  /// Publishes a commit. Throws [MlsEpochConflictException] when the epoch is
  /// not exactly one past the group's, or when the generation has moved on.
  Future<MlsCommitPublishedDto> publishCommit({
    required String contextId,
    required bool isChannel,
    required PublishMlsCommitDto dto,
  }) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        client.url('${_contextBase(contextId, isChannel)}/commits'),
        data: dto.toJson(),
      );
      return MlsCommitPublishedDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _asConflict(e) ?? e;
    }
  }

  // ---------------------------------------------------------------------------
  // Context state
  // ---------------------------------------------------------------------------

  Future<MlsContextStateDto> getState({
    required String contextId,
    required bool isChannel,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('${_contextBase(contextId, isChannel)}/state'),
    );
    return MlsContextStateDto.fromJson(response.data!);
  }

  /// Which devices can read this context, asked after the fact.
  ///
  /// Reports, never repairs: the server holds no group keys and cannot add a
  /// device to a group. It is the step before the repair, where until now
  /// nobody knew there was anything to ask for.
  ///
  /// Conversation needs membership, channel needs ViewChannel - the same
  /// authorization as `getState` either side.
  Future<MlsCoverageDto> getCoverage({
    required String contextId,
    required bool isChannel,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('${_contextBase(contextId, isChannel)}/coverage'),
    );
    return MlsCoverageDto.fromJson(response.data!);
  }

  /// Turns encryption on for a channel. Requires ManageChannel server-side.
  ///
  /// `X-Device-Id` rides along from `DeviceIdInterceptor`, which stamps every
  /// request through [ApiClient]. The server reads it to record which device
  /// built the group; without it coverage can say nothing about this account's
  /// own hardware, on exactly the path - re-keying - where the account's other
  /// devices are most likely to fall out.
  Future<MlsToggleResultDto> enableChannelEncryption({
    required String channelId,
    required EnableMlsDto dto,
  }) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        client.url('${_contextBase(channelId, true)}/enable'),
        data: dto.toJson(),
      );
      return MlsToggleResultDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _asConflict(e) ?? e;
    }
  }

  /// Turns encryption off for a channel. Nothing is decrypted - the response
  /// names the terminated generation so the UI can say which stretch of history
  /// stays readable only on devices that already hold its keys.
  Future<MlsToggleResultDto> disableChannelEncryption(String channelId) async {
    try {
      final response = await client.dio.post<Map<String, dynamic>>(
        client.url('${_contextBase(channelId, true)}/disable'),
      );
      return MlsToggleResultDto.fromJson(response.data!);
    } on DioException catch (e) {
      throw _asConflict(e) ?? e;
    }
  }

  // ---------------------------------------------------------------------------
  // Welcomes
  // ---------------------------------------------------------------------------

  /// Welcomes waiting for *this* device, across every context.
  ///
  /// [deviceId] is what makes the read non-destructive. Omitting it selects the
  /// legacy contract, where the server consumes on read - which loses the
  /// single-use init key whenever the join afterwards fails, locking this device
  /// out of that context permanently.
  Future<List<PendingWelcomeDto>> getPendingWelcomes(String deviceId) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url('$_base/conversations/welcomes'),
      queryParameters: {'deviceId': deviceId},
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PendingWelcomeDto.fromJson)
        .toList();
  }

  /// Marks Welcomes consumed - only after the join actually succeeded.
  ///
  /// [deviceId] is required by contract §E6. The ack used to be scoped by user
  /// alone, so one device could consume another's Welcome; the server now scopes
  /// by `(UserId, DeviceId)` and answers 400 rather than silently acking nothing
  /// when it can determine neither this field nor `X-Device-Id`.
  Future<AckWelcomesResultDto> ackWelcomes(
    List<String> welcomeIds, {
    required String deviceId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/conversations/welcomes/ack'),
      data: {'welcomeIds': welcomeIds, 'deviceId': deviceId},
    );
    return AckWelcomesResultDto.fromJson(response.data!);
  }

  // ---------------------------------------------------------------------------
  // Key packages
  // ---------------------------------------------------------------------------

  /// Consumes one key package per device of each listed user, to add them to a
  /// group. Server-side this is gated on being friends with all of them.
  Future<ConsumeTokensResultDto> consumeTokensForUsers(
    List<String> userIds,
  ) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/conversations/consume-tokens'),
      data: {'userIds': userIds},
    );
    return ConsumeTokensResultDto.fromJson(response.data!);
  }

  // ---------------------------------------------------------------------------
  // Join requests
  //
  // Conversations as well as channels, per contract §B. The routes used to be
  // channel-only on the theory that a conversation's roster is fixed at creation
  // and everyone in it was welcomed then - but a group member is a *device*, and
  // a device registered after the conversation existed was never welcomed to
  // anything. It had no way in and nobody could give it one, which is root cause
  // R2 of the "my friend texts me and I can't read it" report.
  //
  // The DTOs are identical either side; only the authorization differs
  // (conversation membership versus ViewChannel), so this is the same
  // `_contextBase` split as everywhere else.
  // ---------------------------------------------------------------------------

  String _joinRequestBase(String contextId, bool isChannel) =>
      '${_contextBase(contextId, isChannel)}/join-requests';

  /// Asks to be let into an encrypted context.
  ///
  /// [keyPackage] travels with the request so reviewers approve exact bytes.
  /// Letting the committer pull a key package separately would leave a window in
  /// which the server could substitute one, and the review would guarantee
  /// nothing.
  Future<MlsJoinRequestDto> requestAccess({
    required String contextId,
    required bool isChannel,
    required String keyPackage,
    required String deviceId,
    required String signatureKeyFingerprint,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url(_joinRequestBase(contextId, isChannel)),
      data: {
        'keyPackage': keyPackage,
        'deviceId': deviceId,
        'signatureKeyFingerprint': signatureKeyFingerprint,
      },
    );
    return MlsJoinRequestDto.fromJson(response.data!);
  }

  /// The review queue for a context. Any member who can see it may read the
  /// queue, because any member may vouch.
  Future<List<MlsJoinRequestDto>> listJoinRequests({
    required String contextId,
    required bool isChannel,
  }) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url(_joinRequestBase(contextId, isChannel)),
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MlsJoinRequestDto.fromJson)
        .toList();
  }

  /// Vouches for a request. The response carries the key package to add only
  /// once this approval completed the threshold.
  Future<MlsJoinRequestApprovalResultDto> approveJoinRequest({
    required String contextId,
    required bool isChannel,
    required String requestId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url(
        '${_joinRequestBase(contextId, isChannel)}/$requestId/approve',
      ),
    );
    return MlsJoinRequestApprovalResultDto.fromJson(response.data!);
  }

  Future<void> denyJoinRequest({
    required String contextId,
    required bool isChannel,
    required String requestId,
  }) async {
    await client.dio.post<void>(
      client.url('${_joinRequestBase(contextId, isChannel)}/$requestId/deny'),
    );
  }

  /// Withdraws your own request.
  Future<void> cancelJoinRequest({
    required String contextId,
    required bool isChannel,
    required String requestId,
  }) async {
    await client.dio.delete<void>(
      client.url('${_joinRequestBase(contextId, isChannel)}/$requestId'),
    );
  }

  // ---------------------------------------------------------------------------
  // Admission challenge and proof (contract §G.1)
  //
  // The server relays these and can verify neither: the proof is a MAC under a
  // key derived from the account master key, which the server holds only in
  // wrapped form. That is the whole reason `TrustedSignIn` admits a device
  // automatically without becoming "trust the server" - a server that adds a
  // device to your account still cannot get it into any group.
  // ---------------------------------------------------------------------------

  /// Posted by an **existing** device of the same account: 32 random bytes the
  /// joining device must MAC.
  Future<MlsAdmissionChallengeDto> issueChallenge({
    required String contextId,
    required bool isChannel,
    required String requestId,
    required String challenge,
    int expiresInSeconds = 900,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url(
        '${_joinRequestBase(contextId, isChannel)}/$requestId/challenge',
      ),
      data: {'challenge': challenge, 'expiresInSeconds': expiresInSeconds},
    );
    return MlsAdmissionChallengeDto.fromJson(response.data!);
  }

  /// Read by the **joining** device. Null while nobody has issued one yet, which
  /// is the normal state until one of the account's other devices comes online.
  Future<MlsAdmissionChallengeDto?> fetchChallenge({
    required String contextId,
    required bool isChannel,
    required String requestId,
  }) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url(
          '${_joinRequestBase(contextId, isChannel)}/$requestId/challenge',
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return MlsAdmissionChallengeDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> submitProof({
    required String contextId,
    required bool isChannel,
    required String requestId,
    required String challengeId,
    required String proof,
  }) async {
    await client.dio.post<void>(
      client.url('${_joinRequestBase(contextId, isChannel)}/$requestId/proof'),
      data: {'challengeId': challengeId, 'proof': proof},
    );
  }

  /// Read by the **admitting** device once the joiner has answered.
  Future<MlsAdmissionProofDto?> fetchProof({
    required String contextId,
    required bool isChannel,
    required String requestId,
  }) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url(
          '${_joinRequestBase(contextId, isChannel)}/$requestId/proof',
        ),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return MlsAdmissionProofDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Both 409 shapes come back on the same status code and are told apart by
  /// their fields: an epoch conflict names the epochs it rejected, a toggle
  /// conflict names the context. Guessing wrong would turn a "wait 30 seconds"
  /// into a retry loop.
  Exception? _asConflict(DioException e) {
    if (e.response?.statusCode != 409) return null;
    final data = e.response?.data;
    if (data is! Map) return null;
    final json = Map<String, dynamic>.from(data);
    if (json.containsKey('currentEpoch') || json.containsKey('rejectedEpoch')) {
      return MlsEpochConflictException(MlsEpochConflictDto.fromJson(json));
    }
    return MlsToggleConflictException(MlsToggleConflictDto.fromJson(json));
  }
}
