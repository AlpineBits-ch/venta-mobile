import 'package:dio/dio.dart';

import 'voice_media_dto.dart';
import 'voice_room_key.dart';
import 'voice_snapshot_dto.dart';

/// A failure returned by the voice media surface, classified the way the
/// contract classifies it.
///
/// The distinctions are load-bearing rather than cosmetic:
///
///  * **409** is a stale *client* - it asked to pull media nobody is
///    publishing. Refetch the snapshot and reconcile; re-sending the same body
///    is guaranteed to fail again, because the track is gone rather than late.
///  * **502** is the SFU rejecting the operation. A real failure, and treating
///    it as success is what leaves a client believing it is subscribed to a
///    peer no media will ever arrive from.
///  * **503** is the room being contended - the change simply was not applied,
///    and retrying shortly after works.
///
/// Everything else ([isFatal]) must not be retried blind.
class VoiceMediaException implements Exception {
  VoiceMediaException({
    required this.statusCode,
    required this.operation,
    this.error,
    this.staleTracks = const [],
    this.action,
  });

  /// Builds one from a Dio failure. The 502 body is `{ operation, error }`;
  /// the 409 body is `{ error, tracks, action }`, where `error` is a code
  /// rather than a message.
  factory VoiceMediaException.from(DioException e, String fallbackOperation) {
    final data = e.response?.data;
    final body = data is Map<String, dynamic> ? data : const {};
    return VoiceMediaException(
      statusCode: e.response?.statusCode ?? 0,
      operation: body['operation'] as String? ?? fallbackOperation,
      error: body['error'] as String? ?? e.message,
      staleTracks: (body['tracks'] as List? ?? const []).cast<String>(),
      action: body['action'] as String?,
    );
  }

  final int statusCode;
  final String operation;
  final String? error;

  /// The tracks the server knew were gone up front. Empty when the publisher
  /// vanished mid-request - the meaning is the same either way, so nothing
  /// should branch on it beyond logging.
  final List<String> staleTracks;

  /// What the server says to do about it, e.g. `refetchSnapshot`.
  final String? action;

  /// This client asked to pull media nobody is publishing - its view of the
  /// room is out of date.
  ///
  /// Never retry: the subscribe was refused because the track no longer
  /// exists, so the identical body fails identically. Refetch the snapshot and
  /// subscribe from that instead. Before the server started answering this, a
  /// stale share cost six seconds of SFU retries and then a 502, and a client
  /// looping on it took voice to the status page.
  bool get isStale =>
      statusCode == 409 && (error == 'staleSubscription' || error == null);

  /// This client's *own* media session has no live peer connection - it was closed, or never
  /// reached `connected`.
  ///
  /// The opposite direction to [isStale] and answered differently, which is why they are separate
  /// despite sharing a status. A stale subscription is a track that stopped: refetch the roster and
  /// pull whatever replaced it. This is the session doing the pulling being spent, which no roster
  /// can repair - it has to be recreated before anything can be pulled onto it at all.
  ///
  /// Never retried. Every call on that session id fails identically from here on.
  ///
  /// The 502 arm matches the transport's own wording, which is what leaks through when the
  /// operation reaches the SFU before the server classifies it.
  bool get isSessionGone =>
      (statusCode == 409 && error == 'sessionGone') ||
      (statusCode == 502 && (error?.contains('session_error') ?? false));

  /// The room was contended and the change was not applied. Transient; retry
  /// after a short delay.
  bool get isContended => statusCode == 503;

  /// The SFU rejected the operation. A real failure - roll back any local
  /// "subscribed" bookkeeping for the peer involved.
  bool get isTransportFailure => statusCode == 502;

  /// Not permitted, or the room does not exist. Retrying cannot help.
  ///
  /// A `404` on these paths is more often the missing gateway prefix than a
  /// missing room - guild routes need `/api/v1/guild` and call routes
  /// `/api/v1/messaging` in front.
  bool get isFatal => statusCode == 403 || statusCode == 404;

  @override
  String toString() =>
      'VoiceMediaException($statusCode, $operation'
      '${error == null ? '' : ': $error'}'
      '${staleTracks.isEmpty ? '' : ' tracks=$staleTracks'})';
}

/// The room named a media backend this build has no implementation for.
///
/// The session handshake declares its backend so a client can pick its media
/// layer from a stated value instead of inferring one. An unrecognised value
/// means "I cannot handle this room" - guessing would negotiate an SDP against
/// a transport with different semantics and fail in a way that looks like a
/// network problem.
class UnsupportedVoiceBackendException implements Exception {
  UnsupportedVoiceBackendException(this.backend);

  final String backend;

  @override
  String toString() =>
      'UnsupportedVoiceBackendException: this build cannot join a voice room '
      'on media backend "$backend".';
}

/// Everything one voice room's transport needs from the server, with the room
/// already bound.
///
/// Both room kinds implement this over their own routes: the guild
/// `{guildId}/channels/{channelId}/voice/...` family and the call
/// `voice/calls/{callId}/...` family are the same operations behind different
/// paths, so the transport above them is written once.
///
/// The vocabulary here is the server's neutral one, not any SFU's: sessions
/// are `mediaSessionId`, and a track says whether it is being published or
/// subscribed rather than whether it is "local" or "remote".
abstract class VoiceMediaApi {
  VoiceRoomKey get roomKey;

  /// The authoritative state of the room. Sufficient on its own, whatever was
  /// missed, whenever it is asked for.
  Future<VoiceRoomSnapshotDto> fetchSnapshot();

  /// Opens a media session. [primary] carries the microphone and runs the
  /// device-takeover path server-side; a secondary session (screen share from
  /// a separate process) deliberately skips it.
  Future<VoiceSessionDto> createSession({bool primary});

  /// Publishes and/or subscribes tracks in one negotiation.
  Future<VoiceNegotiateResponseDto> negotiate({
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
    required List<Map<String, dynamic>> tracks,
  });

  Future<VoiceRenegotiateResponseDto> renegotiate({
    required String mediaSessionId,
    required Map<String, dynamic> sessionDescription,
  });

  Future<void> closeTracks({
    required String mediaSessionId,
    required List<String> trackNames,
  });

  /// Reports what this client can actually see, so the server can decide what
  /// to serve it.
  ///
  /// [tileHeights] maps a publisher's user id to the height in **device
  /// pixels** of the largest tile this client draws them in, and it drives the
  /// simulcast layer each of their video tracks is served at. The map is
  /// authoritative rather than a delta: a publisher missing from it is one this
  /// client is not drawing.
  ///
  /// The reply is this client's own subscription set, which nothing here reads
  /// yet - the subscription-set contract is not implemented, and a small room
  /// is not sent one at all. Reporting is still worth doing on its own: it is
  /// the only measurement behind layer selection.
  Future<void> updateSubscriber({Map<String, int>? tileHeights});

  /// Claims a viewer slot on a screen share. Expires after 90 seconds, so it
  /// is re-posted on the heartbeat timer rather than once.
  Future<void> watchShare(String shareId);

  Future<void> unwatchShare(String shareId);

  /// `{ shareId: [userId, ...] }` for every share in the room.
  Future<Map<String, List<String>>> shareViewers();
}

/// Runs [operation], turning any Dio failure into a [VoiceMediaException] so
/// callers can branch on the contract's status codes rather than on Dio's.
Future<T> mapMediaErrors<T>(String name, Future<T> Function() operation) async {
  try {
    return await operation();
  } on DioException catch (e) {
    throw VoiceMediaException.from(e, name);
  }
}

/// How long to wait before retrying a failed negotiation, or null for "do not
/// retry". [attempt] is 1-based.
///
/// The policy, and why each arm is what it is:
///
///  * **409 stale** and **403/404** are never retried. The first means the
///    track is gone rather than late, so the identical body fails identically;
///    the other two cannot be fixed by asking again.
///  * **503** is contended - nothing about the request was wrong, so it is
///    retried quickly.
///  * **502** backs off exponentially from a second. Incident VNT-GE21R3P7 had
///    the same subscribe reattempted every 5-6 seconds against a snapshot that
///    could not have changed in between; retrying faster than the room state
///    actually moves spends requests to learn nothing, and turns one bad moment
///    into the burst that trips a degraded threshold.
Duration? voiceRetryDelay(VoiceMediaException e, int attempt) {
  // `isSessionGone` is checked before the 502 arm below, because it can *be* a 502 and retrying it
  // is the one thing guaranteed not to work.
  if (e.isFatal || e.isStale || e.isSessionGone) return null;
  if (e.isContended) return Duration(milliseconds: 250 * attempt);
  if (e.isTransportFailure) {
    return Duration(milliseconds: 1000 * (1 << (attempt - 1)));
  }
  return null;
}

/// Backends this client's media layer can actually drive.
///
/// Everything about the negotiation is neutral, so this list is short only
/// because there is one SFU today - not because the code below it is
/// Cloudflare-shaped.
const Set<String> supportedVoiceBackends = {'cloudflare'};
