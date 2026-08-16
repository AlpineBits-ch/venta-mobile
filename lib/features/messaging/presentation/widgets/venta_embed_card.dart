import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guild_voice/bloc/guild_voice_cubit.dart';
import '../../../guild_voice/bloc/voice_ring_cubit.dart';
import '../../../invites/presentation/widgets/invite_dialog.dart';
import '../../../wiki/data/wiki_repository.dart';
import '../../data/models/embed_dto.dart';
import 'message_link_launcher.dart';

/// The cards for links that point back at this instance: guild invites, wiki
/// pages and voice-channel invitations.
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
      EmbedVentaKind.voiceInvite => _VentaVoiceInviteCard(
        embed: embed,
        venta: venta,
      ),
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

/// "Come and join me in here", left in the conversation after the ring itself
/// is gone.
///
/// **Why this exists when there is already a ring card.** `VoiceRingCard` is the
/// live toast: it appears the moment somebody rings, counts down, and is gone
/// inside a minute whether or not anyone looked. This is the durable half - a
/// message the server writes into the two people's DM - and it is read for as
/// long as the conversation exists. Most of the time it is already history by
/// the time anybody sees it, which is why the expired state is the interesting
/// one rather than an edge case.
///
/// **Purely presentational, like the other venta cards.** Everything it draws is
/// on the embed; there is no fetch on mount and no loading state. The view has
/// already checked the server-generated flag ([EmbedDtoX.isServerVouchedVenta]),
/// which is what makes the identifiers below safe to act on - without it a bot
/// could author an embed carrying any `venta` block it liked and get a card that
/// looks server-vouched.
class _VentaVoiceInviteCard extends StatefulWidget {
  const _VentaVoiceInviteCard({required this.embed, required this.venta});

  final EmbedDto embed;
  final EmbedVentaDto venta;

  @override
  State<_VentaVoiceInviteCard> createState() => _VentaVoiceInviteCardState();
}

class _VentaVoiceInviteCardState extends State<_VentaVoiceInviteCard> {
  /// Flipped by the timer below, so a card that is live when drawn stops being
  /// live in place rather than only on the next rebuild.
  bool _lapsed = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncLapse();
  }

  @override
  void didUpdateWidget(covariant _VentaVoiceInviteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The embed is replaced wholesale when a `MessageUpdated` lands, so the
    // deadline can change under a card that is already on screen.
    if (oldWidget.venta.expiresAt != widget.venta.expiresAt) {
      setState(_syncLapse);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Compares the deadline against this machine's clock and, when it is close
  /// enough to be worth waiting for, arms a timer to flip the card in place.
  ///
  /// The comparison is made at render time rather than trusted as a stored
  /// state: an absolute instant stays right forever, whereas a boolean written
  /// at post time would have been wrong within the minute.
  void _syncLapse() {
    _timer?.cancel();
    _timer = null;

    final expiresAt = widget.venta.expiresAt;
    if (expiresAt == null) {
      // A standing invitation - see [_standing]. Nothing to count down.
      _lapsed = false;
      return;
    }

    final remaining = expiresAt.difference(DateTime.now().toUtc());
    if (remaining <= Duration.zero) {
      _lapsed = true;
      return;
    }

    _lapsed = false;
    // A ring lives sixty seconds. A card claiming to expire in an hour means
    // the sender's clock or ours is wrong, and holding a timer open for it
    // would pin this row alive for that long to flip a state nobody is still
    // looking at. Such a card just renders live until it is scrolled past.
    if (remaining > _maxLapseTimer) return;
    _timer = Timer(remaining, () {
      if (mounted) setState(() => _lapsed = true);
    });
  }

  /// An invitation that was never a ring, and therefore never expires.
  ///
  /// **The distinction that "no ring id" alone cannot make.** A card sent as a
  /// plain message rather than as a ring carries neither, and reading that as
  /// "lapsed" would stamp "this invitation has expired" on one that was valid
  /// the second it arrived - and stays valid. The absence of an expiry is the
  /// signal; a card that *had* one and is past it is the genuinely lapsed case.
  bool get _standing => widget.venta.expiresAt == null;

  /// Whether the ring can still be accepted.
  bool get _live =>
      !_lapsed && !_standing && (widget.venta.ringId?.isNotEmpty ?? false);

  /// Accepts the ring, which closes the invitation and then joins.
  ///
  /// **Two calls, in that order, and the second one is not made here.**
  /// Accepting closes the invitation and hands back the channel's coordinates;
  /// `AppShell` listens for [VoiceRingState.acceptedChannel] and makes the
  /// ordinary join call, which already handles device resolution, media
  /// negotiation and leaving whatever channel you were in. There is deliberately
  /// no second join path.
  ///
  /// Only reachable while [_live]. Past the expiry the ring no longer exists and
  /// this would answer `409` - [_joinAnyway] is the honest affordance there.
  void _accept() {
    final ringId = widget.venta.ringId;
    if (ringId == null || ringId.isEmpty || !_live) return;
    unawaited(getIt<VoiceRingCubit>().accept(ringId));
  }

  /// Walks into the channel without answering anything.
  ///
  /// What an expired card offers, and deliberately not dressed up as accepting
  /// a minute-old invitation. It is the same join as tapping the channel in the
  /// list, subject to the same permission check - so it correctly fails for
  /// somebody who has since lost access.
  void _joinAnyway() {
    final guildId = widget.venta.guildId;
    final channelId = widget.venta.channelId;
    if (guildId == null || channelId == null) return;

    // The embed names the channel; the guild cache is the fallback for the name
    // and is the only source for the guild's own, and an empty label is better
    // than holding the join up to go and look one up.
    final guild = getIt<GuildRepository>().cachedById(guildId);
    final cachedName = guild?.channels
        .where((c) => c.id == channelId)
        .firstOrNull
        ?.name;

    unawaited(
      getIt<GuildVoiceCubit>().join(
        guildId: guildId,
        channelId: channelId,
        channelName: widget.venta.channelName ?? cachedName ?? '',
        guildName: guild?.name ?? '',
      ),
    );
  }

  /// The channel's name as it read when the invitation was sent.
  ///
  /// Falls back to the embed's title, which the server sets to the same string -
  /// it is there so a client that has never heard of this type still renders
  /// something legible.
  String get _channelName {
    final name = widget.venta.channelName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return widget.embed.title?.trim() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    // Whether this is our own invitation, seen from the sending side. The card
    // lands in a conversation, so both people read the same row - and offering
    // the inviter a Join button for the channel they are sitting in, which is
    // the only way they were allowed to send this at all, would be nonsense.
    final me = getIt<AuthRepository>().currentUserId;
    final inviterId = widget.venta.inviterId;
    final isOwnInvitation =
        me != null && me.isNotEmpty && inviterId != null && me == inviterId;

    final name = _channelName;

    return BlocBuilder<GuildVoiceCubit, GuildVoiceState>(
      bloc: getIt<GuildVoiceCubit>(),
      buildWhen: (previous, current) => previous.channelId != current.channelId,
      builder: (context, voice) {
        // Whether joining will pull them out of a channel they are already in.
        // Worth saying before they tap, not after.
        final willMove =
            !isOwnInvitation &&
            voice.channelId != null &&
            voice.channelId != widget.venta.channelId;

        return _VentaFrame(
          icon: Icons.volume_up_outlined,
          onTap: isOwnInvitation ? null : (_live ? _accept : _joinAnyway),
          // The inviter reads the same row as the person they invited, and gets
          // the card without the affordance.
          action: isOwnInvitation
              ? null
              : _live
              ? FilledButton(onPressed: _accept, child: const Text('Join'))
              // Not an accept. There is no ring to accept - it lapsed, or there
              // never was one - so this is the ordinary join, which grants
              // nothing the channel's own permissions would not.
              : TextButton(
                  onPressed: _joinAnyway,
                  child: const Text('Join channel'),
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Voice channel invitation',
                style: theme.textTheme.labelSmall?.copyWith(color: muted),
              ),
              Text(
                name.isEmpty ? 'a voice channel' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Three states, not two: a standing invitation never had an
              // expiry, so saying it has expired would be a lie about a card
              // that is still good.
              if (!_live && !_standing)
                Text(
                  'This invitation has expired',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              if (willMove)
                Text(
                  'Joining will move you out of your current channel.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
            ],
          ),
        );
      },
    );
  }
}

const _maxVentaCardWidth = 400.0;
const _glyphSize = 40.0;

/// Longest deadline the voice-invite card will hold a timer open for.
const _maxLapseTimer = Duration(minutes: 5);
