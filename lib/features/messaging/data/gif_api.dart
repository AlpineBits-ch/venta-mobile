import 'package:dio/dio.dart';

/// A single GIF search/trending result from Klipy.
class GifResult {
  const GifResult({
    required this.id,
    required this.title,
    required this.url,
    required this.previewUrl,
  });

  final String id;
  final String title;

  /// Full animated GIF URL - sent as the message content, matching desktop.
  final String url;

  /// Static JPEG thumbnail - used for the picker grid.
  final String previewUrl;
}

/// Hits Klipy directly from the client (no gateway involved) - same
/// convention as the desktop app, which embeds this key client-side too
/// since it's already shipped in every build.
class GifApi {
  GifApi({Dio? dio}) : _dio = dio ?? Dio();

  static const _apiKey =
      'urPFHj6XtUHQIo9G5XD3nvudiXcyRIiad68WfDV0DV8WmJXSFfxFC4PGqcRTXuL5';
  static const _base = 'https://api.klipy.com/api/v1/$_apiKey/gifs';
  static const _perPage = 24;

  final Dio _dio;

  Future<List<GifResult>> trending() =>
      _fetch('$_base/trending', {'per_page': _perPage});

  Future<List<GifResult>> search(String query) =>
      _fetch('$_base/search', {'q': query, 'per_page': _perPage});

  Future<List<GifResult>> _fetch(
    String url,
    Map<String, dynamic> params,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: params,
    );
    final items =
        (response.data!['data'] as Map<String, dynamic>)['data']
            as List<dynamic>? ??
        const [];
    return items.map((raw) {
      final item = raw as Map<String, dynamic>;
      final hd =
          (item['file'] as Map<String, dynamic>)['hd'] as Map<String, dynamic>;
      final gif = hd['gif'] as Map<String, dynamic>?;
      final jpg = hd['jpg'] as Map<String, dynamic>?;
      return GifResult(
        id: item['id'].toString(),
        title: item['title'] as String? ?? '',
        url: gif?['url'] as String? ?? '',
        previewUrl: jpg?['url'] as String? ?? gif?['url'] as String? ?? '',
      );
    }).toList();
  }
}

/// True when [text] is an entire message consisting of a Klipy CDN GIF URL -
/// such a message renders as an inline GIF image rather than plain text.
bool isKlipyGifUrl(String text) => RegExp(
  r'^https://static\.klipy\.com/.+',
  caseSensitive: false,
).hasMatch(text.trim());
