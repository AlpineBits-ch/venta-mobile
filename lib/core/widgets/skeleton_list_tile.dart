import 'package:flutter/material.dart';

import '../theme/widget_styles.dart';
import 'shimmer_box.dart';

/// Placeholder row shaped like a `ListTile` (avatar + two text lines), shown
/// while a list is loading instead of a bare `CircularProgressIndicator` —
/// content appears roughly where it will actually render.
class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

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
              children: const [
                ShimmerBox(
                  width: 140,
                  height: 14,
                  borderRadius: AppRadii.badge,
                ),
                SizedBox(height: AppSpacing.xs),
                ShimmerBox(width: 90, height: 12, borderRadius: AppRadii.badge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
