import 'guild_features.dart';

/// Wraps the 64-bit permission bitmask. Deliberately `BigInt`, not `int` -
/// `Superadmin` sits at bit 63, the sign bit of a 64-bit signed integer, so a
/// native Dart `int` would misbehave for that flag specifically.
///
/// The wire format is a **comma-separated list of flag names**
/// (.NET's default `[Flags]` enum `ToString()`, e.g. `"ViewChannel,
/// SendMessages"`), not a numeric string - verified against Alpine's
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
    'ManageEmojis': 37,
    'ManageEvents': 38,
    // Household module permissions. The bit *positions* here are this
    // client's own numbering, not the server's: the wire format is names in
    // both directions (see the class doc), so nothing depends on agreeing on
    // a number - only on each name having a distinct, stable bit locally.
    // They resolve per channel, so an overwrite granting control of one list
    // doesn't grant every list, and viewing any module's contents needs only
    // `ViewChannel`.
    'ManageLists': 39,
    'AddListItems': 40,
    'CheckOffListItems': 41,
    'ManageChores': 42,
    'CompleteChores': 43,
    'ManageLedger': 44,
    'AddExpenses': 45,
    'ManagePantry': 46,
    'CreateDecisions': 47,
    'VoteDecisions': 48,
    'ManageGuests': 49,
    'PlanMeals': 50,
    'ManageMeals': 51,
    'LogMaintenance': 52,
    'ManageMaintenance': 53,
    'Superadmin': 63,
  };

  /// Which module each permission belongs to, for the permissions that have
  /// one. A guild without the module answers `403` for these regardless of
  /// roles - **including for the owner** - so a role editor that offers them
  /// anyway is offering something that cannot work.
  static const permissionFeature = <String, String>{
    'Connect': GuildFeature.voiceChannels,
    'Speak': GuildFeature.voiceChannels,
    'Stream': GuildFeature.voiceChannels,
    'MuteMembers': GuildFeature.voiceChannels,
    'DeafenMembers': GuildFeature.voiceChannels,
    'MoveMembers': GuildFeature.voiceChannels,
    'CreateThreads': GuildFeature.threads,
    'SendMessagesInThreads': GuildFeature.threads,
    'ManageOwnThreads': GuildFeature.threads,
    'ManageAnyThread': GuildFeature.threads,
    'ViewWiki': GuildFeature.wiki,
    'CreateWikiPages': GuildFeature.wiki,
    'EditOwnWikiPages': GuildFeature.wiki,
    'EditAnyWikiPage': GuildFeature.wiki,
    'DeleteWikiPages': GuildFeature.wiki,
    'ManageWikiRevisions': GuildFeature.wiki,
    'ManageWikiStructure': GuildFeature.wiki,
    'ModerateWikiComments': GuildFeature.wiki,
    'PublishWikiPublicly': GuildFeature.wiki,
    'KickMembers': GuildFeature.moderation,
    'BanMembers': GuildFeature.moderation,
    'ModerateMembers': GuildFeature.moderation,
    'ViewAuditLog': GuildFeature.moderation,
    'ManageEmojis': GuildFeature.emojis,
    'ManageEvents': GuildFeature.events,
    'ManageLists': GuildFeature.lists,
    'AddListItems': GuildFeature.lists,
    'CheckOffListItems': GuildFeature.lists,
    'ManageChores': GuildFeature.chores,
    'CompleteChores': GuildFeature.chores,
    'ManageLedger': GuildFeature.ledger,
    'AddExpenses': GuildFeature.ledger,
    'ManagePantry': GuildFeature.pantry,
    'CreateDecisions': GuildFeature.decisions,
    'VoteDecisions': GuildFeature.decisions,
    'ManageGuests': GuildFeature.guestAccess,
    'PlanMeals': GuildFeature.meals,
    'ManageMeals': GuildFeature.meals,
    'LogMaintenance': GuildFeature.maintenance,
    'ManageMaintenance': GuildFeature.maintenance,
  };

  /// Plain-language labels for the role editor - `CheckOffListItems` is a
  /// flag name, not something to put in front of somebody deciding who's
  /// allowed to tick the milk off.
  static const flagLabels = <String, String>{
    'ManageLists': 'Manage lists',
    'AddListItems': 'Add list items',
    'CheckOffListItems': 'Tick items off',
    'ManageChores': 'Manage chores',
    'CompleteChores': 'Complete chores',
    'ManageLedger': 'Manage the ledger',
    'AddExpenses': 'Add expenses',
    'ManagePantry': 'Manage the pantry',
    'CreateDecisions': 'Open decisions',
    'VoteDecisions': 'Vote on decisions',
    'ManageGuests': 'Give guests temporary access',
    'PlanMeals': 'Plan meals',
    'ManageMeals': 'Manage recipes and the plan',
    // Deliberately the low bar. Whoever discovers the washing machine is dead
    // is whoever tried to use it, and needing a manage bit to say so is how a
    // house ends up with a broken machine nobody has recorded.
    'LogMaintenance': 'Log services and report faults',
    'ManageMaintenance': 'Manage appliances',
  };

  static final GuildPermissions none = GuildPermissions(BigInt.zero);
  static final GuildPermissions superadmin = _bit(63);

  /// Every flag name except `Superadmin` - used to render the role
  /// permission-editor's checkbox list. Declaration order matches the
  /// server's own grouping (channel/messages, voice, threads, moderation,
  /// wiki, household), not bit position.
  static List<String> get grantableFlagNames =>
      _flags.keys.where((k) => k != 'Superadmin').toList();

  /// [grantableFlagNames] minus everything belonging to a module this guild
  /// doesn't have. A community server has no business listing "Tick items
  /// off", and a household has no business listing wiki permissions - in both
  /// cases granting it would change nothing, because the feature gate refuses
  /// before roles are even consulted.
  static List<String> grantableFlagNamesFor(GuildFeatures features) => [
    for (final name in grantableFlagNames)
      if (permissionFeature[name] == null ||
          features.has(permissionFeature[name]!))
        name,
  ];

  /// How a flag reads in the role editor.
  static String labelFor(String flagName) => flagLabels[flagName] ?? flagName;

  static GuildPermissions _bit(int position) =>
      GuildPermissions(BigInt.one << position);

  static GuildPermissions parse(String? serialized) {
    if (serialized == null ||
        serialized.trim().isEmpty ||
        serialized.trim() == 'None') {
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
    if (value & (BigInt.one << 63) != BigInt.zero)
      return true; // Superadmin bypasses all checks
    return value & (BigInt.one << bit) != BigInt.zero;
  }

  bool get isSuperadmin => value & (BigInt.one << 63) != BigInt.zero;

  GuildPermissions operator |(GuildPermissions other) =>
      GuildPermissions(value | other.value);

  /// Sets or clears one named flag - the building block for a permission
  /// checkbox list.
  GuildPermissions withFlag(String flagName, bool enabled) {
    final bit = _flags[flagName];
    if (bit == null) return this;
    final mask = BigInt.one << bit;
    return GuildPermissions(enabled ? (value | mask) : (value & ~mask));
  }

  /// `perms` with `deny` bits cleared then `allow` bits set - matches the
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
      if (value & (BigInt.one << entry.value) != BigInt.zero)
        names.add(entry.key);
    }
    return names.join(', ');
  }
}
