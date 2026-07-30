import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/di/injector.dart';
import '../../../../../core/theme/widget_styles.dart';
import '../../../../../core/widgets/load_failure_view.dart';
import '../../../data/guild_repository.dart';
import '../../../data/models/guild_emoji_dto.dart';

/// Custom guild emoji management - grid of uploaded emoji with a FAB to add
/// more (image picker + name + animated toggle) and long-press to delete.
/// Reachable via the same `ManageGuild`-gated settings entry point as every
/// other tab here; the server still separately enforces `ManageEmojis` on
/// every upload/delete call regardless.
class EmojiSettingsTab extends StatefulWidget {
  const EmojiSettingsTab({super.key, required this.guildId});

  final String guildId;

  @override
  State<EmojiSettingsTab> createState() => _EmojiSettingsTabState();
}

class _EmojiSettingsTabState extends State<EmojiSettingsTab> {
  final _picker = ImagePicker();
  List<GuildEmojiDto>? _emojis;
  bool _loadFailed = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loadFailed = false);
    try {
      final emojis = await getIt<GuildRepository>().getEmojis(
        widget.guildId,
        forceRefresh: true,
      );
      if (mounted) setState(() => _emojis = emojis);
    } catch (_) {
      // Was `_emojis = const []`, which rendered a failed fetch as "No custom
      // emoji yet." - and would have invited someone to re-upload emoji that
      // already exist.
      if (mounted) setState(() => _loadFailed = true);
    }
  }

  Future<({String name, bool animated})?> _promptEmojiDetails() async {
    final nameController = TextEditingController();
    var animated = false;
    try {
      return await showDialog<({String name, bool animated})>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('New emoji'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: const InputDecoration(hintText: 'emoji_name'),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Animated'),
                  value: animated,
                  onChanged: (value) => setDialogState(() => animated = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                // Without a name the upload was dropped on the floor after
                // the dialog closed, so picking an image then tapping Upload
                // looked like the upload had simply failed silently.
                onPressed: nameController.text.trim().isEmpty
                    ? null
                    : () => Navigator.of(context).pop((
                        name: nameController.text.trim(),
                        animated: animated,
                      )),
                child: const Text('Upload'),
              ),
            ],
          ),
        ),
      );
    } finally {
      nameController.dispose();
    }
  }

  Future<void> _uploadFlow() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;
    final details = await _promptEmojiDetails();
    if (details == null || details.name.isEmpty || !mounted) return;

    setState(() => _uploading = true);
    try {
      final bytes = await file.readAsBytes();
      await getIt<GuildRepository>().uploadEmoji(
        widget.guildId,
        name: details.name,
        animated: details.animated,
        bytes: bytes,
        fileName: file.name,
      );
      await _load();
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.statusCode == 409
                  ? 'An emoji named "${details.name}" already exists.'
                  : 'Could not upload emoji.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not upload emoji.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmDelete(GuildEmojiDto emoji) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete :${emoji.name}:?'),
        content: const Text(
          'Existing reactions using this emoji keep working but show the '
          'name instead of the image.',
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
    if (confirmed != true) return;
    try {
      await getIt<GuildRepository>().deleteEmoji(widget.guildId, emoji.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete emoji.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final emojis = _emojis;
    if (_loadFailed) {
      return LoadFailureView(message: 'Couldn\'t load emoji.', onRetry: _load);
    }
    if (emojis == null) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      body: emojis.isEmpty
          ? Center(
              child: Text(
                'No custom emoji yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : Column(
              children: [
                // Deleting is long-press only, which nothing on screen said -
                // so the grid looked read-only. Cheaper than adding a delete
                // affordance to every tile and keeps the grid uncluttered.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.m,
                    AppSpacing.m,
                    AppSpacing.m,
                    0,
                  ),
                  child: Text(
                    'Long-press an emoji to delete it.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: AppSpacing.m,
                          crossAxisSpacing: AppSpacing.s,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: emojis.length,
                    itemBuilder: (context, index) {
                      final emoji = emojis[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.chip),
                        onLongPress: () => _confirmDelete(emoji),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Image.network(
                                emoji.imageUrl,
                                errorBuilder: (context, error, stack) => Icon(
                                  Icons.broken_image_outlined,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              emoji.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploading ? null : _uploadFlow,
        tooltip: 'Upload emoji',
        child: _uploading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add),
      ),
    );
  }
}
