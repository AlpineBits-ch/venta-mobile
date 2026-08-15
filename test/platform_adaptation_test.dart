import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/core/widgets/adaptive_progress_indicator.dart';
import 'package:venta_mobile/core/widgets/app_back_button.dart';
import 'package:venta_mobile/core/widgets/button_progress_indicator.dart';

/// The iOS half of the theme, which is otherwise unobservable here: this repo
/// is developed on Windows, so nothing short of `debugDefaultTargetPlatformOverride`
/// ever renders the Cupertino branch. Without these, "looks native on iOS" is a
/// claim no one on this machine can check before shipping.
///
/// The sizing assertion on [AdaptiveProgressIndicator] is the load-bearing one.
/// It's the reason that widget exists rather than
/// `CircularProgressIndicator.adaptive`: the framework's adaptive constructor
/// renders `CupertinoActivityIndicator` at its own fixed 20x20 and ignores
/// `color`/`strokeWidth` entirely, so every 16-18px spinner in this app would
/// have quietly overflowed its box and lost its tint on iOS only.
void main() {
  // A safety net only. Each body clears the override itself before returning,
  // because `testWidgets` asserts the foundation debug vars are unset at the
  // end of the *body* - which is earlier than any `tearDown` runs.
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  Future<void> pumpOn(
    WidgetTester tester,
    TargetPlatform platform,
    Widget child,
  ) {
    debugDefaultTargetPlatformOverride = platform;
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    );
  }

  group('AppTheme', () {
    // `testWidgets` rather than `test` even though nothing is pumped: building
    // the theme reaches `GoogleFonts.interTextTheme()`, which needs a binding.
    testWidgets('iOS drops the ink ripple and hands the title back to AppBar', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(AppTheme.light.splashFactory, same(NoSplash.splashFactory));
      expect(AppTheme.dark.splashFactory, same(NoSplash.splashFactory));
      // Null, not `true` - unset is what makes `AppBar` apply its own iOS
      // default, which also knows to give up on centring when there are
      // enough actions to crowd the title.
      expect(AppTheme.light.appBarTheme.centerTitle, isNull);
      expect(AppTheme.dark.appBarTheme.centerTitle, isNull);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('Android keeps the ripple and the leading-aligned title', (
      tester,
    ) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      expect(AppTheme.light.splashFactory, same(InkRipple.splashFactory));
      expect(AppTheme.light.appBarTheme.centerTitle, isFalse);
      expect(AppTheme.dark.appBarTheme.centerTitle, isFalse);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('AppBackButton', () {
    testWidgets('is a chevron on iOS and an arrow on Android', (tester) async {
      await pumpOn(
        tester,
        TargetPlatform.iOS,
        const AppBackButton(fallbackLocation: '/'),
      );
      expect(
        tester.widget<Icon>(find.byType(Icon)).icon,
        Icons.arrow_back_ios_new,
      );

      await pumpOn(
        tester,
        TargetPlatform.android,
        const AppBackButton(fallbackLocation: '/'),
      );
      expect(tester.widget<Icon>(find.byType(Icon)).icon, Icons.arrow_back);
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('AdaptiveProgressIndicator', () {
    testWidgets('honours its size and colour on iOS', (tester) async {
      await pumpOn(
        tester,
        TargetPlatform.iOS,
        const AdaptiveProgressIndicator(
          size: 16,
          strokeWidth: 2,
          color: Color(0xFFABCDEF),
        ),
      );

      final indicator = find.byType(CupertinoActivityIndicator);
      expect(indicator, findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // 16, not the 20 that `CircularProgressIndicator.adaptive` would force.
      expect(tester.getSize(indicator), const Size(16, 16));
      expect(
        tester.widget<CupertinoActivityIndicator>(indicator).color,
        const Color(0xFFABCDEF),
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('is the Material arc on Android', (tester) async {
      await pumpOn(
        tester,
        TargetPlatform.android,
        const AdaptiveProgressIndicator(
          size: 16,
          strokeWidth: 2,
          color: Color(0xFFABCDEF),
        ),
      );

      final indicator = find.byType(CircularProgressIndicator);
      expect(indicator, findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      expect(tester.getSize(indicator), const Size(16, 16));
      expect(
        tester.widget<CircularProgressIndicator>(indicator).strokeWidth,
        2,
      );
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('an unsized one is the same extent on both platforms', (
      tester,
    ) async {
      await pumpOn(
        tester,
        TargetPlatform.iOS,
        const Center(child: AdaptiveProgressIndicator()),
      );
      final ios = tester.getSize(find.byType(CupertinoActivityIndicator));

      await pumpOn(
        tester,
        TargetPlatform.android,
        const Center(child: AdaptiveProgressIndicator()),
      );
      expect(ios, tester.getSize(find.byType(CircularProgressIndicator)));
      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('ButtonProgressIndicator', () {
    testWidgets('keeps the button foreground colour on iOS', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final theme = AppTheme.light;

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Scaffold(body: ButtonProgressIndicator()),
        ),
      );

      final indicator = find.byType(CupertinoActivityIndicator);
      expect(indicator, findsOneWidget);
      expect(tester.getSize(indicator), const Size(18, 18));
      // The whole point of `ButtonProgressIndicator`: on a filled primary
      // button the spinner has to be `onPrimary`, and the framework's adaptive
      // indicator would have dropped that colour on iOS.
      expect(
        tester.widget<CupertinoActivityIndicator>(indicator).color,
        theme.colorScheme.onPrimary,
      );
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
