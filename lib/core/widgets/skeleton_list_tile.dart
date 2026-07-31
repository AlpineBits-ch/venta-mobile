import 'package:flutter/material.dart';

import '../theme/widget_styles.dart';
import 'shimmer_box.dart';

/// Placeholder row shaped like a `ListTile`, shown while a list is loading
/// instead of a bare `CircularProgressIndicator` - content appears roughly
/// where it will actually render.
///
/// The second line is opt-in, and deliberately so: every list using this today
/// (DMs, channels, members) renders one line per row, and a skeleton promising
/// a subtitle that never arrives is the loading state telling you about a
/// feature the screen doesn't have. Pass `subtitle: true` from a list whose
/// rows really do have one.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key, this.subtitle = false});

  final bool subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(
                  width: 140,
                  height: 14,
                  borderRadius: AppRadii.badge,
                ),
                if (subtitle) ...[
                  const SizedBox(height: AppSpacing.xs),
                  const ShimmerBox(
                    width: 90,
                    height: 12,
                    borderRadius: AppRadii.badge,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
