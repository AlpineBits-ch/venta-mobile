/// Which modules a guild has. Deliberately a **set of flag names**, not a
/// bitmask: the wire format is a comma-separated string of names (the same
/// shape `permissions` uses on roles - see [GuildPermissions]), and the server
/// accepts names on write too. Keeping names end-to-end means a flag being
/// renumbered server-side can't silently change what this client sends.
///
/// Unknown names are preserved rather than dropped. That matters on write: the
/// modules screen sends the *exact* set back, so a module this build doesn't
/// know about yet would otherwise be switched off by an old client saving an
/// unrelated toggle.
class GuildFeatures {
  const GuildFeatures(this.names);

  final Set<String> names;

  static const GuildFeatures none = GuildFeatures(<String>{});

  /// What a guild has when the server doesn't report `features` at all - an
  /// older backend, or a payload that predates this field. Every guild that
  /// existed before modules landed is a `Community` with the full community
  /// preset, so assuming "everything on" keeps those clients behaving exactly
  /// as they did. The opposite default would blank out the whole UI.
  static final GuildFeatures communityPreset = GuildFeatures({
    ...GuildFeature.communityModules,
  });

  /// `"VoiceChannels, Threads"` -> the set. `"None"`, empty and null all mean
  /// no modules - distinct from *absent*, which is [communityPreset].
  static GuildFeatures parse(String serialized) {
    final trimmed = serialized.trim();
    if (trimmed.isEmpty || trimmed == 'None') return none;
    return GuildFeatures({
      for (final part in trimmed.split(','))
        if (part.trim().isNotEmpty) part.trim(),
    });
  }

  bool has(String feature) => names.contains(feature);

  GuildFeatures withFlag(String feature, bool enabled) => GuildFeatures({
    ...names.where((n) => n != feature),
    if (enabled) feature,
  });

  /// Emits `"None"` for an empty set, matching what the server serializes.
  String toWireString() => names.isEmpty ? 'None' : names.join(', ');
}

/// The flag names themselves, as constants rather than string literals
/// scattered across call sites - a typo'd gate would silently hide a feature
/// forever instead of failing loudly.
abstract final class GuildFeature {
  static const voiceChannels = 'VoiceChannels';
  static const threads = 'Threads';

  /// Gates Forum **and Media** channels alike.
  static const forums = 'Forums';
  static const announcements = 'Announcements';
  static const tickets = 'Tickets';
  static const moderation = 'Moderation';
  static const autoMod = 'AutoMod';
  static const onboarding = 'Onboarding';
  static const emojis = 'Emojis';
  static const bots = 'Bots';
  static const wiki = 'Wiki';
  static const events = 'Events';

  // Household modules. Five of them are channel types (`List`, `Chores`,
  // `Ledger`, `Pantry`, `Decisions`); the other three are guild-scoped -
  // who's home, quiet hours, and time-boxed guest access. Every endpoint
  // behind them answers `403` when the module is off, for the owner too.
  static const lists = 'Lists';
  static const chores = 'Chores';
  static const ledger = 'Ledger';
  static const pantry = 'Pantry';
  static const decisions = 'Decisions';
  static const presence = 'Presence';
  static const quietHours = 'QuietHours';
  static const guestAccess = 'GuestAccess';

  static const communityModules = <String>[
    voiceChannels,
    threads,
    forums,
    announcements,
    tickets,
    moderation,
    autoMod,
    onboarding,
    emojis,
    bots,
    wiki,
    events,
  ];

  static const householdModules = <String>[
    lists,
    chores,
    ledger,
    pantry,
    decisions,
    presence,
    quietHours,
    guestAccess,
  ];

  /// Short human labels for the modules screen.
  static const labels = <String, String>{
    voiceChannels: 'Voice channels',
    threads: 'Threads',
    forums: 'Forums & media',
    announcements: 'Announcement channels',
    tickets: 'Tickets',
    moderation: 'Moderation',
    autoMod: 'Auto-moderation',
    onboarding: 'Onboarding',
    emojis: 'Custom emoji',
    bots: 'Bots',
    wiki: 'Wiki',
    events: 'Scheduled events',
    lists: 'Lists',
    chores: 'Chores',
    ledger: 'Shared ledger',
    pantry: 'Pantry',
    decisions: 'Decisions',
    presence: 'Presence',
    quietHours: 'Quiet hours',
    guestAccess: 'Guest access',
  };

  static const descriptions = <String, String>{
    voiceChannels: 'Voice channels and everything that moderates them',
    threads: 'Threads on messages, and the permissions behind them',
    forums: 'Forum and media channels',
    announcements: 'Channels other servers can follow',
    tickets: 'Ticket channels',
    moderation: 'Kick, ban, timeout and the audit log',
    autoMod: 'Automatic content filtering',
    onboarding: 'Rules gate, questions and the welcome screen',
    emojis: 'Upload and manage custom emoji',
    bots: 'Install and manage bots',
    wiki: 'The whole wiki and its permissions',
    events: 'The scheduled-events calendar',
    lists: 'Shopping and todo lists, shared and ticked off together',
    chores: 'A rota that weights by effort instead of just taking turns',
    ledger: 'Shared expenses, who owes who, and settling up',
    pantry: 'What\'s in stock, what\'s running out, what\'s going off',
    decisions: 'House decisions where one reasoned objection stops it',
    presence: 'Who\'s actually in the flat right now',
    quietHours: 'A nightly window that holds back chore reminders',
    guestAccess: 'Roles that hand themselves back when they run out',
  };

  /// The channel-type modules, in the order a household sidebar tends to use
  /// them. The remaining three ([presence], [quietHours], [guestAccess]) have
  /// no channel of their own.
  static const householdChannelModules = <String>[
    lists,
    chores,
    ledger,
    pantry,
    decisions,
  ];
}
