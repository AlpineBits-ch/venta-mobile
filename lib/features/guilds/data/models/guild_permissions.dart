/// Wraps the 64-bit permission bitmask. Deliberately `BigInt`, not `int` —
/// `Superadmin` sits at bit 63, the sign bit of a 64-bit signed integer, so a
/// native Dart `int` would misbehave for that flag specifically.
///
/// The wire format is a **comma-separated list of flag names**
/// (.NET's default `[Flags]` enum `ToString()`, e.g. `"ViewChannel,
/// SendMessages"`), not a numeric string — verified against Alpine's
/// `parsePermissions`/`stringifyPermissions` in `enums/permissions.enum.ts`.
class GuildPermissions {
  const GuildPermissions(this.value);

  final BigInt value;

  static const _flags = <String, int>{
    'ViewChannel': 0,
    'SendMessages': 1,
    'EditOwnMessages': 2,
    'EditAnyMessage': 3,
    'DeleteOwnMessages': 4,
    'DeleteAnyMessage': 5,
    'PinMessages': 6,
    'AttachFiles': 7,
    'EmbedLinks': 8,
    'AddReactions': 9,
    'Connect': 10,
    'Speak': 11,
    'Stream': 12,
    'MuteMembers': 13,
    'DeafenMembers': 14,
    'MoveMembers': 15,
    'CreateThreads': 16,
    'SendMessagesInThreads': 17,
    'ManageOwnThreads': 18,
    'ManageAnyThread': 19,
    'ManageChannel': 20,
    'ManagePermissions': 21,
    'CreateInvite': 22,
    'ViewWiki': 23,
    'CreateWikiPages': 24,
    'EditOwnWikiPages': 25,
    'EditAnyWikiPage': 26,
    'DeleteWikiPages': 27,
    'ManageWikiRevisions': 28,
    'ManageWikiStructure': 29,
    'ModerateWikiComments': 30,
    'PublishWikiPublicly': 31,
    'KickMembers': 32,
    'BanMembers': 33,
    'ModerateMembers': 34,
    'ManageGuild': 35,
    'ViewAuditLog': 36,
    'Superadmin': 63,
  };

  static final GuildPermissions none = GuildPermissions(BigInt.zero);
  static final GuildPermissions superadmin = _bit(63);

  static GuildPermissions _bit(int position) => GuildPermissions(BigInt.one << position);

  static GuildPermissions parse(String? serialized) {
    if (serialized == null || serialized.trim().isEmpty || serialized.trim() == 'None') {
      return none;
    }
    var result = BigInt.zero;
    for (final part in serialized.split(',')) {
      final key = part.trim();
      final bit = _flags[key];
      if (bit != null) result |= BigInt.one << bit;
    }
    return GuildPermissions(result);
  }

  bool has(String flagName) {
    final bit = _flags[flagName];
    if (bit == null) return false;
    if (value & (BigInt.one << 63) != BigInt.zero) return true; // Superadmin bypasses all checks
    return value & (BigInt.one << bit) != BigInt.zero;
  }

  bool get isSuperadmin => value & (BigInt.one << 63) != BigInt.zero;

  GuildPermissions operator |(GuildPermissions other) => GuildPermissions(value | other.value);

  /// `perms` with `deny` bits cleared then `allow` bits set — matches the
  /// standard "deny wins over role default, allow wins over deny" override
  /// order used for channel/category permission overrides.
  static GuildPermissions applyOverride(
    GuildPermissions base,
    GuildPermissions allow,
    GuildPermissions deny,
  ) {
    return GuildPermissions((base.value & ~deny.value) | allow.value);
  }

  String toWireString() {
    if (value == BigInt.zero) return 'None';
    final names = <String>[];
    for (final entry in _flags.entries) {
      if (value & (BigInt.one << entry.value) != BigInt.zero) names.add(entry.key);
    }
    return names.join(', ');
  }
}
