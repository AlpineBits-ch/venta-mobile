import 'package:flutter/material.dart';

import '../../features/billing/presentation/widgets/entitlement_notice.dart';
import '../theme/app_colors.dart';
import '../theme/widget_styles.dart';
import '../voice/voice_limits.dart';

/// What this room may carry, said quietly, and what happened to this device's
/// own video, said plainly.
///
/// Two registers on purpose. The counts are ambient - they sit under the room
/// title as denominators and answer "how full is this" before anybody asks, in
/// the same tone as a participant count. The notice is a sentence, and it is
/// there because something specific happened to the person reading it.
///
/// **The counts are the reason a disabled control is not a mystery.** A share
/// button that cannot be pressed with "1 of 1 sharing" beside it explains
/// itself; the same button with nothing beside it reads as a bug.
///
/// Absent limits render nothing at all rather than an empty rail of dashes. A
/// server that reports no limits is not a room with no ceilings, and drawing
/// "- of -" would claim to know something this client does not.
class VoiceLimitsBar extends StatelessWidget {
  const VoiceLimitsBar({
    super.key,
    required this.limits,
    required this.participantCount,
    this.videoNotice,
  });

  final VoiceRoomLimitsDto? limits;

  /// How many people this client currently draws in the room. The numerator;
  /// the denominator is the room's own ceiling.
  final int participantCount;

  /// One sentence about this device's own video - the rung a publish was
  /// clamped to, or why one did not happen. Null the rest of the time, which is
  /// almost always.
  final String? videoNotice;

  @override
  Widget build(BuildContext context) {
    final limits = this.limits;
    final notice = videoNotice;
    final chips = limits == null ? const <String>[] : _chipsFor(limits);

    if (chips.isEmpty && notice == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (chips.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.xs + 2,
            runSpacing: AppSpacing.xs,
            children: [for (final chip in chips) _LimitChip(label: chip)],
          ),
        if (notice != null) ...[
          SizedBox(height: chips.isEmpty ? 0 : AppSpacing.s + 2),
          EntitlementNotice(message: notice, onDark: true),
        ],
      ],
    );
  }

  /// The counts worth drawing, in the order somebody reads them: how many
  /// people, then how many pictures, then how good the picture is.
  ///
  /// A room with no ceiling on something contributes no chip for it rather than
  /// an "unlimited" one. "Unlimited" is a fact about a plan, and this rail is
  /// about a room - a chip reading "3 of unlimited" is noise on every screen it
  /// would ever appear on.
  List<String> _chipsFor(VoiceRoomLimitsDto limits) {
    final occupancy = limits.occupancyLabel(participantCount);
    final publishers = limits.publisherLabel;
    final rung = limits.videoRung;

    return [
      ?occupancy,
      ?publishers,
      // The bottom rung is a state rather than a resolution, so it is named as
      // one. Rendering the literal "none" beside two counts would read as a
      // missing value, which is the opposite of what it means.
      if (limits.isAudioOnly) 'Audio only' else ?rung,
    ];
  }
}

class _LimitChip extends StatelessWidget {
  const _LimitChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBorderSubtle,
        borderRadius: BorderRadius.circular(AppRadii.badge + 4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
