import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/widget_styles.dart';

/// Shows a newly minted recovery code once, and refuses to move on until the
/// user has demonstrably written it down.
///
/// Contract §C.1.1 and §G.5. This is the only credential that survives a
/// password reset: without it a reset leaves the master key sealed under a
/// password the user has by definition forgotten, and every backup blob plus the
/// account identity key become permanently unopenable. It is not derivable from
/// anything the server holds, so if it is lost together with the password there
/// is nothing anyone can do.
///
/// The confirmation step is deliberately a re-entry rather than a checkbox.
/// "I have saved this" is a box people tick; typing four groups back is a thing
/// they can only do if they actually saved it. The wording says the loss is
/// permanent **before** the user can proceed rather than in a help article,
/// because this is the one screen where they can still act on it.
class RecoveryCodeScreen extends StatefulWidget {
  const RecoveryCodeScreen({
    super.key,
    required this.recoveryCode,
    this.title = 'Save your recovery code',
  });

  final String recoveryCode;
  final String title;

  @override
  State<RecoveryCodeScreen> createState() => _RecoveryCodeScreenState();
}

class _RecoveryCodeScreenState extends State<RecoveryCodeScreen> {
  final _controller = TextEditingController();
  bool _confirming = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Compared on the normalised form, matching what the engine derives from.
  /// Rejecting a correct code because it was typed in lower case, or without the
  /// grouping dashes, would be the worst possible moment for a formatting
  /// quibble.
  static String _normalize(String value) =>
      value.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();

  /// The 31-symbol alphabet, mirroring the engine's (contract §C.1.2). Held here
  /// so a mistyped `0` or `I` is named as such rather than reported as "does not
  /// match" - those are the characters people actually get wrong, and saying
  /// *which* one is the difference between a fixable typo and giving up.
  static const _alphabet = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

  void _confirm() {
    final typed = _normalize(_controller.text);

    final stray = typed.split('').where((c) => !_alphabet.contains(c)).toSet();
    if (stray.isNotEmpty) {
      setState(
        () => _error =
            'A recovery code never contains '
            '${stray.map((c) => '"$c"').join(', ')}. '
            '0 and O, and 1, I and L, are easy to mix up.',
      );
      return;
    }

    if (typed == _normalize(widget.recoveryCode)) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _error = 'That does not match. Check it and try again.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        // No back button: leaving without saving the code is the failure mode
        // this screen exists to prevent.
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _confirming
                    ? 'Type your recovery code back'
                    : 'Write this down somewhere safe',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                _confirming
                    ? 'Just to be sure it is really saved. Capitals and dashes '
                          'do not matter.'
                    : 'It is the only way back into your encrypted messages if '
                          'you ever reset your password. We cannot show it '
                          'again and we cannot recover it for you — if you lose '
                          'both this code and your password, your encrypted '
                          'history is gone permanently.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: AppSpacing.m),

              if (!_confirming) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: SelectableText(
                    widget.recoveryCode,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: widget.recoveryCode),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recovery code copied')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _controller,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    letterSpacing: 1.5,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Recovery code',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onSubmitted: (_) => _confirm(),
                ),
              ],

              const SizedBox(height: AppSpacing.l),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirming
                      ? _confirm
                      : () => setState(() => _confirming = true),
                  child: Text(_confirming ? 'Confirm' : 'I have saved it'),
                ),
              ),
              if (_confirming) ...[
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => setState(() {
                      _confirming = false;
                      _error = null;
                      _controller.clear();
                    }),
                    child: const Text('Show me the code again'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
