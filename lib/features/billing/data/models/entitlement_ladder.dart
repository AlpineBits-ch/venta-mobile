/// The rungs of a published ladder, with the metrics that say what each one
/// permits.
///
/// **The mapping from a rung to a number of pixels is the server's, and this is
/// how it arrives.** `720p30` is a name, not an instruction: a client that
/// decided in Dart that it means 1280x720 would have written a pricing decision
/// into a release, and the day a rung is added or re-specified every shipped
/// build would be wrong about it. The ladder is on the wire precisely so that
/// nothing here has to know.
///
/// Hand-rolled for the same reason `EntitlementValueDto` is: a rung whose
/// metrics this build cannot read has to decode to "no metrics" rather than
/// throw, and one thrown decode would take the whole snapshot - and with it
/// every ceiling on it - offline.
library;

/// One rung, as the server published it.
///
/// [maxHeight] and [maxFramerate] are null when the payload carried no readable
/// number for them, which is not the same as zero. Zero is a real answer and
/// only the bottom rung gives it: `none` permits no picture at all.
class EntitlementLadderRungDto {
  const EntitlementLadderRungDto({
    required this.rung,
    required this.rank,
    this.maxHeight,
    this.maxFramerate,
  });

  final String rung;
  final int rank;
  final int? maxHeight;
  final int? maxFramerate;

  factory EntitlementLadderRungDto.fromJson(Map<String, dynamic> json) {
    final rank = json['rank'];
    return EntitlementLadderRungDto(
      rung: json['rung'] is String ? json['rung'] as String : '',
      rank: rank is num ? rank.toInt() : 0,
      maxHeight: _metric(json['maxHeight']),
      maxFramerate: _metric(json['maxFramerate']),
    );
  }

  Map<String, dynamic> toJson() => {
    'rung': rung,
    'rank': rank,
    'maxHeight': ?maxHeight,
    'maxFramerate': ?maxFramerate,
  };

  static int? _metric(Object? raw) => raw is num ? raw.toInt() : null;

  @override
  bool operator ==(Object other) =>
      other is EntitlementLadderRungDto &&
      other.rung == rung &&
      other.rank == rank &&
      other.maxHeight == maxHeight &&
      other.maxFramerate == maxFramerate;

  @override
  int get hashCode => Object.hash(rung, rank, maxHeight, maxFramerate);
}

/// The ladders this build looks up by name.
abstract final class EntitlementLadders {
  static const videoQuality = 'video_quality';
}

/// The rung named [rung] on [ladder], or null when the ladder does not list it.
///
/// Matched case-insensitively on the name rather than by rank: a rank is only
/// comparable within one ladder and a snapshot can carry a ceiling whose ladder
/// it did not publish, in which case there is nothing to index into.
EntitlementLadderRungDto? findLadderRung(
  List<EntitlementLadderRungDto>? ladder,
  String? rung,
) {
  if (ladder == null || rung == null) return null;
  final wanted = rung.trim().toLowerCase();
  if (wanted.isEmpty) return null;
  for (final entry in ladder) {
    if (entry.rung.trim().toLowerCase() == wanted) return entry;
  }
  return null;
}

Map<String, List<EntitlementLadderRungDto>> entitlementLaddersFromJson(
  Map<String, dynamic>? json,
) {
  if (json == null) return const {};
  final ladders = <String, List<EntitlementLadderRungDto>>{};
  for (final entry in json.entries) {
    final raw = entry.value;
    if (raw is! List) continue;
    ladders[entry.key] = [
      for (final rung in raw)
        if (rung is Map)
          EntitlementLadderRungDto.fromJson(
            rung.map((key, value) => MapEntry('$key', value)),
          ),
    ];
  }
  return ladders;
}

Map<String, dynamic> entitlementLaddersToJson(
  Map<String, List<EntitlementLadderRungDto>> ladders,
) => ladders.map(
  (key, value) => MapEntry(key, [for (final r in value) r.toJson()]),
);
