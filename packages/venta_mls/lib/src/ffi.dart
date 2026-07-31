import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import 'errors.dart';

typedef _CallNative =
    Pointer<Utf8> Function(Pointer<Utf8> command, Pointer<Utf8> args);
typedef _CallDart =
    Pointer<Utf8> Function(Pointer<Utf8> command, Pointer<Utf8> args);

typedef _FreeNative = Void Function(Pointer<Utf8> ptr);
typedef _FreeDart = void Function(Pointer<Utf8> ptr);

/// The `dart:ffi` half of the engine: one call in, one JSON value out.
///
/// Everything is synchronous. The operations behind it are symmetric crypto on
/// payloads the size of a chat message - microseconds - with one exception,
/// bulk key-package generation, which the caller chunks rather than this layer
/// hiding behind an isolate. An isolate would not help anyway: the engine's
/// state is a process-global lock in Rust, so a second isolate would serialise
/// against the first while costing a message hop each way.
class MlsFfi {
  MlsFfi._(this._call, this._free);

  static MlsFfi? _instance;

  /// Opens the native library once per process.
  static MlsFfi instance() {
    final existing = _instance;
    if (existing != null) return existing;

    final library = _openLibrary();
    final created = MlsFfi._(
      library.lookupFunction<_CallNative, _CallDart>('venta_mls_call'),
      library.lookupFunction<_FreeNative, _FreeDart>('venta_mls_free'),
    );
    _instance = created;
    return created;
  }

  final _CallDart _call;
  final _FreeDart _free;

  static DynamicLibrary _openLibrary() {
    if (Platform.isAndroid) return DynamicLibrary.open('libventa_mls.so');
    // iOS links the engine statically into the app binary - see the podspec for
    // why it cannot be a dynamic library there.
    if (Platform.isIOS) return DynamicLibrary.process();
    if (Platform.isMacOS) return DynamicLibrary.process();
    if (Platform.isWindows) return DynamicLibrary.open('venta_mls.dll');
    if (Platform.isLinux) return DynamicLibrary.open('libventa_mls.so');
    throw UnsupportedError(
      'venta_mls has no native build for ${Platform.operatingSystem}',
    );
  }

  /// Runs one engine command.
  ///
  /// Returns the decoded `ok` value, or throws [MlsException] carrying the kind
  /// the Rust side tagged the failure with.
  Object? invoke(String command, [Map<String, Object?> args = const {}]) {
    final commandPtr = command.toNativeUtf8();
    final argsPtr = jsonEncode(args).toNativeUtf8();
    Pointer<Utf8> resultPtr = nullptr;
    try {
      resultPtr = _call(commandPtr, argsPtr);
      if (resultPtr == nullptr) {
        throw const MlsException(
          MlsErrorKind.mlsError,
          'the engine returned nothing',
        );
      }
      final decoded = jsonDecode(resultPtr.toDartString());
      if (decoded is! Map<String, dynamic>) {
        throw const MlsException(
          MlsErrorKind.mlsError,
          'the engine returned a malformed response',
        );
      }
      final error = decoded['error'];
      if (error != null) throw MlsException.parse(error.toString());
      return decoded['ok'];
    } finally {
      malloc.free(commandPtr);
      malloc.free(argsPtr);
      if (resultPtr != nullptr) _free(resultPtr);
    }
  }
}
