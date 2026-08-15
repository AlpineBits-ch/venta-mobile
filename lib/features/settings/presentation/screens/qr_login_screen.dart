import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/media/camera_permission.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/button_progress_indicator.dart';
import '../../../auth/data/identity_api.dart';
import '../device_type_icon.dart';

enum _Stage {
  /// Waiting on the OS camera prompt.
  permission,

  /// Camera is live, looking for a code.
  scanning,

  /// A code was read; `/scan` is in flight.
  claiming,

  /// `/scan` came back - waiting for the user to approve or deny.
  confirming,

  /// `/approve` is in flight.
  deciding,

  /// Terminal: approved, denied, or failed.
  finished,
}

/// Scans a QR code shown by a desktop/web client and approves (or denies) that
/// device's login. Reached from the settings index
/// (`RoutePaths.qrLogin`).
///
/// This phone's own session is never touched - approving only authorises the
/// *other* device to fetch its own tokens, and no token material passes
/// through the two calls this screen makes.
class QrLoginScreen extends StatefulWidget {
  const QrLoginScreen({super.key});

  @override
  State<QrLoginScreen> createState() => _QrLoginScreenState();
}

class _QrLoginScreenState extends State<QrLoginScreen> {
  /// `autoStart: false` so the camera only ever opens after
  /// [ensureCameraPermission] has actually said yes - otherwise the plugin
  /// races the permission prompt and surfaces its own error view instead.
  final _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  _Stage _stage = _Stage.permission;
  bool _permissionDenied = false;
  String? _code;
  QrLoginTarget? _target;
  String? _error;

  /// Set the moment a barcode is accepted. The detection stream can emit again
  /// between `onDetect` firing and `stop()` completing, and a second `/scan`
  /// for the same code would 404 (already claimed) over the top of the
  /// confirmation screen.
  bool _consumed = false;

  @override
  void initState() {
    super.initState();
    _requestCamera();
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  Future<void> _requestCamera() async {
    final granted = await ensureCameraPermission();
    if (!mounted) return;
    if (!granted) {
      setState(() {
        _permissionDenied = true;
        _stage = _Stage.finished;
      });
      return;
    }
    setState(() => _stage = _Stage.scanning);
    await _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      await _controller.start();
    } catch (_) {
      // MobileScanner's own errorBuilder renders the failure in place; there's
      // nothing useful to add on top of it.
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_consumed) return;
    // The payload is an opaque string, so anything non-empty is worth trying -
    // validity is the server's call, not a shape we can check here.
    final value = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .firstWhere((raw) => raw != null && raw.isNotEmpty, orElse: () => null);
    if (value == null) return;

    _consumed = true;
    unawaited(_controller.stop());
    setState(() {
      _code = value;
      _stage = _Stage.claiming;
      _error = null;
    });

    try {
      final target = await getIt<IdentityApi>().scanQrLogin(value);
      if (!mounted) return;
      setState(() {
        _target = target;
        _stage = _Stage.confirming;
      });
    } on QrLoginCodeInvalidException {
      _fail(
        'This code is no longer valid. Ask the other device for a new one.',
      );
    } catch (_) {
      _fail('Could not check that code - try again.');
    }
  }

  Future<void> _decide(bool approve) async {
    final code = _code;
    if (code == null) return;
    setState(() {
      _stage = _Stage.deciding;
      _error = null;
    });
    try {
      await getIt<IdentityApi>().respondToQrLogin(code: code, approve: approve);
      if (!mounted) return;
      setState(() => _stage = _Stage.finished);
    } on QrLoginCodeInvalidException {
      _fail(
        'This code is no longer valid. Ask the other device for a new one.',
      );
    } on QrLoginNotYoursException {
      _fail('This code was scanned by a different account.');
    } catch (_) {
      // Which half failed matters: a failed *deny* leaves the code claimed but
      // undecided, so it lapses on its own within the three-minute window.
      _fail(
        approve
            ? 'Could not approve that login - try again.'
            : 'Could not send the denial. The code expires on its own shortly.',
      );
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _stage = _Stage.finished;
    });
  }

  /// Back to a live camera from any terminal state, without rebuilding the
  /// screen - the permission is already granted at this point.
  Future<void> _scanAgain() async {
    setState(() {
      _consumed = false;
      _code = null;
      _target = null;
      _error = null;
      _stage = _Stage.scanning;
    });
    await _startCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.settings),
        title: const Text('Scan QR Code'),
        actions: [
          if (_stage == _Stage.scanning)
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) => IconButton(
                tooltip: 'Torch',
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flashlight_on
                      : Icons.flashlight_off,
                ),
                onPressed: state.torchState == TorchState.unavailable
                    ? null
                    : () => unawaited(_controller.toggleTorch()),
              ),
            ),
        ],
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    switch (_stage) {
      case _Stage.permission:
        return const Center(child: CircularProgressIndicator.adaptive());
      case _Stage.scanning:
      case _Stage.claiming:
        return _ScannerView(
          controller: _controller,
          onDetect: _onDetect,
          busy: _stage == _Stage.claiming,
        );
      case _Stage.confirming:
      case _Stage.deciding:
        return _ConfirmView(
          target: _target!,
          busy: _stage == _Stage.deciding,
          onApprove: () => _decide(true),
          onDeny: () => _decide(false),
        );
      case _Stage.finished:
        if (_permissionDenied) {
          return _MessageView(
            icon: Icons.no_photography_outlined,
            tone: _Tone.error,
            title: 'Camera access is off',
            body:
                'Venta needs the camera to read the QR code on your other '
                'device. Turn it on in system settings, then come back.',
            primaryLabel: 'Open settings',
            onPrimary: () => unawaited(openAppSettings()),
          );
        }
        if (_error != null) {
          return _MessageView(
            icon: Icons.error_outline,
            tone: _Tone.error,
            title: 'Didn\'t work',
            body: _error!,
            primaryLabel: 'Scan again',
            onPrimary: _scanAgain,
          );
        }
        return _MessageView(
          icon: Icons.check_circle_outline,
          tone: _Tone.success,
          title: 'All set',
          body:
              '${_target?.deviceName ?? 'That device'} can finish signing in '
              'now. Nothing changed about this phone\'s session.',
          primaryLabel: 'Done',
          onPrimary: () => Navigator.of(context).maybePop(),
          secondaryLabel: 'Scan another',
          onSecondary: _scanAgain,
        );
    }
  }
}

/// The live camera with a cutout window. The window is cosmetic *and*
/// functional: the same rect is handed to the scanner so codes outside it are
/// ignored, which is what stops a second code elsewhere on a desktop screen
/// from being read instead of the one the user aimed at.
class _ScannerView extends StatelessWidget {
  const _ScannerView({
    required this.controller,
    required this.onDetect,
    required this.busy,
  });

  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side =
            constraints.biggest.shortestSide *
            (constraints.maxHeight > constraints.maxWidth ? 0.72 : 0.5);
        final window = Rect.fromCenter(
          center: Offset(
            constraints.maxWidth / 2,
            // Above centre, so the hint and the phone's own hand don't sit on
            // top of the code being framed.
            constraints.maxHeight * 0.42,
          ),
          width: side,
          height: side,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              scanWindow: window,
              onDetect: onDetect,
              errorBuilder: (context, error) => _MessageView(
                icon: Icons.videocam_off_outlined,
                tone: _Tone.error,
                title: 'Camera unavailable',
                body:
                    'The camera could not be started. Close anything else '
                    'using it and try again.',
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _CutoutPainter(
                  window: window,
                  scrim: Colors.black.withValues(alpha: 0.55),
                  border: busy
                      ? theme.colorScheme.primary
                      : Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.l,
              right: AppSpacing.l,
              top: window.bottom + AppSpacing.l,
              child: Text(
                busy
                    ? 'Checking that code...'
                    : 'Point the camera at the QR code on the device you want '
                          'to sign in.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            if (busy)
              Positioned(
                left: 0,
                right: 0,
                top: window.bottom + AppSpacing.xl + AppSpacing.l,
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CutoutPainter extends CustomPainter {
  const _CutoutPainter({
    required this.window,
    required this.scrim,
    required this.border,
  });

  final Rect window;
  final Color scrim;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final hole = RRect.fromRectAndRadius(
      window,
      const Radius.circular(AppRadii.dialog),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Offset.zero & size),
        Path()..addRRect(hole),
      ),
      Paint()..color = scrim,
    );
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = border,
    );
  }

  @override
  bool shouldRepaint(_CutoutPainter oldDelegate) =>
      oldDelegate.window != window || oldDelegate.border != border;
}

/// "`{deviceName}` wants to log in - is this you?". Never reached
/// automatically: a code sitting on a stranger's screen (phishing, or just a
/// public monitor) must not sign anyone in without this tap.
class _ConfirmView extends StatelessWidget {
  const _ConfirmView({
    required this.target,
    required this.busy,
    required this.onApprove,
    required this.onDeny,
  });

  final QrLoginTarget target;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.l),
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadii.dialog),
              ),
              child: Icon(
                deviceTypeIcon(target.deviceType),
                size: 48,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            target.deviceName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'wants to log in - is this you?',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.l),
          SettingsSectionNote(
            text:
                'Only approve this if you are looking at that device right '
                'now. Approving lets it sign in to your account; it does not '
                'sign you out here.',
          ),
          const SizedBox(height: AppSpacing.l),
          FilledButton(
            onPressed: busy ? null : onApprove,
            child: busy
                ? const ButtonProgressIndicator()
                : const Text('Yes, approve'),
          ),
          const SizedBox(height: AppSpacing.s),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: busy ? null : onDeny,
            child: const Text('No, deny'),
          ),
        ],
      ),
    );
  }
}

/// A short explanatory paragraph in the same card shape settings pages use, so
/// this screen's warning doesn't read as a differently-styled one-off.
class SettingsSectionNote extends StatelessWidget {
  const SettingsSectionNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Text(text, style: theme.textTheme.bodySmall),
    );
  }
}

enum _Tone { success, error }

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final _Tone tone;
  final String title;
  final String body;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tone == _Tone.error
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (primaryLabel != null) ...[
              const SizedBox(height: AppSpacing.l),
              FilledButton(onPressed: onPrimary, child: Text(primaryLabel!)),
            ],
            if (secondaryLabel != null) ...[
              const SizedBox(height: AppSpacing.s),
              TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
