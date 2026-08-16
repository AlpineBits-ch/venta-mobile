import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../bloc/voice_ring_cubit.dart';

/// "Ask somebody into this voice channel."
///
/// **Two different invitations live here, and only one of them has rules about
/// where you are.**
///
/// * Tapping a row sends the quiet one - a card in that person's DM, `delivery:
///   Message`. No ring is created, so nothing expires and there is nothing to
///   accept or decline. **The sender does not have to be in the channel**; they
///   only have to be able to see and connect to it themselves, which is why this
///   sheet can be opened from a channel somebody is merely looking at.
/// * The bell beside a row sends the loud one - a live ~60 second ring that
///   buzzes their devices. **That one is offered only while this account is
///   sitting in the channel**, because its entire claim is "I am in here", and
///   ringing from a channel you are only looking at would be a claim about
///   somebody else's room. The endpoint refuses it with a bare `403`, which is a
///   bug in the client rather than something to put on screen - so [isInChannel]
///   decides whether the bell exists at all.
///
/// **The list is the channel's viewers, not the guild's members.** A ring at
/// somebody who cannot see the channel is refused, and a permission refusal is
/// deliberately not refunded against the rate limit - walking the member list to
/// find out who can see a private channel is meant to cost a token per name.
/// Filtering here is what stops this sheet doing exactly that by accident.
///
/// The target is picked by user id from that roster - there is no
/// invite-by-mention and no invite-from-DM.
Future<void> showVoiceRingInviteSheet(
  BuildContext context, {
  required String guildId,
  required String channelId,
  bool isInChannel = false,
  Set<String> alreadyInChannel = const {},
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _VoiceRingInviteSheet(
    guildId: guildId,
    channelId: channelId,
    isInChannel: isInChannel,
    alreadyInChannel: alreadyInChannel,
  ),
);

class _VoiceRingInviteSheet extends StatefulWidget {
  const _VoiceRingInviteSheet({
    required this.guildId,
    required this.channelId,
    required this.isInChannel,
    required this.alreadyInChannel,
  });

  final String guildId;
  final String channelId;

  /// Whether this account is sitting in the channel right now, which is the one
  /// thing the ring needs and the message invitation does not. False hides the
  /// bell; it never hides a row.
  final bool isInChannel;

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

  /// Exactly who holds `ViewChannel` here, resolved server-side. Read once and
  /// awaited by every search rather than re-read per keystroke - it is a fact
  /// about the channel, not about the query.
  late final Future<Set<String>> _viewers;

  /// Who has been rung from this sheet, so the row can say so.
  ///
  /// Repeating a ring already out is idempotent server-side - it answers the
  /// same ring with no second event and no second push - so this is display
  /// only and never a guard.
  final _rung = <String>{};

  /// Who has been sent a message invitation while this sheet has been open.
  ///
  /// A note about this sitting rather than a durable fact: the durable one is
  /// the card in their conversation, and this sheet has no way to see it.
  final _invited = <String>{};

  /// The one invitation in flight, so a double tap cannot send twice. Unlike the
  /// ring there is no idempotency behind this: a second request writes a second
  /// card into the conversation.
  String? _inviting;

  /// A refusal against the one person it is about. Reported per row rather than
  /// in a sheet-wide banner because the common one - they do not accept messages
  /// from this sender - is a fact about those two people and would be a lie
  /// about everybody else in the list.
  ({String userId, String message})? _inviteRefusal;

  @override
  void initState() {
    super.initState();
    // A failed viewer read collapses to an empty roster rather than falling back
    // on the guild's member list: offering everybody would be offering rows the
    // server refuses, and paying a rate-limit token per name to find out.
    _viewers = getIt<GuildRepository>()
        .getChannelViewers(widget.channelId)
        .then((ids) => ids.toSet())
        .onError<Object>((_, _) => <String>{});
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
      final viewers = await _viewers;
      // Inviting yourself is a `400`, and is nobody's intent anyway.
      final self = getIt<AuthRepository>().currentUserId;
      if (!mounted) return;
      setState(
        () => _results = results
            .where((m) => viewers.contains(m.userId))
            .where((m) => m.userId != self)
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

  /// The quiet one, and what a row does.
  Future<void> _invite(GuildMemberDto member) async {
    if (_inviting != null || _invited.contains(member.userId)) return;

    setState(() {
      _inviting = member.userId;
      _inviteRefusal = null;
    });

    final outcome = await getIt<VoiceRingCubit>().sendInvite(
      guildId: widget.guildId,
      channelId: widget.channelId,
      targetUserId: member.userId,
    );

    if (!mounted) return;
    setState(() {
      _inviting = null;
      if (outcome.wasSent) {
        _invited.add(member.userId);
      } else {
        _inviteRefusal = (
          userId: member.userId,
          message: outcome.refusalMessage!,
        );
      }
    });
  }

  /// The loud one. Still the same call it always was, just no longer what a row
  /// does.
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
                  // Not "no members": the roster this list is drawn from is who
                  // can see the channel, so an empty one says that instead.
                  ? const Center(
                      child: Text('Nobody else can see this channel.'),
                    )
                  : ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final member = results[index];
                        return _MemberRow(
                          member: member,
                          isInChannel: widget.isInChannel,
                          rung: _rung.contains(member.userId),
                          invited: _invited.contains(member.userId),
                          inviting: _inviting == member.userId,
                          // Any invitation in flight quiets every row, so a
                          // second send cannot start before the first answers.
                          busy: _inviting != null,
                          refusal: _inviteRefusal?.userId == member.userId
                              ? _inviteRefusal?.message
                              : null,
                          onInvite: () => _invite(member),
                          onRing: () => _ring(member),
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

/// One person, with the quiet invitation on the row and the loud one beside it.
class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.isInChannel,
    required this.rung,
    required this.invited,
    required this.inviting,
    required this.busy,
    required this.refusal,
    required this.onInvite,
    required this.onRing,
  });

  final GuildMemberDto member;
  final bool isInChannel;
  final bool rung;
  final bool invited;
  final bool inviting;
  final bool busy;
  final String? refusal;
  final VoidCallback onInvite;
  final VoidCallback onRing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = refusal;

    return ListTile(
      title: Text(member.nickname ?? member.profile?.userName ?? member.userId),
      subtitle: message == null
          ? null
          : Text(
              message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (inviting)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2),
            )
          else if (invited)
            Text(
              'Invited',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          // Deliberately small, deliberately separate, and absent entirely from
          // a channel this account is only looking at. Ringing buzzes a phone
          // and a decline locks the sender out for hours, so it must never be
          // the thing somebody hits by aiming at a name.
          if (isInChannel) ...[
            const SizedBox(width: AppSpacing.s),
            IconButton(
              icon: Icon(
                rung ? Icons.notifications_active : Icons.notifications_none,
              ),
              tooltip: 'Ring them now',
              // Not disabled once rung: a repeat costs nothing and the server
              // answers the ring that is already out.
              onPressed: onRing,
            ),
          ],
        ],
      ),
      // The row itself sends the message invitation. It interrupts nobody, it
      // does not expire, and it is what somebody means by "invite them" almost
      // every time - so it is the whole width of the row rather than an icon.
      onTap: invited || busy ? null : onInvite,
    );
  }
}
