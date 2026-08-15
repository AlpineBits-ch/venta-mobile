import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'adaptive_progress_indicator.dart';

/// Renders one live camera/screen-share video track - the video-capable
/// sibling of `CallParticipantTile`. Owns its own `RTCVideoRenderer` and
/// wraps whatever [track] currently is in a throwaway local `MediaStream`
/// (flutter_webrtc's renderer only accepts a stream, not a bare track).
///
/// [track] is expected to change *reference* (not mutate) whenever the
/// underlying `MediaStreamTrack` is replaced/cleared - `MediaStreamTrack`s
/// can't live in `Equatable` cubit state, so callers re-read the current
/// track from the webrtc service on every rebuild driven by the cubit's
/// `videoRevision` counter and pass whatever comes back.
class VideoParticipantTile extends StatefulWidget {
  const VideoParticipantTile({
    super.key,
    required this.track,
    this.width = 160,
    this.height = 120,
    this.mirror = false,
    this.onHeightChanged,
    this.onHidden,
    this.objectFit = RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    this.borderRadius = 12,
  });

  final MediaStreamTrack? track;
  final double width;
  final double height;

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
  MediaStream? _wrapperStream;
  bool _rendererReady = false;
  int? _reportedHeight;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _renderer.initialize();
    if (!mounted) {
      await _renderer.dispose();
      return;
    }
    _rendererReady = true;
    await _attachTrack(widget.track);
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
    if (oldWidget.track?.id != widget.track?.id) {
      unawaited(_attachTrack(widget.track));
    }
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

  Future<void> _attachTrack(MediaStreamTrack? track) async {
    if (!_rendererReady) return;
    final previousStream = _wrapperStream;
    _wrapperStream = null;
    if (track == null) {
      _renderer.srcObject = null;
    } else {
      final stream = await createLocalMediaStream('video-tile-${track.id}');
      await stream.addTrack(track);
      if (!mounted) {
        await stream.dispose();
        return;
      }
      _wrapperStream = stream;
      setState(() => _renderer.srcObject = stream);
    }
    await previousStream?.dispose();
  }

  @override
  void dispose() {
    widget.onHidden?.call();
    _renderer.dispose();
    _wrapperStream?.dispose();
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
          child: widget.track == null || !_rendererReady
              ? const Center(
                  child: AdaptiveProgressIndicator(
                    size: 20,
                    strokeWidth: 2,
                    color: Colors.white54,
                  ),
                )
              : RTCVideoView(
                  _renderer,
                  objectFit: widget.objectFit,
                  mirror: widget.mirror,
                ),
        ),
      ),
    );
  }
}
