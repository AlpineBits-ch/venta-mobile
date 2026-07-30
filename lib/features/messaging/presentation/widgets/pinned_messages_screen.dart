import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../data/message_content_codec.dart';
import '../../data/message_repository.dart';
import '../../data/models/message_dto.dart';

/// Pinned-messages panel for the current channel/conversation - backed by
/// `GET .../pins`, most-recently-pinned first. Shows who pinned each entry
/// and when, mirroring what moderators expect from the audit log. Results
/// are read-only, same "no scroll-to-index infra" limitation as
/// [MessageSearchScreen].
class PinnedMessagesScreen extends StatefulWidget {
  const PinnedMessagesScreen({super.key, required this.repository});

  final MessageRepository repository;

  @override
  State<PinnedMessagesScreen> createState() => _PinnedMessagesScreenState();
}

class _PinnedMessagesScreenState extends State<PinnedMessagesScreen> {
  List<MessageDto>? _pins;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pins = await widget.repository.getPinnedMessages();
      if (mounted) setState(() => _pins = pins);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not load pinned messages.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pins = _pins;
    return Scaffold(
      appBar: AppBar(title: const Text('Pinned Messages')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : pins == null || pins.isEmpty
          ? Center(
              child: Text(
                'No pinned messages yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
              itemCount: pins.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final message = pins[index];
                final text = MessageContentCodec.decode(message.content);
                return ListTile(
                  title: ProfileResolver(
                    userId: message.authorId,
                    builder: (context, profile) =>
                        Text(profile?.userName ?? '…'),
                  ),
                  subtitle: Text(
                    text.isEmpty ? '(attachment)' : text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Icon(Icons.push_pin, size: 14),
                      if (message.pinnedAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            message.pinnedAt!.toLocal().toString().split(
                              '.',
                            )[0],
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
