/// One entitlement value on the wire, and how it reads to a person.
///
/// The entitlement snapshot and the plan catalogue publish entitlements in the
/// *same* encoding, which is why this file exists once rather than twice: the
/// numbers a plan promises and the numbers this account currently resolves are
/// the same three shapes, and a second renderer would agree with the first on
/// "75" and disagree on the two that matter - the unlimited ceiling that
/// arrives as `value: null`, and a value whose shape this build cannot read.
///
/// Hand-rolled rather than freezed because the shape is discriminated on
/// `kind` and the failure mode of an unrecognised kind has to be a neutral
/// rendering rather than a thrown decode. A `json_serializable` union would
/// throw, and one new value kind added server-side would take the whole screen
/// offline on every shipped client.
library;

/// Which of the three shapes arrived, plus the one this build cannot read.
enum EntitlementValueKind {
  numeric,
  flag,
  ladder,

  /// A `kind` added after this build shipped. Renders as "Unknown", never as
  /// zero and never as "not included" - both of those are real answers, and
  /// giving one of them to a payload we could not parse understates a plan.
  unknown,
}

/// A ceiling, a switch or a rung, as the server sent it.
///
/// **Read [unlimited] before [value].** `value` is null exactly when
/// `unlimited` is true, and the null is written explicitly by the server so
/// that "no ceiling" and "the field is missing" are different bytes. The
/// internal sentinel for no ceiling is `long.MaxValue`, which the server
/// refuses to put on the wire as a number at all, so a numeric value here is
/// always a real limit.
class EntitlementValueDto {
  const EntitlementValueDto({
    required this.kind,
    this.value,
    this.unlimited = false,
    this.granted = false,
    this.rung,
    this.rank,
    this.ladder,
  });

  const EntitlementValueDto.numeric({int? value, bool unlimited = false})
    : this(
        kind: EntitlementValueKind.numeric,
        value: value,
        unlimited: unlimited,
      );

  const EntitlementValueDto.flag({bool granted = false})
    : this(kind: EntitlementValueKind.flag, granted: granted);

  const EntitlementValueDto.ladder({
    required String rung,
    required int rank,
    String? ladder,
  }) : this(
         kind: EntitlementValueKind.ladder,
         rung: rung,
         rank: rank,
         ladder: ladder,
       );

  final EntitlementValueKind kind;

  /// The limit, for a numeric value that has one. Null when [unlimited].
  final int? value;

  final bool unlimited;

  final bool granted;

  /// The rung's name, which is what a person reads - `720p30`.
  final String? rung;

  /// Position on [ladder], ascending. Comparable only against another rank of
  /// the same ladder, which is why the ladder is named alongside it.
  final int? rank;

  final String? ladder;

  factory EntitlementValueDto.fromJson(Map<String, dynamic> json) {
    switch (json['kind']) {
      case 'numeric':
        final unlimited = json['unlimited'] == true;
        final raw = json['value'];
        return EntitlementValueDto.numeric(
          value: unlimited || raw is! num ? null : raw.toInt(),
          unlimited: unlimited,
        );
      case 'flag':
        return EntitlementValueDto.flag(granted: json['granted'] == true);
      case 'ladder':
        final rung = json['rung'];
        final rank = json['rank'];
        // Both or neither. A rung with no rank cannot be compared against
        // another plan's, and comparison is the entire job of the "what would
        // be available" half of this screen.
        if (rung is! String || rank is! num) {
          return const EntitlementValueDto(kind: EntitlementValueKind.unknown);
        }
        return EntitlementValueDto.ladder(
          rung: rung,
          rank: rank.toInt(),
          ladder: json['ladder'] as String?,
        );
      default:
        return const EntitlementValueDto(kind: EntitlementValueKind.unknown);
    }
  }

  /// Only ever round-trips what was read. Nothing in this client writes an
  /// entitlement value to the server, and there is no endpoint that would take
  /// one.
  Map<String, dynamic> toJson() => switch (kind) {
    EntitlementValueKind.numeric => {
      'kind': 'numeric',
      'value': value,
      'unlimited': unlimited,
    },
    EntitlementValueKind.flag => {'kind': 'flag', 'granted': granted},
    EntitlementValueKind.ladder => {
      'kind': 'ladder',
      'rung': rung,
      'rank': rank,
      if (ladder != null) 'ladder': ladder,
    },
    EntitlementValueKind.unknown => {'kind': 'unknown'},
  };

  // There is deliberately no "does this grant more than that", and an earlier
  // draft of this file had one. It existed so a plan the reader is not on could
  // be marked wherever it grants more than the plan they are on. That is a
  // comparison that presents another plan as somewhere to move to - the same
  // statement a control would make, drawn as an icon instead of a button. Every
  // plan now renders as what it includes and nothing measures one against
  // another, so the comparison has no caller and no reason to exist.
  //
  // `==` below is value equality for the change line on a degradation, which
  // asks whether the request and the grant were the same thing. That is not a
  // ranking and does not become one.

  @override
  bool operator ==(Object other) =>
      other is EntitlementValueDto &&
      other.kind == kind &&
      other.value == value &&
      other.unlimited == unlimited &&
      other.granted == granted &&
      other.rung == rung &&
      other.rank == rank;

  @override
  int get hashCode => Object.hash(kind, value, unlimited, granted, rung, rank);
}

/// The one place a catalogue key's units are known.
///
/// Read off the key's suffix rather than an enumerated table, because the
/// catalogue grows: a `storage.archive_quota_bytes` added next quarter renders
/// as a size in a build that predates it, where a table would render it as a
/// ten-digit count.
String _describeNumber(String key, int amount) {
  if (key.endsWith('_bytes')) return formatByteCeiling(amount);
  if (key.endsWith('_days')) return amount == 1 ? '1 day' : '$amount days';
  return '$amount';
}

/// `104857600` becomes `100 MB`.
///
/// Binary steps, because every ceiling this renders is a byte count the server
/// compares against with `>=` on a whole number of bytes. One fractional digit
/// below ten so that 1.5 GB does not read as "2 GB" next to a plan that really
/// does grant two.
String formatByteCeiling(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var value = bytes.abs().toDouble();
  var index = 0;
  while (value >= 1024 && index < units.length - 1) {
    value /= 1024;
    index++;
  }
  final rendered = index > 0 && value < 10 && value != value.roundToDouble()
      ? value.toStringAsFixed(1)
      : value.round().toString();
  return '${bytes < 0 ? '-' : ''}$rendered ${units[index]}';
}

/// What one value reads as on a plan card.
///
/// Nothing here decides what a value *means*. A rung renders as the rung the
/// server named, not as a resolution this file invented a mapping for: that
/// mapping is a pricing decision, and one made in a Dart file is one nobody
/// can change without a release.
///
/// A null value is "Not listed" and never a blank: "this plan does not list
/// this key" and "this plan lists it as off" are different facts, and a blank
/// says the second one about the first.
String describeEntitlementValue(String key, EntitlementValueDto? value) {
  if (value == null) return 'Not listed';

  return switch (value.kind) {
    EntitlementValueKind.numeric =>
      value.unlimited
          ? 'Unlimited'
          : value.value == null
          ? 'Unknown'
          : _describeNumber(key, value.value!),
    EntitlementValueKind.flag => value.granted ? 'Included' : 'Not included',
    EntitlementValueKind.ladder => value.rung ?? 'Unknown',
    EntitlementValueKind.unknown => 'Unknown',
  };
}

/// One display name per catalogue key, so a limit can be named without every
/// widget switching on eleven strings.
///
/// An exhaustive table of literals rather than a transformation of the key,
/// deliberately: `voice.max_participants` prettied up by code reads as "Voice
/// max participants", which is a database column with spaces in it. A key this
/// build has never heard of returns null, and the caller renders the raw key -
/// which is ugly, and is the honest rendering of a capability nobody here has
/// written a name for.
const _keyNames = <String, String>{
  'voice.max_participants': 'People in a voice room',
  'voice.video_ceiling': 'Video quality',
  'voice.max_publishers': 'Cameras and screenshares at once',
  'storage.upload_max_bytes': 'Largest upload in a server',
  'storage.guild_quota_bytes': 'Server storage',
  'guild.emoji_slots': 'Custom emoji',
  'guild.bots_installed': 'Installed bots',
  'guild.vanity_url': 'Vanity invite link',
  'guild.audit_log_days': 'Audit log history',
  'user.upload_max_bytes': 'Largest upload',
  'user.max_devices': 'Devices on your account',
};

/// The display name for a catalogue key, or the key itself when this build has
/// no name for it.
String entitlementKeyLabel(String key) => _keyNames[key] ?? key;

/// Whether this build has a written name for [key]. Read by [orderEntitlementKeys]
/// so an unnamed key sorts to the bottom rather than sitting between two
/// sentences looking like a bug.
bool isNamedEntitlementKey(String key) => _keyNames.containsKey(key);

/// [keys] in the order they should be read.
///
/// Named keys first, in the order of the table above, which groups voice with
/// voice and storage with storage - a plan card read top to bottom should not
/// alternate between "how many people" and "how many bytes". Keys this build
/// has no name for follow, sorted, so a server that adds one puts it somewhere
/// stable instead of somewhere different on every rebuild.
///
/// The server sends `entitlements` as a JSON object and Dart preserves the
/// decode order, so without this the order is whatever the server happened to
/// iterate its dictionary in - which is stable in practice and guaranteed by
/// nothing.
List<String> orderEntitlementKeys(Iterable<String> keys) {
  final present = keys.toSet();
  final named = [
    for (final key in _keyNames.keys)
      if (present.remove(key)) key,
  ];
  return [...named, ...present.toList()..sort()];
}
