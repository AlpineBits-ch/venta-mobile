import '../../../core/network/api_client.dart';
import 'models/conversation_dto.dart';

class ConversationApi {
  ConversationApi({required this.client});

  final ApiClient client;

  /// Creates a conversation.
  ///
  /// The encrypted variant is not a flag on an otherwise identical call: the
  /// caller has to have built the MLS group locally first and consumed a key
  /// package for every invitee device, because [deviceWelcomes] is what admits
  /// those devices to it. The server refuses to create an encrypted conversation
  /// where any member has no Welcome - a member who can never read the
  /// conversation is worse than a failed creation.
  ///
  /// See `ConversationEncryptionService.createEncrypted`, which is the only
  /// thing that should be passing the MLS arguments here.
  Future<ConversationDto> create({
    String? name,
    required List<String> memberUserIds,
    bool encrypted = false,
    List<Map<String, Object?>> deviceWelcomes = const [],
    String? mlsGroupId,
    int? mlsEpoch,
    String? mlsGroupInfo,
    bool allowPartialDeviceCoverage = false,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/messaging/conversations'),
      // The server validates reachability per *device* and refuses outright
      // when a member device has no key package left, unless this says the
      // human was shown the list and accepted it (contract §E7). Sending it
      // unconditionally would be exactly the silent partial coverage the check
      // exists to prevent, so it comes from a decision and never from a
      // default.
      queryParameters: allowPartialDeviceCoverage
          ? const {'allowPartialDeviceCoverage': 'true'}
          : null,
      data: {
        'name': name,
        'members': memberUserIds.map((id) => {'userId': id}).toList(),
        'encryption': encrypted ? 'Encrypted' : 'Plain',
        'deviceWelcomes': deviceWelcomes,
        'mlsGroupId': ?mlsGroupId,
        'mlsEpoch': ?mlsEpoch,
        'mlsGroupInfo': ?mlsGroupInfo,
      },
    );
    return ConversationDto.fromJson(response.data!);
  }

  /// Adds someone to an existing group conversation.
  ///
  /// Roster only. For an encrypted conversation their devices still have to be
  /// admitted to the MLS group, which only a member's client can do - see
  /// `ConversationMemberService.addMember` for the pairing and the order it has
  /// to happen in.
  ///
  /// Refused server-side on a two-person DM: growing a 1:1 into a group silently
  /// changes what the other person thought they were in.
  Future<ConversationDto> addMember({
    required String conversationId,
    required String userId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      client.url('/api/v1/messaging/conversations/$conversationId/members'),
      data: {'userId': userId},
    );
    return ConversationDto.fromJson(response.data!);
  }

  Future<List<ConversationDto>> list({int offset = 0, int limit = 50}) async {
    final response = await client.dio.get<List<dynamic>>(
      client.url('/api/v1/messaging/conversations?offset=$offset&limit=$limit'),
    );
    return response.data!
        .map((json) => ConversationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<ConversationDto> getById(String id) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      client.url('/api/v1/messaging/conversations/$id'),
    );
    return ConversationDto.fromJson(response.data!);
  }

  Future<void> delete(String id) async {
    await client.dio.delete<void>(
      client.url('/api/v1/messaging/conversations/$id'),
    );
  }
}
