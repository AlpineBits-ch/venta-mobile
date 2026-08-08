import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:venta_mobile/features/household/presentation/screens/pantry_scanner_screen.dart';

/// What the scanner decides to act on, before anything reaches the pantry.
///
/// This is the half of the scanner nobody can see going wrong. A checksum
/// written the wrong way round rejects every genuine grocery barcode on earth
/// while looking entirely correct in review, and the symptom - "it just doesn't
/// pick anything up" - is indistinguishable from a bad camera, bad lighting or
/// a bad phone. So the rule is pinned to real codes off real packets.
void main() {
  /// Genuine GTINs. The check digit of each is what these tests are about, so
  /// they are the published textbook examples rather than invented ones.
  const validEan13 = '4006381333931';
  const validEan8 = '96385074';
  const validUpcA = '036000291452';

  Barcode barcode(
    String raw, {
    BarcodeFormat format = BarcodeFormat.ean13,
    Size size = const Size(100, 40),
  }) => Barcode(rawValue: raw, format: format, size: size);

  group('the check digit', () {
    test('accepts real EAN-13, EAN-8 and UPC-A codes', () {
      expect(gtinChecksumHolds(validEan13), isTrue);
      expect(gtinChecksumHolds(validEan8), isTrue);
      expect(gtinChecksumHolds(validUpcA), isTrue);
    });

    test('rejects a code with one digit misread', () {
      // The failure this exists for: a bar smeared or half in shadow comes back
      // the right length and all digits, and only the check digit says so.
      expect(gtinChecksumHolds('4006381333932'), isFalse);
      expect(gtinChecksumHolds('96385075'), isFalse);
    });

    test('rejects transposed digits, which is the other common misread', () {
      expect(gtinChecksumHolds('4006381333913'), isFalse);
    });

    test('rejects anything that is not digits, and anything too short', () {
      expect(gtinChecksumHolds('40063813339 1'), isFalse);
      expect(gtinChecksumHolds('400638A33393'), isFalse);
      expect(gtinChecksumHolds('4006381'), isFalse);
      expect(gtinChecksumHolds(''), isFalse);
    });
  });

  group('what counts as a code worth scanning', () {
    test('a GTIN format is only accepted when its checksum holds', () {
      expect(isPlausibleBarcode(BarcodeFormat.ean13, validEan13), isTrue);
      expect(isPlausibleBarcode(BarcodeFormat.ean13, '4006381333932'), isFalse);
      expect(isPlausibleBarcode(BarcodeFormat.upcA, validUpcA), isTrue);
    });

    test('UPC-E is taken on its digits, having no usable check digit here', () {
      expect(isPlausibleBarcode(BarcodeFormat.upcE, '01234565'), isTrue);
      expect(isPlausibleBarcode(BarcodeFormat.upcE, '0123'), isFalse);
      expect(isPlausibleBarcode(BarcodeFormat.upcE, '01234E'), isFalse);
    });

    test('a case code is accepted on length alone', () {
      // Code 128 and ITF-14 turn up on multipacks and carry nothing this side
      // of the symbology worth checking, so the floor is only "not a smear".
      expect(isPlausibleBarcode(BarcodeFormat.code128, 'ABC123'), isTrue);
      expect(isPlausibleBarcode(BarcodeFormat.code128, 'AB'), isFalse);
      expect(isPlausibleBarcode(BarcodeFormat.itf14, '12345678901231'), isTrue);
    });
  });

  group('choosing between codes in frame', () {
    test('takes the biggest, which is the packet being held up', () {
      // A bag on the counter puts several in frame at once. The one under the
      // lens is the one filling it.
      final chosen = bestBarcodeOf([
        barcode(validEan8, format: BarcodeFormat.ean8, size: const Size(40, 15)),
        barcode(validEan13, size: const Size(220, 90)),
        barcode(
          validUpcA,
          format: BarcodeFormat.upcA,
          size: const Size(60, 24),
        ),
      ]);
      expect(chosen, validEan13);
    });

    test('skips a misread even when it is the biggest thing in frame', () {
      final chosen = bestBarcodeOf([
        barcode('4006381333932', size: const Size(300, 120)),
        barcode(validEan13, size: const Size(80, 30)),
      ]);
      expect(chosen, validEan13);
    });

    test('returns nothing rather than guessing', () {
      expect(bestBarcodeOf([]), isNull);
      expect(bestBarcodeOf([barcode('4006381333932')]), isNull);
      expect(bestBarcodeOf([barcode('')]), isNull);
    });

    test('still picks something when no size was reported', () {
      // Not every platform fills `size` in. A zero-area code must not be
      // silently unpickable - it is still the only thing on screen.
      expect(bestBarcodeOf([barcode(validEan13, size: Size.zero)]), validEan13);
    });
  });
}
