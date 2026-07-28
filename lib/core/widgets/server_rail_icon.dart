import 'package:flutter/material.dart';

import '../theme/status_colors_extension.dart';

/// One circular icon in the Discord-style server rail (shown in the app's
/// `startDrawer`). `selected` draws the short pill indicator on the left
/// edge, exactly like Discord mobile's server list.
class ServerRailIcon extends StatelessWidget {
  const ServerRailIcon({
    super.key,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.label,
    this.backgroundColor,
  });

  final VoidCallback onTap;
  final bool selected;
  final IconData? icon;
  final String? label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 4,
            height: selected ? 32 : 0,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
            ),
          ),
          Center(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(selected ? 16 : 24),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: backgroundColor ?? context.statusColors.hover,
                  borderRadius: BorderRadius.circular(selected ? 16 : 24),
                ),
                child: icon != null
                    ? Icon(icon, color: theme.colorScheme.onSurface, size: 24)
                    : Text(
                        label ?? '',
                        style: theme.textTheme.titleSmall,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
