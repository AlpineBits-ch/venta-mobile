import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/crypto/account_encryption_service.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../screens/recovery_code_setup_screen.dart';

/// Offers the recovery-code setup when the account has no recovery-code
/// wrapping (contract §C.1.1).
///
/// A banner rather than a modal, and dismissible for the session. Every account
/// in the field is in this state, so a blocking gate would meet every existing
/// user with a wall on the launch after an update - and the thing being offered
/// is an improvement to an account that works today, not a repair to one that
/// does not. Nothing about the app is degraded while it goes unanswered; the
/// account is simply still one password reset away from losing its encrypted
/// history, which is exactly what it was before this shipped.
///
/// It comes back on the next launch until a code is actually confirmed. That is
/// the point: a prompt shown once and never again is how §C.1.1 stays inactive
/// for the people who tapped past it.
class RecoveryCodeBanner extends StatefulWidget {
  const RecoveryCodeBanner({super.key});

  @override
  State<RecoveryCodeBanner> createState() => _RecoveryCodeBannerState();
}

class _RecoveryCodeBannerState extends State<RecoveryCodeBanner> {
  bool _dismissed = false;

  /// Resolved once, defensively, and **never from `build`**.
  ///
  /// This widget sits in `AppShell`, the root of every authenticated screen. An
  /// exception thrown out of its build method is not a missing banner - it is
  /// the whole app rendering nothing, which in a release build is a blank screen
  /// with no diagnostic and no way back. `getIt` throws for an unregistered
  /// type, and the ways a container can be short a registration at the moment a
  /// frame is built (a widget test, a background isolate, a reset mid-session, a
  /// later refactor of `configureDependencies`) are not a set worth betting the
  /// launch on. A cosmetic offer must degrade to nothing rather than take the
  /// shell with it.
  ValueListenable<bool>? _owed;

  @override
  void initState() {
    super.initState();
    try {
      _owed = getIt<AccountEncryptionService>().recoveryCodeOwed;
    } catch (e) {
      debugPrint(
        'RecoveryCodeBanner: no encryption service to ask, staying hidden: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final owedListenable = _owed;
    if (owedListenable == null) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: owedListenable,
      builder: (context, owed, _) {
        if (!owed || _dismissed) return const SizedBox.shrink();

        return Material(
          color: theme.colorScheme.secondaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.key_outlined,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'A password reset would erase your encrypted messages. '
                      'Save a recovery code.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                      rootNavigator: true,
                    ).push<bool>(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => const RecoveryCodeSetupScreen(),
                      ),
                    ),
                    child: const Text('Set up'),
                  ),
                  IconButton(
                    tooltip: 'Dismiss',
                    iconSize: 18,
                    onPressed: () => setState(() => _dismissed = true),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
