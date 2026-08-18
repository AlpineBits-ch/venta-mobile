import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../guild_voice/bloc/guild_voice_cubit.dart';
import '../../bloc/call_cubit.dart';
import '../../bloc/voice_resume_cubit.dart';

/// "You were connected to a voice channel - do you want to reconnect?"
///
/// Raised once per launch after a force quit or a crash, which are the two ways
/// out of a voice room that skip the leave path. See [VoiceResumeCubit] for why
/// the Dismiss button is the load-bearing half.
class VoiceResumeBanner extends StatefulWidget {
  const VoiceResumeBanner({super.key});

  @override
  State<VoiceResumeBanner> createState() => _VoiceResumeBannerState();
}

class _VoiceResumeBannerState extends State<VoiceResumeBanner> {
  /// Resolved once, defensively, and **never from `build`** - same reasoning as
  /// `RecoveryCodeBanner`: this sits in `AppShell`, so an exception out of its
  /// build is the whole app rendering nothing rather than one missing offer.
  VoiceResumeCubit? _resume;
  GuildVoiceCubit? _guildVoice;
  CallCubit? _call;

  @override
  void initState() {
    super.initState();
    try {
      _resume = getIt<VoiceResumeCubit>();
      _guildVoice = getIt<GuildVoiceCubit>();
      _call = getIt<CallCubit>();
    } catch (e) {
      debugPrint('VoiceResumeBanner: nothing to ask, staying hidden: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final resume = _resume;
    final guildVoice = _guildVoice;
    final call = _call;
    if (resume == null || guildVoice == null || call == null) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<VoiceResumeCubit, VoiceResumeState>(
      bloc: resume,
      builder: (context, state) {
        final offer = state.offer;
        if (offer == null) return const SizedBox.shrink();

        // Suppressed the moment this client is in a room of the kind the offer
        // is about - which includes the reconnect this banner just started, and
        // also covers someone who answered the question by doing before getting
        // round to the banner. `VoiceStatusBar` and the call screen take over
        // from there; two "you are in voice" surfaces at once is one too many.
        //
        // Watched rather than checked once, because both are live: the cubit
        // asks the server at launch and the answer can be overtaken at any
        // point afterwards.
        return BlocBuilder<GuildVoiceCubit, GuildVoiceState>(
          bloc: guildVoice,
          builder: (context, voiceState) => BlocBuilder<CallCubit, CallState>(
            bloc: call,
            builder: (context, callState) {
              final busyElsewhere = switch (offer) {
                ChannelResumeOffer() => voiceState.isInVoice,
                CallResumeOffer() => callState.phase != CallPhase.idle,
              };
              if (busyElsewhere) return const SizedBox.shrink();
              return _Bar(offer: offer, busy: state.busy, resume: resume);
            },
          ),
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.offer, required this.busy, required this.resume});

  final VoiceResumeOffer offer;
  final bool busy;
  final VoiceResumeCubit resume;

  String get _message => switch (offer) {
    CallResumeOffer() => 'You were in a call. Rejoin?',
    ChannelResumeOffer(:final channelName) =>
      channelName == null || channelName.isEmpty
          ? 'You were connected to a voice channel. Reconnect?'
          : 'You were connected to $channelName. Reconnect?',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              Icon(
                Icons.headset_mic_outlined,
                size: 18,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  _message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: busy ? null : resume.reconnect,
                child: const Text('Reconnect'),
              ),
              TextButton(
                onPressed: busy ? null : resume.dismiss,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
