/// A raw re-broadcast of one SignalR hub method invocation. Repositories
/// filter by [name] and interpret [args] themselves — some events carry a
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

  /// For events whose sole argument is a bare string (e.g. a user/conversation id).
  String get stringPayload => (args?.isNotEmpty == true ? args!.first as String? : null) ?? '';
}
