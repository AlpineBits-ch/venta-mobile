import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/call_action_button.dart';
import '../../../../core/widgets/call_participant_tile.dart';
import '../../../../core/widgets/elapsed_time_label.dart';
import '../../../../core/widgets/screen_share_view.dart';
import '../../../../core/widgets/video_participant_tile.dart';
import '../../../auth/data/auth_repository.dart';
import '../../bloc/guild_voice_cubit.dart';

/// Full-screen "in-call" view for the currently joined guild voice channel.
/// Pushed via the root navigator (see `VoiceStatusBar`/`GuildDetailScreen`),
/// poppable at any time — leaving this screen does not disconnect, matching
/// Discord: voice stays connected while browsing text channels, and this
/// view is just one way of looking at it.
///
/// Deliberately always-dark regardless of the app's light/dark theme
/// setting — see the matching note in `CallScreen`.
class GuildVoiceScreen extends StatelessWidget {
  const GuildVoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkAppBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        title: BlocBuilder<GuildVoiceCubit, GuildVoiceState>(
          bloc: getIt<GuildVoiceCubit>(),
          builder: (context, state) => Text(
            state.channelName ?? 'Voice',
            style: const TextStyle(color: AppColors.darkTextPrimary),
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
            final myUserId = getIt<AuthRepository>().currentUserId ?? '';
            final participants = state.rosterFor(state.channelId!);
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  Text(
                    state.guildName ?? '',
                    style: const TextStyle(color: AppColors.darkTextSecondary),
                  ),
                  if (state.phase == GuildVoicePhase.active &&
                      state.connectedAt != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    ElapsedTimeLabel(
                      since: state.connectedAt!,
                      style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  for (final sharer in participants.where((p) => p.isStreaming))
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.l),
                      child: ScreenShareView(
                        userId: sharer.userId,
                        isSelf: sharer.userId == myUserId,
                        track: sharer.userId == myUserId
                            ? getIt<GuildVoiceCubit>().localScreenTrack
                            : getIt<GuildVoiceCubit>().remoteScreenTrackFor(
                                sharer.userId,
                              ),
                      ),
                    ),
                  Expanded(
                    child: state.phase == GuildVoicePhase.connecting
                        ? const Center(
                            child: Text(
                              'Connecting…',
                              style: TextStyle(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          )
                        : Center(
                            child: Wrap(
                              spacing: AppSpacing.l,
                              runSpacing: AppSpacing.l,
                              alignment: WrapAlignment.center,
                              children: [
                                for (final participant in participants)
                                  if (participant.userId == myUserId &&
                                      participant.hasCamera)
                                    VideoParticipantTile(
                                      track: getIt<GuildVoiceCubit>()
                                          .localVideoTrack,
                                      mirror: true,
                                    )
                                  else if (participant.hasCamera)
                                    VideoParticipantTile(
                                      track: getIt<GuildVoiceCubit>()
                                          .remoteVideoTrackFor(
                                            participant.userId,
                                          ),
                                    )
                                  else
                                    CallParticipantTile(
                                      userId: participant.userId,
                                      isMuted: participant.isMuted,
                                    ),
                              ],
                            ),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CallActionButton(
                        icon: state.isMuted ? Icons.mic_off : Icons.mic,
                        label: state.isMuted ? 'Unmute' : 'Mute',
                        background: state.isMuted
                            ? Colors.white
                            : Colors.white24,
                        iconColor: state.isMuted ? Colors.black : Colors.white,
                        onTap: () => getIt<GuildVoiceCubit>().toggleMute(),
                      ),
                      CallActionButton(
                        icon: state.isDeafened
                            ? Icons.hearing_disabled
                            : Icons.headset,
                        label: state.isDeafened ? 'Undeafen' : 'Deafen',
                        background: state.isDeafened
                            ? Colors.white
                            : Colors.white24,
                        iconColor: state.isDeafened
                            ? Colors.black
                            : Colors.white,
                        onTap: () => getIt<GuildVoiceCubit>().toggleDeafen(),
                      ),
                      CallActionButton(
                        icon: state.isSpeakerOn
                            ? Icons.volume_up
                            : Icons.phone_in_talk,
                        label: state.isSpeakerOn ? 'Speaker' : 'Earpiece',
                        background: state.isSpeakerOn
                            ? Colors.white24
                            : Colors.white,
                        iconColor: state.isSpeakerOn
                            ? Colors.white
                            : Colors.black,
                        onTap: () => getIt<GuildVoiceCubit>().toggleSpeaker(),
                      ),
                      CallActionButton(
                        icon: getIt<GuildVoiceCubit>().isCameraOn
                            ? Icons.videocam
                            : Icons.videocam_off,
                        label: 'Camera',
                        background: getIt<GuildVoiceCubit>().isCameraOn
                            ? Colors.white
                            : Colors.white24,
                        iconColor: getIt<GuildVoiceCubit>().isCameraOn
                            ? Colors.black
                            : Colors.white,
                        onTap: () => getIt<GuildVoiceCubit>().toggleCamera(),
                      ),
                      if (Platform.isAndroid)
                        CallActionButton(
                          icon: getIt<GuildVoiceCubit>().isScreenSharing
                              ? Icons.stop_screen_share
                              : Icons.screen_share,
                          label: 'Share',
                          background: getIt<GuildVoiceCubit>().isScreenSharing
                              ? Colors.white
                              : Colors.white24,
                          iconColor: getIt<GuildVoiceCubit>().isScreenSharing
                              ? Colors.black
                              : Colors.white,
                          onTap: () =>
                              getIt<GuildVoiceCubit>().toggleScreenShare(),
                        ),
                      CallActionButton(
                        icon: Icons.call_end,
                        label: 'Leave',
                        background: Theme.of(context).colorScheme.error,
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
