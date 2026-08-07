import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_error.dart';
import '../../../../core/routing/household_deep_link.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../guilds/data/guild_repository.dart';
import '../../../guilds/data/models/channel_dto.dart';
import '../../../guilds/data/models/guild_dto.dart';
import '../../../guilds/data/models/guild_member_dto.dart';
import '../../../guilds/data/models/guild_permissions.dart';
import '../../data/household_api.dart';
import '../../data/household_repository.dart';
import '../../data/models/household_alert.dart';
import '../widgets/household_widgets.dart';

/// Everything the five household channel screens need before they can render
/// a single row: which guild this is, whether the module is even on, and what
/// this member is allowed to do.
///
/// Permission gating here is **guild-level**, matching every other screen in
/// this app (forum, wiki, events). The server resolves these per channel, so a
/// channel overwrite can differ from what this predicts - it's a UI hint, and
/// the server is the authority on every write either way.
///
/// The module gate is not a permission check and must not read like one. A
/// guild without the module answers `403` on every endpoint for everyone
/// including the owner, and there is no escape hatch - so the module state is
/// checked *before* rendering and shown as a product state ("your house
/// doesn't do money"), never as "you're not allowed".
abstract class HouseholdChannelState<W extends StatefulWidget>
    extends State<W> {
  String get guildId;
  String get channelId;

  /// The `GuildFeature` flag this screen's endpoints are gated on.
  String get requiredFeature;

  /// The row a notification brought somebody here for, if any.
  ///
  /// Set from the route on open and **cleared once the board has shown it**:
  /// it describes an arrival, not a selection, and a highlight that survives a
  /// pull-to-refresh half an hour later is a mark nobody can explain. Screens
  /// call [clearFocus] after the row has been scrolled to.
  HouseholdFocus? focus;

  /// Whether [focus] names [id] as a row of [kind].
  bool isFocused(String kind, String? id) =>
      focus?.matches(kind, id) ?? false;

  void clearFocus() {
    if (focus == null) return;
    if (mounted) setState(() => focus = null);
  }

  /// Points the board at a new row, and re-arms the scroll.
  void moveFocusTo(HouseholdFocus? target) {
    if (target == null || !mounted) return;
    setState(() {
      focus = target;
      _focusRevealed = false;
    });
  }

  final _focusKeys = <String, GlobalKey>{};
  bool _focusRevealed = false;

  /// Marks and scrolls to [child] when it is the row the route or an alert
  /// named, and does nothing at all otherwise.
  ///
  /// The mark is deliberately temporary. It says "this is the one you were
  /// told about", which stops being true within seconds - an outline still
  /// sitting there after a pull-to-refresh is a state nobody can account for.
  Widget focusRow(String kind, String id, Widget child, {String? label}) {
    if (!isFocused(kind, id)) return child;
    final key = _focusKeys.putIfAbsent(id, GlobalKey.new);
    if (!_focusRevealed) {
      _focusRevealed = true;
      // The row only exists once the board has loaded, so this runs from the
      // build that first contains it rather than from `initState`.
      revealHouseholdRow(key);
      Future.delayed(const Duration(seconds: 4), clearFocus);
    }
    return HouseFocusMark(
      key: key,
      focused: true,
      label: label ?? 'The one you were told about',
      child: child,
    );
  }

  GuildDto? guild;
  GuildPermissions permissions = GuildPermissions.none;

  StreamSubscription<List<GuildDto>>? _guildsSub;
  StreamSubscription<HouseholdAlert>? _alertsSub;

  HouseholdApi get api => getIt<HouseholdApi>();
  HouseholdRepository get household => getIt<HouseholdRepository>();

  /// Who's looking. Every one of these modules is about *people* - who owes
  /// what, whose turn it is, who's home - so nearly every screen needs it.
  String get currentUserId => getIt<AuthRepository>().currentUserId ?? '';

  ChannelDto? get channel =>
      guild?.channels.where((c) => c.id == channelId).firstOrNull;

  /// The house, for the pickers that need it - who to assign a chore to, who
  /// an expense is split between. Loaded on demand via [ensureMembers] so the
  /// modules that never ask (pantry, decisions) don't pay for it.
  List<GuildMemberDto>? members;

  Future<void> ensureMembers() async {
    if (members != null) return;
    try {
      // A household is a flat, not a public server - one page covers it, and
      // a paged picker for six people would be silly.
      final loaded = await getIt<GuildRepository>().getMembers(
        guildId,
        take: 100,
      );
      if (mounted) setState(() => members = loaded);
    } catch (_) {
      // Pickers fall back to "just me", which is still usable.
    }
  }

  /// `#groceries`. Falls back to the module's own name while the guild is
  /// still loading, so the app bar never flashes the word "Channel".
  String get channelTitle {
    final name = channel?.name;
    return name == null ? fallbackTitle : '#$name';
  }

  /// Shown until the channel is known - override per module ("Pantry",
  /// "Ledger"…).
  String get fallbackTitle => 'Channel';

  /// Null while the guild hasn't loaded: assuming the module is *on* until we
  /// know otherwise avoids flashing "switched off" at somebody whose house is
  /// perfectly fine.
  bool get moduleEnabled => guild?.hasFeature(requiredFeature) ?? true;

  bool can(String permission) => permissions.has(permission);

  @override
  void initState() {
    super.initState();
    _loadGuildContext();
    // Toggling a module, renaming the channel or a role change all arrive as
    // a fresh guild - track it rather than reading the cache once.
    _guildsSub = getIt<GuildRepository>().guildsStream.listen((guilds) {
      final updated = guilds.where((g) => g.id == guildId).firstOrNull;
      if (updated != null && mounted) setState(() => guild = updated);
    });
    _alertsSub = household.channelAlerts(channelId).listen((alert) {
      if (mounted) onHouseholdAlert(alert);
    });
  }

  @override
  void dispose() {
    unawaited(_guildsSub?.cancel());
    unawaited(_alertsSub?.cancel());
    super.dispose();
  }

  /// A household alert landed on this board while it was open.
  ///
  /// Handled here rather than per module because the kinds keep being added
  /// and every one of them arrives on the same event: a screen that only knew
  /// about its own would silently stop surfacing whatever shipped next. It
  /// also arrives as a push, but a tray entry for the screen somebody is
  /// already looking at is easy to miss.
  ///
  /// The copy is the server's - it writes [HouseholdAlert.title] and
  /// [HouseholdAlert.body] precisely so a client needs none of its own.
  /// Override to reload as well; call `super` to keep the message.
  ///
  /// It also points the board at the row, when the kind names one. An alert
  /// about a row somebody is looking at should move the board to it rather
  /// than leave a sentence in a snackbar to be matched up by hand - and a kind
  /// this build has never heard of simply names no row and shows the sentence,
  /// which is the whole contract.
  void onHouseholdAlert(HouseholdAlert alert) {
    moveFocusTo(alert.focus);
    showMessage(alert.message);
  }

  Future<void> _loadGuildContext() async {
    final repository = getIt<GuildRepository>();
    final cached = repository.cachedById(guildId);
    if (cached != null && mounted) setState(() => guild = cached);
    try {
      // A cold start straight into this route (persisted location, deep link)
      // has no cache at all, so this can't be skipped when `cached` is null.
      final fetched = await repository.fetchGuild(guildId);
      if (mounted) setState(() => guild = fetched);
    } catch (_) {
      // Keep whatever was cached; the module gate defaults to "on" and the
      // screen's own load will surface the failure.
    }
    try {
      final self = await repository.getOwnMember(guildId);
      final ownerId = guild?.ownerId;
      if (mounted) {
        setState(
          () => permissions = ownerId != null
              ? self.effectivePermissions(ownerId)
              : self.permissions,
        );
      }
    } catch (_) {
      // Leave gated affordances hidden - still enforced server-side.
    }
  }

  /// Standard app bar for a household channel. [actions] are the module's own.
  PreferredSizeWidget buildAppBar({
    List<Widget> actions = const [],
    PreferredSizeWidget? bottom,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return AppBar(
      leading: AppBackButton(fallbackLocation: RoutePaths.serverPath(guildId)),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(channelTitle),
          if (subtitle != null)
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
      actions: moduleEnabled ? actions : const [],
      bottom: bottom,
    );
  }

  /// The body to render instead of the module's own when it's switched off.
  Widget buildModuleOff() => ModuleOffView(
    feature: requiredFeature,
    guildNoun: (guild?.kind.noun ?? 'Server').toLowerCase(),
    onOpenSettings: can('ManageGuild')
        ? () => context.push(RoutePaths.serverSettingsPath(guildId))
        : null,
  );

  /// Errors from these endpoints are worth showing verbatim where the server
  /// bothered to explain itself ("Anna is not in the rotation"), and this is
  /// the one place that decision is made.
  void showError(Object error, String fallback) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error) ?? fallback)));
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
