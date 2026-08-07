import 'package:dio/dio.dart';

import 'voice_media_dto.dart';
import 'voice_room_key.dart';
import 'voice_snapshot_dto.dart';

/// A failure returned by the voice media surface, classified the way the
/// contract classifies it.
///
/// The distinction is load-bearing rather than cosmetic. A **502** is the SFU
/// rejecting the operation outright: it is a real failure, and treating it as
/// success is what leaves a client believing it is subscribed to a peer no
/// media will ever arrive from. A **503** is the room being contended - the
/// change simply was not applied, and retrying shortly after works. Everything
/// else ([isFatal]) must not be retried blind.
class VoiceMediaException implements Exception {
  VoiceMediaException({
    required this.statusCode,
    required this.operation,
    this.error,
  });

  /// Builds one from a Dio failure, reading the `{ operation, error }` body
  /// the server sends with a 502.
  factory VoiceMediaException.from(DioException e, String fallbackOperation) {
    final data = e.response?.data;
    final body = data is Map<String, dynamic> ? data : const {};
    return VoiceMediaException(
      statusCode: e.response?.statusCode ?? 0,
      operation: body['operation'] as String? ?? fallbackOperation,
      error: body['error'] as String? ?? e.message,
    );
  }

  final int statusCode;
  final String operation;
  final String? error;

  /// The room was contended and the change was not applied. Transient; retry
  /// after a short delay.
  bool get isContended => statusCode == 503;

  /// The SFU rejected the operation. A real failure - roll back any local
  /// "subscribed" bookkeeping for the peer involved.
  bool get isTransportFailure => statusCode == 502;

  /// Not permitted, or the room does not exist. Retrying cannot help.
  bool get isFatal => statusCode == 403 || statusCode == 404;

  @override
  String toString() =>
      'VoiceMediaException($statusCode, $operation'
      '${error == null ? '' : ': $error'})';
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

/// Backends this client's media layer can actually drive.
///
/// Everything about the negotiation is neutral, so this list is short only
/// because there is one SFU today - not because the code below it is
/// Cloudflare-shaped.
const Set<String> supportedVoiceBackends = {'cloudflare'};
