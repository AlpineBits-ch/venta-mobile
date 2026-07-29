import 'package:flutter/material.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/hex_color.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/role_dto.dart';
import 'role_editor_screen.dart';

class RolesSettingsTab extends StatefulWidget {
  const RolesSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<RolesSettingsTab> createState() => _RolesSettingsTabState();
}

class _RolesSettingsTabState extends State<RolesSettingsTab> {
  List<RoleDto>? _roles;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repository = getIt<GuildRepository>();
    final guild =
        repository.cachedById(widget.guildId) ??
        await repository.fetchGuild(widget.guildId);
    if (!mounted) return;
    setState(() {
      _roles = guild.roles.where((r) => r.type != RoleType.everyone).toList()
        ..sort((a, b) => b.position.compareTo(a.position));
    });
  }

  Future<void> _createRole() async {
    try {
      await getIt<GuildRepository>().createRole(
        guildId: widget.guildId,
        name: 'new-role',
      );
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not create role.')));
      }
    }
  }

  Future<void> _reorder(int oldIndex, int newIndex) async {
    final roles = _roles;
    if (roles == null) return;
    setState(() {
      final role = roles.removeAt(oldIndex);
      roles.insert(newIndex, role);
    });
    final count = roles.length;
    final positions = [
      for (var i = 0; i < count; i++)
        (roleId: roles[i].id, position: count - i),
    ];
    try {
      await getIt<GuildRepository>().reorderRoles(widget.guildId, positions);
    } catch (_) {
      await _load();
    }
  }

  Future<void> _openEditor(RoleDto role) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => RoleEditorScreen(guildId: widget.guildId, role: role),
      ),
    );
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = _roles;
    if (roles == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: roles.isEmpty
          ? const Center(child: Text('No roles yet.'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              itemCount: roles.length,
              onReorderItem: _reorder,
              itemBuilder: (context, index) {
                final role = roles[index];
                final color = role.color != null && role.color!.isNotEmpty
                    ? parseHexColor(role.color!)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.3);
                return ListTile(
                  key: ValueKey(role.id),
                  leading: CircleAvatar(radius: 8, backgroundColor: color),
                  title: Text(role.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openEditor(role),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createRole,
        tooltip: 'Create role',
        child: const Icon(Icons.add),
      ),
    );
  }
}
