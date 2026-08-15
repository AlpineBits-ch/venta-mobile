/// DEVELOPMENT HARNESS - slated for removal once phase 2 ships.
///
/// This screen exists to answer one question, and it is the only question
/// phase 1 of pantry vision set out to answer: **can these models actually read
/// a real cupboard** - side-on labels, things behind things, kitchen lighting.
/// Nobody knows until somebody points it at a shelf, and if the answer is no
/// that is a day spent rather than a month.
///
/// So it is deliberately ugly and deliberately raw. It shows elapsed time, the
/// item count, the `unreadable` number the model admitted to, one dense line
/// per item and the whole parsed payload underneath, because every one of those
/// is evidence about whether the thing works. None of it is shipped UI: the
/// real flow is capture -> propose -> resolve -> reconcile -> review -> apply,
/// and it looks nothing like this.
///
/// It is reachable from AI settings only, never from the pantry, so nobody
/// finds it by accident and mistakes it for the feature. When phase 2 lands,
/// delete this file, its route in `app_router.dart`, `RoutePaths
/// .pantryVisionHarness`, and the "Try it on a photo" row that opens it.
///
/// See `docs/pantry-vision.md`.
library;

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/ai/ai_key_store.dart';
import '../../../../core/ai/ai_provider.dart';
import '../../../../core/ai/pantry_vision_models.dart';
import '../../../../core/ai/vision_client.dart';
import '../../../../core/ai/vision_image_prep.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/adaptive_progress_indicator.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../../settings/presentation/screens/ai_settings_screen.dart';

class PantryVisionHarnessScreen extends StatefulWidget {
  const PantryVisionHarnessScreen({super.key});

  @override
  State<PantryVisionHarnessScreen> createState() =>
      _PantryVisionHarnessScreenState();
}

class _PantryVisionHarnessScreenState extends State<PantryVisionHarnessScreen> {
  final _keys = getIt<AiKeyStore>();
  final _client = getIt<PantryVisionClient>();
  final _picker = ImagePicker();

  AiProviderConfig? _config;

  /// The cost knob, and the whole reason this toggle is here: the image
  /// dominates the token count, so 2576px is roughly twice the price of 1568px
  /// per photo. Whether it buys anything on a real shelf of small print is one
  /// of the two things this harness is for.
  bool _detailed = false;

  bool _running = false;
  CancelToken? _cancelToken;

  PantryVisionResult? _result;
  int? _elapsedMs;
  AiFailure? _failure;

  /// Anything that isn't an [AiFailure] - a picker that threw, a permission
  /// refusal. Shown rather than swallowed: a harness that silently does nothing
  /// teaches nothing.
  String? _localError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadConfig());
  }

  @override
  void dispose() {
    _cancelToken?.cancel('screen closed');
    super.dispose();
  }

  Future<void> _loadConfig() async {
    final config = await _keys.readConfig();
    if (mounted) setState(() => _config = config);
  }

  /// Opens AI settings and re-reads the configuration on the way back. Both
  /// routes out of this screen exist because something was missing, so coming
  /// back to the same "No provider configured" line the user just fixed is the
  /// one outcome worth spending a state read on.
  Future<void> _openSettings() async {
    await context.push(RoutePaths.aiSettings);
    await _loadConfig();
  }

  Future<void> _run(ImageSource source) async {
    if (_running) return;

    // Before the picker, not after: the consent question is "may a photo be
    // sent", and asking it while the user is already holding a photo they took
    // is asking at the point it is hardest to say no.
    final provider = _config?.provider;
    if (provider == null) {
      setState(
        () => _failure = const AiFailure(AiFailureKind.notConfigured),
      );
      return;
    }
    final consented = await ensureVisionConsent(context, provider, _keys);
    if (!consented || !mounted) return;

    XFile? file;
    try {
      file = await _picker.pickImage(source: source);
    } catch (error) {
      if (mounted) setState(() => _localError = '$error');
      return;
    }
    if (file == null || !mounted) return;

    // Read before the awaits below, not inside them - and worth having in a
    // harness at all because "which language did it answer in" is one of the
    // things this screen exists to find out on a real shelf.
    final language = context.read<LocaleCubit>().effective;

    setState(() {
      _running = true;
      _result = null;
      _failure = null;
      _localError = null;
      _elapsedMs = null;
    });

    final stopwatch = Stopwatch()..start();
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    try {
      final bytes = await file.readAsBytes();
      // Off-thread: decoding and downscaling a 12-megapixel photo on the UI
      // isolate stalls it for long enough that the spinner this screen just put
      // up never paints, which reads as a hang at the exact moment the user is
      // waiting to find out whether the shot worked.
      final image = await prepareVisionImageOffThread(
        bytes,
        longEdge: _detailed ? kVisionLongEdgeDetailed : kVisionLongEdgeDefault,
      );
      final result = await _client.read(
        [image],
        language: language,
        cancelToken: cancelToken,
      );
      stopwatch.stop();
      if (!mounted) return;
      setState(() {
        _result = result;
        _elapsedMs = stopwatch.elapsedMilliseconds;
      });
    } on AiFailure catch (failure) {
      stopwatch.stop();
      if (!mounted) return;
      setState(() {
        _failure = failure;
        _elapsedMs = stopwatch.elapsedMilliseconds;
      });
    } catch (error) {
      stopwatch.stop();
      if (!mounted) return;
      setState(() {
        _localError = '$error';
        _elapsedMs = stopwatch.elapsedMilliseconds;
      });
    } finally {
      _cancelToken = null;
      if (mounted) setState(() => _running = false);
    }
  }

  void _cancel() => _cancelToken?.cancel('cancelled by user');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _config;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.aiSettings),
        title: const Text('Vision harness'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.m,
          AppSpacing.xl,
        ),
        children: [
          const _HarnessNotice(),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'Sending to',
            children: [
              SettingsRow(
                icon: Icons.smart_toy_outlined,
                title: config?.provider.label ?? 'No provider configured',
                subtitle: config?.model,
                onTap: () => unawaited(_openSettings()),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSection(
            label: 'Resolution',
            child: SwitchListTile.adaptive(
              title: const Text('Small print'),
              subtitle: Text(
                _detailed
                    ? '$kVisionLongEdgeDetailed px long edge - roughly double '
                          'the cost per photo'
                    : '$kVisionLongEdgeDefault px long edge',
              ),
              value: _detailed,
              onChanged: _running
                  ? null
                  : (value) => setState(() => _detailed = value),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          if (_running) ...[
            Row(
              children: [
                const AdaptiveProgressIndicator(size: 18, strokeWidth: 2),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Text(
                    'Reading the photo. This takes 5-15 seconds.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: _cancel, child: const Text('Cancel')),
            ),
          ] else
            // Wrapped rather than a Row: at 2.35x these two labels do not fit
            // side by side, and this screen still has to work in a kitchen.
            Wrap(
              spacing: AppSpacing.s,
              runSpacing: AppSpacing.s,
              children: [
                FilledButton.icon(
                  onPressed: () => unawaited(_run(ImageSource.camera)),
                  icon: const Icon(Icons.photo_camera_outlined, size: 20),
                  label: const Text('Take a photo'),
                ),
                OutlinedButton.icon(
                  onPressed: () => unawaited(_run(ImageSource.gallery)),
                  icon: const Icon(Icons.photo_library_outlined, size: 20),
                  label: const Text('Pick a photo'),
                ),
              ],
            ),
          if (_failure != null) ...[
            const SizedBox(height: AppSpacing.l),
            _FailureBlock(
              failure: _failure!,
              provider: config?.provider ?? AiProvider.anthropic,
              onOpenSettings: () => unawaited(_openSettings()),
            ),
          ],
          if (_localError != null) ...[
            const SizedBox(height: AppSpacing.l),
            SelectableText(
              _localError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: AppSpacing.l),
            _ResultBlock(result: _result!, elapsedMs: _elapsedMs ?? 0),
          ],
        ],
      ),
    );
  }
}

/// Says what this screen is, at the top, in the app. Somebody will find it
/// through settings search or a stale bookmark and needs to know within a
/// second that it is not the feature.
class _HarnessNotice extends StatelessWidget {
  const _HarnessNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tint.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, size: 20, color: tint),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              'Development harness. It sends one photo to the model and dumps '
              'what came back. Nothing here writes to your pantry.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FailureBlock extends StatelessWidget {
  const _FailureBlock({
    required this.failure,
    required this.provider,
    required this.onOpenSettings,
  });

  final AiFailure failure;
  final AiProvider provider;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: tint.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            failure.message(provider),
            style: theme.textTheme.titleSmall?.copyWith(color: tint),
          ),
          if (failure.detail != null) ...[
            const SizedBox(height: AppSpacing.s),
            // Selectable and unabridged: the provider's own words are the most
            // useful thing on the screen when an adapter is wrong, and they are
            // exactly what gets pasted into a bug report.
            SelectableText(
              failure.detail!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
          if (failure.kind == AiFailureKind.notConfigured) ...[
            const SizedBox(height: AppSpacing.s),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                onPressed: onOpenSettings,
                child: const Text('Set up a key'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({required this.result, required this.elapsedMs});

  final PantryVisionResult result;
  final int elapsedMs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      height: 1.5,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${elapsedMs}ms  ·  ${result.items.length} items  ·  '
          '${result.unreadable} unreadable',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.s),
        if (result.isEmpty)
          Text(
            'The model returned nothing it was willing to name.',
            style: theme.textTheme.bodyMedium,
          ),
        for (final item in result.items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: SelectableText(_itemLine(item), style: mono),
          ),
        const SizedBox(height: AppSpacing.m),
        Text('RAW', style: theme.textTheme.labelSmall),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          // The parsed result rather than the provider's envelope: what the app
          // believes is the thing worth checking against the shelf, and it is
          // also what phase 2 will act on.
          child: SelectableText(_prettyJson(result), style: mono),
        ),
      ],
    );
  }
}

/// One item, one line, every field the model gave. Dense on purpose - this is
/// read next to an open cupboard with the real shelf as the reference.
String _itemLine(PantryVisionItem item) {
  final parts = <String>[
    item.name,
    if (item.brand != null) item.brand!,
    if (item.size != null || item.unit != null)
      '${item.size ?? '?'}${item.unit ?? ''}',
    'x${item.count}',
    item.confidence.name,
    if (item.note != null) item.note!,
  ];
  return parts.join(' · ');
}

String _prettyJson(PantryVisionResult result) {
  return const JsonEncoder.withIndent('  ').convert({
    'items': [
      for (final item in result.items)
        {
          'name': item.name,
          'brand': item.brand,
          'size': item.size,
          'unit': item.unit,
          'count': item.count,
          'confidence': item.confidence.name,
          'note': item.note,
        },
    ],
    'unreadable': result.unreadable,
  });
}
