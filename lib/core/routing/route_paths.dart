abstract final class RoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const serverSetup = '/server-setup';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const homeFriends = '/home/friends';
  static const conversation = '/home/conversation/:conversationId';

  /// Unread channels and mentions across every guild. Outside the shell, and
  /// outside `/home` in particular - it's reachable from a guild as readily as
  /// from Home, and nesting it under one of them would make the back arrow lie
  /// about where it came from. Takes an optional `?guildId=` that only scopes
  /// the Mentions tab.
  static const inbox = '/inbox';

  static const server = '/server/:guildId';
  static const serverChannel = '/server/:guildId/channel/:channelId';
  static const serverChannelSettings =
      '/server/:guildId/channel/:channelId/settings';

  /// A Forum/Media channel's tag editor and posting config - separate from
  /// [serverChannelSettings] (name/topic/slowmode/delete), which every channel
  /// type shares.
  static const serverChannelForumSettings =
      '/server/:guildId/channel/:channelId/forum';
  static const serverMembers = '/server/:guildId/members';

  /// Where a member changes the onboarding answers that granted them roles and
  /// channels - Discord's "Channels & Roles". Only reachable in guilds that
  /// actually have prompts configured.
  static const serverChannelsRoles = '/server/:guildId/channels-roles';
  static const serverSettings = '/server/:guildId/settings';
  static const serverEvents = '/server/:guildId/events';
  static const serverWiki = '/server/:guildId/wiki';

  /// Declared/registered before [serverWikiPage] in `app_router.dart` - both
  /// match a 4-segment `/server/:guildId/wiki/*` location, and go_router
  /// picks the first declared match, so this literal `new` segment must be
  /// tried before the `:pageId` wildcard swallows it.
  static const serverWikiNewPage = '/server/:guildId/wiki/new';
  static const serverWikiPage = '/server/:guildId/wiki/:pageId';
  static const serverWikiPageEdit = '/server/:guildId/wiki/:pageId/edit';
  static const serverWikiHistory = '/server/:guildId/wiki/:pageId/history';

  /// Your own profile, read-only - the "view" half of what used to be one
  /// crammed `/profile-settings` page. [editProfile] is the "edit" half and
  /// [settings] is everything that isn't profile at all.
  static const selfProfile = '/me';
  static const editProfile = '/me/edit';
  static const userProfile = '/user/:userId';

  static const settings = '/settings';
  static const accountSettings = '/settings/account';
  static const mfaSettings = '/settings/mfa';
  static const notificationSettings = '/settings/notifications';
  static const appearanceSettings = '/settings/appearance';

  /// Bring-your-own-key AI: which provider reads a photo of a cupboard, which
  /// model, and the key that pays for it.
  ///
  /// Under App Settings rather than Privacy even though it is the page that
  /// carries the "photos are not end-to-end encrypted" disclosure: it is a
  /// thing the user turns on and configures, and burying an opt-in feature in
  /// the privacy section is how nobody finds it. The disclosure travels with
  /// the consent sheet, which fires before the first photo leaves the device.
  static const aiSettings = '/settings/ai';

  /// The phase-1 vision harness - shoot a photo, dump what the model said.
  ///
  /// A development tool, deliberately reachable only from [aiSettings] and
  /// never from the pantry, and slated for removal once the real capture flow
  /// ships. Nested under [aiSettings] so backing out of it returns to the page
  /// that offered it.
  static const pantryVisionHarness = '/settings/ai/harness';

  /// Who can reach you, what you share, and what may be done with your data.
  static const privacy = '/settings/privacy';

  /// Sub-pages of [privacy]. Nested under it rather than flat under
  /// `/settings`, so `parentOf` sends the system back button to the Privacy
  /// page these were opened from and not to the settings index.
  static const blockedUsers = '/settings/privacy/blocked';
  static const guildDmPrivacy = '/settings/privacy/servers';
  static const dataExport = '/settings/privacy/data';
  static const legalDocuments = '/settings/privacy/legal';

  /// What this account reported and what became of it. Under Privacy because
  /// that is where someone goes looking for it weeks later - it is deliberately
  /// not reachable from anywhere else.
  static const myReports = '/settings/privacy/reports';

  /// Component-by-component platform health, and the way out to the public
  /// status page. Under App Settings rather than Account: it is about the
  /// instance, not about you.
  static const platformStatus = '/settings/status';

  /// Scanning a desktop/web client's login QR code. Nothing here is about
  /// *this* device's session - see `QrLoginScreen`.
  static const qrLogin = '/settings/qr-login';

  /// Every session signed in to the account, with per-device revoke.
  static const devices = '/settings/devices';

  /// Where the profile *and* settings used to live together. Kept only as a
  /// redirect target: [RoutePersistence] may have saved it as the last visited
  /// location, and a cold start on an unmatched path lands on go_router's
  /// error page.
  static const legacyProfileSettings = '/profile-settings';

  /// Where [location] goes when it's asked to go back and has nothing beneath
  /// it on the stack, or `null` if there is nowhere above it (the auth screens,
  /// and [home] itself - backing out of those closes the app).
  ///
  /// Deliberately the same targets the screens pass to `AppBackButton`: the
  /// arrow in the app bar and the system back button on the same screen going
  /// to different places is its own bug. This exists because the system back
  /// button has no screen to ask - see `UpBackButtonDispatcher`.
  static String? parentOf(String location) {
    return switch (Uri.parse(location).pathSegments) {
      // A channel's own sub-screens (settings, forum config) go back to the
      // channel; the channel itself goes back to the guild.
      ['server', final guildId, 'channel', final channelId, ...final rest] =>
        rest.isEmpty
            ? serverPath(guildId)
            : serverChannelPath(guildId, channelId),
      // The editor is reached from the wiki index as often as from the page
      // it edits, and `WikiEditorScreen` resolves that tie towards the index.
      ['server', final guildId, 'wiki', _, 'edit'] => serverWikiPath(guildId),
      ['server', final guildId, 'wiki', final pageId, ...final rest] =>
        rest.isEmpty || pageId == 'new'
            ? serverWikiPath(guildId)
            : serverWikiPagePath(guildId, pageId),
      // Everything else hanging off a guild - members, settings, events, the
      // wiki index, Channels & Roles.
      ['server', final guildId, _, ...] => serverPath(guildId),
      ['server', _] => home,
      ['home'] => null,
      // Friends and conversations both sit under Home.
      ['home', ...] => home,
      ['inbox'] => home,
      ['me'] => home,
      ['me', ...] => selfProfile,
      ['settings'] => home,
      // Declared before the catch-all below it: the privacy sub-pages are two
      // levels deep and would otherwise back out past the page that opened them.
      ['settings', 'privacy', ...final rest] =>
        rest.isEmpty ? settings : privacy,
      // Same shape, same reason: the vision harness hangs off the AI settings
      // page and must back out to it rather than past it to the index.
      ['settings', 'ai', ...final rest] => rest.isEmpty ? settings : aiSettings,
      ['settings', ...] => settings,
      ['user', ...] => home,
      _ => null,
    };
  }

  static String conversationPath(String conversationId) =>
      '/home/conversation/$conversationId';

  static String inboxPath({String? guildId}) =>
      guildId == null ? inbox : '$inbox?guildId=$guildId';

  static String userProfilePath(String userId) => '/user/$userId';

  static String serverPath(String guildId) => '/server/$guildId';

  static String serverChannelPath(String guildId, String channelId) =>
      '/server/$guildId/channel/$channelId';

  /// A household board opened at one of its rows.
  ///
  /// A query string rather than a deeper path because the destination is the
  /// same screen either way: a chore occurrence has no screen of its own, it is
  /// a row on a board that is opened scrolled to it. Keeping it in the query
  /// also leaves [parentOf] alone, which reads path segments only, so the back
  /// arrow from a deep-linked board still goes to the guild.
  ///
  /// [focusKind] is a [HouseholdFocusKind] token; see `household_deep_link.dart`
  /// for why the alert's own `kind` is not what travels here.
  static String serverChannelFocusPath(
    String guildId,
    String channelId, {
    required String focusKind,
    required String focusId,
  }) =>
      '${serverChannelPath(guildId, channelId)}'
      '?focusKind=${Uri.encodeQueryComponent(focusKind)}'
      '&focus=${Uri.encodeQueryComponent(focusId)}';

  static String serverChannelSettingsPath(String guildId, String channelId) =>
      '/server/$guildId/channel/$channelId/settings';

  static String serverChannelForumSettingsPath(
    String guildId,
    String channelId,
  ) => '/server/$guildId/channel/$channelId/forum';

  static String serverMembersPath(String guildId) => '/server/$guildId/members';

  static String serverChannelsRolesPath(String guildId) =>
      '/server/$guildId/channels-roles';

  static String serverSettingsPath(String guildId) =>
      '/server/$guildId/settings';

  static String serverEventsPath(String guildId) => '/server/$guildId/events';

  static String serverWikiPath(String guildId) => '/server/$guildId/wiki';

  static String serverWikiNewPagePath(String guildId) =>
      '/server/$guildId/wiki/new';

  static String serverWikiPagePath(String guildId, String pageId) =>
      '/server/$guildId/wiki/$pageId';

  static String serverWikiPageEditPath(String guildId, String pageId) =>
      '/server/$guildId/wiki/$pageId/edit';

  static String serverWikiHistoryPath(String guildId, String pageId) =>
      '/server/$guildId/wiki/$pageId/history';
}
