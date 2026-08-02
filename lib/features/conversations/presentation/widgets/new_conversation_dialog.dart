import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/conversation_encryption_service.dart';
import '../../../../core/mls/mls_service.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../friends/data/models/relationship_model.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../../mls/data/models/mls_dtos.dart';
import '../../data/conversation_api.dart';
import '../../data/conversation_repository.dart';
import '../../data/models/conversation_dto.dart';

/// Start (or reopen) a direct message, or create a named group DM - mirrors
/// desktop's `NewConversationDialogComponent`: pick from your friends list
/// (locally filtered by name, same as desktop's `filteredFriends`), a single
/// selection opens/creates a 1:1, two or more prompts for an optional group
/// name.
///
/// The encryption switch is create-time only, matching both the desktop client
/// and the server: a conversation has no toggle endpoint, so this is the one
/// moment it can be decided.
Future<void> showNewConversationDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _NewConversationDialog(),
  );
}

class _NewConversationDialog extends StatefulWidget {
  const _NewConversationDialog();

  @override
  State<_NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<_NewConversationDialog> {
  final _searchController = TextEditingController();
  final _groupNameController = TextEditingController();
  final Set<String> _selectedIds = {};
  List<MinimalProfileId> _friends = const [];
  bool _loading = true;
  bool _creating = false;
  bool _encrypted = false;

  String get _myUserId => getIt<AuthRepository>().currentUserId ?? '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final relationships = await getIt<RelationshipRepository>().fetch();
      final friends = relationships
          .where((r) => r.status == RelationshipStatus.friends)
          .map((r) => r.otherParty(_myUserId))
          .toList();
      if (mounted) {
        setState(() {
          _friends = friends;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MinimalProfileId> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _friends;
    return _friends
        .where((f) => f.userName.toLowerCase().contains(query))
        .toList();
  }

  void _toggle(String userId) {
    setState(() {
      if (!_selectedIds.remove(userId)) _selectedIds.add(userId);
    });
  }

  Future<void> _create() async {
    if (_selectedIds.isEmpty || _creating) return;
    setState(() => _creating = true);
    try {
      final ConversationDto conversation;
      if (_encrypted) {
        // Deliberately not routed through `createOrOpenDirectMessage` even for
        // a single friend: that reuses any existing plain conversation with
        // them, and silently handing back an unencrypted thread to someone who
        // asked for an encrypted one is the worst possible outcome here.
        conversation = await getIt<ConversationEncryptionService>()
            .createEncrypted(
              ownUserId: _myUserId,
              memberUserIds: _selectedIds.toList(),
              name: _groupName,
              onPartialCoverage: _confirmPartialCoverage,
            );
      } else if (_selectedIds.length == 1) {
        conversation = await getIt<ConversationRepository>()
            .createOrOpenDirectMessage(_selectedIds.single);
      } else {
        conversation = await getIt<ConversationApi>().create(
          name: _groupName,
          memberUserIds: _selectedIds.toList(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push(RoutePaths.conversationPath(conversation.id));
    } on UnreachableMembersException {
      // The human was shown the devices and said no. That is an answer, not an
      // error, so the dialog simply stays open on their selection.
      if (mounted) setState(() => _creating = false);
    } catch (_) {
      if (mounted) {
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start that conversation.')),
        );
      }
    }
  }

  /// Offers the choice the old code never gave: create anyway, or go back.
  ///
  /// It used to refuse outright, and only when a participant had **no**
  /// reachable device at all - a participant with a working laptop and a dry
  /// phone sailed through and the phone was dropped from the group silently and
  /// permanently. Nothing retro-adds a device to an existing MLS group, so
  /// "later" never comes on its own.
  ///
  /// Blocking until a human decides is what Alpine's new-conversation dialog
  /// does, and the accepted answer is what puts
  /// `?allowPartialDeviceCoverage=true` on the create.
  Future<bool> _confirmPartialCoverage(
    List<UnreachableDeviceDto> devices,
  ) async {
    if (!mounted) return false;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Some devices cannot be included'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'These devices have no encryption keys available, so they will '
              'not be able to read this conversation - including anything sent '
              'before they are let back in.',
            ),
            const SizedBox(height: AppSpacing.s),
            for (final device in devices)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('• ${device.deviceName ?? device.deviceId}'),
              ),
            const SizedBox(height: AppSpacing.s),
            const Text(
              'Waiting until they are online again is usually the better '
              'option.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create anyway'),
          ),
        ],
      ),
    );
    return accepted ?? false;
  }

  String? get _groupName => _groupNameController.text.trim().isEmpty
      ? null
      : _groupNameController.text.trim();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGroup = _selectedIds.length >= 2;
    return AlertDialog(
      title: const Text('New Message'),
      content: SizedBox(
        width: 360,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(hintText: 'Search friends'),
            ),
            if (isGroup) ...[
              const SizedBox(height: AppSpacing.s),
              TextField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  hintText: 'Group name (optional)',
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.s),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                  ? Center(
                      child: Text(
                        _friends.isEmpty ? 'No friends yet.' : 'No matches.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final friend = _filtered[index];
                        final selected = _selectedIds.contains(friend.userId);
                        return CheckboxListTile(
                          value: selected,
                          onChanged: (_) => _toggle(friend.userId),
                          // Tapping a row here toggles the checkbox; the
                          // avatar must not navigate away mid-selection.
                          secondary: UserAvatar(
                            userId: friend.userId,
                            fallbackLabel: friend.userName,
                            onTap: () => _toggle(friend.userId),
                          ),
                          title: Text(friend.userName),
                        );
                      },
                    ),
            ),
            const Divider(height: AppSpacing.m),
            _EncryptionToggle(
              value: _encrypted,
              onChanged: _creating
                  ? null
                  : (value) => setState(() => _encrypted = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _creating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedIds.isEmpty || _creating ? null : _create,
          child: _creating
              ? const ButtonProgressIndicator()
              : Text(isGroup ? 'Create Group' : 'Start'),
        ),
      ],
    );
  }
}

/// The create-time encryption switch.
///
/// Disabled outright when this device has no MLS keys - offering a toggle that
/// can only fail is worse than explaining why it is not available, and the
/// failure would land after the user has already picked everyone.
class _EncryptionToggle extends StatelessWidget {
  const _EncryptionToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ready = getIt<MlsService>().isUnlocked;

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      secondary: Icon(
        value ? Icons.lock_outline : Icons.lock_open_outlined,
        color: value
            ? context.statusColors.online
            : theme.colorScheme.onSurface.withValues(alpha: 0.45),
      ),
      title: const Text('End-to-end encrypted'),
      subtitle: Text(
        ready
            ? 'The server won\'t be able to read or search these messages.'
            : 'Encryption keys aren\'t set up on this device yet.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      value: value && ready,
      onChanged: ready ? onChanged : null,
    );
  }
}
