import 'dart:convert';
import 'dart:typed_data';

import 'package:venta_mobile/core/storage/state_file_cipher.dart';

/// A stand-in for the engine's AES-256-GCM, for tests that cannot load the
/// native library.
///
/// Deliberately **not** a no-op. What these tests need to establish is that
/// `MlsStore` routes both files through the cipher, that a file written under
/// one key does not open under another, and that nothing recognisable survives
/// on disk - all of which a keyed transform demonstrates and an identity
/// function would not. That the real transform is authenticated encryption is
/// established in the Rust tests (`the_state_file_holds_no_readable_key_material`,
/// `a_sealed_state_file_is_useless_without_its_key`), which run against the
/// actual primitive.
class FakeStateCipher implements StateFileCipher {
  FakeStateCipher(this.keyB64);

  final String keyB64;

  late final Uint8List _key = Uint8List.fromList(utf8.encode(keyB64));

  /// Set by tests that need to prove a failure to open is not silently
  /// swallowed.
  bool failToOpen = false;

  int sealCount = 0;
  int openCount = 0;

  static final _magic = ascii.encode(StateFileCipher.magic);

  @override
  Future<List<int>> seal(List<int> plaintext) async {
    sealCount++;
    return [..._magic, ..._xor(plaintext)];
  }

  @override
  Future<List<int>> open(List<int> sealed) async {
    openCount++;
    if (failToOpen) throw StateError('FakeStateCipher: refused');
    if (!StateFileCipher.isSealed(sealed)) {
      throw StateError('FakeStateCipher: not a sealed blob');
    }
    return _xor(sealed.sublist(_magic.length));
  }

  List<int> _xor(List<int> bytes) => [
    for (var i = 0; i < bytes.length; i++) bytes[i] ^ _key[i % _key.length],
  ];
}
