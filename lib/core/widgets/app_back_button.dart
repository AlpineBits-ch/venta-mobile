import 'package:flutter/material.dart';
import '../routing/back_navigation.dart';

/// An `AppBar` `leading` back arrow that falls back to [fallbackLocation]
/// when there's nothing to pop.
///
/// Flutter's own automatic back button only appears when the current route
/// has something beneath it on the navigation stack. Every top-level screen
/// outside `AppShell`'s `ShellRoute` (channel, conversation, forum, ...) can
/// also be reached as the *only* stack entry - cold-start restore via
/// `RoutePersistence`, a deep link, or a tapped push notification all
/// replace the whole stack with just that route - which silently drops the
/// back button rather than erroring, easy to miss until someone actually
/// cold-starts into a channel.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, required this.fallbackLocation});

  final String fallbackLocation;

  @override
  Widget build(BuildContext context) {
    // Matches what `BackButtonIcon` picks per platform: iOS's back affordance
    // is a thin chevron, not Material's filled arrow. Worth spelling out even
    // though this is one file, because `AppBackButton` is the leading widget
    // on every screen outside the shell - the arrow is on-screen more than
    // any other icon in the app.
    final platform = Theme.of(context).platform;
    final isApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return IconButton(
      icon: Icon(isApple ? Icons.arrow_back_ios_new : Icons.arrow_back),
      tooltip: 'Back',
      onPressed: () => BackNavigation.goBack(context, fallbackLocation),
    );
  }
}
