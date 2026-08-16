import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flips the local camera between front and back.
///
/// Shared by the self-preview tile and the full-screen self view so the two
/// behave identically - the same icon, the same half-turn, and the same
/// treatment of a flip that is still in flight.
///
/// **Stateful because the flip is not instant.** Switching stops the capture
/// and opens the other camera, which takes long enough on a handset to be seen.
/// Left as a plain button, that gap reads as a dead control and gets tapped
/// again; the second tap is dropped by the service's own guard, so the user
/// learns nothing from it either. Here the icon turns as soon as it is pressed
/// and the control is inert until the picture comes back, which says "working"
/// with the thing already under the thumb.
class CameraSwitchButton extends StatefulWidget {
  const CameraSwitchButton({
    super.key,
    required this.onSwitch,
    this.onBusyChanged,
    this.compact = false,
  });

  /// Completes once the other camera is live - or once the flip has failed, in
  /// which case the picture simply stays as it was. Either way this is done
  /// waiting; there is no failure state to render, because a camera that never
  /// changed side is not a broken screen.
  final Future<void> Function() onSwitch;

  /// Reports the flip starting and finishing, for whoever owns the picture:
  /// the capture stops for as long as the platform takes to open the other
  /// camera, and a preview that simply freezes for a second reads as a hang.
  /// The button alone cannot say so - it is a 32-pixel circle in the corner of
  /// the thing that has actually stopped.
  final ValueChanged<bool>? onBusyChanged;

  /// The small circular variant that sits on top of the preview tile, as
  /// opposed to the icon button used in the full-screen controls.
  final bool compact;

  @override
  State<CameraSwitchButton> createState() => _CameraSwitchButtonState();
}

class _CameraSwitchButtonState extends State<CameraSwitchButton> {
  bool _busy = false;

  /// A whole turn per press, accumulated rather than toggled between two values
  /// so the icon always rotates onward instead of unwinding on every other tap.
  ///
  /// Whole rather than half because this glyph has a top and a bottom: stopping
  /// at 180 degrees would leave a camera icon standing on its head until the
  /// next press, which is a spin that looks like a rendering bug.
  double _turns = 0;

  Future<void> _flip() async {
    if (_busy) return;
    // Before the await, not after it: the confirmation belongs to the press,
    // and the press is the only part of this that is instant.
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _busy = true;
      _turns += 1;
    });
    widget.onBusyChanged?.call(true);
    try {
      await widget.onSwitch();
    } catch (e) {
      // Swallowed here rather than let out into the gesture callback, where it
      // would take the frame with it. There is nothing to show: a flip that did
      // not happen leaves the picture exactly as it was, which the user can
      // already see. What must not survive it is the busy state below.
      debugPrint('[Voice] camera flip failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
      widget.onBusyChanged?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dimmed rather than greyed while it is working: this button sits on video
    // in both variants, and a disabled-grey glyph on a moving picture reads as
    // an artefact rather than as a state.
    final icon = AnimatedOpacity(
      opacity: _busy ? 0.5 : 1,
      duration: const Duration(milliseconds: 150),
      child: AnimatedRotation(
        turns: _turns,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
        child: Icon(
          Icons.cameraswitch_rounded,
          size: widget.compact ? 18 : 24,
          // Inherits the surrounding icon theme full-screen, where the controls
          // set their own; explicit over the preview tile, which has none.
          color: widget.compact ? Colors.white : null,
        ),
      ),
    );

    if (!widget.compact) {
      return IconButton(
        onPressed: _busy ? null : _flip,
        tooltip: 'Switch camera',
        icon: icon,
      );
    }

    return Semantics(
      button: true,
      enabled: !_busy,
      label: 'Switch camera',
      child: Tooltip(
        message: 'Switch camera',
        child: Material(
          color: Colors.black54,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _busy ? null : _flip,
            child: SizedBox(width: 32, height: 32, child: Center(child: icon)),
          ),
        ),
      ),
    );
  }
}
