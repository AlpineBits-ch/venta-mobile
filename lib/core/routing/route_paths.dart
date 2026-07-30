abstract final class RoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const serverSetup = '/server-setup';
  static const forgotPassword = '/forgot-password';

  static const home = '/home';
  static const homeFriends = '/home/friends';
  static const conversation = '/home/conversation/:conversationId';

  static const server = '/server/:guildId';
  static const serverChannel = '/server/:guildId/channel/:channelId';
  static const serverChannelSettings =
      '/server/:guildId/channel/:channelId/settings';
  static const serverMembers = '/server/:guildId/members';
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

  /// Where the profile *and* settings used to live together. Kept only as a
  /// redirect target: [RoutePersistence] may have saved it as the last visited
  /// location, and a cold start on an unmatched path lands on go_router's
  /// error page.
  static const legacyProfileSettings = '/profile-settings';

  static String conversationPath(String conversationId) =>
      '/home/conversation/$conversationId';

  static String userProfilePath(String userId) => '/user/$userId';

  static String serverPath(String guildId) => '/server/$guildId';

  static String serverChannelPath(String guildId, String channelId) =>
      '/server/$guildId/channel/$channelId';

  static String serverChannelSettingsPath(String guildId, String channelId) =>
      '/server/$guildId/channel/$channelId/settings';

  static String serverMembersPath(String guildId) => '/server/$guildId/members';

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
