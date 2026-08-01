import 'dart:convert';

/// Encodes/decodes message bodies for the wire. `content` is always
/// base64(UTF-8), even for `Plain` messages - matches Alpine.
///
/// The wrapping is the *server's*, not this client's: `CreateMessageDto.Content`
/// is a `string` but `Message.Content` is a `byte[]`, so the server stores
/// `Encoding.UTF8.GetBytes(dto.Content)` and `System.Text.Json` base64s it on
/// the way back out. Whatever was POSTed therefore comes back as
/// `base64(utf8(posted))`, for a plain body and a base64 MLS ciphertext alike.
///
/// The encrypted read path is exactly [decodeStrict] followed by the engine -
/// see `MessageDecryptor`. Missing that layer is what made every encrypted
/// message unreadable on this client while the desktop one worked.
abstract final class MessageContentCodec {
  static String encode(String plaintext) =>
      base64Encode(utf8.encode(plaintext));

  static String decode(String wireContent) {
    try {
      return decodeStrict(wireContent);
    } catch (_) {
      return wireContent;
    }
  }

  /// Same unwrap, but throwing rather than passing the raw value through.
  ///
  /// The lenient [decode] is right for display - showing the bytes beats
  /// showing nothing. It is wrong before a decrypt: handing the engine an
  /// undecoded value makes it fail deep inside TLS deserialization, where the
  /// error says nothing about the actual problem being the envelope. Mirrors
  /// Alpine's `fromBase64`, which does not swallow either.
  static String decodeStrict(String wireContent) =>
      utf8.decode(base64Decode(wireContent));
}
