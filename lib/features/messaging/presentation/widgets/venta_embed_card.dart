import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../invites/presentation/widgets/invite_dialog.dart';
import '../../../wiki/data/wiki_repository.dart';
import '../../data/models/embed_dto.dart';
import 'message_link_launcher.dart';

/// The cards for links that point back at this instance: guild invites and wiki
/// pages.
///
/// These used to be found by the client. `thread_view.dart` carried an invite
/// regex and rendered its own tile from whatever it matched; the server now
/// recognises its own links by host, resolves them in-process and ships an
/// ordinary embed carrying the ids behind the card. Finding the link is the
/// part that went away - what is left is drawing what arrived.
///
/// **Only ever built for an embed the server vouched for**
/// ([EmbedDtoX.isServerVouchedVenta]). Without bit 16 the embed was written by
/// whoever posted the message, and a bot can author one carrying any `venta`
/// block it likes; such an embed still renders, but through the ordinary card,
/// with none of the chrome below that says "this is a real invite".
class VentaEmbedCard extends StatelessWidget {
  const VentaEmbedCard({super.key, required this.embed});

  final EmbedDto embed;

  @override
  Widget build(BuildContext context) {
    final venta = embed.venta;
    if (venta == null) return const SizedBox.shrink();

    return switch (venta.kind) {
      EmbedVentaKind.invite => _VentaInviteCard(embed: embed, venta: venta),
      EmbedVentaKind.wikiPage => _VentaWikiCard(embed: embed, venta: venta),
      // Unreachable - the view filters an unrecognised kind out before it gets
      // here - but a half-drawn card is worse than no card, so it is nothing
      // here too.
      EmbedVentaKind.unknown => const SizedBox.shrink(),
    };
  }
}

/// The shared frame: a glyph, a body, and a tap target.
class _VentaFrame extends StatelessWidget {
  const _VentaFrame({
    required this.icon,
    required this.child,
    this.onTap,
    this.action,
  });

  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxVentaCardWidth),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s + 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: _glyphSize,
                  height: _glyphSize,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(child: child),
                if (action != null) ...[
                  const SizedBox(width: AppSpacing.s),
                  action!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A guild invite somebody pasted into the channel.
///
/// `title` is the guild's name and `description` its description, both **typed
/// by a guild's owner**. Server-relayed, not server-authored - so they are
/// rendered as plain [Text] like every other embed string here, never through
/// Markdown.
class _VentaInviteCard extends StatelessWidget {
  const _VentaInviteCard({required this.embed, required this.venta});

  final EmbedDto embed;
  final EmbedVentaDto venta;

  /// The one volatile field the card can answer without a request.
  ///
  /// A generated embed is frozen at post time and does not learn that the
  /// invite was later revoked or exhausted - but an absolute instant does not
  /// go stale the way "expired" does, so comparing it to the clock at render
  /// time is right forever. Everything else about the invite's validity is
  /// deliberately not carried and is left to the redeem call to discover.
  bool get _lapsed {
    final expiresAt = venta.expiresAt;
    return expiresAt != null && expiresAt.isBefore(DateTime.now().toUtc());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final code = venta.inviteCode;
    final name = embed.title?.trim();
    final description = embed.description?.trim();

    void open() {
      if (code == null || code.isEmpty) return;
      showDialog<void>(
        context: context,
        builder: (_) => InviteDialog(code: code),
      );
    }

    return _VentaFrame(
      icon: Icons.groups_outlined,
      onTap: _lapsed ? null : open,
      action: _lapsed
          ? null
          : TextButton(onPressed: open, child: const Text('Join')),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Invite to join a server',
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
          Text(
            name == null || name.isEmpty ? 'A server' : name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (description != null && description.isNotEmpty)
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          if (_lapsed)
            Text(
              'This invite has expired.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }
}

/// A wiki page. Deliberately a stub until this particular reader fills it in.
///
/// **The server sends no title and never will.** A generated embed is stored
/// once on the message and shown to everyone who can read the channel, with no
/// per-viewer variant - while reading a wiki is gated on `ViewWiki` per user and
/// per role, which being able to read the message does not imply. A
/// server-resolved title would therefore leak a private page's name to whoever
/// the link was forwarded to, permanently, in a row nobody can revoke. The
/// missing title is the feature.
///
/// So the card draws a neutral placeholder immediately and asks the
/// permission-checked endpoint for the name on this reader's behalf. A `403` or
/// a `404` keeps the placeholder and says nothing about which - the stub is
/// deliberately silent about whether the page is private or gone, and so is
/// this.
class _VentaWikiCard extends StatefulWidget {
  const _VentaWikiCard({required this.embed, required this.venta});

  final EmbedDto embed;
  final EmbedVentaDto venta;

  @override
  State<_VentaWikiCard> createState() => _VentaWikiCardState();
}

class _VentaWikiCardState extends State<_VentaWikiCard> {
  String? _title;

  @override
  void initState() {
    super.initState();
    _resolveTitle();
  }

  /// Fills the name in for this viewer, at most once per page per session.
  ///
  /// The cache is what keeps this from being the per-message-on-render fetch
  /// the old client-side wiki card did - the same page linked in twenty
  /// messages costs one request, and a card scrolled past and back costs none.
  Future<void> _resolveTitle() async {
    final guildId = widget.venta.guildId;
    final pageId = widget.venta.pageId;
    if (guildId == null || pageId == null) return;

    final cached = _titleCache[pageId];
    if (cached != null) {
      setState(() => _title = cached);
      return;
    }

    try {
      final page = await getIt<WikiRepository>().getPage(guildId, pageId);
      final title = page.title.trim();
      if (title.isEmpty) return;
      _titleCache[pageId] = title;
      if (mounted) setState(() => _title = title);
    } catch (_) {
      // 403 (this reader may not see the page), 404 (deleted, or never real),
      // or the network. All three keep the placeholder: turning any of them
      // into "this page is private" or "this page was deleted" would say the
      // thing the stub exists not to say.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final title = _title;

    final guildId = widget.venta.guildId;
    final pageId = widget.venta.pageId;

    return _VentaFrame(
      icon: Icons.menu_book_outlined,
      // Composed from the ids in the `venta` block against our own route table,
      // not from a URL the payload handed us. The block deliberately carries no
      // endpoint to call, precisely so that a bot-authored embed cannot choose
      // where this client points itself.
      onTap: (guildId == null || pageId == null)
          ? () => openMessageLink(context, widget.embed.url)
          : () => context.push(RoutePaths.serverWikiPagePath(guildId, pageId)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Wiki page',
            style: theme.textTheme.labelSmall?.copyWith(color: muted),
          ),
          Text(
            title ?? widget.embed.url ?? 'A page in this server\'s wiki',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Page id to title, for this app session. Not invalidated on a rename: a
  /// stale card title costs nothing, and the wiki screen itself is the
  /// authority once the reader opens it.
  static final _titleCache = <String, String>{};

  @visibleForTesting
  static void clearTitleCache() => _titleCache.clear();
}

/// Test seam for the per-session wiki title cache.
@visibleForTesting
void clearVentaWikiTitleCache() => _VentaWikiCardState.clearTitleCache();

const _maxVentaCardWidth = 400.0;
const _glyphSize = 40.0;
