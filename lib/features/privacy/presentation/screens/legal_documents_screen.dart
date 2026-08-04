import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/routing/route_paths.dart';
import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/settings_tiles.dart';
import '../../data/models/legal_document_dto.dart';
import '../../data/privacy_repository.dart';

/// The terms and policies in force, what this account has accepted, and the
/// Accept button for anything outstanding.
///
/// Documents are opened externally rather than rendered here. The version the
/// user accepts has to be the artifact the server hashed; re-rendering it
/// through a Markdown widget puts this client between the two, and a rendering
/// bug then becomes a consent record for text nobody read.
class LegalDocumentsScreen extends StatefulWidget {
  const LegalDocumentsScreen({super.key});

  @override
  State<LegalDocumentsScreen> createState() => _LegalDocumentsScreenState();
}

class _LegalDocumentsScreenState extends State<LegalDocumentsScreen> {
  List<LegalDocumentDto>? _documents;
  List<UserConsentDto> _consents = const [];
  bool _failed = false;

  /// Document types with an accept in flight.
  final Set<LegalDocumentType> _accepting = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    try {
      final repository = getIt<PrivacyRepository>();
      // Both, before either is rendered: a document list without the consents
      // beside it would show every policy as un-accepted for as long as the
      // second request takes, which is a prompt to re-accept things the user
      // already has.
      final documents = await repository.getLegalDocuments();
      final consents = await repository.getConsents();
      if (!mounted) return;
      setState(() {
        _documents = documents;
        _consents = consents;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  /// The version of [type] this account accepted, or null if it never has.
  String? _acceptedVersion(LegalDocumentType type) {
    for (final consent in _consents) {
      if (consent.documentType == type) return consent.version;
    }
    return null;
  }

  Future<void> _accept(LegalDocumentDto document) async {
    setState(() => _accepting.add(document.documentType));
    try {
      await getIt<PrivacyRepository>().acceptConsent(
        documentType: document.documentType,
        version: document.version,
      );
      if (!mounted) return;
      setState(() {
        _consents = [
          for (final c in _consents)
            if (c.documentType != document.documentType) c,
          UserConsentDto(
            documentType: document.documentType,
            version: document.version,
            acceptedAt: DateTime.now().toUtc(),
          ),
        ];
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not record your acceptance.')),
        );
      }
    } finally {
      if (mounted) setState(() => _accepting.remove(document.documentType));
    }
  }

  Future<void> _open(LegalDocumentDto document) async {
    // Falls back to the raw markdown route when no rendered page was given -
    // see `PrivacyApi.legalDocumentUrl`.
    final url = getIt<PrivacyRepository>().legalDocumentUrl(document);
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open that document.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final documents = _documents;
    final outstanding = [
      for (final d in documents ?? const <LegalDocumentDto>[])
        if (_acceptedVersion(d.documentType) != d.version) d,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: RoutePaths.privacy),
        title: const Text('Terms and policies'),
      ),
      body: switch ((_failed, documents)) {
        (true, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load the current terms and policies.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.m),
                FilledButton(onPressed: _load, child: const Text('Try again')),
              ],
            ),
          ),
        ),
        (_, null) => const Center(child: CircularProgressIndicator()),
        (_, final List<LegalDocumentDto> list) when list.isEmpty => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'This server hasn\'t published any terms or policies.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
        (_, final List<LegalDocumentDto> list) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.m,
            AppSpacing.xl,
          ),
          children: [
            if (outstanding.isNotEmpty) ...[
              _OutstandingBanner(count: outstanding.length),
              const SizedBox(height: AppSpacing.l),
            ],
            SettingsSection(
              label: 'Current versions',
              children: [
                for (final document in list)
                  _DocumentRow(
                    document: document,
                    acceptedVersion: _acceptedVersion(document.documentType),
                    accepting: _accepting.contains(document.documentType),
                    onOpen: () => _open(document),
                    onAccept: () => _accept(document),
                  ),
              ],
            ),
            const SettingsFootnote(
              'Accepting is recorded against your account with the version '
              'number and the date. To withdraw acceptance of the Terms or the '
              'Privacy Policy you would have to delete your account - the '
              'optional choices on the Privacy page can be changed at any '
              'time and are not affected.',
            ),
          ],
        ),
      },
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.document,
    required this.acceptedVersion,
    required this.accepting,
    required this.onOpen,
    required this.onAccept,
  });

  final LegalDocumentDto document;
  final String? acceptedVersion;
  final bool accepting;
  final VoidCallback onOpen;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final upToDate = acceptedVersion == document.version;
    return SettingsRow(
      icon: switch (document.documentType) {
        LegalDocumentType.terms => Icons.gavel_outlined,
        LegalDocumentType.privacy => Icons.lock_outline,
        LegalDocumentType.cookies => Icons.cookie_outlined,
      },
      title: document.documentType.label,
      subtitle: switch ((upToDate, acceptedVersion)) {
        (true, _) => 'Version ${document.version} - accepted',
        // Naming both versions rather than just "update available": a user
        // being asked to accept something again is entitled to know what they
        // accepted last time.
        (_, final String accepted) =>
          'You accepted $accepted - version ${document.version} is now current',
        _ => 'Version ${document.version} - not yet accepted',
      },
      onTap: onOpen,
      showChevron: false,
      trailing: upToDate
          ? const Icon(Icons.open_in_new, size: 18)
          : FilledButton(
              onPressed: accepting ? null : onAccept,
              child: const Text('Accept'),
            ),
    );
  }
}

class _OutstandingBanner extends StatelessWidget {
  const _OutstandingBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.primary;
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
          Icon(Icons.description_outlined, size: 20, color: tint),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              count == 1
                  ? 'One document has been updated since you last accepted '
                        'it. Open it below, then accept.'
                  : '$count documents have been updated since you last '
                        'accepted them. Open each below, then accept.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
