import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../data/guild_repository.dart';
import '../../data/models/guild_dto.dart';

/// "What are you making" → "what's it called", then create. Two steps rather
/// than one name prompt because [GuildKind] seeds the whole module set: it's
/// the decision that shapes everything else, and it's much cheaper to answer
/// up front than to fix afterwards in settings.
///
/// Pops the created [GuildDto], or null if the user backed out.
class CreateGuildScreen extends StatefulWidget {
  const CreateGuildScreen({super.key});

  @override
  State<CreateGuildScreen> createState() => _CreateGuildScreenState();
}

class _CreateGuildScreenState extends State<CreateGuildScreen> {
  final _nameController = TextEditingController();
  GuildKind? _kind;
  int _step = 0;
  bool _creating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final kind = _kind;
    if (kind == null || _nameController.text.trim().isEmpty) return;
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final guild = await getIt<GuildRepository>().createGuild(
        name: _nameController.text.trim(),
        // Community is the server's own default, so it's left unsent - that
        // keeps a plain community identical to what the old flow produced.
        kind: kind == GuildKind.community ? null : kind,
      );
      if (mounted) Navigator.of(context).pop(guild);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error =
              apiErrorMessage(error) ?? 'Could not create that server.',
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canContinue = _step == 0
        ? _kind != null
        : _nameController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(_step == 0 ? Icons.close : Icons.arrow_back),
          tooltip: _step == 0 ? 'Cancel' : 'Back',
          onPressed: _creating
              ? null
              : () => _step == 0
                    ? Navigator.of(context).pop()
                    : setState(() => _step = 0),
        ),
        title: Text(_step == 0 ? 'What are you making?' : 'Name it'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 2,
            minHeight: 4,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _step == 0 ? _buildKindStep(theme) : _buildNameStep(theme),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: !canContinue || _creating
                      ? null
                      : () =>
                            _step == 0 ? setState(() => _step = 1) : _create(),
                  child: _creating
                      ? const ButtonProgressIndicator()
                      : Text(_step == 0 ? 'Continue' : 'Create'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKindStep(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        Text(
          'This sets which parts of Venta you get. You can change it, or turn '
          'individual modules on and off, in settings later.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        for (final kind in GuildKind.values) ...[
          _KindOption(
            kind: kind,
            selected: _kind == kind,
            onTap: () => setState(() => _kind = kind),
          ),
          const SizedBox(height: AppSpacing.s),
        ],
      ],
    );
  }

  Widget _buildNameStep(ThemeData theme) {
    final kind = _kind ?? GuildKind.community;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.l),
      children: [
        TextField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: '${kind.noun} name',
            hintText: switch (kind) {
              GuildKind.household => 'The Flat',
              GuildKind.team => 'Design team',
              GuildKind.study => 'Physics revision',
              GuildKind.event => 'Sarah\'s wedding',
              GuildKind.community => 'My server',
            },
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        Text('WHAT YOU\'LL GET', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.s),
        Text(
          kind.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        // Deliberately not a promise of the exact flag set: the preset is the
        // server's to define, and it may gain modules this build predates.
        Text(
          'A starter set of modules comes with this - nothing is permanent, '
          'and turning one off later hides it without deleting anything.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _KindOption extends StatelessWidget {
  const _KindOption({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  final GuildKind kind;
  final bool selected;
  final VoidCallback onTap;

  IconData get _icon => switch (kind) {
    GuildKind.community => Icons.groups_outlined,
    GuildKind.household => Icons.home_outlined,
    GuildKind.team => Icons.work_outline,
    GuildKind.study => Icons.school_outlined,
    GuildKind.event => Icons.celebration_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              Icon(
                _icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kind.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kind.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
