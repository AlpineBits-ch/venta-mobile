/// Pins the `guild.ModalOpen` wire format and the modal-submit body.
///
/// Worth having as tests rather than as a comment because neither end of this
/// can be exercised by hand: it takes a bot that answers a slash command with a
/// modal to see any of it, and the two shapes are the part that fails silently
/// when they are wrong - a mis-cased `custom_id` decodes to null and produces a
/// form with an unanswerable field, and a mis-cased submit key produces a `202`
/// that hands the bot an answer with no question attached.
///
/// The expectations here are the same ones Alpine's
/// `bot-modal-dialog.component.spec.ts` asserts, deliberately: the two clients
/// are talking to the same endpoint and a divergence between them is a bug in
/// whichever one moved.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/features/bots/data/models/bot_modal_dtos.dart';
import 'package:venta_mobile/features/bots/presentation/bot_modal_field.dart';

void main() {
  test('reads the wire names the server actually sends', () {
    final dto = BotModalOpenDto.fromJson({
      'guildId': 'gild_1',
      'channelId': 'chan_1',
      'botUserId': 'bot_1',
      'customId': 'feedback-modal',
      'title': 'Feedback',
      'components': [
        {
          'type': 1,
          'components': [
            {
              'type': 4,
              'custom_id': 'summary',
              'label': 'What happened?',
              'placeholder': 'Describe it',
              'value': 'prefilled',
              'required': true,
              'min_length': 5,
              'max_length': 200,
              'style': 2,
            },
          ],
        },
      ],
    });

    expect(dto.isAnswerable, isTrue);
    final fields = flattenModalRows(
      dto.components,
    ).indexed.map((e) => toModalField(e.$2, e.$1)).toList();
    expect(fields.length, 1);
    final f = fields.single;
    expect(f.key, '0:summary');
    expect(f.customId, 'summary');
    expect(f.label, 'What happened?');
    expect(f.placeholder, 'Describe it');
    expect(f.isRequired, isTrue);
    expect(f.minLength, 5);
    expect(f.maxLength, 200);
    expect(f.isParagraph, isTrue);
    expect(f.initialValue, 'prefilled');
    expect(f.isUnsupported, isFalse);
  });

  test('tolerates a PascalCase envelope and camelCase components', () {
    final dto = BotModalOpenDto.fromJson({
      'GuildId': 'g',
      'ChannelId': 'c',
      'BotUserId': 'b',
      'CustomId': 'k',
      'Title': 'T',
      'Components': [
        {
          'type': 1,
          'components': [
            {'type': 4, 'customId': 'a', 'minLength': 3, 'maxLength': 9},
          ],
        },
      ],
    });
    expect(dto.guildId, 'g');
    expect(dto.channelId, 'c');
    expect(dto.botUserId, 'b');
    expect(dto.customId, 'k');
    expect(dto.title, 'T');
    final f = toModalField(flattenModalRows(dto.components).single, 0);
    expect(f.customId, 'a');
    expect(f.minLength, 3);
    expect(f.maxLength, 9);
  });

  test('unsupported / nonsense bounds / label fallbacks', () {
    expect(
      toModalField(
        const BotComponentDto(type: 2, customId: 'press', label: 'Press'),
        0,
      ).isUnsupported,
      isTrue,
    );
    expect(
      toModalField(
        const BotComponentDto(type: 4, label: 'Nameless'),
        0,
      ).isUnsupported,
      isTrue,
    );
    expect(
      toModalField(const BotComponentDto(type: 4, customId: 'x'), 0).label,
      'x',
    );
    expect(
      toModalField(const BotComponentDto(type: 4, customId: ''), 2).label,
      'Field 3',
    );
    final bounded = toModalField(
      const BotComponentDto(
        type: 4,
        customId: 's',
        minLength: -3,
        maxLength: 0,
      ),
      0,
    );
    expect(bounded.minLength, isNull);
    expect(bounded.maxLength, isNull);
  });

  test('flatten stops following a self-nesting payload', () {
    // Cannot build a true cycle out of an immutable tree, so this is the
    // deep-nesting case the depth limit actually guards.
    var node = const BotComponentDto(type: 4, customId: 'deep');
    for (var i = 0; i < 10; i++) {
      node = BotComponentDto(type: 1, components: [node]);
    }
    expect(flattenModalRows([node]), isEmpty);
  });

  test('validation', () {
    const req = ModalField(
      key: 'k',
      customId: 'c',
      label: 'L',
      placeholder: '',
      isRequired: true,
      minLength: null,
      maxLength: null,
      isParagraph: false,
      initialValue: '',
      isUnsupported: false,
    );
    expect(validateModalField(req, '   '), 'This field is required.');
    expect(validateModalField(req, 'x'), isNull);

    const minOnly = ModalField(
      key: 'k',
      customId: 'c',
      label: 'L',
      placeholder: '',
      isRequired: false,
      minLength: 10,
      maxLength: null,
      isParagraph: false,
      initialValue: '',
      isUnsupported: false,
    );
    expect(validateModalField(minOnly, ''), isNull);
    expect(
      validateModalField(minOnly, 'short'),
      'Must be at least 10 characters.',
    );

    const maxOnly = ModalField(
      key: 'k',
      customId: 'c',
      label: 'L',
      placeholder: '',
      isRequired: false,
      minLength: null,
      maxLength: 3,
      isParagraph: false,
      initialValue: '',
      isUnsupported: false,
    );
    expect(
      validateModalField(maxOnly, 'abcd'),
      'Must be at most 3 characters.',
    );
    expect(validateModalField(maxOnly, 'abc'), isNull);
  });

  test('submit rows match Alpine exactly', () {
    final fields = [
      toModalField(const BotComponentDto(type: 4, customId: 'a'), 0),
      toModalField(const BotComponentDto(type: 4, customId: 'b'), 1),
    ];
    expect(buildModalSubmitRows(fields, {'0:a': 'first', '1:b': 'second'}), [
      {
        'type': 1,
        'components': [
          {'type': 4, 'custom_id': 'a', 'value': 'first'},
        ],
      },
      {
        'type': 1,
        'components': [
          {'type': 4, 'custom_id': 'b', 'value': 'second'},
        ],
      },
    ]);

    final withUnsupported = [
      toModalField(const BotComponentDto(type: 2, customId: 'press'), 0),
      toModalField(const BotComponentDto(type: 4, customId: 'b'), 1),
    ];
    expect(buildModalSubmitRows(withUnsupported, {'1:b': 'second'}), [
      {
        'type': 1,
        'components': [
          {'type': 4, 'custom_id': 'b', 'value': 'second'},
        ],
      },
    ]);

    expect(
      buildModalSubmitRows([
        toModalField(const BotComponentDto(type: 4, customId: 'a'), 0),
      ], {}),
      [
        {
          'type': 1,
          'components': [
            {'type': 4, 'custom_id': 'a', 'value': ''},
          ],
        },
      ],
    );
  });

  test('unanswerable payloads', () {
    expect(
      const BotModalOpenDto(guildId: 'g', customId: null).isAnswerable,
      isFalse,
    );
    expect(
      const BotModalOpenDto(guildId: null, customId: 'k').isAnswerable,
      isFalse,
    );
    expect(
      const BotModalOpenDto(guildId: 'g', customId: '  ').isAnswerable,
      isFalse,
    );
  });
}
