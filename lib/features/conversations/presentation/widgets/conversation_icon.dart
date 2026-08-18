import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/authed_image_headers.dart';
import '../../../../core/widgets/avatar_image.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../data/conversation_api.dart';
import '../../data/models/conversation_dto.dart';

/// How far down the member list to look for a face. Bounds the profile
/// lookups a long group costs - past the second tile they are not drawn, and
/// a twenty-person group should not cost twenty resolves to render one circle.
const _candidateLimit = 4;

/// The picture for one conversation row: the other person for a 1:1, the
/// group's own icon when it has one, and two member faces when it does not.
///
/// The composite exists because a group of five people is otherwise a grey
/// disc with one arbitrary letter on it, and a list of several such groups is
/// unreadable. Two faces is the most that stays legible at 40px.
class ConversationIcon extends StatelessWidget {
  const ConversationIcon({
    super.key,
    required this.conversation,
    required this.myUserId,
    this.radius = 20,
  });

  final ConversationDto conversation;
  final String myUserId;
  final double radius;

  List<ConversationMemberDto> get _others =>
      conversation.members.where((m) => m.userId != myUserId).toList();

  @override
  Widget build(BuildContext context) {
    final others = _others;

    // A 1:1 is the other person, full stop - no icon, no composite. The group
    // test is the member count rather than `others.length`, so it still holds
    // in the moment before the caller knows its own user id.
    if (conversation.members.length <= 2) {
      final other = others.firstOrNull;
      if (other == null) {
        return _GroupGlyph(radius: radius);
      }
      return _MemberFace(member: other, radius: radius);
    }

    final iconUrl = conversationIconUrl(conversation);
    if (iconUrl != null) {
      return _GroupIcon(
        url: iconUrl,
        radius: radius,
        // The glyph shows through while the icon loads and stays if it fails,
        // for the same reason `AvatarImage` draws its initial underneath.
        fallback: _GroupGlyph(radius: radius),
      );
    }

    final candidates = others.take(_candidateLimit).toList();
    if (candidates.length < 2) {
      return candidates.isEmpty
          ? _GroupGlyph(radius: radius)
          : _MemberFace(member: candidates.single, radius: radius);
    }

    return _CompositeFaces(
      first: candidates[0],
      second: candidates[1],
      radius: radius,
    );
  }
}

/// The group icon's address with its cache key attached, or null when the
/// group has no icon.
///
/// The URL is derived from the conversation id, so nothing about it changes
/// when the image behind it does - without the stamp, a replaced icon serves
/// the previous bytes out of the image cache until the app is reinstalled.
String? conversationIconUrl(ConversationDto conversation) {
  final stamp = conversation.iconUpdatedAt;
  if (stamp == null) return null;
  final base = getIt<ConversationApi>().iconUrl(conversation.id);
  return '$base?v=${stamp.toUtc().toIso8601String()}';
}

class _GroupIcon extends StatelessWidget {
  const _GroupIcon({
    required this.url,
    required this.radius,
    required this.fallback,
  });

  final String url;
  final double radius;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            fallback,
            CachedNetworkImage(
              imageUrl: url,
              // The icon route is member-only and answers 404 rather than 401
              // to anyone without a bearer, so a header-less request looks
              // exactly like a group that never had an icon.
              httpHeaders: authedImageHeaders(),
              fit: BoxFit.cover,
              width: size,
              height: size,
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

/// One member's face, resolved through the profile cache the same way
/// `UserAvatar` does - but without its tap target or presence dot, which
/// belong to the row rather than to one half of a composite.
class _MemberFace extends StatelessWidget {
  const _MemberFace({required this.member, required this.radius});

  final ConversationMemberDto member;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ProfileResolver(
      userId: member.userId,
      builder: (context, profile) => AvatarImage(
        userId: member.userId,
        imageUrl: profile?.avatarUrl,
        // The cached roster name is a fallback, not the answer: it is written
        // when the member joined and does not follow a rename.
        label: profile?.userName ?? member.cachedUserName,
        radius: radius,
      ),
    );
  }
}

/// Two faces in one disc, split down the middle.
///
/// Each half is a full [AvatarImage] scaled to the whole circle and then
/// clipped, rather than two small avatars side by side: a face cropped to a
/// half-disc still reads as a face, whereas two shrunken circles inside a
/// circle read as a bug. Deliberately no attempt is made to skip members
/// without a picture - the API mints an `avatarUrl` for everyone whether or
/// not one was uploaded, so "has a picture" is not knowable before layout, and
/// a member without one contributes their coloured initial instead of a hole.
class _CompositeFaces extends StatelessWidget {
  const _CompositeFaces({
    required this.first,
    required this.second,
    required this.radius,
  });

  final ConversationMemberDto first;
  final ConversationMemberDto second;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final divider = Theme.of(context).colorScheme.surface;
    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Row(
          children: [
            Expanded(child: _half(first, Alignment.centerLeft)),
            // A hairline in the surface colour, so two similar avatars do not
            // merge into one shape at list size.
            SizedBox(width: 1, child: ColoredBox(color: divider)),
            Expanded(child: _half(second, Alignment.centerRight)),
          ],
        ),
      ),
    );
  }

  /// `OverflowBox` lets the full-size avatar paint at its natural width inside
  /// a half-width slot; the alignment picks which half survives the clip.
  Widget _half(ConversationMemberDto member, Alignment align) {
    return ClipRect(
      child: OverflowBox(
        maxWidth: radius * 2,
        alignment: align,
        child: _MemberFace(member: member, radius: radius),
      ),
    );
  }
}

/// The last resort: a group with nobody to show a face for.
class _GroupGlyph extends StatelessWidget {
  const _GroupGlyph({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.group_outlined,
        size: radius,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
