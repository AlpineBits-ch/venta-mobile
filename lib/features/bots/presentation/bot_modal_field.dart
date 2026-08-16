import 'package:flutter/foundation.dart';

import '../data/models/bot_modal_dtos.dart';

/// Discord's text-input styles. Anything else on a `type: 4` is treated as
/// single-line.
const _paragraphTextInputStyle = 2;

/// How deep a bot's component tree is followed before it is assumed to be
/// malformed.
const _maxRowDepth = 4;

/// One field, after the action-row wrapper has been unwrapped.
@immutable
class ModalField {
  const ModalField({
    required this.key,
    required this.customId,
    required this.label,
    required this.placeholder,
    required this.isRequired,
    required this.minLength,
    required this.maxLength,
    required this.isParagraph,
    required this.initialValue,
    required this.isUnsupported,
  });

  /// Identity key for this field's controller, value and error. Index-prefixed
  /// because `custom_id` is bot-chosen and may repeat, and two fields sharing a
  /// key would have the user typing into both at once.
  final String key;

  /// The bot's handle for this field; what the answer is keyed by on the way
  /// back.
  final String customId;
  final String label;
  final String placeholder;
  final bool isRequired;
  final int? minLength;
  final int? maxLength;

  /// Style 2 - render a multi-line box rather than a single-line input.
  final bool isParagraph;

  /// Whatever the bot prefilled the field with.
  final String initialValue;

  /// Set when the payload asked for something this dialog cannot render, or
  /// cannot answer.
  final bool isUnsupported;
}

/// Turns the tolerated whole numbers into a usable bound, and everything else
/// into "no bound".
///
/// These arrive from a bot process, not from the server's own model - a
/// negative or zero `min_length` would otherwise make a field permanently
/// invalid with no way for the user to fix it.
int? _bound(int? raw) => raw != null && raw > 0 ? raw : null;

/// Unwraps action rows into the fields they hold.
///
/// Depth-limited: the tree comes from a bot, and a payload that nests rows into
/// each other - by accident or otherwise - would spin here forever with the UI
/// thread in it.
List<BotComponentDto> flattenModalRows(
  List<BotComponentDto> components, [
  int depth = 0,
]) {
  if (depth > _maxRowDepth) return const [];
  final out = <BotComponentDto>[];
  for (final component in components) {
    if (component.type == BotComponentType.actionRow &&
        component.components.isNotEmpty) {
      out.addAll(flattenModalRows(component.components, depth + 1));
    } else {
      out.add(component);
    }
  }
  return out;
}

/// Reads one component of a modal payload as a field this dialog can put on
/// screen.
///
/// Nothing is dropped here, not even something this client has no idea how to
/// draw. An unknown component still gets a row with its label and a line saying
/// this client does not render it yet - a form that silently loses half its
/// questions reads as a bot that asked something incoherent, and the user has
/// no way to tell that anything is missing.
ModalField toModalField(BotComponentDto component, int index) {
  final customId = component.customId?.trim() ?? '';
  final label = component.label?.trim() ?? '';
  return ModalField(
    key: '$index:$customId',
    customId: customId,
    label: label.isNotEmpty
        ? label
        : (customId.isNotEmpty ? customId : 'Field ${index + 1}'),
    placeholder: component.placeholder ?? '',
    isRequired: component.isRequired,
    minLength: _bound(component.minLength),
    maxLength: _bound(component.maxLength),
    isParagraph: component.style == _paragraphTextInputStyle,
    initialValue: component.value ?? '',
    // A text input with no custom_id is unanswerable: the bot keys the reply on
    // it, so there is nothing to send the typed value back as.
    isUnsupported:
        component.type != BotComponentType.textInput || customId.isEmpty,
  );
}

/// The reason this field cannot be sent, or null.
///
/// [ModalField.minLength] is only enforced once something has been typed. On an
/// optional field, blank means "not answered" rather than "answered too
/// briefly", and holding a user to a 20-character minimum on a question they
/// are entitled to skip would make the form unsubmittable.
String? validateModalField(ModalField field, String raw) {
  if (field.isRequired && raw.trim().isEmpty) return 'This field is required.';
  if (raw.isEmpty) return null;
  final min = field.minLength;
  if (min != null && raw.length < min) {
    return 'Must be at least $min characters.';
  }
  final max = field.maxLength;
  if (max != null && raw.length > max) {
    return 'Must be at most $max characters.';
  }
  return null;
}

/// Builds the `components` of a modal-submit body.
///
/// A modal answer is not a flat list of inputs: it is one action row per field,
/// each wrapping the single text input it held, and the bot's library reads
/// answers back through that nesting. The server round-trips the array through
/// the same `ComponentPayload` class that produced it, so the keys here are the
/// `[JsonPropertyName]` ones - `custom_id`, not `customId`, which would
/// deserialize to null and hand the bot an answer with no question attached.
///
/// Only `custom_id` and `value` go back. Label, placeholder and the length
/// bounds were the bot's own instructions, and echoing them would invite a bot
/// to trust them as if they had survived a round trip through a client that is
/// free to have ignored them.
///
/// Unsupported components are dropped rather than sent blank: a row the bot
/// cannot key on is worse than a missing row, and one with no `custom_id` is
/// exactly that.
List<Map<String, dynamic>> buildModalSubmitRows(
  List<ModalField> fields,
  Map<String, String> values,
) {
  return [
    for (final field in fields)
      if (!field.isUnsupported)
        {
          'type': BotComponentType.actionRow,
          'components': [
            {
              'type': BotComponentType.textInput,
              'custom_id': field.customId,
              'value': values[field.key] ?? '',
            },
          ],
        },
  ];
}
