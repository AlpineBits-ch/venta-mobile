import '../../features/conversations/data/conversation_api.dart';
import '../../features/conversations/data/models/conversation_dto.dart';
import '../../features/mls/data/models/mls_dtos.dart';
import 'mls_service.dart';
import 'mls_sync_service.dart';

class AddConversationMemberResult {
  const AddConversationMemberResult({
    required this.conversation,
    required this.unreachableDevices,
  });

  final ConversationDto conversation;

  /// Devices that had no key package left, so they were not admitted to the
  /// group. Their owner is in the conversation but cannot read it until they
  /// next come online and are added - better said than discovered when the
  /// history stays empty.
  final List<UnreachableDeviceDto> unreachableDevices;
}

/// Adding someone to a group conversation.
///
/// Two steps that must happen in this order. **The roster comes first:** a
/// member who cannot yet read sees an empty conversation, which is recoverable
/// and visible to them. The reverse — holding group keys without being a member
/// — would leave them able to decrypt traffic for a conversation the server does
/// not believe they are in.
///
/// The ordering is load-bearing rather than incidental, which is why it has its
/// own test: it is exactly the kind of thing a later refactor would happily
/// swap.
class ConversationMemberService {
  ConversationMemberService({
    required this.api,
    required this.mls,
    required this.sync,
  });

  final ConversationApi api;
  final MlsService mls;
  final MlsSyncService sync;

  Future<AddConversationMemberResult> addMember({
    required String conversationId,
    required String userId,
  }) async {
    final conversation = await api.addMember(
      conversationId: conversationId,
      userId: userId,
    );

    // Plaintext conversation: membership is the whole of it.
    if (mls.knownGeneration(conversationId) == null) {
      return AddConversationMemberResult(
        conversation: conversation,
        unreachableDevices: const [],
      );
    }

    final unreachable = await sync.addMembers(
      contextId: conversationId,
      isChannel: false,
      userIds: [userId],
    );

    return AddConversationMemberResult(
      conversation: conversation,
      unreachableDevices: unreachable,
    );
  }
}
