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
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
