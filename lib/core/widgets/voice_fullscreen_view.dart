import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../orientation/viewer_orientation.dart';
import '../theme/app_colors.dart';
import 'profile_resolver.dart';
import 'tilt_rotation.dart';
import 'video_participant_tile.dart';

/// One incoming camera or screen share, filling the screen.
///
/// Pushed as an ordinary route by whichever voice screen owns the tile that was
/// tapped, so the back button and the back gesture close it for free and the
/// grid underneath stays mounted - which matters, because that grid is still
/// reporting its own tile sizes and still holding its subscriptions.
///
/// **Two things have to be told to the server for this to look like fullscreen
/// rather than an upscaled thumbnail**, and both are the caller's to arrange
/// through [onHeightChanged] and [onEnter]:
///
///  * **The new tile height.** Which simulcast layer this client is served is
///    chosen from the height it reports, so a viewer that opens a picture
///    without saying so keeps being served the layer its thumbnail asked for
///    and stretches it. The tile below reports its own size on first layout
///    like any other, under whatever id the caller gives it - a *different* id
///    from the grid tile, so the two coexist and the larger one wins while this
///    is open.
///  * **The pin.** In a room the server is being selective in, a subscription
///    set is active speakers plus pins, so opening somebody who is not talking
///    can ask for a track the set does not include.
///
/// [updates] is the cubit that owns the media. `MediaStreamTrack`s cannot live
/// in cubit state, so [track] re-reads the current one imperatively on every
/// emission - the same arrangement the grid tiles use, for the same reason.
///
/// This is also the one screen in the app that is allowed to be sideways. It
/// turns its own contents rather than asking the platform to turn the window -
/// see [TiltRotation] for why that is the only version that works for everyone
/// - and the window is pinned to a single portrait orientation while it is open
/// so the tilt reading and the window agree on which way is up.
class VoiceFullscreenView extends StatefulWidget {
  const VoiceFullscreenView({
    super.key,
    required this.userId,
    required this.updates,
    required this.track,
    required this.onEnter,
    required this.onExit,
    this.isShare = false,
    this.onHeightChanged,
    this.onHidden,
  });

  /// Whose picture this is. Named rather than labelled so the title resolves
  /// through the same profile cache every other name on the screen does.
  final String userId;

  /// Whether this is a screen share rather than a camera, which is the only
  /// thing the title says differently.
  final bool isShare;

  /// Emits whenever the owning cubit does. Only used to re-read [track].
  final Stream<Object?> updates;

  /// The track to render right now, or null while none has arrived.
  final MediaStreamTrack? Function() track;

  /// Claims the pin and any share audio. Called once, on open.
  final Future<void> Function() onEnter;

  /// Releases both. Called once, on close, including a close by gesture.
  final Future<void> Function() onExit;

  /// See `VideoParticipantTile.onHeightChanged`. Reported under an id of the
  /// caller's choosing, which must not be the grid tile's.
  final ValueChanged<int>? onHeightChanged;

  /// See `VideoParticipantTile.onHidden`.
  final VoidCallback? onHidden;

  @override
  State<VoiceFullscreenView> createState() => _VoiceFullscreenViewState();
}

class _VoiceFullscreenViewState extends State<VoiceFullscreenView> {
  late ViewerOrientationMode _mode = ViewerOrientationPrefs.mode;

  @override
  void initState() {
    super.initState();
    unawaited(widget.onEnter());
    // `main()` allows both portrait orientations. Both would be fine on their
    // own, but the tilt reading is interpreted relative to the window: a window
    // that has flipped to reverse portrait while a sideways picture is on
    // screen turns that picture upside down. One orientation, restored on the
    // way out.
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
  }

  @override
  void dispose() {
    // Not awaited and deliberately not gated on `mounted`: the screen is going
    // away either way, and a pin left claimed keeps a subscription this viewer
    // no longer has anywhere to draw.
    unawaited(widget.onExit());
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );
    super.dispose();
  }

  void _setMode(ViewerOrientationMode mode) {
    setState(() => _mode = mode);
    ViewerOrientationPrefs.mode = mode;
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      // Outside the rotation: cutouts and system bars belong to the device, so
      // their insets are only in the right place while they are still being
      // read in the device's own coordinates. Inside, they would pad whichever
      // edge happened to be the content's top.
      child: SafeArea(
        child: TiltRotation(
          mode: _mode,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: AppColors.darkTextPrimary,
              // See `AppTheme` - built title, kept leading-aligned on both
              // platforms.
              centerTitle: false,
              title: ProfileResolver(
                userId: widget.userId,
                builder: (context, profile) {
                  final name = profile?.userName ?? '…';
                  return Text(
                    widget.isShare ? '$name is sharing' : name,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
              actions: [
                ViewerOrientationButton(mode: _mode, onChanged: _setMode),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) => StreamBuilder<Object?>(
                stream: widget.updates,
                builder: (context, _) => Center(
                  child: VideoParticipantTile(
                    track: widget.track(),
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    borderRadius: 0,
                    onHeightChanged: widget.onHeightChanged,
                    onHidden: widget.onHidden,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
