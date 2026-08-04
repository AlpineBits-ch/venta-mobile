import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The Venta brand mark: a rounded speech bubble with two eyes and the small
/// detached dot above it. The same shape the launcher icon in `assets/icon/`
/// and the desktop client's `assets/branding/logo-mark.svg` draw.
///
/// Painted instead of shipped as an asset because Alpine keeps three
/// near-identical copies of that SVG which differ only in fill (brand, ink,
/// white). A body/eye colour pair covers all three, and lets a placement tint
/// the mark from the theme rather than pick a file.
class VentaLogoMark extends StatelessWidget {
  const VentaLogoMark({
    super.key,
    this.size = 32,
    this.bodyColor = AppColors.logoMark,
    this.eyeColor = AppColors.logoMarkEye,
  });

  final double size;

  /// The bubble, the dot and the pupils - everything drawn in the logo's
  /// coral by default.
  final Color bodyColor;

  /// The two eyes. On a tinted chip this should be the chip's own fill, so the
  /// eyes read as holes punched through the bubble rather than as a second
  /// colour, which is how the white variant of the mark works on the desktop
  /// client's home button.
  final Color eyeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _VentaLogoMarkPainter(
          bodyColor: bodyColor,
          eyeColor: eyeColor,
        ),
      ),
    );
  }
}

class _VentaLogoMarkPainter extends CustomPainter {
  const _VentaLogoMarkPainter({
    required this.bodyColor,
    required this.eyeColor,
  });

  final Color bodyColor;
  final Color eyeColor;

  /// The mark is authored on a 64x64 grid. Every coordinate below is read
  /// straight off `logo-mark.svg`, including its off-centre framing, so the
  /// two files stay comparable by eye when the mark is redrawn.
  static const _grid = 64.0;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / _grid;
    final body = Paint()..color = bodyColor;
    final eye = Paint()..color = eyeColor;

    canvas
      ..drawCircle(Offset(48 * s, 10 * s), 9 * s, body)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(6 * s, 12 * s, 52 * s, 46 * s),
          Radius.circular(20 * s),
        ),
        body,
      )
      ..drawCircle(Offset(23 * s, 30 * s), 6 * s, eye)
      ..drawCircle(Offset(41 * s, 30 * s), 6 * s, eye)
      ..drawCircle(Offset(25 * s, 28 * s), 1.6 * s, body)
      ..drawCircle(Offset(43 * s, 28 * s), 1.6 * s, body);
  }

  @override
  bool shouldRepaint(_VentaLogoMarkPainter oldDelegate) =>
      oldDelegate.bodyColor != bodyColor || oldDelegate.eyeColor != eyeColor;
}
