import 'package:flutter/material.dart';

import 'profile_resolver.dart';
import 'user_avatar.dart';

/// One participant's avatar + name in a call screen's roster - shared by
/// [CallScreen] and [GuildVoiceScreen]. Always rendered on the same
/// intentionally-dark call chrome, so text stays literal white rather than
/// theme-derived (matching the rest of that chrome).
class CallParticipantTile extends StatelessWidget {
  const CallParticipantTile({
    super.key,
    required this.userId,
    required this.isMuted,
    this.isSpeaking = false,
  });

  final String userId;
  final bool isMuted;

  /// Draws the talking ring. Defaults to false so the guild-voice roster,
  /// which has no speaking events of its own yet, is unaffected.
  final bool isSpeaking;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Animated so the ring fades rather than strobing on and off with
            // every voice-activity flip.
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSpeaking
                      ? const Color(0xFF3BA55D)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: UserAvatar(userId: userId, radius: 44, onTap: () {}),
            ),
            if (isMuted)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic_off,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        ProfileResolver(
          userId: userId,
          builder: (context, profile) => Text(
            profile?.userName ?? '…',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
