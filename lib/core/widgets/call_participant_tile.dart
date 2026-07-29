import 'package:flutter/material.dart';

import 'profile_resolver.dart';
import 'user_avatar.dart';

/// One participant's avatar + name in a call screen's roster — shared by
/// [CallScreen] and [GuildVoiceScreen]. Always rendered on the same
/// intentionally-dark call chrome, so text stays literal white rather than
/// theme-derived (matching the rest of that chrome).
class CallParticipantTile extends StatelessWidget {
  const CallParticipantTile({
    super.key,
    required this.userId,
    required this.isMuted,
  });

  final String userId;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(userId: userId, radius: 44, onTap: () {}),
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
