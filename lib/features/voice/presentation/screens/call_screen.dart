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
import '../../../../core/widgets/voice_fullscreen_view.dart';
import '../../../../core/widgets/voice_limits_bar.dart';
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
class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CallCubit? _cubit;

  /// Screen shares are watched only while this screen is mounted. Watching is
  /// announced explicitly rather than inferred from the subscription, because
  /// a subscribe has no teardown a client is obliged to send - and an
  /// unwatched stream that stays pulled costs the publisher egress for a
  /// picture nobody is looking at.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cubit = context.read<CallCubit>();
    if (identical(cubit, _cubit)) return;
    _cubit?.setSharesVisible(false);
    _cubit = cubit..setSharesVisible(true);
  }

  @override
  void dispose() {
    _cubit?.setSharesVisible(false);
    super.dispose();
  }

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

/// Opens one incoming picture full-screen.
///
/// The tile id is deliberately not the grid tile's. Both are on screen at once
/// - the grid stays mounted under the pushed route - and the server is told the
/// *largest* size a publisher is drawn at, so two ids let the full-screen one
/// win while it is open and let removing it fall back to the thumbnail without
/// either having to know about the other.
void _openFullscreen(
  BuildContext context,
  CallCubit cubit, {
  required String userId,
  required String tileId,
  String? shareId,
}) {
  final fullscreenTileId = 'full:$tileId';
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VoiceFullscreenView(
        userId: userId,
        isShare: shareId != null,
        updates: cubit.stream,
        track: () => shareId == null
            ? cubit.remoteVideoTrackFor(userId)
            : cubit.remoteScreenTrackForShare(shareId),
        // See the matching note in `GuildVoiceScreen`: the roster answers this,
        // not the track, so a picture that ends any of the several ways it can
        // closes this route without each of them being named here.
        isLive: () {
          final sharer = cubit.state.participants
              .where((p) => p.userId == userId)
              .firstOrNull;
          if (sharer == null) return false;
          return shareId == null
              ? sharer.hasCamera
              : sharer.shareById(shareId) != null;
        },
        onEnter: () => cubit.setFocus(userId: userId, shareId: shareId),
        onExit: () => cubit.setFocus(),
        onHeightChanged: (devicePixels) => cubit.reportTileHeight(
          tileId: fullscreenTileId,
          userId: userId,
          devicePixels: devicePixels,
        ),
        onHidden: () => cubit.forgetTile(fullscreenTileId),
      ),
    ),
  );
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
    // Held rather than read per tile because the tiles report their size back
    // through it, and one of those reports happens while the tile is being
    // disposed - where the element's `context` is no longer usable.
    final cubit = context.read<CallCubit>();

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
          // Under the call's own header, where a denominator belongs. A call
          // has no server plan behind it, so anything here came from an
          // operator ceiling - which is why the notice below is a sentence and
          // never a control.
          const SizedBox(height: AppSpacing.m),
          VoiceLimitsBar(
            limits: state.limits,
            participantCount: state.participants.length,
            videoNotice: state.videoNotice,
          ),
          const SizedBox(height: AppSpacing.l),
          for (final sharer in state.participants.where((p) => p.isStreaming))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.l),
              child: ScreenShareView(
                userId: sharer.userId,
                isSelf: sharer.userId == myUserId,
                track: sharer.userId == myUserId
                    ? cubit.localScreenTrack
                    : cubit.remoteScreenTrackFor(sharer.userId),
                // Only somebody else's share is worth a size: the server picks
                // a layer for what this client *pulls*, and nobody pulls their
                // own picture.
                onHeightChanged: sharer.userId == myUserId
                    ? null
                    : (devicePixels) => cubit.reportTileHeight(
                        tileId: 'share:${sharer.userId}',
                        userId: sharer.userId,
                        devicePixels: devicePixels,
                      ),
                onHidden: sharer.userId == myUserId
                    ? null
                    : () => cubit.forgetTile('share:${sharer.userId}'),
                onTap: sharer.userId == myUserId
                    ? null
                    : () => _openFullscreen(
                        context,
                        cubit,
                        userId: sharer.userId,
                        tileId: 'share:${sharer.userId}',
                        shareId: sharer.shares.firstOrNull?.shareId,
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
                  if (cubit.isCameraOn)
                    VideoParticipantTile(
                      track: cubit.localVideoTrack,
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
                        GestureDetector(
                          onTap: () => _openFullscreen(
                            context,
                            cubit,
                            userId: participant.userId,
                            tileId: 'camera:${participant.userId}',
                          ),
                          child: VideoParticipantTile(
                            track: cubit.remoteVideoTrackFor(
                              participant.userId,
                            ),
                            onHeightChanged: (devicePixels) =>
                                cubit.reportTileHeight(
                                  tileId: 'camera:${participant.userId}',
                                  userId: participant.userId,
                                  devicePixels: devicePixels,
                                ),
                            onHidden: () => cubit.forgetTile(
                              'camera:${participant.userId}',
                            ),
                          ),
                        )
                      else
                        CallParticipantTile(
                          userId: participant.userId,
                          isMuted: participant.isMuted,
                          isSpeaking: participant.isSpeaking,
                          isStreaming: participant.isStreaming,
                          viewerCount: participant.shares.fold(
                            0,
                            (n, s) => n + s.viewerCount,
                          ),
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
                icon: cubit.isCameraOn ? Icons.videocam : Icons.videocam_off,
                label: 'Camera',
                background: cubit.isCameraOn ? Colors.white : Colors.white24,
                iconColor: cubit.isCameraOn ? Colors.black : Colors.white,
                // Only for turning it on. Whatever the ceiling has become, the
                // person already publishing must always be able to stop.
                enabled: cubit.isCameraOn || !cubit.isVideoBlocked,
                onTap: () => cubit.toggleCamera(),
              ),
              if (Platform.isAndroid)
                CallActionButton(
                  icon: cubit.isScreenSharing
                      ? Icons.stop_screen_share
                      : Icons.screen_share,
                  label: 'Share',
                  background: cubit.isScreenSharing
                      ? Colors.white
                      : Colors.white24,
                  iconColor: cubit.isScreenSharing
                      ? Colors.black
                      : Colors.white,
                  enabled: cubit.isScreenSharing || !cubit.isVideoBlocked,
                  onTap: () => cubit.toggleScreenShare(),
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
