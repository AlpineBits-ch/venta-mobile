import 'dart:ui';

import 'package:dio/dio.dart';

import '../locale/app_language.dart';

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
/// The device half is read from [PlatformDispatcher] rather than
/// `Localizations.localeOf`, and still is now that `MaterialApp` has
/// `supportedLocales` and delegates. A `Localizations` lookup answers with the
/// locale the *app* resolved to - one of three, clamped to `en` for anything
/// else - so a phone set to French would report `en` and the request would
/// confidently ask for the wrong language, when the catalog holds a French name
/// and would happily have served it. [PlatformDispatcher] reports what the
/// handset actually prefers, which is the honest thing to put in this header.
/// An interceptor also has no `BuildContext` to do the lookup with;
/// `lib/core/push/household_strings.dart` reads the platform locale for the
/// same pair of reasons.
///
/// ## Where the language comes from now
///
/// The device is the *fallback*, not the answer. Since the language setting
/// shipped, a person can say which language they want and it has to beat what
/// the handset is set to - which is the whole point of the setting, given the
/// app's own strings are still English and the catalog's names are the only
/// thing it visibly changes. Both are used together rather than one replacing
/// the other: an explicit choice leads at `q=1`, the device's own preference
/// list follows at lower qualities, so a German-speaking user on an Italian
/// phone gets German where the catalog has it and Italian - not English - where
/// it does not. [AppLanguage.system] contributes nothing and leaves the header
/// exactly as it was before the setting existed.
class AcceptLanguageInterceptor extends Interceptor {
  /// [language] is a callback rather than a `LocaleCubit` or a `getIt` lookup
  /// on purpose. This is constructed inside `ApiClient`, which is built during
  /// dependency registration and long before any widget tree exists, and an
  /// interceptor that reaches for a service locator is one that cannot be
  /// exercised from a test without standing the whole locator up. The default
  /// keeps the pre-setting behaviour, so an `ApiClient` built without one - a
  /// test's, most of all - still sends what the device asks for.
  AcceptLanguageInterceptor({
    AppLanguage Function()? language,
    List<Locale> Function()? locales,
  }) : _language = language ?? (() => AppLanguage.system),
       _locales = locales ?? (() => PlatformDispatcher.instance.locales);

  /// What the user chose, unresolved - [AppLanguage.system] means "no choice",
  /// which is a different thing from "chose the device's language" only in that
  /// it keeps following the device when the device changes.
  final AppLanguage Function() _language;

  /// Injected so a test can pin the device's languages.
  final List<Locale> Function() _locales;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // A caller that set the header meant it - a screen offering "show me this
    // in French" must win over both the setting and what the phone is set to.
    if (!options.headers.containsKey('Accept-Language')) {
      final header = buildAcceptLanguage(_preferredLocales());
      if (header != null) options.headers['Accept-Language'] = header;
    }
    handler.next(options);
  }

  /// The chosen language in front of the device's list.
  ///
  /// Composed here rather than inside [buildAcceptLanguage] so that helper
  /// stays a pure list-of-locales-to-header function with no idea this app has
  /// a setting. Duplicates cost nothing: `buildAcceptLanguage` drops repeated
  /// tags, so choosing the language the phone is already set to produces the
  /// same header it produced before.
  List<Locale> _preferredLocales() {
    final chosen = _language().locale;
    final device = _locales();
    return chosen == null ? device : [chosen, ...device];
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
