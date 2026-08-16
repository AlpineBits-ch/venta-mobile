import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../diagnostics/voice_diagnostics.dart';
import '../theme/app_colors.dart';
import '../theme/widget_styles.dart';

/// This session's voice faults, in the order they happened.
///
/// **Reachable from the failure rather than from settings.** The two ways in
/// are the sentence a failed connect puts on screen and the card a black tile
/// draws over itself - both places somebody is already looking when they want
/// this. A panel filed under a developer menu is one nobody in a broken call
/// will find, which is the same reasoning that put the received-resolution
/// switch in the full-screen viewer's own app bar.
///
/// Read-only and copyable. What it is for is being pasted into a bug report by
/// somebody who is not going to attach a log file.
Future<void> showVoiceDiagnosticsSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => const VoiceDiagnosticsSheet(),
    );

class VoiceDiagnosticsSheet extends StatelessWidget {
  const VoiceDiagnosticsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: ValueListenableBuilder<List<VoiceDiagnosticEntry>>(
          valueListenable: VoiceDiagnostics.shared.entries,
          builder: (context, entries, _) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.l,
                  AppSpacing.l,
                  AppSpacing.s,
                  AppSpacing.s,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Voice diagnostics',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy',
                      onPressed: entries.isEmpty
                          ? null
                          : () => _copy(context, entries),
                      icon: const Icon(
                        Icons.copy_all_outlined,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Text(
                  'What this device recorded about voice this session. '
                  'Cleared when the app restarts.',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Flexible(
                child: entries.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'Nothing recorded.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.l,
                          0,
                          AppSpacing.l,
                          AppSpacing.l,
                        ),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.m),
                        itemBuilder: (context, index) =>
                            _EntryRow(entry: entries[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copy(BuildContext context, List<VoiceDiagnosticEntry> entries) {
    // Oldest first in the clipboard, newest first on screen: a list is read
    // top-down for "what is wrong now", and a report is read as a sequence.
    final text = entries.reversed
        .map(
          (e) =>
              '${e.at.toIso8601String()} ${e.reference} '
              '${e.subject ?? ''} ${e.detail ?? ''}'.trimRight(),
        )
        .join('\n');
    unawaitedCopy(text);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied voice diagnostics')));
  }
}

/// Fire-and-forget clipboard write. Split out so the caller reads as one line
/// and the analyzer still sees the future handled.
void unawaitedCopy(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final VoiceDiagnosticEntry entry;

  @override
  Widget build(BuildContext context) {
    final time = entry.at.toLocal();
    final clock =
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              entry.isError ? Icons.error_outline : Icons.info_outline,
              size: 15,
              color: entry.isError
                  ? Colors.orangeAccent
                  : AppColors.darkTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              entry.reference,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
            const Spacer(),
            Text(
              clock,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        if (entry.subject != null)
          Padding(
            padding: const EdgeInsets.only(left: 21, top: 2),
            child: Text(
              entry.subject!,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
            ),
          ),
        if (entry.detail != null)
          Padding(
            padding: const EdgeInsets.only(left: 21, top: 2),
            child: Text(
              entry.detail!,
              style: const TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
