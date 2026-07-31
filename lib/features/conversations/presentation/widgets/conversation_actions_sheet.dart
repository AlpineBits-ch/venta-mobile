import 'package:flutter/material.dart';

import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/conversation_prefs.dart';
import '../../data/models/conversation_dto.dart';

enum ConversationAction { profile, closeDm, pin, markRead, mute }

/// Long-press actions for one DM row, headed by whose DM it is.
///
/// Returns the chosen action, or null when the sheet is dismissed - every side
/// effect belongs to the caller, which is the screen that owns the list the
/// action changes.
Future<ConversationAction?> showConversationActionsSheet({
  required BuildContext context,
  required ConversationDto conversation,
  required String myUserId,
}) {
  return showModalBottomSheet<ConversationAction>(
    context: context,
    // The shell's nav rail lives in a sibling of the content pane's own
    // Navigator (see `AppShell`) - without this the sheet is clipped to just
    // the content pane instead of covering the whole device width.
    useRootNavigator: true,
    builder: (context) => _ConversationActionsSheet(
      conversation: conversation,
      myUserId: myUserId,
    ),
  );
}

class _ConversationActionsSheet extends StatelessWidget {
  const _ConversationActionsSheet({
    required this.conversation,
    required this.myUserId,
  });

  final ConversationDto conversation;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final others = conversation.members
        .where((m) => m.userId != myUserId)
        .toList();
    // A group DM has no single profile behind it, so the header falls back to
    // the joined member names and the Profile row drops out below.
    final otherUserId = others.length == 1 ? others.single.userId : null;
    final title =
        conversation.name ??
        (others.isEmpty
            ? 'Just you'
            : others.map((m) => m.cachedUserName).join(', '));
    final pinned = ConversationPrefs.isPinned(conversation.id);
    final muted = ConversationPrefs.isMuted(conversation.id);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              otherUserId: otherUserId,
              title: title,
              memberCount: conversation.members.length,
            ),
            const SizedBox(height: AppSpacing.m),
            _ActionGroup([
              if (otherUserId != null)
                const _Action(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  value: ConversationAction.profile,
                ),
              const _Action(
                icon: Icons.close_rounded,
                label: 'Close DM',
                value: ConversationAction.closeDm,
                destructive: true,
              ),
            ]),
            const SizedBox(height: AppSpacing.s),
            _ActionGroup([
              _Action(
                icon: pinned ? Icons.push_pin : Icons.push_pin_outlined,
                label: pinned ? 'Unpin' : 'Pin',
                value: ConversationAction.pin,
              ),
            ]),
            const SizedBox(height: AppSpacing.s),
            _ActionGroup([
              const _Action(
                icon: Icons.done_all,
                label: 'Mark as Read',
                value: ConversationAction.markRead,
              ),
              _Action(
                icon: muted
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                label: muted ? 'Unmute Conversation' : 'Mute Conversation',
                value: ConversationAction.mute,
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.otherUserId,
    required this.title,
    required this.memberCount,
  });

  final String? otherUserId;
  final String title;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = otherUserId;
    return Row(
      children: [
        if (userId != null)
          UserAvatar(
            userId: userId,
            radius: AppRadii.avatarMedium,
            showStatus: true,
            // The default tap pushes the profile route, which would land
            // *underneath* this sheet - route it through the same action the
            // Profile row below returns instead.
            onTap: () => Navigator.pop(context, ConversationAction.profile),
          )
        else
          CircleAvatar(
            radius: AppRadii.avatarMedium,
            backgroundColor: context.statusColors.hover,
            child: Icon(
              Icons.group_outlined,
              color: theme.colorScheme.onSurface,
            ),
          ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: userId == null
              ? _HeaderText(name: title, memberCount: memberCount)
              // The cached member name can be stale; prefer the live profile
              // the avatar beside it is already resolving.
              : ProfileResolver(
                  userId: userId,
                  builder: (context, profile) => _HeaderText(
                    name: profile?.userName ?? title,
                    memberCount: memberCount,
                  ),
                ),
        ),
      ],
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.name, required this.memberCount});

  final String name;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          memberCount > 2 ? '$memberCount members' : 'Direct Message',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

/// One rounded card of rows joined by hairlines, so related actions read as a
/// single connected control rather than a loose stack of list tiles.
class _ActionGroup extends StatelessWidget {
  const _ActionGroup(this.actions);

  final List<_Action> actions;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.dialog),
      child: Material(
        color: context.statusColors.hover,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, action) in actions.indexed) ...[
              // Indented past the icon column, the way a grouped list separates
              // rows without cutting the card in half.
              if (index > 0) const Divider(height: 1, indent: 56),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.value,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final ConversationAction value;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive ? theme.colorScheme.error : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(color: color),
      ),
      onTap: () => Navigator.pop(context, value),
    );
  }
}
