import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../network/api_client.dart';

/// What the server knows about a stored backup blob. Metadata only - the blob
/// itself is opaque ciphertext the server never parses.
class BackupMetaDto {
  const BackupMetaDto({
    required this.version,
    required this.recoveryKeyVersion,
    required this.sizeBytes,
    required this.updatedAt,
    required this.etag,
  });

  factory BackupMetaDto.fromJson(Map<String, dynamic> json) => BackupMetaDto(
    version: (json['version'] as num?)?.toInt() ?? 0,
    recoveryKeyVersion: (json['recoveryKeyVersion'] as num?)?.toInt() ?? 0,
    sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
    etag: json['etag'] as String? ?? '',
  );

  final int version;

  /// Binds the blob to the recovery-key envelope it was sealed under. A mismatch
  /// means the key was rotated and this blob can no longer be opened - which the
  /// user has to be told, not discover during a restore.
  final int recoveryKeyVersion;
  final int sizeBytes;
  final DateTime? updatedAt;
  final String etag;
}

/// Per-device encrypted backup storage. Contract §C.2.
class MlsBackupApi {
  MlsBackupApi({required this.client});

  final ApiClient client;

  /// 16 MiB, matching the server's cap. Checked client-side too so a device
  /// whose store has grown past it says something useful rather than watching a
  /// 413 come back after uploading the whole thing.
  static const maxBlobBytes = 16 * 1024 * 1024;

  String _base(String deviceId) =>
      '/api/v1/identity/devices/client/${Uri.encodeComponent(deviceId)}/backup';

  Future<BackupMetaDto?> meta(String deviceId) async {
    try {
      final response = await client.dio.get<Map<String, dynamic>>(
        client.url('${_base(deviceId)}/meta'),
      );
      final data = response.data;
      return (data == null || data.isEmpty)
          ? null
          : BackupMetaDto.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Uploads the envelope.
  ///
  /// [etag] is the one this device last saw. Passing it is what stops two
  /// sessions of the same device from silently overwriting each other's blob;
  /// the server answers 409 rather than taking the second write.
  Future<BackupMetaDto> upload({
    required String deviceId,
    required String envelope,
    required int recoveryKeyVersion,
    String? etag,
  }) async {
    final bytes = Uint8List.fromList(utf8.encode(envelope));
    if (bytes.length > maxBlobBytes) {
      throw StateError(
        'This device\'s backup is ${(bytes.length / 1048576).toStringAsFixed(1)} '
        'MiB, over the 16 MiB limit.',
      );
    }

    final response = await client.dio.put<Map<String, dynamic>>(
      client.url(_base(deviceId)),
      data: Stream<List<int>>.value(bytes),
      options: Options(
        contentType: 'application/octet-stream',
        headers: {
          'Content-Length': bytes.length,
          'X-Backup-Version': 1,
          'X-Backup-Recovery-Key-Version': recoveryKeyVersion,
          'If-Match': ?etag,
        },
      ),
    );
    return BackupMetaDto.fromJson(response.data ?? const {});
  }

  /// Downloads the envelope. Null when this device has never stored one.
  ///
  /// Every read writes a server-side audit row and pushes `identity.BackupRead`
  /// to the account's other devices - backup exfiltration has to be visible, so
  /// this is deliberately not a quiet call.
  Future<String?> download(String deviceId) async {
    try {
      final response = await client.dio.get<List<int>>(
        client.url(_base(deviceId)),
        options: Options(responseType: ResponseType.bytes),
      );
      final data = response.data;
      if (data == null || data.isEmpty) return null;
      return utf8.decode(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> delete(String deviceId) async {
    await client.dio.delete<void>(client.url(_base(deviceId)));
  }
}
