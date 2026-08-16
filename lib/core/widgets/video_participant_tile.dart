import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../voice/voice_video_feed.dart';
import 'adaptive_progress_indicator.dart';
import 'received_resolution_badge.dart';
import 'voice_tile_fault_overlay.dart';

/// Renders one live camera/screen-share video track - the video-capable
/// sibling of `CallParticipantTile`. Owns its own `RTCVideoRenderer` and
/// attaches the [VoiceVideoFeed]'s stream to it.
///
/// **It attaches the SDK's stream and builds nothing of its own.** This used to
/// wrap each track in a throwaway `createLocalMediaStream` + `addTrack`, because
/// the renderer takes a stream and the cubits handed out bare tracks. That wrap
/// is what produced the permanently black tile, three ways at once:
///
///  * `addTrack` is a platform call that **throws** when the native track has
///    been released since the Dart reference was read - reported from a handset
///    as `PlatformException(mediaStreamAddTrack: Track is nil)` while a camera
///    was being flipped, which is exactly when `LocalVideoTrack.restartTrack`
///    stops the old track and disposes its stream. The throw landed before
///    `srcObject` was ever assigned, in a future nobody awaited.
///  * the synthetic stream gave the renderer an `ownerTag` of its own, which is
///    what `flutter_webrtc`'s re-bind path matches on. A track object replaced
///    under an unchanged track id - an ICE restart, a resubscribe - therefore
///    never reached the renderer, and the sink stayed on the dead track.
///  * disposing it on the way out clears, on darwin, whichever renderer is found
///    holding that track id first. With a grid tile and a full-screen view open
///    on the same track, closing one blacked the other.
///
/// The stream on a feed is the one the media SDK already owns. Attaching it
/// costs no platform call, keeps the plugin's own lifecycle handling, and is
/// never disposed from here.
///
/// [feed] is expected to change *value* (not mutate) whenever the underlying
/// media is replaced or cleared - feeds can't live in `Equatable` cubit state,
/// so callers re-read the current one from the webrtc service on every rebuild
/// driven by the cubit's `videoRevision` counter and pass whatever comes back.
class VideoParticipantTile extends StatefulWidget {
  const VideoParticipantTile({
    super.key,
    required this.feed,
    this.width = 160,
    this.height = 120,
    this.mirror = false,
    this.onHeightChanged,
    this.onHidden,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    this.borderRadius = 12,
    this.expectsVideo = true,
    this.label,
  });

  final VoiceVideoFeed? feed;

  /// What this tile is showing, for the fault log - a publisher's user id, or a
  /// share's id. Without it every black tile in a room records itself under the
  /// same subject, so the log collapses them into one entry and the one thing
  /// worth knowing - *whose* picture is missing - is the thing that is absent.
  final String? label;
  final double width;
  final double height;

  /// Whether a picture is owed here at all.
  ///
  /// True for every tile that is drawn *because* the roster says a camera is on,
  /// which is all of them today - and it is what lets a tile that never receives
  /// anything say so instead of spinning indefinitely. A tile drawn
  /// speculatively would pass false and simply wait.
  final bool expectsVideo;

  /// Cover for a grid tile, which is a fixed shape the picture has to fill.
  /// Contain for a full-screen one, where cropping to the device's aspect
  /// ratio would cut the sides off a 16:9 camera or a shared document.
  final RTCVideoViewObjectFit objectFit;

  final double borderRadius;

  /// Mirrors the video horizontally - used for the local front-camera
  /// self-preview so it behaves like every other camera app.
  final bool mirror;

  /// Called with this tile's height in **device pixels** whenever it changes,
  /// including the first layout. The server picks the simulcast layer this
  /// publisher is served at from it, so a tile that never reports is served
  /// the safe maximum - full quality into a thumbnail.
  ///
  /// Device pixels rather than logical ones because the layer is a question
  /// about the picture, and two phones drawing "120 logical pixels" want
  /// different amounts of video.
  final ValueChanged<int>? onHeightChanged;

  /// Called when the tile leaves the layout, so whoever is reporting can stop
  /// claiming a size for a picture that is no longer drawn.
  final VoidCallback? onHidden;

  @override
  State<VideoParticipantTile> createState() => _VideoParticipantTileState();
}

class _VideoParticipantTileState extends State<VideoParticipantTile> {
  final _renderer = RTCVideoRenderer();
  bool _rendererReady = false;
  int? _reportedHeight;

  /// The feed the renderer currently holds, so a rebuild with the same feed
  /// does not re-attach and a rebuild with a different one does.
  VoiceVideoFeed? _attached;

  /// Why the last attach failed, or null. Held rather than logged and dropped:
  /// this is the state the tile is stuck in, so it is the state the tile has to
  /// be able to say out loud.
  Object? _attachError;

  /// When this tile started expecting a picture. The clock the "nothing ever
  /// arrived" reading is measured from.
  final DateTime _mountedAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    await _renderer.initialize();
    if (!mounted) {
      await _renderer.dispose();
      return;
    }
    setState(() => _rendererReady = true);
    _attach(widget.feed);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Here rather than in `initState` because the device pixel ratio comes from
    // the media query, which is not available in `initState` and changes when
    // the tile moves to another display.
    _reportHeight();
  }

  @override
  void didUpdateWidget(covariant VideoParticipantTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    _attach(widget.feed);
    if (oldWidget.height != widget.height) _reportHeight();
  }

  /// The height is a laid-out constant rather than a measured `RenderBox`: this
  /// widget is given its size, so there is nothing to wait a frame for.
  void _reportHeight() {
    final report = widget.onHeightChanged;
    if (report == null) return;
    final devicePixels =
        (widget.height * MediaQuery.devicePixelRatioOf(context)).round();
    if (devicePixels == _reportedHeight) return;
    _reportedHeight = devicePixels;
    report(devicePixels);
  }

  /// Points the renderer at [feed].
  ///
  /// **Synchronous, which is the point.** `srcObject` is a plain setter; there
  /// is no await between deciding what to show and showing it, so two rebuilds
  /// in the same frame cannot land out of order and leave the renderer on the
  /// older of two feeds - which the previous asynchronous version could, and
  /// did, permanently.
  void _attach(VoiceVideoFeed? feed) {
    if (!_rendererReady) return;
    if (feed == _attached && _attachError == null) return;
    _attached = feed;
    try {
      // One renderer outlives several feeds here, and the platform emits a size
      // event only when the size *changes*. A new feed that never decodes would
      // otherwise leave the previous one's resolution on screen - which is
      // exactly the stale reading `ReceivedResolutionBadge` exists to rule out.
      _renderer.value = RTCVideoValue.empty;
      _renderer.srcObject = feed?.stream;
      if (_attachError != null) setState(() => _attachError = null);
    } catch (e) {
      // Nothing here is expected to throw any more - that is what removing the
      // platform round trip bought - so if one does, it is worth saying so on
      // the tile rather than discovering it from a black rectangle.
      setState(() => _attachError = e);
    }
  }

  @override
  void dispose() {
    widget.onHidden?.call();
    // The renderer only. The stream belongs to the media SDK and is shared with
    // every other tile on the same track; disposing it from here is what took
    // the other tile's picture down with this one.
    unawaited(_renderer.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.feed != null && _rendererReady)
                RTCVideoView(
                  _renderer,
                  objectFit: widget.objectFit,
                  mirror: widget.mirror,
                ),
              // Over the picture rather than instead of it. A tile can be
              // decoding and drawing while the *sender* is muted, and a fault
              // that replaced the view would throw away the last good frame.
              VoiceTileFaultOverlay(
                renderer: _renderer,
                health: widget.feed?.health,
                awaitingSince: widget.expectsVideo ? _mountedAt : null,
                attachError: _attachError,
                compact: widget.height < 200,
                label: widget.label,
              ),
              // Top right, because bottom left is already the sharer's name
              // label in `ScreenShareView`. Draws nothing at all unless the
              // diagnostics pref is on.
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ReceivedResolutionBadge(
                    renderer: _renderer,
                    reportedDevicePixels: _reportedHeight,
                    health: widget.feed?.health,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The spinner a tile shows while it is still reasonable to be waiting.
///
/// Extracted because the fault overlay decides when waiting stops being
/// reasonable, and both states have to be drawn by the same thing or they can
/// be on screen at once.
class VoiceTileSpinner extends StatelessWidget {
  const VoiceTileSpinner({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: AdaptiveProgressIndicator(
      size: 20,
      strokeWidth: 2,
      color: Colors.white54,
    ),
  );
}
