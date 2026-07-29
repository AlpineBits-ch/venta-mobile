import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../bloc/guild_voice_cubit.dart';

/// Full-screen "in-call" view for the currently joined guild voice channel.
/// Pushed via the root navigator (see `VoiceStatusBar`/`GuildDetailScreen`),
/// poppable at any time — leaving this screen does not disconnect, matching
/// Discord: voice stays connected while browsing text channels, and this
/// view is just one way of looking at it.
class GuildVoiceScreen extends StatelessWidget {
  const GuildVoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: BlocBuilder<GuildVoiceCubit, GuildVoiceState>(
          bloc: getIt<GuildVoiceCubit>(),
          builder: (context, state) => Text(
            state.channelName ?? 'Voice',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<GuildVoiceCubit, GuildVoiceState>(
          bloc: getIt<GuildVoiceCubit>(),
          builder: (context, state) {
            if (!state.isInVoice || state.channelId == null) {
              return const SizedBox.shrink();
            }
            final participants = state.rosterFor(state.channelId!);
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  Text(
                    state.guildName ?? '',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: state.phase == GuildVoicePhase.connecting
                        ? const Center(
                            child: Text('Connecting…', style: TextStyle(color: Colors.white70)),
                          )
                        : Center(
                            child: Wrap(
                              spacing: AppSpacing.l,
                              runSpacing: AppSpacing.l,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final participant in participants)
                                  _ParticipantTile(participant: participant),
                              ],
                            ),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: state.isMuted ? Icons.mic_off : Icons.mic,
                        background: state.isMuted ? Colors.white : Colors.white24,
                        iconColor: state.isMuted ? Colors.black : Colors.white,
                        onTap: () => getIt<GuildVoiceCubit>().toggleMute(),
                      ),
                      _ActionButton(
                        icon: state.isDeafened ? Icons.headset_off : Icons.headset,
                        background: state.isDeafened ? Colors.white : Colors.white24,
                        iconColor: state.isDeafened ? Colors.black : Colors.white,
                        onTap: () => getIt<GuildVoiceCubit>().toggleDeafen(),
                      ),
                      _ActionButton(
                        icon: state.isSpeakerOn ? Icons.volume_up : Icons.hearing,
                        background: state.isSpeakerOn ? Colors.white24 : Colors.white,
                        iconColor: state.isSpeakerOn ? Colors.white : Colors.black,
                        onTap: () => getIt<GuildVoiceCubit>().toggleSpeaker(),
                      ),
                      _ActionButton(
                        icon: Icons.call_end,
                        background: Colors.red,
                        onTap: () {
                          getIt<GuildVoiceCubit>().leave();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});
  final VoiceParticipantState participant;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            UserAvatar(userId: participant.userId, radius: 44, onTap: () {}),
            if (participant.isMuted)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Icon(Icons.mic_off, size: 14, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ProfileResolver(
          userId: participant.userId,
          builder: (context, profile) =>
              Text(profile?.userName ?? '…', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.background,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(radius: 30, backgroundColor: background, child: Icon(icon, color: iconColor)),
    );
  }
}
