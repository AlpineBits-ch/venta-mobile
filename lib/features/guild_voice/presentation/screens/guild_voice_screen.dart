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
import '../../../../core/widgets/voice_fullscreen_view.dart';
import '../../../../core/widgets/voice_limits_bar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../bloc/guild_voice_cubit.dart';

/// Full-screen "in-call" view for the currently joined guild voice channel.
/// Pushed via the root navigator (see `VoiceStatusBar`/`GuildDetailScreen`),
/// poppable at any time - leaving this screen does not disconnect, matching
/// Discord: voice stays connected while browsing text channels, and this
/// view is just one way of looking at it.
///
/// Deliberately always-dark regardless of the app's light/dark theme
/// setting - see the matching note in `CallScreen`.
class GuildVoiceScreen extends StatefulWidget {
  const GuildVoiceScreen({super.key});

  @override
  State<GuildVoiceScreen> createState() => _GuildVoiceScreenState();
}

class _GuildVoiceScreenState extends State<GuildVoiceScreen> {
  /// Screen shares are watched only while this screen is on top. Guild voice
  /// is explicitly a background activity - the user is expected to browse away
  /// and stay connected - so the viewer claim and the subscription behind it
  /// are held for the moments the stream is actually being looked at, and
  /// released the rest of the time.
  @override
  void initState() {
    super.initState();
    getIt<GuildVoiceCubit>().setSharesVisible(true);
  }

  @override
  void dispose() {
    getIt<GuildVoiceCubit>().setSharesVisible(false);
    super.dispose();
  }

  /// Opens one incoming picture full-screen.
  ///
  /// The tile id is deliberately not the grid tile's. Both are on screen at
  /// once - the grid stays mounted under the pushed route - and the server is
  /// told the *largest* size a publisher is drawn at, so two ids let the
  /// full-screen one win while it is open and let removing it fall back to the
  /// thumbnail without either having to know about the other.
  void _openFullscreen({
    required String userId,
    required String tileId,
    String? shareId,
  }) {
    final cubit = getIt<GuildVoiceCubit>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkAppBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
        // See `AppTheme` - built title, kept leading-aligned on both platforms.
        centerTitle: false,
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
                  // Between the room's identity and its contents, which is
                  // where a denominator belongs: "6 of 10" is a fact about the
                  // channel named directly above it, and the counts are what
                  // make a dimmed camera button explain itself rather than read
                  // as broken.
                  const SizedBox(height: AppSpacing.m),
                  VoiceLimitsBar(
                    limits: state.limits,
                    participantCount: participants.length,
                    videoNotice: state.videoNotice,
                  ),
                  const SizedBox(height: AppSpacing.l),
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
                        // Only somebody else's share is worth a size: the
                        // server picks a layer for what this client *pulls*,
                        // and nobody pulls their own picture.
                        onHeightChanged: sharer.userId == myUserId
                            ? null
                            : (devicePixels) =>
                                  getIt<GuildVoiceCubit>().reportTileHeight(
                                    tileId: 'share:${sharer.userId}',
                                    userId: sharer.userId,
                                    devicePixels: devicePixels,
                                  ),
                        onHidden: sharer.userId == myUserId
                            ? null
                            : () => getIt<GuildVoiceCubit>().forgetTile(
                                'share:${sharer.userId}',
                              ),
                        onTap: sharer.userId == myUserId
                            ? null
                            : () => _openFullscreen(
                                userId: sharer.userId,
                                tileId: 'share:${sharer.userId}',
                                shareId: sharer.shares.firstOrNull?.shareId,
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
                                    GestureDetector(
                                      onTap: () => _openFullscreen(
                                        userId: participant.userId,
                                        tileId:
                                            'camera:${participant.userId}',
                                      ),
                                      child: VideoParticipantTile(
                                        track: getIt<GuildVoiceCubit>()
                                            .remoteVideoTrackFor(
                                              participant.userId,
                                            ),
                                        onHeightChanged: (devicePixels) =>
                                            getIt<GuildVoiceCubit>()
                                                .reportTileHeight(
                                                  tileId:
                                                      'camera:${participant.userId}',
                                                  userId: participant.userId,
                                                  devicePixels: devicePixels,
                                                ),
                                        onHidden: () =>
                                            getIt<GuildVoiceCubit>().forgetTile(
                                              'camera:${participant.userId}',
                                            ),
                                      ),
                                    )
                                  else
                                    CallParticipantTile(
                                      userId: participant.userId,
                                      isMuted: participant.isMuted,
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
                        // Only for turning it on. Whatever the room's ceiling
                        // has become, the person already publishing must always
                        // be able to stop - a limit that traps a camera on is a
                        // far worse failure than one that keeps it off.
                        enabled:
                            getIt<GuildVoiceCubit>().isCameraOn ||
                            !getIt<GuildVoiceCubit>().isVideoBlocked,
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
                          enabled:
                              getIt<GuildVoiceCubit>().isScreenSharing ||
                              !getIt<GuildVoiceCubit>().isVideoBlocked,
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
