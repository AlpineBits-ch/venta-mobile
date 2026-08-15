import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/features/messaging/data/models/embed_dto.dart';
import 'package:venta_mobile/features/messaging/presentation/widgets/message_embeds_view.dart';
import 'package:venta_mobile/features/messaging/presentation/widgets/venta_embed_card.dart';

/// The cards for links back to this instance, and the two things about them that
/// are easy to get wrong in a way nothing complains about.
///
/// **The flag.** A `venta.*` embed without bit 16 was written by whoever posted
/// the message, and a bot can author one carrying any `venta` block it likes. It
/// buys an attacker nothing - every action a card offers runs through an
/// authenticated, permission-checked endpoint - but a card that *looks*
/// server-vouched when it is not is a phishing surface.
///
/// **The wiki stub.** It carries no title and never will: a generated embed is
/// stored once and shown to everyone who can read the channel, while reading a
/// wiki is gated per user and per role, so a server-resolved title would leak a
/// private page's name to whoever the link was forwarded to. The missing title
/// is the feature, and a client that treats it as a broken card gets it exactly
/// backwards.
String _embedsJson(List<Map<String, Object?>> embeds) => jsonEncode(embeds);

const _serverGenerated = 1 << 16;

Map<String, Object?> _inviteEmbed({
  int flags = _serverGenerated,
  String? title = 'Sunday Raid Group',
  Map<String, Object?>? venta,
}) => {
  'type': 'venta.invite',
  'url': 'https://app.venta.gg/invite/ABC23456',
  if (title != null) 'title': title,
  'description': 'Casual mythic+ and too much chatting',
  'flags': flags,
  'fields': <Object?>[],
  'venta':
      venta ??
      {
        'kind': 'invite',
        'resolved': true,
        'invite_code': 'ABC23456',
        'guild_id': 'gild_1',
        'channel_id': 'chan_1',
        'expires_at': '2099-09-01T12:00:00+00:00',
        'max_uses': 25,
      },
};

Map<String, Object?> _wikiEmbed({int flags = _serverGenerated}) => {
  'type': 'venta.wiki_page',
  'url': 'https://app.venta.gg/wiki/gild_1/wkpg_7QZ1MMKTV9',
  'flags': flags,
  'fields': <Object?>[],
  'venta': {
    'kind': 'wiki_page',
    'resolved': false,
    'guild_id': 'gild_1',
    'page_id': 'wkpg_7QZ1MMKTV9',
  },
};

void main() {
  group('the venta block', () {
    test('is read with the snake_case names the wire actually uses', () {
      final embed = parseEmbedsJson(_embedsJson([_inviteEmbed()])).single;

      expect(embed.type, EmbedType.ventaInvite);
      expect(embed.venta?.kind, EmbedVentaKind.invite);
      expect(embed.venta?.inviteCode, 'ABC23456');
      expect(embed.venta?.guildId, 'gild_1');
      expect(embed.venta?.channelId, 'chan_1');
      expect(embed.venta?.maxUses, 25);
      expect(embed.venta?.expiresAt, isNotNull);
    });

    /// The multi-word fields on an embed are snake_case, unlike the camelCase
    /// message fields around them - `embedsJson` is an opaque string produced by
    /// a different serializer. This client read them camel-cased, which meant
    /// `proxy_url` was never populated and every card hot-linked the
    /// third-party origin instead of our proxy: the exact leak `proxy_url`
    /// exists to prevent.
    test('media reads proxy_url, not proxyUrl', () {
      final embed = parseEmbedsJson(
        _embedsJson([
          {
            'type': 'link',
            'title': 'Example',
            'thumbnail': {
              'url': 'https://example.com/hero.png',
              'proxy_url': 'https://api.venta.gg/api/v1/previews/media/abc',
              'width': 1200,
              'height': 630,
              'content_type': 'image/png',
              'placeholder': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
              'placeholder_version': 1,
            },
          },
        ]),
      ).single;

      final media = embed.thumbnail!;
      expect(media.proxyUrl, startsWith('https://api.venta.gg/'));
      expect(media.displayUrl, media.proxyUrl);
      expect(media.contentType, 'image/png');
      expect(media.placeholderVersion, 1);
      expect(media.blurHash, isNotNull);
    });

    test('author and footer icons read icon_url too', () {
      final embed = parseEmbedsJson(
        _embedsJson([
          {
            'type': 'link',
            'author': {
              'name': 'Ada',
              'icon_url': 'https://example.com/a.png',
              'proxy_icon_url': 'https://api.venta.gg/p/a',
            },
            'footer': {
              'text': 'CI',
              'icon_url': 'https://example.com/f.png',
            },
          },
        ]),
      ).single;

      expect(embed.author?.displayIconUrl, 'https://api.venta.gg/p/a');
      expect(embed.footer?.displayIconUrl, 'https://example.com/f.png');
    });
  });

  group('trust', () {
    test('the flag is what makes a card a venta card', () {
      final vouched = parseEmbedsJson(_embedsJson([_inviteEmbed()])).single;
      expect(vouched.isServerVouchedVenta, isTrue);
    });

    /// Without bit 16 the embed is the message author's own, bot or otherwise.
    /// It still renders - as an ordinary card, with its own title and
    /// description - but never with the chrome that says the server vouched for
    /// it.
    test('an unflagged venta.invite is not a venta card', () {
      final embed = parseEmbedsJson(
        _embedsJson([_inviteEmbed(flags: 0)]),
      ).single;

      expect(embed.isVentaType, isTrue);
      expect(embed.isGenerated, isFalse);
      expect(embed.isServerVouchedVenta, isFalse);
    });

    /// A flag on a type with no `venta` block is not a card either - there is
    /// nothing behind it to act on.
    test('a flagged venta type with no block is not a venta card', () {
      final embed = parseEmbedsJson(
        _embedsJson([
          {
            'type': 'venta.invite',
            'title': 'Looks real',
            'flags': _serverGenerated,
          },
        ]),
      ).single;

      expect(embed.venta, isNull);
      expect(embed.isServerVouchedVenta, isFalse);
    });

    /// Discord's own flag bit 5 must not be mistaken for ours, and an embed
    /// carrying both is still ours.
    test('bit 16 is tested for, not the whole field', () {
      final other = parseEmbedsJson(
        _embedsJson([_inviteEmbed(flags: 1 << 5)]),
      ).single;
      expect(other.isServerVouchedVenta, isFalse);

      final both = parseEmbedsJson(
        _embedsJson([_inviteEmbed(flags: _serverGenerated | (1 << 5))]),
      ).single;
      expect(both.isServerVouchedVenta, isTrue);
    });
  });

  group('unknown kinds', () {
    /// A future internal-link kind will arrive before this build is replaced,
    /// and a card drawn from half a contract is worse than no card. Note this
    /// has to be detected from the raw type string: `venta.poll` decodes to
    /// `EmbedType.unknown`, which is otherwise indistinguishable from any other
    /// unrecognised type - and the two want opposite treatment.
    test('a venta kind this build does not know draws nothing', () {
      final embed = parseEmbedsJson(
        _embedsJson([
          {
            'type': 'venta.poll',
            'title': 'Something new',
            'flags': _serverGenerated,
            'venta': {'kind': 'poll', 'resolved': true},
          },
        ]),
      ).single;

      expect(embed.type, EmbedType.unknown);
      expect(embed.rawType, 'venta.poll');
      expect(embed.isVentaType, isTrue);
      expect(embed.isKnownVentaKind, isFalse);
      expect(embed.isUnrecognisedVenta, isTrue);
      expect(embed.isServerVouchedVenta, isFalse);
    });

    /// An unknown *ordinary* type keeps the old behaviour: the link layout
    /// degrades to whatever fields are present, which renders something sane.
    /// Only the namespaced ones are dropped.
    test('an unknown ordinary type still renders', () {
      final embed = parseEmbedsJson(
        _embedsJson([
          {'type': 'poll', 'title': 'Something new'},
        ]),
      ).single;

      expect(embed.type, EmbedType.unknown);
      expect(embed.isVentaType, isFalse);
      expect(embed.isUnrecognisedVenta, isFalse);
      expect(embed.isEmpty, isFalse);
    });

    testWidgets('and the view drops it rather than drawing a link card', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageEmbedsView(
              embeds: parseEmbedsJson(
                _embedsJson([
                  {
                    'type': 'venta.poll',
                    'title': 'Should not be drawn',
                    'flags': _serverGenerated,
                    'venta': {'kind': 'poll'},
                  },
                ]),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Should not be drawn'), findsNothing);
    });
  });

  group('the wiki stub', () {
    /// No title, no description, and it is still a card worth drawing. The
    /// generic `isEmpty` check would otherwise throw it away for having nothing
    /// on it, which is precisely the shape the server promises to send.
    test('a titleless wiki stub is not an empty embed', () {
      final embed = parseEmbedsJson(_embedsJson([_wikiEmbed()])).single;

      expect(embed.title, isNull);
      expect(embed.description, isNull);
      expect(embed.venta?.resolved, isFalse);
      expect(embed.venta?.pageId, 'wkpg_7QZ1MMKTV9');
      expect(embed.isServerVouchedVenta, isTrue);
      expect(
        embed.isEmpty,
        isFalse,
        reason: 'the missing title is the contract, not a broken card',
      );
    });

    /// The same card *without* the flag has nothing on it at all and genuinely
    /// is empty, so the ordinary rule applies again.
    test('an unvouched titleless stub is empty like any other', () {
      final embed = parseEmbedsJson(
        _embedsJson([_wikiEmbed(flags: 0)]),
      ).single;

      expect(embed.isServerVouchedVenta, isFalse);
      expect(embed.isEmpty, isTrue);
    });
  });

  group('rendering', () {
    Future<void> pump(WidgetTester tester, List<Map<String, Object?>> embeds) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MessageEmbedsView(
                  embeds: parseEmbedsJson(_embedsJson(embeds)),
                ),
              ),
            ),
          ),
        );

    testWidgets('an invite card names the guild and offers a join', (
      tester,
    ) async {
      await pump(tester, [_inviteEmbed()]);

      expect(tester.takeException(), isNull);
      expect(find.byType(VentaEmbedCard), findsOneWidget);
      expect(find.text('Sunday Raid Group'), findsOneWidget);
      expect(find.text('Join'), findsOneWidget);
    });

    /// `expires_at` is frozen into the card and stays correct forever - an
    /// absolute instant does not go stale the way "expired" does - so this is
    /// the one piece of validity the card can answer with no request at all.
    testWidgets('an invite past its expiry says so and offers no join', (
      tester,
    ) async {
      await pump(tester, [
        _inviteEmbed(
          venta: {
            'kind': 'invite',
            'resolved': true,
            'invite_code': 'ABC23456',
            'guild_id': 'gild_1',
            'expires_at': '2020-01-01T00:00:00+00:00',
          },
        ),
      ]);

      expect(tester.takeException(), isNull);
      expect(find.text('This invite has expired.'), findsOneWidget);
      expect(find.text('Join'), findsNothing);
    });

    testWidgets('an invite with no expiry never lapses on its own', (
      tester,
    ) async {
      await pump(tester, [
        _inviteEmbed(
          venta: {
            'kind': 'invite',
            'resolved': true,
            'invite_code': 'ABC23456',
            'guild_id': 'gild_1',
          },
        ),
      ]);

      expect(find.text('This invite has expired.'), findsNothing);
      expect(find.text('Join'), findsOneWidget);
    });

    /// `title` and `description` on an invite card are typed by a guild's
    /// owner - server-relayed, not server-authored - so they are rendered as
    /// plain text like every other embed string, never through Markdown.
    testWidgets('owner-typed text is rendered as text', (tester) async {
      await pump(tester, [
        _inviteEmbed(title: '[click me](https://evil.example)'),
      ]);

      expect(tester.takeException(), isNull);
      expect(find.text('[click me](https://evil.example)'), findsOneWidget);
    });

    testWidgets('an invite with no title still draws a card', (tester) async {
      await pump(tester, [_inviteEmbed(title: null)]);

      expect(tester.takeException(), isNull);
      expect(find.byType(VentaEmbedCard), findsOneWidget);
    });

    /// The placeholder goes up immediately. The name is filled in per viewer
    /// from the permission-checked endpoint, and a `403` or a `404` keeps the
    /// placeholder - never "this page is private" or "this page was deleted",
    /// because the stub is deliberately silent about which.
    testWidgets('a wiki stub draws a neutral placeholder with no title', (
      tester,
    ) async {
      clearVentaWikiTitleCache();
      await pump(tester, [_wikiEmbed()]);

      expect(tester.takeException(), isNull);
      expect(find.byType(VentaEmbedCard), findsOneWidget);
      expect(find.text('Wiki page'), findsOneWidget);
      expect(find.textContaining('private'), findsNothing);
      expect(find.textContaining('deleted'), findsNothing);
    });

    testWidgets('an unflagged venta embed falls back to the ordinary card', (
      tester,
    ) async {
      await pump(tester, [_inviteEmbed(flags: 0)]);

      expect(tester.takeException(), isNull);
      expect(find.byType(VentaEmbedCard), findsNothing);
      // It is still the author's embed and still renders its own content -
      // just with none of the chrome that claims the server vouched for it.
      expect(find.text('Sunday Raid Group'), findsOneWidget);
      expect(find.text('Join'), findsNothing);
    });
  });
}
