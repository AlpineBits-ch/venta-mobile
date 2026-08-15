import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'profile_resolver.dart';
import 'video_participant_tile.dart';

/// Full-width "spotlight" view of one active screen share - the Discord-
/// style prominent treatment for `kind: "screen"` tracks, as opposed to the
/// small avatar-sized `VideoParticipantTile` used for camera video. Reuses
/// the same renderer plumbing, just laid out larger with a name label.
class ScreenShareView extends StatelessWidget {
  const ScreenShareView({
    super.key,
    required this.userId,
    required this.track,
    required this.isSelf,
    this.onHeightChanged,
    this.onHidden,
  });

  final String userId;
  final MediaStreamTrack? track;
  final bool isSelf;

  /// See `VideoParticipantTile.onHeightChanged`. A share is the largest thing
  /// on the screen and the most expensive thing in the room, so it is the tile
  /// where reporting a size is worth the most.
  final ValueChanged<int>? onHeightChanged;

  /// See `VideoParticipantTile.onHidden`.
  final VoidCallback? onHidden;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            VideoParticipantTile(
              track: track,
              width: width,
              height: width * 9 / 16,
              onHeightChanged: onHeightChanged,
              onHidden: onHidden,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: isSelf
                      ? const Text(
                          'You are sharing your screen',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        )
                      : ProfileResolver(
                          userId: userId,
                          builder: (context, profile) => Text(
                            '${profile?.userName ?? '…'} is sharing',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
