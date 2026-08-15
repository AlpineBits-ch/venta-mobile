import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../bloc/voice_ring_cubit.dart';

/// "Ask somebody to join you in here."
///
/// Opened only from a voice channel this account is **sitting in**. That is a
/// deliberate limitation rather than a missing feature: the invitation's entire
/// claim is "I am in here", so inviting from a channel you are merely looking at
/// would be a claim about somebody else's room. The endpoint refuses it with a
/// bare `403`, and the affordance should not have been offered at all.
///
/// The target is picked by user id from the guild's own member list - there is
/// no invite-by-mention and no invite-from-DM.
Future<void> showVoiceRingInviteSheet(
  BuildContext context, {
  required String guildId,
  required String channelId,
  Set<String> alreadyInChannel = const {},
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _VoiceRingInviteSheet(
    guildId: guildId,
    channelId: channelId,
    alreadyInChannel: alreadyInChannel,
  ),
);

class _VoiceRingInviteSheet extends StatefulWidget {
  const _VoiceRingInviteSheet({
    required this.guildId,
    required this.channelId,
    required this.alreadyInChannel,
  });

  final String guildId;
  final String channelId;

  /// Anybody the roster already shows in the channel. Hidden rather than shown
  /// and refused: ringing them answers `409 TargetAlreadyInChannel`, which is
  /// nothing to tell the user about but also nothing to make them discover.
  final Set<String> alreadyInChannel;

  @override
  State<_VoiceRingInviteSheet> createState() => _VoiceRingInviteSheetState();
}

class _VoiceRingInviteSheetState extends State<_VoiceRingInviteSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<GuildMemberDto>? _results;

  /// Who has been rung from this sheet, so the row can say so.
  ///
  /// Repeating a ring already out is idempotent server-side - it answers the
  /// same ring with no second event and no second push - so this is display
  /// only and never a guard.
  final _rung = <String>{};

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    try {
      final repository = getIt<GuildRepository>();
      final results = query.isEmpty
          ? await repository.getMembers(widget.guildId)
          : await repository.searchMembers(widget.guildId, query);
      if (!mounted) return;
      setState(
        () => _results = results
            .where((m) => !widget.alreadyInChannel.contains(m.userId))
            .toList(),
      );
    } catch (_) {
      if (mounted) setState(() => _results = const []);
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(value.trim()),
    );
  }

  Future<void> _ring(GuildMemberDto member) async {
    setState(() => _rung.add(member.userId));
    await getIt<VoiceRingCubit>().sendRing(
      guildId: widget.guildId,
      channelId: widget.channelId,
      targetUserId: member.userId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _results;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.l,
        right: AppSpacing.l,
        top: AppSpacing.l,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: SizedBox(
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite to this channel', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.s),
            TextField(
              controller: _searchController,
              onChanged: _onChanged,
              decoration: const InputDecoration(
                hintText: 'Search members',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Expanded(
              child: results == null
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : results.isEmpty
                  ? const Center(child: Text('Nobody to invite.'))
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final member = results[index];
                        final rung = _rung.contains(member.userId);
                        return ListTile(
                          title: Text(
                            member.nickname ??
                                member.profile?.userName ??
                                member.userId,
                          ),
                          trailing: rung
                              ? const Icon(Icons.check, size: 18)
                              : const Icon(Icons.notifications_none),
                          // Not disabled once rung: a repeat costs nothing and
                          // the server answers the ring that is already out.
                          onTap: () => _ring(member),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
