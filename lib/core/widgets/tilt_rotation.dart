import 'package:flutter/material.dart';

import '../orientation/device_tilt.dart';
import '../orientation/viewer_orientation.dart';

/// Turns [child] to match the way the device is being held.
///
/// The rotation is done here rather than by the platform on purpose. The app is
/// portrait locked, and a device with rotation lock on would not turn for us
/// even if it were not - so a viewer that waited for the window to rotate would
/// work for some people and silently do nothing for the rest. Rotating the
/// content inside a window that never moves behaves the same for everyone, and
/// is the only version that can also honour a *forced* landscape.
///
/// [RotatedBox] rather than [Transform] because it rotates during layout: the
/// child is measured with width and height swapped and genuinely lays out
/// sideways, instead of being drawn sideways inside portrait-shaped
/// constraints.
///
/// Put any [SafeArea] *outside* this widget. Display cutouts and system bars
/// are attached to the physical device, not to the rotated content, so their
/// insets have to be taken in unrotated coordinates or they end up padding the
/// wrong edge.
class TiltRotation extends StatefulWidget {
  const TiltRotation({super.key, required this.mode, required this.child});

  final ViewerOrientationMode mode;
  final Widget child;

  @override
  State<TiltRotation> createState() => _TiltRotationState();
}

class _TiltRotationState extends State<TiltRotation> {
  VoidCallback? _releaseTilt;

  /// Which way round landscape was last held. Forced landscape needs a side to
  /// pick when the device is lying flat or standing upright, and the side the
  /// person last used is a better guess than a constant.
  int _lastLandscapeTurns = 1;

  @override
  void initState() {
    super.initState();
    // Claimed in every mode, not just [ViewerOrientationMode.auto]: forced
    // landscape still reads the tilt to choose its side, and switching back to
    // auto has to be able to answer immediately rather than after the next
    // time the phone moves.
    _releaseTilt = DeviceTilt.instance.claim();
    DeviceTilt.instance.quarterTurns.addListener(_onTilt);
    _onTilt();
  }

  @override
  void dispose() {
    DeviceTilt.instance.quarterTurns.removeListener(_onTilt);
    _releaseTilt?.call();
    super.dispose();
  }

  void _onTilt() {
    final turns = DeviceTilt.instance.quarterTurns.value;
    if (turns != 0) _lastLandscapeTurns = turns;
    if (mounted) setState(() {});
  }

  int get _quarterTurns {
    final tilt = DeviceTilt.instance.quarterTurns.value;
    return switch (widget.mode) {
      ViewerOrientationMode.auto => tilt,
      ViewerOrientationMode.portrait => 0,
      ViewerOrientationMode.landscape => tilt == 0 ? _lastLandscapeTurns : tilt,
    };
  }

  @override
  Widget build(BuildContext context) {
    return RotatedBox(quarterTurns: _quarterTurns, child: widget.child);
  }
}

/// The manual override, as an app-bar action.
///
/// Cycles auto -> landscape -> portrait, in that order, because the person who
/// goes looking for this button is usually the one whose device will not turn
/// itself and who wants landscape now.
class ViewerOrientationButton extends StatelessWidget {
  const ViewerOrientationButton({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ViewerOrientationMode mode;
  final ValueChanged<ViewerOrientationMode> onChanged;

  static ViewerOrientationMode _next(ViewerOrientationMode mode) =>
      switch (mode) {
        ViewerOrientationMode.auto => ViewerOrientationMode.landscape,
        ViewerOrientationMode.landscape => ViewerOrientationMode.portrait,
        ViewerOrientationMode.portrait => ViewerOrientationMode.auto,
      };

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (mode) {
      ViewerOrientationMode.auto => (
        Icons.screen_rotation,
        'Rotates with the device',
      ),
      ViewerOrientationMode.landscape => (
        Icons.screen_lock_landscape,
        'Locked sideways',
      ),
      ViewerOrientationMode.portrait => (
        Icons.screen_lock_portrait,
        'Locked upright',
      ),
    };
    return IconButton(
      icon: Icon(icon),
      tooltip: label,
      onPressed: () => onChanged(_next(mode)),
    );
  }
}
