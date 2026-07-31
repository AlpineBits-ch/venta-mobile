# venta_mls

The MLS (RFC 9420) engine for venta_mobile: [openmls](https://openmls.tech) 0.8.1
behind a `dart:ffi` boundary.

This is a port of Alpine's `src-tauri/src/crypto/mls.rs`, kept deliberately
line-for-line equivalent. Both clients talk to the same server, join the same
groups and read each other's ciphertext — a divergence here is a divergence in
the wire protocol, and the symptom is a mobile device that cannot open a Welcome
the desktop client wrote.

**Ciphersuite:** `MLS_128_DHKEMX25519_AES128GCM_SHA256_Ed25519`, matching Alpine.
A group created under one ciphersuite cannot be joined by a device offering a key
package built under another.

## Building

Requires a Rust toolchain. Everything else is wired into the normal Flutter build
— `flutter run` compiles the crate and packages the result.

```
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
cargo install cargo-ndk
```

Android additionally needs the NDK (Android Studio → SDK Manager → SDK Tools →
NDK). The Gradle task finds it via `android.ndkDirectory`, so no environment
variable is needed.

iOS needs `aarch64-apple-ios` (device) and `aarch64-apple-ios-sim` /
`x86_64-apple-ios` (simulator); `ios/build_rust.sh` adds whichever Xcode asks for.

**The iOS path has not been built on a Mac.** The podspec and build script are
written against the standard static-library pattern — script phase produces
`ios/build/libventa_mls.a`, `-force_load` keeps the symbols, `Classes/` holds a
reference so the archive is not dropped — but nothing here has exercised it.
Expect to iterate on it the first time.

## Why a JSON C ABI rather than flutter_rust_bridge

One entry point taking `(command, args-json)` and returning `{"ok": …}` or
`{"error": "Kind: message"}`:

```rust
venta_mls_call(command: *const c_char, args_json: *const c_char) -> *mut c_char
venta_mls_free(ptr: *mut c_char)
```

Alpine reaches the same logic through Tauri's IPC, which already gives it JSON in
and JSON out. Matching that shape means `lib/venta_mls.dart` is a
transliteration of `mls.service.ts` rather than a reinterpretation of it, and
adding an operation later touches two match arms instead of a generated binding,
a codegen step and a build-time dependency.

Errors carry a kind prefix (`WrongEpoch`, `UnknownSender`, `GroupNotFound`,
`KeyNotFound`, `ValidationError`, `MlsError`) so callers can branch without
matching on prose — same vocabulary as Alpine's `parseMlsError`. Panics are
caught at the boundary and returned as `MlsError`; the release profile
deliberately does **not** set `panic = "abort"`, because aborting would take the
whole app down over one unreadable message.

## Threading

Every call is synchronous. The operations are symmetric crypto on
message-sized payloads — microseconds — with one exception: bulk key-package
generation, which the Dart layer chunks (10 at a time, yielding between) rather
than hiding behind an isolate. An isolate would not help anyway, since the
engine's state is a process-global lock in Rust.

## Storage

`initStorage(directory)` points the engine at `<directory>/mls_state.json` and
restores whatever is there. The path is passed in rather than discovered: Flutter
owns the app's directory layout via `path_provider`, and the app scopes it per
account (see `MlsStore.stateDirectory`).

Writes go through a temp file and a rename. Alpine writes in place, which a
desktop process can afford; Android kills backgrounded apps freely, and a
half-written `mls_state.json` is every group this device belongs to, gone.

## Tests

```
cargo test --manifest-path packages/venta_mls/rust/Cargo.toml
```

Four round-trip tests, each giving its simulated devices their own `MlsState` so
that two members of one group do not share a `groups` map and test nothing:
message exchange, discarding a rejected commit without forking, removal
detection, and state surviving a restart.
