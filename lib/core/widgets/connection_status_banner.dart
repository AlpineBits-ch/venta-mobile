import 'dart:async';

import 'package:flutter/material.dart';

import '../di/injector.dart';
import '../realtime/realtime_service.dart';
import '../realtime/realtime_transport.dart';

/// Thin banner shown app-wide whenever the realtime hub connection isn't
/// live - mirrors desktop's `connection-status` indicator. Lives in
/// `AppShell`'s chrome (above the rail+content row, same idea as
/// `VoiceStatusBar`) so it's visible no matter which screen is active,
/// without every screen needing its own awareness of connection state.
class ConnectionStatusBanner extends StatefulWidget {
  const ConnectionStatusBanner({super.key});

  @override
  State<ConnectionStatusBanner> createState() => _ConnectionStatusBannerState();
}

class _ConnectionStatusBannerState extends State<ConnectionStatusBanner> {
  // Optimistic default - avoids a one-frame flash on cold start before the
  // first status event arrives.
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.connected;
  StreamSubscription<RealtimeConnectionStatus>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = getIt<RealtimeService>().connectionStatus.listen((status) {
      if (mounted) setState(() => _status = status);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _status != RealtimeConnectionStatus.connected;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              color: _status == RealtimeConnectionStatus.disconnected
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Text(
                    _status == RealtimeConnectionStatus.disconnected
                        ? 'Disconnected - trying to reconnect…'
                        : 'Connecting…',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _status == RealtimeConnectionStatus.disconnected
                          ? theme.colorScheme.onError
                          : theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
