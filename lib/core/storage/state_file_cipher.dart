import 'dart:convert';
import 'dart:typed_data';

import 'package:venta_mls/venta_mls.dart';

/// Seals the two files `MlsStore` owns.
///
/// `mls_message_cache.json` is the plaintext of every message this device has
/// ever decrypted, and `mls_group_registry.json` names every group it belongs
/// to. Both used to be plain JSON in a directory Android's auto-backup includes
/// by default and iOS backs up unconditionally, so a restore onto another
/// handset handed over the complete readable history with no keychain access and
/// no unlock.
///
/// An interface rather than a concrete class only so tests can substitute a
/// cipher they can reason about without a native library loaded; the production
/// implementation is the engine's AES-256-GCM, the same primitive the backup
/// envelope uses.
abstract class StateFileCipher {
  /// Prefix the engine writes on a sealed host blob. Recognised here so a file
  /// written before this existed still loads and can be sealed in place.
  static const magic = 'VENTABOX1';

  static final _magicBytes = Uint8List.fromList(ascii.encode(magic));

  static bool isSealed(List<int> bytes) {
    if (bytes.length < _magicBytes.length) return false;
    for (var i = 0; i < _magicBytes.length; i++) {
      if (bytes[i] != _magicBytes[i]) return false;
    }
    return true;
  }

  Future<List<int>> seal(List<int> plaintext);

  /// Throws when [sealed] is not a sealed blob or the key is wrong.
  ///
  /// Deliberately not "return the input, it might be legacy". The caller decides
  /// that by looking at [isSealed] *before* calling, because a silent fallback
  /// would hand JSON parsing a blob of ciphertext, conclude the cache was
  /// corrupt, and replace it with an empty one - permanently losing plaintext
  /// that MLS will not produce a second time.
  Future<List<int>> open(List<int> sealed);
}

/// [StateFileCipher] backed by the MLS engine.
class EngineStateFileCipher implements StateFileCipher {
  EngineStateFileCipher({required this.stateKeyB64, VentaMls? engine})
    : _engine = engine ?? VentaMls();

  /// 32 bytes, base64. Lives in the OS keychain, which is precisely what a
  /// device backup does not carry.
  final String stateKeyB64;
  final VentaMls _engine;

  @override
  Future<List<int>> seal(List<int> plaintext) async => base64Decode(
    await _engine.sealHostBlob(
      plaintextB64: base64Encode(plaintext),
      stateKeyB64: stateKeyB64,
    ),
  );

  @override
  Future<List<int>> open(List<int> sealed) async => base64Decode(
    await _engine.openHostBlob(
      sealedB64: base64Encode(sealed),
      stateKeyB64: stateKeyB64,
    ),
  );
}
