import 'dart:async';

import '../../../core/realtime/realtime_event.dart';
import '../../../core/realtime/realtime_service.dart';
import 'models/wiki_category_dto.dart';
import 'models/wiki_dto.dart';
import 'models/wiki_page_dto.dart';
import 'models/wiki_page_summary_dto.dart';
import 'models/wiki_revision_dto.dart';
import 'wiki_api.dart';

/// App-lifetime singleton, like `GuildRepository`, but deliberately holds no
/// cache of its own — wiki screens are opened per-guild and fetch fresh on
/// open (mirrors `GuildDetailScreen._load()`), and only one wiki screen is
/// ever open at a time. This repository's job is just to turn the six
/// `guild.Wiki*` realtime events into a guildId invalidation signal that any
/// open wiki screen can filter on and refetch from — deliberately screen-
/// local invalidation rather than shared state, the same choice made for
/// `guild.PresenceChanged` on the member list.
class WikiRepository {
  WikiRepository({
    required this.api,
    required RealtimeService realtimeService,
  }) {
    _realtimeSub = realtimeService.events
        .where(
          (e) => const {
            'guild.WikiPageCreated',
            'guild.WikiPageUpdated',
            'guild.WikiPageDeleted',
            'guild.WikiCategoryCreated',
            'guild.WikiCategoryUpdated',
            'guild.WikiCategoryDeleted',
          }.contains(e.name),
        )
        .listen((event) {
          final guildId = event.objectPayload['guildId'] as String?;
          if (guildId != null) _invalidatedController.add(guildId);
        });
  }

  final WikiApi api;
  late final StreamSubscription<RealtimeEvent> _realtimeSub;

  final _invalidatedController = StreamController<String>.broadcast();

  /// Emits a guildId every time that guild's wiki structure or a page
  /// changed remotely — screens filter for their own guildId.
  Stream<String> get invalidated => _invalidatedController.stream;

  Future<WikiDto> getWiki(String guildId) => api.getWiki(guildId);

  Future<WikiPageDto> getPage(String guildId, String pageId) =>
      api.getPage(guildId, pageId);

  Future<WikiPageDto> createPage(
    String guildId, {
    required String title,
    String? content,
    String? parentPageId,
    String? categoryId,
    WikiVisibility visibility = WikiVisibility.private,
    List<String> tags = const [],
    bool isPinned = false,
  }) => api.createPage(
    guildId,
    title: title,
    content: content,
    parentPageId: parentPageId,
    categoryId: categoryId,
    visibility: visibility,
    tags: tags,
    isPinned: isPinned,
  );

  Future<WikiPageDto> updatePage(
    String guildId,
    String pageId, {
    String? title,
    String? content,
    String? parentPageId,
    bool clearParentPage = false,
    String? categoryId,
    bool clearCategory = false,
    WikiVisibility? visibility,
    List<String>? tags,
    bool? isPinned,
  }) => api.updatePage(
    guildId,
    pageId,
    title: title,
    content: content,
    parentPageId: parentPageId,
    clearParentPage: clearParentPage,
    categoryId: categoryId,
    clearCategory: clearCategory,
    visibility: visibility,
    tags: tags,
    isPinned: isPinned,
  );

  Future<void> deletePage(String guildId, String pageId) =>
      api.deletePage(guildId, pageId);

  Future<List<WikiRevisionDto>> getRevisions(String guildId, String pageId) =>
      api.getRevisions(guildId, pageId);

  Future<WikiPageDto> restoreRevision(
    String guildId,
    String pageId,
    String revisionId,
  ) => api.restoreRevision(guildId, pageId, revisionId);

  Future<WikiCategoryDto> createCategory(
    String guildId, {
    required String name,
    int? position,
    String? parentCategoryId,
  }) => api.createCategory(
    guildId,
    name: name,
    position: position,
    parentCategoryId: parentCategoryId,
  );

  Future<WikiCategoryDto> updateCategory(
    String guildId,
    String categoryId, {
    String? name,
    int? position,
    String? parentCategoryId,
    bool clearParentCategory = false,
  }) => api.updateCategory(
    guildId,
    categoryId,
    name: name,
    position: position,
    parentCategoryId: parentCategoryId,
    clearParentCategory: clearParentCategory,
  );

  Future<void> deleteCategory(String guildId, String categoryId) =>
      api.deleteCategory(guildId, categoryId);

  void dispose() {
    _realtimeSub.cancel();
    _invalidatedController.close();
  }
}
