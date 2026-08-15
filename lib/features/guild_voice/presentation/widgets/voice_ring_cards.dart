import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../bloc/voice_ring_cubit.dart';

/// The stack of "come and join me in here" invitations asking this account in.
///
/// A stack rather than a slot: two different people can ask you into two
/// different channels at once, and each is answered independently. Newest first.
///
/// Inline and dismissible-by-answering, never fullscreen. That is the whole
/// difference between this and an incoming call - nobody is on the line, and an
/// invitation that takes the screen over is an interruption that was not asked
/// for. The same reasoning is why the push behind it is an ordinary alert rather
/// than a VoIP payload.
class VoiceRingCardStack extends StatelessWidget {
  const VoiceRingCardStack({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceRingCubit, VoiceRingState>(
      bloc: getIt<VoiceRingCubit>(),
      buildWhen: (previous, current) => previous.incoming != current.incoming,
      builder: (context, state) {
        if (state.incoming.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final ring in state.incoming)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: VoiceRingCard(ring: ring),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// One invitation.
class VoiceRingCard extends StatelessWidget {
  const VoiceRingCard({super.key, required this.ring});

  final IncomingRing ring;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = getIt<VoiceRingCubit>();
    final invitation = ring.invitation;
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.65);

    // `inviterName` can be null when the profile lookup failed. `inviterId`
    // never is, but a raw id is not a name to put in a sentence, so the card
    // falls back to saying nothing about who rather than saying an id.
    final who = invitation.inviterName?.trim();
    final channel = invitation.channelName?.trim();

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s + 2),
        child: Row(
          children: [
            Icon(Icons.headset_mic_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    who == null || who.isEmpty
                        ? 'Voice invite'
                        : '$who wants you in voice',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    [
                      if (channel != null && channel.isNotEmpty) channel,
                      if (invitation.participantUserIds.isNotEmpty)
                        '${invitation.participantUserIds.length} in here',
                      // Counted down from the server's own remaining-seconds
                      // rather than from a deadline, so a handset with a wrong
                      // clock still shows the truth.
                      '${ring.remainingSeconds}s',
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            // Obviously the decline button, and obviously distinct from letting
            // the card lapse: declining locks this inviter out of ringing again
            // for 15 minutes, then 2 hours, then 24. Letting it expire carries
            // none of that, so the two must not look like the same gesture.
            TextButton(
              onPressed: () => cubit.decline(ring.ringId),
              child: const Text('Decline'),
            ),
            const SizedBox(width: AppSpacing.xs),
            FilledButton(
              onPressed: () => cubit.accept(ring.ringId),
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
