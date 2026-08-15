import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/elapsed_time_label.dart';
import '../../bloc/guild_voice_cubit.dart';
import '../screens/guild_voice_screen.dart';
import 'voice_ring_invite_sheet.dart';

/// Persistent "connected to voice channel X" bar - the mobile analogue of
/// Alpine's `voice-status-bar`. Lives in `AppShell`'s chrome (not scoped to
/// any one route) so it survives navigating between text channels/guilds;
/// tapping it reopens the full `GuildVoiceScreen`, the hang-up button leaves
/// directly without navigating anywhere.
class VoiceStatusBar extends StatelessWidget {
  const VoiceStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuildVoiceCubit, GuildVoiceState>(
      bloc: getIt<GuildVoiceCubit>(),
      builder: (context, state) {
        if (!state.isInVoice) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Material(
          color: context.statusColors.sidebar,
          child: InkWell(
            onTap: () => Navigator.of(
              context,
              rootNavigator: true,
            ).push(MaterialPageRoute(builder: (_) => const GuildVoiceScreen())),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: state.phase == GuildVoicePhase.connecting
                        ? context.statusColors.idle
                        : context.statusColors.online,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              state.phase == GuildVoicePhase.connecting
                                  ? 'Connecting…'
                                  : 'Voice connected',
                              style: theme.textTheme.labelMedium,
                            ),
                            if (state.phase == GuildVoicePhase.active &&
                                state.connectedAt != null) ...[
                              Text(
                                ' · ',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              ElapsedTimeLabel(
                                since: state.connectedAt!,
                                style: theme.textTheme.labelMedium,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          '${state.channelName ?? ''} · ${state.guildName ?? ''}',
                          style: theme.textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Offered only while actually connected, and only from this
                  // bar, because the invitation's entire claim is "I am in
                  // here". Inviting from a channel you are merely looking at is
                  // refused server-side with a bare 403, which is a bug in the
                  // client rather than something to put on screen - so the
                  // affordance simply is not there to press.
                  if (state.phase == GuildVoicePhase.active &&
                      state.guildId != null &&
                      state.channelId != null)
                    IconButton(
                      icon: const Icon(Icons.person_add_alt),
                      tooltip: 'Invite to this channel',
                      onPressed: () => showVoiceRingInviteSheet(
                        context,
                        guildId: state.guildId!,
                        channelId: state.channelId!,
                        // Hidden rather than shown and refused: ringing
                        // somebody already in the channel answers `409` and the
                        // roster already says they are there.
                        alreadyInChannel: {
                          for (final p in state.rosterFor(state.channelId!))
                            p.userId,
                        },
                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.call_end, color: theme.colorScheme.error),
                    onPressed: () => getIt<GuildVoiceCubit>().leave(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
