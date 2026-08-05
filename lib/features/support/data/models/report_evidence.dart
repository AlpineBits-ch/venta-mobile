import 'dart:convert';

/// One message in the snapshot attached to a report.
///
/// Built by the caller from whatever it has already rendered - this layer never
/// reaches back into a repository, because the whole point of the snapshot is
/// that it is what the *reporter saw*.
class EvidenceMessage {
  const EvidenceMessage({
    required this.id,
    required this.authorId,
    required this.content,
    this.sentAt,
    this.reported = false,
    this.attachments = const [],
  });

  final String id;
  final String authorId;

  /// The plaintext as this client rendered it - after decryption in an
  /// encrypted conversation, as displayed in a plain one.
  ///
  /// **Null, never ciphertext.** A message this device holds no keys for
  /// renders as unreadable here too; sending the base64 through would give a
  /// moderator a wall of noise they cannot do anything with, and would look
  /// like content.
  final String? content;

  final DateTime? sentAt;

  /// The one being reported. Exactly one message in a snapshot carries this,
  /// and it is the one that survives truncation.
  final bool reported;

  /// Attachments reduced to a description each - `image/png, 2.1 MB`. Never
  /// the bytes: the cap is 16 KB, and one base64'd screenshot is past it.
  final List<String> attachments;

  Map<String, dynamic> toJson() => {
    'id': id,
    'authorId': authorId,
    if (sentAt != null) 'sentAt': sentAt!.toUtc().toIso8601String(),
    // Present-and-null rather than absent, so "we couldn't read this" is
    // distinguishable from a client that didn't bother to send content.
    'content': content,
    if (content == null) 'unreadable': true,
    if (attachments.isNotEmpty) 'attachments': attachments,
    if (reported) 'reported': true,
  };
}

/// The `evidence` blob on a report.
///
/// Two cases, and which one this is changes what the blob is *for*:
///
///  * **Encrypted conversation** - the server holds ciphertext and can never
///    read the message. Whatever is attached here is the only thing a moderator
///    will ever see; send nothing and the report is decided on the reporter's
///    free-text description alone.
///  * **Plain conversation**, which is the default - the server has the
///    message. The snapshot is still worth sending, because a message deleted
///    before review is otherwise gone, but it is a convenience rather than the
///    sole record.
///
/// [encrypted] is read from the conversation, never assumed either way. The
/// console renders the evidence as unverified in both cases, but the flag
/// decides what it tells the moderator - "the server holds only ciphertext and
/// cannot corroborate any of it" versus "not checked against the stored
/// message" - so getting it wrong makes them either over-trust or under-trust
/// what they are reading.
abstract final class ReportEvidence {
  /// The server refuses anything larger, serialised.
  static const maxBytes = 16 * 1024;

  /// How much conversation goes in around the reported message. Context, not
  /// the whole conversation: this blob is read by staff, and a report is not a
  /// reason to hand over everything anybody ever said.
  static const contextBefore = 10;
  static const contextAfter = 3;

  /// The slice of [chronological] that goes in the snapshot - up to
  /// [contextBefore] messages before the reported one and [contextAfter] after.
  ///
  /// [chronological] must be oldest-first. Returns just the reported message if
  /// it isn't in the list, and an empty list if there is nothing at all.
  static List<EvidenceMessage> window(
    List<EvidenceMessage> chronological,
    String reportedId,
  ) {
    final index = chronological.indexWhere((m) => m.id == reportedId);
    if (index < 0) return const [];
    final start = (index - contextBefore).clamp(0, chronological.length);
    final end = (index + contextAfter + 1).clamp(0, chronological.length);
    return chronological.sublist(start, end);
  }

  /// The blob to send, or null when there is nothing worth attaching.
  ///
  /// Trims until it fits [maxBytes]: oldest first, because the reported message
  /// and what came after it are what a moderator is actually reading. If the
  /// reported message alone is still too large its content is cut - a truncated
  /// quote with a marker beats a report the server refuses outright, which is
  /// what `evidence_too_large` would otherwise cost the user at submit time.
  static Map<String, dynamic>? build({
    required String conversationId,
    required bool encrypted,
    required DateTime capturedAt,
    required List<EvidenceMessage> messages,
  }) {
    if (messages.isEmpty) return null;

    Map<String, dynamic> blobOf(List<EvidenceMessage> window) => {
      'capturedAt': capturedAt.toUtc().toIso8601String(),
      'conversationId': conversationId,
      'encrypted': encrypted,
      'messages': [for (final m in window) m.toJson()],
    };

    final window = [...messages];
    while (window.length > 1 && _sizeOf(blobOf(window)) > maxBytes) {
      // Never the reported one, even if it is somehow the oldest.
      final dropIndex = window.first.reported ? 1 : 0;
      window.removeAt(dropIndex);
    }

    var blob = blobOf(window);
    if (_sizeOf(blob) <= maxBytes) return blob;

    // One message left and still over. Halve its content until it fits; the
    // envelope around it is a few hundred bytes, so this terminates.
    var only = window.single;
    var content = only.content ?? '';
    while (content.isNotEmpty && _sizeOf(blob) > maxBytes) {
      content = content.substring(0, content.length ~/ 2);
      only = EvidenceMessage(
        id: only.id,
        authorId: only.authorId,
        content: content.isEmpty ? null : '$content…',
        sentAt: only.sentAt,
        reported: only.reported,
        // Kept: the attachment lines are a few dozen bytes each and they are
        // often the point of the report.
        attachments: only.attachments,
      );
      blob = blobOf([only]);
    }
    return _sizeOf(blob) <= maxBytes ? blob : null;
  }

  static int _sizeOf(Map<String, dynamic> blob) =>
      utf8.encode(jsonEncode(blob)).length;
}
