import '../../../core/network/api_client.dart';
import 'models/inbox_breadcrumb_dto.dart';
import 'models/inbox_mention_dto.dart';
import 'models/inbox_summary_dto.dart';
import 'models/inbox_task_dto.dart';
import 'models/inbox_unread_dto.dart';

/// Unread channels and mentions across every guild the caller is in.
///
/// Every route here acts on the caller's *own* inbox - there is no user id in
/// any path and no way to read anyone else's, so nothing in this class takes
/// one.
class InboxApi {
  InboxApi({required this.client});

  final ApiClient client;

  /// `guild` singular, matching `GuildApi` - the inbox hangs off the same
  /// service.
  String get _base => client.url('/api/v1/guild/inbox');

  /// Channels with messages newer than the caller's read cursor, newest
  /// activity first.
  ///
  /// [limit] is clamped to 1-25 server-side. A page can come back with fewer
  /// groups than asked for - or none at all - and still have a
  /// [InboxUnreadPageDto.nextCursor], because muting and permission filtering
  /// are applied after the page is taken. `InboxRepository` is what follows
  /// those; nothing should call this in a loop of its own.
  Future<InboxUnreadPageDto> getUnread({String? cursor, int limit = 10}) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/unread',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
    );
    final page = InboxUnreadPageDto.fromJson(response.data!);
    return page.copyWith(
      groups: [
        for (final group in page.groups)
          group.copyWith(breadcrumb: _absolutize(group.breadcrumb)),
      ],
    );
  }

  /// Messages that mentioned the caller, newest first - direct and `@here`
  /// merged with `@everyone`/`@role` pings.
  ///
  /// [since] is capped at the index's 31-day retention window regardless of
  /// what is asked for, and there is no backfill before the feature shipped:
  /// this is a recent-activity view, never a complete archive. [limit] is
  /// clamped to 1-50.
  Future<InboxMentionPageDto> getMentions({
    String? guildId,
    InboxMentionSince since = InboxMentionSince.week,
    bool includeEveryone = true,
    bool includeRoles = true,
    bool includeDms = true,
    int limit = 25,
    String? cursor,
  }) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/mentions',
      queryParameters: {
        if (guildId != null) 'guildId': guildId,
        'since': since.wireValue,
        'includeEveryone': includeEveryone,
        'includeRoles': includeRoles,
        'includeDms': includeDms,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    final page = InboxMentionPageDto.fromJson(response.data!);
    return page.copyWith(
      mentions: [
        for (final mention in page.mentions)
          mention.breadcrumb == null
              ? mention
              : mention.copyWith(breadcrumb: _absolutize(mention.breadcrumb!)),
      ],
    );
  }

  /// Household rows waiting on the caller, across every guild they're in.
  ///
  /// The other half of the inbox: `/unread` will never show a household
  /// channel, because a list holds no message history and so can never be
  /// unread. Deadlines first, soonest at the top; undated items after, oldest
  /// first - the order is the server's and is not re-sorted here.
  ///
  /// No cursor - it's a to-do list. [InboxTaskPageDto.truncated] says more were
  /// waiting. [limit] defaults to 25 server-side and caps at 50.
  Future<InboxTaskPageDto> getTasks({int limit = 25}) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/tasks',
      queryParameters: {'limit': limit},
    );
    final page = InboxTaskPageDto.fromJson(response.data!);
    return page.copyWith(
      tasks: [
        for (final task in page.tasks)
          task.copyWith(breadcrumb: _absolutize(task.breadcrumb)),
      ],
    );
  }

  Future<InboxSummaryDto> getSummary() async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '$_base/summary',
    );
    return InboxSummaryDto.fromJson(response.data!);
  }

  /// Marks one channel read up to its current head.
  ///
  /// Same effect as the `guild.UpdateLastRead` hub method; this exists so the
  /// check button works without a live socket. A channel with no messages is a
  /// `204` no-op rather than an error.
  Future<void> markChannelRead(String channelId) async {
    await client.dio.post<void>('$_base/channels/$channelId/read');
  }

  /// Marks every channel in every guild read. Idempotent, and rate-limited
  /// server-side - this is a bulk write across the whole account, so it is
  /// wired to an explicit action and never to a timer.
  Future<void> markAllRead() async {
    await client.dio.post<void>('$_base/read-all');
  }

  /// Dismisses one mention.
  ///
  /// [createdAt] must be the exact ISO-8601 string the mentions response gave
  /// back, not a re-serialised `DateTime` - see [InboxMentionDto.createdAtRaw].
  /// The index is keyed on it, so a mismatch is a `204` that deleted nothing.
  Future<void> dismissMention({
    required String messageId,
    required String createdAt,
  }) async {
    await client.dio.delete<void>(
      '$_base/mentions/$messageId',
      queryParameters: {'createdAt': createdAt},
    );
  }

  /// Guild icon URLs arrive server-relative (`/api/v1/guild/guilds/…/icon`).
  /// The server is chosen at login on this client (self-hosted instances), so
  /// they're only usable once resolved against it - done here rather than in
  /// the widget so a `InboxBreadcrumbDto` is always carrying something an
  /// `Image` can take.
  InboxBreadcrumbDto _absolutize(InboxBreadcrumbDto breadcrumb) =>
      breadcrumb.copyWith(
        guildIconUrl: _absoluteUrl(breadcrumb.guildIconUrl),
        guildIconThumbnailUrl: _absoluteUrl(breadcrumb.guildIconThumbnailUrl),
      );

  String? _absoluteUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return client.url(path.startsWith('/') ? path : '/$path');
  }
}
