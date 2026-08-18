import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:venta_mobile/core/realtime/realtime_service.dart';

/// Hub methods this client *sends* rather than receives. An invoke needs no
/// registration - registration is what makes an inbound method reach the app.
final _invokePattern = RegExp(r'invoke\(\s*$');

/// A prefix test rather than a whole method name, e.g.
/// `event.name.startsWith('guild.ForumTag')`.
final _prefixPattern = RegExp(r'startsWith\(\s*$');

/// Anything shaped like a hub method name in a string literal.
final _eventLiteral = RegExp(
  r"'((?:conversation|guild|call|presence|social|inbox|status)"
  r"(?:\.[A-Za-z]+)+)'",
);

/// Every string literal in [source] that names a hub method the app expects to
/// *receive*, with outbound invokes and prefix tests filtered out.
Set<String> _inboundEventNamesIn(String source) {
  // Line comments are stripped first: several of these names appear in prose
  // explaining what an event does, and a comment naming an event is not a
  // handler for it.
  final code = source
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'//.*$'), ''))
      .join('\n');

  final names = <String>{};
  for (final match in _eventLiteral.allMatches(code)) {
    final before = code.substring(0, match.start);
    if (_invokePattern.hasMatch(before) || _prefixPattern.hasMatch(before)) {
      continue;
    }
    names.add(match.group(1)!);
  }
  return names;
}

void main() {
  /// The transport only delivers hub methods named in
  /// [RealtimeService.watchedEvents], so a handler for an unregistered event is
  /// unreachable code that looks exactly like a backend which stopped
  /// broadcasting - no error, no log, just a feature that quietly never
  /// updates.
  ///
  /// This has happened. `conversation.CallStateChanged`,
  /// `conversation.ConversationUpdated`, `conversation.MlsJoinRequest`,
  /// `conversation.MlsDeviceRemoved` and `conversation.MlsDeviceAdmitted` were
  /// all handled in `lib/` and none of them was registered, so the DM header
  /// never learned about a call in progress and a removed device never learned
  /// it had been removed. A per-feature list (see `household_test.dart`) only
  /// guards the feature that remembered to write one; this guards the rule.
  test('every hub event handled in lib is registered on the transport', () {
    final watched = RealtimeService.watchedEvents.toSet();
    final unregistered = <String, List<String>>{};

    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      // The registration list itself is the answer, not a question about it.
      if (entity.path.endsWith('realtime_service.dart')) continue;

      for (final name in _inboundEventNamesIn(entity.readAsStringSync())) {
        if (watched.contains(name)) continue;
        unregistered.putIfAbsent(name, () => []).add(entity.path);
      }
    }

    expect(
      unregistered,
      isEmpty,
      reason:
          'These hub methods are handled in lib/ but are not in '
          'RealtimeService.watchedEvents, so they are dropped before any '
          'repository sees them:\n'
          '${unregistered.entries.map((e) => '  ${e.key}  (${e.value.join(', ')})').join('\n')}',
    );
  });

  test('the five events that were silently dropped are registered', () {
    expect(
      RealtimeService.watchedEvents,
      containsAll(<String>[
        'conversation.CallStateChanged',
        'conversation.ConversationUpdated',
        'conversation.MlsJoinRequest',
        'conversation.MlsDeviceRemoved',
        'conversation.MlsDeviceAdmitted',
      ]),
    );
  });

  test('the watch list has no duplicates', () {
    final seen = <String>{};
    final duplicated = RealtimeService.watchedEvents
        .where((name) => !seen.add(name))
        .toList();
    expect(duplicated, isEmpty);
  });
}
