import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/mls_service.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../conversations/data/conversation_repository.dart';
import '../../../conversations/data/models/conversation_dto.dart';
import '../../../mls/presentation/screens/conversation_encryption_screen.dart';
import '../../../voice/bloc/call_cubit.dart';
import '../../bloc/message_thread_bloc.dart';
import '../../data/message_api.dart';
import '../../data/message_repository.dart';
import '../widgets/thread_view.dart';

/// Full-screen thread view, pushed *outside* `AppShell` - this is where the
/// back button lives; going back returns to the shell with the server rail
/// still in place, matching Discord mobile's navigation.
///
/// Normally `HomeScreen` (inside the shell) has already primed
/// [ConversationRepository]'s cache by the time this is pushed. But this
/// route also gets reached directly - a cold start restoring straight into
/// a DM (see `RoutePersistence`), or a deep link/push notification - where
/// nothing upstream has fetched the conversation list yet. So this fetches
/// for itself when the cache is empty, and rebuilds once it lands rather
/// than being stuck on the "Conversation" placeholder title (and no leading
/// avatar, since [ThreadView]'s DM avatar reads the same cache) forever.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  StreamSubscription<List<ConversationDto>>? _conversationsSub;

  @override
  void initState() {
    super.initState();
    final repository = getIt<ConversationRepository>();
    final alreadyCached = repository.cached.any(
      (c) => c.id == widget.conversationId,
    );
    if (!alreadyCached) {
      repository.fetch().catchError((Object _) => <ConversationDto>[]);
    }
    _conversationsSub = repository.conversationsStream.listen((_) {
      if (mounted) setState(() {});
    });
    // Catch-up for a call that started before this screen was opened.
    // `conversation.CallStateChanged` keeps it current afterwards, but it is
    // sent once and never replayed, so opening the screen late would otherwise
    // show a plain "call" button for a call already in progress.
    unawaited(
      getIt<CallCubit>().refreshConversationCall(widget.conversationId),
    );
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    super.dispose();
  }

  String _title(String myUserId) {
    final conversation = getIt<ConversationRepository>().cached
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;
    if (conversation == null) return 'Conversation';
    if (conversation.name != null) return conversation.name!;
    final others = conversation.members
        .where((m) => m.userId != myUserId)
        .toList();
    if (others.isEmpty) return 'Just you';
    return others.map((m) => m.cachedUserName).join(', ');
  }

  /// Whether to offer the encryption screen at all. A plaintext DM has nothing
  /// to say there, and an entry point that leads to an empty page is worse than
  /// no entry point.
  bool get _encrypted {
    final conversation = getIt<ConversationRepository>().cached
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;
    return conversation?.encryptionState == ConversationEncryption.encrypted ||
        getIt<MlsService>().hasEverHeldGroup(widget.conversationId);
  }

  List<String> _otherMemberIds(String myUserId) {
    final conversation = getIt<ConversationRepository>().cached
        .where((c) => c.id == widget.conversationId)
        .firstOrNull;
    return conversation?.members
            .where((m) => m.userId != myUserId)
            .map((m) => m.userId)
            .toList() ??
        const [];
  }

  @override
  Widget build(BuildContext context) {
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    final otherMemberIds = _otherMemberIds(myUserId);
    return BlocProvider(
      create: (_) => MessageThreadBloc(
        repository: MessageRepository(
          api: getIt<MessageApi>(),
          realtimeService: getIt(),
          mls: getIt(),
          mlsSync: getIt(),
          conversationId: widget.conversationId,
        ),
        myUserId: myUserId,
        soundService: getIt(),
        privacy: getIt(),
      ),
      child: ThreadView(
        title: _title(myUserId),
        myUserId: myUserId,
        mentionableUserIds: otherMemberIds,
        actions: [
          if (_encrypted)
            IconButton(
              icon: const Icon(Icons.lock_outline),
              tooltip: 'Encryption',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ConversationEncryptionScreen(
                    conversationId: widget.conversationId,
                  ),
                ),
              ),
            ),
          if (otherMemberIds.isNotEmpty)
            BlocBuilder<CallCubit, CallState>(
              bloc: getIt<CallCubit>(),
              builder: (context, callState) {
                final cubit = getIt<CallCubit>();
                final inThisCall =
                    callState.call?.conversationId == widget.conversationId &&
                    callState.phase != CallPhase.idle;
                // A call already running here is joined rather than
                // placed. Nothing else surfaces it to someone the ring
                // never addressed - a member who declined, who left, or
                // who was never invited.
                final ongoing = cubit.ongoingCallIn(widget.conversationId);
                if (!inThisCall &&
                    ongoing != null &&
                    callState.phase == CallPhase.idle) {
                  return TextButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Join'),
                    onPressed: () =>
                        cubit.joinConversationCall(widget.conversationId),
                  );
                }
                return IconButton(
                  icon: Icon(inThisCall ? Icons.call_end : Icons.call),
                  onPressed: inThisCall
                      ? cubit.endCall
                      : callState.phase == CallPhase.idle
                      ? () => cubit.startCall(
                          conversationId: widget.conversationId,
                          participantUserIds: otherMemberIds,
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
