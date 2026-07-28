import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';

/// Lets a user point the client at a self-hosted instance instead of the
/// default `api.venta.gg` — mirrors Alpine's `ApiConfigService`. Wired up
/// for real once `AuthRepository` lands in Phase 1.
class ServerSetupScreen extends StatelessWidget {
  const ServerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Server')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Text(
            'Self-hosted server selection lands in Phase 1.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
