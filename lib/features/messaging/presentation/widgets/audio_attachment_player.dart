import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/models/attachment_dto.dart';
// Back-import of the file that builds this player. Deliberate, and the same
// reasoning that makes `resolveAttachmentDownloadUrl` public over there: the
// save button carries wording and failure behaviour that must not fork between
// the file chip, the image viewer and this header row, so there is one of it.
import 'message_attachment_view.dart';

/// Playback level, shared by every player in the session.
///
/// Module scope rather than per-widget state: somebody who turned a clip down
/// did that because this conversation is loud, and having the next clip start
/// back at full volume is the behaviour they were trying to avoid. Deliberately
/// not persisted and never written to settings - a level chosen for one session
/// is not a preference, and the OS volume keys are where a lasting one belongs.
final ValueNotifier<double> _sharedVolume = ValueNotifier<double>(1);

/// Widest a player is allowed to get, so a clip on a tablet doesn't stretch to
/// the full column. Same cap `MessageEmbedsView` puts on a preview card. Public
/// because the parent sizes the box this goes in and has to know it.
const audioPlayerMaxWidth = 400.0;

/// File extension for a recorded content type, for the temp file the bytes are
/// written to.
///
/// Android's extractor sniffs the container but leans on the extension when the
/// header is ambiguous, and an extensionless file is exactly the "this plays
/// everywhere else" failure. iOS is told the type outright (see
/// [_AudioAttachmentPlayerState._sourceMimeType]) so this matters less there.
const _extensionByContentType = <String, String>{
  'audio/mpeg': '.mp3',
  'audio/mp3': '.mp3',
  'audio/mp4': '.m4a',
  'audio/x-m4a': '.m4a',
  'audio/aac': '.aac',
  'audio/ogg': '.ogg',
  'audio/opus': '.opus',
  'audio/webm': '.webm',
  'audio/wav': '.wav',
  'audio/wave': '.wav',
  'audio/x-wav': '.wav',
  'audio/flac': '.flac',
  'audio/x-flac': '.flac',
  'audio/3gpp': '.3gp',
  'audio/amr': '.amr',
};

/// An inline player for an audio attachment - mobile's counterpart to Alpine's
/// `AudioAttachmentComponent`.
///
/// **The bytes are downloaded through [ApiClient] and played from a temp file
/// rather than streamed from [url].** The attachment download route is
/// `[Authorize]`d server-side (it answers `404`, not `401`, to an anonymous
/// caller), and the platform players sit outside Dio, so nothing would stamp a
/// bearer on their request. Handing [url] straight to `UrlSource` gets a body
/// that is an error page, which the decoder reports as nothing more useful than
/// "unsupported format". The download costs whole-file buffering with no ranged
/// seeking, which is the price of that route.
///
/// That download is deferred until the first play. A channel with a dozen clips
/// in the scrollback must not pull all of them down just to print a duration
/// nobody asked to see - which is why the total clock reads `0:00` and the
/// scrubber is inert until the play button has been pressed once.
class AudioAttachmentPlayer extends StatefulWidget {
  const AudioAttachmentPlayer({
    super.key,
    required this.attachment,
    required this.url,
  });

  final AttachmentDto attachment;

  /// Resolved by the parent rather than built here, so message-embedded and
  /// standalone attachments keep resolving their address in exactly one place
  /// (see `resolveAttachmentDownloadUrl`).
  final String url;

  @override
  State<AudioAttachmentPlayer> createState() => _AudioAttachmentPlayerState();
}

class _AudioAttachmentPlayerState extends State<AudioAttachmentPlayer> {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<void>> _subscriptions = [];

  bool _playing = false;
  bool _loading = false;

  /// Set once the player has a prepared source, so pausing and resuming does
  /// not fetch the file again.
  bool _loaded = false;
  bool _muted = false;

  /// The clip ran to the end. Held rather than acted on immediately: seeking a
  /// player back to zero is what the *next* press of play wants, and doing it
  /// in the completion handler would race the platform's own stop.
  bool _atEnd = false;

  /// Why playback failed, in as many words as we actually have. Null when
  /// nothing has gone wrong. Shown under the transport row.
  String? _failure;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  /// While the scrubber is under a finger, position events are ignored - the
  /// platform's stale ticks would otherwise yank the thumb back mid-drag.
  bool _scrubbing = false;

  @override
  void initState() {
    super.initState();
    // `stop` rather than the default `release`: releasing tears the decoder
    // down at the end of a clip, so replaying it would re-prepare (and on
    // Android re-read) a file that is already sitting on disk.
    _player.setReleaseMode(ReleaseMode.stop);
    _applyVolume();
    _sharedVolume.addListener(_onSharedVolumeChanged);

    _subscriptions.addAll([
      _player.onPlayerStateChanged.listen((state) {
        if (!mounted) return;
        setState(() => _playing = state == PlayerState.playing);
      }),
      _player.onDurationChanged.listen((duration) {
        if (!mounted) return;
        // A stream of unknown length reports zero or a negative; a scrubber
        // cannot be drawn against that, so it stays disabled.
        setState(
          () => _duration = duration.isNegative ? Duration.zero : duration,
        );
      }),
      _player.onPositionChanged.listen((position) {
        if (!mounted || _scrubbing) return;
        setState(() => _position = position);
      }),
      _player.onPlayerComplete.listen((_) {
        if (!mounted) return;
        setState(() {
          _playing = false;
          _position = Duration.zero;
          _atEnd = true;
        });
      }),
    ]);
  }

  @override
  void dispose() {
    _sharedVolume.removeListener(_onSharedVolumeChanged);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    // Disposing stops playback too, which is what a clip scrolled far out of a
    // long list should do - the widget is torn down and rebuilt constantly and
    // audio still coming from a row nobody can see is a bug, not a feature.
    _player.dispose();
    super.dispose();
  }

  /// The type to hand the platform, or null when we have nothing worth saying.
  ///
  /// Load-bearing, not decoration: the download route answers
  /// `Content-Disposition: attachment`, and for anything it could not sniff a
  /// type for it answers `application/octet-stream`. iOS' `AVURLAsset` takes
  /// this as an override and will refuse a file outright on a type that tells
  /// it nothing about the codec - which is the "couldn't play this" you get on
  /// a file that plays fine everywhere else. So only a real `audio/*` is passed
  /// on; anything else is withheld and the platform is left to sniff, which is
  /// strictly better than being lied to.
  String? get _sourceMimeType {
    final declared = _normalisedContentType;
    return declared.startsWith('audio/') ? declared : null;
  }

  String get _normalisedContentType =>
      widget.attachment.contentType.split(';').first.trim().toLowerCase();

  /// Pushes the level at the platform and nothing else - no rebuild, because
  /// this also runs from `initState`, where marking the element dirty is the
  /// "setState() called during build" crash.
  void _applyVolume() {
    // Muting is a level of zero here rather than a separate flag, because the
    // remembered level lives in `_sharedVolume` either way and unmuting is just
    // reading it again.
    _player.setVolume(_muted ? 0 : _sharedVolume.value);
  }

  /// Another player on screen moved the shared level: follow it, and redraw so
  /// this one's slider and icon agree with it.
  void _onSharedVolumeChanged() {
    _applyVolume();
    if (mounted) setState(() {});
  }

  Future<void> _toggle() async {
    if (_loading) return;
    if (_playing) {
      await _player.pause();
      return;
    }
    if (!_loaded && !await _load()) return;
    try {
      if (_atEnd) {
        await _player.seek(Duration.zero);
        _atEnd = false;
      }
      await _player.resume();
    } catch (e) {
      // A codec the device cannot decode fails here and not at load, and
      // leaving the button stuck showing pause is worse than saying so.
      _fail(_detail(e));
    }
  }

  /// Downloads the clip and prepares the player against it.
  ///
  /// Returns whether the source is playable. On failure the loaded latch stays
  /// down so the next press retries from scratch, rather than re-failing
  /// against a player that never got a source.
  Future<bool> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final file = await _fetch();
      await _player.setSource(
        DeviceFileSource(file.path, mimeType: _sourceMimeType),
      );
      if (!mounted) return false;
      _loaded = true;
      return true;
    } catch (e) {
      if (mounted) _fail(_detail(e));
      return false;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// The clip on disk, downloaded if it isn't there yet.
  ///
  /// Cached by attachment id, which is immutable and content-addressed, so a
  /// row scrolled out of the list and back in - which destroys and rebuilds
  /// this widget - replays from disk instead of re-downloading. It goes in the
  /// temp directory precisely so eviction stays the platform's problem; nothing
  /// here is worth keeping across launches.
  ///
  /// Written to a sibling `.part` and renamed, the same way `SenderAvatarCache`
  /// does it: two rows for one clip can be loading at once, and a half-written
  /// file handed to a decoder is a corrupt clip rather than no clip.
  Future<File> _fetch() async {
    final root = Directory(
      '${(await getTemporaryDirectory()).path}/venta_audio',
    );
    if (!await root.exists()) await root.create(recursive: true);

    final file = File('${root.path}/${widget.attachment.id}$_extension');
    if (await file.exists() && await file.length() > 0) return file;

    final response = await getIt<ApiClient>().dio.get<List<int>>(
      widget.url,
      options: Options(responseType: ResponseType.bytes),
    );
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('empty response');
    }

    // Named per widget, not per file: the same clip can be on screen twice, and
    // two loads sharing one scratch name would interleave into one corrupt one.
    final part = File('${file.path}.$hashCode.part');
    await part.writeAsBytes(bytes, flush: true);
    await part.rename(file.path);
    return file;
  }

  String get _extension {
    final mapped = _extensionByContentType[_normalisedContentType];
    if (mapped != null) return mapped;
    // Nothing usable was recorded, so fall back to whatever the uploader's own
    // file was called - it is a guess, but it is the only one left.
    final dot = widget.attachment.fileName.lastIndexOf('.');
    if (dot <= 0 || dot == widget.attachment.fileName.length - 1) return '';
    return widget.attachment.fileName.substring(dot).toLowerCase();
  }

  void _fail(String detail) {
    // Dropped so the next press re-fetches rather than re-failing against a
    // source the platform has already given up on.
    _loaded = false;
    setState(() => _failure = detail);
  }

  /// As much of a reason as the failure actually carries. A status code when
  /// the download was refused, the exception's type otherwise - a bare
  /// "couldn't play this" with no hint is the dead control this replaced.
  String _detail(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      return status != null ? 'HTTP $status' : error.type.name;
    }
    if (error is TimeoutException) return 'timed out';
    if (error is FileSystemException) return 'storage';
    return error.runtimeType.toString();
  }

  /// `h:mm:ss` past the hour, `m:ss` below it.
  String _clock(Duration value) {
    final total = value.inSeconds;
    if (total <= 0) return '0:00';
    final seconds = (total % 60).toString().padLeft(2, '0');
    final minutes = (total ~/ 60) % 60;
    final hours = total ~/ 3600;
    if (hours == 0) return '$minutes:$seconds';
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // The parent hands this a tight width (a `Wrap` cannot size it otherwise),
    // and a tight constraint beats the cap below - so it is loosened here, and
    // the cap holds even in a caller that did not think to apply it.
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: _card(theme),
    );
  }

  Widget _card(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: audioPlayerMaxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _nameRow(theme),
          _transportRow(theme),
          // Only once there is something to hear. Before that it would be a
          // control that does nothing, on every untouched clip in a scrollback.
          if (_loaded) _volumeRow(theme),
          if (_failure != null) _failureRow(theme),
        ],
      ),
    );
  }

  Widget _nameRow(ThemeData theme) {
    return Row(
      children: [
        const Icon(Icons.audiotrack_outlined, size: 16),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            widget.attachment.fileName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: theme.textTheme.bodySmall,
          ),
        ),
        // Was "open externally", which handed the raw URL to the OS browser.
        // That was never an escape hatch, for exactly the reason the class doc
        // gives for playback: the route needs a bearer nothing outside Dio can
        // add, and it answers `404` without one - so the browser opened on an
        // error page. Saving the clip is the same fetch playback already does,
        // this time through a save dialog. See `saveAttachment`.
        AttachmentSaveButton(
          attachment: widget.attachment,
          iconSize: 16,
          compact: true,
        ),
      ],
    );
  }

  Widget _transportRow(ThemeData theme) {
    final clockStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Row(
      children: [
        _playButton(theme),
        const SizedBox(width: AppSpacing.xs),
        Text(_clock(_position), style: clockStyle),
        Expanded(child: _seekSlider(theme)),
        Text(_clock(_duration), style: clockStyle),
      ],
    );
  }

  Widget _playButton(ThemeData theme) {
    return Material(
      color: theme.colorScheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _loading ? null : _toggle,
        child: SizedBox(
          width: 32,
          height: 32,
          child: _loading
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : Icon(
                  _playing ? Icons.pause : Icons.play_arrow,
                  size: 18,
                  color: theme.colorScheme.onPrimary,
                ),
        ),
      ),
    );
  }

  Widget _seekSlider(ThemeData theme) {
    final total = _duration.inMilliseconds.toDouble();
    final value = _position.inMilliseconds.toDouble().clamp(0, total);
    return _compactSlider(
      theme,
      // Nothing to seek within until a duration is known, which is only after
      // the first play - an enabled scrubber over an unloaded clip would move
      // and then do nothing.
      onChanged: total <= 0
          ? null
          : (next) => setState(() {
              _scrubbing = true;
              _position = Duration(milliseconds: next.round());
            }),
      // Seek on release rather than on every drag tick: each seek is a platform
      // round-trip, and firing one per pixel makes the thumb fight the player.
      onChangeEnd: total <= 0
          ? null
          : (next) async {
              try {
                await _player.seek(Duration(milliseconds: next.round()));
              } finally {
                // Released even when the seek was refused, or the scrubber
                // would stop tracking playback for the rest of the session.
                _scrubbing = false;
              }
            },
      max: total <= 0 ? 1 : total,
      value: total <= 0 ? 0 : value.toDouble(),
    );
  }

  Widget _volumeRow(ThemeData theme) {
    final level = _muted ? 0.0 : _sharedVolume.value;
    return Row(
      children: [
        IconButton(
          icon: Icon(_volumeIcon(level), size: 16),
          visualDensity: VisualDensity.compact,
          tooltip: _muted ? 'Unmute' : 'Mute',
          onPressed: () {
            // Muting something already at zero would be a no-op the icon claims
            // it undid, so bring it back to audible instead.
            if (!_muted && _sharedVolume.value == 0) {
              _sharedVolume.value = 1;
            } else {
              setState(() => _muted = !_muted);
              _applyVolume();
            }
          },
        ),
        Expanded(
          child: _compactSlider(
            theme,
            value: level,
            max: 1,
            onChanged: (next) {
              // Dragging the slider is itself an unmute - leaving it muted
              // would make the drag visibly do nothing.
              _muted = false;
              // Assigning the shared level redraws every player on screen,
              // which is the point: the next clip starts where this one is.
              _sharedVolume.value = next;
              // Both repeated on purpose. Dragging back to the level that was
              // already stored notifies nobody, and this player would be left
              // silent behind an unmuted icon.
              _applyVolume();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  IconData _volumeIcon(double level) {
    if (level == 0) return Icons.volume_off;
    return level < 0.5 ? Icons.volume_down : Icons.volume_up;
  }

  /// A slider sized for a message row.
  ///
  /// Material's default thumb and 40px press overlay are drawn for a settings
  /// screen; at that size the control dominates a chat bubble. Only the metrics
  /// are overridden - every colour still comes off the ambient scheme.
  Widget _compactSlider(
    ThemeData theme, {
    required double value,
    required double max,
    required ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        activeTrackColor: theme.colorScheme.primary,
        inactiveTrackColor: theme.colorScheme.outlineVariant,
        thumbColor: theme.colorScheme.primary,
        disabledActiveTrackColor: theme.colorScheme.outlineVariant,
        disabledInactiveTrackColor: theme.colorScheme.outlineVariant,
        disabledThumbColor: theme.colorScheme.outlineVariant,
      ),
      child: Slider(
        value: value.clamp(0, max),
        max: max,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }

  Widget _failureRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        "Couldn't play this file ($_failure)",
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
