import '../../../core/network/api_client.dart';
import 'models/wiki_category_dto.dart';
import 'models/wiki_dto.dart';
import 'models/wiki_page_dto.dart';
import 'models/wiki_page_summary_dto.dart';
import 'models/wiki_revision_dto.dart';

/// Mirrors Alpine's `WikiService` — every endpoint lives under
/// `{baseUrl}/api/v1/guild/guilds/{guildId}/wiki`.
class WikiApi {
  WikiApi({required this.client});

  final ApiClient client;

  String _base(String guildId) =>
      client.url('/api/v1/guild/guilds/$guildId/wiki');

  Future<WikiDto> getWiki(String guildId) async {
    final response = await client.dio.get<Map<String, dynamic>>(_base(guildId));
    return WikiDto.fromJson(response.data!);
  }

  Future<WikiPageDto> getPage(String guildId, String pageId) async {
    final response = await client.dio.get<Map<String, dynamic>>(
      '${_base(guildId)}/pages/$pageId',
    );
    return WikiPageDto.fromJson(response.data!);
  }

  Future<WikiPageDto> createPage(
    String guildId, {
    required String title,
    String? content,
    String? parentPageId,
    String? categoryId,
    WikiVisibility visibility = WikiVisibility.private,
    List<String> tags = const [],
    bool isPinned = false,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId)}/pages',
      data: {
        'title': title,
        'content': content,
        'parentPageId': parentPageId,
        'categoryId': categoryId,
        'visibility': _visibilityWireValue(visibility),
        'tags': tags,
        'isPinned': isPinned,
      },
    );
    return WikiPageDto.fromJson(response.data!);
  }

  /// `null` for [parentPageId]/[categoryId] means "don't change"; pass an
  /// explicit empty string sentinel is not needed here since callers only
  /// invoke this with fields that changed — [clearParentPage]/
  /// [clearCategory] force those relationships to `null` server-side.
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
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '${_base(guildId)}/pages/$pageId',
      data: {
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (clearParentPage)
          'parentPageId': null
        else if (parentPageId != null)
          'parentPageId': parentPageId,
        if (clearCategory)
          'categoryId': null
        else if (categoryId != null)
          'categoryId': categoryId,
        if (visibility != null) 'visibility': _visibilityWireValue(visibility),
        if (tags != null) 'tags': tags,
        if (isPinned != null) 'isPinned': isPinned,
      },
    );
    return WikiPageDto.fromJson(response.data!);
  }

  Future<void> deletePage(String guildId, String pageId) async {
    await client.dio.delete<void>('${_base(guildId)}/pages/$pageId');
  }

  Future<List<WikiRevisionDto>> getRevisions(
    String guildId,
    String pageId,
  ) async {
    final response = await client.dio.get<List<dynamic>>(
      '${_base(guildId)}/pages/$pageId/revisions',
    );
    return response.data!
        .map((json) => WikiRevisionDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<WikiPageDto> restoreRevision(
    String guildId,
    String pageId,
    String revisionId,
  ) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId)}/pages/$pageId/revisions/$revisionId/restore',
    );
    return WikiPageDto.fromJson(response.data!);
  }

  Future<WikiCategoryDto> createCategory(
    String guildId, {
    required String name,
    int? position,
    String? parentCategoryId,
  }) async {
    final response = await client.dio.post<Map<String, dynamic>>(
      '${_base(guildId)}/categories',
      data: {
        'name': name,
        'position': position,
        'parentCategoryId': parentCategoryId,
      },
    );
    return WikiCategoryDto.fromJson(response.data!);
  }

  Future<WikiCategoryDto> updateCategory(
    String guildId,
    String categoryId, {
    String? name,
    int? position,
    String? parentCategoryId,
    bool clearParentCategory = false,
  }) async {
    final response = await client.dio.put<Map<String, dynamic>>(
      '${_base(guildId)}/categories/$categoryId',
      data: {
        if (name != null) 'name': name,
        if (position != null) 'position': position,
        if (clearParentCategory)
          'parentCategoryId': null
        else if (parentCategoryId != null)
          'parentCategoryId': parentCategoryId,
      },
    );
    return WikiCategoryDto.fromJson(response.data!);
  }

  Future<void> deleteCategory(String guildId, String categoryId) async {
    await client.dio.delete<void>('${_base(guildId)}/categories/$categoryId');
  }

  String _visibilityWireValue(WikiVisibility visibility) =>
      switch (visibility) {
        WikiVisibility.public => 'Public',
        WikiVisibility.private => 'Private',
      };
}
