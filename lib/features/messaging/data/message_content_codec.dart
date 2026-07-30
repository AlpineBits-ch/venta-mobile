import 'dart:convert';

/// Encodes/decodes message bodies for the wire. `content` is always
/// base64(UTF-8), even for `Plain` messages - matches Alpine.
///
/// This is the seam where MLS encrypt/decrypt gets inserted later: every
/// message is currently treated as plaintext regardless of its
/// `encryptionState`, per the v1 "plaintext-first" scope decision.
abstract final class MessageContentCodec {
  static String encode(String plaintext) =>
      base64Encode(utf8.encode(plaintext));

  static String decode(String wireContent) {
    try {
      return utf8.decode(base64Decode(wireContent));
    } catch (_) {
      return wireContent;
    }
  }
}
