abstract final class RoutePaths {
  static const login = '/login';
  static const register = '/register';
  static const serverSetup = '/server-setup';

  static const home = '/home';
  static const homeFriends = '/home/friends';
  static const conversation = '/home/conversation/:conversationId';

  static const server = '/server/:guildId';
  static const serverChannel = '/server/:guildId/channel/:channelId';
  static const serverMembers = '/server/:guildId/members';
  static const serverSettings = '/server/:guildId/settings';

  static const profileSettings = '/profile-settings';
  static const userProfile = '/user/:userId';

  static String conversationPath(String conversationId) =>
      '/home/conversation/$conversationId';

  static String userProfilePath(String userId) => '/user/$userId';

  static String serverPath(String guildId) => '/server/$guildId';

  static String serverChannelPath(String guildId, String channelId) =>
      '/server/$guildId/channel/$channelId';

  static String serverMembersPath(String guildId) => '/server/$guildId/members';

  static String serverSettingsPath(String guildId) => '/server/$guildId/settings';
}
