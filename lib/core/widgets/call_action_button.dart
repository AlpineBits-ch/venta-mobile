import 'package:flutter/material.dart';

/// One circular control in a call screen's action row (mute/deafen/speaker/
/// end-call, etc.) - shared by [CallScreen] and [GuildVoiceScreen] so their
/// controls stay visually identical instead of being copy-pasted per screen.
class CallActionButton extends StatelessWidget {
  const CallActionButton({
    super.key,
    required this.icon,
    required this.background,
    required this.onTap,
    this.iconColor = Colors.white,
    this.label,
    this.enabled = true,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final String? label;

  /// False for a control that would only be refused - a camera in an
  /// audio-only room, a share where every slot is taken.
  ///
  /// **Dimmed and inert, never hidden.** A control that vanishes takes its own
  /// explanation with it: the user is left looking for a button they used
  /// yesterday, with nothing on screen connecting its absence to the room. Left
  /// in place and faded, it is the thing the counts and the sentence beside it
  /// are about. It also comes straight back when the room does, without the
  /// action row reflowing under somebody's thumb mid-call.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: background,
                child: Icon(icon, color: iconColor),
              ),
              if (label != null) ...[
                const SizedBox(height: 4),
                Text(
                  label!,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
