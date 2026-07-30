import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/status_colors_extension.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/call_action_button.dart';
import '../../../../core/widgets/call_participant_tile.dart';
import '../../../../core/widgets/countdown_label.dart';
import '../../../../core/widgets/elapsed_time_label.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/screen_share_view.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/widgets/video_participant_tile.dart';
import '../../../auth/data/auth_repository.dart';
import '../../bloc/call_cubit.dart';

/// Full-screen call UI - covers both the incoming-call prompt and the
/// active-call controls, since both are just different renderings of the
/// same `CallCubit` state and the screen is pushed/popped as one unit by
/// `AppShell` whenever `CallState.phase` leaves/returns to idle.
///
/// Deliberately always-dark regardless of the app's light/dark theme
/// setting (same "photo viewer chrome" exception as `message_attachment_view`'s
/// full-screen image viewer) - text/icon colors below are the named
/// `AppColors` dark-surface tokens rather than `colorScheme.onSurface`,
/// which would invert unreadably if the app theme were light.
class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkAppBg,
        body: SafeArea(
          child: BlocBuilder<CallCubit, CallState>(
            builder: (context, state) {
              return switch (state.phase) {
                CallPhase.incoming => _IncomingCallView(
                  state: state,
                  myUserId: myUserId,
                ),
                CallPhase.idle => const SizedBox.shrink(),
                CallPhase.connecting || CallPhase.active => _ActiveCallView(
                  state: state,
                  myUserId: myUserId,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _IncomingCallView extends StatelessWidget {
  const _IncomingCallView({required this.state, required this.myUserId});
  final CallState state;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callerId = state.call?.participants
        .map((p) => p.userId)
        .firstWhere((id) => id != myUserId, orElse: () => '');
    final hasCaller = callerId != null && callerId.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasCaller) UserAvatar(userId: callerId, radius: 56, onTap: () {}),
          const SizedBox(height: AppSpacing.l),
          if (hasCaller)
            ProfileResolver(
              userId: callerId,
              builder: (context, profile) => Text(
                profile?.userName ?? '…',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Incoming call',
            style: TextStyle(color: AppColors.darkTextSecondary),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CallActionButton(
                icon: Icons.call_end,
                label: 'Decline',
                background: theme.colorScheme.error,
                onTap: () => context.read<CallCubit>().declineIncomingCall(),
              ),
              CallActionButton(
                icon: Icons.call,
                label: 'Accept',
                background: context.statusColors.online,
                onTap: () => context.read<CallCubit>().acceptIncomingCall(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }
}

class _ActiveCallView extends StatelessWidget {
  const _ActiveCallView({required this.state, required this.myUserId});
  final CallState state;
  final String myUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final others = state.participants
        .where((p) => p.userId != myUserId)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.m),
          Text(
            state.phase == CallPhase.connecting ? 'Connecting…' : 'Voice call',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.darkTextSecondary,
            ),
          ),
          if (state.phase == CallPhase.active && state.connectedAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            ElapsedTimeLabel(
              since: state.connectedAt!,
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
              ),
            ),
          ],
          if (state.aloneDeadline != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Waiting for others to rejoin - call ends in ',
                  style: TextStyle(color: context.statusColors.idle),
                ),
                CountdownLabel(
                  deadline: state.aloneDeadline!,
                  style: TextStyle(
                    color: context.statusColors.idle,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          for (final sharer in state.participants.where((p) => p.isStreaming))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.l),
              child: ScreenShareView(
                userId: sharer.userId,
                isSelf: sharer.userId == myUserId,
                track: sharer.userId == myUserId
                    ? context.read<CallCubit>().localScreenTrack
                    : context.read<CallCubit>().remoteScreenTrackFor(
                        sharer.userId,
                      ),
              ),
            ),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: AppSpacing.l,
                runSpacing: AppSpacing.l,
                alignment: WrapAlignment.center,
                children: [
                  if (context.read<CallCubit>().isCameraOn)
                    VideoParticipantTile(
                      track: context.read<CallCubit>().localVideoTrack,
                      mirror: true,
                    ),
                  if (others.isEmpty)
                    Text(
                      state.aloneDeadline != null
                          ? 'You\'re the only one here…'
                          : 'Ringing…',
                      style: TextStyle(color: AppColors.darkTextSecondary),
                    )
                  else
                    for (final participant in others)
                      if (participant.hasCamera)
                        VideoParticipantTile(
                          track: context.read<CallCubit>().remoteVideoTrackFor(
                            participant.userId,
                          ),
                        )
                      else
                        CallParticipantTile(
                          userId: participant.userId,
                          isMuted: participant.isMuted,
                          isSpeaking: participant.isSpeaking,
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
                background: state.isMuted ? Colors.white : Colors.white24,
                iconColor: state.isMuted ? Colors.black : Colors.white,
                onTap: () => context.read<CallCubit>().toggleMute(),
              ),
              CallActionButton(
                icon: state.isDeafened ? Icons.hearing_disabled : Icons.headset,
                label: state.isDeafened ? 'Undeafen' : 'Deafen',
                background: state.isDeafened ? Colors.white : Colors.white24,
                iconColor: state.isDeafened ? Colors.black : Colors.white,
                onTap: () => context.read<CallCubit>().toggleDeafen(),
              ),
              CallActionButton(
                icon: state.isSpeakerOn ? Icons.volume_up : Icons.phone_in_talk,
                label: state.isSpeakerOn ? 'Speaker' : 'Earpiece',
                background: state.isSpeakerOn ? Colors.white24 : Colors.white,
                iconColor: state.isSpeakerOn ? Colors.white : Colors.black,
                onTap: () => context.read<CallCubit>().toggleSpeaker(),
              ),
              CallActionButton(
                icon: context.read<CallCubit>().isCameraOn
                    ? Icons.videocam
                    : Icons.videocam_off,
                label: 'Camera',
                background: context.read<CallCubit>().isCameraOn
                    ? Colors.white
                    : Colors.white24,
                iconColor: context.read<CallCubit>().isCameraOn
                    ? Colors.black
                    : Colors.white,
                onTap: () => context.read<CallCubit>().toggleCamera(),
              ),
              if (Platform.isAndroid)
                CallActionButton(
                  icon: context.read<CallCubit>().isScreenSharing
                      ? Icons.stop_screen_share
                      : Icons.screen_share,
                  label: 'Share',
                  background: context.read<CallCubit>().isScreenSharing
                      ? Colors.white
                      : Colors.white24,
                  iconColor: context.read<CallCubit>().isScreenSharing
                      ? Colors.black
                      : Colors.white,
                  onTap: () => context.read<CallCubit>().toggleScreenShare(),
                ),
              CallActionButton(
                icon: Icons.call_end,
                label: 'End',
                background: theme.colorScheme.error,
                onTap: () => context.read<CallCubit>().endCall(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
        ],
      ),
    );
  }
}
