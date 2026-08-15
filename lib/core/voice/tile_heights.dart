import 'dart:async';

import 'package:flutter/foundation.dart';

/// How large this client is drawing each publisher, reported to the server so
/// it can pick a simulcast layer per viewer.
///
/// This is the only measurement the server has. Without it a ranked room falls
/// back to a guess - the middle layer for cameras, full quality for screen
/// shares - and the guess is deliberately generous, because an unreadable tile
/// is worse than an expensive one. Reporting is therefore not an optimisation
/// on top of layer selection; it is the input that makes it choose anything but
/// the safe maximum.
///
/// Tiles are keyed by tile, not by publisher, because one participant can
/// occupy two of them at once - a camera thumbnail and a full-width screen
/// share - and the server wants the *largest*. Keying on the publisher would
/// make whichever tile rebuilt last overwrite the other, so a share would
/// intermittently be requested at thumbnail quality.
class VoiceTileHeights {
  VoiceTileHeights({
    required this.send,
    this.debounce = const Duration(milliseconds: 500),
  });

  /// Posts the complete map. The endpoint replaces the stored dictionary
  /// wholesale, so a publisher missing from it is a publisher this client is
  /// no longer drawing - which is why [_flush] always sends everything rather
  /// than a delta.
  final Future<void> Function(Map<String, int> tileHeights) send;

  /// Long enough to swallow a rotation or a layout settling, short enough that
  /// the layer follows the tile within a frame or two of the user seeing it.
  /// A resize is not free on the server - it recomputes a plan and can move a
  /// subscription - so this must never track an animation.
  final Duration debounce;

  final Map<String, ({String userId, int height})> _tiles = {};
  Map<String, int> _sent = const {};
  Timer? _timer;
  bool _disposed = false;

  /// Records the height, in **device pixels**, of one rendered tile.
  void set({
    required String tileId,
    required String userId,
    required int devicePixels,
  }) {
    if (devicePixels <= 0) return;
    final existing = _tiles[tileId];
    if (existing != null &&
        existing.userId == userId &&
        existing.height == devicePixels) {
      return;
    }
    _tiles[tileId] = (userId: userId, height: devicePixels);
    _schedule();
  }

  /// Drops a tile that is no longer on screen. The publisher stays in the map
  /// while any of their other tiles is still live.
  void remove(String tileId) {
    if (_tiles.remove(tileId) != null) _schedule();
  }

  /// Forgets everything without reporting. For a torn-down session, where the
  /// state this describes no longer exists on either side.
  void clear() {
    _timer?.cancel();
    _timer = null;
    _tiles.clear();
    _sent = const {};
  }

  void dispose() {
    _disposed = true;
    clear();
  }

  void _schedule() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer(debounce, _flush);
  }

  Future<void> _flush() async {
    _timer = null;
    if (_disposed) return;

    final heights = <String, int>{};
    for (final tile in _tiles.values) {
      final current = heights[tile.userId];
      if (current == null || tile.height > current) {
        heights[tile.userId] = tile.height;
      }
    }
    if (mapEquals(heights, _sent)) return;

    // Optimistic: a failed report must not be retried into a loop, and it
    // costs quality rather than correctness. Recording it as sent would strand
    // the value until something else moved, so the next resize reports it
    // again from scratch.
    final previous = _sent;
    _sent = heights;
    try {
      await send(heights);
    } catch (_) {
      if (!_disposed && mapEquals(_sent, heights)) _sent = previous;
    }
  }
}
