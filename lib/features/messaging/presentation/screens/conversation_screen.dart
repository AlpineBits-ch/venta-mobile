import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../conversations/data/conversation_repository.dart';
import '../../../voice/bloc/call_cubit.dart';
import '../../bloc/message_thread_bloc.dart';
import '../../data/message_api.dart';
import '../../data/message_repository.dart';
import '../widgets/thread_view.dart';

/// Full-screen thread view, pushed *outside* `AppShell` — this is where the
/// back button lives; going back returns to the shell with the server rail
/// still in place, matching Discord mobile's navigation.
class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key, required this.conversationId});

  final String conversationId;

  String _title(String myUserId) {
    final conversation = getIt<ConversationRepository>().cached
        .where((c) => c.id == conversationId)
        .firstOrNull;
    if (conversation == null) return 'Conversation';
    if (conversation.name != null) return conversation.name!;
    final others = conversation.members
        .where((m) => m.userId != myUserId)
        .toList();
    if (others.isEmpty) return 'Just you';
    return others.map((m) => m.cachedUserName).join(', ');
  }

  List<String> _otherMemberIds(String myUserId) {
    final conversation = getIt<ConversationRepository>().cached
        .where((c) => c.id == conversationId)
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
          conversationId: conversationId,
        ),
        myUserId: myUserId,
      ),
      child: ThreadView(
        title: _title(myUserId),
        myUserId: myUserId,
        actions: otherMemberIds.isEmpty
            ? null
            : [
                BlocBuilder<CallCubit, CallState>(
                  bloc: getIt<CallCubit>(),
                  builder: (context, callState) {
                    final inThisCall =
                        callState.call?.conversationId == conversationId &&
                        callState.phase != CallPhase.idle;
                    return IconButton(
                      icon: Icon(inThisCall ? Icons.call_end : Icons.call),
                      onPressed: inThisCall
                          ? getIt<CallCubit>().endCall
                          : callState.phase == CallPhase.idle
                          ? () => getIt<CallCubit>().startCall(
                              conversationId: conversationId,
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
