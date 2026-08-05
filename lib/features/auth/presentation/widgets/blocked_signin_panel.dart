import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/widget_styles.dart';

/// What a restricted account sees instead of the sign-in form.
///
/// Not a toast and not a red line under the password field: the user cannot
/// proceed, retrying is not the answer, and leaving the form on screen invites
/// exactly the retry that ends at the rate limiter. It replaces the form.
///
/// Three things this screen must not contradict, all of them decided elsewhere:
///
///  * **One appeal per decision.** The appeal is filed on the support site, not
///    here, and a second submission is refused there. So there is no "request
///    another review" button, and there is no second appeal to offer.
///  * **A declined appeal is final.** Staff may still lift a restriction
///    afterwards at their own discretion - that is a thing that may happen to
///    someone, not a thing they can ask for, and rendering it as an action
///    guarantees a stream of requests that go nowhere.
///  * **An accepted appeal is not instant.** Granting records the decision and
///    a moderator issues the unban separately, so nothing here tells anyone to
///    go and try signing in.
///
/// There is deliberately no reference code and no reason on this screen. The
/// `403` carries neither - see `SigninNotAllowedException` - and the email
/// already has both. Inventing a placeholder for either would have the client
/// contradicting the one message that is actually specific.
class BlockedSignInPanel extends StatelessWidget {
  const BlockedSignInPanel({
    super.key,
    required this.supportUrl,
    required this.onUseDifferentAccount,
  });

  /// The instance's support desk, or null when it couldn't be derived. Null
  /// hides both links rather than rendering ones that go nowhere.
  final String? supportUrl;

  final VoidCallback onUseDifferentAccount;

  Future<void> _open(BuildContext context, String url) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (opened || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      // The address is shown rather than swallowed: with no way in through the
      // app, a browser the handset couldn't hand off to still leaves them
      // something they can type.
      SnackBar(content: Text('Could not open $url')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = supportUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.block, color: theme.colorScheme.error, size: 22),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: Text(
                // What happened, in the first line, before any policy.
                'You can\'t sign in to this account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          'Your account has been restricted by the moderation team.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'We emailed the address on this account with what happened, why, and '
          'a reference code.',
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
        ),
        if (url != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            'If you think this is wrong, you can appeal once.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.l),
          // The support site is anonymous precisely so these are reachable
          // while signed out - never say "contact support" without a link that
          // works from here.
          FilledButton(
            onPressed: () => _open(context, '$url/appeal'),
            child: const Text('Appeal this decision'),
          ),
          const SizedBox(height: AppSpacing.xs),
          OutlinedButton(
            onPressed: () => _open(context, url),
            child: const Text('Contact us'),
          ),
        ] else ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            'The email explains how to appeal.',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        const SizedBox(height: AppSpacing.xs),
        // No "retry" and no "reset password" anywhere on this screen. Neither
        // helps, and both read as the client not understanding its own state.
        TextButton(
          onPressed: onUseDifferentAccount,
          child: const Text('Try a different account'),
        ),
      ],
    );
  }
}
