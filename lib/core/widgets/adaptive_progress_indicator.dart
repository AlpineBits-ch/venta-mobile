import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// An indeterminate busy spinner: Material's sweeping arc on Android, iOS's
/// spoked activity indicator on iOS.
///
/// Deliberately not `CircularProgressIndicator.adaptive`, which is only right
/// for a spinner that has no size and no colour. On iOS that constructor drops
/// `strokeWidth`, `color` and `valueColor` on the floor - it reads
/// *`backgroundColor`* as the tick colour - and renders a
/// `CupertinoActivityIndicator` at its own fixed 20x20 regardless of the box
/// it was given. Both of those bite here: a 16px spinner in a `SizedBox`
/// overflows, and the `onPrimary`-tinted one inside a filled button reverts to
/// the default grey (see [ButtonProgressIndicator] for why that colour matters).
/// Driving `CupertinoActivityIndicator`'s own `radius`/`color` keeps the size
/// and the tint honest on both platforms.
///
/// Indeterminate only. A *determinate* progress ring has no iOS idiom worth
/// swapping to, so those call sites keep using `CircularProgressIndicator`
/// with a `value` directly.
class AdaptiveProgressIndicator extends StatelessWidget {
  const AdaptiveProgressIndicator({
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  /// Side length of the spinner. Null means "fill the box", matching a bare
  /// `CircularProgressIndicator` - which is what full-screen loading states
  /// want, and is the only case where the iOS indicator has to invent a size.
  final double? size;

  /// Foreground. Null takes each platform's own default: `colorScheme.primary`
  /// on Material, the system inactive grey on iOS.
  final Color? color;

  /// Material only - the iOS indicator's stroke is a function of its radius.
  final double? strokeWidth;

  /// What `CircularProgressIndicator` lays itself out at when unconstrained
  /// (`_kMinCircularProgressIndicatorSize`), so an unsized spinner doesn't
  /// change size across platforms.
  static const double _unsizedExtent = 36;

  @override
  Widget build(BuildContext context) {
    // `Theme.of(context).platform`, not `defaultTargetPlatform`: it is what
    // every `.adaptive` constructor in the framework switches on, so a test
    // (or a debug toggle) that overrides one overrides this too.
    final platform = Theme.of(context).platform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    if (isApple) {
      final extent = size ?? _unsizedExtent;
      return SizedBox(
        width: extent,
        height: extent,
        child: CupertinoActivityIndicator(radius: extent / 2, color: color),
      );
    }

    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color,
    );
    if (size == null) return indicator;
    return SizedBox(width: size, height: size, child: indicator);
  }
}
