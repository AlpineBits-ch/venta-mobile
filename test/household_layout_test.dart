import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/theme/app_theme.dart';
import 'package:venta_mobile/features/household/data/models/maintenance_dto.dart';
import 'package:venta_mobile/features/household/presentation/screens/ledger_channel_screen.dart';
import 'package:venta_mobile/features/household/presentation/screens/maintenance_channel_screen.dart';
import 'package:venta_mobile/features/household/presentation/widgets/household_widgets.dart';
import 'package:venta_mobile/features/settings/presentation/screens/account_settings_screen.dart';

/// The household screens are read standing up, one-handed, on a narrow phone -
/// and by people who have turned the text size up, which is exactly the
/// population most likely to be reading a warranty date off a boiler.
///
/// So the shared vocabulary is pumped here at 390pt, in both themes, at normal
/// size and at the largest accessibility step. A `RenderFlex` overflow throws
/// during layout, and `tester.takeException()` is what turns that into a failed
/// test rather than a red stripe nobody sees.
/// ODbL 4.3's model notice, which is what the server sends with every
/// catalog-supplied product name. Copied verbatim rather than shortened: it is
/// the wording the licence itself blesses, and the whole point of the widget
/// under test is that it fits without being reworded.
const catalogAttribution =
    'Contains information from Open Food Facts, which is made available here '
    'under the Open Database License (ODbL).';

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
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        home: MediaQuery(
          data: MediaQueryData(
            size: phone,
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
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

  /// Controllers for the phone field's four interesting contents. Built once
  /// and shared across the pumps below - the widget only ever reads them.
  final emptyPhone = TextEditingController();
  final savedPhone = TextEditingController(text: '+41 79 123 45 67');
  final nationalPhone = TextEditingController(text: '079 123 45 67');
  final doubleZeroPhone = TextEditingController(text: '0041 79 123 45 67');
  tearDownAll(() {
    for (final controller in [
      emptyPhone,
      savedPhone,
      nationalPhone,
      doubleZeroPhone,
    ]) {
      controller.dispose();
    }
  });

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

    // The phone-number half, which is read in the same conditions as the rest
    // of the household UI plus one worse one: standing in a kitchen trying to
    // work out why the number you typed isn't being accepted. The error copy
    // has to be long enough to explain the `+` and must therefore be allowed
    // to wrap rather than clip - which is exactly what these catch.
    'a phone number nobody has entered yet': PhoneNumberCard(
      controller: emptyPhone,
      saved: null,
      onChanged: () {},
      onSave: () {},
      onRemove: () {},
    ),
    'a phone number already on the account': PhoneNumberCard(
      controller: savedPhone,
      saved: '+41791234567',
      onChanged: () {},
      onSave: () {},
      onRemove: () {},
    ),
    // The long refusal: the whole point of it is that it explains why 00 is
    // not swapped for +, and that explanation is several lines at 2.35x.
    'a phone number typed the way you dial it': PhoneNumberCard(
      controller: nationalPhone,
      saved: null,
      onChanged: () {},
      onSave: () {},
      onRemove: () {},
    ),
    'a phone number written 0041': PhoneNumberCard(
      controller: doubleZeroPhone,
      saved: null,
      onChanged: () {},
      onSave: () {},
      onRemove: () {},
    ),
    'a phone number still being read': PhoneNumberCard(
      controller: emptyPhone,
      saved: null,
      loading: true,
      onChanged: () {},
      onSave: () {},
      onRemove: () {},
    ),
    'a number being saved': PhoneNumberCard(
      controller: savedPhone,
      saved: '+41799999999',
      saving: true,
      onChanged: () {},
      onSave: () {},
      onRemove: () {},
    ),

    // The per-household opt-in, in all four states it can actually be in -
    // including the one nothing else would think to draw: switched on over an
    // account with no number behind it. Removing a number now clears the
    // opt-in everywhere, so that one is a leftover from older accounts rather
    // than a routine state, but the server can still send it and the card
    // still has to fit it.
    'sharing switched off': PhoneSharingCard(
      sharing: false,
      hasNumber: true,
      onChanged: (_) {},
      onAddNumber: () {},
    ),
    'sharing switched on': PhoneSharingCard(
      sharing: true,
      hasNumber: true,
      onChanged: (_) {},
      onAddNumber: () {},
    ),
    'sharing with no number on the account': PhoneSharingCard(
      sharing: false,
      hasNumber: false,
      onChanged: (_) {},
      onAddNumber: () {},
    ),
    'sharing switched on with nothing behind it': PhoneSharingCard(
      sharing: true,
      hasNumber: false,
      onChanged: (_) {},
      onAddNumber: () {},
    ),
    'sharing mid-flight': PhoneSharingCard(
      sharing: false,
      hasNumber: true,
      busy: true,
      onChanged: (_) {},
      onAddNumber: () {},
    ),

    // The number itself, next to the caution that is the only check in the
    // whole flow. Both have to survive being read at the largest text size,
    // because that caution is the one sentence that stops money going to a
    // stranger.
    'a number to pay into': const PayeePhoneRow(phoneNumber: '+41791234567'),
    'a very long number to pay into': const PayeePhoneRow(
      phoneNumber: '+998901234567890',
    ),

    // The catalog half of the scanner. A public product database can now name
    // a barcode this house has never seen, which means two things have to fit
    // on screen that never had to before: a mark saying the name is a
    // suggestion rather than the flat's own word, and the credit its licence
    // requires. The credit is the awkward one - it is a full sentence of
    // someone else's wording, it is not ours to shorten, and it sits in the
    // densest strip of the busiest screen in the app.
    'a suggested-name mark': const SuggestedNameBadge(),

    // The pill lives at the end of a product name in a tally row, so the slot
    // it gets is whatever the name leaves. This is that slot at its worst, and
    // it is the reason the pill is flexible there rather than fixed: at 2.35x
    // the word "Suggested" is wider than the space a long product name leaves
    // it, and a pill that cannot shrink takes the whole row over the edge.
    'a suggested-name mark with almost no room': const SizedBox(
      width: 96,
      child: Row(
        children: [
          Flexible(
            child: Text(
              'Migros Bio Vollmilch UHT 1L',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 6),
          Flexible(child: SuggestedNameBadge()),
        ],
      ),
    ),
    'the credit a catalog name owes': const ProductSourceNote(
      attribution: catalogAttribution,
    ),

    // Both jobs of the naming sheet, since they render different copy. Height
    // is pinned because the sheet scrolls internally: what these catch is a row
    // inside it overflowing at 2.35x, which is exactly what the badge plus a
    // long product name would do if it were not allowed to shrink.
    'naming a product nothing could name': const SizedBox(
      height: 520,
      child: ProductNameSheet(),
    ),
    'correcting a name a catalog suggested': const SizedBox(
      height: 560,
      child: ProductNameSheet(
        initialName: 'Migros Bio Vollmilch UHT 1L',
        suggestion: 'Migros Bio Vollmilch UHT 1L',
        brand: 'M-Budget, Migros',
        attribution: catalogAttribution,
      ),
    ),
  };

  for (final entry in cases.entries) {
    for (final brightness in Brightness.values) {
      for (final scale in const [1.0, largestTextScale]) {
        testWidgets('${entry.key} fits at 390pt '
            '(${brightness.name}, text x$scale)', (tester) async {
          await pump(
            tester,
            entry.value,
            textScale: scale,
            brightness: brightness,
          );
          expect(tester.takeException(), isNull);
        });
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
