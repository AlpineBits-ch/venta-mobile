import 'package:flutter/foundation.dart';

import 'secure_storage_fault.dart' show reportSwallowed;

/// The stable identifiers voice failures are reported under.
///
/// **A code, not a sentence.** The sentence shown to somebody in a call has to
/// be short and in their language; the thing they read back over a support
/// channel has to survive being retyped, and has to grep. These are what go in
/// brackets after the sentence, what tags the Sentry issue, and what indexes the
/// session log - one vocabulary rather than three.
///
/// They are deliberately coarse. A code names *the question to ask next*, not
/// the exact line that threw: `V-NODEC` says "the bytes arrived and the decoder
/// refused them", which is a codec investigation, while `V-NODATA` says "nothing
/// arrived at all", which is a subscription one. Splitting either further would
/// move the judgement into the code and out of the log entry, which carries the
/// detail.
abstract final class VoiceFaultCodes {
  /// The join request itself was refused - an authorisation or routing failure,
  /// before any media exists.
  static const String join = 'V-JOIN';

  /// The media connection could not be established or the microphone could not
  /// be published.
  static const String connect = 'V-CONN';

  /// The room named a media backend this build cannot drive.
  static const String backend = 'V-BACKEND';

  /// A connect was abandoned because the room was left underneath it. Recorded
  /// rather than reported: it is the *correct* outcome of a race, and the reason
  /// the connection that follows is a fresh one.
  static const String superseded = 'V-CANCEL';

  /// The SDK exhausted its own reconnect ladder and the media is gone.
  static const String mediaLost = 'V-LOST';

  /// Rebuilding the media half after [mediaLost] failed.
  static const String rejoin = 'V-REJOIN';

  /// A publish reached the SFU but was not declared to the backend, so nothing
  /// in the product can see it until a heartbeat repairs the record.
  static const String publish = 'V-PUB';

  /// A track could not be attached to a renderer. Its tile is black and will
  /// stay black until the track is replaced.
  static const String attach = 'V-ATTACH';

  /// Subscribed, and not one byte has arrived.
  static const String noData = 'V-NODATA';

  /// Bytes are arriving and the decoder has produced no frames from them -
  /// which on this platform is almost always a codec or H.264 profile the
  /// hardware decoder never matched.
  static const String noDecode = 'V-NODEC';

  /// Frames are being decoded and the renderer has never been handed a size.
  static const String noFrames = 'V-NOFRAME';

  /// Frames were arriving and stopped.
  static const String stalled = 'V-STALL';

  /// The publisher has muted the track. Not a fault - the black tile is
  /// correct - and named so the overlay can say so rather than accuse the
  /// network.
  static const String senderPaused = 'V-PAUSED';

  /// The publication exists and this client is not subscribed to it, which
  /// means the server's subscription set excluded it.
  static const String notSubscribed = 'V-NOSUB';
}

/// One recorded voice fault.
@immutable
class VoiceDiagnosticEntry {
  const VoiceDiagnosticEntry({
    required this.code,
    required this.sequence,
    required this.at,
    this.subject,
    this.detail,
    this.isError = true,
  });

  final String code;

  /// Position in this session's log, from 1. What makes [reference] unique
  /// without needing a clock or a random source - two `V-NODEC`s a minute apart
  /// are two different investigations and have to be tellable apart in a
  /// screenshot.
  final int sequence;

  final DateTime at;

  /// What the fault is about - a user id, a track name, a channel. Free text,
  /// and safe to omit.
  final String? subject;

  /// Everything known about the cause, already flattened to a string. Held as
  /// text rather than as the exception because this outlives the exception and
  /// is read on a screen.
  final String? detail;

  /// False for entries that record something notable that is not a failure, so
  /// the panel can show the sequence of events around a fault without every row
  /// reading as a fault.
  final bool isError;

  /// What somebody reads out. Short enough to retype, unique within a session.
  String get reference => '$code#$sequence';

  @override
  String toString() => detail == null ? reference : '$reference $detail';
}

/// The session's voice fault log, and the one place a voice failure is allowed
/// to be swallowed.
///
/// **Deliberately not gated on `kDebugMode`,** for the reason
/// `VideoDiagnosticsPrefs` gives: the failures worth this machinery only happen
/// against a real SFU on a real network, which in practice means a release
/// build on somebody else's handset. A diagnostic that vanishes in the build
/// where the bug lives is not a diagnostic.
///
/// **In memory, and only in memory.** A fault describes one moment of one
/// session; carrying it across a relaunch would have the panel explaining a
/// connection that no longer exists.
///
/// Everything recorded here also reaches Sentry through [reportSwallowed]
/// unless it is marked non-error, so a fault nobody happened to be looking at
/// is still evidence.
class VoiceDiagnostics {
  VoiceDiagnostics();

  /// The one every non-injected caller uses. Voice failures happen in the
  /// transport, in two cubits and in a widget that owns no dependencies, and
  /// threading a log through all of them would guarantee the widget is the one
  /// that gets left out - which is the tile, which is where the black picture
  /// is.
  static final VoiceDiagnostics shared = VoiceDiagnostics();

  /// Enough to hold a whole failed join and the tile faults that followed it,
  /// few enough that a room stalling for an hour cannot grow without bound.
  static const int maxEntries = 60;

  final _entries = ValueNotifier<List<VoiceDiagnosticEntry>>(
    const <VoiceDiagnosticEntry>[],
  );

  /// Newest first.
  ValueListenable<List<VoiceDiagnosticEntry>> get entries => _entries;

  int _sequence = 0;

  /// Records one fault and returns its [VoiceDiagnosticEntry.reference], so the
  /// caller can put it in the sentence it is about to show.
  ///
  /// [error] is flattened into the detail rather than stored: this log outlives
  /// the exception, and holding a `DioException` alive by its response body for
  /// the rest of a session is a leak with no reader.
  ///
  /// Repeats of the same code and subject *replace* the previous entry rather
  /// than stacking. A tile that cannot decode reports every stats tick, and 60
  /// identical rows would push out the connect failure that explains them.
  String record(
    String code, {
    String? subject,
    String? detail,
    Object? error,
    StackTrace? stackTrace,
    bool isError = true,
  }) {
    final parts = [
      if (detail != null && detail.isNotEmpty) detail,
      if (error != null) '$error',
    ];
    final entry = VoiceDiagnosticEntry(
      code: code,
      sequence: ++_sequence,
      at: DateTime.now(),
      subject: subject,
      detail: parts.isEmpty ? null : parts.join(' - '),
      isError: isError,
    );

    final kept = [
      entry,
      for (final existing in _entries.value)
        if (existing.code != code || existing.subject != subject) existing,
    ];
    _entries.value = List.unmodifiable(
      kept.length <= maxEntries ? kept : kept.sublist(0, maxEntries),
    );

    debugPrint('[Voice] ${entry.reference} ${entry.subject ?? ''} '
        '${entry.detail ?? ''}'.trimRight());

    if (isError) {
      reportSwallowed(
        'voice/$code',
        error ?? StateError(entry.detail ?? code),
        stackTrace,
        {
          'voice_code': code,
          'voice_ref': entry.reference,
          'voice_subject': ?subject,
        },
      );
    }
    return entry.reference;
  }

  void clear() {
    if (_entries.value.isEmpty) return;
    _entries.value = const <VoiceDiagnosticEntry>[];
  }
}

/// The sentence [message] with the trace reference appended.
///
/// Kept as one function so every voice error string is punctuated the same way
/// and a support reply can say "read me what is in the brackets" without
/// qualifying which screen it was on.
String withVoiceTrace(String message, String reference) =>
    '$message [$reference]';
