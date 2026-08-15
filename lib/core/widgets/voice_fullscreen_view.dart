import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../theme/app_colors.dart';
import 'profile_resolver.dart';
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
  @override
  void initState() {
    super.initState();
    unawaited(widget.onEnter());
  }

  @override
  void dispose() {
    // Not awaited and deliberately not gated on `mounted`: the screen is going
    // away either way, and a pin left claimed keeps a subscription this viewer
    // no longer has anywhere to draw.
    unawaited(widget.onExit());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.darkTextPrimary,
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
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => StreamBuilder<Object?>(
            stream: widget.updates,
            builder: (context, _) => Center(
              child: VideoParticipantTile(
                track: widget.track(),
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                borderRadius: 0,
                onHeightChanged: widget.onHeightChanged,
                onHidden: widget.onHidden,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
