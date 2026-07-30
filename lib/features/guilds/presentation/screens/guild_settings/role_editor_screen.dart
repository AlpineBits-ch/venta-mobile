import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/hex_color.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_dto.dart';
import '../../../data/models/guild_features.dart';
import '../../../data/models/guild_member_dto.dart';
import '../../../data/models/guild_permissions.dart';
import '../../../data/models/role_dto.dart';

const _presetColors = [
  '#EF4444',
  '#F97316',
  '#F59E0B',
  '#EAB308',
  '#84CC16',
  '#22C55E',
  '#10B981',
  '#14B8A6',
  '#06B6D4',
  '#3B82F6',
  '#6366F1',
  '#8B5CF6',
  '#A855F7',
  '#D946EF',
  '#EC4899',
  '#64748B',
];

class RoleEditorScreen extends StatefulWidget {
  const RoleEditorScreen({
    super.key,
    required this.guildId,
    required this.role,
  });

  final String guildId;
  final RoleDto role;

  @override
  State<RoleEditorScreen> createState() => _RoleEditorScreenState();
}

class _RoleEditorScreenState extends State<RoleEditorScreen> {
  late final _nameController = TextEditingController(text: widget.role.name);
  late final _descriptionController = TextEditingController(
    text: widget.role.description ?? '',
  );
  late String? _color = widget.role.color;
  late GuildPermissions _permissions = widget.role.permissionsValue;
  bool _saving = false;

  List<GuildMemberDto>? _members;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await getIt<GuildRepository>().getRoleMembers(
        widget.role.id,
      );
      if (mounted) setState(() => _members = members);
    } catch (_) {
      if (mounted) setState(() => _members = const []);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await getIt<GuildRepository>().updateRole(
        guildId: widget.guildId,
        roleId: widget.role.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        color: _color,
        permissions: _permissions,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        final message = e.toString().contains('403')
            ? 'You can only grant permissions you already have yourself.'
            : 'Could not save this role.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete role?'),
        content: Text(
          'This removes "${widget.role.name}" from everyone who has it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await getIt<GuildRepository>().deleteRole(widget.guildId, widget.role.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete this role.')),
        );
      }
    }
  }

  Future<void> _removeMember(GuildMemberDto member) async {
    try {
      await getIt<GuildRepository>().removeRoleMember(
        widget.role.id,
        member.id,
      );
      await _loadMembers();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not remove that member.')),
        );
      }
    }
  }

  Future<void> _addMember() async {
    final member = await showDialog<GuildMemberDto>(
      context: context,
      builder: (_) => _MemberPickerDialog(
        guildId: widget.guildId,
        excludeIds: (_members ?? const []).map((m) => m.id).toSet(),
      ),
    );
    if (member == null) return;
    try {
      await getIt<GuildRepository>().addRoleMember(widget.role.id, member.id);
      await _loadMembers();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not add that member.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('/${widget.role.name}'),
        actions: [
          IconButton(
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: AppSpacing.s),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: AppSpacing.m),
          Text('Color', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              for (final hex in _presetColors)
                GestureDetector(
                  onTap: () => setState(() => _color = hex),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: parseHexColor(hex),
                    child: _color == hex
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          Text('Permissions', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          // Filtered by the guild's modules: a permission whose module is off
          // is refused before roles are even consulted, so offering it here
          // would be offering something that cannot take effect.
          for (final flag in GuildPermissions.grantableFlagNamesFor(
            getIt<GuildRepository>().cachedById(widget.guildId)?.featureSet ??
                GuildFeatures.communityPreset,
          ))
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(GuildPermissions.labelFor(flag)),
              value: _permissions.has(flag),
              onChanged: (value) => setState(
                () => _permissions = _permissions.withFlag(flag, value),
              ),
            ),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              Text('Members', style: theme.textTheme.titleSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: _addMember,
                icon: const Icon(Icons.person_add_alt, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_members == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.m),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_members!.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              child: Text(
                'No members have this role yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          else
            for (final member in _members!)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  member.nickname ?? member.profile?.userName ?? member.userId,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeMember(member),
                ),
              ),
          const SizedBox(height: AppSpacing.l),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Text('Save role'),
          ),
        ],
      ),
    );
  }
}

class _MemberPickerDialog extends StatefulWidget {
  const _MemberPickerDialog({required this.guildId, required this.excludeIds});

  final String guildId;
  final Set<String> excludeIds;

  @override
  State<_MemberPickerDialog> createState() => _MemberPickerDialogState();
}

class _MemberPickerDialogState extends State<_MemberPickerDialog> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<GuildMemberDto>? _results;

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
      final results = query.isEmpty
          ? await getIt<GuildRepository>().getMembers(widget.guildId)
          : await getIt<GuildRepository>().searchMembers(widget.guildId, query);
      if (mounted) {
        setState(
          () => _results = results
              .where((m) => !widget.excludeIds.contains(m.id))
              .toList(),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add member'),
      content: SizedBox(
        width: 320,
        height: 360,
        child: Column(
          children: [
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
              child: _results == null
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _results!.length,
                      itemBuilder: (context, index) {
                        final member = _results![index];
                        return ListTile(
                          title: Text(
                            member.nickname ??
                                member.profile?.userName ??
                                member.userId,
                          ),
                          onTap: () => Navigator.of(context).pop(member),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
