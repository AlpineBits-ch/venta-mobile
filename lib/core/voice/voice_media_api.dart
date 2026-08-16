import 'package:dio/dio.dart';

import '../../features/billing/data/models/entitlement_denial.dart';
import 'video_layers.dart';
import 'voice_media_dto.dart';
import 'voice_room_key.dart';
import 'voice_snapshot_dto.dart';

/// A failure returned by the voice media surface, classified the way the
/// contract classifies it.
///
/// The distinctions are load-bearing rather than cosmetic, and the three `503`s
/// are three different situations sharing one status:
///
///  * **`voiceNotConfigured`** is a self-hosted install with no SFU. Not a
///    fault, not transient, and not something to retry - the feature does not
///    exist on this instance and should be hidden.
///  * **`sfuUnavailable`** is the control plane being unreachable. Retry with
///    backoff, and **do not tear anything down**: media does not travel the
///    path that failed, so every call already in progress is unaffected.
///  * **anything else `503`** is the room being contended - the change simply
///    was not applied, and retrying shortly after works.
///
/// **502** is the SFU rejecting a control-plane operation. A real failure, and
/// not fixed by asking again.
///
/// Everything else ([isFatal]) must not be retried blind.
class VoiceMediaException implements Exception {
  VoiceMediaException({
    required this.statusCode,
    required this.operation,
    this.error,
    this.action,
  });

  /// Builds one from a Dio failure. The 502 body is `{ operation, error }` and
  /// the 503 bodies are `{ error, action }`, where `error` is a code rather
  /// than a message.
  factory VoiceMediaException.from(DioException e, String fallbackOperation) {
    final data = e.response?.data;
    final body = data is Map<String, dynamic> ? data : const {};
    return VoiceMediaException(
      statusCode: e.response?.statusCode ?? 0,
      operation: body['operation'] as String? ?? fallbackOperation,
      error: body['error'] as String? ?? e.message,
      action: body['action'] as String?,
    );
  }

  final int statusCode;
  final String operation;
  final String? error;

  /// What the server says to do about it, e.g. `contactOperator` or `retry`.
  final String? action;

  /// This instance has no SFU configured at all.
  ///
  /// A supported state rather than a fault - a self-hosted install that has not
  /// set voice up - so the answer is to hide the feature and say so, not to
  /// retry or to show a failure. There is no capability read to ask up front,
  /// so this is discovered by trying once and is worth caching for the session.
  bool get isVoiceNotConfigured =>
      statusCode == 503 && error == 'voiceNotConfigured';

  /// The control plane could not be reached. Retry with backoff.
  ///
  /// **Nothing is torn down on this.** The failure is on the path that mints
  /// connections, not the one media rides, so a call already in progress has
  /// not noticed and must not be ended on this client's initiative.
  bool get isSfuUnavailable => statusCode == 503 && error == 'sfuUnavailable';

  /// The room was contended and the change was not applied. Transient; retry
  /// after a short delay.
  bool get isContended =>
      statusCode == 503 && !isVoiceNotConfigured && !isSfuUnavailable;

  /// The SFU rejected the operation. A real failure - roll back any local
  /// bookkeeping for whatever it was about.
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
      '${error == null ? '' : ': $error'})';
}

/// The room named a media backend this build has no implementation for.
///
/// The connection handshake declares its backend so a client can pick its media
/// layer from a stated value instead of inferring one. An unrecognised value
/// means "I cannot handle this room" - guessing would drive a transport with
/// different semantics and fail in a way that looks like a network problem.
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
/// The vocabulary is the server's neutral one, not the SFU's. What this backend
/// still decides is *whether* a client may connect, *what* it may send, and the
/// roster the rest of the product reads - it no longer carries any media or any
/// negotiation, so nothing here names an SDP, a transceiver or a mid.
abstract class VoiceMediaApi {
  VoiceRoomKey get roomKey;

  /// The authoritative state of the room. Sufficient on its own, whatever was
  /// missed, whenever it is asked for.
  Future<VoiceRoomSnapshotDto> fetchSnapshot();

  /// Mints a connection to the SFU node this room lives on.
  ///
  /// [primary] carries the microphone and runs the device-takeover path
  /// server-side. A *secondary* connection - a screen share published from a
  /// separate process - must pass `primary: false` **and** a [tag]: the SFU
  /// keys participants by identity and disconnects an earlier session that
  /// reappears under the same one, so a secondary minted as primary kicks this
  /// client's own call off the air.
  ///
  /// Cheap and repeatable. It does not touch the roster, does not re-announce
  /// anybody, and does not disturb a connection already held - only the token is
  /// new. That is what makes it the answer to an expired token, and it is also
  /// why it must not be called on every attempt of a reconnect ladder: doing so
  /// mints tokens at the SFU's retry rate to solve a problem that has not
  /// occurred.
  Future<VoiceConnectionDto> createConnection({bool primary, String? tag});

  /// Declares tracks that are **already published** through the SDK.
  ///
  /// The media does not depend on this - the picture is flowing by the time it
  /// is called - but the roster, the viewer counts, the entitlement check and
  /// every other client's UI do. Nothing in the product can see a publisher who
  /// skipped it.
  ///
  /// Both halves of a screen share go in one call, which is what lets a
  /// receiving client group them into a single tile from the two
  /// `TrackPublished` events that follow.
  ///
  /// [video] describes what this client intends to send and is optional. It is
  /// only read when the body carries video, because a video ceiling has never
  /// had anything to say about a microphone.
  ///
  /// Answers to handle: a `200` carrying `degradations` is a success that was
  /// clamped, and a `403` carrying an entitlement denial is a publish that will
  /// reach nobody - stop the local track, because the connection token does not
  /// permit it either.
  Future<VoicePublishResultDto> declarePublish({
    required List<String> trackNames,
    Map<String, dynamic>? video,
  });

  /// Marks tracks closed and tells peers to drop them. Unpublishing `audio`
  /// marks this participant no longer publishing.
  Future<void> unpublish({required List<String> trackNames});

  /// Declares a resolution change made **without republishing** - a share that
  /// switched source, a camera that changed size.
  ///
  /// It exists because a ceiling computed once at publish time is one a later
  /// resolution change walks straight past. It never refuses anything, and
  /// declaring nothing leaves the ceiling exactly where the last publish put
  /// it - so an unchanged resolution needs no call at all.
  Future<void> declareVideo(Map<String, dynamic> video);

  /// Reports what this client can actually see, so the server can decide what
  /// to serve it. Everything here only ever *reduces* what is sent, which is
  /// why it needs no permission beyond speaking for oneself.
  ///
  /// [paused] is this client backgrounded or hidden. It **drops video, never
  /// audio** - a backgrounded client is still in the conversation.
  ///
  /// [pinned] names publishers to keep subscribed whatever the ranking says.
  /// Capped server-side (3 by default), and a pin over the cap is dropped
  /// silently rather than refused.
  ///
  /// [pausedPublishers] are publishers whose tile this client has collapsed.
  /// Video only, the same as [paused].
  ///
  /// [tileHeights] maps a publisher's user id to the height in **device pixels**
  /// of the largest tile this client draws them in, and it is the only
  /// measurement behind layer selection. The map is authoritative rather than a
  /// delta: a publisher missing from it is one this client is not drawing.
  ///
  /// [screenAudioShares] names shares whose audio half to deliver. Share audio
  /// is off by default because most shares carry none, and distributing it
  /// doubles the stream count of the most expensive thing in a room.
  ///
  /// **Every field is optional and an omitted one is left alone**, so a tile
  /// resize is a body with `tileHeights` in it and nothing else. An empty list
  /// is not an omission: it clears that set.
  ///
  /// The reply is this client's own subscription set, so a caller can act on
  /// what it just reported without waiting for the push.
  Future<VoiceSubscriptionSetDto?> updateSubscriber({
    bool? paused,
    Map<String, int>? tileHeights,
    List<String>? pinned,
    List<String>? pausedPublishers,
    List<String>? screenAudioShares,
  });

  /// Claims a viewer slot on a screen share. Expires after 90 seconds, so it
  /// is re-posted on the heartbeat timer rather than once.
  Future<void> watchShare(String shareId);

  Future<void> unwatchShare(String shareId);

  /// `{ shareId: [userId, ...] }` for every share in the room.
  Future<Map<String, List<String>>> shareViewers();
}

/// Runs [operation], turning any Dio failure into a [VoiceMediaException] so
/// callers can branch on the contract's status codes rather than on Dio's.
///
/// With one exception, checked first: a `403` carrying the entitlement refusal
/// body is an [EntitlementDenialException] instead. That is a publish the
/// server would not carry out at any size - a `none` rung, or no publisher slot
/// free - and it is the one refusal on these routes with a plain explanation
/// attached. Folded into [VoiceMediaException] it would arrive as `isFatal`,
/// indistinguishable from "no such room", and the camera button would fail
/// silently.
Future<T> mapMediaErrors<T>(String name, Future<T> Function() operation) async {
  try {
    return await operation();
  } on DioException catch (e) {
    final denial = entitlementDenialOf(e);
    if (denial != null) throw EntitlementDenialException(denial);
    throw VoiceMediaException.from(e, name);
  }
}

/// How long to wait before retrying a failed media call, or null for "do not
/// retry". [attempt] is 1-based.
///
/// The policy, and why each arm is what it is:
///
///  * **`voiceNotConfigured`** is never retried. There is no SFU on this
///    instance and there will not be one before the operator configures it, so
///    a retry loop is a request per interval for the life of the session.
///  * **403/404** cannot be fixed by asking again.
///  * **contended 503** is the request being fine and the room being busy, so
///    it is retried quickly.
///  * **`sfuUnavailable` 503** and **502** back off exponentially from a
///    second. Incident VNT-GE21R3P7 had the same operation reattempted every
///    5-6 seconds against a state that could not have changed in between;
///    retrying faster than the thing being retried against actually moves
///    spends requests to learn nothing, and turns one bad moment into the burst
///    that trips a degraded threshold.
Duration? voiceRetryDelay(VoiceMediaException e, int attempt) {
  if (e.isFatal || e.isVoiceNotConfigured) return null;
  if (e.isContended) return Duration(milliseconds: 250 * attempt);
  if (e.isSfuUnavailable || e.isTransportFailure) {
    return Duration(milliseconds: 1000 * (1 << (attempt - 1)));
  }
  return null;
}

/// Backends this client's media layer can actually drive.
///
/// Short because there is one SFU today, not because the code below it is
/// LiveKit-shaped: everything above [VoiceMediaApi] is written in the server's
/// neutral vocabulary, which is what made the move off the previous SFU a
/// change to one file rather than to the feature.
const Set<String> supportedVoiceBackends = {'livekit'};

/// Re-exported so callers that build a publish body do not have to import the
/// layer module separately.
typedef VoiceVideoIntent = VideoPublishIntent;
