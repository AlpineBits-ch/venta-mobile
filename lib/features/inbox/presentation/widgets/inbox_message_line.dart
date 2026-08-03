import 'package:flutter/material.dart';

import '../../../../core/theme/widget_styles.dart';
import '../../../../core/widgets/avatar_image.dart';
import '../../../../core/widgets/profile_resolver.dart';
import '../../../messaging/data/message_content_codec.dart';
import '../../../messaging/data/system_message_text.dart';
import '../../data/models/inbox_message_dto.dart';

/// Resolves who wrote an inbox row and hands the answer to [builder].
///
/// `authorDisplayName`/`authorAvatarUrl` win where they're set: those are
/// webhook and bot authors, which have no profile to look up, and resolving
/// [InboxMessageDto.authorId] for one returns the *installer's* profile rather
/// than the bot's. Everything else goes through [ProfileResolver] so the inbox
/// shows the same live name and avatar the channel does.
class InboxAuthor extends StatelessWidget {
  const InboxAuthor({super.key, required this.message, required this.builder});

  final InboxMessageDto message;
  final Widget Function(BuildContext context, String name, String? avatarUrl)
  builder;

  @override
  Widget build(BuildContext context) {
    final displayName = message.authorDisplayName;
    if (displayName != null && displayName.isNotEmpty) {
      return builder(context, displayName, message.authorAvatarUrl);
    }
    return ProfileResolver(
      userId: message.authorId,
      builder: (context, profile) => builder(
        context,
        profile?.userName.isNotEmpty ?? false ? profile!.userName : '…',
        message.authorAvatarUrl ?? profile?.avatarUrl,
      ),
    );
  }
}

/// One preview line: a small avatar, the author's name and as much of the
/// message as fits.
///
/// Deliberately not a `ThreadView` bubble in miniature - no markdown, no
/// mention resolution, no attachments. A preview that renders a code block or
/// an image would make every group card a different height, and the inbox's
/// job is to help you decide whether to open the channel.
class InboxMessageLine extends StatelessWidget {
  const InboxMessageLine({
    super.key,
    required this.message,
    this.maxLines = 2,
    this.showAvatar = true,
  });

  final InboxMessageDto message;
  final int maxLines;
  final bool showAvatar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InboxAuthor(
      message: message,
      builder: (context, name, avatarUrl) {
        final body = inboxMessageBody(message, authorName: name);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              AvatarImage(
                userId: message.authorId,
                imageUrl: avatarUrl,
                label: name,
                radius: 10,
              ),
              const SizedBox(width: AppSpacing.s),
            ],
            Expanded(
              child: message.isSystemEvent
                  ? Text(
                      body,
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$name  ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: body,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.75,
                              ),
                              fontStyle: message.isUndecryptable
                                  ? FontStyle.italic
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      maxLines: maxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// What an inbox row says, in one line of text.
///
/// The encrypted case is the interesting one: the server holds no keys, so it
/// cannot generate a preview for an encrypted channel at all, and a message
/// this device can't open has no text behind it to fall back on. Saying so is
/// a client decision, and the honest one - the alternative is rendering base64.
String inboxMessageBody(InboxMessageDto message, {required String authorName}) {
  if (message.isUndecryptable) {
    return "Can't be decrypted on this device";
  }
  if (message.isSystemEvent) {
    return systemJoinLeaveText(
      leaving: message.type == InboxMessageType.guildMemberLeave,
      variant: message.systemMessageVariant,
      userName: authorName,
    );
  }
  final text = MessageContentCodec.decode(message.content).trim();
  if (text.isNotEmpty) return text;
  if (message.type == InboxMessageType.invite) return 'Sent an invite';
  // Empty body with something hanging off it - an attachment-only post, or an
  // embed the inbox doesn't render.
  if (message.embedsJson != null) return 'Sent an embed';
  return 'Sent an attachment';
}
