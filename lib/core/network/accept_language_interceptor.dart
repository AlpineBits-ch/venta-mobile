import 'dart:ui';

import 'package:dio/dio.dart';

/// Tells the server which language this device reads.
///
/// Added when the product catalog shipped and it turned out nothing in this app
/// had ever sent the header. The catalog holds a product's name in de, fr, it
/// and en and picks by `Accept-Language`; with the header absent the server
/// falls back to its own order - German first. A German-speaking flat therefore
/// got the right name by luck, and a French- or Italian-speaking one got German
/// names for every product they scanned, with nothing in the app to explain
/// why or any way to change it.
///
/// It sits in the client rather than on the two catalog calls because the next
/// endpoint to grow a translation will not come with a reminder, and a header
/// that describes the device belongs with the other headers that describe the
/// device.
///
/// Read from [PlatformDispatcher] rather than `Localizations.localeOf`: the app
/// has no `supportedLocales` and no delegates, so a `MaterialApp` lookup
/// resolves to `en` on every device regardless of its actual settings - which
/// would be worse than sending nothing, because it would confidently ask for
/// the wrong language. `lib/core/push/household_strings.dart` reads the
/// platform locale for the same reason.
class AcceptLanguageInterceptor extends Interceptor {
  AcceptLanguageInterceptor({List<Locale> Function()? locales})
    : _locales = locales ?? (() => PlatformDispatcher.instance.locales);

  /// Injected so a test can pin the device's languages.
  final List<Locale> Function() _locales;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // A caller that set the header meant it - a screen offering "show me this
    // in French" must win over what the phone is set to.
    if (!options.headers.containsKey('Accept-Language')) {
      final header = buildAcceptLanguage(_locales());
      if (header != null) options.headers['Accept-Language'] = header;
    }
    handler.next(options);
  }
}

/// The device's languages as an RFC 9110 `Accept-Language` value, best first.
///
/// Quality values descend in steps of 0.1 and stop at 0.1, which is enough for
/// the four languages any of these endpoints actually holds. Region subtags are
/// kept (`de-CH`) even though the catalog ignores them: they cost nothing here
/// and some other endpoint may one day care about the difference between Swiss
/// and German German.
String? buildAcceptLanguage(List<Locale> locales) {
  final seen = <String>{};
  final parts = <String>[];

  for (final locale in locales) {
    final tag = locale.toLanguageTag();
    if (tag.isEmpty || tag == 'und' || !seen.add(tag)) continue;

    if (parts.isEmpty) {
      parts.add(tag);
    } else {
      final quality = (1.0 - parts.length * 0.1).clamp(0.1, 0.9);
      parts.add('$tag;q=${quality.toStringAsFixed(1)}');
    }
    if (parts.length == 5) break;
  }

  return parts.isEmpty ? null : parts.join(', ');
}
