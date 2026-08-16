import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' show RTCVideoViewObjectFit;

import '../diagnostics/video_diagnostics_prefs.dart';
import '../orientation/viewer_orientation.dart';
import '../theme/app_colors.dart';
import '../voice/voice_video_feed.dart';
import 'adaptive_progress_indicator.dart';
import 'camera_switch_button.dart';
import 'profile_resolver.dart';
import 'tilt_rotation.dart';
import 'video_participant_tile.dart';

/// One camera or screen share, filling the screen - somebody else's, or this
/// device's own.
///
/// Pushed as an ordinary route by whichever voice screen owns the tile that was
/// tapped, so the back button and the back gesture close it for free and the
/// grid underneath stays mounted - which matters, because that grid is still
/// reporting its own tile sizes and still holding its subscriptions.
///
/// **The local case is the same screen with less to arrange.** Nobody
/// subscribes to their own picture, so there is no pin to claim and no size to
/// report - the two paragraphs below are about an incoming stream and simply do
/// not apply, which is why [onEnter], [onExit] and [onHeightChanged] are all
/// optional. What the local case adds is [onSwitchCamera]: full screen is where
/// you are actually looking at your own camera, so it is where flipping it
/// belongs.
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
/// in cubit state, so [feed] re-reads the current one imperatively on every
/// emission - the same arrangement the grid tiles use, for the same reason.
///
/// This is also the one screen in the app that is allowed to be sideways. It
/// turns its own contents rather than asking the platform to turn the window -
/// see [TiltRotation] for why that is the only version that works for everyone
/// - and the window is pinned to a single portrait orientation while it is open
/// so the tilt reading and the window agree on which way is up.
///
/// **Nothing is laid out beside the picture.** The title and the controls float
/// over it on a scrim and then withdraw, taking the device's own bars with
/// them, so what is left is the frame and the black around it. Any tap brings
/// them back. A bar that stayed in the layout would be a permanent strip of the
/// screen this route exists to hand over - and on a 16:9 picture in a portrait
/// window, the strip it takes is the picture itself, not the letterbox.
class VoiceFullscreenView extends StatefulWidget {
  const VoiceFullscreenView({
    super.key,
    required this.updates,
    required this.feed,
    required this.isLive,
    this.userId,
    this.title,
    this.onEnter,
    this.onExit,
    this.isShare = false,
    this.isMirrored,
    this.onSwitchCamera,
    this.onHeightChanged,
    this.onHidden,
  }) : assert(
         userId != null || title != null,
         'a full-screen picture has to say whose it is',
       );

  /// Whose picture this is. Named rather than labelled so the title resolves
  /// through the same profile cache every other name on the screen does.
  /// Unused when [title] is given, which is the local case: resolving your own
  /// name to put it above your own camera is a lookup to say "you".
  final String? userId;

  /// A fixed title, in place of resolving [userId].
  final String? title;

  /// Whether this is a screen share rather than a camera, which is the only
  /// thing the title says differently.
  final bool isShare;

  /// Emits whenever the owning cubit does. Only used to re-read [feed].
  final Stream<Object?> updates;

  /// The picture to render right now, or null while none has arrived.
  final VoiceVideoFeed? Function() feed;

  /// Whether the picture this route was opened on still exists in the roster.
  ///
  /// Read on every emission the same way [feed] is, and for the same reason:
  /// the roster is authoritative, and it can drop a share through half a dozen
  /// routes - the publisher stopping it, leaving, being evicted by the server's
  /// liveness sweep, or a snapshot arriving that simply no longer lists it.
  /// Enumerating those events here would mean re-listing them every time the
  /// server grows another one; asking the roster covers all of them by
  /// construction, including the ones that do not exist yet.
  ///
  /// **A null [feed] is deliberately not the test.** A feed reads null for a
  /// beat during renegotiation too, and closing the view on that would snatch
  /// the picture away from a viewer whose stream was about to come back. Absent
  /// from the roster is a fact; absent from the wire for a moment is not.
  final bool Function() isLive;

  /// Whether to mirror the picture, re-read on every emission the same way
  /// [feed] is - a camera flip changes the answer while this route is open,
  /// and this route is where the flip is most likely to be pressed.
  ///
  /// Null - never mirrored - for anything arriving from somebody else: a remote
  /// camera has already been mirrored, or not, by whoever is holding it.
  final bool Function()? isMirrored;

  /// Flips the camera this device is publishing from. Null for a picture that
  /// is not ours, which is every remote one.
  final Future<void> Function()? onSwitchCamera;

  /// Claims the pin and any share audio. Called once, on open. Null for a local
  /// picture, which is subscribed to by nobody.
  final Future<void> Function()? onEnter;

  /// Releases both. Called once, on close, including a close by gesture.
  final Future<void> Function()? onExit;

  /// See `VideoParticipantTile.onHeightChanged`. Reported under an id of the
  /// caller's choosing, which must not be the grid tile's.
  final ValueChanged<int>? onHeightChanged;

  /// See `VideoParticipantTile.onHidden`.
  final VoidCallback? onHidden;

  @override
  State<VoiceFullscreenView> createState() => _VoiceFullscreenViewState();
}

/// How long the controls stay up before getting out of the way of the picture.
const _chromeLinger = Duration(seconds: 3);

class _VoiceFullscreenViewState extends State<VoiceFullscreenView> {
  late ViewerOrientationMode _mode = ViewerOrientationPrefs.mode;

  /// Watches the roster for the picture disappearing underneath this route.
  ///
  /// Separate from the `StreamBuilder` in [build], which sees the same
  /// emissions: that one decides what to *draw*, and drawing is the wrong place
  /// to pop a route from - a `Navigator` call during a build is a framework
  /// error. This listens for the same change and acts on it outside the frame.
  StreamSubscription<Object?>? _liveness;

  /// Whether the title and the controls are up.
  ///
  /// They start up - a screen that opens bare is a screen with no way out that
  /// anybody can see - and then withdraw, because the point of this route is
  /// the picture and everything else is in front of it. Any tap brings them
  /// back, which is the one gesture every full-screen viewer has taught.
  bool _chromeVisible = true;
  Timer? _chromeTimer;

  /// True while the camera is being flipped, which stops the picture for as
  /// long as the platform takes to open the other one. Held here rather than
  /// inside the button so the *picture* can say what is happening; a preview
  /// that simply freezes reads as a hang.
  bool _switchingCamera = false;

  @override
  void initState() {
    super.initState();
    unawaited(widget.onEnter?.call());
    _liveness = widget.updates.listen((_) {
      if (!mounted || widget.isLive()) return;
      _dismiss();
    });
    // `main()` allows both portrait orientations. Both would be fine on their
    // own, but the tilt reading is interpreted relative to the window: a window
    // that has flipped to reverse portrait while a sideways picture is on
    // screen turns that picture upside down. One orientation, restored on the
    // way out.
    unawaited(
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    );
    _keepChromeUp();
  }

  /// Shows the controls (if they were down) and restarts their countdown.
  /// Called for a tap on the picture and after anything that was pressed, so
  /// the bar never withdraws out from under a thumb that is still using it.
  void _keepChromeUp() {
    _chromeTimer?.cancel();
    if (!_chromeVisible) setState(() => _chromeVisible = true);
    _syncSystemBars();
    _chromeTimer = Timer(_chromeLinger, () {
      if (mounted) _hideChrome();
    });
  }

  void _hideChrome() {
    _chromeTimer?.cancel();
    if (!_chromeVisible) return;
    setState(() => _chromeVisible = false);
    _syncSystemBars();
  }

  /// The device's own bars follow the app's, so "out of the way" means all of
  /// it. Restored by [dispose] - hiding the status bar for one route and
  /// leaving it hidden for the app is the kind of thing nobody notices until
  /// they cannot find the clock.
  void _syncSystemBars() {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: _chromeVisible ? SystemUiOverlay.values : const [],
      ),
    );
  }

  void _toggleChrome() {
    if (_chromeVisible) {
      _hideChrome();
    } else {
      _keepChromeUp();
    }
  }

  /// Close this route because what it was showing no longer exists.
  ///
  /// Removes *this* route by identity rather than popping whatever is on top.
  /// A bare `pop()` closes the topmost route, which is not necessarily this one
  /// - a settings sheet, a dialog or the share-quality picker can sit above it,
  /// and a share ending underneath would then dismiss that instead and leave
  /// the dead fullscreen exactly where it was. `removeRoute` is also what keeps
  /// this safe against the shell popping the call screen in the same beat.
  void _dismiss() {
    final route = ModalRoute.of(context);
    if (route == null) return;
    Navigator.of(context).removeRoute(route);
  }

  @override
  void dispose() {
    _chromeTimer?.cancel();
    unawaited(_liveness?.cancel());
    // Not awaited and deliberately not gated on `mounted`: the screen is going
    // away either way, and a pin left claimed keeps a subscription this viewer
    // no longer has anywhere to draw.
    unawaited(widget.onExit?.call());
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      ),
    );
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
    _keepChromeUp();
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
            // No `appBar`: a bar in the layout takes its height out of the
            // picture, and this route exists to give the picture everything.
            // The controls float over it instead, on a scrim of their own.
            body: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  // Opaque so the whole black field answers, not only the part
                  // a letterboxed picture happens to cover.
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleChrome,
                  child: LayoutBuilder(
                    builder: (context, constraints) => StreamBuilder<Object?>(
                      stream: widget.updates,
                      builder: (context, _) => Center(
                        child: VideoParticipantTile(
                          feed: widget.feed(),
                          label: widget.userId == null
                              ? 'full:self'
                              : 'full:${widget.userId}',
                          // A local picture is this device's own capture and
                          // has no delivery to explain; the two callbacks that
                          // are null for it say the same thing.
                          expectsVideo: widget.onSwitchCamera == null,
                          mirror: widget.isMirrored?.call() ?? false,
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
                // Over the picture rather than replacing it: the frozen last
                // frame underneath is the honest thing to show while the other
                // camera opens, and dimming it is what makes the freeze read as
                // deliberate.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _switchingCamera ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const ColoredBox(
                        color: Colors.black45,
                        child: Center(
                          child: AdaptiveProgressIndicator(
                            size: 28,
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(top: 0, left: 0, right: 0, child: _buildChrome()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The title and controls, floating over the top of the picture.
  ///
  /// Only the buttons take taps. The scrim and the title deliberately let them
  /// through to the picture underneath, so the whole screen answers the
  /// show/hide gesture except the few places where something else is meant.
  Widget _buildChrome() {
    return IgnorePointer(
      ignoring: !_chromeVisible,
      child: AnimatedSlide(
        offset: _chromeVisible ? Offset.zero : const Offset(0, -0.35),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _chromeVisible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.transparent],
              ),
            ),
            child: IconTheme(
              data: const IconThemeData(color: AppColors.darkTextPrimary),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 24),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: 'Back',
                      icon: const BackButtonIcon(),
                    ),
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                        child: widget.title != null
                            ? Text(
                                widget.title!,
                                overflow: TextOverflow.ellipsis,
                              )
                            : ProfileResolver(
                                userId: widget.userId!,
                                builder: (context, profile) {
                                  final name = profile?.userName ?? '…';
                                  return Text(
                                    widget.isShare ? '$name is sharing' : name,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                      ),
                    ),
                    // First of the controls, because on the one screen where it
                    // is offered it is the thing being reached for - the other
                    // two are about how the picture is presented, this one is
                    // about what the picture is of.
                    if (widget.onSwitchCamera != null)
                      CameraSwitchButton(
                        onSwitch: widget.onSwitchCamera!,
                        onBusyChanged: (busy) {
                          setState(() => _switchingCamera = busy);
                          _keepChromeUp();
                        },
                      ),
                    // The diagnostics switch lives here rather than in settings
                    // because this is the screen where the question gets asked
                    // - you are looking at a picture and wondering what you are
                    // actually being sent. The pref is global, so flipping it
                    // here also lights up the grid tiles underneath.
                    ValueListenableBuilder<bool>(
                      valueListenable: VideoDiagnosticsPrefs.enabled,
                      builder: (context, showing, _) => IconButton(
                        onPressed: () {
                          VideoDiagnosticsPrefs.toggle();
                          _keepChromeUp();
                        },
                        tooltip: showing
                            ? 'Hide received resolution'
                            : 'Show received resolution',
                        icon: Icon(
                          showing ? Icons.analytics : Icons.analytics_outlined,
                        ),
                      ),
                    ),
                    ViewerOrientationButton(mode: _mode, onChanged: _setMode),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
