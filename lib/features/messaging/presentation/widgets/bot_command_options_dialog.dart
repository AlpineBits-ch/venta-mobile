import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../data/bot_command_api.dart';
import '../../data/models/bot_command_dto.dart';

/// Collects one value per command option before invoking a bot command that
/// takes parameters - matches desktop's `BotCommandDialogComponent`.
/// `User`/`Channel`/`Role`/`Mentionable` options fall back to a plain text
/// field for a raw id, same as desktop (no picker widget for those yet).
Future<List<InvokeCommandOption>?> showBotCommandOptionsDialog(
  BuildContext context,
  BotCommandDto command,
) {
  return showDialog<List<InvokeCommandOption>>(
    context: context,
    builder: (_) => _BotCommandOptionsDialog(command: command),
  );
}

class _BotCommandOptionsDialog extends StatefulWidget {
  const _BotCommandOptionsDialog({required this.command});

  final BotCommandDto command;

  @override
  State<_BotCommandOptionsDialog> createState() =>
      _BotCommandOptionsDialogState();
}

class _BotCommandOptionsDialogState extends State<_BotCommandOptionsDialog> {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, bool> _boolValues = {};

  @override
  void initState() {
    super.initState();
    for (final option in widget.command.options) {
      if (option.type == BotCommandOptionType.boolean) {
        _boolValues[option.name] = false;
      } else {
        _textControllers[option.name] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit {
    for (final option in widget.command.options) {
      if (!option.required || option.type == BotCommandOptionType.boolean)
        continue;
      if ((_textControllers[option.name]?.text ?? '').trim().isEmpty)
        return false;
    }
    return true;
  }

  void _submit() {
    final options = <InvokeCommandOption>[];
    for (final option in widget.command.options) {
      if (option.type == BotCommandOptionType.boolean) {
        options.add(
          InvokeCommandOption(
            name: option.name,
            value: _boolValues[option.name] ?? false,
          ),
        );
        continue;
      }
      final raw = _textControllers[option.name]!.text.trim();
      if (raw.isEmpty) {
        if (option.required) return;
        continue;
      }
      options.add(
        InvokeCommandOption(
          name: option.name,
          value: _coerce(option.type, raw),
        ),
      );
    }
    Navigator.of(context).pop(options);
  }

  Object _coerce(BotCommandOptionType type, String raw) {
    switch (type) {
      case BotCommandOptionType.integer:
        return int.tryParse(raw) ?? raw;
      case BotCommandOptionType.number:
        return num.tryParse(raw) ?? raw;
      case BotCommandOptionType.string:
      case BotCommandOptionType.boolean:
      case BotCommandOptionType.user:
      case BotCommandOptionType.channel:
      case BotCommandOptionType.role:
      case BotCommandOptionType.mentionable:
        return raw;
    }
  }

  String _hintFor(BotCommandOptionDto option) {
    switch (option.type) {
      case BotCommandOptionType.user:
        return 'User ID';
      case BotCommandOptionType.channel:
        return 'Channel ID';
      case BotCommandOptionType.role:
        return 'Role ID';
      case BotCommandOptionType.mentionable:
        return 'User or role ID';
      case BotCommandOptionType.integer:
      case BotCommandOptionType.number:
        return 'Number';
      case BotCommandOptionType.string:
      case BotCommandOptionType.boolean:
        return option.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('/${widget.command.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in widget.command.options) ...[
              if (option.type == BotCommandOptionType.boolean)
                StatefulBuilder(
                  builder: (context, setInner) => SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.name),
                    subtitle: option.description != null
                        ? Text(option.description!)
                        : null,
                    value: _boolValues[option.name] ?? false,
                    onChanged: (value) =>
                        setInner(() => _boolValues[option.name] = value),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s),
                  child: TextField(
                    controller: _textControllers[option.name],
                    keyboardType:
                        option.type == BotCommandOptionType.integer ||
                            option.type == BotCommandOptionType.number
                        ? TextInputType.number
                        : TextInputType.text,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: option.name + (option.required ? ' *' : ''),
                      hintText: _hintFor(option),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSubmit ? _submit : null,
          child: const Text('Run'),
        ),
      ],
    );
  }
}
