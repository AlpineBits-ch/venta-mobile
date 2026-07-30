import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/profile/data/models/profile_dto.dart';
import '../../features/profile/data/profile_repository.dart';
import '../di/injector.dart';

/// Resolves a [ProfileDto] by user id - checks `ProfileRepository`'s cache
/// synchronously first (instant for anyone already seen this session),
/// otherwise fetches once and rebuilds. Shared by anything that needs a
/// user's live name/avatar/status (`UserAvatar`, message author headers, …)
/// so the cache-then-fetch dance lives in exactly one place.
class ProfileResolver extends StatefulWidget {
  const ProfileResolver({
    super.key,
    required this.userId,
    required this.builder,
  });

  final String userId;
  final Widget Function(BuildContext context, ProfileDto? profile) builder;

  @override
  State<ProfileResolver> createState() => _ProfileResolverState();
}

class _ProfileResolverState extends State<ProfileResolver> {
  ProfileDto? _profile;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant ProfileResolver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _profile = null;
      _resolve();
    }
  }

  void _resolve() {
    final repository = getIt<ProfileRepository>();
    final cached = repository.cachedByUserId(widget.userId);
    if (cached != null) {
      _profile = cached;
      return;
    }
    repository
        .getByUserId(widget.userId)
        .then((profile) {
          if (mounted) setState(() => _profile = profile);
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _profile);
}

/// The [ProfileResolver] equivalent for *your own* profile: cache first, fetch
/// once if it isn't there, then stay subscribed to
/// [ProfileRepository.selfStream] so an avatar/status/bio change made anywhere
/// in the app rebuilds this too.
///
/// Screens can't assume the self profile is already loaded - any of them can be
/// cold-started directly from a persisted route with nothing else on the stack,
/// which is how the account page ended up showing a blank username.
class SelfProfileResolver extends StatefulWidget {
  const SelfProfileResolver({super.key, required this.builder});

  final Widget Function(BuildContext context, ProfileDto? profile) builder;

  @override
  State<SelfProfileResolver> createState() => _SelfProfileResolverState();
}

class _SelfProfileResolverState extends State<SelfProfileResolver> {
  ProfileDto? _profile;
  StreamSubscription<ProfileDto>? _subscription;

  @override
  void initState() {
    super.initState();
    final repository = getIt<ProfileRepository>();
    _profile = repository.cachedSelf;
    _subscription = repository.selfStream.listen((profile) {
      if (mounted) setState(() => _profile = profile);
    });
    if (_profile == null) {
      // Result arrives via `selfStream`; this only has to not blow up.
      repository.getSelf().then<void>(
        (_) {},
        onError: (Object e, StackTrace st) =>
            debugPrint('self profile fetch failed: $e\n$st'),
      );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _profile);
}
