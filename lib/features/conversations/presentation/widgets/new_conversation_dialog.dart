import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../friends/data/models/relationship_model.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../data/conversation_api.dart';
import '../../data/conversation_repository.dart';

/// Start (or reopen) a direct message, or create a named group DM - mirrors
/// desktop's `NewConversationDialogComponent`: pick from your friends list
/// (locally filtered by name, same as desktop's `filteredFriends`), a single
/// selection opens/creates a 1:1, two or more prompts for an optional group
/// name. E2EE group creation is out of scope here (matches this client's
/// deferred MLS phase) - always creates a Plain conversation.
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
      final conversation = _selectedIds.length == 1
          ? await getIt<ConversationRepository>().createOrOpenDirectMessage(
              _selectedIds.single,
            )
          : await getIt<ConversationApi>().create(
              name: _groupNameController.text.trim().isEmpty
                  ? null
                  : _groupNameController.text.trim(),
              memberUserIds: _selectedIds.toList(),
            );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.push(RoutePaths.conversationPath(conversation.id));
    } catch (_) {
      if (mounted) {
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start that conversation.')),
        );
      }
    }
  }

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
                          secondary: CircleAvatar(
                            backgroundColor: context.statusColors.hover,
                            child: Text(
                              friend.userName.isNotEmpty
                                  ? friend.userName[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(friend.userName),
                        );
                      },
                    ),
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
