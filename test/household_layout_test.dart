import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/features/household/data/models/maintenance_dto.dart';
import 'package:venta_mobile/features/household/presentation/screens/maintenance_channel_screen.dart';
import 'package:venta_mobile/features/household/presentation/widgets/household_widgets.dart';

/// The household screens are read standing up, one-handed, on a narrow phone -
/// and by people who have turned the text size up, which is exactly the
/// population most likely to be reading a warranty date off a boiler.
///
/// So the shared vocabulary is pumped here at 390pt, in both themes, at normal
/// size and at the largest accessibility step. A `RenderFlex` overflow throws
/// during layout, and `tester.takeException()` is what turns that into a failed
/// test rather than a red stripe nobody sees.
void main() {
  /// iPhone 14/15/16 logical width, which is the narrowest phone worth
  /// designing to and the one most of these will be read on.
  const phone = Size(390, 844);

  /// The top of iOS's accessibility slider. Android's largest font scale plus
  /// display scaling lands in the same neighbourhood.
  const largestTextScale = 2.35;

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    required double textScale,
    required Brightness brightness,
  }) async {
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: brightness == Brightness.dark
            ? AppTheme.dark
            : AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: phone,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  final asset = MaintenanceAssetDto(
    id: 'a1',
    channelId: 'c1',
    name: 'Washing machine that somebody gave a very long name to',
    location: 'Bathroom, behind the door',
    status: AssetStatus.broken,
    isServiceOverdue: true,
    isWarrantyExpiring: true,
    warrantyUntil: DateTime.utc(2026, 12, 1),
  );

  final cases = <String, Widget>{
    'an amount': const HouseAmount(amountMinor: 123456789, currency: 'CHF'),
    'an amount nobody has typed yet': const HouseAmountPending(),
    'a primary action': HousePrimaryButton(
      label: 'Make the shopping list for the coming fortnight',
      icon: Icons.playlist_add_rounded,
      onPressed: () {},
    ),
    'a full row of pills': const Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        HousePill(label: 'Running low', icon: Icons.trending_down_rounded),
        HousePill(label: 'On the shopping list', icon: Icons.check_rounded),
        HousePill(label: 'Warranty to 1 Dec 2026'),
      ],
    ),
    'an empty state': const HouseEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Nothing owed',
      body:
          'Rent, internet, the electricity bill - set one up once and every '
          'period shows up here on its own, split the way you agreed.',
    ),
    'an appliance carrying every badge at once': AssetCard(
      asset: asset,
      onTap: () {},
      onMarkBroken: () {},
    ),
    'a loading board': const SizedBox(height: 320, child: HouseCardSkeleton()),
  };

  for (final entry in cases.entries) {
    for (final brightness in Brightness.values) {
      for (final scale in const [1.0, largestTextScale]) {
        testWidgets(
          '${entry.key} fits at 390pt '
          '(${brightness.name}, text x$scale)',
          (tester) async {
            await pump(
              tester,
              entry.value,
              textScale: scale,
              brightness: brightness,
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  /// The mark a deep link leaves on the row it opened at. It has to draw
  /// without animating when the reader has asked for reduced motion - the
  /// outline is information, not decoration, even when the fade is not.
  testWidgets('the focus mark respects reduced motion', (tester) async {
    tester.view.physicalSize = phone;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: MediaQuery(
          data: const MediaQueryData(size: phone, disableAnimations: true),
          child: const Scaffold(
            body: HouseFocusMark(
              focused: true,
              label: 'The one you were told about',
              child: HouseCard(child: Text('Bins')),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    expect(find.text('Bins'), findsOneWidget);
  });
}
