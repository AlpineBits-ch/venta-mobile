import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/media/camera_permission.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/household_api_wave2.dart';
import '../../data/models/pantry_dto.dart';
import '../widgets/household_widgets.dart';

/// Filling the pantry by camera, a bagful at a time.
///
/// This is the one screen where a phone beats a laptop outright, and it is
/// built around the actual moment: somebody standing at an open cupboard with a
/// shopping bag, unpacking with one hand. So the camera stays live and the
/// screen never navigates away between items. A scan confirms by feel - a
/// haptic tick and a line sliding onto the tally - and the next packet can go
/// straight under the lens.
///
/// **There is exactly one interruption**, and it is the first time this house
/// sees a barcode: there is no product database behind any of this and there
/// must not be one, so the house names its own things. Every scan after that is
/// silent, which is the whole reason the naming prompt is affordable.
///
/// The tally is not decoration either. Batch entry with no visible record is
/// how people end up scanning the same jar twice or missing one and not
/// knowing, so what this session added stays on screen and every line can be
/// taken back.
class PantryScannerScreen extends StatefulWidget {
  const PantryScannerScreen({
    super.key,
    required this.channelId,
    required this.channelName,
  });

  final String channelId;

  /// `#fridge`, for the one line of context the camera view has room for.
  final String channelName;

  @override
  State<PantryScannerScreen> createState() => _PantryScannerScreenState();
}

/// One thing this session put away, kept so it can be taken back.
class _Scanned {
  _Scanned({
    required this.item,
    required this.created,
    required this.quantityBefore,
  });

  final PantryItemDto item;

  /// Whether the scan added a row or topped up one that was already there -
  /// which is what "undo" has to mean two different things about.
  final bool created;
  final double quantityBefore;

  bool undone = false;
}

class _PantryScannerScreenState extends State<PantryScannerScreen> {
  /// `autoStart: false` so the camera only opens once permission has actually
  /// been granted - otherwise the plugin races the prompt and shows its own
  /// error view over the top.
  ///
  /// `DetectionSpeed.normal` rather than `noDuplicates`: a shopping bag holds
  /// four identical yoghurts, and refusing to read the same code twice would
  /// silently drop three of them. The repeat guard is [_recent], which is
  /// time-based and forgets.
  final _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.normal,
  );

  final _scanned = <_Scanned>[];

  /// Codes read in the last moment, so one packet held under the lens is not
  /// counted five times a second. Long enough to move a hand, short enough that
  /// the second identical yoghurt still goes in.
  final _recent = <String, DateTime>{};
  static const _repeatWindow = Duration(seconds: 3);

  bool _permissionDenied = false;
  bool _cameraReady = false;

  /// Set while a scan is in flight or a name is being asked for. Detection
  /// keeps running underneath; this only stops a second request being queued
  /// behind the first, which is what turns one busy moment into five.
  bool _busy = false;

  /// The last thing that happened, shown over the tally for a couple of
  /// seconds. Copy rather than a snackbar: a snackbar covers the tally, and the
  /// tally is the thing being confirmed.
  String? _toast;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_requestCamera());
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _requestCamera() async {
    final granted = await ensureCameraPermission();
    if (!mounted) return;
    if (!granted) {
      setState(() => _permissionDenied = true);
      return;
    }
    setState(() => _cameraReady = true);
    try {
      await _controller.start();
    } catch (_) {
      // MobileScanner's own errorBuilder renders the failure in place, and
      // there is nothing useful to add on top of it.
    }
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toast = message);
    _toastTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((raw) => raw != null && raw.isNotEmpty, orElse: () => null);
    if (value == null) return;

    final now = DateTime.now();
    final last = _recent[value];
    if (last != null && now.difference(last) < _repeatWindow) return;
    _recent[value] = now;

    await _scan(value);
  }

  Future<void> _scan(String barcode, {String? name}) async {
    setState(() => _busy = true);
    try {
      final before = _quantityOf(barcode);
      final result = await householdApi.scanPantryItem(
        widget.channelId,
        barcode: barcode,
        name: name,
      );
      if (!mounted) return;
      houseHaptic();
      setState(() {
        _scanned.insert(
          0,
          _Scanned(
            item: result.item,
            created: result.created,
            quantityBefore: before ?? result.item.quantity - 1,
          ),
        );
      });
      _showToast(
        result.created
            ? 'Added ${result.item.name}'
            : '${result.item.name} · ${formatQuantity(result.item.quantity)}'
                  '${result.item.unit == null ? '' : ' ${result.item.unit}'}',
      );
    } on PantryNameRequired {
      if (!mounted) return;
      await _askForName(barcode);
    } catch (error) {
      if (mounted) {
        _showToast(householdErrorText(error, 'That one did not go in.'));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  double? _quantityOf(String barcode) => _scanned
      .where((s) => !s.undone && s.item.barcode == barcode)
      .firstOrNull
      ?.item
      .quantity;

  /// The only thing that stops the camera, and only ever once per product.
  Future<void> _askForName(String barcode) async {
    await _controller.stop();
    if (!mounted) return;
    final name = await showHouseSheet<String>(
      context: context,
      builder: (_) => const _NameNewProductSheet(),
    );
    if (!mounted) return;
    unawaited(_controller.start());
    if (name == null || name.trim().isEmpty) {
      _showToast('Skipped - that one still needs a name');
      return;
    }
    await _scan(barcode, name: name.trim());
  }

  Future<void> _undo(_Scanned entry) async {
    setState(() => entry.undone = true);
    try {
      if (entry.created) {
        await householdApi.deletePantryItem(entry.item.id);
      } else {
        await householdApi.updatePantryItem(
          entry.item.id,
          quantity: entry.quantityBefore,
        );
      }
      if (mounted) _showToast('Took ${entry.item.name} back out');
    } catch (error) {
      if (!mounted) return;
      setState(() => entry.undone = false);
      _showToast(householdErrorText(error, 'Could not undo that.'));
    }
  }

  int get _addedCount => _scanned.where((s) => !s.undone).length;

  @override
  Widget build(BuildContext context) {
    // The one screen in the app whose background is a camera rather than the
    // theme's surface, so the status-bar icons are forced light here instead of
    // following the app theme into being invisible.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _permissionDenied
            ? _CameraDenied(onOpenSettings: () => unawaited(openAppSettings()))
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (_cameraReady)
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error) =>
                          const _CameraUnavailable(),
                    )
                  else
                    const ColoredBox(color: Colors.black),
                  const IgnorePointer(child: _ScanReticle()),
                  SafeArea(
                    child: Column(
                      children: [
                        _ScannerBar(
                          controller: _controller,
                          channelName: widget.channelName,
                          onClose: () => Navigator.of(context).pop(_addedCount),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: AppSpacing.xl),
                              child: _Hint(
                                busy: _busy,
                                hasScanned: _scanned.isNotEmpty,
                              ),
                            ),
                          ),
                        ),
                        if (_toast != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.m,
                              0,
                              AppSpacing.m,
                              AppSpacing.s,
                            ),
                            child: _ScanToast(message: _toast!),
                          ),
                        _Tally(
                          entries: _scanned,
                          onUndo: _undo,
                          onDone: () => Navigator.of(context).pop(_addedCount),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Top row: what is being filled, the torch, and the way out.
class _ScannerBar extends StatelessWidget {
  const _ScannerBar({
    required this.controller,
    required this.channelName,
    required this.onClose,
  });

  final MobileScannerController controller;
  final String channelName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            iconSize: 26,
            color: Colors.white,
            tooltip: 'Stop scanning',
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Text(
              'Filling $channelName',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(color: Colors.white),
            ),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, _) => IconButton(
              iconSize: 26,
              color: Colors.white,
              tooltip: state.torchState == TorchState.on
                  ? 'Turn the light off'
                  : 'Turn the light on',
              icon: Icon(
                state.torchState == TorchState.on
                    ? Icons.flashlight_on_rounded
                    : Icons.flashlight_off_rounded,
              ),
              onPressed: state.torchState == TorchState.unavailable
                  ? null
                  : () => unawaited(controller.toggleTorch()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A wide, short frame rather than a square: barcodes are wide, and a square
/// reticle invites people to hold the packet too far back to focus.
class _ScanReticle extends StatelessWidget {
  const _ScanReticle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.78,
        child: AspectRatio(
          aspectRatio: 2.2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.dialog),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.busy, required this.hasScanned});

  final bool busy;
  final bool hasScanned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = busy
        ? 'Putting it away…'
        : hasScanned
        ? 'Next one'
        : 'Hold a barcode in the frame';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.composerPill),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

/// The per-scan confirmation. Quiet on purpose: the haptic has already said it
/// worked, and this only says *what*.
class _ScanToast extends StatelessWidget {
  const _ScanToast({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_rounded,
              size: 18,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What went in this session, and the way out.
///
/// It grows to a few rows and then scrolls, so the camera keeps most of the
/// screen: the tally is a receipt, not the task. "Done" sits in it rather than
/// in the app bar because this screen is used one-handed and the top corners of
/// a phone are the two places a thumb cannot reach.
class _Tally extends StatelessWidget {
  const _Tally({
    required this.entries,
    required this.onUndo,
    required this.onDone,
  });

  final List<_Scanned> entries;
  final void Function(_Scanned) onUndo;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final live = entries.where((e) => !e.undone).toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadii.dialog),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
        AppSpacing.m,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (live.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.m),
              child: Text(
                'Nothing in yet. Everything you scan lands here, and you can '
                'take any of it back out.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            )
          else ...[
            HouseSectionHeader(
              label: live.length == 1 ? '1 thing put away' : 'Put away',
              trailing: Text('${live.length}'),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 168),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: live.length,
                itemBuilder: (context, index) =>
                    _TallyRow(entry: live[index], onUndo: onUndo),
              ),
            ),
            const SizedBox(height: AppSpacing.s),
          ],
          HousePrimaryButton(
            label: live.isEmpty
                ? 'Done'
                : live.length == 1
                ? 'Done · 1 thing'
                : 'Done · ${live.length} things',
            icon: Icons.check_rounded,
            onPressed: onDone,
          ),
        ],
      ),
    );
  }
}

class _TallyRow extends StatelessWidget {
  const _TallyRow({required this.entry, required this.onUndo});

  final _Scanned entry;
  final void Function(_Scanned) onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final unit = entry.item.unit?.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            entry.created
                ? Icons.add_circle_outline_rounded
                : Icons.arrow_upward_rounded,
            size: 16,
            color: muted,
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              entry.item.name,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            unit == null || unit.isEmpty
                ? formatQuantity(entry.item.quantity)
                : '${formatQuantity(entry.item.quantity)} $unit',
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
          IconButton(
            onPressed: () => onUndo(entry),
            visualDensity: VisualDensity.compact,
            iconSize: 20,
            tooltip: 'Take ${entry.item.name} back out',
            icon: const Icon(Icons.undo_rounded),
          ),
        ],
      ),
    );
  }
}

/// The only prompt in the flow: what this house calls a product it has never
/// seen. Asked once per barcode, ever.
class _NameNewProductSheet extends StatefulWidget {
  const _NameNewProductSheet();

  @override
  State<_NameNewProductSheet> createState() => _NameNewProductSheetState();
}

class _NameNewProductSheetState extends State<_NameNewProductSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HouseSheet(
      title: 'What is this?',
      actionLabel: 'Save and carry on',
      onAction: _controller.text.trim().isEmpty ? null : _save,
      children: [
        SheetField(
          label: 'Call it',
          child: TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_controller.text.trim().isNotEmpty) _save();
            },
            decoration: const InputDecoration(hintText: 'Oat milk'),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Only the first time. This house remembers the barcode, so every '
          'scan of it after this one goes straight in.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _CameraDenied extends StatelessWidget {
  const _CameraDenied({required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return _ScannerMessage(
      icon: Icons.no_photography_outlined,
      title: 'Camera access is off',
      body:
          'Scanning needs the camera. Turn it on in system settings and come '
          'back - you can always add things to the pantry by hand instead.',
      action: FilledButton(
        onPressed: onOpenSettings,
        child: const Text('Open settings'),
      ),
    );
  }
}

class _CameraUnavailable extends StatelessWidget {
  const _CameraUnavailable();

  @override
  Widget build(BuildContext context) {
    return const _ScannerMessage(
      icon: Icons.videocam_off_outlined,
      title: 'Camera unavailable',
      body:
          'The camera could not be started. Close anything else using it and '
          'try again.',
    );
  }
}

class _ScannerMessage extends StatelessWidget {
  const _ScannerMessage({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(0),
              color: Colors.white,
              tooltip: 'Back',
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 44, color: Colors.white70),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  if (action != null) ...[
                    const SizedBox(height: AppSpacing.l),
                    action!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
