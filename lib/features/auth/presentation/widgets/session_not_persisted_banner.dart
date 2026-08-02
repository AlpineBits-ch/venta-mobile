import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../data/auth_repository.dart';

/// Says out loud that this sign-in will not survive closing the app.
///
/// Reached when a keychain write refused during login. The session itself is
/// fine - the tokens are in memory and every request works - so blocking the
/// user would be wrong. But so is saying nothing: they would find out by
/// relaunching, landing back on the login screen, and having no idea why. The
/// whole reason this class of fault went undiagnosed for a day is that each
/// layer degraded quietly.
///
/// Not dismissible, unlike the recovery-code offer. That one is an invitation;
/// this is a statement about the state of the session that stays true until it
/// ends.
class SessionNotPersistedBanner extends StatefulWidget {
  const SessionNotPersistedBanner({super.key});

  @override
  State<SessionNotPersistedBanner> createState() =>
      _SessionNotPersistedBannerState();
}

class _SessionNotPersistedBannerState extends State<SessionNotPersistedBanner> {
  /// Resolved once, in `initState`, and never from `build` - see
  /// `RecoveryCodeBanner` for why. This widget also sits in `AppShell`, so an
  /// exception out of its build is the whole app rendering nothing.
  ValueListenable<bool>? _persisted;

  @override
  void initState() {
    super.initState();
    try {
      _persisted = getIt<AuthRepository>().sessionPersisted;
    } catch (e) {
      debugPrint('SessionNotPersistedBanner: no auth repository, staying hidden: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listenable = _persisted;
    if (listenable == null) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: listenable,
      builder: (context, persisted, _) {
        if (persisted) return const SizedBox.shrink();

        return Material(
          color: theme.colorScheme.errorContainer,
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
                    Icons.lock_open_outlined,
                    size: 18,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: AppSpacing.s),
                  Expanded(
                    child: Text(
                      'This device could not save your sign-in, so you will '
                      'have to sign in again next time you open the app.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
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
