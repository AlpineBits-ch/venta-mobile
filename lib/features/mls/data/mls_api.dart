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

  /// Turns encryption on for a channel. Requires ManageChannel server-side.
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
  Future<AckWelcomesResultDto> ackWelcomes(List<String> welcomeIds) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('$_base/conversations/welcomes/ack'),
      data: {'welcomeIds': welcomeIds},
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
  // Channels only. A conversation's roster is fixed at creation and its members
  // were all welcomed then, so there is nobody to admit later - the server
  // exposes these routes on channels alone.
  // ---------------------------------------------------------------------------

  String _joinRequestBase(String channelId) =>
      '$_base/channels/${Uri.encodeComponent(channelId)}/mls/join-requests';

  /// Asks to be let into an encrypted channel.
  ///
  /// [keyPackage] travels with the request so reviewers approve exact bytes.
  /// Letting the committer pull a key package separately would leave a window in
  /// which the server could substitute one, and the review would guarantee
  /// nothing.
  Future<MlsJoinRequestDto> requestAccess({
    required String channelId,
    required String keyPackage,
    required String deviceId,
    required String signatureKeyFingerprint,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url(_joinRequestBase(channelId)),
      data: {
        'keyPackage': keyPackage,
        'deviceId': deviceId,
        'signatureKeyFingerprint': signatureKeyFingerprint,
      },
    );
    return MlsJoinRequestDto.fromJson(response.data!);
  }

  /// The review queue for a channel. Any member who can see the channel may read
  /// it, because any member may vouch.
  Future<List<MlsJoinRequestDto>> listJoinRequests(String channelId) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url(_joinRequestBase(channelId)),
    );
    return (response.data ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MlsJoinRequestDto.fromJson)
        .toList();
  }

  /// Vouches for a request. The response carries the key package to add only
  /// once this approval completed the threshold.
  Future<MlsJoinRequestApprovalResultDto> approveJoinRequest({
    required String channelId,
    required String requestId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('${_joinRequestBase(channelId)}/$requestId/approve'),
    );
    return MlsJoinRequestApprovalResultDto.fromJson(response.data!);
  }

  Future<void> denyJoinRequest({
    required String channelId,
    required String requestId,
  }) async {
    await client.dio.post<void>(
      client.url('${_joinRequestBase(channelId)}/$requestId/deny'),
    );
  }

  /// Withdraws your own request.
  Future<void> cancelJoinRequest({
    required String channelId,
    required String requestId,
  }) async {
    await client.dio.delete<void>(
      client.url('${_joinRequestBase(channelId)}/$requestId'),
    );
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
