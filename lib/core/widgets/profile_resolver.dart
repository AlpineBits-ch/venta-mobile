import 'package:flutter/material.dart';

import '../../features/profile/data/models/profile_dto.dart';
import '../../features/profile/data/profile_repository.dart';
import '../di/injector.dart';

/// Resolves a [ProfileDto] by user id — checks `ProfileRepository`'s cache
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
