import 'package:dio/dio.dart';

/// Pulls a human-readable reason out of a failed request.
///
/// The backend answers a rejected write in one of three shapes depending on
/// which layer refused it: ASP.NET's validation-problem body
/// (`{errors: {field: [msg]}}`), a bare `{message}`/`{error}` object, or a
/// plain string (`403`/`409`, and the onboarding endpoints' `400`s). Callers
/// that want to show *why* a save failed - rather than a flat "Could not save
/// changes" - run the exception through this and fall back to their own
/// wording when it returns null.
String? apiErrorMessage(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;

  if (data is String) {
    final trimmed = data.trim();
    // An HTML error page (a proxy 502, say) is not a message worth showing.
    if (trimmed.isEmpty || trimmed.startsWith('<')) return null;
    return trimmed;
  }

  if (data is Map) {
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final messages = <String>[];
      for (final value in errors.values) {
        if (value is String) {
          messages.add(value);
        } else if (value is List) {
          messages.addAll(value.whereType<String>());
        }
      }
      if (messages.isNotEmpty) return messages.join('\n');
    }
    for (final key in const ['message', 'error', 'title', 'detail']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
  }

  return null;
}
