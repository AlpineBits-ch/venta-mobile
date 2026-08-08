import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/mls/mls_coverage_service.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/mls_api.dart';
import '../../data/models/mls_dtos.dart';
import '../widgets/device_coverage_section.dart';

/// A conversation's security screen.
///
/// A DM had nowhere for this to live: `ChannelEncryptionScreen` sits behind
/// guild channel settings, which a conversation does not have, so anything worth
/// saying about a DM's encryption had only the message list to say it in - and
/// the message list is the one place the guide says not to put a device somebody
/// cannot act on.
///
/// Deliberately not a toggle. The server has no per-conversation enable path
/// this client uses; a conversation is created encrypted or it is not, so this
/// is a place to look rather than a place to change something.
class ConversationEncryptionScreen extends StatefulWidget {
  const ConversationEncryptionScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ConversationEncryptionScreen> createState() =>
      _ConversationEncryptionScreenState();
}

class _ConversationEncryptionScreenState
    extends State<ConversationEncryptionScreen> {
  MlsContextStateDto? _state;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final state = await getIt<MlsApi>().getState(
        contextId: widget.conversationId,
        isChannel: false,
      );
      // A re-key makes every verdict this device has cached wrong rather than
      // stale, and the state call already carries the answer - so noticing it
      // costs nothing here.
      getIt<MlsCoverageService>().noteGeneration(
        widget.conversationId,
        state.activeGeneration,
      );
      if (!mounted) return;
      setState(() {
        _state = state;
        _loading = false;
      });
    } catch (e) {
      debugPrint('ConversationEncryptionScreen: $e');
      if (!mounted) return;
      setState(() {
        _error = 'Could not read this conversation\'s encryption state.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final encrypted = _state?.encrypted ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Encryption')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.m),
              children: [
                Text(
                  encrypted
                      ? 'End-to-end encrypted'
                      : 'Not end-to-end encrypted',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  encrypted
                      ? 'Messages here can only be read by the devices that '
                            'were let into this conversation. The server stores '
                            'them as ciphertext and cannot read or search them.'
                      : 'Messages here are stored so the server can read them. '
                            'A conversation is either encrypted from the start '
                            'or it is not.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),

                if (_error case final message?) ...[
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],

                DeviceCoverageSection(
                  contextId: widget.conversationId,
                  isChannel: false,
                ),
              ],
            ),
    );
  }
}
