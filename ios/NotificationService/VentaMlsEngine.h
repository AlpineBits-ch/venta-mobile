//
//  The MLS engine's C ABI, as the extension sees it.
//
//  The app reaches these same two symbols through `dart:ffi`
//  (packages/venta_mls/lib/src/ffi.dart); the extension cannot, because it runs
//  no Dart. It links the identical `libventa_mls.a` and calls them directly, so
//  both paths are the same openmls build reading the same state file - which is
//  the only way a message decrypted in a notification stays consistent with the
//  same message decrypted in the app.
//
#ifndef VentaMlsEngine_h
#define VentaMlsEngine_h

/// Runs one engine command. `args_json` is a JSON object; the result is a JSON
/// object with either an `ok` or an `error` member. The returned pointer is
/// owned by the caller and must be released with `venta_mls_free`.
char *venta_mls_call(const char *command, const char *args_json);

/// Releases a string returned by `venta_mls_call`.
void venta_mls_free(char *ptr);

#endif /* VentaMlsEngine_h */
