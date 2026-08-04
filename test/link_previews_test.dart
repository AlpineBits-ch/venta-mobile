import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:venta_mobile/core/sound/sound_service.dart';
import 'package:venta_mobile/features/messaging/bloc/message_thread_bloc.dart';
import 'package:venta_mobile/features/messaging/data/message_repository.dart';
import 'package:venta_mobile/features/messaging/data/models/embed_dto.dart';
import 'package:venta_mobile/features/messaging/data/models/message_dto.dart';
import 'package:venta_mobile/features/messaging/presentation/widgets/message_embeds_view.dart';
import 'package:venta_mobile/features/privacy/data/privacy_repository.dart';

/// Link previews, and specifically the three places the feature is easy to get
/// wrong in a way nothing complains about:
///
/// * a preview arrives *after* its message, as an update carrying no body - so
///   applying it must not disturb the text or the edit marker;
/// * `updatedAt` moves for a preview and a pin, so an "(edited)" marker driven
///   off it labels every message containing a link as edited by nobody;
/// * every string on a card came off a stranger's page, so a malformed one has
///   to degrade rather than throw out of a `build`.
class _MockMessageRepository extends Mock implements MessageRepository {}

class _MockSoundService extends Mock implements SoundService {}

class _MockPrivacyRepository extends Mock implements PrivacyRepository {}

const _messageId = 'msg-1';

/// One `link` card, as the server encodes it: a JSON string, not an object.
String _embedsJson({String title = 'Example Domain'}) => jsonEncode([
  {
    'type': 'link',
    'title': title,
    'description': 'An illustrative example.',
    'url': 'https://example.com',
    'provider': {'name': 'example.com'},
    'thumbnail': {
      'url': 'https://example.com/hero.png',
      'proxyUrl': 'https://api.venta.gg/api/v1/previews/media/abc123',
      'width': 1200,
      'height': 630,
      'placeholder': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      'placeholderVersion': 1,
    },
    'flags': 1 << 16,
  },
]);

void main() {
  group('parseEmbedsJson', () {
    test('reads the server\'s JSON-encoded string, not a nested object', () {
      final embeds = parseEmbedsJson(_embedsJson());

      expect(embeds, hasLength(1));
      expect(embeds.single.type, EmbedType.link);
      expect(embeds.single.title, 'Example Domain');
      expect(embeds.single.provider?.name, 'example.com');
      expect(embeds.single.thumbnail?.width, 1200);
      expect(embeds.single.isGenerated, isTrue);
    });

    test('null, empty and malformed all degrade to no cards', () {
      // A card is decoration; a message whose embeds won't parse still has to
      // render its text, so none of these may throw.
      expect(parseEmbedsJson(null), isEmpty);
      expect(parseEmbedsJson(''), isEmpty);
      expect(parseEmbedsJson('not json at all'), isEmpty);
      expect(parseEmbedsJson('{"not":"a list"}'), isEmpty);
    });

    test('an unknown embed type still renders as a card', () {
      // The layout falls back rather than the whole embed disappearing - a
      // future type is a card whose shape we don't know, not a card that
      // shouldn't exist.
      final embeds = parseEmbedsJson(
        jsonEncode([
          {'type': 'poll', 'title': 'Something new'},
        ]),
      );

      expect(embeds.single.type, EmbedType.unknown);
      expect(embeds.single.title, 'Something new');
      expect(embeds.single.isEmpty, isFalse);
    });

    test('the same JSON parses to the same list, memoised', () {
      // The timeline re-reads this for every visible row on every frame of a
      // scroll; re-parsing per row per frame is what this avoids.
      final json = _embedsJson();
      expect(identical(parseEmbedsJson(json), parseEmbedsJson(json)), isTrue);
    });
  });

  group('embed media', () {
    test('the proxy wins over the origin', () {
      // Rendering `url` hands a third-party origin the IP address and read
      // time of everyone who scrolls past a link one other person posted.
      final media = parseEmbedsJson(_embedsJson()).single.thumbnail!;

      expect(media.displayUrl, startsWith('https://api.venta.gg/'));
    });

    test('falls back to the origin only when there is no proxy', () {
      const media = EmbedMediaDto(url: 'https://example.com/hero.png');
      expect(media.displayUrl, 'https://example.com/hero.png');
    });

    test('an empty string is not a URL', () {
      const media = EmbedMediaDto(url: '', proxyUrl: '');
      expect(media.displayUrl, isNull);
    });

    test('a placeholder in an unrecognised encoding is not decoded', () {
      // Version 2 would be a string of exactly the right shape and entirely
      // the wrong meaning - handing it to a BlurHash decoder produces noise,
      // not an error.
      const hash = 'LEHV6nWB2yk8pyo0adR*.7kCMdnj';
      expect(
        const EmbedMediaDto(placeholder: hash, placeholderVersion: 1).blurHash,
        hash,
      );
      expect(
        const EmbedMediaDto(placeholder: hash, placeholderVersion: 2).blurHash,
        isNull,
      );
      expect(const EmbedMediaDto(placeholder: hash).blurHash, isNull);
    });

    test('space is only reserved when the server measured both sides', () {
      expect(
        const EmbedMediaDto(width: 1200, height: 630).aspectRatio,
        1200 / 630,
      );
      expect(const EmbedMediaDto(width: 1200).aspectRatio, isNull);
      expect(const EmbedMediaDto(width: 0, height: 0).aspectRatio, isNull);
    });
  });

  group('message flags', () {
    test('bit 2 separates "dismissed" from "never had one"', () {
      const suppressed = MessageDto(
        id: _messageId,
        content: '',
        authorId: 'u',
        flags: 4,
      );
      const plain = MessageDto(id: _messageId, content: '', authorId: 'u');

      expect(suppressed.hasSuppressedEmbeds, isTrue);
      expect(plain.hasSuppressedEmbeds, isFalse);
    });

    test('"(edited)" comes from editedAt, never updatedAt', () {
      // The specific bug this split exists to prevent: `updatedAt` also moves
      // when a preview attaches, so driving the marker off it labels every
      // message containing a link as edited a second after it was posted.
      final previewAttached = MessageDto(
        id: _messageId,
        content: '',
        authorId: 'u',
        updatedAt: DateTime.utc(2026, 8, 4, 12),
      );
      final actuallyEdited = previewAttached.copyWith(
        editedAt: DateTime.utc(2026, 8, 4, 12, 5),
      );

      expect(previewAttached.isEdited, isFalse);
      expect(actuallyEdited.isEdited, isTrue);
    });
  });

  group('the card itself', () {
    Future<void> pump(WidgetTester tester, String embedsJson) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MessageEmbedsView(embeds: parseEmbedsJson(embedsJson)),
              ),
            ),
          ),
        );

    testWidgets('a rich card with fields lays out', (tester) async {
      // The fields grid measures itself against the available width, and a
      // widget that measures cannot be asked for an intrinsic height - which
      // is what a stretched accent bar would have required. This is the test
      // that catches putting one back.
      await pump(
        tester,
        jsonEncode([
          {
            'type': 'rich',
            'title': 'Build #482',
            'description': 'Deployed to production.',
            'color': '#5865f2',
            'fields': [
              {'name': 'Branch', 'value': 'main', 'inline': true},
              {'name': 'Duration', 'value': '4m 12s', 'inline': true},
              {'name': 'Commit', 'value': 'Fix the thing', 'inline': false},
            ],
            'footer': {'text': 'CI'},
          },
        ]),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Build #482'), findsOneWidget);
      expect(find.text('4m 12s'), findsOneWidget);
      expect(find.text('CI'), findsOneWidget);
    });

    testWidgets('a card with only a URL and a provider still renders', (
      tester,
    ) async {
      // Every field comes off a third-party page that may have supplied
      // nothing at all, so this is a valid card and not an empty one.
      await pump(
        tester,
        jsonEncode([
          {
            'type': 'link',
            'url': 'https://example.com',
            'provider': {'name': 'example.com'},
          },
        ]),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('example.com'), findsOneWidget);
    });

    testWidgets('a malformed accent colour does not take the card down', (
      tester,
    ) async {
      await pump(
        tester,
        jsonEncode([
          {'type': 'link', 'title': 'Odd', 'color': 'rebeccapurple'},
        ]),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Odd'), findsOneWidget);
    });

    testWidgets('a card with nothing on it draws nothing', (tester) async {
      await pump(
        tester,
        jsonEncode([
          {'type': 'link'},
        ]),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(ClipRRect), findsNothing);
    });
  });

  group('a preview landing on an open thread', () {
    late _MockMessageRepository repository;
    late StreamController<MessageRepositoryEvent> events;

    MessageThreadBloc buildBloc(MessageDto seed) {
      events = StreamController<MessageRepositoryEvent>.broadcast();
      repository = _MockMessageRepository();
      when(() => repository.events).thenAnswer((_) => events.stream);
      when(() => repository.fetchPage()).thenAnswer((_) async => [seed]);
      when(() => repository.updateLastRead(any())).thenAnswer((_) async {});
      when(
        () => repository.setEmbedsSuppressed(
          messageId: any(named: 'messageId'),
          suppress: any(named: 'suppress'),
        ),
      ).thenAnswer((_) async {});

      final privacy = _MockPrivacyRepository();
      when(() => privacy.shouldRenderTypingIndicators).thenReturn(true);

      return MessageThreadBloc(
        repository: repository,
        myUserId: 'me',
        soundService: _MockSoundService(),
        privacy: privacy,
      );
    }

    final seed = MessageDto(
      id: _messageId,
      // Base64 of "look: https://example.com", the shape the wire uses.
      content: base64Encode(utf8.encode('look: https://example.com')),
      authorId: 'me',
      createdAt: DateTime.utc(2026, 8, 4, 12),
    );

    test(
      'attaches the card without touching the text or the edit marker',
      () async {
        final bloc = buildBloc(seed);
        bloc.add(const ThreadOpened());
        await bloc.stream.firstWhere((s) => !s.isLoadingInitial);

        // The update the author did not cause: no body, just the cards.
        events.add(
          RemoteMessageUpdated(
            messageId: _messageId,
            embedsJson: _embedsJson(),
            flags: 0,
            isAuthorEdit: false,
          ),
        );
        final updated = await bloc.stream.firstWhere(
          (s) => s.messages.single.embeds.isNotEmpty,
        );

        final message = updated.messages.single;
        expect(message.content, seed.content, reason: 'body must be untouched');
        expect(message.isEdited, isFalse, reason: 'nobody edited this');
        expect(message.embeds.single.title, 'Example Domain');

        await bloc.close();
        await events.close();
      },
    );

    test('a real edit still moves the text and sets the marker', () async {
      final bloc = buildBloc(seed);
      bloc.add(const ThreadOpened());
      await bloc.stream.firstWhere((s) => !s.isLoadingInitial);

      final editedAt = DateTime.utc(2026, 8, 4, 12, 5);
      events.add(
        RemoteMessageUpdated(
          messageId: _messageId,
          content: base64Encode(utf8.encode('actually, never mind')),
          editedAt: editedAt,
        ),
      );
      final updated = await bloc.stream.firstWhere(
        (s) => s.messages.single.isEdited,
      );

      expect(
        utf8.decode(base64Decode(updated.messages.single.content)),
        'actually, never mind',
      );
      expect(updated.messages.single.editedAt, editedAt);

      await bloc.close();
      await events.close();
    });

    test('dismissing a preview drops the cards and sets the flag', () async {
      final bloc = buildBloc(seed.copyWith(embedsJson: _embedsJson()));
      bloc.add(const ThreadOpened());
      await bloc.stream.firstWhere((s) => !s.isLoadingInitial);

      bloc.add(const MessageEmbedsSuppressionToggled(_messageId));
      final suppressed = await bloc.stream.firstWhere(
        (s) => s.messages.single.hasSuppressedEmbeds,
      );

      expect(suppressed.messages.single.embeds, isEmpty);
      verify(
        () => repository.setEmbedsSuppressed(
          messageId: _messageId,
          suppress: true,
        ),
      ).called(1);

      await bloc.close();
      await events.close();
    });

    test('a refused dismissal puts the card back', () async {
      // The server answers 403 for anyone who is neither the author nor a
      // holder of `DeleteAnyMessage`. Leaving the card hidden would make a
      // refusal look like it worked.
      final bloc = buildBloc(seed.copyWith(embedsJson: _embedsJson()));
      bloc.add(const ThreadOpened());
      await bloc.stream.firstWhere((s) => !s.isLoadingInitial);

      when(
        () => repository.setEmbedsSuppressed(
          messageId: any(named: 'messageId'),
          suppress: any(named: 'suppress'),
        ),
      ).thenThrow(Exception('403'));

      bloc.add(const MessageEmbedsSuppressionToggled(_messageId));
      final restored = await bloc.stream.firstWhere(
        (s) =>
            !s.messages.single.hasSuppressedEmbeds &&
            s.messages.single.embeds.isNotEmpty,
      );

      expect(restored.messages.single.embeds, hasLength(1));

      await bloc.close();
      await events.close();
    });
  });
}
