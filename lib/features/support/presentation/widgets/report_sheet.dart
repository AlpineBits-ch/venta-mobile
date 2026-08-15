import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../friends/data/relationship_repository.dart';
import '../../data/models/report_dto.dart';
import '../../data/models/report_evidence.dart';
import '../../data/support_api.dart';
import '../../data/support_repository.dart';

/// Everything a report needs to know about what it is reporting.
///
/// [targetUserId] is always the account being reported, whatever [subjectKind]
/// points at - a report on a message is a report on its author, and the server
/// requires it either way.
class ReportTarget {
  const ReportTarget({
    required this.targetUserId,
    required this.subjectKind,
    required this.title,
    this.subjectId,
    this.displayName,
    this.evidence,
    this.evidenceMessages = const [],
    this.offerBlock = true,
  });

  final String targetUserId;
  final ReportSubjectKind subjectKind;

  /// Required by the server for everything except a plain user report.
  final String? subjectId;

  /// What the sheet is titled - "Report message", "Report @alice".
  final String title;

  /// Who, for the Block offer afterwards. Null falls back to neutral wording.
  final String? displayName;

  /// The snapshot to attach, already trimmed by `ReportEvidence.build`, or null
  /// when there is nothing to attach.
  final Map<String, dynamic>? evidence;

  /// The same snapshot in the form the review sheet renders. Held alongside
  /// rather than parsed back out of [evidence]: the user is being shown what is
  /// about to be uploaded, and reconstructing that from the wire blob is one
  /// more place for the two to drift apart.
  final List<EvidenceMessage> evidenceMessages;

  /// Whether to offer "Block them too" after submitting. False for a server
  /// report - blocking whoever owns it is not what that user is asking for.
  final bool offerBlock;
}

/// Opens the report flow and handles everything after it - the confirmation,
/// the merged case, and the offer to block.
///
/// Lives here rather than at each entry point so all four surfaces behave
/// identically; a report filed from a member list and one filed from a message
/// should not confirm differently.
Future<void> showReportSheet(BuildContext context, ReportTarget target) async {
  final submission = await showModalBottomSheet<ReportSubmissionDto>(
    context: context,
    isScrollControlled: true,
    // The shell's nav rail is a sibling of the content Navigator, so without
    // this the sheet is clipped to the content pane instead of the device.
    useRootNavigator: true,
    builder: (_) => _ReportSheet(target: target),
  );
  if (submission == null || !context.mounted) return;

  final blockable = target.offerBlock && !await _isBlocked(target.targetUserId);
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // A quiet line, not a modal. Nothing here is a celebration.
      content: Text(
        submission.merged
            // The report folded into one already filed against this subject in
            // the last 24 hours. Saying "Report submitted" again would tell the
            // user a second report exists when it doesn't.
            ? 'Thanks, we\'ve added this to your earlier report.'
            : 'Thanks - this has been sent to the moderation team.',
      ),
      duration: const Duration(seconds: 6),
      action: blockable
          // The moment blocking is most useful: they have just told us this
          // person is a problem, and blocking works immediately where the
          // report is a queue.
          ? SnackBarAction(
              label: 'Block them',
              onPressed: () => _confirmBlock(context, target),
            )
          : null,
    ),
  );
}

Future<bool> _isBlocked(String userId) async {
  try {
    return await getIt<RelationshipRepository>().isBlocked(userId);
  } catch (_) {
    // An unreadable block list is not a reason to offer blocking someone who
    // is already blocked - treat unknown as blocked and simply don't offer.
    return true;
  }
}

Future<void> _confirmBlock(BuildContext context, ReportTarget target) async {
  final name = target.displayName ?? 'this person';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Block $name?'),
      content: const Text(
        'They won\'t be able to message you, call you, add you as a friend '
        'or mention you, and you won\'t see them either. They are not told.\n\n'
        'If you are friends, that ends - unblocking later does not bring it '
        'back.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(dialogContext).colorScheme.error,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Block'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  try {
    await getIt<RelationshipRepository>().block(target.targetUserId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name is blocked.')));
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not block them.')));
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.target});

  final ReportTarget target;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _detailsMaxLength = 4000;

  final _detailsController = TextEditingController();
  ReportReason? _reason;
  bool _submitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null || _submitting) return;
    setState(() => _submitting = true);
    final target = widget.target;
    try {
      final submission = await getIt<SupportRepository>().submitReport(
        targetUserId: target.targetUserId,
        subjectKind: target.subjectKind,
        subjectId: target.subjectId,
        reason: reason,
        details: _detailsController.text.trim(),
        evidence: target.evidence,
      );
      if (!mounted) return;
      Navigator.of(context).pop(submission);
    } on ReportRefusedException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _toast(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _toast('Could not send that report. Please try again.');
    }
  }

  void _toast(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final evidence = widget.target.evidenceMessages;

    return SafeArea(
      child: Padding(
        // Above the keyboard - the details field is the last thing on this
        // sheet and it is the whole reason someone scrolled down here.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.m,
              AppSpacing.l,
            ),
            children: [
              Text(widget.target.title, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Reports go to the moderation team. The person you report is '
                'not told who reported them.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              Text('WHAT\'S HAPPENING?', style: theme.textTheme.labelSmall),
              const SizedBox(height: AppSpacing.xs),
              // One flat list of all eleven. The three that are triaged
              // Critical sit in the body of it rather than under "Something
              // else", but nothing here promises how fast anything happens.
              RadioGroup<ReportReason>(
                groupValue: _reason,
                // `RadioGroup` takes no null handler, so the in-flight guard is
                // in the callback: changing the reason while the write is
                // already gone would move the control under a report that no
                // longer matches it.
                onChanged: (value) {
                  if (_submitting) return;
                  setState(() => _reason = value);
                },
                child: Column(
                  children: [
                    for (final reason in ReportReason.values)
                      RadioListTile<ReportReason>.adaptive(
                        value: reason,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(reason.label),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'ANYTHING ELSE? (OPTIONAL)',
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _detailsController,
                enabled: !_submitting,
                maxLines: 4,
                maxLength: _detailsMaxLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'What should a moderator know?',
                ),
              ),
              if (evidence.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.s),
                // Said out loud, with a way to check. Silently uploading a
                // slice of someone's private conversation - even their own - is
                // not something to do without telling them.
                _EvidenceNotice(
                  messages: evidence,
                  onReview: () => _showEvidence(context, evidence),
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              FilledButton(
                onPressed: _reason == null || _submitting ? null : _submit,
                child: _submitting
                    ? const AdaptiveProgressIndicator(size: 18, strokeWidth: 2)
                    : const Text('Submit report'),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEvidence(BuildContext context, List<EvidenceMessage> messages) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => _EvidenceReviewSheet(messages: messages),
    );
  }
}

class _EvidenceNotice extends StatelessWidget {
  const _EvidenceNotice({required this.messages, required this.onReview});

  final List<EvidenceMessage> messages;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = messages.length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  count == 1
                      ? 'This message will be included so a moderator can see '
                            'it.'
                      : '$count messages from this chat will be included so a '
                            'moderator can see the context.',
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onReview,
              child: const Text('Review what\'s included'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Exactly what is about to be uploaded, in the order it was sent.
class _EvidenceReviewSheet extends StatelessWidget {
  const _EvidenceReviewSheet({required this.messages});

  final List<EvidenceMessage> messages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            Text('What will be sent', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Attachments are described rather than uploaded, and nothing '
              'from any other conversation is included.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            for (final message in messages)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: message.reported
                      ? theme.colorScheme.error.withValues(alpha: 0.10)
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.reported)
                      Text(
                        'THE MESSAGE YOU\'RE REPORTING',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    Text(
                      message.content ??
                          'This message could not be read on this device.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: message.content == null
                            ? FontStyle.italic
                            : null,
                      ),
                    ),
                    for (final attachment in message.attachments)
                      Text(
                        attachment,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.s),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
