/// The optional, visibility-gated parts of a profile.
///
/// Every one of these is **absent from the payload entirely** when the subject's
/// privacy settings don't admit the viewer - not null, not an empty list, the
/// key simply isn't there. So the models are nullable on [ProfileDto] and the
/// UI branches on absence; a client that treats a missing key as "empty" would
/// render "no servers in common" where the honest answer is "you aren't allowed
/// to know".
///
/// Hand-written rather than generated because the field names here are the
/// least settled part of the contract - `mutualFriends` and `mutualServers` are
/// live but undocumented in shape, and reading a couple of plausible aliases
/// costs nothing next to a codegen'd parser that throws on the first surprise
/// and takes the whole profile with it.
library;

/// A friend or a server the viewer has in common with the subject.
class MutualEntry {
  const MutualEntry({required this.id, required this.name, this.imageUrl});

  factory MutualEntry.fromJson(Map<String, dynamic> json) => MutualEntry(
    id: _string(json, const ['id', 'userId', 'guildId', 'profileId']) ?? '',
    name: _string(json, const ['name', 'userName', 'displayName']) ?? '',
    imageUrl: _string(json, const ['avatarUrl', 'iconUrl', 'imageUrl']),
  );

  final String id;
  final String name;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': imageUrl,
  };
}

/// A linked external account. Steam is the only type today; the list shape is
/// deliberate on the server's part, so nothing here assumes there is one.
class ProfileConnection {
  const ProfileConnection({
    required this.type,
    required this.externalId,
    this.displayName,
    this.verified = false,
  });

  factory ProfileConnection.fromJson(Map<String, dynamic> json) =>
      ProfileConnection(
        type: json['type']?.toString() ?? '',
        externalId: json['externalId']?.toString() ?? '',
        displayName: json['displayName'] as String?,
        verified: json['verified'] as bool? ?? false,
      );

  final String type;
  final String externalId;
  final String? displayName;
  final bool verified;

  /// What to show: the account's own name where it gave one, otherwise the id.
  String get label =>
      (displayName?.isNotEmpty ?? false) ? displayName! : externalId;

  Map<String, dynamic> toJson() => {
    'type': type,
    'externalId': externalId,
    'displayName': displayName,
    'verified': verified,
  };
}

/// What the subject is doing - "playing X", and so on.
///
/// The gate is live but no data source is wired yet, so this is always absent
/// today. Parsed leniently for the same reason: the shape will be settled by
/// whatever eventually publishes it, and a strict parser written now would be
/// guessing.
class ProfileActivity {
  const ProfileActivity({required this.name, this.details, this.state});

  factory ProfileActivity.fromJson(Map<String, dynamic> json) =>
      ProfileActivity(
        name: _string(json, const ['name', 'applicationName', 'title']) ?? '',
        details: json['details'] as String?,
        state: json['state'] as String?,
      );

  final String name;
  final String? details;
  final String? state;

  /// A single line, or null when there is nothing worth a line.
  String? get summary {
    if (name.isEmpty) return null;
    final tail = details ?? state;
    return tail == null || tail.isEmpty ? name : '$name - $tail';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'details': details,
    'state': state,
  };
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}
