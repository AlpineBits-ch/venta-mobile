import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routing/deep_link_handler.dart';
import '../../../invites/presentation/widgets/invite_dialog.dart';

/// Opens a link tapped in message text, or on a link-preview card.
///
/// Anything Venta can handle itself stays in the app - an invite opens the
/// same popup the `venta://invite/…` deep link does, rather than bouncing out
/// to a browser and back. Everything else is somebody else's link and goes to
/// the system handler.
Future<void> openMessageLink(BuildContext context, String? href) async {
  if (href == null || href.isEmpty) return;
  final uri = Uri.tryParse(href);
  if (uri == null) return;

  switch (DeepLinkHandler.resolve(uri)) {
    case InviteTarget(:final code):
      await showDialog<void>(
        context: context,
        builder: (_) => InviteDialog(code: code),
      );
    case RouteTarget(:final path):
      if (context.mounted) context.push(path);
    case null:
      // `externalApplication` rather than an in-app webview: a link in a
      // message is untrusted, and the browser is where the address bar is.
      //
      // It is also the whole of this client's answer to an embed's player.
      // `video.url` is a third-party iframe document, and there is no
      // sandboxed frame to put it in here - handing it to the system handler
      // (which opens the provider's own app, the way Discord's mobile client
      // does) is the degraded card the backend guide asks for.
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Couldn\'t open that link.')),
          );
        }
      }
  }
}
