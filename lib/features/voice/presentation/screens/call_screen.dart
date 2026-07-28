import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../bloc/call_cubit.dart';

/// Full-screen call UI — covers both the incoming-call prompt and the
/// active-call controls, since both are just different renderings of the
/// same `CallCubit` state and the screen is pushed/popped as one unit by
/// `AppShell` whenever `CallState.phase` leaves/returns to idle.
class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUserId = getIt<AuthRepository>().currentUserId ?? '';
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: BlocBuilder<CallCubit, CallState>(
            builder: (context, state) {
              return switch (state.phase) {
                CallPhase.incoming => _IncomingCallView(state: state),
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
  const _IncomingCallView({required this.state});
  final CallState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callerId = state.call?.participants.firstOrNull?.userId;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (callerId != null) UserAvatar(userId: callerId, radius: 56, onTap: () {}),
          const SizedBox(height: AppSpacing.l),
          if (callerId != null)
            ProfileResolver(
              userId: callerId,
              builder: (context, profile) => Text(
                profile?.userName ?? '…',
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
          const SizedBox(height: AppSpacing.xs),
          const Text('Incoming call', style: TextStyle(color: Colors.white70)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CallActionButton(
                icon: Icons.call_end,
                background: Colors.red,
                onTap: () => context.read<CallCubit>().declineIncomingCall(),
              ),
              _CallActionButton(
                icon: Icons.call,
                background: Colors.green,
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
    final others = state.participants.where((p) => p.userId != myUserId).toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.m),
          Text(
            state.phase == CallPhase.connecting ? 'Connecting…' : 'Voice call',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: Center(
              child: Wrap(
                spacing: AppSpacing.l,
                runSpacing: AppSpacing.l,
                alignment: WrapAlignment.center,
                children: [
                  if (others.isEmpty)
                    const Text('Ringing…', style: TextStyle(color: Colors.white70))
                  else
                    for (final participant in others) _ParticipantTile(participant: participant),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CallActionButton(
                icon: state.isMuted ? Icons.mic_off : Icons.mic,
                background: state.isMuted ? Colors.white : Colors.white24,
                iconColor: state.isMuted ? Colors.black : Colors.white,
                onTap: () => context.read<CallCubit>().toggleMute(),
              ),
              _CallActionButton(
                icon: state.isDeafened ? Icons.headset_off : Icons.headset,
                background: state.isDeafened ? Colors.white : Colors.white24,
                iconColor: state.isDeafened ? Colors.black : Colors.white,
                onTap: () => context.read<CallCubit>().toggleDeafen(),
              ),
              _CallActionButton(
                icon: Icons.call_end,
                background: Colors.red,
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

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});
  final CallParticipantState participant;

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
          builder: (context, profile) => Text(
            profile?.userName ?? '…',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _CallActionButton extends StatelessWidget {
  const _CallActionButton({
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
      child: CircleAvatar(
        radius: 30,
        backgroundColor: background,
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}
