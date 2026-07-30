/// A raw re-broadcast of one SignalR hub method invocation. Repositories
/// filter by [name] and interpret [args] themselves - some events carry a
/// single JSON object (`conversation.MessageCreated`), others a bare string
/// (`presence.UserOnline`), matching whatever the hub actually sends.
class RealtimeEvent {
  const RealtimeEvent(this.name, this.args);

  final String name;
  final List<Object?>? args;

  /// For events whose sole argument is a JSON object.
  Map<String, dynamic> get objectPayload {
    final first = args?.isNotEmpty == true ? args!.first : null;
    return first is Map ? first.cast<String, dynamic>() : const {};
  }

  /// Case-insensitive read from [objectPayload].
  ///
  /// The hub isn't consistent about property casing: the voice endpoints send
  /// anonymous objects declared in camelCase (`new { userId, channelId }`)
  /// while the channel/category/emoji/event ones use C#'s natural PascalCase
  /// (`new { GuildId = ... }`). Whether that difference survives to the wire
  /// depends on the hub protocol's naming policy, which is a backend detail
  /// this client shouldn't be betting on - one `guildId` lookup silently
  /// returning null is the difference between a live-updating sidebar and a
  /// stale one. Reading case-insensitively makes the client correct under
  /// either policy.
  Object? field(String name) {
    final payload = objectPayload;
    final direct = payload[name];
    if (direct != null) return direct;
    final lower = name.toLowerCase();
    for (final entry in payload.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return null;
  }

  /// [field] narrowed to a string, for the id-carrying properties that make
  /// up nearly every payload.
  String? stringField(String name) => field(name) as String?;

  /// For events whose sole argument is a bare string (e.g. a user/conversation id).
  String get stringPayload =>
      (args?.isNotEmpty == true ? args!.first as String? : null) ?? '';
}
